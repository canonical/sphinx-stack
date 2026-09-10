# Contributing to Sphinx Stack development

The Sphinx Stack is a shared foundation for Sphinx documentation projects, and
contributions help improve the documentation of all its users. The Documentation
Practice team performs most of the work, but all contributors are welcome.

Common contributions include:

- Bug fixes: Build errors, broken links, configuration issues
- Improvements: Better defaults, new extensions, workflow enhancements, new or improved
  style rules
- Dependency updates: Security patches, compatibility fixes, better tooling

If you run into any problems or see room for improvement, we encourage you to open an issue or even contribute a fix.

> This guide only covers contributions to development. If you're interested in
> contributing to the Sphinx Stack documentation, refer to the [documentation
> repository's
> guide](https://github.com/canonical/sphinx-stack-docs/blob/main/CONTRIBUTING.md).

## Review the project expectations

Review these three documents before contributing:

### Ubuntu Code of Conduct

When contributing, you must abide by the [Ubuntu Code of
Conduct](https://ubuntu.com/community/ethos/code-of-conduct). Projects governed by
Canonical expect good conduct and excellence from every member.

### Canonical Contributor License Agreement

Code contributions can only be accepted from contributors who have signed the
[Contributor License Agreement (CLA)](https://ubuntu.com/legal/contributors). Signing
the agreement grants Canonical permission to use your contributions, and you remain the
copyright owner of your work (no copyright assignment occurs).

Review the terms of the agreement before signing it or committing anything. If you agree
and choose to sign it, your work can be incorporated into the repository.

### Open source license

The Sphinx Stack is licensed under [GPL-3.0](LICENSE).

## Report an issue or open a request

If you find a bug or feature gap in the Sphinx Stack, look for it in the [project's
GitHub issues](https://github.com/canonical/sphinx-stack/issues) first. Add
your voice to the thread if you have fresh input.

If the bug or feature doesn't have an issue, [open
one](https://github.com/canonical/sphinx-stack/issues/new/choose).

## What belongs in the Sphinx Stack

The Sphinx Stack is designed to be a minimal, flexible foundation for diverse
documentation projects.

**Belongs in the Sphinx Stack:**
- Bug fixes for core functionality
- Improvements to default configuration that benefit all users
- Dependency updates for security or compatibility

**May not belong in the Sphinx Stack:**
- Optional tooling or features (these should be opt-in and implemented by projects using
  the Sphinx Stack)
- Opinionated formatting or linting rules that would cause a sizable portion of existing
  doc sets to fail checks suddenly
- Changes that conflict with existing workflows
- Features that are project-specific rather than general-purpose
- UI-related changes may be better suited for the ongoing alternative theme update
  project (ask maintainers)

When in doubt, open an issue first to discuss whether the change aligns with the
project's goals.

## Versioning

The Sphinx Stack follows a modified [Semantic Versioning 2.0](https://semver.org). 

### Major version

A major version increment signifies one or more changes that, if ignored or overridden, would greatly affect the quality of the documentation or the project’s compatibility with subsequent versions. These changes are necessary and often require significant effort by the user to incorporate. Breaking changes are introduced in major versions only. Changes warranting a major version increment must be planned and implemented by maintainers.

#### Breaking changes

To minimize disruptions caused by breaking changes, there should be a migration path 
provided where possible. The Sphinx Stack project aims to deprecate features being 
removed at least one release prior to removal. Breaking change PRs are labeled with `Awaiting release` once approved and are only merged at the next major release.

In cases where there is a need to address a serious security vulnerability or critical 
product bug, maintainers may merge a breaking change without prior notice, assessed on a 
case-by-case basis and communicated in the release notes.

### Minor version

A minor version increment signifies a new optional feature that users can choose to adopt. If ignored, these changes will not negatively affect documentation quality or compatibility with subsequent versions.

These changes can require action from the user, but are trivial to incorporate.

### Patch version

While patch releases aren’t tagged in this versioning policy, hotfixes are still accounted for. Every commit to the `main` branch is effectively a patch release.

These changes correct existing behavior or information and are trivial to incorporate.

## Development setup

Create a [personal fork](https://github.com/canonical/sphinx-stack/fork) of
the repository, then clone it and add the upstream remote:

With
[SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account):

```bash
git clone git@github.com:<username>/sphinx-stack
cd sphinx-stack
git remote add upstream git@github.com:canonical/sphinx-stack
git fetch upstream
```

With
[HTTPS](https://docs.github.com/en/get-started/git-basics/about-remote-repositories#cloning-with-https-urls):

```bash
git clone https://github.com/<username>/sphinx-stack
cd sphinx-stack
git remote add upstream https://github.com/canonical/sphinx-stack
git fetch upstream
```

Install dependencies and verify the build:

```bash
cd docs
make install
make html
```

## Contribute a change

### Link to an issue

All work should be tied to an existing issue. See [Report an issue or open a
request](#report-an-issue-or-open-a-request) to find or open one. Once you're ready to
start, comment on the issue to have it assigned to you.

For significant changes, describe your proposal in the issue thread, including the plan, tests, and
documentation. For new documentation pages, propose a [Diátaxis](https://diataxis.fr)
category.

### Create a development branch

`main` is the default branch and is protected. All changes are introduced through a pull request.

Sync and create a new branch:

```bash
git fetch upstream
git checkout -b <new-branch-name>
```

Name your branch `<ticket-id>-<description>` (e.g., `issue-235-add-string-sanitizer`),
keeping it under 80 characters.

Create a new branch for each task. Once a branch has been merged, don't recreate it or push further commits to it.

### Make your changes

Follow these guidelines:

- Use separate commits for each logical change, and for changes to different components
- Keep the Sphinx Stack minimal by default; optional features are best implemented
  by the projects using the Sphinx Stack rather than the Sphinx Stack itself

### Commit a change

```bash
git add -A
git commit
```

Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) format:

```
feat: add text sanitizer
```

To determine the commit type, check the file history with `git log --oneline <filename>`.

> **Tip**
>
> If you're unsure which type to use, the commit may be doing too much, so split it into
> smaller commits instead. Select the highest-ranked type that fits:
>
> - `ci`
> - `build`
> - `feat`
> - `fix`
> - `perf`
> - `refactor`
> - `style`
> - `test`
> - `docs`
> - `chore`

### Sign your commits

All commits require cryptographic signatures ([DCO
1.1](https://developercertificate.org/)). You can sign commits by adding `-S` to the
`git commit` command from the previous section, for example:

```bash
git commit -S -m "feat: add logging levels to update script"
```

Signed commits display a "Verified" badge in GitHub. Set up signing via [GitHub Docs -
About commit signature
verification](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification).

> **Tip**
>
> You can configure your Git client to sign commits by default for any local repository
> by running `git config --global commit.gpgsign true`. Once you have done this, you no
> longer need to add `-S` to your commits explicitly.
>
> See [GitHub Docs - Signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits) for more information.

If you've made an unsigned commit and encounter the "Commits must have verified
signatures" error when pushing your changes to the remote:

1. Amend the most recent commit by signing it without changing the commit message, and
   push again:

   ```bash
   git commit --amend --no-edit -n -S
   git push
   ```

2. If you still encounter the same error, confirm that your GitHub account has been set
   up properly to sign commits as described in the [GitHub Docs - About commit signature
   verification](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification).

   > **Tip**
   >
   > If you use SSH keys to sign your commits, make sure to add a "Signing Key" type in
   > your GitHub account. See [GitHub Docs - Adding a new SSH key to your
   > account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
   > for more information.

### Test the change

Build and run the checks locally before submitting:

```bash
cd docs
make html
```

```bash
make spelling      # Check spelling
make linkcheck     # Validate links
make woke          # Check inclusive language
make lint-md       # Check Markdown style
make vale          # Check style guide compliance (optional)
```

To preview locally with live reload at `http://127.0.0.1:8000`, run:

```bash
make run
```

### Document the change

This documentation is sourced from
[canonical/sphinx-stack-docs](https://github.com/canonical/sphinx-stack-docs) and uses
[Diátaxis](https://diataxis.fr). For small changes, update existing how-to guides and
references. For significant changes or new flows, create new pages
in the appropriate category.

Run the same basic checks locally that GitHub runs on PRs; see [Test the
change](#test-the-change).

#### Changelog guidance

Ensure that feature changes and fixes are documented in the relevant release notes.

### Push the branch and open a PR

```bash
git push -u origin <branch-name>
```

Next, open a PR on GitHub. Format its title as a conventional commit (GitHub may do this
automatically for single-commit branches).

### Describing PRs

Your PR should include the following details:

- Title: Short, descriptive summary
- Description: Problem solved, features added, or bugs fixed
- Relevant issues: [Link related issues and PRs](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/autolinked-references-and-urls)
- Testing: How reviewers can verify the change or test the fix
- Reversibility: For costly-to-reverse decisions, explain reasoning and reversal steps
- Labels: Categorize the changes by adding the relevant labels e.g. `bug`, `documentation`, `breaking change` 

## CI/CD pipeline

The repository configures multiple automated checks. Some are conditional based on
target branch or changed files.

If a check fails, review the logs for remediation guidance. For failures unrelated to
your changes, rebase against the latest base branch.

### Checks on all PRs

These run on every PR and on pushes to `main`:

- Documentation build: Builds the documentation and checks for errors
- Spelling check: Verifies spelling using Vale
- Link check: Validates all links in the documentation
- Inclusive language check: Runs woke to check for non-inclusive language
- Python dependency build: Verifies dependencies can be built from source

### Checks on PRs to `main` only

- CLA check: Verifies you have signed the Canonical Contributor License Agreement
- Removed URLs check: Detects if any URLs were removed without redirects

#### CLA check in CI

When you open a pull request (PR) against the `main` branch, a mandatory automated check
verifies that you have signed the CLA. It uses the
[canonical/has-signed-canonical-cla](https://github.com/canonical/has-signed-canonical-cla)
GitHub Action.

If you haven't signed the CLA:
1. The check will fail with a message indicating the CLA requirement
2. Visit <https://ubuntu.com/legal/contributors> to review and sign the agreement
3. Once signed, re-run the check if you have permissions, or ask a maintainer to do so.
   Pushing a new commit also triggers re-evaluation.

The CLA check only runs on PRs to `main`. Internal team members working on other
branches should ensure they have signed the CLA before their changes are merged to
`main`.

### Checks on changes to `docs/` only

- Markdown style check: Runs `pymarkdownlnt` on Markdown files
- Automatic documentation checks: Runs upstream documentation workflow checks. The
  project uses
  [canonical/documentation-workflows](https://github.com/canonical/documentation-workflows)
  for automatic documentation checks. To modify this part of CI behavior, pass inputs to
  upstream workflows rather than creating or customizing local copies.

### Optional checks (allowed to fail)

- Style guide check (`vale`): Checks compliance with the Canonical style guide
- Accessibility check (`pa11y`): Checks accessibility of generated HTML

## Review process

PRs are reviewed based on priority but are typically reviewed within a week. 

### Responding to feedback

Push additional commits to address feedback (commit locally rather than via GitHub UI to
avoid sync conflicts).

Rebase your branch before requesting a review to keep your commits clean. Once review
has started, avoid rebasing to maintain the review history and make it easier for
reviewers to see what changed.

### Common feedback themes

Reviewers may request:

- Wording, terminology, or formatting changes
- Consistency with existing patterns
- Proper reST or MyST markup style
- Minimal examples before listing options
- Cross-references: Use proper reST or MyST syntax
- Examples: Start minimal, then show options; include verification steps
- Theme compatibility: Test in both light and dark modes

### Merging

A maintainer approval is needed before any PR can be merged. Approved PRs are squashed and merged.

Breaking changes follow a different merge timeline, see [Breaking changes](#breaking-changes).
