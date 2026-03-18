# Benchmark Methodology

Use this methodology to measure the effect of configuration changes before submitting a PR that modifies `settings.json.template` or `CLAUDE.md`.

---

## Goal

Produce reproducible, comparable measurements of context window efficiency. The claim "this change saves N tokens" or "this reduces compaction frequency" must be backed by data from this methodology.

---

## Setup

### Reference Task
Pick a task that is:
- Reproducible: same starting state each run
- Representative: involves typical tool use (Grep, Read, Edit, Bash)
- Bounded: 3-10 steps, completes in one session
- Non-trivial: at least 20K tokens of context usage

Good example: "Add a new field to the User model, update the tests, and write a migration."

### Reference Repo
Use the same git repo and commit SHA for all runs. Small, public repos work best (e.g., a TODO app, a simple CLI tool).

---

## Procedure

### Baseline (3 runs)
1. Start from a clean state: no `~/.claude/dotfiles/`, default `settings.json`
2. Run the reference task
3. Record after completion:
   - Peak context % (from statusline or session log)
   - Compaction count (how many times `/compact` or auto-compact fired)
   - Total input tokens (from final statusline reading)
   - Total cost (if visible in the session)
4. Repeat 3 times. Record all three values.

### Variant (3 runs)
1. Install the change being tested
2. Run the identical reference task from the same repo/commit
3. Record the same metrics
4. Repeat 3 times.

---

## Metrics

| Metric | How to measure | Why it matters |
|--------|---------------|----------------|
| Peak context % | Highest `◉ N%` seen in statusline | Primary efficiency signal |
| Compaction count | Count `/compact` events in session | Fewer = smoother workflow |
| Total input tokens | Final `N↓` in statusline | Direct cost proxy |
| Task completion quality | Did Claude finish correctly? | Correctness must not regress |

---

## Reporting Format

Include this table in your PR description:

```
## Benchmark Results

Reference task: [describe briefly]
Repo: [name + commit SHA]

| Run | Baseline peak% | Variant peak% | Baseline tokens | Variant tokens |
|-----|---------------|---------------|-----------------|----------------|
| 1   | 78%           | 62%           | 48K             | 39K            |
| 2   | 81%           | 65%           | 51K             | 41K            |
| 3   | 76%           | 60%           | 46K             | 38K            |
| avg | 78%           | 62%           | 48K             | 39K            |

Change: -16pp peak context, -9K tokens avg (~19% reduction)
Quality regression: none (task completed correctly all 6 runs)
```

---

## Minimum Bar for `settings.json.template` PRs

- ≥ 3 runs each baseline and variant
- ≥ 5% improvement in at least one metric
- Zero quality regressions
- Explanation of *why* the setting produces the result (see `docs/why-each-setting.md` for examples)

---

## Notes

- Variance of ±5% across runs is normal
- If baseline and variant overlap within variance, the change has no measurable effect
- Token counts vary with Claude's verbosity — consistent task instructions reduce this noise
- Run in the same shell environment (same PATH, same env vars) for all runs
