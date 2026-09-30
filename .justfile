#################################################
# Documentation task recipes for the Sphinx Stack
#################################################

#######################
# Environment variables
#######################

export DOCS_DIR := "docs"
export DEV_DIR := env("DEV_DIR", DOCS_DIR / "_dev")
export DOCS_VENVDIR := env("DOCS_VENVDIR", DOCS_DIR / ".venv")
export DOCS_VENV := env("DOCS_VENV", DOCS_VENVDIR / "bin" / "activate")
export DOCS_SOURCEDIR := env("DOCS_SOURCEDIR", DOCS_DIR)
export DOCS_BUILDDIR := env("DOCS_BUILDDIR", DOCS_DIR / "_build")
export DOCS_PIP_OPTS := env("DOCS_PIP_OPTS", "")
export PYTHONPATH := DEV_DIR + (if env("PYTHONPATH", "") == "" { "" } else { ":" + env("PYTHONPATH", "") })
export SPHINX_BUILD := env("SPHINX_BUILD", DOCS_VENVDIR / "bin" / "sphinx-build")
export SPHINX_OPTS := env("SPHINX_OPTS", "-c " + DOCS_DIR + " -d " + DEV_DIR + "/.doctrees -j auto")
export SPHINX_AUTOBUILD_OPTS := env("SPHINX_AUTOBUILD_OPTS", "-D llms_txt_enabled=0")
export SPHINX_HOST := env("SPHINX_HOST", "127.0.0.1")
export SPHINX_PORT := env("SPHINX_PORT", "8000")
export VALE_CONFIG := env("VALE_CONFIG", DEV_DIR / "vale.ini")
export DOCS_PDFPACKAGES := env("DOCS_PDFPACKAGES", "latexmk fonts-freefont-otf texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended texlive-font-utils texlive-lang-cjk texlive-xetex plantuml xindy tex-gyre dvipng")


###############
# Just settings
###############

set quiet  # We don't want to see which commands are being run
set shell := ["sh", "-ceu"]  # We use universal POSIX `sh` for basic commands
set no-exit-message  # We want to handle all error messages ourselves


################
# Just variables
################

project_line := shell("grep '^project = ' \"$1/conf.py\"", DOCS_DIR)  # e.g. project = "Project"
product := trim_end_match(trim_start_match(project_line, 'project = "'), '"')
product_short := kebabcase(product)
version := shell("git describe --tags 2> /dev/null || git rev-parse --short HEAD")
verbose := "false"  # Default value for common verbosity option
help := "false"  # Default value for common help option
clean := "false"  # Default value for common clean option
refresh := "false"  # Default value for common refresh option
log := "false"  # Default value for common log option


#########
# Recipes
#########

# Default command, if user passed no sub-command
_default: help

# help
[
    group("Main"),
    doc("View help for the commands"),
    metadata("This documentation is managed with the just task runner. Use it for different documentation operations, including setup, building, and checking for problems."),
    arg("command", help="Command to show help for")
]
help command="help": (_help command)

_help command="help" help_option="true":
    #!/usr/bin/sh
    set -eu
    . "$DEV_DIR/_lib.sh"

    if [ "{{help_option}}" = "true" ]; then
        print_help "{{command}}" "{{product}} {{version}}" "{{just_executable()}}" "{{justfile()}}"
    fi


