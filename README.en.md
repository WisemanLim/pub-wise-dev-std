# Wise Dev Standard — Claude Code Plugin (public distribution)

A Claude Code plugin that, from a `PRD.md` plus a few choices, **recommends a trend-aligned dev stack** (language, package manager, framework, database, run method) and **scaffolds the base project structure**. The standard can be exported to an IDE-neutral `AGENTS.md`, so **Cursor and Antigravity follow the same standard**.

- **한국어**: [README.md](README.md)
- **Public repo**: `pub-wise-dev-std` — marketplace name is `wise-dev-std`, plugin name is `wise-dev-std`.
- **Phase 1 scope**: Claude CLI plugin. Cursor/Antigravity reuse via `AGENTS.md` export.

> Install/update commands use the form **`wise-dev-std@wise-dev-std`** (`<plugin>@<marketplace>`).

---

## 1. What it solves

Standardizes and automates the decisions a developer repeats on every new project:

1. Environment setup + FE/BE/DB/Ops structure design
2. Package-manager choice per language — `uv`, `pip`, `pnpm`, `npm`, …
3. `local / dev / staging / prod` separation + DB choice (`sqlite` / `postgres`)
4. Run method — direct (`pnpm dev`, `uvicorn`) vs `docker compose up`
5. Given a `PRD.md`, pick only the **basic conditions** (node/python, frontend/backend) and it
   recommends the preferred language / package manager / run method and generates the base structure.
   - If writing a PRD is hard, `/wise-dev-std:prd` drafts `PRD.md` from a **5-question survey**
     (agile One-Page by default, `--full` for full spec).
6. Provide an **industry (KSIC section)** and it overlays that domain's regulation, data classes,
   preferred stack, infra and tests (e.g. finance=network-segregation/PCI, healthcare=FHIR/de-id,
   gaming=loot-box probability audit).

---

## 2. Components

| Type    | Name                             | Role                                                             |
| ------- | -------------------------------- | ---------------------------------------------------------------- |
| Command | `/wise-dev-std:prd`         | Survey (Why·Who·What·How·Success) → draft root `PRD.md` (`--full` full spec) |
| Command | `/wise-dev-std:recommend`   | PRD + choices → stack recommendation (table)                     |
| Command | `/wise-dev-std:scaffold`    | Chosen profile → dirs/Makefile/compose/manifest/CI/.env          |
| Command | `/wise-dev-std:env-init`    | Generate `local/dev/staging/prod` env files + compose override   |
| Command | `/wise-dev-std:standardize` | Export the standard to `AGENTS.md` + `.cursor/rules`             |
| Command | `/wise-dev-std:implement`   | After recommend~standardize: implement from PRD + test cycle (`test/impl/<Nth>`) + per-language/platform `.gitignore` |
| Command | `/wise-dev-std:review`      | **In-depth analysis + line-by-line code review, run together** → `.review/` (code review defaults to Level 2, confirm/auto-recommend) |
| Skill   | `prd-advisor`                    | PRD authoring knowledge base (5-question survey + One-Page/full-spec template + KSIC KPI·NFR suggestions) |
| Skill   | `stack-advisor`                  | Stack decision knowledge base (decision matrix + KSIC industry map) |
| Skill   | `project-scaffolder`             | Structure-generation rules (incl. `test/` scaffold + domain `COMPLIANCE.md`) |
| Skill   | `test-runner`                    | Testing standard: scenario→run→fix&retest→result (`test/` convention) |
| Skill   | `depth-reviewer`                 | In-depth analysis KB (stack·license·security·maintenance·architecture·legal·5-level rating) |
| Skill   | `code-reviewer`                  | Line-by-line, reader-level (0–4, default 2) code review KB (`.review/` tree) |
| Agent   | `stack-architect`                | Subagent running recommend→scaffold→env-init end to end          |
| Hook    | `SessionStart`                   | Hints usage if `PRD.md` exists, else suggests `/prd` helper (silent if already scaffolded) |
| Data    | `profiles/*.yaml`                | **Extension point (stack)** — one YAML = one selectable stack    |
| Data    | `domains/*.yaml`                 | **Extension point (industry)** — KSIC-section domain overlay (regulation/data-classes/stack-bias) |

