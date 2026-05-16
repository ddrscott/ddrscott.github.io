---
title: "What the SQL?!? Recursive"
date: 2017-03-15
created: 2017-03-15T00:00:00Z
type: blog
status: settled
tags: [sql]
publish: [ddrscott]
source: import
image: /images/i_heart_recursion.png
prompt: "Import from blog post: 2017/what-the-sql-recursive.markdown"
---

# What the SQL?!? Recursive

<img src="/images/i_heart_recursion.png" alt='What the SQL?!? Recursive' />

Today's "What the SQL?!?" features the keyword `RECURSIVE`. This clause allows
us to elegantly select results from the previous results from the previous results
from the previous results...

<!-- more -->

Please note, our target database is PostgreSQL. These examples may work with
other databases, but might need some massaging to get them to work properly.
Search online for the specific vendor's documentation if errors pop up.
Try searching for "RECURSIVE queries $DB_VENDOR_NAME". Not all database vendors
support the keyword `RECURSIVE`.

## Fibonacci Sequence

According to [Wikipedia](https://en.wikipedia.org/wiki/Fibonacci_number):

> In mathematics, the Fibonacci numbers are the numbers in the following integer
> sequence, called the Fibonacci sequence, and characterized by the fact that
> every number after the first two is the sum of the two preceding ones:
>
>     1, 1, 2, 3, 5, 8, 13, 21, 34, 55 ...

## SQL Solution

Our SQL solution will make use of the `RECURSIVE` [CTE](https://www.postgresql.org/docs/9.3/static/queries-with.html)
keyword.

```sql
WITH RECURSIVE t(i, fi, fib) AS (
  SELECT
    1,
    0::NUMERIC,
    1::NUMERIC
  UNION ALL
  SELECT
    i + 1,
    fib,
    fi + fib
  FROM t
  WHERE i < 10
)
SELECT
  i,
  fib
FROM t
```

## The Ins and Outs

Here's some inline colorful comments to explain the sections:
<img src="/images/recursion_sql.png" alt='annotated SQL' />

Maybe arrows will help a little more with the flow of data:
<img src="/images/recursive_query.jpg" alt='Data Flow' />

## Fibonacci Results

When you run the query, you'll get the following results:

```
 i  | fib
----+-----
  1 |   1
  2 |   1
  3 |   2
  4 |   3
  5 |   5
  6 |   8
  7 |  13
  8 |  21
  9 |  34
 10 |  55

(10 rows)
```

If you want to see the results for a high number, update `i < 10` to a higher
value. If you go above `i < 793`, Postgres gives up and returns `Nan` which means
`Not a number` which means the computed value is larger than your computer can
handle and still treat like a number. Sorry, get a new computer or work with
numbers less than 166 digits long.

## A Real World Example with Hierarchical Data
Fibonacci sequence is nice and all, but you have real data concerns. You're
thinking, "Show me the DATA!". So here's the data...

```sql
-- Build `sample_people` table
CREATE TABLE sample_people AS
  SELECT
    column1::int     AS id,
    column2::varchar AS name,
    column3::int     AS parent_id
  FROM (
    VALUES
      (0, 'Root' , null),
      (1, 'Alice', 0),
      (2, 'Bob'  , 1),
      (3, 'Cat'  , 1),
      (4, 'Dan'  , 3),
      (5, 'Evan' , 0),
      (6, 'Frank', 5)
  ) as t
  ;

SELECT * FROM sample_people;
--  id | name  | parent_id
-- ----+-------+-----------
--   0 | Root  |
--   1 | Alice |         0
--   2 | Bob   |         1
--   3 | Cat   |         1
--   4 | Dan   |         3
--   5 | Evan  |         0
--   6 | Frank |         5
```

Our `sample_people` table represents a person by name and that person may have a
parent. The parent of all the parents is `Root`.

And finally our recursive query to get a nice display of the hierarchy.

```sql
WITH RECURSIVE tree -- `tree` is the table alias.
                    -- It must be used as part of the `UNION` statement.
  AS (
  -- 1) Initialize table with all the top level rows.
  --    Anything without a parent is a parent. Is that apparent?
  SELECT
    0 AS level,        -- 2) Set the level to 0.
    sample_people.*    -- 3) Return the initial row
  FROM sample_people
  WHERE parent_id = 0  -- 4) Top level doesn't have a parent.
  UNION ALL
  -- 5) Union all the parents with their children.
  SELECT
    tree.level + 1,    -- 6) Increment the level every time we loop.
    sample_people.*    -- 7) Return the current row - the child row. 
  FROM tree    -- 8) `tree` is populated with the previous results.
               --    Every loop gets a new record from current result.
  JOIN sample_people ON sample_people.parent_id = tree.id
)
SELECT
  repeat(' ', level * 4) || name AS display
FROM tree
ORDER BY level, name
;

--    display
-- -------------
--  Alice
--  Evan
--      Bob
--      Cat
--      Frank
--          Dan
-- (6 rows)
```

## Bait and Switch

`RECURSIVE` is not actually recursive. It isn't a function calling itself.
Sorry, not sorry. It's much closer to a `while` loop. Here's what Postgres has to say about it:

> Note: Strictly speaking, this process is **iteration** not recursion, but RECURSIVE
> is the terminology chosen by the SQL standards committee. [emphasis added]

## Closing

So the next time you try to crawl a hierarchy of data, we hope `RECURSIVE` comes
to mind. It's a great way to save round trips to the database and query what is
needed based on the data's structure. Think of all the nested subqueries we can
save together!

## References

- Postgres WITH Queries: https://www.postgresql.org/docs/9.3/static/queries-with.html
- Wikipedia Fibonacci number: https://en.wikipedia.org/wiki/Fibonacci_number

