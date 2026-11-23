---
layout: post
title: "DuckDB 2.0 LTS: Triggers, First-Class VARIANT, and NEAREST Joins - Tested on 2.0.1"
date: 2026-11-23
categories: [big-data, DuckDB, Data-Engineering]
tags: [DuckDB, DuckDB 2.0, VARIANT, triggers, NEAREST join, SQL, agent mode, analytics, data engineering]
description: "Hands-on with DuckDB 2.0 LTS: triggers as incremental materialized views, shredded VARIANT, NEAREST joins, agent mode, and migration gotchas."
---

## Your Laptop Analytics Engine Just Grew a Server Mode, Triggers, and an Agent Mode

**DuckDB has always been the database you embed, not the database you operate. No server, no daemon, no DBA. DuckDB 2.0 keeps that philosophy but ships the kind of feature list you would expect from a major Postgres release: triggers, a first-class `VARIANT` type, a client-server protocol, and a SQL parser that extensions can hook into.**

Two dates make this the right week to look at it. DuckDB 1.4, the previous LTS line, reached the end of its support window on **November 17, 2026** - last Tuesday. And on **November 20**, the team released **DuckDB 2.0.1**, the first patch release of the 2.0 LTS line, fixing the rough edges that early adopters hit. The 2.0 line itself (codenamed "Cinnamon Teal") landed on October 21 and is [supported until at least October 2027](https://www.duckdb.org/2026/10/21/announcing-duckdb-200). If you have been waiting for the dust to settle before upgrading, the dust has settled.

Every example below was executed against the real DuckDB 2.0.1 CLI while preparing this article, and the outputs shown are the actual outputs, not reconstructions. Where a feature comes straight from the release notes without a local run, that is called out.

<!--more-->

## Setup: Getting 2.0.1

The CLI is a single binary, installed with the official script:

```bash
curl https://install.duckdb.org | sh
~/.duckdb/cli/latest/duckdb --version
```

```
v2.0.1 (Cyanoptera) 8d78114e90
```

One environment gotcha worth knowing before we start: the [migration guide](https://duckdb.org/docs/2.0/operations_manual/migration) notes that **the DuckDB 2.0 Python client requires Python 3.11 or newer**. This is easy to verify accidentally - on a machine with Python 3.10, `pip install duckdb` silently resolves to the older 1.5.6 client, and `pip install duckdb==2.0.1` fails with "No matching distribution found". If your pipeline pins an older Python, your DuckDB upgrade is blocked on a Python upgrade, not the other way around.

## Feature 1: Triggers - Incremental Materialized Views by Hand

DuckDB 2.0 adds `CREATE TRIGGER` with `BEFORE`/`AFTER`, `FOR EACH ROW`/`FOR EACH STATEMENT`, transition tables via `REFERENCING OLD/NEW TABLE`, and `DROP TRIGGER`. The audit-table use case is the classic one, but the more interesting pattern for data engineers is maintaining an aggregate table incrementally - the poor man's materialized view.

The example below (adapted from the [official 2.0 announcement](https://www.duckdb.org/2026/10/21/announcing-duckdb-200) and executed on 2.0.1) keeps a running average age per nationality, maintained by two triggers:

```sql
CREATE TABLE people (name VARCHAR, nationality VARCHAR, age INTEGER);
CREATE TABLE age_statistics (
    nationality VARCHAR PRIMARY KEY,
    sum_age INTEGER, num_people INTEGER, average_age DOUBLE
);

CREATE TRIGGER people_insert
    AFTER INSERT ON people
    REFERENCING NEW TABLE AS n
    FOR EACH STATEMENT
    MERGE INTO age_statistics s
    USING (
        SELECT nationality, sum(age) AS sum_age, count(*) AS num_people
        FROM n GROUP BY nationality
    ) d
    ON s.nationality = d.nationality
    WHEN MATCHED THEN UPDATE SET
        sum_age = s.sum_age + d.sum_age,
        num_people = s.num_people + d.num_people,
        average_age = (s.sum_age + d.sum_age) / (s.num_people + d.num_people)
    WHEN NOT MATCHED THEN INSERT
        VALUES (d.nationality, d.sum_age, d.num_people, d.sum_age / d.num_people);

CREATE TRIGGER people_delete
    AFTER DELETE ON people
    REFERENCING OLD TABLE AS o
    FOR EACH STATEMENT
    MERGE INTO age_statistics s
    USING (
        SELECT nationality, sum(age) AS sum_age, count(*) AS num_people
        FROM o GROUP BY nationality
    ) d
    ON s.nationality = d.nationality
    WHEN MATCHED AND s.num_people = d.num_people THEN DELETE
    WHEN MATCHED THEN UPDATE SET
        sum_age = s.sum_age - d.sum_age,
        num_people = s.num_people - d.num_people,
        average_age = (s.sum_age - d.sum_age) / (s.num_people - d.num_people);
```

Now insert six people and read the aggregate:

```sql
INSERT INTO people VALUES
    ('Alice','US',34),('Bram','NL',27),('Csilla','HU',45),
    ('Dave','US',58),('Eva','NL',19),('Femke','NL',41);
SELECT * FROM age_statistics ORDER BY nationality;
```

```
┌─────────────┬─────────┬────────────┬─────────────┐
│ nationality │ sum_age │ num_people │ average_age │
├─────────────┼─────────┼────────────┼─────────────┤
│ HU          │ 45      │ 1          │ 45.0        │
│ NL          │ 87      │ 3          │ 29.0        │
│ US          │ 92      │ 2          │ 46.0        │
└─────────────┴─────────┴────────────┴─────────────┘
```

Delete Alice and everyone from Hungary, and the statistics table updates itself:

```sql
DELETE FROM people WHERE name = 'Alice';
DELETE FROM people WHERE nationality = 'HU';
SELECT * FROM age_statistics ORDER BY nationality;
```

```
┌─────────────┬─────────┬────────────┬─────────────┐
│ nationality │ sum_age │ num_people │ average_age │
├─────────────┼─────────┼────────────┼─────────────┤
│ NL          │ 87      │ 3          │ 29.0        │
│ US          │ 58      │ 1          │ 58.0        │
└─────────────┴─────────┴────────────┴─────────────┘
```

The US row correctly drops to Dave alone (58.0), and the HU row disappears entirely once its last person leaves. Real materialized views are still on the roadmap, but triggers get you most of the way there today for slowly changing aggregates.

## Feature 2: VARIANT Becomes First-Class

DuckDB 1.5 introduced `VARIANT` for semi-structured data. In 2.0 it is fully integrated: DuckDB detects the common structure across rows and "shreds" it, so schemaless JSON-shaped data compresses and executes like columnar data, with shredded `VARIANT` reading and writing for Parquet end to end. A family of `variant_*` functions ships alongside:

```sql
CREATE TABLE events (payload VARIANT);
INSERT INTO events VALUES
    ('{"user": {"id": 42, "tags": ["a", "b"]}}'::JSON::VARIANT),
    ('{"event": "click", "x": 10, "y": 20}'::JSON::VARIANT);

SELECT variant_type(payload) AS vtype, variant_keys(payload) AS keys
FROM events;
```

```
┌────────┬───────────────┐
│ vtype  │     keys      │
├────────┼───────────────┤
│ OBJECT │ [user]        │
│ OBJECT │ [event, x, y] │
└────────┴───────────────┘
```

Two rows with completely different shapes, one column, no JSON text parsing at query time. If you read the [Spark 4.3 post](https://saurzcode.in/big-data/apache-spark/data-engineering/apache-spark-4-3-new-features/) from two weeks ago, you saw Spark's `VARIANT` land in the same release window - semi-structured data with columnar performance is clearly where both engines are heading, and it pairs naturally with the Iceberg v3 spec work covered in the [Iceberg 1.12 post](https://saurzcode.in/big-data/apache-iceberg/data-engineering/apache-iceberg-1-12-deletion-vectors/).

## Feature 3: NEAREST Joins - Top-k Similarity as a Join Clause

If you have ever written a "find the k closest embeddings for each query" lookup, you know the usual shape: a cross join, a distance computation, `row_number()`, a filter. DuckDB 2.0 makes it a join clause. The syntax is `NEAREST k BY SIMILARITY expr` (higher is closer) or `NEAREST k BY DISTANCE expr` (lower is closer), per the [FROM/JOIN documentation](https://www.duckdb.org/docs/2.0/sql/query_syntax/from):

```sql
CREATE TABLE docs(id INTEGER, embedding FLOAT[3]);
INSERT INTO docs VALUES
    (1,[1.0,0.0,0.0]), (2,[0.0,1.0,0.0]), (3,[0.9,0.1,0.0]);
CREATE TABLE queries(qid INTEGER, embedding FLOAT[3]);
INSERT INTO queries VALUES
    (101,[1.0,0.0,0.0]), (102,[0.0,1.0,0.0]);

SELECT q.qid, d.id AS nearest_doc,
       round(array_cosine_similarity(q.embedding, d.embedding), 3) AS sim
FROM queries q
INNER JOIN docs d NEAREST 2
BY SIMILARITY array_cosine_similarity(q.embedding, d.embedding)
ORDER BY q.qid, sim DESC;
```

```
┌──────┬─────────────┬───────┐
│ qid  │ nearest_doc │  sim  │
├──────┼─────────────┼───────┤
│ 101  │ 1           │ 1.0   │
│ 101  │ 3           │ 0.994 │
│ 102  │ 2           │ 1.0   │
│ 102  │ 3           │ 0.11  │
└──────┴─────────────┴───────┘
```

Each query row matched its two closest documents, no window function in sight. Prefix with `APPROX` for an approximate search on larger inputs. For a local RAG prototype or a dedup pass over embeddings sitting in Parquet, this removes the last reason to stand up a separate vector index for small-scale work.

## Feature 4: Agent Mode in the CLI

This one is a sign of the times. Coding agents (Claude Code, Codex, Cursor) increasingly drive the DuckDB CLI directly. The 2.0 CLI detects when an agent is running it and switches to **agent mode**: compact Markdown tables instead of padded boxes, explicit truncation notices, runaway queries stopped early, and errors reported as JSON. The release post reports a 59% reduction in output volume the model has to read on TPC-H.

You can force it on with `-agent`:

```bash
echo "SELECT * FROM (VALUES (1,'a'),(2,'b')) t(id,x);" | duckdb -agent
```

```
duckdb agent mode on (-agent); .help agent explains the output
| id:INTEGER | x:VARCHAR |
|---|---|
| 1 | a |
| 2 | b |
```

Types inline in the header, no box-drawing characters, nothing for the model to mis-tokenize. If you build agentic tooling that shells out to DuckDB, pin `-agent` in your invocation and stop parsing pretty-printed boxes.

## Feature 5: Quality-of-Life SQL

Three smaller additions that were verified locally:

**The `$variable` shorthand.** No more `getvariable('x')` clutter:

```sql
SET VARIABLE cutoff = 30;
SELECT * FROM (VALUES ('Alice',34),('Eva',19),('Dave',58)) AS t(name, age)
WHERE age > $cutoff;
```

```
┌───────┬─────┐
│ name  │ age │
├───────┼─────┤
│ Alice │ 34  │
│ Dave  │ 58  │
└───────┴─────┘
```

**Data-modifying CTEs.** `INSERT`, `UPDATE`, `DELETE`, and `COPY` can now be pipeline steps, so "move these rows and tell me what moved" is one statement:

```sql
CREATE TABLE raw_events(id INTEGER, payload VARCHAR);
INSERT INTO raw_events VALUES (1,'a'),(2,'b'),(3,'c');

WITH moved AS (
    DELETE FROM raw_events WHERE id <= 2 RETURNING *
)
SELECT * FROM moved ORDER BY id;
```

```
┌────┬─────────┐
│ id │ payload │
├────┼─────────┤
│ 1  │ a       │
│ 2  │ b       │
└────┴─────────┘
```

**JSON mutation functions.** `json_set`, `json_insert`, `json_replace`, and `json_remove` return modified copies of a document:

```sql
SELECT json_set('{"a": 1, "b": 2}', '/c', '3'::JSON)      AS added,
       json_replace('{"a": 1, "b": 2}', '/a', '99'::JSON) AS replaced,
       json_remove('{"a": 1, "b": 2}', '/b')              AS removed;
```

```
┌─────────────────────┬────────────────┬─────────┐
│        added        │   replaced     │ removed │
├─────────────────────┼────────────────┼─────────┤
│ {"a":1,"b":2,"c":3} │ {"a":99,"b":2} │ {"a":1} │
└─────────────────────┴────────────────┴─────────┘
```

## DuckDB as a Server: Quack and CONNECT

The headline architectural addition is the polished **Quack protocol**: any DuckDB process can serve its databases to other DuckDB processes, and the new `CONNECT` statement points your session at a remote database (Quack, PostgreSQL, or MySQL) in one command, with pushdown of queries to the remote server. The CLI adds `-serve` and `-connect` shortcuts. From the official announcement, the pattern looks like this:

```sql
-- server side
CALL quack_serve(token = 'my_token');

-- client side
ATTACH 'quack:localhost' AS qk (TOKEN 'my_token');
CONNECT qk;
SELECT * FROM events;
```

By default the server listens on `localhost` only; for remote access the docs recommend a TLS-terminating reverse proxy rather than the testing-only `allow_other_hostname` option. The server-side of this flow needs a persistent process, so treat the snippet above as the documented shape from the release post rather than output reproduced here. The takeaway: DuckDB can now fill the "shared analytics cache" role between your notebooks and your warehouse without standing up a different database.

## Lakehouse Extensions Keep Closing the Gap

Two core extension updates matter if you read this blog regularly:

- The **Iceberg extension** adds REST catalog `ATTACH` options that derive a table's location from its namespace, or load metadata from the `metadata-location` file the catalog returns, plus controls for URL prefix and namespace separator. That makes the [Iceberg REST catalog setup](https://saurzcode.in/big-data/apache-iceberg/data-engineering/iceberg-rest-catalog-one-catalog-many-engines/) we wired up with Spark, Trino, and PyIceberg reachable from DuckDB with less glue.
- The **Delta extension** can now create Delta tables with `CREATE TABLE` (including partitioning and table properties), and supports time travel.
- DuckLake 1.1 shipped with a new specification and reference implementation.

## Migration: The Parts That Bite

The [migration guide](https://duckdb.org/docs/2.0/operations_manual/migration) is short but dense. The items most likely to hit a real deployment:

**Storage format is one-way.** Every new database file created by 2.0 uses storage version 69, which DuckDB versions before 2.0 **cannot read**. The other direction is fine: 2.0 reads and writes existing 1.x files, and those files keep their old storage version so older DuckDB can still open them. If you need a new file to stay readable by an older version, write it explicitly:

```bash
duckdb my.db -storage-version v1.5.6 -c "CREATE TABLE t (x INT);"
```

For a team where the notebook fleet upgrades faster than the batch jobs, this is the migration plan: upgrade readers first, keep writing in the old format until everything is on 2.0, then flip.

**The old lambda syntax is off by default.** The single-arrow form now fails:

```sql
SELECT list_transform([1, 2, 3], x -> x + 1);
```

```
Binder Error: Deprecated lambda arrow (->) detected. Please transition to the new lambda syntax, i.e.., lambda x, i: x + i, before DuckDB's next release.
Use SET lambda_syntax='ENABLE_SINGLE_ARROW' to revert to the deprecated behavior.
```

The Python-style form works:

```sql
SELECT list_transform([1, 2, 3], lambda x: x + 1) AS plus_one;
```

```
┌───────────┐
│ plus_one  │
├───────────┤
│ [2, 3, 4] │
└───────────┘
```

The escape hatch (`SET lambda_syntax = 'enable_single_arrow'`) and the old syntax itself are both removed in 2.1, so fix the SQL now rather than pinning the setting.

**The new PEG parser is the default.** Compatible by design, with two deliberate behavior changes worth knowing: `~` and `!~` now do *partial* regex match like PostgreSQL (`'abc' ~ 'b'` is now `true`), and any error inside an explicit transaction now aborts the whole transaction - previously parser and binder errors left the transaction usable. A `legacy_parser` extension exists if you need a bridge.

**MERGE and UPDATE ... FROM semantics flipped twice, so check your version.** In 2.0.0, a target row matched by multiple source rows raised an error in `MERGE` and was updated once in `UPDATE ... FROM`. Enforcing that serialized large updates and caused a significant performance regression, so [2.0.1 reverted to the 1.x behavior](https://duckdb.org/2026/11/20/announcing-duckdb-201): the row is updated once per match, and the final value can be non-deterministic. Verified on 2.0.1:

```sql
CREATE TABLE tgt(id INTEGER, val VARCHAR);
CREATE TABLE src(id INTEGER, val VARCHAR);
INSERT INTO tgt VALUES (1,'orig');
INSERT INTO src VALUES (1,'a'),(1,'b');

MERGE INTO tgt USING src ON tgt.id = src.id
WHEN MATCHED THEN UPDATE SET val = src.val;
SELECT * FROM tgt;
```

```
┌────┬─────┐
│ id │ val │
├────┼─────┤
│ 1  │ a   │
└────┴─────┘
```

One target row, two matching source rows, one silent winner. A proper fix that keeps both correctness and performance is planned for 2.1. Until then, deduplicate your source rows or make the `ON` condition unique - do not rely on which match wins.

## What 2.0.1 Fixed Since Last Month

The first patch release is more than housekeeping:

- **Secret scope matching tightened.** A `SECRET` scoped to `s3://bucket-` previously also matched `s3://bucket-1/`, which could send credentials to the wrong bucket. Scopes must now match the full host or bucket name. Audit your scoped secrets before upgrading.
- **Silent data loss workaround for a Linux kernel bug** (CVE-2026-97945) that can zero lazily freed memory after reuse. The bundled allocator no longer frees memory that way; if you cannot upgrade, set `DUCKDB_JE_MALLOC_CONF=muzzy_decay_ms:0`.
- **A correctness fix for reading 1.x files**: 2.0.0 could miss rows containing `NULL` values when filtering tables stored by DuckDB 1.x. If you tested 2.0.0 against old database files and saw row-count drift, this was probably it.
- **Security fixes**: `CREATE SECRET` is now refused when `enable_external_access=false`, a remote path traversal issue under the same setting is closed, and a Brotli decoder CVE is patched.
- **Sirius**, a new core extension, runs DuckDB queries natively on NVIDIA GPUs (Linux, CUDA 12 or 13 driver). Queries using features Sirius does not support yet fall back to the CPU engine.

## Should You Upgrade?

The honest answer depends on what reads your files. The feature set (triggers, shredded `VARIANT`, `NEAREST` joins, agent mode, Quack) is real and the examples above are runnable today. The storage format one-way door means the upgrade order matters: anything still on 1.x that must read shared DuckDB files has to go last, or you write new files with an explicit `-storage-version`. With 1.4 support ended on November 17 and 1.5 supported until March 2027, the comfortable window is "upgrade before Q1 ends", and 2.0.1 is a much safer landing spot than 2.0.0 was.

If your workloads are pure SQL over Parquet on object storage, asynchronous I/O alone is worth the migration testing - the I/O layer now issues reads in the background and scales independently of query processing, which the team measured as dramatically faster queries on `s3://`.

What is your DuckDB upgrade plan - are you jumping to 2.0 now that the first patch is out, or holding on 1.5 until March? And if you have tried agent mode with your coding assistant, does the compact output actually help, or does your agent ignore the CLI entirely? Share your experience in the comments.

## References

- [Announcing DuckDB 2.0.0 LTS "Cinnamon Teal"](https://www.duckdb.org/2026/10/21/announcing-duckdb-200) (October 21, 2026)
- [Announcing DuckDB 2.0.1 LTS](https://duckdb.org/2026/11/20/announcing-duckdb-201) (November 20, 2026)
- [Migrating to DuckDB 2.0](https://duckdb.org/docs/2.0/operations_manual/migration)
- [FROM and JOIN Clauses - Nearest Joins](https://www.duckdb.org/docs/2.0/sql/query_syntax/from)
- [What's New in the Docs for 2.0](https://duckdb.org/docs/2.0/whats_new_in_the_docs)
- [A Preview of DuckDB v2.0](https://www.duckdb.org/2026/08/17/duckdb-20-highlights)
