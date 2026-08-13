#!/usr/bin/env python3
"""Shared test harness for the FuncTion analyzer: discovery, invocation, running.

This is the single source of truth for *how a benchmark is run*. Both
front-ends build on it:

  * script/runtest.py   -- runs + renders HTML/LaTeX/CSV reports
  * this file, `run`    -- runs + checks coverage, for regression testing
                           (the comparison itself is script/function-diff.py)

Regression workflow:

    script/harness.py run -o regression_out --layout flat --cover logs
    script/function-diff.py logs regression_out --regression

Two design rules, both learned from bugs this replaces:

1. *The config is the source of truth, not the directory name.* The analysis
   mode comes from the config's own "analysis" field; the group table below is
   only a fallback for configs that predate it. A group missing from a table
   must never silently change the analysis performed.

2. *Coverage is computed from the baselines, not from discovery.* Anything
   present in the reference directory that this run did not reproduce is a
   failure. Deriving it from discovery instead cannot detect a whole group
   being skipped -- which is exactly how tests/atl (139 configs, all
   baselined) went unchecked.
"""

import argparse
import concurrent.futures as cf
import glob
import json
import os
import re
import shlex
import subprocess
import sys
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Fallback only: used when a config does not declare its own "analysis".
GROUP_MODES = {
    "termination": [],
    "ctl": ["-ctl"],
    "atl": ["-atl"],
    "resilience": ["-atl"],
    "guarantee": ["-ctl"],
    "recurrence": ["-ctl"],
}

# Authoritative: keyed by the config's "analysis" field.
ANALYSIS_FLAGS = {
    "termination": [],
    "atl": ["-atl"],
    "ctl": ["-ctl"],
    "guarantee": ["-ctl"],
    "recurrence": ["-ctl"],
}

# Folders that get special handling / are skipped.
RESILIENCE_FOLDER = "resilience"   # matrix: every .c x every root property
# A first-level folder is treated as the resilience matrix root if it is named
# RESILIENCE_FOLDER OR, robustly to renames of that folder, if it holds this
# signature config at its top level.
RESILIENCE_SIGNATURE = "termination-resilience.json"
CTL_FOLDER = "ctl"                 # matrix: every .c x lifting variant
MATRIX_FOLDERS = {RESILIENCE_FOLDER, CTL_FOLDER}
SKIP_FOLDERS = {"ctl_lifted"}      # excluded from the run for now
# With --short, these (large SV-COMP) subtrees are pruned for a quick run.
SHORT_SKIP_FOLDERS = {"svcomp", "sv_comp"}

C = {"red": "\033[91m", "grn": "\033[92m", "yel": "\033[93m",
     "blu": "\033[94m", "bld": "\033[1m", "rst": "\033[0m"}


def color(tag, s):
    return f"{C[tag]}{s}{C['rst']}" if sys.stdout.isatty() else s


# --------------------------------------------------------------------------- #
# Discovery
# --------------------------------------------------------------------------- #

def default_groups(tests_dir):
    """Every subdirectory of tests/ is a group.

    Derived from the filesystem rather than a hardcoded table: a table has to
    be kept in sync with the directory names, and when it drifts the missing
    group is skipped silently (tests/atl was never regression-tested, and
    renaming tests/resilience to tests/resilience_excluded dropped that group
    too, both without any error).
    """
    try:
        return sorted(d for d in os.listdir(tests_dir)
                      if os.path.isdir(os.path.join(tests_dir, d)))
    except OSError:
        return []


def resilience_roots(gdir):
    """First-level subdirs of `gdir` that are resilience matrix roots: named
    RESILIENCE_FOLDER or carrying the RESILIENCE_SIGNATURE config."""
    roots = set()
    try:
        entries = os.listdir(gdir)
    except OSError:
        return roots
    for name in entries:
        sub = os.path.join(gdir, name)
        if os.path.isdir(sub) and (
                name == RESILIENCE_FOLDER
                or os.path.isfile(os.path.join(sub, RESILIENCE_SIGNATURE))):
            roots.add(name)
    return roots


def discover(tests_dir, groups, flt, short=False):
    """Yield (group, folder, cfile, cfg) for every (.c, config) pair.

    `folder` is the first path component under the group directory (the tab the
    test belongs to); it is the group name for files sitting directly in it.

    Normal folders: a .c is paired with every .json in the SAME directory whose
    name has the .c name as a prefix (`<stem>.json`, `<stem>.*.json`).

    A resilience matrix root (a first-level folder named `resilience` or holding
    a `termination-resilience.json`) is special: it holds N global property
    configs at its root, and EVERY .c anywhere in its subtree is paired with ALL
    of them (so the report can show one row per file with one result column per
    property). Detection by signature keeps this working when the folder is
    renamed.

    Paths are relative to ROOT (the analyzer concatenates output_dir + filename).
    """
    pat = re.compile(flt) if flt else None
    for group in groups:
        gdir = os.path.join(tests_dir, group)
        if not os.path.isdir(gdir):
            continue
        matrix_roots = resilience_roots(gdir)
        for dirpath, dirs, files in os.walk(gdir):
            skip = SKIP_FOLDERS | SHORT_SKIP_FOLDERS if short else SKIP_FOLDERS
            dirs[:] = [d for d in dirs if d not in skip]  # prune
            rel_dir = os.path.relpath(dirpath, gdir)
            folder = group if rel_dir == "." else rel_dir.split(os.sep)[0]
            cfiles = sorted(f for f in files if f.endswith(".c"))

            if folder in matrix_roots:
                res_root = os.path.join(gdir, folder)
                props = sorted(f for f in os.listdir(res_root)
                               if f.endswith(".json"))
                for cf_name in cfiles:
                    cfile = os.path.relpath(os.path.join(dirpath, cf_name), ROOT)
                    if pat and not pat.search(cfile):
                        continue
                    for j in props:
                        cfg = os.path.relpath(os.path.join(res_root, j), ROOT)
                        yield group, folder, cfile, cfg
                continue

            jsons = sorted(f for f in files if f.endswith(".json"))
            for cf_name in cfiles:
                stem = cf_name[:-2]  # drop the trailing ".c"
                cfile = os.path.relpath(os.path.join(dirpath, cf_name), ROOT)
                if pat and not pat.search(cfile):
                    continue
                # Match configs by the .c stem, AND by its base stem (drop a
                # "_combination_N" suffix): generated combinations share the
                # property configs of their base test, so one config set per
                # base suffices instead of duplicating it per combination.
                prefixes = [stem]
                base = re.sub(r"_combination_\d+$", "", stem)
                if base != stem:
                    prefixes.append(base)
                # The "." separator avoids cross-matching stems that are
                # prefixes of one another (e.g. "foo" must not grab "foo_bar").
                for j in jsons:
                    if any(j.startswith(p + ".") for p in prefixes):
                        cfg_abs = os.path.join(dirpath, j)
                        yield group, folder, cfile, os.path.relpath(cfg_abs, ROOT)