### Layout

```
pub-wise-dev-std/
├── .claude-plugin/marketplace.json     # marketplace definition (name: wise-dev-std)
├── plugins/wise-dev-std/
│   ├── .claude-plugin/plugin.json
│   ├── commands/                        # prd, recommend, scaffold, env-init, standardize, implement, review
│   ├── skills/                          # prd-advisor, stack-advisor, project-scaffolder, test-runner, depth-reviewer, code-reviewer
│   ├── agents/                          # stack-architect
│   ├── profiles/                        # *.yaml (stack extension point) + _schema.md
│   ├── domains/                         # *.yaml (industry/KSIC extension point) + _schema.md
│   ├── hooks/hooks.json                 # SessionStart
│   ├── data/trends-cache.yaml           # version pins + regulation dates (--trends cache-first)
│   ├── scripts/                         # detect-prd, export-portable, install-portable, refresh-trends
│   └── templates/                       # AGENTS.md(IDE-neutral) + gitignore/ + scaffold/<id>/ (static)
└── README.md  /  README.en.md
```

---

## 3. Install

> Key: **marketplace name = `wise-dev-std`**, **plugin name = `wise-dev-std`**.
> Install with `wise-dev-std@wise-dev-std`.

### Option A — git clone + local marketplace (for editing/contributing)

Clone the repo first:

```
git clone https://github.com/WisemanLim/pub-wise-dev-std.git
cd pub-wise-dev-std
```

In the Claude CLI (from the cloned directory):

```
/plugin marketplace add .
/plugin install wise-dev-std@wise-dev-std
```

> Pass `marketplace add` the **directory** (clone root) that contains `.claude-plugin/marketplace.json`.
> Success = the commands show up in `/help` or `/plugin`.

### Option B — Git marketplace (team)

```
/plugin marketplace add WisemanLim/pub-wise-dev-std
/plugin install wise-dev-std@wise-dev-std
```

Enable/disable in the `/plugin` menu.

### Update

**Installed via Option A (git clone)** — pull the source, then refresh the marketplace:

```
cd pub-wise-dev-std
git pull
```

Then in the Claude CLI:

```
/plugin marketplace update wise-dev-std
/plugin update wise-dev-std@wise-dev-std
```

**Installed via Option B (remote marketplace)** — just refresh marketplace metadata:

```
/plugin marketplace update wise-dev-std
/plugin update wise-dev-std@wise-dev-std
```

- `marketplace update` refreshes the marketplace listing (version / plugin metadata; arg = marketplace name `wise-dev-std`).
- `plugin update` upgrades the installed plugin to the latest version.
- Verify: check the version (currently `0.8.0`) in the `/plugin` menu.
- If broken, reinstall: `/plugin uninstall wise-dev-std@wise-dev-std` then install again.

> Versioning: bump `version` in both `plugin.json` and `marketplace.json` together (SemVer).

---

## 4. Usage

### 4-1. Basic flow

