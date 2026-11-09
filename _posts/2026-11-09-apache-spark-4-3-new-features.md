---
layout: post
title: "Apache Spark 4.3.0: ASOF Joins, counter_diff, and JSON_TABLE - the Features You'll Actually Use"
date: 2026-11-09
categories: [big-data, Apache-Spark, Data-Engineering]
tags: [Apache Spark, Spark 4.3, ASOF JOIN, JSON_TABLE, VARIANT, counter_diff, Structured Streaming, data engineering]
description: "Apache Spark 4.3.0 hands-on: ASOF JOIN for point-in-time matching, counter_diff for cumulative metrics, JSON_TABLE and VARIANT functions - with runnable PySpark demos and real output."
---

## Every Streaming Job Has a "Latest Value Before This Timestamp" Problem

**Here is a question that comes up in every market-data, clickstream, and IoT pipeline I have touched: "for each event, what was the most recent state of the world before that event?" A trade lands at 09:30:07 - which quote was valid then? A sensor reading arrives - what was the last calibration?**

Until now, the Spark answer was a self-join on a timestamp range followed by a `row_number()` window to pick the latest, and then you explain to your reviewer why the query plan has two sorts. **Apache Spark 4.3.0**, released last week (over 1,100 Jira tickets, more than 210 contributors), ships a real answer: `ASOF JOIN`. And it is not the only quality-of-life feature in this release - `counter_diff` and `JSON_TABLE` fix two other annoyances I have hit in production.

Let me show you all three with actual code, run locally on Spark 4.3.0, then walk through the rest of the release.

<!--more-->

## Setup: Running 4.3.0 Locally