# --------------------------------------------------------------------------- #
# Reading analyzer output
# --------------------------------------------------------------------------- #

# Configs that could not be parsed. A malformed config used to fall back to {}
# in silence, which means the test runs with NO property and NO precondition
# and quietly returns a meaningless verdict instead of failing.
BAD_CONFIGS = {}


def read_config(cfg):
    try:
        with open(os.path.join(ROOT, cfg)) as fh:
            return json.load(fh)
    except json.JSONDecodeError as e:
        if cfg not in BAD_CONFIGS:
            BAD_CONFIGS[cfg] = str(e)
            print(color("red", f"  malformed config, ignored: {cfg} ({e})"),
                  file=sys.stderr)
        return {}
    except OSError:
        return {}


def norm_result(res):
    """Normalise the analyzer verdict to TRUE/UNKNOWN, tolerating the 'UKNOWN'
    typo, casing, and a boolean 0/1 (or false/true) encoding."""
    r = str(res).strip().upper()
    if r in ("UKNOWN", "UNKNOWN", "0", "FALSE"):
        return "UNKNOWN"
    if r in ("TRUE", "1"):
        return "TRUE"
    return r or "-"


def count_leaves(tree):
    """Return (defined, total) leaves of the analyzer's decision tree. A leaf is
    "defined" when its value is not 'bottom'; the defined leaves are exactly the
    partitions of the inferred sufficient precondition, so their count is the
    number of sufficient conditions found."""
    if not isinstance(tree, dict):
        return (0, 0)
    if "Leaf" in tree:
        return (0 if str(tree["Leaf"]).strip().lower() == "bottom" else 1, 1)
    node = tree.get("Node")
    if isinstance(node, dict):
        dl = tl = 0
        for side in ("left", "right"):
            d, t = count_leaves(node.get(side))
            dl += d
            tl += t
        return (dl, tl)
    return (0, 0)


def parse_log_result(log):
    """Extract 'Final Analysis Result: <verdict>' from the analyzer output."""
    m = re.search(r"Final Analysis Result:\s*([A-Za-z()]+)", log)
    return norm_result(m.group(1)) if m else None


# --------------------------------------------------------------------------- #
# Running
# --------------------------------------------------------------------------- #

# Analyzer options the *reporting* front-end adds (a richer analysis for the
# paper's tables). They are NOT part of the regression invocation: the analyzer
# encodes its options in the output filename, so adding them here would produce
# `foo.c-domainpolyhedra-ordinals3-refine.json` where logs/ holds
# `foo.c-domainpolyhedra.json`, and nothing would ever match the baselines.
# The two front-ends differ on this on purpose -- hence the parameter.
REPORT_FLAGS = ["-domain", "polyhedra", "-refine", "-ordinals", "3",
                "-joinbwd", "7"]


def build_cmd(executable, group, cfile, cfg, out, extra=(), force=()):
    """Assemble the analyzer invocation.

    Option ORDER encodes precedence, and the two hooks differ by it:
      * `extra`  goes BEFORE -config, so the test's own config can override it
                 (defaults, e.g. REPORT_FLAGS' -domain polyhedra);
      * `force`  goes AFTER, so it wins over the test config -- what an ablation
                 needs when imposing the same knob on every test
                 (e.g. -max-partitions 4).
    """
    cmd = [executable, cfile] + list(extra) + ["-config", cfg]
    conf = read_config(cfg)
    # Pick the analysis flag from the config's declared analysis; fall back to
    # the folder/group mode only when the config does not specify one.
    analysis = conf.get("analysis")
    flags = ANALYSIS_FLAGS.get(analysis) if analysis in ANALYSIS_FLAGS \
        else GROUP_MODES.get(group, [])
    if flags:
        cmd += flags + [conf.get("property", "")]
    cmd += list(force)
    cmd += ["-json_output", out + os.sep]
    return cmd


def task_dir(out, cfg, layout):
    """Where a single run writes its report.

    "isolated" gives each (c-file, config) pair its own subdirectory: several
    configs may target the same .c and the analyzer names its JSON after the .c
    only, so a shared directory would make those runs overwrite each other.

    "flat" writes straight into `out`, reproducing the layout of the logs/
    baselines (which predate the isolated one) so function-diff can match paths.
    """
    if layout == "flat":
        return out
    return os.path.join(out, os.path.splitext(cfg)[0].replace(os.sep, "__"))