```
# 1) prepare PRD.md — drop one in, or draft it from a survey if writing is hard
/wise-dev-std:prd "My Project" healthcare       # 5-question survey → root PRD.md
#   full spec (architecture·NFR·data·regulation):  /wise-dev-std:prd "My Project" --full

# 2) recommend a stack (+ industry hint for regulation/data-class overlay)
/wise-dev-std:recommend
#   language hint:        /wise-dev-std:recommend python --trends
#   language+industry:    /wise-dev-std:recommend python healthcare --trends

# 3) scaffold after confirming (industry → COMPLIANCE.md)
/wise-dev-std:scaffold python-fastapi --domain healthcare
#   interactive stack picker:  /wise-dev-std:scaffold custom

# 4) generate env files (local/dev/staging/prod)
/wise-dev-std:env-init python-fastapi

# 5) export the standard to Cursor/Antigravity
/wise-dev-std:standardize python-fastapi

# 6) implement from PRD + test (creates test/impl/<Nth> per iteration)
/wise-dev-std:implement python-fastapi "login API"

# 7) in-depth analysis + line-by-line code review (together) → .review/
/wise-dev-std:review                       # code review defaults to Level 2 (confirm/auto-recommend)
/wise-dev-std:review --level 3 --pdf true  # explicit level + PDF
/wise-dev-std:review --only code ./src     # code review only, specific path
```

---

### 4-2. Stage-by-stage guide (prd → review)

The 7 commands form **one pipeline**. Each stage takes the previous stage's output as input and hands off to the next.
Order: **prd → recommend → scaffold → env-init → standardize → implement → review.**

```
PRD.md  →  recommend  →  scaffold   →  env-init  →  standardize →  implement  →  review
 define     stack          skeleton     env files     IDE std       build+test    review
```

#### Stage 1 — `prd` · define requirements

- **Purpose**: Pin down what/why first (`PRD.md`). The single input for every later stage.
- **Command**: `/wise-dev-std:prd "[name]" [industry] [--full]`
- **Input**: project name, (optional) industry KSIC keyword, `--full` (full-spec expansion).
- **Behavior**: `prd-advisor` asks the **5 core questions (Why·Who·What·How·Success)** at once and drafts.
  Never overwrites an existing PRD (asks to augment first). Unknown values are marked `assumption:`.
- **Output**: root `PRD.md` (One-Page by default; `--full` adds architecture·NFR·data·regulation·Epic).
- **Next**: `recommend`.
- 💡 Skip this stage if you already have a PRD.

#### Stage 2 — `recommend` · stack recommendation

- **Purpose**: Decide **language·package-manager·framework·DB·run-method** from PRD + basic choices.
- **Command**: `/wise-dev-std:recommend [language/profile hint] [industry] [--trends]`
- **Input**: `PRD.md` (auto-detected), language/mobile hint, industry KSIC keyword, `--trends` (latest versions/regulation dates).
- **Behavior**: `stack-advisor` scores `profiles/*.yaml` × `domains/*.yaml` via a decision matrix →
  top profile + alternatives. With an industry, attaches a regulation/data-class overlay summary.
- **Output**: a recommendation **table** (choice/alternative/rationale) + domain overlay summary (printed, no files).
- **Next**: `scaffold` with the confirmed `<profile-id>`.
- 💡 `--trends` is cache-first (`data/trends-cache.yaml`); only STALE items are re-checked via WebSearch.

#### Stage 3 — `scaffold` · project skeleton

- **Purpose**: Generate the real directory/build/CI/doc skeleton from the confirmed profile.
- **Command**: `/wise-dev-std:scaffold <profile-id> [--domain <id>] [target-dir]`
  or interactive: `/wise-dev-std:scaffold custom` (platform→language→DB→env→industry→name, 6 steps).
- **Input**: profile id (or custom picks), (optional) industry domain, target location.
- **Behavior**: `project-scaffolder` copies the static template `templates/scaffold/<id>/` + substitutes `{{PROJECT_NAME}}`.
  `kind: service` → compose/Dockerfile/DB; `kind: mobile` → platform layout + flavors + Fastlane.
  Also assembles an idempotent `.gitignore` (language + platform) at this point.
- **Output**: directory tree, `Makefile`, `docker-compose.yml`, language manifest, `.env.*`,
  `.github/workflows/ci.yml`, `README.md`/`README.en.md` stubs, and `COMPLIANCE.md` if an industry is given.
