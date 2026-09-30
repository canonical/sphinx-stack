#!/usr/bin/env python3
"""Smoke-test the output of the Just recipes, without pytest.

Each recipe is run and its output is compared with baked-in expectations. For
multi-line output, only the first and last lines are checked. Any non-zero exit
code is an immediate failure that stops the run. Run it from anywhere:

    python3 <path-to>/cli-test.py

Standard library only; Python 3.11 or newer.
"""

import os
import queue
import re
import signal
import shutil
import socket
import subprocess
import sys
import tempfile
import threading
import time
from dataclasses import dataclass, field
from pathlib import Path
from re import Pattern

# The justfile path is relative to this script's directory, where `just` runs.
JUSTFILE = "../../.justfile"
SCRIPT_DIR = Path(__file__).parent
COMMAND_TIMEOUT = 900
SERVE_TIMEOUT = 300
SERVE_HOST = "127.0.0.1"
SERVE_PORT = 8000
SERVE_READY = "[sphinx-autobuild] Waiting to detect changes..."
ANSI_ESCAPE = re.compile(r"\x1b\[[0-9;]*m")

Expected = str | Pattern[str]


@dataclass
class Case:
    args: list[str]
    first: Expected
    last: Expected
    env: dict[str, str] = field(default_factory=dict)
    serve: bool = False
    wait_port: bool = False
    sandbox: bool = False
    skip: bool = False


@dataclass
class Result:
    exit_code: int | None
    lines: list[str]
    error: str = ""


HELP_FIRST = "Usage:"
HELP_LAST = "            --help  Show this help"
MAIN_HELP_FIRST = re.compile(r"Project \S+")
STYLE_FIRST = re.compile(
    r"find docs/\.venv/lib/python[\d.]+/site-packages/vale/vale_bin "
    r"-size 195c -exec docs/\.venv/bin/vale --version ;"
)
SERVE_FIRST = "Serving docs locally at 127.0.0.1..."
SERVE_QUIET_LAST = "Press Ctrl + C to end"
BUILT_LAST = "Docs built to docs/_build"
SETUP_LINE = "Docs already installed and up-to-date"