def run_one(executable, group, folder, cfile, cfg, out, timeout,
            layout="isolated", extra=(), force=()):
    # A test may pin its own budget: without it the global -t has to be set for
    # the slowest benchmark, which slows every run down.
    timeout = read_config(cfg).get("timeout", timeout)
    task_out = task_dir(out, cfg, layout)
    # The analyzer's own mkdir does not create nested paths: pre-create the
    # destination directory so the JSON can be written.
    os.makedirs(os.path.join(task_out, os.path.dirname(cfile)), exist_ok=True)
    cmd = build_cmd(executable, group, cfile, cfg, task_out, extra, force)
    status, rc = "OK", 0
    t0 = time.perf_counter()
    try:
        p = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True,
                           timeout=timeout)
        rc, log = p.returncode, p.stdout + p.stderr
        if rc != 0:
            status = "FAIL"
    except subprocess.TimeoutExpired:
        status, rc, log = "TO", 124, "TIMEOUT\n"
    wall = time.perf_counter() - t0  # measured wall-clock; reliable across paths

    conf_in = read_config(cfg)
    rec = {
        "group": group, "folder": folder, "file": cfile, "config": cfg,
        # Identity of this run: a config may share its .c with sibling configs,
        # so reports key off the config (name = label, key = unique filename).
        "name": os.path.splitext(os.path.basename(cfg))[0],
        "key": os.path.splitext(cfg)[0].replace(os.sep, "__")
        + "__" + os.path.splitext(cfile)[0].replace(os.sep, "__"),
        "property": conf_in.get("property", "termination"),
        "domain": conf_in.get("domain", "boxes"),
        # expected verdict declared in the config (native benchmarks), if any.
        "expected": conf_in.get("expected", "-"),
        # players (agents) of the benchmark, declared in the config.
        "players": conf_in.get("players", []),
        "result": "-", "time": round(wall, 3), "analyzer_time": "-",
        # number of defined leaves of the decision tree (the sufficient
        # precondition partitions) and total number of leaves.
        "suff": 0, "leaves": 0,
        "vulnerability": "-", "status": status, "rc": rc, "log": log,
        "tree": None, "conf": {},
    }

    # The analyzer chooses the output filename itself (and may override the
    # domain, e.g. CTL is forced to polyhedra), so locate the JSON by globbing
    # rather than guessing the name.
    produced = sorted(glob.glob(os.path.join(task_out, cfile + "-domain*.json")),
                      key=os.path.getmtime)
    log_result = parse_log_result(log)

    if produced:
        try:
            with open(produced[-1]) as fh:
                data = json.load(fh)
            conf = data.get("Config", {})
            rec["conf"] = conf
            rec["tree"] = data.get("tree")
            rec["suff"], rec["leaves"] = count_leaves(rec["tree"])
            rec["result"] = norm_result(conf.get("result", "-"))
            rec["analyzer_time"] = conf.get("time", "-")
            rec["domain"] = conf.get("domain", rec["domain"])
            rec["property"] = conf.get("property", rec["property"])
            rec["vulnerability"] = (
                data["vulnerability"] if isinstance(data.get("vulnerability"), str)
                else json.dumps(data.get("vulnerability")))
            if status == "OK":
                rec["status"] = rec["result"]  # TRUE / UNKNOWN
        except (OSError, json.JSONDecodeError):
            rec["status"] = "FAIL"
    elif log_result and status == "OK":
        # Analysis reached a verdict but the JSON write failed: trust the log.
        rec["result"] = rec["status"] = log_result
    elif status == "OK":
        rec["status"] = "FAIL"  # exited 0 but produced no result at all
    return rec


def run_all(executable, bench, out, timeout, jobs, layout="isolated",
            progress=None, extra=(), force=()):
    """Run every discovered benchmark; return the list of records."""
    records = []
    with cf.ThreadPoolExecutor(max_workers=jobs) as ex:
        futs = [ex.submit(run_one, executable, g, fo, c, cfg, out, timeout,
                          layout, extra, force)
                for (g, fo, c, cfg) in bench]
        for fut in cf.as_completed(futs):
            rec = fut.result()
            records.append(rec)
            if progress:
                progress(rec)
    return records


# --------------------------------------------------------------------------- #
# Expected results, declared in each test's own config
# --------------------------------------------------------------------------- #
#
#   "expected": "TRUE"                      legacy form == {"result": "TRUE"}
#   "expected": {"result": "TRUE", "suff": 3, "leaves": 7, "time": 1.23}
#   "expected": {"status": "FAIL", "reason": "frontend: undeclared 'true'"}
#
# Every field is optional: only what is pinned gets checked. Tolerances are
# global (defaults below, overridable on the command line) rather than per
# test -- suff/leaves are deterministic for a given binary, so there is no
# per-test noise to absorb, and when a knob like -max-partitions moves them it
# moves them for the whole suite at once.

# field -> how to read it off a run record
EXPECT_FIELDS = {
    "result": lambda r: norm_result(r["result"]),
    # defined leaves of the decision tree = the partitions of the inferred
    # sufficient precondition, i.e. how many preconditions were found
    "suff": lambda r: r["suff"],
    "leaves": lambda r: r["leaves"],
    # Measured wall-clock FIRST: the analyzer only reports whole seconds
    # ("time": "1"), so its own figure is quantised to 1s and carries almost no
    # signal -- a whole 66-test suite summed to exactly 65.0s on both sides of
    # an ablation. Wall-clock is noisier (it includes startup, and inflates
    # under -j) but it is the only field with resolution.
    "time": lambda r: _num(r.get("time"), r.get("analyzer_time")),
    # OK / FAIL / TO -- pinning FAIL declares a *known* failure
    "status": lambda r: r["status"],
}
# fields `bless` writes back by default (status is opt-in: it is a statement
# about a known bug, not a measurement)
BLESS_FIELDS = ("result", "suff", "leaves", "time")

