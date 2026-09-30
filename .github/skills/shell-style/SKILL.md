---
name: shell-style
description: Review shell scripts, shell recipes, or shell code blocks (bash or POSIX sh) for style and correctness against the Google Shell Style Guide. Use when asked to review, lint, audit, or critique shell/bash/sh code, or when writing new shell scripts that should follow Google's conventions.
---

Use `shell-style-guide.md` (in this skill's directory) as the authoritative
reference. It is a mirror of Google's Shell Style Guide
(https://google.github.io/styleguide/shellguide.html). Read it before
reviewing so citations match its actual wording and section headings.

## Scope detection

First determine what dialect the target code actually uses, since the guide
is written for `bash` specifically:

- If a file has a `#!/bin/bash` (or `#!/usr/bin/env bash`) shebang, or uses
  bash-only features (`[[ … ]]`, arrays, `(( … ))`, `local`, `readarray`,
  `function name()`), apply the full guide, including the bash-only sections
  (Test `[[ … ]]`, Arrays, Arithmetic, etc.).
- If a file deliberately targets POSIX `sh` (`#!/bin/sh`, `#!/usr/bin/sh`, or
  a `set shell := ["sh", …]`-style POSIX constraint such as in a `justfile`),
  do **not** flag the absence of bash-only features as violations. Still
  apply the dialect-agnostic guidance: comments, naming, formatting,
  quoting, error handling, command substitution style, `main`, etc. Note
  explicitly in your report that bash-specific rules were skipped and why.
- If a project's own conventions intentionally diverge from the guide (e.g.
  a documented reason to avoid bashisms), respect that intent rather than
  insisting on bash idioms.

## Review process

1. Identify the shell file(s) or embedded shell blocks (e.g. recipe bodies
   in a `Makefile`/`justfile`, heredocs, CI workflow `run:` steps) to review.
2. If the `shellcheck` CLI is available, run it against real `.sh`/`.bash`
   files and fold its findings into the review (ShellCheck is explicitly
   recommended by the guide). Skip this for embedded snippets that aren't
   standalone files.
3. Walk the guide's sections and check the code against each applicable
   rule, including (non-exhaustive):
   - Shebang/interpreter choice and minimal flags (§1.1)
   - File extension and executability conventions (§2.1), no SUID/SGID (§2.2)
   - Errors to STDERR, an `err()`-style helper if relevant (§3.1)
   - File header, function header comments (Description/Globals/Arguments/
     Outputs/Returns), TODO format `TODO(name): …` (§4)
   - Indentation (2 spaces, no tabs), 80-col lines, long strings via heredoc
     (§5.1–5.2)
   - Pipeline splitting style (§5.3)
   - `; then`/`; do` on the same line, aligned `fi`/`done` (§5.4)
   - `case` indentation and `;;` placement (§5.5)
   - Variable brace-delimiting and quoting conventions (§5.6–5.7)
   - `$(...)` over backticks (§6.2)
   - `[[ … ]]` over `[ … ]`/`test` in bash context (§6.3–6.4)
   - Explicit `./*` wildcard expansion (§6.5)
   - No `eval` (§6.6)
   - Arrays instead of space-delimited strings for lists (§6.7)
   - Avoiding pipe-to-`while` subshell pitfalls (§6.8)
   - `(( … ))`/`$(( … ))` over `let`/`expr`/`$[ … ]` (§6.9)
   - No aliases in scripts (§6.10)
   - Naming conventions for functions/variables/constants (§7)
   - `local` for function-scoped variables, with separate declare+assign
     when capturing a command substitution's exit code matters (§7.5)
   - Functions grouped above a `main "$@"` for longer scripts (§7.6–7.7)
   - Checking return values explicitly, builtins over external commands
     (§8)
4. For each finding, report: file and line (or snippet), the guide section
   it relates to, what's wrong, and a concrete fix. Don't invent
   violations for things the guide calls optional/recommended-only — note
   the difference between "required" and "strongly recommended" language
   used in the guide.
5. Prioritize correctness/safety issues (quoting bugs, unchecked return
   values, `eval`, unsafe wildcard expansion) over pure style nits, and say
   so when summarizing.

Keep the final report concise: a short summary plus a findings list (or a
table), not a line-by-line transcript of the whole file.
