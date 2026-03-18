# Code Review Checklist

## Security (OWASP Top 10)
- [ ] No SQL built by string concatenation — use parameterized queries
- [ ] No unsanitized user input rendered as HTML — escape or use safe APIs
- [ ] No secrets, tokens, or passwords hardcoded or logged
- [ ] No shell commands built from user input — use argument arrays, not strings
- [ ] Auth checks present on all state-mutating endpoints
- [ ] No path traversal: user-supplied filenames must be validated/sandboxed
- [ ] Dependencies: no newly added packages with known CVEs

## Correctness
- [ ] Edge cases handled: empty input, zero, null/None, empty list
- [ ] Error paths: what happens on network failure, DB error, timeout?
- [ ] Concurrency: any shared state that could race?
- [ ] Off-by-one: loop bounds, slice indices, pagination limits
- [ ] Data truncation: integers that could overflow, strings that exceed column width

## Minimum Change Principle
- [ ] Only changes what was asked — no unrequested refactors
- [ ] No new comments or docstrings on unchanged code
- [ ] No style cleanup beyond the changed lines
- [ ] No added features "while we're here"

## Code Quality
- [ ] Names are accurate — function does exactly what its name implies
- [ ] No dead code introduced (unreachable branches, unused variables)
- [ ] No premature abstractions — three similar lines beats a new helper for one use
- [ ] No feature flags or backwards-compat shims unless the code will have two live paths

## Performance
- [ ] No N+1 queries introduced (loop that issues DB/network calls per item)
- [ ] No unbounded result sets returned to the client
- [ ] No blocking I/O on the main thread / event loop
- [ ] No large allocations inside hot loops

## Tests (if present)
- [ ] Tests cover the happy path and at least one failure path
- [ ] Tests don't mock so aggressively that they test the mock, not the code
- [ ] No `time.sleep()` in tests — use deterministic waits or fakes
