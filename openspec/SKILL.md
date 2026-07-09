---
name: openspec
description: Use when the user says "/openspec", "启用 openspec", "spec-driven", "写规格", "提 proposal", "走规格驱动", or wants requirements/contracts persisted into repo-level specs as the single source of truth before implementation. Also use when deciding whether to adopt a full spec (proposal/specs/design/tasks) workflow vs a lighter setup, OR when the work touches the company Lina framework and needs routing to the right lina-* skill. Symptoms - requirements keep getting re-explained; conversations disagree on what was actually decided; AI drifts from the agreed contract; the user wants a change-request trail; the user asks which lina-* module to use for a given task.
---

# OpenSpec — Spec-Driven Contract Layer + Lina Framework Router

## Overview

This skill does **two things**, and they are orthogonal:

1. **Contract layer (Part A)** — Persist requirements and design decisions into specs that live in the repo, so every session works against the *single source of truth* instead of someone's latest recollection. Distilled from [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) (MIT).
2. **Framework router (Part B)** — When the work touches the company Lina framework, route to the right `lina-*` skill instead of re-deriving how to use it. One entry point, twelve destinations — like a switchboard.

> **The red line with Superpowers (memorize this):** OpenSpec owns *what to build and the contract* (proposals, specs, design, tasks). The methodology layer — [[brainstorming]], [[writing-plans]], [[test-driven-development]], [[systematic-debugging]], [[verification-before-completion]] — owns *how to build and the quality*. This skill reads specs; it does **not** redefine the requirement baseline. Light projects can skip OpenSpec entirely and run on methodology alone.

---

## Part A — Spec-Driven Workflow (the contract layer)

### The philosophy

- **Fluid, not rigid.** Specs evolve; they are not carved in stone. Propose a delta, review it, merge it.
- **Iterative, not waterfall.** You can go explore → propose → apply → archive more than once for the same feature as understanding grows.
- **Brownfield, not just greenfield.** An existing project already has specs (even implicit ones). The first job is to make them explicit, not to start over.

### The 4-phase loop

| Phase | Command (upstream) | What happens | Changes specs? |
|---|---|---|---|
| **1. Explore** | `/opsx:explore` | Read the codebase and existing specs. Map current behavior. Ask the questions a proposal will need answered. | No (read-only) |
| **2. Propose** | `/opsx:propose` | Produce the **four artifacts** (below): `proposal.md` + `specs/` (the delta) + optional `design.md` + `tasks.md`. User reviews before anything is built. | Proposes a delta — not yet applied |
| **3. Apply** | `/opsx:apply` | Implement against `tasks.md`. The spec delta is the acceptance baseline: done = the delta's "Specs" section matches reality. | Code moves toward the spec |
| **4. Archive** | `/opsx:archive` | Move the change into `openspec/changes/archive/`, **promote the spec deltas back into `openspec/specs/`** so the next session inherits them. | Yes — this is where specs get updated |

> You do **not** need the upstream CLI for the methodology. The phases are a discipline. If you install upstream (`npm install -g @fission-ai/openspec`), the `/opsx:*` commands automate the bookkeeping; without it, you follow the same four phases by hand.

### The four artifacts (what lives in the repo)

