# Claude Code consumer — `bc-quality-review`

A [Claude Code](https://claude.com/claude-code) skill that runs a BCQuality review on AL / Business
Central changes in any local repo. It reads the project's `git diff` and `app.json`, selects
applicable knowledge across the `microsoft`, `community`, and `custom` layers, and reports findings
with `file:line` locations and references to the knowledge files.

> **Note on placement.** BCQuality is *content*; consumers normally live outside it (AL-Go and other
> orchestrators). This folder is a deliberate exception in this fork: a personal/team consumer kept
> next to the knowledge it reads, so a new machine is just "clone + install". It lives under
> `consumers/` so it never touches the `microsoft`/`community`/`custom` content layers and is ignored
> by the content validator and the knowledge index.

## Install (new machine)

```
git clone https://github.com/Kielkenny/BCQuality.git
cd BCQuality
# Windows:
powershell -ExecutionPolicy Bypass -File .\consumers\claude-code\install.ps1
# macOS / Linux / Git-Bash:
bash ./consumers/claude-code/install.sh
```

This copies `SKILL.md` into `~/.claude/skills/bc-quality-review/` and sets `BCQUALITY_HOME` to **this
checkout**, so the clone you just made *is* the knowledge corpus. Restart the terminal / Claude so the
environment variable is picked up.

## Use

In any BC/AL repository, ask Claude: **"run a BCQuality review"**.

It is additive — it does not replace CodeCop/UICop (run your analyzer for those) or generic code
review. It adds the BC-specific domain knowledge those tools miss.

## Update

`git pull` in this checkout updates the knowledge (the skill also pulls at review time). To update the
skill file itself, re-run the installer.

## Files

- `SKILL.md` — the skill (the review instructions Claude follows).
- `install.ps1` / `install.sh` — installers that wire the skill to this checkout.
