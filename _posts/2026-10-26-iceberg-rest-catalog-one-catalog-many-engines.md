---
layout: post
title: "Iceberg REST Catalog: One Catalog, Every Engine (Spark, Trino, Flink, PyIceberg)"
date: 2026-10-26
categories: [big-data, Apache-Iceberg, Data-Engineering]
tags: [Apache Iceberg, REST catalog, Spark, Trino, Flink, PyIceberg, lakehouse, data engineering]
description: "Deep dive into the Apache Iceberg REST catalog: why it replaced Hive thrift for multi-engine lakehouses, verified configs for Spark, Trino, Flink and PyIceberg, and a runnable demo."
---

## The Metastore Is the Last Thing Coupling Your Engines Together

**Your Spark jobs write Iceberg tables through the Hive metastore. Then the analytics team wants Trino on the same tables. Then the streaming team wants Flink. Then someone writes a Python script. And suddenly four engines are sharing thrift URIs, Kerberos keytabs, and database credentials - and every engine upgrades on its own schedule. Sound familiar?**

In my [intro to Apache Iceberg](https://saurzcode.in/big-data/apache-iceberg/data-engineering/apache-iceberg/), I covered why the table format matters: ACID commits, schema evolution, time travel. But the table format is only half the story. The **catalog** - the thing that answers "what is the current metadata file for table X?" - is where multi-engine architectures quietly fall apart. Hive metastore ties you to Hadoop-era dependencies and a thrift protocol. A JDBC catalog means handing database credentials to every engine. Glue and Nessie each need their own client implementation in every language.

The Iceberg community's answer is the **REST catalog**: a single HTTP/JSON protocol, defined by an [OpenAPI spec](https://iceberg.apache.org/rest-catalog-spec/), that any engine can implement once and use to talk to any catalog. One endpoint. Every engine. Let's dig in.

<!--more-->

## What the REST Catalog Actually Is

The [REST catalog spec](https://iceberg.apache.org/rest-catalog-spec/) is refreshingly honest about why it exists: as Iceberg grew to more languages and engines, "pluggable catalogs started to cause some practical problems. Catalogs needed to be implemented in multiple languages and it proved difficult for commercial offerings to support many different catalogs and clients."

So the community did what Hive did with thrift, but for the HTTP era: a common, versioned API for catalog operations - list namespaces, create table, load table, commit - that sits between the engine and wherever the metadata actually lives. The engine speaks REST; the server speaks whatever its backing store needs.

The spec calls out what this buys you:

- **Language and engine compatibility** - a new engine or language needs one REST client to support every REST catalog, instead of N catalog integrations.
- **Improved reliability** - change-based commits enable server-side deconfliction and retries, so two engines committing concurrently get far fewer failures.
- **Simplified metadata management** - the catalog service writes root metadata, so metadata version upgrades stop being a per-engine rollout.
- **Advanced features** - lazy snapshot loading, multi-table commits, and caching become possible.
- **Security** - the protocol supports secure table sharing using **credential vending** or remote signing: instead of every engine holding long-lived S3 credentials, the catalog hands out short-lived, table-scoped credentials.

That last point is the one I see teams underrate. With a Hive metastore, every engine still needs direct object-store credentials. With credential vending, the engine asks the catalog "may I read table X?" and gets back temporary credentials scoped to exactly that. Your S3 bucket policy stops being a free-for-all.

## One Catalog, Four Engines

Here is the whole pitch in one picture: a single REST endpoint - say `http://iceberg-rest:8181` - and Spark, Trino, Flink, and PyIceberg all pointed at it. No thrift. No JDBC jars. No shared database password.

### Spark

From the [Iceberg Spark configuration docs](https://iceberg.apache.org/docs/latest/spark-configuration/):

```properties
spark.sql.catalog.rest_prod = org.apache.iceberg.spark.SparkCatalog
spark.sql.catalog.rest_prod.type = rest
spark.sql.catalog.rest_prod.uri = http://iceberg-rest:8181
spark.sql.catalog.rest_prod.warehouse = lakehouse
```

That's it. `spark.sql.catalog.<name>.type = rest` swaps the catalog implementation without touching a single query. Everything from my [Kafka-to-Iceberg streaming post](https://saurzcode.in/big-data/apache-iceberg/apache-kafka/spark/data-engineering/streaming-kafka-to-iceberg-lakehouse/) - the `foreachBatch` writes, the table maintenance calls - works unchanged against a REST catalog, because the code never knew which catalog it was talking to.

### Trino

From the [Trino Iceberg connector docs](https://trino.io/docs/current/connector/iceberg.html):

```properties
connector.name=iceberg
iceberg.catalog.type=rest
iceberg.rest-catalog.uri=http://iceberg-rest:8181
iceberg.rest-catalog.warehouse=lakehouse
iceberg.rest-catalog.security=OAUTH2
iceberg.rest-catalog.oauth2.credential=client_id:client_secret
iceberg.rest-catalog.vended-credentials-enabled=true
```

A few properties worth knowing: `security` supports `NONE`, `SIGV4`, `GOOGLE`, and `OAUTH2` (with either a `token` or a `credential` for the client-credentials flow). `vended-credentials-enabled=true` is the flag that turns on the credential vending I described above - Trino will use the temporary credentials the catalog returns for file access instead of its own.

### Flink

From the [Iceberg Flink docs](https://iceberg.apache.org/docs/latest/flink/):

```sql
CREATE CATALOG rest_catalog WITH (
  'type'='iceberg',
  'catalog-type'='rest',
  'uri'='http://iceberg-rest:8181'
);
```

Same table, same catalog, now queryable from Flink SQL. The [Flink configuration reference](https://iceberg.apache.org/docs/latest/flink-configuration/) adds `credential` (OAuth2 client credentials exchange) and `token` options when your REST server requires auth.

### PyIceberg

From the [PyIceberg configuration docs](https://pyiceberg.apache.org/configuration/), in `~/.pyiceberg.yaml`:

```yaml
catalog:
  default:
    uri: http://iceberg-rest:8181
    credential: t-1234:secret
    warehouse: lakehouse
```

This is also the fix for a limitation I glossed over in my [MCP for Data Engineers post](https://saurzcode.in/data-engineering/ai/mcp-for-data-engineers-iceberg-lakehouse/): that demo pointed PyIceberg at a local SQL catalog, which meant the AI agent was browsing a *different* catalog than production. Point it at the REST catalog instead and your agent sees exactly the tables Spark and Trino see - same namespaces, same snapshots.

## Run It: The Code Doesn't Change, Only the Config Does

The cleanest way to feel the REST catalog's value is to notice what *doesn't* change. Here is a complete PyIceberg script. I ran it locally against a throwaway SQL catalog (SQLite) - but the REST swap is a four-line config change at the top, which is the entire point:

```python
import os, datetime, pyarrow as pa
from pyiceberg.catalog import load_catalog

CATALOG_TYPE = os.environ.get("CATALOG_TYPE", "sql")

if CATALOG_TYPE == "rest":
    # Any REST catalog: Polaris, Lakekeeper, Nessie, AWS Glue's Iceberg REST endpoint...
    catalog = load_catalog(
        "rest",
        **{
            "uri": "http://iceberg-rest:8181/catalog",
            "credential": "client1:secret1",   # OAuth2 client credentials
            "warehouse": "lakehouse",
        },
    )
else:
    # Local stand-in so you can run this with zero infrastructure
    catalog = load_catalog(
        "sql",
        **{
            "uri": "sqlite:////tmp/catalog.db",
            "warehouse": "file:///tmp/warehouse",
        },
    )

catalog.create_namespace_if_not_exists("demo")

schema = pa.schema([
    pa.field("event_id", pa.int64(), nullable=False),
    pa.field("event_type", pa.string()),
    pa.field("amount", pa.float64()),
    pa.field("ts", pa.timestamp("us")),
])
try:
    table = catalog.create_table("demo.payments", schema=schema)
except Exception:
    table = catalog.load_table("demo.payments")

data = pa.Table.from_pylist(
    [
        {"event_id": 1, "event_type": "purchase", "amount": 49.99,  "ts": datetime.datetime(2026, 10, 26, 9, 15, 0)},
        {"event_id": 2, "event_type": "refund",   "amount": -9.99,  "ts": datetime.datetime(2026, 10, 26, 9, 16, 12)},
        {"event_id": 3, "event_type": "purchase", "amount": 129.00, "ts": datetime.datetime(2026, 10, 26, 9, 17, 45)},
    ],
    schema=table.schema().as_arrow(),
)
table.append(data)

snap = table.current_snapshot()
print("table:", table.name())
print("snapshot id:", snap.snapshot_id)
print("rows:", table.scan().to_arrow().num_rows)
print(table.scan().to_pandas().to_string(index=False))
```

Actual output from my run (PyIceberg 0.12.0, Python 3.10):

```text
table: ('demo', 'payments')
snapshot id: 8622846007602441676
rows: 3
 event_id event_type  amount                  ts
        1   purchase   49.99 2026-10-26 09:15:00
        2     refund   -9.99 2026-10-26 09:16:12
        3   purchase  129.00 2026-10-26 09:17:45
```

Every line below the config block - namespace creation, table creation, the Arrow append, the snapshot read - is identical no matter which catalog backs it. That is what the REST protocol standardizes. Your Spark DataFrame writes, your Trino `CREATE TABLE`, your Flink SQL, and this Python script are all just HTTP clients of the same `/v1` API.

If you want a real REST server locally, the spec page points at the community-maintained `iceberg-rest-fixture` Docker image - the same fixture Iceberg's own test suite uses.

## Who Can Serve a REST Catalog?

You need something on the server side. The good news: options have multiplied fast.

- **[Apache Polaris (Incubating)](https://polaris.apache.org/)** - Snowflake's donated open-source catalog, now an Apache incubator project.
- **[Lakekeeper](https://github.com/lakekeeper/lakekeeper)** - an Apache-2.0 REST catalog written in Rust, with access control, credential vending, and audit built in.
- **[Project Nessie](https://projectnessie.org/)** - the git-for-data catalog, with branch-and-merge semantics for tables; the Spark, Trino, and Flink docs all list `nessie` as a built-in catalog type alongside `rest`.
- **[AWS Glue Data Catalog](https://docs.aws.amazon.com/glue/latest/dg/connect-glu-iceberg-rest.html)** - AWS now exposes an Iceberg REST endpoint directly against Glue, so existing Glue tables are reachable by any REST client without migrating metadata.

And because the protocol is a public OpenAPI spec, new engines and platforms keep showing up with REST catalog support. The network effect is the feature.

## When Not to Reach for REST

Honesty section, because no architecture is free:

- **Single-engine shops**: if everything you have is Spark-on-Hadoop and will stay that way, the Hive metastore you already run is fine. REST buys you decoupling you may not need yet.
- **It's another service to run**: the REST catalog is a stateless HTTP service, but it still needs deployment, HA, monitoring, and auth. (Glue's managed endpoint is the exception - nothing to run.)
- **Mind the client cache**: Spark, Trino, and Flink all cache catalog entries locally (Spark's `cache-enabled` defaults to `true` with a 30-second expiration). One engine's `DROP TABLE` may be invisible to another engine for up to the cache window. Usually fine; surprising once.
- **Small files still happen**: a better catalog doesn't fix a bad file layout. That problem still belongs to your maintenance jobs - I wrote a whole [field guide on the small-files problem](https://saurzcode.in/big-data/apache-iceberg/spark/data-engineering/small-files-field-guide/) last week.

## Wrapping Up

The REST catalog turns the Iceberg catalog from a per-engine integration problem into a shared service: one OpenAPI-defined protocol, one endpoint to secure, credential vending instead of scattered S3 keys, and every engine - Spark, Trino, Flink, PyIceberg, and the growing list behind them - reading and committing through the same door. If your lakehouse has more than one engine in it (and whose doesn't, in 2026?), this is the piece that makes "one catalog, many engines" real instead of aspirational.

**Are you running a REST catalog in production - Polaris, Lakekeeper, Nessie, Glue, something homegrown? What's bitten you: auth setup, caching surprises, multi-engine commits? Share your experience in the comments!**

## References

- [Apache Iceberg REST Catalog Spec](https://iceberg.apache.org/rest-catalog-spec/)
- [Iceberg Spark Configuration - Catalogs](https://iceberg.apache.org/docs/latest/spark-configuration/)
- [Trino Iceberg Connector](https://trino.io/docs/current/connector/iceberg.html)
- [Iceberg Flink Getting Started](https://iceberg.apache.org/docs/latest/flink/) and [Flink Configuration](https://iceberg.apache.org/docs/latest/flink-configuration/)
- [PyIceberg Configuration - REST Catalog](https://pyiceberg.apache.org/configuration/)
- [AWS Glue Iceberg REST endpoint](https://docs.aws.amazon.com/glue/latest/dg/connect-glu-iceberg-rest.html)
- [Apache Polaris (Incubating)](https://polaris.apache.org/)
- [Lakekeeper on GitHub](https://github.com/lakekeeper/lakekeeper)