| Artifact | Holds | Why it matters |
|---|---|---|
| **`proposal.md`** | Why this change, what's in/out of scope, the decision and its alternatives | The "why" survives the author. A future session (or reviewer) reads this instead of guessing. |
| **`specs/`** (delta) | The *changes* to specifications — what WILL be true after this lands, written as spec deltas | The negotiable part. Reviewed and merged; never edited silently once applied. |
| **`design.md`** *(optional)* | Technical design — data models, sequence, trade-offs | Only for complex changes. Skip for trivial ones (don't pay ceremony tax). |
| **`tasks.md`** | The ordered, checkable implementation list | The execution contract. "Apply" works through this; "done" is when every task is checked and the spec delta holds. |

### The gate before "Apply"

Do not start `apply` until:
- The proposal has **testable** acceptance criteria (not "make it better").
- Repository-answerable questions were answered by **reading**, not by asking the user.
- The user has reviewed the artifacts or explicitly approved proceeding.

(Same instinct as [[grill-me]] — drive the soft spots into the open before building.)

### Directory layout in the repo (reference)

```
openspec/
├── specs/                 # the living source of truth (current, accumulated)
│   ├── ...
├── changes/               # in-flight and historical proposals
│   ├── <change-id>/       #   proposal.md + specs/ + design.md? + tasks.md
│   └── archive/           #   landed changes, post-merge
```

---

## Part B — Lina Framework Router (the "use what" layer)

### When this part fires

Any time the task touches the company Lina framework: scaffolding a new microservice, adding a middleware integration, data access, caching, messaging, permissions, scheduled tasks, monitoring, templating.

**You do not re-derive Lina usage here.** You route to the right `lina-*` skill and follow *its* conventions. This skill is the switchboard; the `lina-*` skills are the destinations. (Single source of truth — their content lives in the company skill library, not duplicated here.)

### Router table (12 skills)

**Foundation**
| Skill | Use for | Triggers |
|---|---|---|
| [[lina-framework-base]] | Parent POM, project scaffolding, BOM, entry point, multi-env config | new Lina project, parent POM, any `lina-*-starter` |

**Data access**
| Skill | Use for | Triggers |
|---|---|---|
| [[lina-mybatis]] | MyBatis ORM (MySQL/Oracle), Mapper/XML, PageHelper | Mapper, XML mapper, CRUD, pagination |
| [[lina-mybatis-plus]] | MyBatis-Plus, single/composite PK, code generator | `@MultiId`, composite PK, `LinaServiceImpl`, `LinaBaseMapper` |
| [[lina-datasource-dynamic]] | Dynamic multi-datasource switching | `@MultipleDataSource`, multi-db routing |

**Cache**
| Skill | Use for | Triggers |
|---|---|---|
| [[lina-redis]] | Redis cache + distributed lock, single/multi cluster | `RedisService`, distributed lock, multi-cluster |

**Messaging**
| Skill | Use for | Triggers |
|---|---|---|
| [[lina-rabbitmq]] | RabbitMQ producers/consumers, multi-connection | RabbitMQ send/consume, producer/consumer |
| [[lina-rocketmq]] | RocketMQ, transactional/delayed/ordered messages | RocketMQ, transaction message, delayed message |

**Templating**
| Skill | Use for | Triggers |
|---|---|---|
| [[lina-freemarker]] | FreeMarker template engine, document generation | FTL, template rendering |

**Auth & permissions**
| Skill | Use for | Triggers |
|---|---|---|
| [[lina-sso]] | CAS single sign-on, session sharing, SPA 302 handling | CAS, SSO login/logout, 302 redirect |
| [[lina-um]] | Unified user/role/menu/dept permissions (Dubbo + REST) | UM, user/role/menu, permission query |

**Ops**
| Skill | Use for | Triggers |
|---|---|---|
| [[lina-prometheus]] | Metrics exposure, actuator endpoint, Prometheus scraping | metrics, actuator, scraping |
| [[lina-xxl-job]] | Distributed scheduled tasks, JobHandler | JobHandler, cron, scheduled task |

### How to route

1. Read the requirement.
2. Identify which Lina module(s) it touches (use the table — match by trigger keywords).
3. Load the matching `[[lina-xxx]]` skill body and follow **its** conventions.
4. If multiple modules are involved (e.g. "add a cached, scheduled data-sync job" → `lina-mybatis-plus` + `lina-redis` + `lina-xxl-job`), load each in turn; don't merge their conventions into one ad-hoc blob.

> A task touching **none** of these is probably not a Lina-framework task — handle it with the methodology layer alone.

---

## When to use

- The user invokes it: `/openspec`, "启用 openspec", "走 spec-driven", "写规格", "提个 proposal".
- Requirements need to survive across sessions, or multiple people/agents must agree on the contract.
- The work touches the Lina framework and you need the right module's conventions.

## When NOT to use

- Light, single-dev, short-lived work with no cross-session memory needs — methodology layer + [[ponytail]] is enough. Don't pay the spec tax.
- Debugging a concrete bug — use [[systematic-debugging]]. (You may *read* specs to understand intended behavior, but don't run the propose loop mid-bug.)
- The task touches no Lina module — Part B has nothing to route to; Part A may still apply if you want a contract trail.

## Anti-patterns (Never)

- **Never** redefine the requirement baseline inside this skill — that is OpenSpec's whole job; this skill *runs* it, and the methodology skills *read* it.
- **Never** copy `lina-*` content into this skill — single source of truth. Route, don't duplicate. When a `lina-*` convention changes upstream, only the `lina-*` skill should need updating.
- **Never** confuse OpenSpec with [[trellis]] — OpenSpec owns the *requirement contract* (propose → archive a delta); Trellis owns *persistence + multi-agent orchestration* (spec/task/memory + worker coordination). They can coexist; they are not the same layer.
- **Never** start `apply` before the user reviews the proposal artifacts — the whole point is a reviewed contract.
- **Never** treat specs as immutable once a change lands — `archive` deliberately rewrites `openspec/specs/`. Fluid, not rigid.

## Collaborates with

- **Superpowers methodology layer** — orthogonal. OpenSpec = *what/contract*; [[brainstorming]]/[[writing-plans]]/[[test-driven-development]]/[[verification-before-completion]] = *how/quality*. Per the red line, one owns the baseline, the other owns execution — neither crosses over.
- **[[trellis]]** — sibling at the engineering-framework tier. Trellis is the persistence + orchestration frame; OpenSpec is the contract layer. For a heavy project you might use both: OpenSpec to negotiate the contract, Trellis to keep it + the tasks + memory coherent across agents.
- **[[grill-me]]** — the `propose` phase's interview instinct is the same: drive soft spots into the open before building.
- **`lina-*` skills** — Part B is a router to them; they are the destinations, this skill is the switchboard.
