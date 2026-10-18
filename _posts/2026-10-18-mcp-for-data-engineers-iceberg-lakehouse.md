---
layout: post
title: "MCP for Data Engineers: Connecting AI Agents to Your Iceberg Lakehouse"
date: 2026-10-18
categories: [Data-Engineering, AI]
tags: [Model Context Protocol, MCP, Apache Iceberg, PyIceberg, AI agents, Claude, data engineering, lakehouse]
description: "Build an MCP server over your Apache Iceberg catalog with PyIceberg and the MCP Python SDK so Claude and other AI agents can browse and query tables."
---

## Your AI Agent Can't See Your Lakehouse - Let's Fix That

**How many times this year have you pasted a table schema into a chat window so the AI could help you write a query?**

In my [last post](https://saurzcode.in/big-data/apache-iceberg/apache-kafka/spark/data-engineering/streaming-kafka-to-iceberg-lakehouse/), we streamed Kafka events into an Apache Iceberg lakehouse with Spark Structured Streaming. The natural follow-up in 2026: instead of querying that table myself, can I just *ask an AI agent* what's in it - and get a real answer from the live catalog, not a pasted screenshot?

That is exactly what the **Model Context Protocol (MCP)** is for. In this post, we'll build a small MCP server that sits on top of an Iceberg catalog and exposes it to any MCP-capable agent (Claude, IDEs, your own agents):

- What MCP actually is, in data-engineering terms
- A working MCP server over an Iceberg catalog (Python, ~60 lines)
- Wiring it into an agent host like Claude
- The security lines you should not cross

Every code sample below was run end to end while writing this post - client, server, and a real Iceberg table.

---
<!--more-->

## What MCP Is, Without the Hype

[The MCP specification](https://modelcontextprotocol.io/specification/2026-07-28) defines an open protocol for connecting LLM applications to external data sources and tools. Three roles matter:

- **Host** - the LLM application the user talks to (Claude Desktop, Claude Code, an IDE)
- **Client** - a connector inside the host, one per server
- **Server** - a process that exposes **tools** (functions the model can call), **resources** (data it can read), and **prompts** (templated workflows)

The wire format is plain **JSON-RPC 2.0**, usually over stdio for a local server or HTTP for a remote one. If you've used the Language Server Protocol, the idea is familiar: LSP standardized "how does an editor talk to a language," MCP standardizes "how does an agent talk to your systems." The spec is versioned by date (the latest revision as of writing is `2026-07-28`), and the SDK negotiates a compatible revision between client and server automatically.

Why should a data engineer care? Because the spec's "tools" are a perfect fit for catalog operations: *list namespaces*, *show schema*, *preview rows* are exactly the things an agent needs before it can help you with a table - and they're exactly what your Iceberg catalog already knows.

## Why the Iceberg Catalog Is the Right Attachment Point

PyIceberg is [catalog-centric by design](https://py.iceberg.apache.org/): every read and write goes through a catalog. And the [Iceberg REST Catalog](https://iceberg.apache.org/docs/latest/rest-catalog/) spec means one HTTP contract can serve Spark, Trino, Flink and PyIceberg at the same time.

So one small MCP server in front of the catalog gives an agent visibility into **every table in the lakehouse, no matter which engine wrote it**. That's a much better deal than wiring agents into each engine separately.

> We'll use PyIceberg's local SQL catalog (SQLite) so you can run everything on a laptop. Swapping in your production REST catalog is a four-line config change - and the REST catalog itself deserves its own deep dive, which is coming in next week's post.

## What We'll Use

| Component | Version (as of Oct 2026) |
|-----------|--------------------------|
| MCP Python SDK (`mcp`) | 2.3.0 |
| PyIceberg | 0.12.0 |
| MCP spec revision | 2026-07-28 |
| Language | Python 3.10+ |

```bash
pip install mcp pyiceberg pyarrow sqlalchemy
```

> **Watch out:** the MCP Python SDK shipped a v2 line this year. `FastMCP` was renamed to `MCPServer`, and `pip install mcp` now installs 2.x. Most blog posts from 2025 still show the v1 API and will fail with an import error. If you're maintaining older code, pin `mcp<2`; the [migration guide](https://py.sdk.modelcontextprotocol.io/v2/migration/) covers the rest. The code below is v2.

## Step 1: Seed a Demo Table

A tiny SQL catalog on SQLite, one namespace, one table, three rows:

```python
"""Create a demo namespace + table with a few rows (PyIceberg SQL catalog on SQLite)."""
from datetime import datetime, timezone

import pyarrow as pa
from pyiceberg.catalog import load_catalog

catalog = load_catalog(
    "lakehouse",
    **{
        "type": "sql",
        "uri": "sqlite:////tmp/lakehouse/catalog.db",
        "warehouse": "file:///tmp/lakehouse",
    }
)

catalog.create_namespace_if_not_exists("demo")

table = catalog.create_table_if_not_exists(
    "demo.order_events",
    schema=pa.schema([
        ("order_id", pa.string()),
        ("customer_id", pa.string()),
        ("amount", pa.float64()),
        ("currency", pa.string()),
        ("event_time", pa.timestamp("us", tz="UTC")),
    ]),
)

rows = pa.Table.from_pylist(
    [
        {"order_id": "o-1001", "customer_id": "c-42", "amount": 249.50, "currency": "USD", "event_time": datetime(2026, 10, 17, 10, 15, tzinfo=timezone.utc)},
        {"order_id": "o-1002", "customer_id": "c-07", "amount": 89.99, "currency": "EUR", "event_time": datetime(2026, 10, 17, 11, 2, tzinfo=timezone.utc)},
        {"order_id": "o-1003", "customer_id": "c-42", "amount": 1200.00, "currency": "USD", "event_time": datetime(2026, 10, 18, 9, 41, tzinfo=timezone.utc)},
    ],
    schema=table.schema().as_arrow(),
)
table.append(rows)
print("seeded:", ".".join(table.name()), "rows:", len(rows))
```

```bash
$ python seed.py
seeded: demo.order_events rows: 3
```

For production, swap the `load_catalog` config for your REST catalog - the tools below don't change:

```python
catalog = load_catalog(
    "lakehouse",
    **{
        "type": "rest",
        "uri": "https://rest.my-lakehouse.internal/iceberg",
        "credential": os.environ["ICEBERG_REST_TOKEN"],
        "warehouse": "lakehouse",
    }
)
```

## Step 2: The MCP Server

Four read-only tools over the catalog. The function docstrings matter - they become the tool descriptions the model reads when deciding what to call:

```python
"""MCP server that exposes an Apache Iceberg lakehouse to AI agents."""
import os
from mcp.server.mcpserver import MCPServer
from pyiceberg.catalog import load_catalog

# Local demo: SQL catalog on SQLite. Production: swap in your REST catalog:
#   catalog = load_catalog("lakehouse", **{
#       "type": "rest",
#       "uri": "https://rest.my-lakehouse.internal/iceberg",
#       "credential": os.environ["ICEBERG_REST_TOKEN"],
#       "warehouse": "lakehouse",
#   })
catalog = load_catalog(
    "lakehouse",
    **{
        "type": "sql",
        "uri": "sqlite:////tmp/lakehouse/catalog.db",
        "warehouse": "file:///tmp/lakehouse",
    }
)

mcp = MCPServer(
    name="iceberg-lakehouse",
    instructions="Read-only access to the Iceberg lakehouse: browse namespaces, "
                 "tables, schemas and preview rows.",
)


@mcp.tool()
def list_namespaces() -> list[str]:
    """List all namespaces (databases) in the Iceberg catalog."""
    return [".".join(ns) for ns in catalog.list_namespaces()]


@mcp.tool()
def list_tables(namespace: str) -> list[str]:
    """List all Iceberg tables in a namespace, e.g. namespace='demo'."""
    return [tbl[-1] for tbl in catalog.list_tables(namespace)]


@mcp.tool()
def describe_table(table: str) -> dict:
    """Schema, partitioning and current snapshot for a table ('namespace.table')."""
    tbl = catalog.load_table(table)
    current = tbl.current_snapshot()
    return {
        "name": ".".join(tbl.name()),
        "location": tbl.location(),
        "schema": [f"{f.field_id}: {f.name} ({f.field_type})"
                   for f in tbl.schema().fields],
        "partition_spec": str(tbl.spec()),
        "current_snapshot_id": current.snapshot_id if current else None,
        "snapshots": len(tbl.snapshots()),
    }


@mcp.tool()
def preview_table(table: str, limit: int = 5) -> list[dict]:
    """Return up to `limit` rows from a table ('namespace.table')."""
    limit = min(limit, 100)  # hard cap: never let an agent pull the whole table
    tbl = catalog.load_table(table)
    return tbl.scan(limit=limit).to_arrow().to_pylist()


if __name__ == "__main__":
    mcp.run(transport="stdio")
```

Three details worth pausing on:

- **Type hints and docstrings are the API contract.** The SDK generates each tool's JSON schema from the signature, and the docstring is what the model reads to pick a tool. Vague docstrings make a confused agent.
- **Return structured data, not prose.** `dict` and `list` returns become MCP structured content the client can render or the model can reason over directly.
- **`preview_table` has a hard cap.** Agents are optimistic. Without `min(limit, 100)`, a curious model can decide to pull ten million rows through your context window.

## Step 3: Prove It Works

Before any agent host touches it, run the server through a real MCP client over stdio - the same transport Claude Desktop uses:

```python
import asyncio, json
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

async def main():
    params = StdioServerParameters(
        command="python",
        args=["iceberg_mcp_server.py"],
    )
    async with stdio_client(params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            tools = await session.list_tools()
            print("TOOLS:", [t.name for t in tools.tools])
            r = await session.call_tool("preview_table",
                                        {"table": "demo.order_events", "limit": 2})
            for c in r.content:
                print(getattr(c, "text", str(c)))

asyncio.run(main())
```

Real output from my run:

```text
TOOLS: ['list_namespaces', 'list_tables', 'describe_table', 'preview_table']
{
  "order_id": "o-1001",
  "customer_id": "c-42",
  "amount": 249.5,
  "currency": "USD",
  "event_time": "2026-10-17T10:15:00Z"
}
{
  "order_id": "o-1002",
  "customer_id": "c-07",
  "amount": 89.99,
  "currency": "EUR",
  "event_time": "2026-10-17T11:02:00Z"
}
```

The server negotiated the protocol, advertised four tools, and streamed real Iceberg rows back. For interactive poking, the official [MCP Inspector](https://github.com/modelcontextprotocol/inspector) (`npx @modelcontextprotocol/inspector python iceberg_mcp_server.py`) gives you a web UI over the same stdio connection.

## Step 4: Wire It into an Agent Host

For Claude Desktop (and other MCP hosts that use the same config shape), register the server in `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "iceberg-lakehouse": {
      "command": "python",
      "args": ["/absolute/path/to/iceberg_mcp_server.py"],
      "env": { "ICEBERG_REST_TOKEN": "<token-if-you-use-rest>" }
    }
  }
}
```

Restart the host and ask: *"What tables are in the `demo` namespace, and show me two sample rows from each."* The agent will call `list_tables` and `preview_table` itself - no copy-pasting schemas. Claude Code users can register servers with `claude mcp add` instead; the [Claude Code MCP docs](https://code.claude.com/docs/en/mcp) walk through it.

## The Security Lines You Should Not Cross

The [spec's own trust section](https://modelcontextprotocol.io/specification/2026-07-28) is blunt: tools are arbitrary code execution, and hosts must get explicit user consent before invoking them. From the data-engineering side, three rules cover most of the risk:

1. **Read-only tools only.** Notice there is no `write_table` above. Start with browse/describe/preview. If you ever add mutations, gate them behind a separate, explicitly-named tool.
2. **Scope the credentials.** The REST catalog token should map to a read-only role at the catalog level - MCP is not your authorization layer, it just carries yours.
3. **Cap everything.** Row limits in `preview_table`, and sensible timeouts. Assume the model will eventually ask for the maximum.

There are also community Iceberg MCP servers worth a look if you'd rather start from one - for example [ryft-io/iceberg-mcp](https://github.com/ryft-io/iceberg-mcp) - but at ~60 lines, building your own is honestly the faster path to understanding what you're exposing.

---

## ✅ Conclusion

The pattern here is small but shifts how you work with a lakehouse: the catalog is already the source of truth for what data exists; MCP simply makes that truth *callable by an agent*. One read-only server, four tools, and your AI assistant stops guessing about schemas and starts reading them.

If you've followed this series - [Iceberg as the table format](https://saurzcode.in/big-data/apache-iceberg/data-engineering/apache-iceberg/), [streaming Kafka events into a table](https://saurzcode.in/big-data/apache-iceberg/apache-kafka/spark/data-engineering/streaming-kafka-to-iceberg-lakehouse/), and now agents over the catalog - the next piece is the layer that makes it all multi-engine: the **Iceberg REST Catalog**. Deep dive next week: one catalog, many engines, with Spark and Trino/Flink side by side.

---

## Related reading

- [Unlocking Data Lakes with Apache Iceberg: The Open Table Format Revolutionizing Analytics]({% post_url 2025-05-25-apache-iceberg %})
- [The Small-Files Problem: A Field Guide]({% post_url 2026-10-18-small-files-field-guide %})
- [HDFS vs Object Storage: Deep Dive for Big Data Processing in the Cloud]({% post_url 2025-05-18-hdfs-vs-object-storage %})

## 💬 Let's Discuss

Are you exposing your lakehouse to agents yet - through MCP, or something homegrown? And if you are, how are you handling read-vs-write boundaries and credentials? Share your setup or questions in the comments!
