---
date: 2024-10-09 08:00 America/Chicago
comments: true
categories: sql
published: true
title: Bowling Scores the SQL Way
image: /images/2024/bowling.jpg
description: |
  How to calculate bowling scores using SQL. No Store Procedures allowed!
---

# How to calculate bowling scores using SQL. No Store Procedures allowed!

<img class="featured" src="/images/2024/bowling.jpg" alt="American bowling alley with scoreboard and people looking confused around a console table. Dim lighting, bright screens showing bowling scores. The camera is focused on the bowling alley. The foreground is blurred." />

The scoring rules for American Bowling are simple on paper, but can be a chore to calculate by hand. This is a fun exercise to calculate the scores in mass using SQL. Because if you can't do it in SQL, you're life is too easy!

If you don't know the rules, here's a quick summary: https://www.kidslearntobowl.com/how-to-keep-score/


## Data Preparation

Making a table to store the raw data for the individual games.

We're not going into full data modelling by adding players and timestamps. We're keeping it simple for this example.

```sql
DROP TABLE IF EXISTS game_rolls;

CREATE TABLE game_rolls (
    game int,
    frame int,
    roll int,
    pins int
);
```


### Add a Perfect Game

A perfect game is 12 strikes in a row. 10 strikes in the first 9 frames and 2 strikes in the 10th frame.

```sql
-- Perfect Game
-- Total: 300
INSERT INTO game_rolls (game, frame, roll, pins)
VALUES
(1,  1, 1, 10),
(1,  2, 1, 10),
(1,  3, 1, 10),
(1,  4, 1, 10),
(1,  5, 1, 10),
(1,  6, 1, 10),
(1,  7, 1, 10),
(1,  8, 1, 10),
(1,  9, 1, 10),
(1, 10, 1, 10),
(1, 10, 2, 10),
(1, 10, 3, 10);
```


### Add an Unlucky Second Game

We managed to knock down 1 pin each frame and missed the second roll. Repeat this for all 10 frames.

```sql
-- 1 pin each frame.
-- Total: 10
INSERT INTO game_rolls (game, frame, roll, pins)
VALUES
(2,  1, 1,  1),
(2,  1, 2,  0),
(2,  2, 1,  1),
(2,  2, 2,  0),
(2,  3, 1,  1),
(2,  3, 2,  0),
(2,  4, 1,  1),
(2,  4, 2,  0),
(2,  5, 1,  1),
(2,  5, 2,  0),
(2,  6, 1,  1),
(2,  6, 2,  0),
(2,  7, 1,  1),
(2,  7, 2,  0),
(2,  8, 1,  1),
(2,  8, 2,  0),
(2,  9, 1,  1),
(2,  9, 2,  0),
(2, 10, 1,  1),
(2, 10, 2,  0);
```


### Add Gutter Ball and Spare

Now, we're showing off our skills. Throw the first ball into the gutter on purpose and take down the rest in the second roll for a spare.

```sql
-- 0 then 10 each frame
-- Total: 100
INSERT INTO game_rolls (game, frame, roll, pins)
VALUES
(3,  1, 1,  0),
(3,  1, 2, 10),
(3,  2, 1,  0),
(3,  2, 2, 10),
(3,  3, 1,  0),
(3,  3, 2, 10),
(3,  4, 1,  0),
(3,  4, 2, 10),
(3,  5, 1,  0),
(3,  5, 2, 10),
(3,  6, 1,  0),
(3,  6, 2, 10),
(3,  7, 1,  0),
(3,  7, 2, 10),
(3,  8, 1,  0),
(3,  8, 2, 10),
(3,  9, 1,  0),
(3,  9, 2, 10),
(3, 10, 1,  0),
(3, 10, 2, 10);
```

### Add Realistic Game with Strikes and Spares

This is my typical night out, never quite getting halfway to perfection (300). If I spent more time bowling and less time writing SQL maybe I'd get better!

