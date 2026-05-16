---
title: "What the SQL?!? Lateral Joins"
date: 2017-03-08
created: 2017-03-08T00:00:00Z
type: blog
status: settled
tags: [sql]
publish: [ddrscott]
source: import
image: /images/what_the_sql_lateral.png
prompt: "Import from blog post: 2017/what-the-sql-lateral.markdown"
---

# What the SQL?!? Lateral Joins

<img src="/images/what_the_sql_lateral.png" alt='What the SQL?!? Lateral Joins' />

Today's "What the SQL?!?" features the keyword `LATERAL`. A prerequisite to
understanding lateral joins are regular joins and subqueries. I'll explain those
briefly to see how `LATERAL` can simplify a complicated SQL query.

<!-- more -->

Please note, our target database is PostgreSQL. These examples may work with
other databases, but might need some massaging to get them to work properly.
Search online for the specific vendor's documentation if errors pop up.
Try searching for "lateral joins $DB_VENDOR_NAME". Not all database vendors
support the keyword `LATERAL`.

## A Problem to Solve

We have a table with system uptimes. The table records a start timestamp and an
end timestamp. If the service is still running, the end timestamp is left null
because it hasn't ended. We want a query to display an overview this data.

Our final solution will return a row per day and 24 columns containing an uptime
percentage for each hour in the day. It will look like the following.

```
  cal_date  | hour_0 | hour_1 | hour_2 | hour_3 | ... | hour_21 | hour_22 | hour_23
------------+--------+--------+--------+--------+-----+---------+---------+---------
 2017-03-01 |      0 |   0.75 |   0.25 |      0 | ... |       0 |       0 |       0
 2017-03-02 |      0 |      0 |      0 |      0 | ... |       1 |       1 |       1
(2 rows)
```

Please note we'll use `...` abbreviate some of the results. All queries are
schema independent and should be copy/paste-able into any `psql` session.

## Sample Uptime Data

The sample uptime data is derived from a virtual table built from the following query:

```sql
SELECT
  *
FROM (
  VALUES
  ('2017-03-01 01:15:00-06'::timestamp, '2017-03-01 02:15:00-06'::timestamp),
  ('2017-03-01 08:00:00-06', '2017-03-01 20:00:00-06'),
  ('2017-03-02 19:00:00-06', null)
) AS t(start_ts, end_ts)
```

The data looks like:

```plain
      start_ts       |       end_ts
---------------------+---------------------
 2017-03-01 01:15:00 | 2017-03-01 02:15:00
 2017-03-01 08:00:00 | 2017-03-01 20:00:00
 2017-03-02 19:00:00 |
(3 rows)
```

We want to plot the time against a time sliced table representing all the
effective hours in the uptime window. We'll make use of another virtual table to
build up all the time slices:

```sql
SELECT
    start_ts,
    start_ts + interval '1 hour' AS end_ts
FROM generate_series('2017-03-01'::date,
                     '2017-03-03'::timestamp - interval '1 hour',
                     interval '1 hour'
                    ) AS t(start_ts)
```

This we make use of PostgreSQL's [generate_series](https://www.postgresql.org/docs/9.3/static/functions-srf.html)
to return all the hours between a time range. The data looks like:

```plain
      start_ts       |       end_ts
---------------------+---------------------
 2017-03-01 00:00:00 | 2017-03-01 01:00:00
 2017-03-01 01:00:00 | 2017-03-01 02:00:00
 2017-03-01 02:00:00 | 2017-03-01 03:00:00
 -- ... many more rows ...
 2017-03-01 03:00:00 | 2017-03-01 04:00:00
 2017-03-02 22:00:00 | 2017-03-02 23:00:00
 2017-03-02 23:00:00 | 2017-03-03 00:00:00
(48 rows)
```

## Left Join

We use a left join to glue together overlapping time ranges between these two
data sets. We want all the data on the `LEFT` side in the `FROM` clause to return
regardless of an uptime record existing within its time slice.