# Free-form documentation carried alongside the pinned values: never compared,
# but preserved by `bless` so promoting a run does not silently erase why a
# result was accepted. `issue` is what keeps a knowingly-degraded verdict
# traceable once its baseline has been promoted and CI is green again.
DOC_FIELDS = ("reason", "issue", "pending")

DEFAULT_TOL = {
    "suff": 0,       # absolute
    "leaves": 0,     # absolute
    "time": 3.0,     # FACTOR, and never fatal unless --strict-time: wall-clock
                     # depends on the machine and the load
}


def _num(*vals):
    for v in vals:
        try:
            return round(float(v), 3)
        except (TypeError, ValueError):
            continue
    return None


def normalize_expected(v):
    """Config "expected" -> dict of pinned fields, documentation included."""
    if isinstance(v, str):
        v = v.strip()
        return {"result": norm_result(v)} if v and v != "-" else {}
    if isinstance(v, dict):
        return {k: val for k, val in v.items()
                if k in EXPECT_FIELDS or k in DOC_FIELDS}
    return {}


def observed(rec, fields=BLESS_FIELDS):
    out = {}
    for k in fields:
        val = EXPECT_FIELDS[k](rec)
        if val is not None:
            out[k] = val
    return out


def expected_diff(rec, tol=None):
    """(hard, soft) mismatches against the config's expected.

    `hard` fails the run; `soft` is timing drift, reported only.
    """
    tol = {**DEFAULT_TOL, **(tol or {})}
    exp = normalize_expected(read_config(rec["config"]).get("expected"))
    hard, soft = [], []
    for k, want in exp.items():
        if k in DOC_FIELDS:
            continue
        got = EXPECT_FIELDS[k](rec)
        if k == "time":
            w, g = _num(want), _num(got)
            f = tol["time"]
            if w and g and f and (g > w * f or w > g * f):
                soft.append((k, want, got))
        elif k in ("suff", "leaves"):
            try:
                if abs(int(got) - int(want)) > int(tol[k]):
                    hard.append((k, want, got))
            except (TypeError, ValueError):
                hard.append((k, want, got))
        elif k == "result":
            if norm_result(str(want)) != norm_result(str(got)):
                hard.append((k, want, got))
        elif str(want) != str(got):
            hard.append((k, want, got))
    return hard, soft


def shared_config(cfg):
    """True for a matrix root property config, shared by every .c of a subtree
    (tests/atl/resilience/*.json: 6 configs for 37k sources).

    Such a config cannot carry a per-test `expected` -- one file would have to
    hold thousands of different results -- so `bless` skips it. Revisit with a
    sidecar keyed by .c path if per-test expectations are ever needed there.
    """
    d = os.path.dirname(cfg)
    return (os.path.basename(d) in MATRIX_FOLDERS
            or os.path.isfile(os.path.join(ROOT, d, RESILIENCE_SIGNATURE)))


# --------------------------------------------------------------------------- #
# Coverage
# --------------------------------------------------------------------------- #

def relset(root):
    """Set of *.json report paths under `root`, relative to `root`."""
    out = set()
    for dp, _, files in os.walk(root):
        for f in files:
            if f.endswith(".json"):
                out.add(os.path.relpath(os.path.join(dp, f), root))
    return out


def coverage(ref, out):
    """Baselines in `ref` that this run did not reproduce.

    Computed from the reference side on purpose: function-diff compares the
    intersection of report paths, so anything the run failed to produce (crash,
    timeout, or a group that discovery never visited) silently drops out of the
    comparison instead of failing it.
    """
    return sorted(relset(ref) - relset(out))


def resolve_exec(path):
    p = path if os.path.isabs(path) else os.path.join(ROOT, path)
    if not (os.path.isfile(p) and os.access(p, os.X_OK)):
        sys.exit(color("red", f"error: analyzer '{p}' not found or not executable"))
    return p


# --------------------------------------------------------------------------- #
# CLI
# --------------------------------------------------------------------------- #

SUMMARY_FIELDS = ("group", "folder", "file", "config", "name", "domain",
                  "property", "expected", "result", "status", "time",
                  "analyzer_time", "suff", "leaves")


def git_rev():
    """HEAD, suffixed -dirty when the tree has uncommitted changes.

    Without the suffix a run.json would claim a revision that does not describe
    the binary that produced it -- and a baseline blessed from a dirty tree
    would correspond to no commit at all.
    """
    try:
        rev = subprocess.run(["git", "rev-parse", "--short", "HEAD"],
                             cwd=ROOT, capture_output=True, text=True,
                             timeout=5).stdout.strip() or "?"
        dirty = subprocess.run(["git", "status", "--porcelain", "--untracked-files=no"],
                               cwd=ROOT, capture_output=True, text=True,
                               timeout=10).stdout.strip()
        return rev + ("-dirty" if dirty else "")
    except (OSError, subprocess.SubprocessError):
        return "?"