```sql
INSERT INTO game_rolls (game, frame, roll, pins)
VALUES
(4,  1, 1,  7),  -- First frame: 7 pins
(4,  1, 2,  2),  -- Spare with 2 pins        =>             = 9

(4,  2, 1,  10), -- Second frame: Strike     =>     9+10+5+4=28

(4,  3, 1,  5),  -- Third frame: 5 pins
(4,  3, 2,  4),  -- Open frame with 4 pins   =>         28+9=37

(4,  4, 1,  8),  -- Fourth frame: 8 pins
(4,  4, 2,  1),  -- Open frame with 1 pin    =>         37+9=46

(4,  5, 1,  10), -- Fifth frame: Strike      =>    46+10+6+3=65

(4,  6, 1,  6),  -- Sixth frame: 6 pins
(4,  6, 2,  3),  -- Open frame with 3 pins   =>         65+9=74

(4,  7, 1,  9),  -- Seventh frame: 9 pins
(4,  7, 2,  0),  -- Open frame with 0 pins   =>         74+9=83

(4,  8, 1,  10), -- Eighth frame: Strike     =>     83+10+9=102

(4,  9, 1,  7),  -- Ninth frame: 7 pins
(4,  9, 2,  2),  -- Open frame with 2 pins   =>       102+9=111

(4, 10, 1,  10), -- Tenth frame: Strike
(4, 10, 2,  10), -- Bonus roll: Strike
(4, 10, 3,  8);  -- Bonus roll: 8 pins       => 111+10+10+8=139
```

## Query to Calculate Scores

There are many ways to calculate the scores.
We're going to make use of [Window Functions](https://www.postgresql.org/docs/current/tutorial-window.html) to look ahead for bonus pins and look behind for spares.

```sql
SELECT
    *,
    COALESCE(LEAD(pins, 1) OVER (w), 0)              AS next_pins,
    COALESCE(LEAD(pins, 2) OVER (w), 0)              AS next_next_pins,
    roll = 1 AND pins = 10                           AS is_strike,
    roll = 2 AND (pins + LAG(pins, 1) OVER (w) = 10) AS is_spare
FROM game_rolls
WINDOW w AS (PARTITION BY game ORDER BY game, frame, roll)
;
```

**Results**:

|game|frame|roll|pins|next_pins|next_next_pins|is_strike|is_spare|
|----|-----|----|----|---------|--------------|---------|--------|
|   4|    1|   1|   7|        2|            10|false    |false   |
|   4|    1|   2|   2|       10|             5|false    |false   |
|   4|    2|   1|  10|        5|             4|true     |false   |
|   4|    3|   1|   5|        4|             8|false    |false   |
|   4|    3|   2|   4|        8|             1|false    |false   |
|   4|    4|   1|   8|        1|            10|false    |false   |
|   4|    4|   2|   1|       10|             6|false    |false   |
|   4|    5|   1|  10|        6|             3|true     |false   |
|   4|    6|   1|   6|        3|             9|false    |false   |
|   4|    6|   2|   3|        9|             0|false    |false   |
|   4|    7|   1|   9|        0|            10|false    |false   |
|   4|    7|   2|   0|       10|             7|false    |false   |
|   4|    8|   1|  10|        7|             2|true     |false   |
|   4|    9|   1|   7|        2|            10|false    |false   |
|   4|    9|   2|   2|       10|            10|false    |false   |
|   4|   10|   1|  10|       10|             8|true     |false   |
|   4|   10|   2|  10|        8|             0|false    |false   |
|   4|   10|   3|   8|        0|             0|false    |false   |



That looks right. The future pins are correct and the strikes and spares are correctly identified.

