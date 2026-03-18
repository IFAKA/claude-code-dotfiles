# Context Budget Rules

## Surgical Reading Discipline

### File Loading Priority Order
1. **Grep first** — search for the specific symbol, pattern, or text before opening any file
2. **Glob to locate** — find files by name pattern before reading their contents
3. **Read targeted sections** — use `offset`/`limit` to read only the relevant lines
4. **Read whole files last** — only when structure or full context is genuinely needed

### What Counts as Over-Reading
- Opening a file "just to see what's in it"
- Reading a file you already read earlier this session
- Reading an entire file when only a function or block is needed
- Reading config files speculatively to check if a setting exists (Grep instead)

### Parallel vs Sequential Tool Calls
- **Independent queries** (e.g., searching two different files): batch in one response
- **Dependent queries** (e.g., grep → then read the matching file): sequential is correct
- Never make N sequential calls that could be 1 parallel call

### Context Hygiene
- If context window > 80%: finish current subtask cleanly, then `/compact`
- Do not re-read files already in context this session — the content is still there
- Summarize long tool outputs mentally; don't repeat them back verbatim

### Signs You're Over-Reading
- Reading a file to "confirm" something you already know from context
- Reading every import in a module to trace a dependency
- Opening files mentioned in comments or docs speculatively
- Using `cat` or `Read` on files you haven't Grep'd first