- **Next**: `env-init`.
- 💡 Safety: **creates files only**. No install/network commands, no real secrets. Existing identical files kept as `*.generated`.

#### Stage 4 — `env-init` · environment files

- **Purpose**: Set up the 4 environments (`local/dev/staging/prod`) per standard; clean up files irrelevant per platform.
- **Command**: `/wise-dev-std:env-init <profile-id> [--db sqlite|postgres]`
- **Input**: profile id, (optional) forced DB.
- **Behavior**: branches on the profile `kind` —
  - `service`: `.env.{local,dev,staging,prod}` + `docker-compose.override.yml` + `.env.example`.
    (local=sqlite, dev+=postgres+redis. `.env.prod` lists **keys only**.)
  - `native-mobile` (iOS/Android): **xcconfig / BuildConfig** instead of `.env.*` (removes stray `.env.*`, reported).
  - `cross-mobile` (Flutter/RN): keeps `.env.*` + `env.dart` / `env.ts` source.
- **Output**: a full set of env files (all real passwords/tokens/signing keys are placeholders).
- **Next**: `standardize`.
- 💡 Mobile `api_base` host: iOS Simulator=`localhost`, Android Emulator=`10.0.2.2`.

#### Stage 5 — `standardize` · export an IDE-neutral standard

- **Purpose**: Export the Claude plugin standard into a format **Cursor·Antigravity also read**.
- **Command**: `/wise-dev-std:standardize [profile-id] [--domain <id>]`
- **Input**: (optional) profile to emphasize, (optional) industry overlay.
- **Behavior**: builds the standard doc from `templates/AGENTS.md` with the current stack/industry summary inserted.
- **Output**: `AGENTS.md` (shared), `.cursor/rules/wise-dev-std.mdc` (`alwaysApply: true`),
  `.antigravity/rules.md`. → all three tools follow the same standard.
- **Next**: `implement`.
- 💡 Shell installer: `scripts/install-portable.sh <target-dir>` (`--zip` to package for distribution).

#### Stage 6 — `implement` · build + test

- **Purpose**: Implement PRD features on the standardized env and apply the **same test cycle**.
- **Command**: `/wise-dev-std:implement [profile-id] [feature-keyword]`
- **Preconditions**: recommend → scaffold → env-init → standardize complete.
- **Behavior**:
  1. **dev-env test (once)** — verify the standard env is set up correctly → `test/dev-env/`.
  2. Ensure `.gitignore` (language + platform, idempotent).
  3. Extract the `feature-keyword` scope from PRD → implement on the standard structure (surgical changes).
  4. **Test cycle** — new iteration `test/impl/<Nth>/`: scenario→run→fix&retest→result.
     If `COMPLIANCE.md` exists, include the domain's compliance test cases.
  5. **Refresh READMEs** — analyze the implemented code and update detailed KO `README.md` + EN `README.en.md`.
- **Output**: feature code, `test/impl/<Nth>/{scenario,result}.md` + `logs/`, refreshed READMEs.
- **Next**: `review` (or repeat `implement` for the next feature).
- 💡 Iteration (`1st`,`2nd`,…) auto-increments; existing iteration dirs are never overwritten.

#### Stage 7 — `review` · in-depth analysis + code review

- **Purpose**: Produce **two reviews at once** on the implemented code.
- **Command**: `/wise-dev-std:review [target-paths...] [--level 0~4] [--only depth|code|both] [--pdf true|false]`
- **Input**: analysis paths (default cwd), (optional) code-review level/scope/PDF. Uses PRD·AGENTS·profile traces as basis.
- **Behavior**:
  1. **In-depth** (`depth-reviewer`, always detailed) — stack·license·security·maintenance·architecture·legal·rating.
  2. **Code review** (`code-reviewer`, default Level 2) — line by line. Without `--level`, auto-recommends then confirms once.
  - The two are independent → recommended to run **in parallel** via two subagents.
