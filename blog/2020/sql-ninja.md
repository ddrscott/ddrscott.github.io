---
title: "Slice and Dice SQL with SQL Ninja"
date: 2020-06-08
created: 2020-06-08T00:00:00Z
type: blog
status: settled
tags: [python, sql]
publish: [ddrscott]
source: import
description: "SQL + Jinja = SQL Templating Done Right™"
image: /images/2020/sql-ninja-head.png
prompt: "Import from blog post: 2020/sql-ninja.markdown"
---

# Slice and Dice SQL with [SQL Ninja](https://github.com/ddrscott/sql-ninja)

<img class="featured" src="/images/2020/sql-ninja-head.png" alt="SQL Ninja Header" />

I write a lot of SQL. It's my primary language for various reasons which we won't get into at here,
but even after using it for so long, SQL can still be a pain for some repetitive tasks.

## Problem

Here's a SQL expression for pivoting some expenses by category:

```sql
SELECT
    DATEFORMAT(entry_dt, 'yyyy-mm') as year_month,
    SUM(CASE WHEN category = 'katanas'   THEN amount END) AS katanas,
    SUM(CASE WHEN category = 'shurikens' THEN amount END) AS shurikens,
    SUM(CASE WHEN category = 'hooks'     THEN amount END) AS hooks,
    SUM(CASE WHEN category = 'shoes'     THEN amount END) AS shoes,
    SUM(CASE WHEN category = 'disguises' THEN amount END) AS disguises,
    SUM(
       CASE WHEN category NOT IN ('katanas','shurikens','hooks','shoes','disguises')
       THEN amount END
    ) AS other_amount,
    SUM(amount) AS total_amount
FROM expenses
ORDER BY year_month, total_amount
```

Can we see the repetitive SQL going on? Here's a hint: `SUM(CASE WHEN(...)) AS ...`.

Wouldn't it be nice to make a list of categories and have the SQL generated for you?
Wouldn't it be nice to use generated SQL directly from command line?

## Solution

SQL is a declarative language. HTML is a declarative language. HTML has so many template languages to choose from,
but SQL has so few.

Enter SQL Ninja.

