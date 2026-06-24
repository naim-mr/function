#!/usr/bin/env python3
"""Regression runner for the FuncTion analyzer.

For every benchmark that ships a ``.c`` file together with its ``.json`` config
(see tests/<group>/), this replays the analysis -- using the same invocation as
script/logs.bash -- into a fresh output directory, then compares the produced
JSON summaries against the golden baselines in logs/ using script/function-diff.py.

Workflow:
  1. run   : tests/<group>/<name>.c + <name>.json  ->  <out>/tests/<group>/<name>.c-domain*.json
  2. cover : every baseline must have been reproduced (a crash/timeout produces
             no JSON, which function-diff would otherwise silently skip)
  3. diff  : script/function-diff.py <ref> <out> --regression [--ignore-time]

Examples:
  script/runregression.py                      # run all, regress against logs/
  script/runregression.py -f euclid -v         # single test, show the diff
  script/runregression.py --update             # refresh baselines from this run
"""

import argparse
import concurrent.futures as cf
import json
import os
import re
import shutil
import subprocess
import sys

# group (subdir of tests/) -> extra analyzer flags. The property, when needed,
# is read from the config and appended after the flag, mirroring logs.bash.
GROUP_MODES = {
    "termination": [],          # property/domain come from -config only
    "ctl": ["-ctl"],            # + property
    "resilience": ["-atl"],     # + property (ATL coalition, e.g. <r>G{...})
    "guarantee": ["-ctl"],
    "recurrence": ["-ctl"],
}

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
C = {"red": "\033[91m", "grn": "\033[92m", "yel": "\033[93m",
     "blu": "\033[94m", "bld": "\033[1m", "rst": "\033[0m"}


def color(tag, s):
    return f"{C[tag]}{s}{C['rst']}" if sys.stdout.isatty() else s


def discover(tests_dir, groups, flt):
    """Yield (group, cfile, cfg) for every benchmark with a config.

    cfile/cfg are returned relative to ROOT: the analyzer concatenates
    output_dir + filename, so a relative filename is required for the JSON to
    land under <out>/ and to match the relative baseline keys (tests/...).
    """
    pat = re.compile(flt) if flt else None
    for group in groups:
        gdir = os.path.join(tests_dir, group)
        if not os.path.isdir(gdir):
            continue
        for dirpath, _, files in os.walk(gdir):
            for f in sorted(files):
                if not f.endswith(".json"):
                    continue
                cfg_abs = os.path.join(dirpath, f)
                cfile_abs = cfg_abs[:-5] + ".c"
                if not os.path.isfile(cfile_abs):
                    continue
                cfile = os.path.relpath(cfile_abs, ROOT)
                cfg = os.path.relpath(cfg_abs, ROOT)
                if pat and not pat.search(cfile):
                    continue
                yield group, cfile, cfg


def build_cmd(executable, group, cfile, cfg, out):
    cmd = [executable, cfile, "-config", cfg]
    flags = GROUP_MODES.get(group, [])
    if flags:
        try:
            with open(cfg) as fh:
                prop = json.load(fh).get("property", "")
        except (OSError, json.JSONDecodeError):
            prop = ""
        cmd += flags + [prop]
    # output_dir is concatenated with the (relative) filename by the analyzer,
    # so it must end with a separator.
    cmd += ["-json_output", out + os.sep]
    return cmd


def run_one(executable, group, cfile, cfg, out, timeout):
    # The analyzer's own mkdir does not create nested paths: pre-create the
    # destination directory so the JSON can be written.
    os.makedirs(os.path.join(out, os.path.dirname(cfile)), exist_ok=True)
    cmd = build_cmd(executable, group, cfile, cfg, out)
    try:
        p = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True,
                           timeout=timeout)
        rc, log = p.returncode, p.stdout + p.stderr
    except subprocess.TimeoutExpired:
        rc, log = 124, "TIMEOUT\n"
    runlog = os.path.join(out, cfile + ".runlog")
    os.makedirs(os.path.dirname(runlog), exist_ok=True)
    with open(runlog, "w") as fh:
        fh.write(" ".join(cmd) + "\n\n" + log)
    return cfile, rc