- **Output**: `.review/REVIEW-InDepth.md` + `.review/CODE-REVIEW-Lv<N>/` (INDEX + per-file reports), plus PDF if requested.
- **Next**: fix the risks found → re-run `implement` → `review` again (loop).
- 💡 Levels: 0=non-developer/PM share, 1=junior onboarding, 2=team baseline (default), 3~4=senior/architect.

> **Iteration loop**: typically you loop `implement` ↔ `review` per feature — `implement` for each new feature,
> `review` as a quality gate at each milestone. Stages 1–5 are usually a one-time setup at project start.

### 4-3. recommend output (shape)

| Item        | Choice                                          | Alternative      | Rationale / tweak                  |
| ----------- | ----------------------------------------------- | ---------------- | ---------------------------------- |
| Industry    | `healthcare` (KSIC Q)                           | —                | medical domain → regulation/FHIR overlay |
| Language    | Python                                          | Node             | PRD has analysis/ML → Python first |
| Package mgr | uv                                              | pip              | fast resolver + venv               |
| Backend     | FastAPI                                         | NestJS           | type hints, auto docs              |
| DB          | SQLite(local) / PostgreSQL(dev+)                | —                | Postgres for new services          |
| Run         | `uv run uvicorn --reload` / `docker compose up` | —                | direct + container                 |
| Profile     | `python-fastapi`                                | `node-next-nest` | —                                  |

### 4-4. Scaffold output

Profile `python-fastapi` example: `app/`, `tests/`, `docker/`, `Makefile`, `docker-compose.yml`, `pyproject.toml`, `.env.{local,dev,staging,prod}`, `.github/workflows/ci.yml`.

Common entry point:

```
make dev      # uv sync && uvicorn --reload  (or compose up)
make test     # pytest
make build    # docker build
make deploy   # helm/argocd
```

> Safety: the scaffolder only **creates files**. It runs no install/network commands and
> generates no real secrets (`.env.prod` lists keys only). Existing identical files are not
> overwritten — written as `*.generated` instead.

---

## 5. Profiles (extension point)

Provided:

| id                 | Description                                                             | status  |
| ------------------ | ----------------------------------------------------------------------- | ------- |
| `node-next-nest`   | Next.js + NestJS (unified TS, BFF)                                      | stable  |
| `python-fastapi`   | FastAPI + uv + uvicorn (data/ML/RAG)                                    | stable  |
| `go-gin`           | Gin + GORM (high-throughput core/workers)                               | stable  |
| `rust-axum`        | Axum/Actix + SQLx (memory-safe, high perf, Tauri)                       | stable  |
| `bio-rag-research` | Research-org RAG platform (role-split + security/audit/reproducibility) | preview |
| `ios-swiftui`      | iOS native (Swift + SwiftUI, Xcode)                                     | stable  |
| `android-compose`  | Android native (Kotlin + Jetpack Compose)                               | stable  |
| `flutter-app`      | Flutter (Dart, single codebase iOS+Android)                            | stable  |
| `react-native-app` | React Native (Expo, TS, iOS+Android)                                    | stable  |

> **Mobile profiles (`kind: mobile`)** differ structurally from server profiles. Instead of a server DB
> (postgres) / docker-compose / K8s, they map to **on-device storage** (SwiftData/Room/Drift/expo-sqlite)
> + a **paired API** (app-only by default; add a server profile separately or combine via `extends:` into a
> monorepo when an API is needed) + **build flavors** (local/dev/staging/prod → flavor·api_base·signing)
> + **Fastlane → TestFlight/Play** deployment (iOS builds need a macOS CI runner). See `profiles/_schema.md`
> §Mobile for the field semantics and `project-scaffolder` §2.5 for scaffolding rules.

### Add a new profile

1. Follow the schema in `plugins/wise-dev-std/profiles/_schema.md`.
2. Add one `profiles/<new-id>.yaml`. (Combine existing profiles via `extends:`.)
3. Done. Commands/skills scan the directory at runtime — **no code changes**.