# setup
[
    group("Setup"),
    doc("Set up the documentation"),
    metadata(
        "Set up the documentation by installing all required Python packages and creating a Python virtual environment. Has two modes:",
        "- 'all' (default) installs all packages for HTML builds.",
        "- 'pdf' installs packages for PDF builds."
    ),
    arg("mode", help="Set up the requirements for PDF build"),
    arg("refresh", long, value="true", help="Remove the old environment and packages first"),
    arg("help", long, value="true"),
    arg("verbose", long, value="true")
]
setup mode="" refresh=refresh help=help verbose=verbose: (_help "setup" help)
    #!/usr/bin/sh
    set -eu
    . "$DEV_DIR/_lib.sh"
    [ "{{help}}" = "true" ] && exit 0

    if [ "{{mode}}" = "pdf" ]; then
        missing=""
        for package in $DOCS_PDFPACKAGES; do
            if ! dpkg-query -W -f='${Status}' "$package" 2> /dev/null | grep -q "ok installed"; then
                missing="$missing $package"
            fi
        done

        if [ -z "$missing" ]; then
            printf '%s\n' "PDF packages already installed"
            exit 0
        fi

        if [ "$(id -u)" -ne 0 ]; then
            printf '%s\n' "Installing the PDF packages requires root. Run again with sudo, for example: sudo just setup pdf" >&2
            exit 1
        fi

        run_cmd \
            "Updating package lists..." \
            "" \
            "{{verbose}}" \
            apt-get update

        # shellcheck disable=SC2086 -- missing intentionally word-splits into
        # package names.
        run_cmd \
            "Installing packages on your system:$missing" \
            "PDF packages installed" \
            "{{verbose}}" \
            apt-get install --no-install-recommends -y $missing

        exit 0
    fi

    requirements="$DOCS_DIR/requirements.txt"

    if ! which python3 > /dev/null; then
        printf '%s\n' "Cannot install docs, missing package 'python3'" >&2
        exit 1
    fi

    if [ "{{refresh}}" = "false" ] && [ -d "$DOCS_VENVDIR" ] && [ "$DOCS_VENVDIR" -nt "$requirements" ]; then
        printf '%s\n' "Docs already installed and up-to-date"
    else
        if [ "{{refresh}}" = "true" ] && [ ! -d "$DOCS_VENVDIR" ]; then
            run_cmd \
                "Removing old environment..." \
                "" \
                "{{verbose}}" \
                rm -r $DOCS_VENVDIR

            run_cmd \
                "Creating docs environment..." \
                "" \
                "{{verbose}}" \
                python3 -m venv "$DOCS_VENVDIR"
        fi

        touch "$DOCS_VENVDIR"

        # shellcheck disable=SC2086 -- DOCS_PIP_OPTS intentionally word-splits
        # into multiple pip flags; it holds no values with spaces/globs.
        run_cmd \
            "Updating packages..." \
            "" \
            "{{verbose}}" \
            "$DOCS_VENVDIR/bin/pip" install $DOCS_PIP_OPTS \
            -r "$requirements" \
            --log "$DOCS_VENVDIR/pip_install.log" \
            --require-virtualenv \
            --upgrade

        pip_list="$DOCS_VENVDIR/pip_list.txt"
        freeze="$("$DOCS_VENVDIR/bin/pip" list --local --format=freeze)"
        
        if [ -f "$pip_list" ]; then
            run_cmd \
                "" \
                "" \
                "{{verbose}}" \
                mv -f "$pip_list" "$pip_list.bak"

            run_cmd \
                "" \
                "" \
                "{{verbose}}" \
                "$freeze" > "$pip_list"
        fi
    fi

# build
[
    group("Main"),
    doc("Render the docs"),
    metadata(
        "Render the docs. Four output types are available:",
        "- 'run' (default) hosts the docs in a local server you can view in the web browser. When you save a change to a source file, the server updates the doc in real time.",
        "- 'html' renders the docs as a static set of HTML pages",
        "- 'pdf' renders the docs as a PDF file",
        "- 'epub' renders the docs as an EPUB e-book"
    ),
    arg("mode", help="Output type, either 'run' (default), 'html', 'pdf', or 'epub'"),
    arg("clean", long, value="true", help="Clean the built docs and temporary files before building"),
    arg("log", long),
    arg("path", long, help="Destination path for PDF builds"),
    arg("help", long, value="true"),
    arg("verbose", long, value="true")
]
build mode="run" log=log clean=clean path="" help=help verbose=verbose: (_help "build" help)
    #!/usr/bin/sh
    set -eu
    . "$DEV_DIR/_lib.sh"
    [ "{{help}}" = "true" ] && exit 0

    build_dir="$DOCS_BUILDDIR"
    log_file="$DEV_DIR/warnings.txt"

    if [ "{{clean}}" = "true" ]; then
        run_cmd \
            "Removing prior build..." \
            "" \
            "{{verbose}}" \
            rm -rf "$build_dir" "$log_file"
    fi

    # shellcheck disable=SC2086 -- SPHINX_OPTS/SPHINX_AUTOBUILD_OPTS
    # intentionally word-split into multiple sphinx-build flags; they hold
    # no values with spaces/globs.
    case "{{mode}}" in
        epub)
            run_cmd \
                "Building epub..." \
                "Epub built to $DOCS_BUILDDIR" \
                "{{verbose}}" \
                "$SPHINX_BUILD" \
                -b epub \
                "$DOCS_SOURCEDIR" \
                "$build_dir" \
                -w "$log_file" \
                $SPHINX_OPTS
            ;;
        html)
            run_cmd \
                "Building docs..." \
                "Docs built to $DOCS_BUILDDIR" \
                "{{verbose}}" \
                "$SPHINX_BUILD" \
                -b dirhtml \
                "$DOCS_SOURCEDIR" \
                "$build_dir" \
                -w "$log_file" \
                $SPHINX_OPTS \
                --fail-on-warning \
                --keep-going
            ;;
        run)
            run_cmd \
                "Serving docs locally at $SPHINX_HOST...\nPress Ctrl + C to end" \
                "Server closed" \
                "{{verbose}}" \
                "$DOCS_VENVDIR/bin/sphinx-autobuild" \
                -b dirhtml \
                --host "$SPHINX_HOST" \
                --port "$SPHINX_PORT" \
                "$DOCS_SOURCEDIR" \
                "$build_dir" \
                $SPHINX_OPTS \
                $SPHINX_AUTOBUILD_OPTS
            ;;
        pdf)
            pdf_dir="{{path}}"
            pdf_dir="${pdf_dir:-$build_dir}"

            run_cmd \
                "Building PDF..." \
                "" \
                "{{verbose}}" \
                "$SPHINX_BUILD" \
                -M latexpdf \
                "$DOCS_SOURCEDIR" \
                "$build_dir" \
                $SPHINX_OPTS

            run_cmd \
                "" \
                "" \
                "{{verbose}}" \
                rm -f \
                "$build_dir/latex/front-page-light.pdf" \
                "$build_dir/latex/normal-page-footer.pdf"

            run_cmd \
                "" \
                "" \
                "{{verbose}}" \
                mkdir -p "$pdf_dir"

            run_cmd \
                "" \
                "" \
                "{{verbose}}" \
                find "$build_dir/latex" -name "*.pdf" -exec mv -t "$pdf_dir" {} +

            run_cmd \
                "" \
                "PDF built to $pdf_dir" \
                "{{verbose}}" \
                rm -r "$build_dir/latex"
            ;;
    esac

