---
name: bc-quality-review
description: Review Business Central / AL code changes against the BCQuality knowledge base (performance, security, privacy, style, ui, error-handling, upgrade). Use when asked to review AL/BC changes, do a "BCQuality review", or check BC code quality before committing or opening a PR in any BC/AL project. Complements CodeCop/UICop and generic code review — it adds BC-specific, remedial domain knowledge that analyzers and a general reviewer miss.
---

# BCQuality review (local consumer)

This skill turns the [BCQuality](https://github.com/Kielkenny/BCQuality) knowledge base into an
interactive AL review you can run in **any** BC project on this machine. BCQuality is *content*
(atomic knowledge files + skills); this file is the lightweight local *consumer* that reads that
content and evaluates the current change set against it.

It is a simplified, interactive variant of BCQuality's `entry → action-skill` flow: instead of an
autonomous orchestrator and a full `knowledge-index.json`, you discover knowledge by path and
frontmatter and apply it to the working diff. Use the full AL-Go/CI path only when a project gains a
GitHub Actions pipeline.

## When to use

- The user asks to review AL/BC changes, "run a BCQuality review", or check BC quality before commit/PR.
- After implementing an AL feature/fix, as the domain-knowledge pass alongside the mechanical checks.

This is **additive** and does not replace:
- **CodeCop/UICop** — run the project's analyzer (e.g. `bash .claude/verify-al.sh`) for mechanical rules.
- **`/code-review`** — generic correctness/bug hunting. BCQuality adds BC-specific domain knowledge.

## Prerequisites — the knowledge corpus

The knowledge lives in a local checkout of the BCQuality fork. Resolve its path in this order:
1. `$BCQUALITY_HOME` if set.
2. Default `E:\dev\BCQuality`.

At the start of a review, refresh it (non-fatal if offline):
`git -C <corpus> pull --ff-only`

If the corpus folder does not exist, tell the user and offer to clone it:
`git clone https://github.com/Kielkenny/BCQuality.git <corpus>`

Enabled layers by default: `microsoft`, `community`, `custom` (all three). Layer precedence for
conflicts: **custom > community > microsoft**.

## The flow

### 1. Establish task context
- **bc-version**: read the project's `app.json` — take the major version of the `application`
  dependency (fallback: `platform`). If neither is determinable, treat bc-version as `unknown`.
- **technologies**: `[al]` (add `javascript` if control add-in JS/CSS/HTML changed).
- **countries**: from `app.json` if declared; otherwise `unknown`.
- **application-area**: the actual areas declared by the changed objects; do NOT substitute `[all]`.

### 2. Determine the change set
- Default to the working diff: `git -C <project> diff` plus staged (`--staged`) and untracked AL files.
- If the user points at specific files or an IDE selection, scope to those instead.
- List the changed AL objects and their types (table, page, codeunit, enum, report, …) and extract
  tokens from the diff (e.g. `SetLoadFields`, `FindSet`, `Commit`, `Modify`, `Label`, `temporary`,
  `IsolatedStorage`, `PageType`, `UsageCategory`, `Error(`, `HttpClient`, `Insert(`, `CalcFields`).

### 3. Discover candidate knowledge
- Across enabled layers, search `*/knowledge/**/*.md` in the corpus. Read each candidate's YAML
  frontmatter (`bc-version`, `domain`, `keywords`, `technologies`, `countries`, `application-area`).
- Prefer domains relevant to the change: `performance`, `security`, `privacy`, `style`, `ui`,
  `error-handling`, `upgrade`. (Use Grep over the corpus to gather files quickly.)

### 4. Filter (Relevance) — per BCQuality READ semantics
- **bc-version** matches if the file is `[all]`, or the target version is in its set/range
  (`[26..28]` expands; `[26..]` means ≥26). If target is `unknown` and the file is not `[all]`, the
  dimension is `unknown` (conditionally applicable, not a hard match).
- **technologies**: non-empty intersection with the task's technologies.
- **countries**: file contains `w1`, or intersects the task's countries.
- **application-area**: file contains `all`, or intersects the changed objects' areas.
- Resolve conflicts by layer precedence; note any suppressed (overridden) files.

### 5. Worklist
Keep a file when its `keywords` intersect the diff tokens, or its topic (path/title/description)
matches a changed object or declaration. Open the **full** body (its `## Best Practice` /
`## Anti Pattern`) only for worklisted files. Skip the rest.

### 6. Evaluate and report
For each worklisted file, judge the diff against its Best Practice / Anti Pattern. Emit findings as a
concise list grouped by severity (`blocker` > `major` > `minor` > `info`):

- **message** — what's wrong and the fix, in one or two sentences.
- **location** — `file:line` (clickable markdown link), derived from the diff.
- **reference** — the knowledge file's repo-relative path and its layer, e.g.
  `microsoft/knowledge/performance/findset-true-applies-updlock-on-read.md` (microsoft).
- **confidence** — `high` for unambiguous pattern matches; `medium` for heuristics or when any
  dimension was `unknown`; `low` for applicability-only advisories. Findings from conditionally
  applicable files are capped at `medium` and must name the unknown dimension.

If no applicable knowledge matched the changes, say so plainly (clean pass) rather than inventing
findings. Surface a self-review concern with no backing knowledge file only as a clearly-labelled
"agent finding (no BCQuality coverage)" with confidence ≤ medium.

## Notes
- Keep the review proportional to the diff: a small change gets a focused pass, a large one a broader sweep.
- When you spot a recurring real gap with no knowledge file, suggest adding one to `custom/knowledge/`
  in the fork (one rule per file, with `.good.al`/`.bad.al` siblings; validate via
  `python .github/scripts/validate_frontmatter.py`).
- This skill reads the corpus and the project diff only; it never pushes to the fork.