def relset(root):
    """Set of *.json report paths under root, relative to root."""
    out = set()
    for dp, _, files in os.walk(root):
        for f in files:
            if f.endswith(".json"):
                out.add(os.path.relpath(os.path.join(dp, f), root))
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("-e", "--exec", default="./main.exe", help="analyzer executable")
    ap.add_argument("-o", "--out", default="regression_out", help="output directory for this run")
    ap.add_argument("-r", "--ref", default="logs", help="baseline directory")
    ap.add_argument("--tests", default="tests", help="benchmarks root")
    ap.add_argument("-g", "--groups", default=",".join(GROUP_MODES),
                    help="comma-separated test groups to run")
    ap.add_argument("-t", "--timeout", type=int, default=60, help="per-test timeout (s)")
    ap.add_argument("-j", "--jobs", type=int, default=os.cpu_count() or 1, help="parallel jobs")
    ap.add_argument("-f", "--filter", default="", help="only run tests whose .c path matches this regex")
    ap.add_argument("-u", "--update", action="store_true", help="refresh baselines from this run instead of comparing")
    ap.add_argument("--no-diff", action="store_true", help="run benchmarks but skip the function-diff step")
    ap.add_argument("--ignore-time", action="store_true", default=True, help="ignore analysis time in the diff (default)")
    ap.add_argument("--with-time", dest="ignore_time", action="store_false", help="take analysis time into account")
    ap.add_argument("-v", "--verbose", action="store_true", help="print full diff (not only regressions)")
    args = ap.parse_args()

    executable = args.exec if os.path.isabs(args.exec) else os.path.join(ROOT, args.exec)
    if not (os.path.isfile(executable) and os.access(executable, os.X_OK)):
        sys.exit(color("red", f"error: analyzer '{executable}' not found or not executable"))

    out = os.path.join(ROOT, args.out)
    ref = os.path.join(ROOT, args.ref)
    tests_dir = os.path.join(ROOT, args.tests)
    groups = [g for g in args.groups.split(",") if g]

    bench = list(discover(tests_dir, groups, args.filter))

    # In comparison mode only run benchmarks that actually have a baseline:
    # the rest carry no reference to diff against and would only add noise.
    baseline = relset(ref)

    def has_baseline(cfile):
        return any(b.startswith(cfile + "-domain") for b in baseline)

    if not args.update:
        bench = [t for t in bench if has_baseline(t[1])]

    if not bench:
        sys.exit(color("yel", "no benchmarks matched."))

    if os.path.isdir(out):
        shutil.rmtree(out)
    os.makedirs(out)

    print(color("bld", f"== running {len(bench)} benchmark(s) =="))
    print(f"  exec={executable}\n  out={out}  ref={ref}  timeout={args.timeout}s  jobs={args.jobs}\n")

    ok = to = crash = 0
    with cf.ThreadPoolExecutor(max_workers=args.jobs) as ex:
        futs = [ex.submit(run_one, executable, g, c, cfg, out, args.timeout)
                for (g, c, cfg) in bench]
        for fut in cf.as_completed(futs):
            cfile, rc = fut.result()
            if rc == 124:
                to += 1
                print(color("yel", f"  TO   {cfile}"))
            elif rc != 0:
                crash += 1
                print(color("red", f"  ERR  {cfile} (rc={rc})"))
            else:
                ok += 1
    print(f"\n  ran: {color('grn', ok)} ok, {color('yel', to)} timeout, {color('red', crash)} nonzero-exit")

    # Coverage: a baselined test that produced no JSON is a silent regression
    # for function-diff (it only compares the intersection of report paths).
    # Scope the check to the benchmarks we actually ran (honours --filter).
    produced = relset(out)
    run_sources = {c for (_, c, _) in bench}

    def baseline_source(relkey):
        m = re.match(r"(.*\.c)-domain", relkey)
        return m.group(1) if m else None

    expected = {b for b in baseline if baseline_source(b) in run_sources}
    missing = sorted(expected - produced)
    if missing:
        print(color("red", f"\n  {len(missing)} baselined test(s) produced NO output (crash/timeout):"))
        for m in missing:
            print(f"    {m}")

    if args.update:
        n = 0
        for rel in sorted(produced):
            dst = os.path.join(ref, rel)
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy(os.path.join(out, rel), dst)
            n += 1
        print(color("blu", f"\nbaselines updated: {n} file(s) written to {ref}"))
        return 0

    if args.no_diff:
        print(f"\noutputs in {out}; diff skipped (--no-diff).")
        return 1 if missing else 0

    # Delegate the actual comparison to the project's diff tool.
    diff_tool = os.path.join(ROOT, "script", "function-diff.py")
    cmd = [sys.executable, diff_tool, ref, out, "--regression"]
    if args.ignore_time:
        cmd.append("--ignore-time")
    if args.verbose:
        cmd.append("--verbose")
    print(color("bld", "\n== function-diff =="))
    rc = subprocess.run(cmd, cwd=ROOT).returncode

    regressed = rc != 0 or bool(missing)
    print(color("red", "\nREGRESSION DETECTED") if regressed
          else color("grn", "\nno regression"))
    return 1 if regressed else 0


if __name__ == "__main__":
    sys.exit(main())