# clean
[
    group("Main"),
    doc("Remove built docs and temporary files"),
    metadata("Remove all built docs and temporary files. Sometimes, stale files can cause build failures, and the only solution is to clear the previous builds."),
    arg("help", long, value="true"),
    arg("verbose", long, value="true")
]
clean help=help verbose=verbose: (_help "clean" help)
    #!/usr/bin/sh
    set -eu
    . "$DEV_DIR/_lib.sh"
    [ "{{help}}" = "true" ] && exit 0

    run_cmd \
        "Removing built docs..." \
        "" \
        "{{verbose}}" \
        git clean -fx "$DOCS_BUILDDIR"

    run_cmd \
        "Removing temporary files..." \
        "Docs cleaned" \
        "{{verbose}}" \
        rm -rf "$DEV_DIR/.doctrees"

# remove
[
    group("Setup"),
    doc("Remove the docs environment"),
    metadata("Remove the docs environment."),
    arg("help", long, value="true"),
    arg("verbose", long, value="true")
]
remove help=help verbose=verbose: (_help "remove" help)
    #!/usr/bin/sh
    set -eu
    . "$DEV_DIR/_lib.sh"
    [ "{{help}}" = "true" ] && exit 0

    run_cmd \
        "Removing docs environment..." \
        "Docs environment removed" \
        "{{verbose}}" \
        rm -rf \
        "$DOCS_VENVDIR" \
        "$DEV_DIR/node_modules" \
        "$DEV_DIR/styles" \
        "$VALE_CONFIG"

# check
[
    group("Main"),
    doc("Check for problems in the documentation"),
    metadata(
        "Check for problems in the documentation. Two checks are available:",
        "- 'style' checks for spelling, style, and Markdown formatting concerns",
        "- 'links' checks for valid external hyperlinks"
    ),
    arg("type", help="The check to run, either 'all' (default), 'style', or 'links'"),
    arg("help", long, value="true"),
    arg("verbose", long, value="true")
]
check type="all" help=help verbose=verbose: (_help "check" help) (_check-style (if help == "true" { "help" } else { type }) verbose) (_check-links (if help == "true" { "help" } else { type }) verbose)