If we wanted, we could make a view, but we're going to continue with the query by using [Common Table Expressions
(CTE)](https://www.postgresql.org/docs/current/queries-with.html).


We'll call the first CTE `stats` and build on it with the next CTE to calculate the bonus based on the rules of
strikes and spares. Strikes get the next two rolls and spares get the next roll.

There is a special condition for the last frame. We accept the pins as final since there are no future frames to
look at. We don't have to 'wait' to score the last frame. We can score it immediately.

> I have to admit, this was the hardest part to figure out and I was stuck on it for longer than I'd like to admit.
> The perfect game scenario was totalling 320 for the longest time! (Perfect games of 12 strikes in a row are 300 points, not 320)

```sql
WITH stats AS (
    SELECT
        *,
        COALESCE(LEAD(pins, 1) OVER (w), 0)              AS next_pins,
        COALESCE(LEAD(pins, 2) OVER (w), 0)              AS next_next_pins,
        roll = 1 AND pins = 10                           AS is_strike,
        roll = 2 AND (pins + LAG(pins, 1) OVER (w) = 10) AS is_spare,
        frame = (max(frame) OVER (PARTITION BY game))    AS is_last_frame
    FROM game_rolls
    WINDOW w AS (PARTITION BY game ORDER BY game, frame, roll)
)
SELECT
    *,
    CASE
        WHEN is_last_frame THEN pins
        WHEN is_strike     THEN pins + next_pins + next_next_pins 
        WHEN is_spare      THEN pins + next_pins
    ELSE
        pins
    END
    AS score
FROM stats
;
```

**Results with pins per frame**:

|game|frame|roll|pins|next_pins|next_next_pins|is_strike|is_spare|is_last_frame|score|
|----|-----|----|----|---------|--------------|---------|--------|-------------|-----|
|   4|    1|   1|   7|        2|            10|false    |false   |false        |    7|
|   4|    1|   2|   2|       10|             5|false    |false   |false        |    2|
|   4|    2|   1|  10|        5|             4|true     |false   |false        |   19|
|   4|    3|   1|   5|        4|             8|false    |false   |false        |    5|
|   4|    3|   2|   4|        8|             1|false    |false   |false        |    4|
|   4|    4|   1|   8|        1|            10|false    |false   |false        |    8|
|   4|    4|   2|   1|       10|             6|false    |false   |false        |    1|
|   4|    5|   1|  10|        6|             3|true     |false   |false        |   19|
|   4|    6|   1|   6|        3|             9|false    |false   |false        |    6|
|   4|    6|   2|   3|        9|             0|false    |false   |false        |    3|
|   4|    7|   1|   9|        0|            10|false    |false   |false        |    9|
|   4|    7|   2|   0|       10|             7|false    |false   |false        |    0|
|   4|    8|   1|  10|        7|             2|true     |false   |false        |   19|
|   4|    9|   1|   7|        2|            10|false    |false   |false        |    7|
|   4|    9|   2|   2|       10|            10|false    |false   |false        |    2|
|   4|   10|   1|  10|       10|             8|true     |false   |true         |   10|
|   4|   10|   2|  10|        8|             0|false    |false   |true         |   10|
|   4|   10|   3|   8|        0|             0|false    |false   |true         |    8|


That looks good. The scores are correct and the last frame is scored correctly.

We could simply `SUM` everything at this point:


```sql
WITH stats AS (
    SELECT
        *,
        COALESCE(LEAD(pins, 1) OVER (w), 0)              AS next_pins,
        COALESCE(LEAD(pins, 2) OVER (w), 0)              AS next_next_pins,
        roll = 1 AND pins = 10                           AS is_strike,
        roll = 2 AND (pins + LAG(pins, 1) OVER (w) = 10) AS is_spare,
        frame = (max(frame) OVER (PARTITION BY game))    AS is_last_frame
    FROM game_rolls
    WINDOW w AS (PARTITION BY game ORDER BY game, frame, roll)
),
scores AS (
    SELECT
        *,
        CASE
            WHEN is_last_frame THEN pins
            WHEN is_strike     THEN pins + next_pins + next_next_pins 
            WHEN is_spare      THEN pins + next_pins
        ELSE
            pins
        END
        AS score
    FROM stats
)
SELECT
    game,
    SUM(score)
FROM scores
GROUP BY game
;
```

**Results final `SUM`**:

|game|sum|
|----|---|
|   1|300|
|   2| 10|
|   3|100|
|   4|139|


Notice the use of CTEs again so we can build on the previous step. This is an important pattern that I follow
strictly when building up queries. It allows me to extract parts into views in the future and provides a good
place for meaningful names.


In Bowling, we normally to see a running score frame by frame. We can do this by adding a cumulative score to each frame with yet another Window Function.

```sql
WITH stats AS (
    SELECT
        *,
        COALESCE(LEAD(pins, 1) OVER (w), 0)              AS next_pins,
        COALESCE(LEAD(pins, 2) OVER (w), 0)              AS next_next_pins,
        roll = 1 AND pins = 10                           AS is_strike,
        roll = 2 AND (pins + LAG(pins, 1) OVER (w) = 10) AS is_spare,
        frame = (max(frame) OVER (PARTITION BY game))    AS is_last_frame
    FROM game_rolls
    WINDOW w AS (PARTITION BY game ORDER BY game, frame, roll)
),
scores AS (
    SELECT
        *,
        CASE
            WHEN is_last_frame THEN pins
            WHEN is_strike     THEN pins + next_pins + next_next_pins 
            WHEN is_spare      THEN pins + next_pins
        ELSE
            pins
        END
        AS score
    FROM stats
),
sums AS (
    -- Note: This CTE will get optimized away by the query planner.
    -- Nothing is calling it, and we can choose which to call in the final query.
    SELECT
        game,
        SUM(score)
    FROM scores
    GROUP BY game
),
cumulative_scores AS (
    SELECT
        *,
        SUM(score) OVER (w) AS cumulative_score,
        CASE
            WHEN is_strike THEN 'X'
            WHEN is_spare  THEN '  /'
        ELSE REPEAT('  ', roll - 1) || pins
        END display
    FROM scores
    WINDOW w AS (PARTITION BY game ORDER BY game, frame, roll)
)
SELECT
    game,
    frame,
    display,
    cumulative_score
FROM cumulative_scores
;
```

**Results Game 1**:

|game|frame|display|cumulative_score|
|----|-----|-------|----------------|
|   1|    1|X      |              30|
|   1|    2|X      |              60|
|   1|    3|X      |              90|
|   1|    4|X      |             120|
|   1|    5|X      |             150|
|   1|    6|X      |             180|
|   1|    7|X      |             210|
|   1|    8|X      |             240|
|   1|    9|X      |             270|
|   1|   10|X      |             280|
|   1|   10|  10   |             290|
|   1|   10|    10 |             300|


**Results Game 2**:

|game|frame|display|cumulative_score|
|----|-----|-------|----------------|
|   2|    1|1      |               1|
|   2|    1|  0    |               1|
|   2|    2|1      |               2|
|   2|    2|  0    |               2|
|   2|    3|1      |               3|
|   2|    3|  0    |               3|
|   2|    4|1      |               4|
|   2|    4|  0    |               4|
|   2|    5|1      |               5|
|   2|    5|  0    |               5|
|   2|    6|1      |               6|
|   2|    6|  0    |               6|
|   2|    7|1      |               7|
|   2|    7|  0    |               7|
|   2|    8|1      |               8|
|   2|    8|  0    |               8|
|   2|    9|1      |               9|
|   2|    9|  0    |               9|
|   2|   10|1      |              10|
|   2|   10|  0    |              10|

**Results Game 3**:

|game|frame|display|cumulative_score|
|----|-----|-------|----------------|
|   3|    1|0      |               0|
|   3|    1|  /    |              10|
|   3|    2|0      |              10|
|   3|    2|  /    |              20|
|   3|    3|0      |              20|
|   3|    3|  /    |              30|
|   3|    4|0      |              30|
|   3|    4|  /    |              40|
|   3|    5|0      |              40|
|   3|    5|  /    |              50|
|   3|    6|0      |              50|
|   3|    6|  /    |              60|
|   3|    7|0      |              60|
|   3|    7|  /    |              70|
|   3|    8|0      |              70|
|   3|    8|  /    |              80|
|   3|    9|0      |              80|
|   3|    9|  /    |              90|
|   3|   10|0      |              90|
|   3|   10|  /    |             100|

**Results Game 4**:

> I'm putting this in a preformatted text block so you can see the formatting. Markdown tables aren't doing
> this justice.

```
|game|frame|display|cumulative_score|
|----|-----|-------|----------------|
|   4|    1|7      |               7|
|   4|    1|  2    |               9|
|   4|    2|X      |              28|
|   4|    3|5      |              33|
|   4|    3|  4    |              37|
|   4|    4|8      |              45|
|   4|    4|  1    |              46|
|   4|    5|X      |              65|
|   4|    6|6      |              71|
|   4|    6|  3    |              74|
|   4|    7|9      |              83|
|   4|    7|  0    |              83|
|   4|    8|X      |             102|
|   4|    9|7      |             109|
|   4|    9|  2    |             111|
|   4|   10|X      |             121|
|   4|   10|  10   |             131|
|   4|   10|    8  |             139|
```


I narrowed the columns a little to make it easier to follow. In the final query, I would include all the columns
to let the client decide how to display it.


## Conclusion

If you wanted to use this using a Business Intelligence (BI) tool, you should create a view for each CTE and then query the final view.

Should bowling be calculated in SQL? I'll leave that up to you. It was a fun exercise to figure out the logic and I hope you enjoyed the ride!