def write_summary(out, records, executable, force, args):
    """Machine-readable summary: verdicts, precision and times, no trees/logs.

    Carries a `meta` header recording HOW the run was produced (forced options,
    binary, git revision). `compare` reads it to label both sides and to warn
    when two runs differ by more than the knob under study -- comparing a run
    made with -report-flags against one without would otherwise look like a
    precision result.

    Written as a SIBLING of the output tree, never inside it: function-diff
    globs every *.json under the run directory and parses each as a report, so
    a summary file sitting in there makes it crash.
    """
    summary = out.rstrip(os.sep) + ".run.json"
    doc = {
        "meta": {
            "date": time.strftime("%Y-%m-%dT%H:%M:%S"),
            "git": git_rev(),
            "exec": os.path.relpath(executable, ROOT),
            "force": list(force),
            "report_flags": REPORT_FLAGS if getattr(args, "report_flags", False) else [],
            "layout": getattr(args, "layout", "isolated"),
            "timeout": getattr(args, "timeout", None),
            "out": os.path.relpath(out, ROOT),
        },
        "records": [{k: r[k] for k in SUMMARY_FIELDS}
                    for r in sorted(records, key=lambda r: r["key"])],
    }
    with open(summary, "w") as fh:
        json.dump(doc, fh, indent=1)
    return summary


def load_summary(path):
    with open(path if os.path.isabs(path) else os.path.join(ROOT, path)) as fh:
        doc = json.load(fh)
    # tolerate the first format (a bare list, no meta)
    if isinstance(doc, list):
        return {}, doc
    return doc.get("meta", {}), doc.get("records", [])


def cmd_run(args):
    executable = resolve_exec(args.exec)
    out = os.path.join(ROOT, args.out)
    tests_dir = os.path.join(ROOT, args.tests)
    groups = ([g for g in args.groups.split(",") if g] if args.groups
              else default_groups(tests_dir))

    bench = list(discover(tests_dir, groups, args.filter, args.short))

    # In regression mode, replay only what the reference actually baselines.
    # tests/ holds far more than logs/ does -- the resilience matrix alone
    # crosses every .c of a subtree with every root property, which runs for
    # hours -- and a benchmark with no baseline has nothing to be compared
    # against anyway. The coverage check below still scans the WHOLE reference,
    # so a baseline that discovery never reaches is reported rather than hidden.
    if args.cover and not args.all:
        baselines = relset(os.path.join(ROOT, args.cover))
        def has_baseline(cfile):
            return any(b.startswith(cfile + "-domain") for b in baselines)
        bench = [t for t in bench if has_baseline(t[2])]

    if not bench:
        sys.exit(color("yel", "no benchmarks matched."))

    os.makedirs(out, exist_ok=True)
    print(color("bld", f"== running {len(bench)} benchmark(s) =="))
    print(f"  exec={executable}\n  out={out}  groups={','.join(groups)}")
    print(f"  timeout={args.timeout}s  jobs={args.jobs}  layout={args.layout}\n")

    tally = {"ok": 0, "to": 0, "err": 0, "known": 0}

    def pending_of(rec):
        """Free-text note when a test's degraded verdict is declared pending.

        A pending test still has its `result` checked: the point is to accept a
        known-bad verdict without blocking CI, while being told the day it
        improves. It is not a way to stop looking at the test.
        """
        return normalize_expected(
            read_config(rec["config"]).get("expected")).get("pending")

    def declared_failure(rec):
        """The config pinned this exact failure status: a KNOWN bug.

        It still shows in the output -- the point is to keep it visible, not to
        hide it -- but it must not fail the run, otherwise declaring a known
        failure would leave the suite red for ever and the whole mechanism
        would be pointless. A test that stops failing IS reported, as a
        mismatch against its pinned status.
        """
        want = normalize_expected(read_config(rec["config"]).get("expected"))
        return want.get("status") == rec["status"]

    def progress(rec):
        if rec["status"] in ("TO", "FAIL"):
            known = declared_failure(rec)
            tag, col = ("TO", "yel") if rec["status"] == "TO" else ("ERR", "red")
            if known:
                tally["known"] += 1
                print(color("blu", f"  {tag}* {rec['file']} (attendu)"))
            else:
                tally["to" if rec["status"] == "TO" else "err"] += 1
                print(color(col, f"  {tag}  {rec['file']} (rc={rec['rc']})"))
        else:
            tally["ok"] += 1

    force = shlex.split(args.force) if args.force else ()
    records = run_all(executable, bench, out, args.timeout, args.jobs,
                      args.layout, progress,
                      REPORT_FLAGS if args.report_flags else (), force)
    print(f"\n  ran: {color('grn', tally['ok'])} ok, "
          f"{color('yel', tally['to'])} timeout, {color('red', tally['err'])} failed"
          + (f", {color('blu', tally['known'])} known-failing"
             if tally["known"] else ""))

    summary = write_summary(out, records, executable, force, args)
    print(f"  summary: {os.path.relpath(summary, ROOT)}")

    rc = 1 if tally["err"] or tally["to"] else 0

    if args.cover:
        ref = os.path.join(ROOT, args.cover)
        missing = coverage(ref, out)
        # A test declared as a known failure produces no report, so its
        # baseline can never be reproduced. Counting it here would keep the
        # suite red for ever and defeat the declaration -- but the baseline is
        # deliberately kept on disk (see `promote`) so the day the bug is fixed
        # there is still something to compare against.
        declared = {r["file"] for r in records if declared_failure(r)}
        expected_missing = [m for m in missing
                            if any(m.startswith(c + "-domain") for c in declared)]
        missing = [m for m in missing if m not in set(expected_missing)]
        if expected_missing:
            print(color("blu", f"\n  {len(expected_missing)} baseline(s) not "
                               f"reproduced by a KNOWN-failing test (ignored)"))
        if missing:
            print(color("red", f"\n  {len(missing)} baseline(s) NOT reproduced "
                               f"by this run:"))
            for m in missing[:20]:
                print(color("red", f"    {m}"))
            if len(missing) > 20:
                print(color("red", f"    ... and {len(missing) - 20} more"))
            rc = 1
        else:
            print(color("grn", f"\n  coverage OK: every baseline in "
                               f"{args.cover} was reproduced"))

    pend = [r for r in records if pending_of(r)]
    if pend:
        print(color("blu", f"\n  {len(pend)} test(s) PENDING (verdict dégradé, "
                           f"déclaré, non bloquant):"))
        for r in pend:
            exp = normalize_expected(read_config(r["config"]).get("expected"))
            ref = f" [{exp['issue']}]" if exp.get("issue") else ""
            print(color("blu", f"    {r['file']}{ref}: {pending_of(r)}"))

    if BAD_CONFIGS:
        print(color("red", f"\n  {len(BAD_CONFIGS)} config(s) illisible(s) — "
                           f"le test a tourné SANS propriété ni précondition:"))
        for cfg, err in BAD_CONFIGS.items():
            print(color("red", f"    {cfg}: {err}"))
        rc = 1

    # Everything the configs pinned in their "expected".
    tol = {"suff": args.tol_suff, "leaves": args.tol_leaves,
           "time": args.tol_time}
    hard_all, soft_all = [], []
    for r in records:
        hard, soft = expected_diff(r, tol)
        if hard:
            hard_all.append((r, hard))
        if soft:
            soft_all.append((r, soft))

    if hard_all:
        print(color("red", f"\n  {len(hard_all)} test(s) differ from their "
                           f'config\'s "expected":'))
        for r, hard in hard_all[:20]:
            for k, want, got in hard:
                print(color("red", f"    {r['file']} [{r['name']}] "
                                   f"{k}: expected {want}, got {got}"))
        if len(hard_all) > 20:
            print(color("red", f"    ... and {len(hard_all) - 20} more"))
        rc = 1
    if soft_all:
        print(color("yel", f"\n  {len(soft_all)} test(s) off on timing "
                           f"(factor >{tol['time']}, not fatal):"))
        for r, soft in soft_all[:10]:
            for k, want, got in soft:
                print(color("yel", f"    {r['file']} [{r['name']}] "
                                   f"{k}: expected {want}s, got {got}s"))
        if args.strict_time:
            rc = 1

    return rc