# The first command, `clean`, leaves no stale files. The commands after it are in
# alphabetical order. Within each command, the order is:
#   1. the plain command
#   2. options only, alphabetized
#   3. arguments, alphabetized
#   4. arguments and options, alphabetized by argument, then by options
CASES = [
    # clean
    Case(
        args=["clean"],
        first="Removing built docs...",
        last="Docs cleaned",
    ),
    Case(
        args=["clean", "--help"],
        first=HELP_FIRST,
        last=HELP_LAST,
    ),
    Case(
        args=["clean", "--verbose"],
        first="Removing built docs...",
        last="Docs cleaned",
    ),
    # build
    Case(
        args=["build"],
        first=SERVE_FIRST,
        last=SERVE_QUIET_LAST,
        serve=True,
        wait_port=True,
    ),
    Case(
        args=["build", "--clean"],
        first="Removing prior build...",
        last=SERVE_QUIET_LAST,
        serve=True,
        wait_port=True,
    ),
    Case(
        args=["build", "--clean", "--verbose"],
        first="Removing prior build...",
        last=SERVE_READY,
        env={"PYTHONUNBUFFERED": "1"},
        serve=True,
    ),
    Case(
        args=["build", "--help"],
        first=HELP_FIRST,
        last=HELP_LAST,
    ),
    Case(
        args=["build", "--verbose"],
        first=SERVE_FIRST,
        last=SERVE_READY,
        env={"PYTHONUNBUFFERED": "1"},
        serve=True,
    ),
    Case(
        args=["build", "epub"],
        first="",
        last="",
        skip=True,
    ),
    Case(
        args=["build", "html"],
        first="Building docs...",
        last=BUILT_LAST,
    ),
    Case(
        args=["build", "pdf"],
        first="",
        last="",
        skip=True,
    ),
    Case(
        args=["build", "run"],
        first=SERVE_FIRST,
        last=SERVE_QUIET_LAST,
        serve=True,
        wait_port=True,
    ),
    Case(
        args=["build", "epub", "--verbose"],
        first="",
        last="",
        skip=True,
    ),
    Case(
        args=["build", "html", "--clean"],
        first="Removing prior build...",
        last=BUILT_LAST,
    ),
    Case(
        args=["build", "html", "--clean", "--verbose"],
        first="Removing prior build...",
        last=BUILT_LAST,
    ),
    Case(
        args=["build", "html", "--verbose"],
        first="Building docs...",
        last=BUILT_LAST,
    ),
    Case(
        args=["build", "pdf", "--verbose"],
        first="",
        last="",
        skip=True,
    ),
    Case(
        args=["build", "run", "--verbose"],
        first=SERVE_FIRST,
        last=SERVE_READY,
        env={"PYTHONUNBUFFERED": "1"},
        serve=True,
    ),
    # check
    Case(
        args=["check", "--help"],
        first=HELP_FIRST,
        last=HELP_LAST,
    ),
    Case(
        args=["check", "links"],
        first="Checking links...",
        last="No broken links found",
    ),
    Case(
        args=["check", "style"],
        first="Running Vale (error) against docs/index.rst. To change target, set CHECK_PATH",
        last="No Markdown files selected for linting",
        env={"CHECK_PATH": "docs/index.rst"},
    ),
    Case(
        args=["check", "links", "--verbose"],
        first="Checking links...",
        last="No broken links found",
    ),
    Case(
        args=["check", "style", "--verbose"],
        first=STYLE_FIRST,
        last="No Markdown files selected for linting",
        env={"CHECK_PATH": "docs/index.rst"},
    ),
    # help
    Case(
        args=["help"],
        first=MAIN_HELP_FIRST,
        last=HELP_LAST,
    ),
    Case(
        args=["help", "build"],
        first=HELP_FIRST,
        last=HELP_LAST,
    ),
    Case(
        args=["help", "check"],
        first=HELP_FIRST,
        last=HELP_LAST,
    ),
    Case(
        args=["help", "clean"],
        first=HELP_FIRST,
        last=HELP_LAST,
    ),
    Case(
        args=["help", "remove"],
        first=HELP_FIRST,
        last=HELP_LAST,
    ),
    Case(
        args=["help", "setup"],
        first=HELP_FIRST,
        last=HELP_LAST,
    ),
    # remove
    Case(
        args=["remove"],
        first="Removing docs environment...",
        last="Docs environment removed",
        sandbox=True,
    ),
    Case(
        args=["remove", "--help"],
        first=HELP_FIRST,
        last=HELP_LAST,
    ),
    Case(
        args=["remove", "--verbose"],
        first="Removing docs environment...",
        last="Docs environment removed",
        sandbox=True,
    ),
    # setup
    Case(
        args=["setup"],
        first=SETUP_LINE,
        last=SETUP_LINE,
    ),
    Case(
        args=["setup", "--help"],
        first=HELP_FIRST,
        last=HELP_LAST,
    ),
    Case(
        args=["setup", "--verbose"],
        first=SETUP_LINE,
        last=SETUP_LINE,
    ),
    Case(
        args=["setup", "pdf"],
        first="",
        last="",
        skip=True,
    ),
    Case(
        args=["setup", "pdf", "--verbose"],
        first="",
        last="",
        skip=True,
    ),
]


def matches(expected: Expected, actual: str) -> bool:
    if isinstance(expected, Pattern):
        return expected.fullmatch(actual) is not None
    return expected == actual


def describe(expected: Expected) -> str:
    return expected.pattern if isinstance(expected, Pattern) else repr(expected)


def clean_output(text: str) -> str:
    return ANSI_ESCAPE.sub("", text)


def just_command(case: Case, overrides: list[str] | None = None) -> list[str]:
    return ["just", "--justfile", JUSTFILE, *(overrides or []), *case.args]


def sandbox_overrides(root: Path) -> list[str]:
    """Point `remove` at a throwaway copy, so it can't delete the real environment."""
    shutil.copy(SCRIPT_DIR / "_lib.sh", root)
    (root / ".venv").mkdir()
    (root / "node_modules").mkdir()
    (root / "styles").mkdir()
    (root / "vale.ini").touch()
    return [
        "--set", "DEV_DIR", str(root),
        "--set", "DOCS_VENVDIR", str(root / ".venv"),
        "--set", "VALE_CONFIG", str(root / "vale.ini"),
    ]


def result_line(case: Case, result: str) -> str:
    return f"'just {' '.join(case.args)}' : {result}"


