---
name: engram-offload
description: "Context offloading: save large outputs to Engram to keep messages lean. Use during long builds or when context > 40%."
---

# Engram Context Offload Protocol

## When to Offload
Save to Engram instead of leaving in messages:
- File read > ~100 lines → save key facts (not raw content)
- Large tool output (build logs, test results, search results > 50 lines)
- Discovery you'll need later this session
- Context > 40%

## Naming Convention
```
title:     {project}/{slug}/{type}
topic_key: {project}/{slug}/{type}
```
Examples:
- `my-app/auth/schema` — auth module schema
- `my-app/session/state` — state before compact
- `my-app/build/errors` — current build errors

## Saving
```
mem_save(
  title: "{project}/{slug}/{type}",
  topic_key: "{project}/{slug}/{type}",
  type: "discovery",
  content: "{compressed key facts — not raw output}"
)
```
Save **what you learned**, not what you read.

## Retrieving
Previews are always truncated — always two steps:
```
Step 1: mem_search("{project}/{slug}") → get ID
Step 2: mem_get_observation(id) → full content
```

## Compact Protocol
**Before** `/compact`:
```
mem_save(
  title: "{project}/session/state",
  topic_key: "{project}/session/state",
  type: "discovery",
  content: "task: ...\nfiles_read: [...]\nkey_facts: [...]\nnext_steps: [...]"
)
```
**After** `/compact`:
```
mem_search("{project}/session/state") → mem_get_observation → continue
```