def cmd_bless(args):
    """Promote a run's observed values into each test config's "expected"."""
    _, records = load_summary(args.run)
    # Same reason as promote's filter: accepting a run's values is a per-test
    # judgement, so blessing has to be scopable to the tests just reviewed.
    if args.filter:
        pat = re.compile(args.filter)
        records = [r for r in records
                   if pat.search(r["file"]) or pat.search(r["config"])]
    fields = tuple(f for f in args.fields.split(",") if f in EXPECT_FIELDS)
    if not fields:
        sys.exit(color("red", f"no valid field in --fields (known: "
                              f"{','.join(EXPECT_FIELDS)})"))

    changed = skipped_shared = skipped_bad = 0
    by_cfg = {}
    for r in records:
        # Never freeze a crash or a timeout as the expected outcome: a failing
        # run carries no measurement, and blessing it would make the bug the
        # reference. Declare those by hand with {"status": "FAIL", "reason": ...}.
        if r["status"] in ("FAIL", "TO"):
            skipped_bad += 1
            continue
        if shared_config(r["config"]):
            skipped_shared += 1
            continue
        # One config, one expectation: if several .c share a config outside the
        # matrix, the last one would silently win -- drop them all instead.
        by_cfg.setdefault(r["config"], []).append(r)

    for cfg, recs in sorted(by_cfg.items()):
        if len(recs) > 1:
            skipped_shared += len(recs)
            continue
        rec = recs[0]
        path = os.path.join(ROOT, cfg)
        try:
            with open(path) as fh:
                conf = json.load(fh)
        except (OSError, json.JSONDecodeError) as e:
            print(color("red", f"  skip {cfg}: {e}"))
            continue
        old = normalize_expected(conf.get("expected"))
        new = {**old, **observed(rec, fields)}
        if new == old:
            continue
        changed += 1
        shown = {k: v for k, v in new.items() if k not in old or old[k] != v}
        print(f"  {cfg}: {shown}")
        if not args.dry_run:
            conf["expected"] = new
            with open(path, "w") as fh:
                json.dump(conf, fh, indent=4, ensure_ascii=False)
                fh.write("\n")

    verb = "would update" if args.dry_run else "updated"
    print(color("bld", f"\n  {verb} {changed} config(s)"))
    if skipped_bad:
        print(color("yel", f"  skipped {skipped_bad} failing/timed-out test(s) "
                           f"-- declare those by hand as "
                           f'{{"status": "FAIL", "reason": "..."}}'))
    if skipped_shared:
        print(color("yel", f"  skipped {skipped_shared} test(s) on a shared "
                           f"config (tests/atl/resilience/*.json and other "
                           f"matrix roots: one config, thousands of sources)"))
    return 0


