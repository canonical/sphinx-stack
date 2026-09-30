# Copyright 2022-2024 Canonical Ltd.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Library functions for the documentation justfile

########################################
# Run a command, printing a status message before and after it. When
# verbose, also prints the resolved command and lets its own stdout/stderr
# through; otherwise the command's own output is suppressed and only the
# status messages are printed.
# Globals:
#   None
# Arguments:
#   msg_begin: Message to print before running the command. May contain
#     a literal '\n' escape, which is expanded.
#   msg_end: Message to print after the command exits successfully.
#   verbose: "true" to show the resolved command and its output.
#   command: The command to run, followed by its arguments.
# Outputs:
#   Writes msg_begin/msg_end to stdout. When verbose, also writes the
#   resolved command and the command's own stdout/stderr.
# Returns:
#   The exit status of the command, via `set -e` in the caller.
########################################
run_cmd() {
    msg_begin="$1"
    msg_end="$2"
    verbose="$3"
    shift 3

    if [ -n "$msg_begin" ]; then
        printf '%b\n' "$msg_begin"
    fi

    if [ "$verbose" = "true" ]; then
        printf '%s\n' "$*"
        "$@"
    else
        "$@" > /dev/null 2>&1
    fi

    if [ -n "$msg_end" ]; then
        printf '%s\n' "$msg_end"
    fi
}

# Begin LLM mush

########################################
# Help text. All data comes from the recipes in the justfile: [doc] is the
# summary, [group] the command group, [metadata] the description paragraphs
# (a paragraph starting with "- " is a bullet), and [arg(..., help=)] the
# argument and option descriptions. Usage is derived from the recipe signature.
# The functions read 'just --list' and 'just --show', so strings in the
# attributes must not contain '"', and a [doc] must not contain '# '.
########################################

# Print the lines of 'just --show' output on stdin that hold the [metadata]
# paragraphs, one paragraph per line, without quotes.
help_metadata() {
    local paragraph

    grep '^\[metadata(' | grep -o '"[^"]*"' | while IFS= read -r paragraph; do
        paragraph="${paragraph#\"}"
        printf '%s\n' "${paragraph%\"}"
    done
}

# Print the [arg] attribute line of a parameter, if it has one.
# Arguments:
#   show: Output of 'just --show' for the recipe.
#   name: Parameter name.
help_arg() {
    printf '%s\n' "$1" | grep "^\[arg(\"$2\"" || :
}

# Print the quoted value of a key in an attribute line, e.g. help="..." or long="...".
# Arguments:
#   line: The attribute line.
#   key: The key to look up.
help_attr() {
    printf '%s\n' "$1" | grep -o "$2=\"[^\"]*\"" | cut -d '"' -f 2
}

########################################
# Print text wrapped to a width, one line at a time.
# Arguments:
#   width: Maximum line length, including the prefixes.
#   first: Prefix of the first line.
#   next: Prefix of the following lines.
#   text: The text to wrap.
########################################
help_print_wrapped() {
    local width="$1" first="$2" next="$3" text="$4" line empty=1 word

    line="$first"
    set -f
    for word in $text; do
        if [ "$empty" = 1 ]; then
            line="$line$word"
            empty=0
        elif [ $((${#line} + 1 + ${#word})) -gt "$width" ]; then
            printf '%s\n' "$line"
            line="$next$word"
        else
            line="$line $word"
        fi
    done
    set +f
    printf '%s\n' "$line"
}

# Wrap paragraphs (one per line on stdin) to 80 columns, with a blank line
# between them. Bullets ("- ") stay together and get a hanging indent.
help_wrap_block() {
    local para bullet prev_bullet=0 first=1

    while IFS= read -r para; do
        case "$para" in
            "- "*) bullet=1 ;;
            *) bullet=0 ;;
        esac

        if [ "$first" = 0 ] && [ "$bullet$prev_bullet" != "11" ]; then
            printf '\n'
        fi

        if [ "$bullet" = 1 ]; then
            help_print_wrapped 80 "" "  " "$para"
        else
            help_print_wrapped 80 "" "" "$para"
        fi

        prev_bullet="$bullet"
        first=0
    done
}

# Print one row: the name right-aligned in an 18-column field, then the
# description wrapped with a hanging indent.
# Arguments:
#   name: The command, argument, or option.
#   description: What it does.
help_print_row() {
    local pad

    pad="$(printf '%18s' "$1")"
    help_print_wrapped 80 "$pad  " "                    " "$2"
}

########################################
# Print the rows of the arguments or options of a recipe that have a help
# string. The global options are left out.
# Arguments:
#   kind: "positional" or "option".
#   show: Output of 'just --show' for the recipe.
#   params: The recipe's parameters, as written in its signature.
########################################
help_print_arguments() {
    local kind="$1" show="$2" param pname argline ahelp
    shift 2

    for param in "$@"; do
        pname="${param%%=*}"
        argline="$(help_arg "$show" "$pname")"
        ahelp="$(help_attr "$argline" help)"

        case "$pname" in
            help|verbose) continue ;;
        esac
        if [ -z "$ahelp" ]; then
            continue
        fi

        case "$argline" in
            *long=*)
                if [ "$kind" = "option" ]; then
                    help_print_row "--$(help_attr "$argline" long)" "$ahelp"
                fi
                ;;
            *)
                if [ "$kind" = "positional" ]; then
                    help_print_row "$pname" "$ahelp"
                fi
                ;;
        esac
    done
}

