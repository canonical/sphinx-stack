# Copilot instructions

Follow [`AGENTS.md`](../AGENTS.md) in the repository root. It is the single source of
truth. In brief:

1. Only write to `/tmp` when running actual unit or integration tests in code. Never use
   it to check basic facts or for scratch files; assume and move on.
2. Don't query the internet. List unknowns and report them at the end of the cycle.
3. Code from the existing context and your own knowledge.
4. Never stash or commit. Compare edited-file copies in the worktree instead.
5. Test only after significant changes. Leave the full suite for a later session.
6. When told to read `<file>:<line-range>`, read only that range.
7. Never write multiline `awk` or `sed` programs, or heredocs (here-files).
