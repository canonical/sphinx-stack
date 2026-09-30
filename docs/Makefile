# Targets that have an equivalent Just recipe pass through to it (for example, `make
# html` runs `just build html`).

# Variables are kept here for forward compatibility

DEV_DIR          ?= _dev
SPHINX_OPTS      ?= -c . -d $(DEV_DIR)/.doctrees -j auto
SPHINX_BUILD     ?= $(DOCS_VENVDIR)/bin/sphinx-build
SPHINX_HOST      ?= 127.0.0.1
SPHINX_PORT      ?= 8000
SPHINX_AUTOBUILD_OPTS ?= -D llms_txt_enabled=0
DOCS_VENVDIR     ?= .venv
DOCS_VENV        ?= $(DOCS_VENVDIR)/bin/activate
DOCS_SOURCEDIR   ?= .
DOCS_BUILDDIR    ?= _build
DOCS_VOCAB       ?= $(DEV_DIR)/styles/config/vocabularies/Canonical
VALE_DIR         ?= $(DOCS_VENVDIR)/lib/python*/site-packages/vale
VALE_CONFIG      ?= $(DEV_DIR)/vale.ini
PA11Y_CMD        ?= $(DEV_DIR)/node_modules/pa11y/bin/pa11y.js --config $(DEV_DIR)/pa11y.json
CONFIRM_SUDO     ?= N
CHECK_PATH       ?= $(filter-out $(DOCS_VENVDIR) $(DOCS_BUILDDIR) $(DEV_DIR),$(wildcard *))

# Pass-through to the justfile in the repository root. Paths that you set are
# relative to this directory here, but to the repository root in Just.
just_paths        = $(foreach name,DEV_DIR DOCS_VENVDIR DOCS_VENV DOCS_SOURCEDIR DOCS_BUILDDIR SPHINX_BUILD VALE_CONFIG,$(if $(filter command line environment,$(origin $(name))),$(name)="docs/$($(name))"))
just             = $(just_paths) just --justfile ../.justfile
# CHECK_PATH is relative to this directory here, but to the repository root in Just.
just_check_path  = $(if $(filter command line environment,$(origin CHECK_PATH)),CHECK_PATH="$(addprefix docs/,$(CHECK_PATH))") ${just} check style

msg_use_just = "'make' is deprecated as a task runner. Use 'just' at the root of the repository instead."
msg_removed = "This recipe has been removed."

help:
	@echo $(msg_use_just)

.PHONY: help full-help html epub pdf linkcheck spelling spellcheck woke \
        vale pa11y run serve install pa11y-install   \
        vale-install pdf-prep pdf-prep-force clean clean-doc \
        update lint-md

full-help:
	@echo $(msg_use_just)

install:
	@${just} setup

run:
	@${just} build run

html:
	@${just} build html

epub:
	@${just} build epub

serve: html
	@${just} build run

clean:
	@${just} clean
	@${just} remove

clean-doc:
	@${just} clean

linkcheck:
	@${just} check links

pa11y:
	@echo $(msg_removed)

lint-md:
	@${just_check_path}

vale-install:
	@echo $(msg_removed)

woke:
	@${just_check_path}

vale:
	@${just_check_path}

spelling:
	@${just_check_path}

spellcheck:
	@${just_check_path}

pdf-prep:
	@${just} setup pdf

pdf-prep-force:
	@${just} setup pdf

pdf:
	@${just} build pdf

update:
	@echo $(msg_removed)

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINX_OPTS).
%:
	@echo $(msg_use_just)