_check-style type verbose:
    #!/usr/bin/sh
    set -eu

    if [ "{{type}}" != "all" ] && [ "{{type}}" != "style" ]; then
        exit 0
    fi

    . "$DEV_DIR/_lib.sh"

    check_path="${CHECK_PATH:-}"

    # Equivalent to activating the venv: vale needs rst2html on PATH
    PATH="$PWD/$DOCS_VENVDIR/bin:$PATH"
    export PATH

    if [ -z "$check_path" ]; then
        for item in "$DOCS_DIR"/*; do
            case "$item" in
                "$DOCS_VENVDIR"|"$DOCS_BUILDDIR"|"$DEV_DIR") ;;
                *) check_path="$check_path $item" ;;
            esac
        done
    fi
    check_path="${check_path# }"

    if [ ! -f "$VALE_CONFIG" ]; then
        # TODO: 'env -C' needs GNU coreutils 8.28+; find a portable way to
        # run get_vale_conf.py from the docs directory
        run_cmd \
            "Fetching Vale configuration..." \
            "" \
            "{{verbose}}" \
            env -C "$DOCS_DIR" "$PWD/$DOCS_VENVDIR/bin/python3" _dev/get_vale_conf.py
    fi

    printf '%s\n' '.Name=="Canonical.400-Enforce-inclusive-terms"' > "$DEV_DIR/styles/woke.filter"
    printf '%s\n' '.Level=="error" and .Name!="Canonical.500-Repeated-words" and .Name!="Canonical.000-US-spellcheck"' > "$DEV_DIR/styles/error.filter"
    printf '%s\n' '.Name=="Canonical.000-US-spellcheck"' > "$DEV_DIR/styles/spelling.filter"

    run_cmd \
        "" \
        "" \
        "{{verbose}}" \
        find "$DOCS_VENVDIR"/lib/python*/site-packages/vale/vale_bin -size 195c -exec "$DOCS_VENVDIR/bin/vale" --version \;

    # Keep the project's custom words in their own Vale vocabulary, so the
    # stock accept.txt is never modified
    custom_vocab_dir="$DEV_DIR/styles/config/vocabularies/Custom"
    custom_config="$DEV_DIR/styles/vale.custom.ini"
    mkdir -p "$custom_vocab_dir"
    cp "$DOCS_SOURCEDIR/.custom_wordlist.txt" "$custom_vocab_dir/accept.txt"
    sed \
        -e 's/^Vocab = Canonical$/Vocab = Canonical, Custom/' \
        -e 's/^StylesPath = styles$/StylesPath = ./' \
        "$VALE_CONFIG" > "$custom_config"

    for filter in error spelling woke; do
        # shellcheck disable=SC2086 -- check_path intentionally word-splits
        # into multiple paths; it holds no values with spaces.
        printf '%s\n' "Running Vale ($filter) against $check_path. To change target, set CHECK_PATH"
        "$DOCS_VENVDIR/bin/vale" \
            --config="$custom_config" \
            --filter="$DEV_DIR/styles/$filter.filter" \
            --glob='*.{md,rst}' \
            $check_path
    done

    if ! ls -d "$DOCS_VENVDIR"/lib/python*/site-packages/pymarkdown > /dev/null 2>&1; then
        run_cmd \
            "Installing pymarkdownlnt..." \
            "" \
            "{{verbose}}" \
            "$DOCS_VENVDIR/bin/pip" install pymarkdownlnt==0.9.35
    fi

    # The explicit scheme makes exit code 1 mean only "no files found"
    printf '%s\n' "Running Markdown lint against $check_path"
    status=0
    "$DOCS_VENVDIR/bin/pymarkdownlnt" \
        --config "$DEV_DIR/.pymarkdown.json" \
        --return-code-scheme explicit \
        scan --recurse $check_path || status=$?

    if [ "$status" -eq 1 ]; then
        printf '%s\n' "No Markdown files selected for linting"
    elif [ "$status" -ne 0 ]; then
        printf '%s\n' "pymarkdownlnt exited with code $status" >&2
        exit "$status"
    fi

_check-links type verbose:
    #!/usr/bin/sh
    set -eu

    if [ "{{type}}" != "all" ] && [ "{{type}}" != "links" ]; then
        exit 0
    fi

    . "$DEV_DIR/_lib.sh"

    # TODO: Revisit this EXIT trap. It exists because run_cmd relies on
    # `set -e`, which is disabled inside `if`/`||`, so a failed linkcheck
    # can't be caught directly. run_cmd's failure handling should be reworked.
    trap 'grep --color -F "[broken]" "$DOCS_BUILDDIR/output.txt" 2> /dev/null || true' EXIT

    run_cmd \
        "Checking links..." \
        "No broken links found" \
        "{{verbose}}" \
        "$SPHINX_BUILD" \
        -b linkcheck \
        -q \
        "$DOCS_SOURCEDIR" \
        "$DOCS_BUILDDIR" \
        $SPHINX_OPTS


###########################################
# Aliases for the old Makefile target names
###########################################

alias install := setup
alias clean-doc := clean

[private]
run: (build "run")

[private]
html: (build "html")

[private]
pdf: (build "pdf")

[private]
linkcheck: (check "links")

[private]
vale: (check "style")

[private]
spelling: (check "style")

[private]
spellcheck: (check "style")

[private]
woke: (check "style")

[private]
lint-md: (check "style")