SQL Ninja uses the popular [Jinja Templating Engine](https://jinja.palletsprojects.com/) which typically generates
HTML, but we can use it to generate SQL.

```sh
pip install sql-ninja
```

Now, let's create a simple SQL file:

```sh
cat > hello.sql <<SQL
SELECT 'world'
SQL
```

From here, we can use the `sql` command provided by [sql-ninja](https://pypi.org/project/sql-ninja/) to transform the
SQL.

```sh
sql hello.sql
# => SELECT 'world'
```

That wasn't very exciting. Let's try to template it:


```sh
cat > hello.sql <<SQL
SELECT '{{ msg }}'
SQL
```

And render the template:
```sh
sql hello.sql
# => SELECT ''
```

What happened? We got a blank message. This is because we didn't provide one to the template engine.
Try this instead:

```sh
sql hello.sql msg='World!!!'
# => SELECT 'World!!!'
```

We did it!

### Starting a New Project

In the real world, we work with work with projects that have a lot of other files. We probably don't want our main
projects root directory littered with `*.sql` files. SQL Ninja recommends putting templates in the following directory:

```
.
└── sql
    └── templates
        └── hello.sql
```

So let's do that with our `hello.sql`

```sh
mkdir -p sql/templates
mv hello.sql sql/templates/
```

And from here, we can run our exact `sql` command from before:

```sh
sql hello.sql msg='World!!!'
# => SELECT 'World!!!'
```

It still works because SQL Ninja has sensible defaults. Files in current the current working directory and
`sql/templates` are the default search paths.

!!! note "Default Searched Directories"
    1. Current working directory
    2. `sql/templates`

    Please use one or the other, but not both.

### Build The Query

Create `sql/templates/expenses.sql`

```sql
{%- set categories = categories or 'katanas shurikens hooks shoes disguises' -%}
{%- set pivots = categories.split(' ') -%}
SELECT
    DATEFORMAT(entry_dt, 'yyyy-mm') as year_month,
    {%- for pivot in pivots %}
    SUM(CASE WHEN category = '{{ pivot }}' THEN amount END) AS {{ pivot }},
    {%- endfor %}
    SUM(
       CASE WHEN category NOT IN (
       {%- for pivot in pivots -%}
       '{{pivot}}'{{',' if not loop.last}}
       {%- endfor -%})
       THEN amount END
    ) AS other_amount,
    SUM(amount) AS total_amount
FROM expenses
ORDER BY year_month, total_amount
```

Let's run it:
```sh
sql expenses.sql categories='food transportation'
#=>
SELECT
    DATEFORMAT(entry_dt, 'yyyy-mm') as year_month,
    SUM(CASE WHEN category = 'food' THEN amount END) AS food,
    SUM(CASE WHEN category = 'transportation' THEN amount END) AS transportation,
    SUM(
       CASE WHEN category NOT IN ('food','transportation')
       THEN amount END
    ) AS other_amount,
    SUM(amount) AS total_amount
FROM expenses
ORDER BY year_month, total_amount
```

### Subquery Workflow

Jinja supports including templates in other templates. This is perfect for sub queries!

Let's break up the expenses query into two:

1. summaries by category
2. pivot the results

```sql
-- sql/templates/expenses/summary.sql
SELECT
    DATEFORMAT(entry_dt, 'yyyy-mm') as year_month,
    category,
    SUM(amount) AS amount
FROM expenses
ORDER BY year_month, category
```

```sql
-- sql/templates/expenses/pivot.sql
{%- set categories = categories or 'katanas shurikens hooks shoes disguises' -%}
{%- set pivots = categories.split(' ') -%}
SELECT
    DATEFORMAT(entry_dt, 'yyyy-mm') as year_month,
    {%- for pivot in pivots %}
    SUM(CASE WHEN category = '{{ pivot }}' THEN amount END) AS {{ pivot }},
    {%- endfor %}
    SUM(
       CASE WHEN category NOT IN (
       {%- for pivot in pivots -%}
       '{{pivot}}'{{',' if not loop.last}}
       {%- endfor -%})
       THEN amount END
    ) AS other_amount,
    SUM(amount) AS total_amount
FROM (
{{"{% include 'expenses/summary.sql' %}"}}
) AS summary
ORDER BY year_month, total_amount
```

Render the new template with: `sql expenses/pivot.sql` and override `categories` or not:

```sql
SELECT
    DATEFORMAT(entry_dt, 'yyyy-mm') as year_month,
    SUM(CASE WHEN category = 'katanas' THEN amount END) AS katanas,
    SUM(CASE WHEN category = 'shurikens' THEN amount END) AS shurikens,
    SUM(CASE WHEN category = 'hooks' THEN amount END) AS hooks,
    SUM(CASE WHEN category = 'shoes' THEN amount END) AS shoes,
    SUM(CASE WHEN category = 'disguises' THEN amount END) AS disguises,
    SUM(
       CASE WHEN category NOT IN ('katanas','shurikens','hooks','shoes','disguises')
       THEN amount END
    ) AS other_amount,
    SUM(amount) AS total_amount
FROM (
SELECT
    DATEFORMAT(entry_dt, 'yyyy-mm') as year_month,
    category,
    SUM(amount) AS amount
FROM expenses
ORDER BY year_month, category
) AS summary
ORDER BY year_month, total_amount
```

## Docker

A [docker image](https://hub.docker.com/repository/docker/ddrscott/sql-ninja) has been built if installing Python is a problem:

```sh
docker pull ddrscott/sql-ninja
```

Docker containers don't have access to local file system, so we need to mount the volume into the container.

```sh
docker run --rm -v $PWD:/app -w /app ddrscott/sql-ninja expenses/pivot.sql
#            ^   ^            ^      ^                  ^
#            |   |            |      |                  |
#            |   |            |      |                  + the template
#            |   |            |      |
#            |   |            |      + the image
#            |   |            |
#            |   |            + start in /app path
#            |   |            
#            |   + volume mount current path to /app
#            |
#            + remove container when complete
```

Make an alias if ya want:

```sh
# Pick one or name it whatever is most memorable to you:
alias sql='docker run --rm -v $PWD:/app -w /app ddrscott/sql-ninja'
alias sqln='docker run --rm -v $PWD:/app -w /app ddrscott/sql-ninja'
alias sqlninja='docker run --rm -v $PWD:/app -w /app ddrscott/sql-ninja'
```

## Why not [Jinja SQL](https://github.com/hashedin/jinjasql)?

The `jinjasql` project has 452 stars as of this writing and it uses Jinja, too. The project
requires the user to write they SQL as Python strings. If we're going to write SQL in Python strings, then we
don't need a templating engine. Just format strings and use Python. With SQL Ninja we want to write SQL in `.sql`
files. Period.

https://hashedin.com/blog/introducing-jinjasql-generate-sql-using-jinja-templates/)


## Conclusion

I'm currently using it in my day job and it has helped parameterize several aspects of some large SQL statements.
Jinja's `macro` and `include` features really standout and make writing SQL almost dreamy. Almost.

Please let us know how this project is working for you and how to make it better!