```sql
SELECT
    *
FROM (
    -- build virtual table of all hours between
    -- a date range
    SELECT
      start_ts,
      start_ts + interval '1 hour' AS end_ts
    FROM generate_series(
           '2017-03-01'::date,
           '2017-03-03'::timestamp - interval '1 hour',
           interval '1 hour'
    ) AS t(start_ts)
) AS cal
LEFT JOIN (
    -- build virtual table of uptimes
    SELECT *
    FROM (
      VALUES
      ('2017-03-01 01:15:00-06'::timestamp, '2017-03-01 02:15:00-06'::timestamp),
      ('2017-03-01 08:00:00-06', '2017-03-01 20:00:00-06'),
      ('2017-03-02 19:00:00-06', null)
    ) AS t(start_ts, end_ts)
) AS uptime ON cal.end_ts > uptime.start_ts AND cal.start_ts <= coalesce(uptime.end_ts, current_timestamp)
```

The result set shows we have some variety in our sample data. With 3 slices
up time and 3 slices of downtime.

```plain
      start_ts       |       end_ts        |      start_ts       |       end_ts
---------------------+---------------------+---------------------+---------------------
 2017-03-01 00:00:00 | 2017-03-01 01:00:00 |                     |
 2017-03-01 01:00:00 | 2017-03-01 02:00:00 | 2017-03-01 01:15:00 | 2017-03-01 02:15:00
 2017-03-01 02:00:00 | 2017-03-01 03:00:00 | 2017-03-01 01:15:00 | 2017-03-01 02:15:00
 2017-03-01 03:00:00 | 2017-03-01 04:00:00 |                     |
 ...
 2017-03-01 07:00:00 | 2017-03-01 08:00:00 |                     |
 2017-03-01 08:00:00 | 2017-03-01 09:00:00 | 2017-03-01 08:00:00 | 2017-03-01 20:00:00
 ...
 2017-03-01 20:00:00 | 2017-03-01 21:00:00 | 2017-03-01 08:00:00 | 2017-03-01 20:00:00
 2017-03-01 21:00:00 | 2017-03-01 22:00:00 |                     |
 ...
 2017-03-02 18:00:00 | 2017-03-02 19:00:00 |                     |
 2017-03-02 19:00:00 | 2017-03-02 20:00:00 | 2017-03-02 19:00:00 |
 ...
 2017-03-02 23:00:00 | 2017-03-03 00:00:00 | 2017-03-02 19:00:00 |
(48 rows)
```

If we try without the `LEFT` clause, we'll only see 20 rows containing the up slices.

## Time to compute some timing

Let's add some times and sensible column names and replace the `*`

```sql
SELECT
    -- will use `first_ts` and `last_ts` to calculate uptime duration
    CASE WHEN uptime.start_ts IS NOT NULL THEN
        greatest(uptime.start_ts, cal.start_ts)
    END                                               AS first_ts,
    least(cal.end_ts, uptime.end_ts)                  AS last_ts,
    date_trunc('day', cal.start_ts)::date             AS cal_date,
    extract(hour from cal.start_ts)                   AS cal_hour,
    extract(epoch from age(cal.end_ts, cal.start_ts)) AS cal_seconds
FROM (
    -- build virtual table of all hours between
    -- a date range
    SELECT
        start_ts,
        start_ts + interval '1 hour' AS end_ts
        FROM generate_series('2017-03-01'::date,
                             '2017-03-03'::timestamp - interval '1 hour',
                             interval '1 hour'
        ) AS t(start_ts)
    ) AS cal
LEFT JOIN (
    -- build virtual table of uptimes
    SELECT *
    FROM (
        VALUES
        ('2017-03-01 01:15:00-06'::timestamp, '2017-03-01 02:15:00-06'::timestamp),
        ('2017-03-01 08:00:00-06', '2017-03-01 20:00:00-06'),
        ('2017-03-02 19:00:00-06', null)
    ) AS t(start_ts, end_ts)
) AS uptime ON cal.end_ts > uptime.start_ts AND cal.start_ts <= coalesce(uptime.end_ts, current_timestamp)
```