---

## 5.5 Domain overlays (industry — KSIC based)

A second axis **orthogonal** to stacks (`profiles/`). Provide an industry (KSIC section) and the
recommendation overlays that domain's **regulation, data classes, preferred stack, infra and tests**,
and scaffolding emits a `COMPLIANCE.md`. Korean regulation is the primary basis, augmented by a
2025–2026 global stack-trend survey (see each YAML's `references`).

| domain id | KSIC | Sector | Key regulation (KR, primary) | Stack bias |
| --- | --- | --- | --- | --- |
| `finance` | K | Finance/Insurance | E-Fin Supervisory Reg(2025)·Credit Info Act·ISMS-P·MyData | Go/Rust core + Postgres ledger + Kafka |
| `healthcare` | Q | Health/Medical | PIPA sensitive·Medical Act·EMR cert·SaMD(IEC62304)·CSAP | FHIR R4 + Python ML + de-id |
| `commerce` | G | Retail/E-commerce | E-Commerce Act·E-Fin Act(settlement)·PCI-DSS | headless + idempotent payments + search |
| `logistics` | H | Transport/Mobility | Location Info Act(6-mo purge)·Freight Act | PostGIS + TimescaleDB + Kafka |
| `manufacturing` | C | Mfg/Smart factory | Smart-factory std·Serious Accident Act·IEC62443 | OPC-UA/MQTT + TSDB + edge Rust/Go |
| `govtech` | O | Public admin | e-Gov Act·eGovFrame·N2SF/CSAP·KWCAG2.2 | eGovFrame(Spring) + accessibility |
| `edtech` | P | Education | PIPA·under-14 guardian consent·COPPA | WebRTC/HLS + burst scaling |
| `media-gaming` | R | Media/Gaming | Game Industry Act loot-box·rating(GRAC/IARC) | UDP/QUIC dedicated servers + anti-cheat |
| `ict-saas` | J | ICT/SaaS | ICT Network Act·PIPA·ISMS-P·CSAP | **baseline**: multi-tenancy + OTel |
| `agriculture` | A | Agri/AgriFood tech | Food/livestock traceability·Food Sanitation·HACCP·Location Info Act | edge/MQTT + TimescaleDB + PostGIS |
| `construction` | F | Construction/BIM | Serious Accidents Punishment Act·OSH Act·BIM(ISO 19650) | BIM/IFC + PostGIS + safety telemetry |
| `hospitality` | I | Hospitality/O2O | E-commerce Act·Food Sanitation·Tourism Act·PCI-DSS | booking concurrency (no overbooking) + idempotent payment |
| `energy-utilities` | D·E | Energy/utilities/water/env | Critical Infra Protection Act·Electricity Act·IEC 62443 | OT/IT segmentation + AMI time-series + anomaly detection |

> `ict-saas` (J) is always the baseline — any industry's software activity is dual-classified under J,
> so domain overlays layer regulation/stack **deltas** on top. Real estate (L) maps to `finance`
> (settlement) or `ict-saas`+PostGIS; R&D (M) maps to `bio-rag-research` or `ict-saas` (stack-advisor §1.5).

### Add a new industry (domain)

1. Follow the overlay schema in `plugins/wise-dev-std/domains/_schema.md`.
2. Add one `domains/<new-id>.yaml` (KSIC section + regulation + preferred profiles + data classes).
3. Done — recommend/scaffold scan at runtime, **no code changes**.

> Domains **bias** stacks, they don't replace them. If a stack is tightly coupled to an industry
> (role-split RAG, etc.), still write it as `profiles/*.yaml` + `extends:` (e.g. `bio-rag-research`).

---

## 6. Cursor · Antigravity reuse

Cursor and Antigravity read a root `AGENTS.md` as context. Cursor also reads `.cursor/rules/*.mdc`.

```
/wise-dev-std:standardize          # export from within Claude
# or directly in a shell:
bash plugins/wise-dev-std/scripts/export-portable.sh /path/to/your/project
```

Output:

- `AGENTS.md` — shared standard for Claude Code / Cursor / Antigravity
- `.cursor/rules/wise-dev-std.mdc` — `alwaysApply: true`

All three tools then follow the same language/package-manager/environment/run standard.

---

## 7. Testing standard (test/)

Testing is part of the standard. The same test cycle applies right after standard env setup and on every implementation iteration; results are stored under `test/` at the project root. (`test-runner` skill)

### Test cycle

1. **Write scenario** — decompose the PRD's requirements/acceptance criteria into a case table → `scenario.md`
2. **Run** — `make test` or a direct runner; raw output goes to `logs/`
3. **Fix & retest on failure** — root cause → fix code → rerun, recording each round (loop)
4. **Write result** — per-case pass/fail, bugs found, fixes, retest rounds, final verdict → `result.md`

### Directory convention

```
test/
├── README.md                 # testing standard overview
├── dev-env/                  # standard env verification (once) — after scaffold + env-init
│   ├── scenario.md           #   deps install, make up, DB connectivity, health, make test
│   ├── result.md
│   └── logs/
└── impl/                     # per implementation iteration (implement command)
    ├── 1st/                  #   iteration auto-increments from existing dirs
    │   ├── scenario.md
    │   ├── result.md
    │   └── logs/
    ├── 2nd/
    └── ...                   # 3rd, 4th, …
```

- `test/dev-env/` verifies once that the **standard env** (language, package manager, DB, run method, compose) is set up correctly.
- `test/impl/<Nth>/` creates a new iteration dir **per implementation**, preserving that round's scenario/result (never overwritten).
- Runner: per-profile `testing.framework` (Vitest+Playwright / pytest / go test / cargo test / Ragas).
- Raw logs (`test/**/logs/`) are recommended to be git-ignored.

> Safety: tests may edit code (step 3), but destructive ops (DB drop, prod deploy), real data, and real secrets are forbidden.

---

## 8. Standard summary

- **Priority languages**: Node/TS · Python · Rust · Go · C/C++
- **Package managers**: Python=`uv` (alt pip), Node=`pnpm` (alt npm), Go=modules, Rust=cargo. `forever` banned
- **DB**: PostgreSQL + Redis for new services; SQLite only for local/test. Vector=PGVector/Chroma, Graph=Neo4j
- **Environments**: local(sqlite) / dev·staging·prod(postgres); compose from dev up
- **Run**: direct + `docker compose up`; production K8s + Helm + GitOps
- **Ops**: GitHub Actions (or GitLab CI), Docker/Compose, K8s/Helm, Argo CD/Flux, SonarQube/Sentry
- **Mobile (App)**: native iOS (Swift/SwiftUI) · Android (Kotlin/Compose); cross-platform Flutter (Dart) · React Native (Expo/TS).
  On-device storage (SwiftData/Room/Drift/expo-sqlite), build flavors (local/dev/staging/prod), Fastlane→TestFlight/Play, iOS build=macOS CI

---

## 9. Validation

```
python3 -c "import json; json.load(open('.claude-plugin/marketplace.json'))"   # marketplace JSON
bash -n plugins/wise-dev-std/scripts/*.sh                                  # script syntax
bash plugins/wise-dev-std/scripts/refresh-trends.sh                        # trends-cache freshness (FRESH/STALE)
# profile + domain + cache YAML syntax (if PyYAML present):
python3 -c "import glob,yaml; P='plugins/wise-dev-std'; fs=glob.glob(P+'/profiles/*.yaml')+glob.glob(P+'/domains/*.yaml')+[P+'/data/trends-cache.yaml']; [yaml.safe_load(open(f)) for f in fs]; print('YAML OK', len(fs))"
```

License: internal use.