def cmd_promote(args):
    """Copy a run's reports into the reference directory (logs/).

    The counterpart of `bless` on the OTHER reference. There are two, and they
    answer different questions:

      * logs/      full reports, decision trees included, compared by
                   function-diff -- "did anything change at all?"
      * expected   a few scalars pinned in each test's config, checked by
                   `run` -- "does this test still prove what it should?"

    Accepting a new behaviour means updating BOTH: `promote` for logs/, `bless`
    for the configs. Doing only the second leaves function-diff red for ever.
    """
    import shutil
    out = os.path.join(ROOT, args.run)
    ref = os.path.join(ROOT, args.ref)
    if not os.path.isdir(out):
        sys.exit(color("red", f"run directory not found: {out}"))

    produced, baseline = relset(out), relset(ref)
    # Accepting a new behaviour is a per-test judgement, so promoting is too:
    # without a filter the only option is to accept every changed report at
    # once, which is exactly what you do not want when reviewing regressions.
    if args.filter:
        pat = re.compile(args.filter)
        produced = {p for p in produced if pat.search(p)}
    added = sorted(produced - baseline)
    updated = sorted(p for p in produced & baseline
                     if open(os.path.join(out, p), "rb").read()
                     != open(os.path.join(ref, p), "rb").read())
    # Baselines the run did not reproduce: promoting must NOT delete them --
    # a crashed test would silently erase its own reference, and the coverage
    # check would then pass because there is nothing left to reproduce.
    scope = ({b for b in baseline if re.search(args.filter, b)}
             if args.filter else baseline)
    missing = sorted(scope - produced)

    for p in added:
        print(color("grn", f"  + {p}"))
    for p in updated:
        print(color("yel", f"  ~ {p}"))
    if missing:
        print(color("red", f"\n  {len(missing)} baseline(s) not reproduced by "
                           f"this run -- KEPT, not deleted:"))
        for p in missing[:10]:
            print(color("red", f"    {p}"))
        if len(missing) > 10:
            print(color("red", f"    ... and {len(missing) - 10} more"))

    if not args.dry_run:
        for p in added + updated:
            dst = os.path.join(ref, p)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy2(os.path.join(out, p), dst)

    verb = "would promote" if args.dry_run else "promoted"
    print(color("bld", f"\n  {verb} {len(added)} new + {len(updated)} changed "
                       f"report(s) into {args.ref}"))
    if not args.dry_run:
        print("  n'oublie pas `bless` pour les `expected` des configs, et "
              "commite logs/ avec le code qui produit ces verdicts.")
    return 0


def _bucket(r):
    s = r["status"]
    return s if s in ("FAIL", "TO") else norm_result(r["result"])


def cmd_compare(args):
    """Put two runs side by side: what B costs and buys against A."""
    meta_a, ra = load_summary(args.a)
    meta_b, rb = load_summary(args.b)
    A = {r["key"] if "key" in r else (r["config"], r["file"]): r for r in ra}
    B = {r["key"] if "key" in r else (r["config"], r["file"]): r for r in rb}
    common = sorted(set(A) & set(B))

    print(color("bld", f"A={args.a}  B={args.b}"))
    for tag, m in (("A", meta_a), ("B", meta_b)):
        if m:
            print(f"  {tag}: git={m.get('git','?')} force={' '.join(m.get('force') or []) or '-'} "
                  f"report_flags={'yes' if m.get('report_flags') else 'no'}")
    # Comparing runs that differ by more than the knob under study turns a
    # setup difference into what looks like a precision result.
    for k in ("report_flags", "layout"):
        if meta_a and meta_b and meta_a.get(k) != meta_b.get(k):
            print(color("yel", f"  warning: A and B differ on {k} -- "
                               f"this is not a like-for-like comparison"))
    print(f"  {len(common)} commun(s), {len(set(A)-set(B))} seulement dans A, "
          f"{len(set(B)-set(A))} seulement dans B\n")
    if not common:
        return 1

    buckets = ("TRUE", "UNKNOWN", "FAIL", "TO")
    ca = {b: sum(1 for k in common if _bucket(A[k]) == b) for b in buckets}
    cb = {b: sum(1 for k in common if _bucket(B[k]) == b) for b in buckets}
    print(color("bld", "verdicts"))
    print(f"  {'':10}{'A':>6}{'B':>6}{'delta':>8}")
    for b in buckets:
        d = cb[b] - ca[b]
        print(f"  {b:10}{ca[b]:>6}{cb[b]:>6}{d:>+8}")

    lost = [k for k in common if _bucket(A[k]) == "TRUE" and _bucket(B[k]) != "TRUE"]
    gained = [k for k in common if _bucket(A[k]) != "TRUE" and _bucket(B[k]) == "TRUE"]
    for label, lst, col in (("perdus (A prouve, B non)", lost, "red"),
                            ("gagnés (B prouve, A non)", gained, "grn")):
        print(color(col, f"\n  {len(lst)} {label}"))
        for k in lst[:args.list]:
            print(f"    {A[k]['file']} [{A[k]['name']}] "
                  f"{_bucket(A[k])} -> {_bucket(B[k])}")
        if len(lst) > args.list:
            print(f"    ... et {len(lst) - args.list} autres")

    # Precision and time only over what BOTH runs decided: a test that crashed
    # on one side has no measurement, and letting it drop out silently would
    # make the faster-but-broken side look better.
    decided = [k for k in common
               if _bucket(A[k]) in ("TRUE", "UNKNOWN")
               and _bucket(B[k]) in ("TRUE", "UNKNOWN")]
    def tot(d, k, f):
        return sum((_num(d[x].get(f)) or 0) for x in k)
    print(color("bld", f"\nprécision ({len(decided)} décidés des deux côtés)"))
    for f in ("suff", "leaves"):
        sa, sb = tot(A, decided, f), tot(B, decided, f)
        pct = f"  ({(sb - sa) / sa * 100:+.0f}%)" if sa else ""
        print(f"  {f:8}{sa:>8.0f} -> {sb:<8.0f}{sb - sa:>+8.0f}{pct}")
    print(color("bld", "\ntemps"))
    ta = sum((_num(A[k].get("time"), A[k].get("analyzer_time")) or 0) for k in decided)
    tb = sum((_num(B[k].get("time"), B[k].get("analyzer_time")) or 0) for k in decided)
    fac = f"  (x{tb / ta:.2f})" if ta else ""
    print(f"  total   {ta:.1f}s -> {tb:.1f}s{fac}")

    if args.csv:
        import csv as _csv
        new = not os.path.exists(args.csv)
        with open(args.csv, "a", newline="") as fh:
            w = _csv.writer(fh)
            if new:
                w.writerow(["A", "B", "force_B", "common", "true_A", "true_B",
                            "lost", "gained", "suff_A", "suff_B",
                            "leaves_A", "leaves_B", "time_A", "time_B"])
            w.writerow([args.a, args.b, " ".join(meta_b.get("force") or []),
                        len(common), ca["TRUE"], cb["TRUE"], len(lost), len(gained),
                        tot(A, decided, "suff"), tot(B, decided, "suff"),
                        tot(A, decided, "leaves"), tot(B, decided, "leaves"),
                        round(ta, 1), round(tb, 1)])
        print(f"\n  ligne agrégée ajoutée à {args.csv}")

    print(color("bld", f"\nnet : {len(lost)} régression(s), {len(gained)} amélioration(s)"))
    if args.gate == "none":
        return 0
    if args.gate == "suff":
        return 1 if tot(B, decided, "suff") < tot(A, decided, "suff") else 0
    return 1 if lost else 0


