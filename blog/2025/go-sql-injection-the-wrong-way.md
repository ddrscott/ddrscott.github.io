---
title: "Go SQL Injection: A Tale of Two Queries"
date: 2025-12-13
created: 2025-12-13T00:00:00Z
type: blog
status: settled
tags: [sql]
publish: [ddrscott]
source: import
description: "Learn how to build dynamic SQL filters in Go the right way by first seeing the wrong way. A practical guide to avoiding SQL injection with parameterized queries."
image: /images/2025/go-sql-injection.png
prompt: "Import from blog post: 2025/go-sql-injection-the-wrong-way.md"
---

# Go SQL Injection: A Tale of Two Queries

<img class="featured" src="/images/2025/go-sql-injection.png" alt="Cartoon graveyard with tombstone reading 'RIP TABLE CARS' and a sad ghost" />

Wouldn't it be great if every developer just *knew* not to concatenate user input into SQL strings? Like, built into our DNA alongside the instinct to breathe and the compulsion to argue about tabs vs spaces?

Alas, we're not there yet. So let's build a car search filter in Go and do it wrong first. Because nothing teaches quite like watching things explode.

## The Setup

Picture this: You're building a car dealership website. Users want to filter cars by cost, color, and year. Simple enough. You reach for `fmt.Sprintf` because it's right there, it's familiar, it's... about to ruin your day.

## The Wrong Way (Please Don't Do This)

```go
package main

import (
    "fmt"
)

// DON'T DO THIS - SQL INJECTION VULNERABLE
func buildQueryWrong(filters map[string]string) string {
    query := "SELECT * FROM cars WHERE 1=1"

    // Allowed filter fields - at least we tried
    allowedFields := map[string]bool{
        "cost":  true,
        "color": true,
        "year":  true,
    }

    for field, value := range filters {
        if allowedFields[field] && value != "" {
            // DANGER: Direct string concatenation!
            // This is the line that gets you on the news.
            query += fmt.Sprintf(" AND %s = '%s'", field, value)
        }
    }

    return query
}

func main() {
    // Normal usage looks fine...
    filters := map[string]string{
        "color": "red",
        "year":  "2020",
    }
    fmt.Println("Normal query:")
    fmt.Println(buildQueryWrong(filters))

    // But an attacker can inject SQL!
    maliciousFilters := map[string]string{
        "color": "red'; DROP TABLE cars; --",
    }
    fmt.Println("\nMalicious query (INJECTION!):")
    fmt.Println(buildQueryWrong(maliciousFilters))
}
```

Run this and weep:

```
Normal query:
SELECT * FROM cars WHERE 1=1 AND color = 'red' AND year = '2020'

Malicious query (INJECTION!):
SELECT * FROM cars WHERE 1=1 AND color = 'red'; DROP TABLE cars; --'
```

See that `DROP TABLE cars`? That's not a filter. That's a resume-generating event.

The `--` at the end comments out anything after it, so your carefully crafted query becomes a two-statement demolition derby. First it selects red cars, then it deletes every car you've ever known.

## Why This Happens

The fundamental problem: we're mixing **code** (SQL structure) with **data** (user values). When you concatenate strings, the database can't tell the difference between:

- `'red'` - a color the user wants
- `'red'; DROP TABLE cars; --'` - a cry for help wrapped in malice

## The Right Way (Parameterized Queries)

The fix is elegant: keep code and data separate. Let the database driver handle escaping. Here's a proper implementation:

```go
package main

import (
    "context"
    "database/sql"
    "fmt"
    "strings"

    _ "github.com/lib/pq" // PostgreSQL driver
)

// FilterField defines allowed fields and their SQL operators
type FilterField struct {
    Column   string
    Operator string // "=", ">=", "<=", "LIKE", etc.
}

// Whitelist of allowed filter fields
// This is your bouncer. Nobody gets in without being on the list.
var allowedFilters = map[string]FilterField{
    "cost":     {Column: "cost", Operator: "<="},
    "cost_min": {Column: "cost", Operator: ">="},
    "color":    {Column: "color", Operator: "="},
    "year":     {Column: "year", Operator: "="},
    "year_min": {Column: "year", Operator: ">="},
    "year_max": {Column: "year", Operator: "<="},
}

// QueryBuilder constructs parameterized SQL queries
type QueryBuilder struct {
    conditions []string
    args       []any
    paramCount int
}

func NewQueryBuilder() *QueryBuilder {
    return &QueryBuilder{
        conditions: make([]string, 0),
        args:       make([]any, 0),
        paramCount: 0,
    }
}

func (qb *QueryBuilder) AddFilter(filterKey string, value any) bool {
    field, ok := allowedFilters[filterKey]
    if !ok || value == nil || value == "" {
        return false // Not on the list? Not my problem.
    }

    qb.paramCount++
    // $1, $2, $3... for PostgreSQL
    // Use ? for MySQL, @p1 for SQL Server
    placeholder := fmt.Sprintf("$%d", qb.paramCount)
    condition := fmt.Sprintf("%s %s %s", field.Column, field.Operator, placeholder)

    qb.conditions = append(qb.conditions, condition)
    qb.args = append(qb.args, value)
    return true
}

func (qb *QueryBuilder) Build(baseQuery string) (string, []any) {
    if len(qb.conditions) == 0 {
        return baseQuery, qb.args
    }

    whereClause := strings.Join(qb.conditions, " AND ")
    return baseQuery + " WHERE " + whereClause, qb.args
}

// SearchCars demonstrates real database usage
func SearchCars(ctx context.Context, db *sql.DB, filters map[string]any) (*sql.Rows, error) {
    qb := NewQueryBuilder()

    for key, value := range filters {
        qb.AddFilter(key, value)
    }

    query, args := qb.Build("SELECT id, make, model, color, year, cost FROM cars")

    // Safe! The driver handles all escaping.
    return db.QueryContext(ctx, query, args...)
}

func main() {
    // Demo the query building
    filters := map[string]any{
        "color":    "red",
        "year_min": 2018,
        "cost":     50000,
    }

    qb := NewQueryBuilder()
    for key, value := range filters {
        qb.AddFilter(key, value)
    }

    query, args := qb.Build("SELECT * FROM cars")

    fmt.Println("Safe Query:")
    fmt.Println(query)
    fmt.Printf("Parameters: %v\n", args)

    // Even malicious input is safe now
    fmt.Println("\n--- Attempted Attack ---")
    maliciousFilters := map[string]any{
        "color": "red'; DROP TABLE cars; --",
    }

    qb2 := NewQueryBuilder()
    for key, value := range maliciousFilters {
        qb2.AddFilter(key, value)
    }

    query2, args2 := qb2.Build("SELECT * FROM cars")

    fmt.Println("Query:")
    fmt.Println(query2)
    fmt.Printf("Parameters: %v\n", args2)
    fmt.Println("\nThe malicious string is just a literal value now.")
    fmt.Println("Good luck finding a car with that color.")
}
```

Output:

```
Safe Query:
SELECT * FROM cars WHERE color = $1 AND year >= $2 AND cost <= $3
Parameters: [red 2018 50000]

--- Attempted Attack ---
Query:
SELECT * FROM cars WHERE color = $1
Parameters: [red'; DROP TABLE cars; --]

The malicious string is just a literal value now.
Good luck finding a car with that color.
```

The attacker's payload becomes a literal string. The database looks for a car with the color `red'; DROP TABLE cars; --` and finds nothing. Your tables survive. Your job survives.

## The Cheat Sheet

| Wrong Way | Right Way |
|-----------|-----------|
| `fmt.Sprintf("... = '%s'", value)` | `db.Query("... = $1", value)` |
| Values embedded in SQL string | Values passed as separate arguments |
| Database sees `DROP TABLE` as SQL | Database sees `DROP TABLE` as text |
| Career-limiting | Career-enhancing |

## Rules to Live By

1. **Never** use string concatenation for SQL with user input
2. **Always** use parameterized queries (`$1`, `?`, `@p1`)
3. **Whitelist** column names - don't let users specify arbitrary columns
4. **Test** with malicious input before your users do

## Placeholder Syntax by Database

Because nothing in databases is ever consistent:

| Database | Placeholder |
|----------|-------------|
| PostgreSQL | `$1`, `$2`, `$3` |
| MySQL | `?`, `?`, `?` |
| SQL Server | `@p1`, `@p2`, `@p3` |
| SQLite | `?` or `$1` (both work) |

## Closing Thoughts

SQL injection has been in the OWASP Top 10 since... well, since there was an OWASP Top 10. It's a solved problem. The solution has been known for decades. And yet, here we are, still writing blog posts about it.

Maybe someday we'll have programming languages that make the wrong thing impossible instead of just difficult. Until then, we have parameterized queries and the eternal vigilance of code review.

Now go audit your codebase. I'll wait.

---

*Have a SQL war story? Found this useful? Drop a comment below. Misery loves company, and so does learning.*
