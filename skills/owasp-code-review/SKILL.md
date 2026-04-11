---
name: owasp-code-review
description: "Opinionated code review checklist: OWASP Top 10 security, correctness edge cases, minimum-change principle, performance anti-patterns, test quality. Use when reviewing PRs, auditing diffs, or doing formal code review."
---

# Code Review Checklist

## Security (OWASP Top 10)
- [ ] No SQL built by string concatenation — use parameterized queries
- [ ] No unsanitized user input rendered as HTML — escape or use safe APIs
- [ ] No secrets, tokens, or passwords hardcoded or logged
- [ ] No shell commands built from user input — use argument arrays, not strings
- [ ] Auth checks on all state-mutating endpoints
- [ ] No path traversal: user-supplied filenames validated/sandboxed
- [ ] No newly added packages with known CVEs

## Correctness
- [ ] Edge cases: empty input, zero, null/None, empty list
- [ ] Error paths: network failure, DB error, timeout?
- [ ] Concurrency: shared state that could race?
- [ ] Off-by-one: loop bounds, slice indices, pagination limits
- [ ] Data truncation: integer overflow, strings exceeding column width

## Minimum Change Principle
- [ ] Only changes what was asked — no unrequested refactors
- [ ] No new comments or docstrings on unchanged code
- [ ] No style cleanup beyond changed lines
- [ ] No added features "while we're here"

## Code Quality
- [ ] Names accurate — function does exactly what name implies
- [ ] No dead code (unreachable branches, unused variables)
- [ ] No premature abstractions — three similar lines beats a new helper
- [ ] No feature flags or backwards-compat shims unless two live paths exist

## Performance
- [ ] No N+1 queries (loop issuing DB/network calls per item)
- [ ] No unbounded result sets to client
- [ ] No blocking I/O on main thread / event loop
- [ ] No large allocations in hot loops

## Tests (if present)
- [ ] Happy path + at least one failure path covered
- [ ] Tests don't mock so aggressively they test the mock, not the code
- [ ] No `time.sleep()` in tests — deterministic waits or fakes
