---
name: context-budget
description: "Surgical reading discipline: Grep before Read, offset/limit for large files, batch tool calls, avoid re-reading. Activate when context window is above 60% or on long sessions."
---

# Context Budget Rules

## File Loading Priority
1. **Grep first** — search for symbol, pattern, or text before opening any file
2. **Glob to locate** — find files by name pattern before reading contents
3. **Read targeted sections** — `offset`/`limit` for only relevant lines
4. **Read whole files last** — only when full structure genuinely needed

## Over-Reading Patterns
- Opening a file "just to see what's in it"
- Re-reading a file already in context this session
- Reading entire file when only a function/block is needed
- Grepping config files speculatively (Grep instead)

## Parallel vs Sequential
- **Independent queries** (two different files): batch in one response
- **Dependent queries** (grep → then read match): sequential is correct
- Never N sequential calls that could be 1 parallel call

## Context Hygiene
- Context > 80%: finish subtask cleanly, then `/compact`
- No re-read files in context — content still there
- Summarize long tool outputs; don't repeat verbatim

## Signs of Over-Reading
- Reading to "confirm" what's already in context
- Reading every import to trace a dependency
- Opening files mentioned in comments speculatively
- `cat`/`Read` on files not yet Grep'd