def main():
    ap = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    r = sub.add_parser("run", help="run benchmarks (optionally checking coverage)")
    r.add_argument("-e", "--exec", default="./main.exe", help="analyzer executable")
    r.add_argument("-o", "--out", default="regression_out", help="output directory")
    r.add_argument("--tests", default="tests", help="benchmarks root")
    r.add_argument("-g", "--groups", default="",
                   help="comma-separated groups (default: every subdir of tests/)")
    r.add_argument("-t", "--timeout", type=int, default=60, help="per-test timeout (s)")
    r.add_argument("-j", "--jobs", type=int, default=os.cpu_count() or 1,
                   help="parallel jobs")
    r.add_argument("-f", "--filter", default="",
                   help="only run tests whose .c path matches this regex")
    r.add_argument("--short", action="store_true", help="prune the large SV-COMP subtrees")
    r.add_argument("--layout", choices=("isolated", "flat"), default="isolated",
                   help="report layout; use 'flat' to compare against logs/")
    r.add_argument("--cover", default="",
                   help="reference directory whose baselines must all be reproduced; "
                        "also restricts the run to baselined benchmarks")
    r.add_argument("--all", action="store_true",
                   help="with --cover, run every discovered benchmark, not just "
                        "the baselined ones")
    r.add_argument("--report-flags", action="store_true",
                   help="add the reporting analysis options (%s); changes the "
                        "analysis AND the report filenames, so it does not "
                        "compare against logs/" % " ".join(REPORT_FLAGS))
    r.add_argument("--force", default="",
                   help="analyzer options forced on every test, applied AFTER "
                        "-config so they override the test's own config "
                        "(e.g. --force '-max-partitions 4'). This is how an "
                        "ablation is expressed: it is a property of the run, "
                        "not of any test.")
    r.add_argument("--tol-suff", type=int, default=DEFAULT_TOL["suff"],
                   help="allowed absolute drift on the pinned `suff`")
    r.add_argument("--tol-leaves", type=int, default=DEFAULT_TOL["leaves"],
                   help="allowed absolute drift on the pinned `leaves`")
    r.add_argument("--tol-time", type=float, default=DEFAULT_TOL["time"],
                   help="allowed FACTOR on the pinned `time` (0 disables)")
    r.add_argument("--strict-time", action="store_true",
                   help="make a timing drift fail the run (off by default: "
                        "wall-clock depends on the machine)")
    r.set_defaults(func=cmd_run)

    c = sub.add_parser("cover", help="check coverage of an existing run directory")
    c.add_argument("ref", help="reference (baseline) directory")
    c.add_argument("out", help="run directory to check")
    c.set_defaults(func=lambda a: _cmd_cover(a))

    b = sub.add_parser("bless",
                       help="promote a run's values into each config's \"expected\"")
    b.add_argument("run", help="the run summary to promote (<out>.run.json)")
    b.add_argument("--fields", default=",".join(BLESS_FIELDS),
                   help="comma-separated fields to write (default: %(default)s)")
    b.add_argument("-f", "--filter", default="",
                   help="only bless tests whose path matches this regex")
    b.add_argument("-n", "--dry-run", action="store_true",
                   help="list what would change without writing")
    b.set_defaults(func=cmd_bless)

    pr = sub.add_parser("promote",
                        help="copy a run's reports into the reference (logs/)")
    pr.add_argument("run", help="run directory produced with --layout flat")
    pr.add_argument("--ref", default="logs", help="reference directory")
    pr.add_argument("-f", "--filter", default="",
                    help="only promote reports whose path matches this regex "
                         "(accepting a regression is a per-test decision)")
    pr.add_argument("-n", "--dry-run", action="store_true",
                    help="list what would change without copying")
    pr.set_defaults(func=cmd_promote)

    p = sub.add_parser("compare", help="put two runs side by side (ablations)")
    p.add_argument("a", help="baseline run summary (<out>.run.json)")
    p.add_argument("b", help="run summary to compare against A")
    p.add_argument("--list", type=int, default=15,
                   help="how many moved tests to list per direction")
    p.add_argument("--gate", choices=("verdicts", "suff", "none"),
                   default="verdicts",
                   help="what drives the exit code (default: %(default)s)")
    p.add_argument("--csv", default="",
                   help="append the aggregate row to this CSV (one row per "
                        "ablation point: the k-sweep table)")
    p.set_defaults(func=cmd_compare)

    args = ap.parse_args()
    sys.exit(args.func(args))


def _cmd_cover(args):
    missing = coverage(os.path.join(ROOT, args.ref), os.path.join(ROOT, args.out))
    if missing:
        print(color("red", f"{len(missing)} baseline(s) not reproduced:"))
        for m in missing:
            print(f"  {m}")
        return 1
    print(color("grn", "coverage OK"))
    return 0


if __name__ == "__main__":
    main()
