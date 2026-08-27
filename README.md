# ArchitectureToolSurface — Demo

**A console for the moment an agent asks "may FeatureCheckout import Persistence?" and gets told no.**

This is the SwiftUI host for
[**architecture-tool-surface-kit**](https://github.com/rajatslakhina/architecture-tool-surface-kit),
a codebase-aware MCP tool surface for a large iOS monorepo — the second MCP server that sits beside
Xcode 27's `mcpbridge` and answers the questions Apple's tooling structurally cannot: which modules
may import which, where the legacy Objective-C boundary is, and which carve-outs have quietly
expired.

The library is consumed here as a **version-pinned remote Swift package dependency**, not a local
path. That is deliberate — see below.

---

## Why this matters

An architectural rule that lives in a Confluence page is advisory. The agent has never read it, and
the agent's next pull request quietly makes it false.

Moving the check to the moment a change is *proposed* is not a productivity optimisation — it
changes who owns the rule from "whoever happens to review" to "the system". But an enforcement layer
an agent talks to has a failure mode a linter does not: a linter that answers wrongly produces a red
build, while a tool that answers wrongly produces *confident text in a context window* that the
agent then acts on and writes a defensible-sounding PR description about.

This console is where you can watch that distinction behave.

---

## What you see on launch

The app opens on the headline panel, already answering, against an eleven-module fixture shaped like
a real monorepo (an app shell, three feature modules, a domain layer, shared infrastructure, and a
decade-old Objective-C module everything is supposed to reach only through a bridge).

**`may_import(FeatureCheckout → Persistence)` → DENIED**, with:

- the rule that fired, cited by id (`no-feature-to-persistence-impl`) with its rationale and source
  location — *"Checkout must not reach infrastructure directly; it talks to DomainOrders, which owns
  the transaction boundary."*
- a remedy tagged **agent may apply**: *"Reach Persistence through the existing legal path
  FeatureCheckout → DomainOrders → PersistenceAPI → Persistence. No manifest change is required."*
- the team to escalate to, and the evidence the answer rests on.

Four things worth driving from there:

| Do this | Watch |
|---|---|
| Set the pickers to `FeatureCheckout → FeatureSearch` | Every remedy flips to **requires policy change**, and a red **"No legal route exists — stop, do not work around it"** appears. That is the signal that ends an agent's turn instead of continuing it. |
| Set them to `FeatureAccount → LegacyProCore` | The denial reports a **lapsed exception** by name and date rather than a bare "forbidden" — somebody approved this edge once and the approval ran out. |
| Tap **Dirty a manifest**, then re-read the panels | `owners(for:)` stays answerable; the reverse query goes **INDETERMINATE** with the exact path to re-parse. Staleness is per-query, not per-index. |
| Tap **+30 days** | `FeatureSearch → LegacyProCore` stops being legal. Expiry is evaluated at point of use against an injected clock, which is why a button can move it. |

The **`invariants_violated(diff:)`** panel checks a three-edge proposed change before it is written,
and catches a cycle that neither added edge closes on its own — edges are applied incrementally, so
"each one is fine individually" is not a defence.

The **tool surface** panel shows the budgeting: two essentials plus two situational tools published,
two names qualified because they collide with the `mcpbridge` stand-in, and two capabilities
relocated into a rendered `SKILL.md` because their answers do not change between turns.

---

## The one interesting thing about this project file

`Demo.xcodeproj` references the library through an `XCRemoteSwiftPackageReference` pinned to
**`upToNextMajorVersion` from `1.0.0`** — not a local path, and not `branch = main`.

A local path would make this repo prove nothing: it would build against whatever is on the machine.
Branch-tracking is subtler and worse — every clone and every CI run would resolve whatever `main`
happens to be that day, which is the wrong default for something a reviewer is meant to be able to
reproduce. The pin means this app builds against exactly
[v1.0.0](https://github.com/rajatslakhina/architecture-tool-surface-kit/releases/tag/v1.0.0), today
and in a year.

`Package.resolved` is deliberately **not** git-ignored here. In an application repo it is the only
thing recording the exact commit a clone resolves.

---

## How to run it

```bash
git clone https://github.com/rajatslakhina/architecture-tool-surface-demo-app.git
cd architecture-tool-surface-demo-app
open Demo.xcodeproj
```

Then: wait for Xcode to resolve the remote package, select the shared **Demo** scheme, pick any iOS
Simulator, and Build & Run. There is nothing to configure — no API keys, no local checkout of the
library, no signing needed for the Simulator.

Requires Xcode 16 or later (Swift 6 language mode, iOS 17 deployment target).

---

## Verification — read this before you trust anything above

**Verified.** CI is green — see the
[Actions tab](https://github.com/rajatslakhina/architecture-tool-surface-demo-app/actions). The job
runs `xcodebuild -resolvePackageDependencies` and then `xcodebuild build` for
`generic/platform=iOS Simulator`. The first step is the load-bearing one: it proves the version-pinned
remote package genuinely resolves from GitHub, not from a local checkout and not from whatever `main`
happens to be. The library's own CI is green too — a cold Linux build and 107 tests with
`-Xswiftc -warnings-as-errors`, plus a macOS build for a generic Simulator destination.

**Not verified: this app has never been launched on a Simulator.** The macOS jobs are compile checks
against a *generic* Simulator destination. They prove the code builds for the platform; they do not
prove the UI rendered, or that the panels behave as described above. **There are no screenshots, and
there is no `Demo/Screenshots/` directory** — the walkthrough above is traced from the source, not
observed. This build ran unattended and Simulator control was refused three times with:

> Computer-use access to "Xcode 26.3", "Simulator" can't be approved during a scheduled run.

"Builds for a Simulator" and "ran on a Simulator" are two different claims and only the first one is
true here.

**Reviewed.** Both repos were graded by an independent reviewer with no memory of writing them,
against a strict checklist. Twenty findings came back, two of them blockers; all were fixed before
release, including six tests in the library that would have passed against a deliberately broken
implementation.

---

## Repos

- **Library:** [architecture-tool-surface-kit](https://github.com/rajatslakhina/architecture-tool-surface-kit) — the decision layer. Foundation-only core, builds and tests on Linux.
- **This app:** the SwiftUI host. Owns exactly one thing the library refuses to own — the context budget, because the number of tokens an agent may spend on tool schemas belongs to whoever is paying for the window.

## Licence

MIT.
