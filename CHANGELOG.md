# sphinx-stack changelog

## Upcoming

* Make removed URL check redirect-aware and add support for reusable workflow contexts
* Exclude utility directories from builds and checks
* Update link to documentation in README
* Skip pa11y installation if it is already present
* Update `CONTRIBUTING.md` to include versioning and breaking changes policy 

### Changed

* `docs/conf.py` [#610](https://github.com/canonical/sphinx-stack/pull/610)
* `docs/Makefile` [#605](https://github.com/canonical/sphinx-stack/pull/605), [#610](https://github.com/canonical/sphinx-stack/pull/610), [#627](https://github.com/canonical/sphinx-stack/pull/627)
* `README.md` [#603](https://github.com/canonical/sphinx-stack/pull/603)
* `.github/workflows/cla-check.yml` [#606](https://github.com/canonical/sphinx-stack/pull/606)
* `.github/workflows/check-removed-urls.yml` [#612](https://github.com/canonical/sphinx-stack/pull/#612)
* `CONTRIBUTING.md` [#632](https://github.com/canonical/sphinx-stack/pull/632)

## 2.0

* Add an `AUTOBUILD_EXTRA_OPTS` variable to extend sphinx-autobuild options for `make run`
* Add default support for the sphinx-llm extension
* Pin dependencies to major versions
* Remove `reuse/` directory
* Rename `.sphinx/` directory to `_dev/`
* Add default configuration for copyright and license statements
* Remove docs and project-specific configuration

### Changed

* `docs/conf.py`  [#562](https://github.com/canonical/sphinx-docs-starter-pack/pull/562), [#576](https://github.com/canonical/sphinx-docs-starter-pack/pull/576), [#590](https://github.com/canonical/sphinx-docs-starter-pack/pull/590), [#595](https://github.com/canonical/sphinx-docs-starter-pack/pull/595), [#598](https://github.com/canonical/sphinx-docs-starter-pack/pull/598)
* `docs/Makefile` [#575](https://github.com/canonical/sphinx-docs-starter-pack/pull/575), [#590](https://github.com/canonical/sphinx-docs-starter-pack/pull/590)
* `docs/requirements.txt` [#590]([https://github.com/canonical/sphinx-docs-starter-pack/pull/590), [#630]([https://github.com/canonical/sphinx-docs-starter-pack/pull/630)
* `docs/reuse/` [#576](https://github.com/canonical/sphinx-docs-starter-pack/pull/576)
* `docs/.sphinx/` [#598](https://github.com/canonical/sphinx-docs-starter-pack/pull/598)
* `docs/_templates/footer.html` [#594](https://github.com/canonical/sphinx-docs-starter-pack/pull/594)
* `docs/requirements.txt` [#596](https://github.com/canonical/sphinx-docs-starter-pack/pull/596)
* `docs/redirects.txt` [#598](https://github.com/canonical/sphinx-docs-starter-pack/pull/598)
* `docs/.sphinx/update_sp.py` [#595](https://github.com/canonical/sphinx-docs-starter-pack/pull/595)
* `.github/workflows/test-sphinx-stack.yml` [#595](https://github.com/canonical/sphinx-docs-starter-pack/pull/595)

## 1.6

* Fix the handling of non-zero exit codes from pymarkdownlnt.
* Add a how-to guide about testing the Ulwazi theme.
* Move the Python virtual environment from `docs/.sphinx/venv` to `docs/.venv`.
* Make rediraffe the default extension for page redirects
* Add default templates for the Canonical cookie banner and Google Analytics.

### Changed

* `.github/workflows/check-removed-urls.yml` [#552](https://github.com/canonical/sphinx-docs-starter-pack/pull/552)
* `.github/workflows/sphinx-python-dependency-build-checks.yml` [#552](https://github.com/canonical/sphinx-docs-starter-pack/pull/552)
* `docs/.gitignore` [#552](https://github.com/canonical/sphinx-docs-starter-pack/pull/552), [#598](https://github.com/canonical/sphinx-docs-starter-pack/pull/598)
* `docs/.sphinx/.wordlist.txt` [#520](https://github.com/canonical/sphinx-docs-starter-pack/pull/520)
* `docs/conf.py` [#549](https://github.com/canonical/sphinx-docs-starter-pack/pull/549), [#558](https://github.com/canonical/sphinx-docs-starter-pack/pull/558), [#552](https://github.com/canonical/sphinx-docs-starter-pack/pull/552), [#558](https://github.com/canonical/sphinx-docs-starter-pack/pull/558)
* `docs/Makefile` [#551](https://github.com/canonical/sphinx-docs-starter-pack/pull/551), [#552](https://github.com/canonical/sphinx-docs-starter-pack/pull/552)
* `docs/redirects.txt` [#558](https://github.com/canonical/sphinx-docs-starter-pack/pull/558)
* `docs/_templates/header.html` [#549](https://github.com/canonical/sphinx-docs-starter-pack/pull/549)
* `docs/_templates/footer.html` [#549](https://github.com/canonical/sphinx-docs-starter-pack/pull/549)

## 1.5

* Add `CONTRIBUTING.md`.
* Rename Makefile variables to avoid collisions in host environment.
* Rename `TARGET` variable for Vale checks to `CHECK_PATH`.
* Remove or replace docs use of archived example product documentation site.
* Revert the switch to a reusable `automatic-doc-checks.yml` workflow.
* Add `-q` flag to linkchecker to only report errors or broken links.
* Update dependency canonical-sphinx to 0.6.0 or higher.
* Update the default runner version for markdown linting.

### Changed

* `docs/Makefile` [#494](https://github.com/canonical/sphinx-docs-starter-pack/pull/494), [#536](https://github.com/canonical/sphinx-docs-starter-pack/pull/536), [#544](https://github.com/canonical/sphinx-docs-starter-pack/pull/544)
* `docs/conf.py` [#502](https://github.com/canonical/sphinx-docs-starter-pack/pull/502), [#545](https://github.com/canonical/sphinx-docs-starter-pack/pull/545)
* `docs/how-to/guidance.rst` [#502](https://github.com/canonical/sphinx-docs-starter-pack/pull/502)
* `docs/reference/index.rst` [#502](https://github.com/canonical/sphinx-docs-starter-pack/pull/502)
* `docs/reference/myst-syntax-reference.md` [#502](https://github.com/canonical/sphinx-docs-starter-pack/pull/502)
* `docs/reference/rst-syntax-reference.rst` [#502](https://github.com/canonical/sphinx-docs-starter-pack/pull/502)
* `.github/workflows/automatic-doc-checks.yml` [#514](https://github.com/canonical/sphinx-docs-starter-pack/pull/514)
* `.github/workflows/markdown-style-checks.yml [#535](https://github.com/canonical/sphinx-docs-starter-pack/pull/535)
* `docs/requirements.txt` [#543](https://github.com/canonical/sphinx-docs-starter-pack/pull/543)

## 1.4.1

* Fix the version slug so the upgrade script has the right release tag.

### Changed

* `docs/.sphinx/version` [#516](https://github.com/canonical/sphinx-docs-starter-pack/pull/516)

## 1.4.0

* Fix exclude paths issue for pymarkdown introduced in 0.9.35 and pin version.
* Add `install` dependency to `pymarkdownlnt-install` make target and use VENVDIR variable.
* Remove scripts and references to unused HTML metrics.
* Pin myst-parser package version to 4.0 to avoid conflicts.
* Make `BUILDDIR` in Makefile configurable from the calling environment.

### Changed

* `docs/requirements.txt` [#496](https://github.com/canonical/sphinx-docs-starter-pack/pull/496)
* `docs/Makefile` [#490](https://github.com/canonical/sphinx-docs-starter-pack/pull/490), [#504](https://github.com/canonical/sphinx-docs-starter-pack/pull/504), [#508](https://github.com/canonical/sphinx-docs-starter-pack/pull/508)
* `docs/.sphinx/update_sp.py` [#490](https://github.com/canonical/sphinx-docs-starter-pack/pull/490)

### Removed

* `docs/.sphinx/metrics/build_metrics.py` [#490](https://github.com/canonical/sphinx-docs-starter-pack/pull/490)
* `docs/.sphinx/metrics/source_metrics.sh` [#490](https://github.com/canonical/sphinx-docs-starter-pack/pull/490)

## 1.3.1

* Switch doc links to `stable` slug.
* !!POTENTIAL CONFIGURATION ISSUE: Fixes duplicate version strings in sitemaps for versioned docs. This removes the `version` variable previously set in the sitemaps configuration section of `conf.py`. If you have any custom code that uses this variable elsewhere, do not remove it.
* Make `VALEDIR` in Makefile configurable from the calling environment.

### Changed

* `docs/conf.py` [#477](https://github.com/canonical/sphinx-docs-starter-pack/pull/477)
* `docs/Makefile` [#468](https://github.com/canonical/sphinx-docs-starter-pack/pull/468), [#472](https://github.com/canonical/sphinx-docs-starter-pack/pull/472)
* `.github/workflows/automatic-doc-checks.yml` [#466](https://github.com/canonical/sphinx-docs-starter-pack/pull/466)
* `.github/workflows/check-removed-urls.yml` [#466](https://github.com/canonical/sphinx-docs-starter-pack/pull/466)
* `.github/workflows/markdown-style-checks.yml` [#466](https://github.com/canonical/sphinx-docs-starter-pack/pull/466)
* `.github/workflows/sphinx-python-dependency-build-checks.yml` [#466](https://github.com/canonical/sphinx-docs-starter-pack/pull/466)
* `docs/Makefile` [#493](https://github.com/canonical/sphinx-docs-starter-pack/pull/493)

## 1.3.0

* !!!BREAKING: Updated deps to use atomic extensions, not `canonical-sphinx[full]`. Updated `sphinx-terminal` uses backwards incompatible syntax
* Changed `html_baseurl` for better canonical URL support
* Changes metrics script to a less brittle Python script
* Introduce guidelines for adding diagrams-as-code
* Introduce guidelines for rendering CSV data as tables
* Introduce guidelines for pulling in docstrings using Sphinx `autodoc` extension
* Introduce guidelines for using custom base templates
* Dropped unused makefile variable `ALLFILES`
* Fix syntax error in Makefile that caused the fallback target to loop
  infinitely.
* Add a step to the tutorial about removing `CODEOWNERS`.

### Added

* `docs/.sphinx/metrics/build_metrics.py` [#373](https://github.com/canonical/sphinx-docs-starter-pack/pull/373)

## Changed

* `docs/Makefile` [#373](https://github.com/canonical/sphinx-docs-starter-pack/pull/373), [#456](https://github.com/canonical/sphinx-docs-starter-pack/pull/456)
* `docs/requirements.txt` [#449](https://github.com/canonical/sphinx-docs-starter-pack/pull/449), [#456](https://github.com/canonical/sphinx-docs-starter-pack/pull/456), [#460](https://github.com/canonical/sphinx-docs-starter-pack/pull/460)
* `docs/conf.py` [#429](https://github.com/canonical/sphinx-docs-starter-pack/pull/429), [#449](https://github.com/canonical/sphinx-docs-starter-pack/pull/449), [#442](https://github.com/canonical/sphinx-docs-starter-pack/pull/442), [#460](https://github.com/canonical/sphinx-docs-starter-pack/pull/460) [#462](https://github.com/canonical/sphinx-docs-starter-pack/pull/462)
* `docs/.sphinx/get_vale_conf.py` [#448](https://github.com/canonical/sphinx-docs-starter-pack/pull/448)
* `docs/.sphinx/update_sp.py` [#425](https://github.com/canonical/sphinx-docs-starter-pack/pull/425)
* `docs/.sphinx/metrics/build_metrics.py` [#448](https://github.com/canonical/sphinx-docs-starter-pack/pull/448)
* `.github/workflows/check-removed-urls.yml` [#437](https://github.com/canonical/sphinx-docs-starter-pack/pull/437), [#445](https://github.com/canonical/sphinx-docs-starter-pack/pull/445)
* `.github/workflows/markdown-style-checks.yml` [#445](https://github.com/canonical/sphinx-docs-starter-pack/pull/445)
* `.github/workflows/sphinx-python-dependency-build-checks.yml` [#445](https://github.com/canonical/sphinx-docs-starter-pack/pull/445)
* `.github/workflows/test-starter-pack.yml` [#445](https://github.com/canonical/sphinx-docs-starter-pack/pull/445)
* `docs/Makefile` [#461](https://github.com/canonical/sphinx-docs-starter-pack/pull/461)

### Removed

* `docs/.sphinx/metrics/build_metrics.sh` [#373](https://github.com/canonical/sphinx-docs-starter-pack/pull/373)

## 1.2.0

* Replaces spelling check with Vale.
* Fixes the Markdown linting GitHub action and adds a `make lint-md` check.
* Fixes the download branch name in the update script.
* Adds a check for removed URLs.

### Added

* `docs/.sphinx/.pymarkdown.json` [#379](https://github.com/canonical/sphinx-docs-starter-pack/pull/379)
* `.github/workflows/check-removed-urls.yml` [#410](https://github.com/canonical/sphinx-docs-starter-pack/pull/410)

### Changed

* `docs/.sphinx/update_sp.py` [#397](https://github.com/canonical/sphinx-docs-starter-pack/pull/397) [#410](https://github.com/canonical/sphinx-docs-starter-pack/pull/410)
* `.github/workflows/markdown-style-checks.yml` [#379](https://github.com/canonical/sphinx-docs-starter-pack/pull/379)
* `docs/Makefile` [#379](https://github.com/canonical/sphinx-docs-starter-pack/pull/379) [#410](https://github.com/canonical/sphinx-docs-starter-pack/pull/410)
* `docs/requirements.txt` [#410](https://github.com/canonical/sphinx-docs-starter-pack/pull/410)
* `docs/.sphinx/get_vale_conf.py` [#410](https://github.com/canonical/sphinx-docs-starter-pack/pull/410)

### Removed

* `docs/.sphinx/.markdownlint.json` [#379](https://github.com/canonical/sphinx-docs-starter-pack/pull/379)
* `docs/.sphinx/.wordlist.txt` [#410](https://github.com/canonical/sphinx-docs-starter-pack/pull/410)
* `docs/.sphinx/spellingcheck.yaml` [#410](https://github.com/canonical/sphinx-docs-starter-pack/pull/410)


## 1.1.0

* Adds sitemap support.
* Simplifies vale binary download & install.
* Leaves vale install output in STDOUT to reveal potential problems.
* Improves update logic.
* Update Makefile logic

### Changed

* `docs/conf.py` [#389](https://github.com/canonical/sphinx-docs-starter-pack/pull/389)
* `docs/requirements.txt`(https://github.com/canonical/sphinx-docs-starter-pack/pull/389)

## 1.0.1

Fixes an issue with Vale implementation, and adds words to main wordlist.

### Changed

* `docs/Makefile` [852c19b](https://github.com/canonical/sphinx-docs-starter-pack/commit/852c19bf162e4697d7f36b49e8bc36ad71302216)
* `docs/.sphinx/.wordlist.txt` [#367](https://github.com/canonical/sphinx-docs-starter-pack/pull/367)
* `docs/.sphinx/get_vale_conf.py` [#358](https://github.com/canonical/sphinx-docs-starter-pack/pull/358)

## 1.0.0

First versioned release. Adds an update command to better facilitate updates to
starter pack based documentation sets.

### Added

* `CHANGELOG.md` [#357](https://github.com/canonical/sphinx-docs-starter-pack/pull/357)
* `.github/pull_request_template.md` [#357](https://github.com/canonical/sphinx-docs-starter-pack/pull/357)
* `docs/.sphinx/version` [#357](https://github.com/canonical/sphinx-docs-starter-pack/pull/357)
* `docs/.sphinx/update_sp.py` [#357](https://github.com/canonical/sphinx-docs-starter-pack/pull/357)

### Changed

* `.readthedocs.yaml` [#357](https://github.com/canonical/sphinx-docs-starter-pack/pull/357)
* `.github/workflows/sphinx-python-dependency-build-checks.yml` [#357](https://github.com/canonical/sphinx-docs-starter-pack/pull/357)
* `docs/.sphinx/.markdownlint.json` [#357](https://github.com/canonical/sphinx-docs-starter-pack/pull/357)
* `docs/Makefile` [#357](https://github.com/canonical/sphinx-docs-starter-pack/pull/357)
* `docs/conf.py` [#357](https://github.com/canonical/sphinx-docs-starter-pack/pull/357)
* `docs/requirements.txt` [#357](https://github.com/canonical/sphinx-docs-starter-pack/pull/357)

### Removed

* `.wokeignore` [#363](https://github.com/canonical/sphinx-docs-starter-pack/pull/363)
* `docs/.sphinx/_static/project_specific.css` [#357](https://github.com/canonical/sphinx-docs-starter-pack/pull/357)

## pre-version

This version is the initial versioned release, supporting the implementation of
updates.

### Added

* All files

## VERSION

{Summary of features}

### Added

* {File} {[Commit number](https://www.github.com) or [PR](https://www.github.com)}
* {File} {[Commit number](https://www.github.com) or [PR](https://www.github.com)}
* {File} {[Commit number](https://www.github.com) or [PR](https://www.github.com)}

### Changed

* {File} {[Commit number](https://www.github.com) or [PR](https://www.github.com)}
* {File} {[Commit number](https://www.github.com) or [PR](https://www.github.com)}
* {File} {[Commit number](https://www.github.com) or [PR](https://www.github.com)}

### Removed

* {File} {[Commit number](https://www.github.com) or [PR](https://www.github.com)}
* {File} {[Commit number](https://www.github.com) or [PR](https://www.github.com)}
* {File} {[Commit number](https://www.github.com) or [PR](https://www.github.com)}