########################################
# Print the main help.
# Arguments:
#   header: Line to print first.
#   just: Path of the just executable.
#   justfile: Path of the justfile.
########################################
help_print_main() {
    local line group name doc

    printf '%s\n\nUsage:\n    just <command> [<option>...]\n\n' "$1"
    "$2" --justfile "$3" --show help | help_metadata | help_wrap_block
    printf '\n%s\n' "Run 'just help <command>' to view a command's usage."

    "$2" --justfile "$3" --list --no-aliases --list-heading '' --list-prefix '' | while IFS= read -r line; do
        case "$line" in
            "["*"]")
                group="${line#\[}"
                printf '\n%s commands:\n' "${group%\]}"
                ;;
            "") ;;
            *)
                name="${line%% *}"
                doc="${line#*# }"
                help_print_row "$name" "$doc"
                ;;
        esac
    done

    printf '\nGlobal options:\n'
    help_print_row "--verbose" "Show more commands in the terminal"
    help_print_row "--help" "Show this help"
}

########################################
# Print the help for one recipe.
# Arguments:
#   name: Recipe name.
#   just: Path of the just executable.
#   justfile: Path of the justfile.
# Returns:
#   1 if the recipe doesn't exist or isn't public.
########################################
help_print_recipe() {
    local name="$1" just="$2" justfile="$3"
    local show sig param pname argline usage options="" has_positional=0 has_option=0

    case " $("$just" --justfile "$justfile" --summary) " in
        *" $name "*) ;;
        *)
            printf '%s\n' "Unknown command '$name'. Run 'just help' to see the commands." >&2
            return 1
            ;;
    esac

    show="$("$just" --justfile "$justfile" --show "$name")"
    sig="$(printf '%s\n' "$show" | grep -m 1 "^$name[ :]")"
    sig="${sig%%:*}"

    # shellcheck disable=SC2086 -- intentional word splitting of the signature
    # into the name and its parameters.
    set -- $sig
    shift

    usage="just $name"
    for param in "$@"; do
        pname="${param%%=*}"
        argline="$(help_arg "$show" "$pname")"

        case "$argline" in
            *long=*)
                options=" [<option>...]"
                if [ "$pname" != "help" ] && [ "$pname" != "verbose" ] && [ -n "$(help_attr "$argline" help)" ]; then
                    has_option=1
                fi
                ;;
            *)
                usage="$usage <$pname>"
                if [ -n "$(help_attr "$argline" help)" ]; then
                    has_positional=1
                fi
                ;;
        esac
    done

    printf 'Usage:\n    %s%s\n\n' "$usage" "$options"
    printf '%s\n' "$show" | help_metadata | help_wrap_block

    if [ "$has_positional" = 1 ]; then
        printf '\nPositional arguments:\n'
        help_print_arguments positional "$show" "$@"
    fi

    if [ "$has_option" = 1 ]; then
        printf '\nOptions:\n'
        help_print_arguments option "$show" "$@"
    fi

    printf '\nGlobal options:\n'
    help_print_row "--verbose" "Show more commands in the terminal"
    help_print_row "--help" "Show this help"
}

########################################
# Print the help for a command, or the main help for "help".
# Arguments:
#   command: Recipe name, or "help" for the main help.
#   header: Line to print first in the main help.
#   just: Path of the just executable.
#   justfile: Path of the justfile.
# Returns:
#   1 if the command doesn't exist.
########################################
print_help() {
    if [ "$1" = "help" ]; then
        help_print_main "$2" "$3" "$4"
    else
        help_print_recipe "$1" "$3" "$4"
    fi
}