def run_command(case: Case) -> Result:
    with tempfile.TemporaryDirectory() as directory:
        overrides = sandbox_overrides(Path(directory)) if case.sandbox else []
        try:
            done = subprocess.run(
                just_command(case, overrides),
                cwd=SCRIPT_DIR,
                env={**os.environ, **case.env},
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                timeout=COMMAND_TIMEOUT,
            )
        except subprocess.TimeoutExpired:
            return Result(exit_code=None, lines=[], error=f"timed out after {COMMAND_TIMEOUT}s")
        if case.sandbox and (Path(directory) / ".venv").exists():
            return Result(exit_code=0, lines=[], error="the sandbox environment was not removed")
    return Result(
        exit_code=done.returncode,
        lines=clean_output(done.stdout).rstrip().splitlines(),
    )


def read_lines(stream, lines: queue.Queue) -> None:
    for line in stream:
        lines.put(clean_output(line.rstrip("\n")))
    lines.put(None)


def wait_for_port(deadline: float) -> str:
    """Wait for the server to accept connections; return an error, if any."""
    while time.monotonic() < deadline:
        try:
            socket.create_connection((SERVE_HOST, SERVE_PORT), timeout=1).close()
            return ""
        except OSError:
            time.sleep(0.5)
    return f"nothing listening on port {SERVE_PORT} after {SERVE_TIMEOUT}s"


def run_server(case: Case) -> Result:
    """Start a server recipe, wait until it is ready, then interrupt it."""
    proc = subprocess.Popen(
        just_command(case),
        cwd=SCRIPT_DIR,
        env={**os.environ, **case.env},
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        start_new_session=True,
    )
    lines: queue.Queue = queue.Queue()
    threading.Thread(target=read_lines, args=(proc.stdout, lines), daemon=True).start()

    seen: list[str] = []
    deadline = time.monotonic() + SERVE_TIMEOUT
    error = ""
    while True:
        try:
            line = lines.get(timeout=max(0.1, deadline - time.monotonic()))
        except queue.Empty:
            error = f"not ready after {SERVE_TIMEOUT}s"
            break
        if line is None:
            error = "exited before the server was ready"
            break
        seen.append(line)
        if matches(case.last, line):
            break

    if not error and case.wait_port:
        error = wait_for_port(deadline)

    if proc.poll() is None:
        os.killpg(proc.pid, signal.SIGINT)
        try:
            proc.wait(timeout=30)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGKILL)
            proc.wait()

    exit_code = proc.returncode if error.startswith("exited") else 0
    return Result(exit_code=exit_code, lines=seen, error=error)


def mismatches(case: Case, result: Result) -> list[str]:
    """Describe each mismatch in the first and last lines."""
    if not result.lines:
        return ["no output"]

    problems = []
    for label, expected, actual in (
        ("first line", case.first, result.lines[0]),
        ("last line", case.last, result.lines[-1]),
    ):
        if not matches(expected, actual):
            problems.append(
                f"{label}:\n"
                f"        expected: {describe(expected)}\n"
                f"        actual:   {actual!r}"
            )
    return problems


def main() -> int:
    passed = failed = skipped = 0
    aborted = False
    for case in CASES:
        if case.skip:
            skipped += 1
            print(result_line(case, "SKIPPED"))
            continue

        result = run_server(case) if case.serve else run_command(case)

        if result.error or (result.exit_code != 0 and not case.serve):
            failed += 1
            aborted = True
            reason = result.error or f"exit code {result.exit_code}"
            detail = f"\n    {reason}"
            if result.lines:
                detail += (
                    f"\n    first line: {result.lines[0]!r}"
                    f"\n    last line:  {result.lines[-1]!r}"
                )
            print(f"{result_line(case, 'FAILED')}{detail}")
            break

        problems = mismatches(case, result)
        if problems:
            failed += 1
            detail = "".join(f"\n    {problem}" for problem in problems)
            print(f"{result_line(case, 'FAILED')}{detail}")
        else:
            passed += 1
            print(result_line(case, "PASSED"))

    not_run = len(CASES) - passed - failed - skipped
    stopped = f"Stopped on a failed run; {not_run} case(s) not run.\n" if aborted else ""
    print(f"\n{stopped}{passed} passed, {failed} failed, {skipped} skipped")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