```plain

      first_ts       |       last_ts       |  cal_date  | cal_hour | cal_seconds
---------------------+---------------------+------------+----------+-------------
                     | 2017-03-01 01:00:00 | 2017-03-01 |        0 |        3600
 2017-03-01 01:15:00 | 2017-03-01 02:00:00 | 2017-03-01 |        1 |        3600
 2017-03-01 02:00:00 | 2017-03-01 02:15:00 | 2017-03-01 |        2 |        3600
                     | 2017-03-01 04:00:00 | 2017-03-01 |        3 |        3600
                     | 2017-03-01 05:00:00 | 2017-03-01 |        4 |        3600
                     | 2017-03-01 06:00:00 | 2017-03-01 |        5 |        3600
                     | 2017-03-01 07:00:00 | 2017-03-01 |        6 |        3600
                     | 2017-03-01 08:00:00 | 2017-03-01 |        7 |        3600
 2017-03-01 08:00:00 | 2017-03-01 09:00:00 | 2017-03-01 |        8 |        3600
 ...
 2017-03-01 20:00:00 | 2017-03-01 20:00:00 | 2017-03-01 |       20 |        3600
                     | 2017-03-01 22:00:00 | 2017-03-01 |       21 |        3600
 ... 
                     | 2017-03-02 19:00:00 | 2017-03-02 |       18 |        3600
 2017-03-02 19:00:00 | 2017-03-02 20:00:00 | 2017-03-02 |       19 |        3600
 ...
 2017-03-02 23:00:00 | 2017-03-03 00:00:00 | 2017-03-02 |       23 |        3600
(48 rows)
```

## Subquery, Subquery, What's the Worry?

