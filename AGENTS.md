# Agent instructions

These instructions favour rapid development. Where they conflict with an agent's
default behaviour (committing, exhaustive testing, web lookups), these win.

## Repo facts

- Task recipes live in `.justfile`. Its shell is POSIX `sh` (`set shell := ["sh", "-ceu"]`):
  no bashisms.
- Helper scripts and configuration are in `docs/_dev/` (`_lib.sh`, Python utilities,
  Vale and pa11y config).
- When writing or reviewing shell code, use the `shell-style` skill in
  `.github/skills/shell-style/`.
- Contribution rules are in `CONTRIBUTING.md`. PRs use `.github/pull_request_template.md`.

## Working rules

1. **Minimal reasoning about unknowns.** Only write to `/tmp` when running actual unit
   or integration tests in code. Never use it, or any other file, to check basic facts
   or as scratch space. Make a reasonable assumption and move on.
2. **No internet queries.** If something is unknown (an API, a command, a flag), add it
   to the Unknowns list and keep going on your best assumption. Report the list at the
   end of the reasoning cycle.
3. **Code from what you have.** Base code on files already in context and on your own
   knowledge. Don't re-explore to double-check.
4. **No git state changes.** Never stash or commit (and don't reset or discard changes).
   If you're unsure about a route, copy the edited file in the worktree (for example
   `file.alt`) and compare the copies with `diff`. Leave the choice and cleanup to the
   user.
5. **Test late.** Test only after significant changes, not after each function edit.
   If a change touches many commands or outputs (such as a new parameter), check at
   most one representative path. Leave the full suite for a later, dedicated session.
6. **Read only the range given.** When told to read `<file>:<line-range>`, read only
   that range. Don't read the rest of the file or the surrounding context.
7. **No multiline `awk`, `sed`, or heredocs.** Never write multiline `awk` or `sed`
   programs, or heredocs (here-files). Use short one-line commands, or plain `sh` with
   simple steps.

## End-of-cycle report

Finish each reasoning cycle with a brief report:

- **Changes:** what was edited.
- **Assumptions:** what you assumed instead of verifying.
- **Unknowns:** the list from rule 2.
- **Alternate copies:** any files created under rule 4.
- **Tests:** what was run, and what was deliberately skipped.