Everything below runs on the official `spark-4.3.0-bin-hadoop3` tarball with Java 17, in `local[*]` mode. One catch: `pip install pyspark` still gives you 4.2.x as I write this, so grab the tarball from [spark.apache.org/downloads.html](https://spark.apache.org/downloads.html) and put its `python` directory on your `PYTHONPATH`.

One config matters for the first demo: ASOF JOIN ships **off by default**. You need:

```python
spark = (SparkSession.builder
         .master("local[*]")
         .config("spark.sql.join.asofJoin.enabled", "true")
         .getOrCreate())
```

## ASOF JOIN: Point-in-Time Matching, Finally Native

The classic use case: join each trade to the most recent quote **at or before** the trade time, per symbol. Here is the old workaround versus the new syntax:

```sql
-- Spark 4.3.0
SELECT t.trade_ts, t.symbol, t.qty, q.quote_ts, q.bid
FROM trades t ASOF JOIN quotes q
  MATCH_CONDITION (t.trade_ts >= q.quote_ts)
  ON t.symbol = q.symbol
```

`MATCH_CONDITION` is the inequality that defines "as of" - the join picks the closest quote timestamp that satisfies it. The regular `ON` clause handles the equality part (same symbol). Real output from my run:

```text
+-------------------+------+---+-------------------+------+
|trade_ts           |symbol|qty|quote_ts           |bid   |
+-------------------+------+---+-------------------+------+
|2026-11-03 09:30:07|AAPL  |200|2026-11-03 09:30:05|189.52|
|2026-11-03 09:30:15|MSFT  |500|2026-11-03 09:30:12|428.90|
|2026-11-03 09:30:18|AAPL  |150|2026-11-03 09:30:05|189.52|
+-------------------+------+---+-------------------+------+
```

Read the third row: the trade at 09:30:18 matched the 09:30:05 quote, not the 09:30:20 one - because 09:30:20 is *after* the trade. That is exactly the semantics you want, and exactly what the window-function workaround kept getting wrong at boundaries.

`INNER` is the default; `LEFT OUTER ASOF JOIN` keeps events that have no earlier match (my TSLA trade at 09:29:55, before any quote, stayed in with a `NULL` bid). Under the hood it runs as a sort-merge join ([SPARK-58124](https://issues.apache.org/jira/browse/SPARK-58124)), so this is not just syntactic sugar - the plan actually looks like a join, not a join-plus-window. If you build fact tables that need "the dimension as it was when the event happened," this replaces a whole pattern.

## counter_diff: Cumulative Counters to Deltas Without the CASE WHEN

Second annoyance: Prometheus-style metrics. Your scrape gives you `requests_total`, a counter that only goes up - until the process restarts and it resets to zero. Converting to per-interval deltas means "difference from previous row, unless it went down, in which case it's a reset."

Spark 4.3.0 adds `counter_diff` ([SPARK-56820](https://issues.apache.org/jira/browse/SPARK-56820)), a window function that does this natively:

```sql
SELECT server, scrape_ts, requests_total,
       counter_diff(requests_total) OVER (
         PARTITION BY server ORDER BY scrape_ts
       ) AS requests_this_minute
FROM metrics
ORDER BY scrape_ts, server;
```

Output from my run, with a restart simulated between 10:02 and 10:03:

```text
+------+-------------------+--------------+--------------------+
|server|scrape_ts          |requests_total|requests_this_minute|
+------+-------------------+--------------+--------------------+
|api-1 |2026-11-03 10:00:00|1200          |NULL                |
|api-2 |2026-11-03 10:00:00|9800          |NULL                |
|api-1 |2026-11-03 10:01:00|1450          |250                 |
|api-2 |2026-11-03 10:01:00|10050         |250                 |
|api-1 |2026-11-03 10:02:00|1710          |260                 |
|api-1 |2026-11-03 10:03:00|40            |NULL                |  <- reset detected
|api-1 |2026-11-03 10:04:00|190           |150                 |
+------+-------------------+--------------+--------------------+
```

The 10:03 row, where the counter dropped from 1710 to 40, comes back `NULL` - a reset is not a meaningful delta - and the next row correctly diffs against 40, not 1710. First rows per partition are `NULL` too.

One gotcha I hit while testing: the optional second argument is **not** the ordering timestamp. I passed the scrape timestamp and got silent `NULL`s everywhere. It is the *reset marker* - a timestamp indicating when the counter was last zeroed (some exporters expose this), used as an extra reset signal. `DESCRIBE FUNCTION EXTENDED counter_diff` in 4.3.0 has the full semantics; the single-argument form is what you want most of the time.

## JSON_TABLE and VARIANT: Nested JSON Without the Schema Dance

Third one: you have a column of JSON strings (an API payload, a Kafka message) and you want the nested array as typed rows. `from_json` needs a full schema up front; `get_json_object` returns strings one path at a time. `JSON_TABLE` ([SPARK-58366](https://issues.apache.org/jira/browse/SPARK-58366)) is the SQL-standard table-valued function - it goes in the `FROM` clause via `LATERAL` and projects JSON paths into typed columns:

```sql
SELECT r.id, jt.sku, jt.qty, jt.price
FROM raw_events r,
LATERAL JSON_TABLE(r.payload, '$.items[*]'
  COLUMNS (
    sku   STRING PATH '$.sku',
    qty   INT    PATH '$.qty',
    price DOUBLE PATH '$.price'
  )
) AS jt;
```

Given `{"order_id":"A-101","items":[{"sku":"kb-01","qty":1,"price":49.99}, ...]}`, the output:

```text
+---+-----+---+-----+
|id |sku  |qty|price|
+---+-----+---+-----+
|1  |kb-01|1  |49.99|
|1  |ms-04|2  |19.5 |
|2  |hd-11|1  |89.0 |
+---+-----+---+-----+
```

One note from testing: the SQL-standard `NESTED PATH` clause (for drilling into sub-arrays inside the same `JSON_TABLE` call) did not parse in my 4.3.0 build, so for multi-level JSON I would reach for the flat form above per level, or...

...go straight to `VARIANT`. `parse_json` now returns the `variant` type instead of a string, and 4.3.0 adds transformation functions (`variant_set`, `variant_insert`, `variant_delete`, `variant_array_append`, each with a `try_` variant that returns `NULL` instead of erroring). Quick check from my session:

```text
spark.sql("SELECT parse_json('{\"a\": 1}') AS v").printSchema()
root
 |-- v: variant (nullable = false)

variant_get(parse_json('{"a": 1}'), '$.a', 'int')        -> 1
try_variant_get(parse_json('{"a": "hello"}'), '$.a', 'int') -> NULL
```

Bad casts returning `NULL` instead of killing the job is the difference between a pipeline that survives a schema drift event and a 2 AM page. `variant_get` filters also push down to DSv2 sources now ([SPARK-55617](https://issues.apache.org/jira/browse/SPARK-55617)), which matters if your semi-structured columns live in a lakehouse table - the same story as the predicate pushdown I covered in my [Iceberg deletion vectors post](https://saurzcode.in/big-data/apache-iceberg/data-engineering/apache-iceberg-1-12-deletion-vectors/).

## The Rest of the Release, Briefly

I did not run these locally, so this is from the [release notes](https://spark.apache.org/releases/spark-release-4-3-0.html) - but two items deserve attention:

- **Stateful Real-Time Mode** ([SPARK-58635](https://issues.apache.org/jira/browse/SPARK-58635)): Real-Time Mode - the ~100 ms end-to-end latency path for Structured Streaming - now supports streaming aggregation, `dropDuplicates`, and `transformWithState`, and drops the `@Experimental` tag. Underneath: concurrent stage scheduling and pipelined shuffles, so producer and consumer stages overlap instead of taking turns. If you wrote off Real-Time Mode because your query had a `groupBy`, revisit it.
- **SCD Type 2 in Auto CDC** ([SPARK-58321](https://issues.apache.org/jira/browse/SPARK-58321)): Declarative Pipelines' `AUTO CDC` can now preserve history (Type 2) instead of only keeping the latest record, through Python, SQL, and Spark Connect. That overlaps heavily with what people were hand-building with `MERGE` - which I walked through in the [streaming Kafka to Iceberg post](https://saurzcode.in/big-data/apache-iceberg/apache-kafka/spark/data-engineering/streaming-kafka-to-iceberg-lakehouse/).

Also in the release: faster iteration on small data, Spark Connect REST endpoints for inspecting sessions and operations with operation IDs for request attribution, a more complete Connect JDBC driver, ANSI `UNNEST`, and a preview of nanosecond-precision timestamps.

One more thing buried in the notes: Spark is moving to a **quarterly feature-release cadence**. If 4.3.0 is the shape of things to come - a few big features plus a pile of SQL ergonomics every three months - keeping a local tarball setup for release-day testing is worth the disk space. My `MATCH_CONDITION` and `counter_diff` experiments above took under an hour from download to real output, and both turned up behavior the docs alone would not have told me (the opt-in config flag, the reset-marker second argument).

Upgrade cautiously as always - but `ASOF JOIN` alone earns this release a test run.

## References

- [Spark 4.3.0 release notes](https://spark.apache.org/releases/spark-release-4-3-0.html)
- [ASOF JOIN syntax reference](https://spark.apache.org/docs/4.3.0/sql-ref-syntax-qry-select-join.html)
- [SPARK-58092](https://issues.apache.org/jira/browse/SPARK-58092) (ASOF JOIN), [SPARK-56820](https://issues.apache.org/jira/browse/SPARK-56820) (counter_diff), [SPARK-58366](https://issues.apache.org/jira/browse/SPARK-58366) (JSON_TABLE), [SPARK-57804](https://issues.apache.org/jira/browse/SPARK-57804) (VARIANT functions)
- [Spark downloads](https://spark.apache.org/downloads.html) - 4.3.0 is tarball-only for now; PyPI still lags a minor version behind