SQL is all about nested subqueries. It's hard to escape without creating
views, but who has time to lookup that [syntax](https://www.postgresql.org/docs/9.3/static/sql-createview.html)
_and_ get their [DBA's](https://imgflip.com/i/1kzzyn) permission to run the DDL?!?

Let's add some duration times to the result set. We'll use the traditional sub
query for it.

```sql
SELECT
    -- calculate uptime seconds
    coalesce(
      extract(epoch FROM age(last_ts, first_ts)),
      0
    ) AS up_seconds,
    *
FROM (
    SELECT
        -- will use `first_ts` and `last_ts` to calculate uptime duration
        CASE WHEN uptime.start_ts IS NOT NULL THEN
            greatest(uptime.start_ts, cal.start_ts)
        END                                               AS first_ts,
        least(cal.end_ts, uptime.end_ts)                  AS last_ts,
        date_trunc('day', cal.start_ts)::date             AS cal_date,
        extract(hour from cal.start_ts)                   AS cal_hour,
        extract(epoch from age(cal.end_ts, cal.start_ts)) AS cal_seconds
    FROM (
        -- build virtual table of all hours between
        -- a date range
        SELECT
            start_ts,
            start_ts + interval '1 hour' AS end_ts
            FROM generate_series('2017-03-01'::date,
                                 '2017-03-03'::timestamp - interval '1 hour',
                                 interval '1 hour'
            ) AS t(start_ts)
    ) AS cal
    LEFT JOIN (
        -- build virtual table of uptimes
        SELECT *
        FROM (
            VALUES
            ('2017-03-01 01:15:00-06'::timestamp, '2017-03-01 02:15:00-06'::timestamp),
            ('2017-03-01 08:00:00-06', '2017-03-01 20:00:00-06'),
            ('2017-03-02 19:00:00-06', null)
        ) AS t(start_ts, end_ts)
    ) AS uptime ON cal.end_ts > uptime.start_ts AND cal.start_ts <= coalesce(uptime.end_ts, current_timestamp)
) t1
```

```plain
 up_seconds
------------
          0
       2700
        900
          0
          0
...
       3600
(48 rows)
```

Without the subquery we'd be getting into even more nested function calls and
would have to double compute values or have no visibility in the intermediate
steps. We could have calculated `up_seconds` directly in the first query which
introduced `first_ts` and `last_ts`. That would look like this:

```sql
SELECT
    coalesce(
        extract(epoch FROM
            age(
                least(cal.end_ts, uptime.end_ts), 
                CASE WHEN uptime.start_ts IS NOT NULL THEN
                  greatest(uptime.start_ts, cal.start_ts)
                END
            )
        ),
        0
    ) AS up_seconds
FROM --- ...
```

It's not for the weak stomach, but frankly speaking, neither is the subquery...

## Enough Nesting, `LATERAL` join save me!

Lateral joins can give us the best of both worlds: reduced subquery nesting and
traceable computed values. We're going to move the initial computed values like
`first_ts` and `last_ts`, move them to a virtual table then `JOIN LATERAL` so
they can get their own table alias. We'll do it again for `up_seconds` and use
`first_ts` and `last_ts` from its sibling table.

```sql
SELECT
    t2.up_seconds
FROM (
    -- build virtual table of all hours between
    -- a date range
    SELECT
        start_ts,
        start_ts + interval '1 hour' AS end_ts
        FROM generate_series('2017-03-01'::date,
                             '2017-03-03'::timestamp - interval '1 hour',
                             interval '1 hour'
        ) AS t(start_ts)
    ) AS cal
LEFT JOIN (
    -- build virtual table of uptimes
    SELECT *
    FROM (
        VALUES
        ('2017-03-01 01:15:00-06'::timestamp, '2017-03-01 02:15:00-06'::timestamp),
        ('2017-03-01 08:00:00-06', '2017-03-01 20:00:00-06'),
        ('2017-03-02 19:00:00-06', null)
    ) AS t(start_ts, end_ts)
) AS uptime ON cal.end_ts > uptime.start_ts AND cal.start_ts <= coalesce(uptime.end_ts, current_timestamp)
JOIN LATERAL (
  SELECT
      -- will use `first_ts` and `last_ts` to calculate uptime duration
    CASE WHEN uptime.start_ts IS NOT NULL THEN
        greatest(uptime.start_ts, cal.start_ts)
    END                                               AS first_ts,
    least(cal.end_ts, uptime.end_ts)                  AS last_ts,
    date_trunc('day', cal.start_ts)::date             AS cal_date,
    extract(hour from cal.start_ts)                   AS cal_hour,
    extract(epoch from age(cal.end_ts, cal.start_ts)) AS cal_seconds
) t1 ON true
JOIN LATERAL (
  -- calculate uptime seconds for the time slice
  SELECT
    coalesce(
        extract(epoch FROM age(last_ts, first_ts)),
        0
    ) AS up_seconds
) t2 ON true
```

This gives us the same results but without the deep nesting.

```plain
 up_seconds
------------
          0
       2700
        900
          0
          0
       3600
...
       3600
(48 rows)
```

What's great about this strategy is we can quickly choose which columns to see
as we build up the query.

```sql
SELECT
  t2.up_seconds
  ...

-- or --

SELECT
  t2.*,
  t1.*
```

Let's build up the final calculation using the same strategy:

```sql
SELECT
  t2.*,
  t3.*
FROM ...
JOIN LATERAL (
  -- calculate percentage between uptime seconds and available seconds
  -- within the time slice
  SELECT
    up_seconds / cal_seconds AS up_pct
) t3 ON true
```

```plain
 up_seconds | up_pct
------------+--------
          0 |      0
       2700 |   0.75
        900 |   0.25
          0 |      0
...
       3600 |      1
(48 rows)
```

## Plot the Hours

Now we have all the computed data we need. Let's plot it as a cross tab (but not
actually use [`crosstab`](https://www.postgresql.org/docs/9.3/static/tablefunc.html))

We'll need to consolidate the long list of data by `cal_date` and pivot the
`cal_hour` as a column and `up_pct` as a value. In case of overlapping uptimes
we'll be pessimists and choose the lowest or `min` uptime percentage.

The final query looks like:

```sql
SELECT
    cal_date,
    max(CASE WHEN cal_hour = 0 THEN up_pct  END) AS hour_0,
    max(CASE WHEN cal_hour = 1 THEN up_pct  END) AS hour_1,
    max(CASE WHEN cal_hour = 2 THEN up_pct  END) AS hour_2,
    max(CASE WHEN cal_hour = 3 THEN up_pct  END) AS hour_3,
    max(CASE WHEN cal_hour = 4 THEN up_pct  END) AS hour_4,
    max(CASE WHEN cal_hour = 5 THEN up_pct  END) AS hour_5,
    max(CASE WHEN cal_hour = 6 THEN up_pct  END) AS hour_6,
    max(CASE WHEN cal_hour = 7 THEN up_pct  END) AS hour_7,
    max(CASE WHEN cal_hour = 8 THEN up_pct  END) AS hour_8,
    max(CASE WHEN cal_hour = 9 THEN up_pct  END) AS hour_9,
    max(CASE WHEN cal_hour = 10 THEN up_pct END) AS hour_10,
    max(CASE WHEN cal_hour = 11 THEN up_pct END) AS hour_11,
    max(CASE WHEN cal_hour = 12 THEN up_pct END) AS hour_12,
    max(CASE WHEN cal_hour = 13 THEN up_pct END) AS hour_13,
    max(CASE WHEN cal_hour = 14 THEN up_pct END) AS hour_14,
    max(CASE WHEN cal_hour = 15 THEN up_pct END) AS hour_15,
    max(CASE WHEN cal_hour = 16 THEN up_pct END) AS hour_16,
    max(CASE WHEN cal_hour = 17 THEN up_pct END) AS hour_17,
    max(CASE WHEN cal_hour = 18 THEN up_pct END) AS hour_18,
    max(CASE WHEN cal_hour = 19 THEN up_pct END) AS hour_19,
    max(CASE WHEN cal_hour = 20 THEN up_pct END) AS hour_20,
    max(CASE WHEN cal_hour = 21 THEN up_pct END) AS hour_21,
    max(CASE WHEN cal_hour = 22 THEN up_pct END) AS hour_22,
    max(CASE WHEN cal_hour = 23 THEN up_pct END) AS hour_23
FROM (
    -- build virtual table of all hours between
    -- a date range
    SELECT
        start_ts,
        start_ts + interval '1 hour' AS end_ts
        FROM generate_series('2017-03-01'::date,
                             '2017-03-03'::timestamp - interval '1 hour',
                             interval '1 hour'
        ) AS t(start_ts)
    ) AS cal
LEFT JOIN (
    -- build virtual table of uptimes
    SELECT *
    FROM (
        VALUES
        ('2017-03-01 01:15:00-06'::timestamp, '2017-03-01 02:15:00-06'::timestamp),
        ('2017-03-01 08:00:00-06', '2017-03-01 20:00:00-06'),
        ('2017-03-02 19:00:00-06', null)
    ) AS t(start_ts, end_ts)
) AS uptime ON cal.end_ts > uptime.start_ts AND cal.start_ts <= coalesce(uptime.end_ts, current_timestamp)
JOIN LATERAL (
  SELECT
      -- will use `first_ts` and `last_ts` to calculate uptime duration
    CASE WHEN uptime.start_ts IS NOT NULL THEN
        greatest(uptime.start_ts, cal.start_ts)
    END                                               AS first_ts,
    least(cal.end_ts, uptime.end_ts)                  AS last_ts,
    date_trunc('day', cal.start_ts)::date             AS cal_date,
    extract(hour from cal.start_ts)                   AS cal_hour,
    extract(epoch from age(cal.end_ts, cal.start_ts)) AS cal_seconds
) t1 ON true
JOIN LATERAL (
  SELECT
    coalesce(
        extract(epoch FROM age(last_ts, first_ts)),
        0
    ) AS up_seconds
) t2 ON true
JOIN LATERAL (
  -- calculate percentage between uptime seconds and available seconds
  -- within the time slice
  SELECT
  up_seconds / cal_seconds AS up_pct
) t3 ON true
GROUP BY cal_date
```

```plain
  cal_date  | hour_0 | hour_1 | hour_2 | hour_3 | ... | hour_23
------------+--------+--------+--------+--------+ ... +---------
 2017-03-01 |      0 |   0.75 |   0.25 |      0 | ... |       0
 2017-03-02 |      0 |      0 |      0 |      0 | ... |       1
(2 rows)
```

## More than CTE and Cross Join

This example only scratches the surface of `LATERAL`s super powers. On the
surface `LATERAL` can do things `CTE`, cross join, and `WINDOW` can do.
PostgreSQL describe `LATERAL` as:

> Subqueries appearing in FROM can be preceded by the key word LATERAL.
> This allows them to reference columns provided by preceding FROM items.
> (Without LATERAL, each subquery is evaluated independently and so cannot
> cross-reference any other FROM item.)

TL;DR - `LATERAL` allows subqueries to reference earlier tables.

## References
- [Postgres Lateral Joins](https://www.postgresql.org/docs/9.6/static/queries-table-expressions.html#QUERIES-LATERAL)
