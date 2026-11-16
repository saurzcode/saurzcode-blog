---
layout: post
title: "Airflow 3.4: Task Loops, TypeScript DAGs, and the Package Name That Changed"
date: 2026-11-16
categories: [Data-Engineering, Apache-Airflow]
tags: [Apache Airflow, Airflow 3.4, TypeScript, Task Loops, YAML, orchestration, AI agents]
description: "Hands-on Airflow 3.4: run bounded Task Loops and YAML DAGs, build a TypeScript DAG with the stable SDK, and avoid the retired npm package."
---

## A DAG Can Repeat Work Without Becoming a Cycle

What happens when a pipeline does not know how many passes it needs? An estimate needs another refinement. A hierarchy has another level. A generated answer fails a quality check and needs another attempt.

Putting the whole operation inside one Python task hides those passes from the orchestrator. Prebuilding ten copies of a task group makes the graph harder to read. Airflow 3.4 introduces a different option: a task group that repeats at runtime, with a hard limit and a visible result for each iteration.

That is one half of this release worth testing. The other is language choice. Apache released the [TypeScript SDK 1.0.0 on November 13](https://github.com/apache/airflow/releases/tag/ts-sdk/1.0.0), following the [Airflow 3.4.0 announcement on November 6](https://airflow.apache.org/blog/airflow-3.4.0/). There is an easy installation trap: stable releases moved to a new npm package name.

For this article, the Python loop and YAML examples were tested on Airflow 3.4.0 with Python 3.12. The TypeScript example was type-checked and bundled with SDK 1.0.0. Those are different levels of validation: the TypeScript DAG was not executed through a running scheduler and workers.

<!--more-->

## Start With an Isolated Airflow 3.4 Environment

An initial installation attempt with Python 3.10 was rejected by the package's Python requirement. The examples were tested with Python 3.12 and the official constraints file:

```bash
python3.12 -m venv .venv
source .venv/bin/activate

pip install "apache-airflow==3.4.0" \
  --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-3.4.0/constraints-3.12.txt"

export AIRFLOW_HOME="$PWD/airflow-home"
export AIRFLOW__CORE__LOAD_EXAMPLES=false
mkdir -p "$AIRFLOW_HOME/dags"
airflow db migrate
airflow version
# 3.4.0
```

This creates a disposable local environment, not an upgrade recipe for an existing deployment. Before touching a deployed instance, read the [3.4.0 significant changes](https://airflow.apache.org/docs/apache-airflow/3.4.0/release_notes.html) and test with the providers, executor, authentication manager and XCom backend you actually use.

## Task Loops: A Stop Condition and a Hard Ceiling

Airflow calls this feature [Task Loops](https://airflow.apache.org/docs/apache-airflow/3.4.0/authoring-and-scheduling/loops.html). Define the body as a decorated task group, then call `.loop()` on that group.

The static dependency graph remains acyclic. Airflow materializes successive iterations at runtime instead of adding a dependency edge back to an earlier task.

Here is the documentation's square-root refinement example, tested locally for this article. Save it as `$AIRFLOW_HOME/dags/refine_estimate.py`:

```python
from airflow.sdk import dag, task, task_group


@dag(tags=["example"])
def refine_estimate():
    @task_group
    def refine():
        @task
        def improve(*, loop):
            estimate = (
                1.0 if loop.index == 1
                else loop.previous["estimate"]
            )
            return (estimate + 2.0 / estimate) / 2.0

        @task
        def evaluate(estimate):
            return {
                "estimate": estimate,
                "error": abs(estimate * estimate - 2.0),
            }

        evaluate(improve())

    def accurate_enough(*, loop):
        return loop.result["error"] < 0.000001

    @task
    def finished():
        print("Refinement finished.")

    refinement = refine.loop(
        max_iterations=10,
        until=accurate_enough,
    )
    refinement >> finished()


refine_estimate()
```

Run it with:

```bash
airflow dags test refine_estimate
```

The test returned these estimates:

| Iteration | Estimate | Error: `abs(estimate² - 2)` | Decision |
| --- | --- | --- | --- |
| 1 | 1.5 | 0.25 | Continue |
| 2 | 1.4166666666666665 | 0.006944444444444198 | Continue |
| 3 | 1.4142156862745097 | 0.000006007304882427178 | Continue |
| 4 | 1.4142135623746899 | 0.000000000004510614104447086 | Stop |

The logs ended with `Loop iteration 4: stop (max_iterations=10)`, `Refinement finished.`, and a successful DagRun.

The data flow matters more than the arithmetic:

- `loop.index` starts at **1**. Handle the first iteration explicitly.
- The terminal task's return value becomes `loop.result` for the stop predicate.
- That result becomes `loop.previous` for the next iteration.
- `until=True` means **stop**, not continue.

This is a `do ... while` shape: the body runs before the condition is checked, so it executes at least once. Airflow creates the next iteration only when needed. The ten-iteration ceiling produced four executed iterations, not four successes followed by six skipped copies.

### The Ceiling Is a Failure Boundary

A second test used a different DAG ID with `max_iterations=2`. It did not converge, and the DagRun ended in `state=failed`. The downstream `finished` task did not run.

That is the distinction I want from a production control: "we tried enough times" is not the same as "the work passed its check."

A fixed-count loop is different. Omit `until` and reaching `max_iterations` is normal successful completion. With a condition, reaching the ceiling while the condition is false fails the final gate.

For a data-quality repair workflow, I would keep retries and iterations separate. A network error may deserve a retry of the same operation. A new repair proposal is a new iteration. Neither mechanism removes the need for idempotent writes, a small result payload and explicit limits on expensive work.

### Constraints to Check Before Adopting It

The [loop guide](https://airflow.apache.org/docs/apache-airflow/3.4.0/authoring-and-scheduling/loops.html) documents several boundaries:

- The body needs one terminal task definition before the gate. Combine multiple final outputs into one result if necessary.
- Nested loops are not supported. A loop cannot sit inside a mapped task group, and the whole loop cannot itself be mapped. Mapped tasks inside a loop are supported.
- The XCom backend must support loops. The default does; an older custom backend needs checking.
- Reading a loop task's output outside the loop means dealing with results across iterations, not assuming there is one scalar return value.

Keep large intermediate datasets in their data store. Pass the estimate, validation summary or artifact reference between iterations, rather than turning XCom into a warehouse.

## TypeScript SDK 1.0.0: Use the Scoped Package

Testing exposed a practical trap. The older release blog shows imports from `apache-airflow-ts-sdk`, but the [November 13 release announcement](https://www.mail-archive.com/dev@airflow.apache.org/msg24352.html) says the unscoped package will receive no further releases.

The stable package is:

```bash
npm install --save-exact @apache-airflow/ts-sdk@1.0.0
npm install --save-dev typescript @types/node esbuild
```

Use the new name in imports too. This small DAG was built with Node.js 22:

```typescript
import { Bundle, Dag } from "@apache-airflow/ts-sdk";

const dag = new Dag("orders_daily", {
  schedule: "@daily",
  tags: ["orders"],
  queue: "typescript",
});

const extract = dag.taskGroup("extract");
const eu = extract.task("eu", async (): Promise<number> => 120)();
const us = extract.task("us", async (): Promise<number> => 80)();

const summarize = dag.task(
  "summarize",
  async ({ eu, us }: { eu: number; us: number }) => eu + us,
);
const total = summarize({ eu, us });

const load = dag.task(
  "load",
  async ({ total, table }: { total: number; table: string }) => {
    console.log(`Loading ${total} orders into ${table}`);
  },
);
const loaded = load({ total, table: "warehouse.orders" });
const alerted = dag.task(
  "alert",
  async () => console.log("No orders today"),
)();

const hasOrders = async ({ total }: { total: number }) => total > 0;
dag.if(hasOrders, { total }, { taskId: "has_orders" })
  .then(loaded)
  .else(alerted);

await new Bundle(dag).serve();
```

The sample counts are constants, and `load` only logs. This demonstrates task wiring, not an actual warehouse write. Passing `eu` and `us` to `summarize` describes dependencies and task-result inputs.

In a fresh npm project, set `"type": "module"` in `package.json` and use this `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "noEmit": true,
    "skipLibCheck": true
  },
  "include": ["src/**/*.ts"]
}
```

Save the code as `src/orders_daily.ts`, then:

```bash
npx tsc
npx airflow-ts-pack src/orders_daily.ts --outdir dist
```

Both commands passed during validation. The packer wrote `dist/bundle.min.mjs` with metadata, source and integrity information embedded.

Do not skip `tsc`: the [SDK guide](https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/language-sdks/typescript.html) explicitly says the packer builds without type checking. A successful bundle alone is not proof that your input types are right.

### A Build Is Not a Deployment Test

The documented deployment puts the bundle into an Airflow DAG bundle and routes the DAG's queue to a Node coordinator:

```ini
[sdk]
coordinators = {"ts": {"classpath": "airflow.sdk.coordinators.node.NodeCoordinator"}}
queue_to_coordinator = {"typescript": "ts"}
```

Node.js 22 or later and the coordinator configuration are needed where the DAG processor reads the artifact and where workers execute tasks. There is no reason to expect copying a TypeScript source file into `dags/` to be enough.

An attempt to use `airflow dags test orders_daily` against the native bundle stopped with `A native Lang-SDK Dag is parsed only by the Dag processor`. A scheduler-and-worker execution test was not completed, so the validation here stops at type checking and packaging. Treat the configuration above as documented deployment guidance, not an end-to-end verified deployment.

There is also a maturity distinction worth preserving. The SDK has a stable **1.0.0 release**, while the Airflow 3.4.0 release notes still call the Dag Importer framework and language SDK integration **experimental**. Some guide text also still says beta. Pin the versions you test; do not turn the SDK's version number into a blanket guarantee for the whole integration.

## YAML DAGs: Explicit Templating, Not Magic Strings

If your pipeline mostly connects existing operators, the [experimental YAML importer](https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/yaml-dags.html) is another route. Enable it on the components that load DAGs, including the environment running the CLI:

```bash
export AIRFLOW__DAG_PROCESSOR__DAG_IMPORTER_CONFIGS='[{"classpath":"airflow.sdk.importers.yaml_importer.YamlDagImporter"}]'
```

Save this as `$AIRFLOW_HOME/dags/daily_sales.yaml`:

{% raw %}
```yaml
$schema: https://airflow.apache.org/schemas/dag/2026-10-30.json
dag_id: daily_sales
schedule: "@daily"
tasks:
  - id: extract
    uses: airflow.providers.standard.operators.bash.BashOperator
    with:
      bash_command:
        $t: "echo extracting orders for {{ ds }}"
  - id: load
    uses: airflow.providers.standard.operators.bash.BashOperator
    with:
      bash_command: "echo loading into warehouse"
    needs: [extract]
```
{% endraw %}

Then run:

```bash
airflow dags test daily_sales
```

The November 16 test printed:

```text
extracting orders for 2026-11-16
loading into warehouse
```

The DagRun finished successfully. Again, these are deliberately harmless commands, not an ETL implementation.

The `$t` object is important. YAML values are literal by default, even for an operator's normally templated field. To render Jinja, wrap the **field value** in the marker object. Putting marker-looking text inside an ordinary string does not make it a template.

Similarly, operator-specific arguments belong under `with:`, while base task options such as `retries` belong beside it. The `$schema` URL is part of discovery and validation, not decorative metadata. These rules make a YAML DAG different from a Python DAG written with less punctuation.

## Where This Fits in a Data Platform

In the [Kafka-to-Iceberg pipeline](https://saurzcode.in/big-data/apache-iceberg/apache-kafka/spark/data-engineering/streaming-kafka-to-iceberg-lakehouse/), Spark owns the streaming computation. Airflow is a place to coordinate bounded maintenance, validation and downstream batch work around that pipeline, not a replacement for the stream processor.

The same boundary helps with agents. My [MCP-over-Iceberg example](https://saurzcode.in/data-engineering/ai/mcp-for-data-engineers-iceberg-lakehouse/) gives an agent access to catalog tools. It does not define when an iterative workflow should stop, how much work it may do or which writes need review. A loop can make the stopping rule visible, but its existence does not make model output correct or authorize a side effect.

My adoption order would be simple: test a deterministic Python loop first, try YAML for a small operator-only DAG, then evaluate a non-Python SDK with a real deployment test. Different authoring languages should not mean different standards for observability, access control or safe retries.

Which would remove more friction in your pipelines: visible bounded iteration, or the ability to author the DAG in the language your team already uses?

## References

- [Airflow 3.4.0 release announcement, November 6](https://airflow.apache.org/blog/airflow-3.4.0/)
- [Airflow 3.4.0 release notes](https://airflow.apache.org/docs/apache-airflow/3.4.0/release_notes.html)
- [Task Loops authoring guide](https://airflow.apache.org/docs/apache-airflow/3.4.0/authoring-and-scheduling/loops.html)
- [TypeScript SDK 1.0.0 release, November 13](https://github.com/apache/airflow/releases/tag/ts-sdk/1.0.0)
- [TypeScript SDK mailing-list announcement and npm rename](https://www.mail-archive.com/dev@airflow.apache.org/msg24352.html)
- [TypeScript SDK guide](https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/language-sdks/typescript.html)
- [Writing DAGs in YAML](https://airflow.apache.org/docs/apache-airflow/stable/authoring-and-scheduling/yaml-dags.html)
- [Dag Importers administration guide](https://airflow.apache.org/docs/apache-airflow/3.4.0/administration-and-deployment/dag-importers.html)
