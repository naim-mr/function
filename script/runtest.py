#!/usr/bin/env python3
"""Run the FuncTion analyzer on every benchmark (.c + its .json config) and
produce human-readable reports in several formats.

Each test ships a ``.json`` config that specifies the domain and the property
(see tests/<group>/). This runs the analysis -- using the same invocation as
script/logs.bash -- reads the JSON summary the analyzer emits, and renders:

  * HTML  : an index table (results/index.html) plus one page per test with
            the source code and the analysis log -- nice to browse.
  * LaTeX : results/index.tex, a longtblr table ready to \\input in a paper.
  * CSV   : results/stats.csv, one row per test for further processing.

Pass --html / --latex / --csv to restrict output to those formats (default:
all three).

Examples:
  script/runtest.py                       # run all, emit html+latex+csv
  script/runtest.py --csv -f termination  # only the CSV, only termination tests
  script/runtest.py --html --latex -j 8
"""

import argparse
import concurrent.futures as cf
import datetime
import glob
import html
import json
import os
import re
import shutil
import subprocess
import sys
import time

# Discovery and running live in script/harness.py, shared with the regression
# path: keeping a second copy here is what let the two drift (the copy in the
# old runregression.py still keyed the analysis off the folder name, so
# tests/atl was never regression-tested). Rendering stays below.
from harness import (  # noqa: E402
    ROOT, GROUP_MODES, ANALYSIS_FLAGS,
    RESILIENCE_FOLDER, RESILIENCE_SIGNATURE, CTL_FOLDER, MATRIX_FOLDERS,
    SKIP_FOLDERS, SHORT_SKIP_FOLDERS,
    resilience_roots, discover, read_config, norm_result, count_leaves,
    parse_log_result, build_cmd, run_one, REPORT_FLAGS,
)

# The CTL->ATL lifting variants, in display order (column of the ctl matrix).
CTL_VARIANTS = ["base", "resilience", "resilience_reachability",
                "robust_reachability"]

# Resilience reporting is severity-based, not TRUE/UNKNOWN: a property holding
# (result TRUE) raises an alarm whose severity depends on the property.
RESILIENCE_CRITICAL = {"termination-exploitability", "robust_non-termination"}
RESILIENCE_LESS = {"termination-resilience", "termination-non-exploitability"}


def num_time(r):
    """Numeric analysis time for stats: the JSON time, else wall-clock."""
    for v in (r.get("analyzer_time"), r.get("time")):
        try:
            return float(v)
        except (TypeError, ValueError):
            continue
    return 0.0


def disp_time(r):
    """Time to display: the value reported by the analyzer in the JSON."""
    try:
        return f"{float(r.get('analyzer_time')):.3f}"
    except (TypeError, ValueError):
        return str(r.get("time"))


# --------------------------------------------------------------------------- #
# Rendering
# --------------------------------------------------------------------------- #

def status_class(status):
    s = status.upper()
    if s == "TRUE":
        return "true"
    if s in ("UKNOWN", "UNKNOWN"):
        return "unknown"
    if s == "TO":
        return "timeout"
    return "fail"


PAGE_CSS = """
:root, html[data-theme="dark"]{
  --bg:#0f1115; --surface:#171a21; --surface2:#1e222b; --border:#2a2f3a;
  --text:#e6e8ee; --muted:#9aa3b2; --accent:#5b8def;
  --true:#3fb950; --true-bg:#10371d;
  --unknown:#d29922; --unknown-bg:#3a2e0c;
  --fail:#f85149; --fail-bg:#3a1413;
  --hero:linear-gradient(135deg,#1b2a4a 0%,#10131a 70%);
}
html[data-theme="light"]{
  --bg:#f4f6fb; --surface:#ffffff; --surface2:#eef1f7; --border:#d8deea;
  --text:#1b2430; --muted:#5b6675; --accent:#1f6feb;
  --true:#1a7f37; --true-bg:#d8f3df;
  --unknown:#9a6700; --unknown-bg:#fdf0d0;
  --fail:#cf222e; --fail-bg:#ffe0e0;
  --hero:linear-gradient(135deg,#dbe6ff 0%,#f4f6fb 70%);
}
*{box-sizing:border-box}
body{
  margin:0; background:var(--bg); color:var(--text);
  font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
  font-size:15px; line-height:1.5;
}
a{color:var(--accent); text-decoration:none}
a:hover{text-decoration:underline}
.wrap{max-width:1200px; margin:0 auto; padding:0 24px 80px}
header.hero{
  background:var(--hero);
  border-bottom:1px solid var(--border); padding:34px 24px; margin-bottom:24px;
}
header.hero .inner{max-width:1200px; margin:0 auto; position:relative}
header.hero h1{margin:0; font-size:30px; font-weight:700; letter-spacing:.3px}
.theme-toggle{
  position:absolute; top:0; right:0; cursor:pointer; font-size:13px; font-weight:600;
  padding:8px 14px; border-radius:999px; background:var(--surface2);
  border:1px solid var(--border); color:var(--text);
}
.theme-toggle:hover{border-color:var(--accent)}
.stats{margin:4px 0 30px}
.stats .stat-head{display:flex; align-items:center; gap:14px; flex-wrap:wrap; margin-bottom:12px}
.stats h2{font-size:15px; text-transform:uppercase; letter-spacing:1.2px; color:var(--muted); margin:0}
.seg{display:inline-flex; border:1px solid var(--border); border-radius:10px; overflow:hidden}
.seg button{
  background:var(--surface); color:var(--muted); border:none; padding:7px 16px;
  font-size:13px; font-weight:600; cursor:pointer;
}
.seg button.active{background:var(--accent); color:#fff}
.stats .chart{background:#fff; border:1px solid var(--border); border-radius:14px; padding:10px; text-align:center}
.stats .chart img{max-width:100%; height:auto}
header.hero .sub{color:var(--muted); margin-top:6px; font-size:14px}
.chips{display:flex; flex-wrap:wrap; gap:10px; margin-top:18px}
.chip{
  display:inline-flex; align-items:baseline; gap:8px; padding:7px 14px;
  border-radius:999px; background:var(--surface2); border:1px solid var(--border);
  font-size:13px; font-weight:600;
}
.chip b{font-size:16px}
.chip.true{color:var(--true)} .chip.unknown{color:var(--unknown)}
.chip.fail,.chip.timeout{color:var(--fail)} .chip.total{color:var(--text)}
.chip.info{color:var(--accent)}
.controls{display:flex; flex-wrap:wrap; gap:14px; align-items:center; margin:6px 0 22px}
.controls input[type=search]{
  flex:1; min-width:220px; padding:10px 14px; border-radius:10px;
  background:var(--surface); border:1px solid var(--border); color:var(--text); font-size:14px;
}
.controls label{color:var(--muted); font-size:14px; display:inline-flex; gap:7px; align-items:center; cursor:pointer}
section.grp{margin-bottom:30px}
section.grp h2{
  font-size:15px; text-transform:uppercase; letter-spacing:1.2px; color:var(--muted);
  margin:0 0 10px; padding-bottom:8px; border-bottom:1px solid var(--border);
}
.card{background:var(--surface); border:1px solid var(--border); border-radius:14px; overflow:hidden}
table{border-collapse:collapse; width:100%; font-size:14px}
thead th{
  position:sticky; top:0; background:var(--surface2); color:var(--muted);
  text-align:left; font-weight:600; padding:11px 16px; border-bottom:1px solid var(--border);
  font-size:12px; text-transform:uppercase; letter-spacing:.5px;
}
tbody td{padding:11px 16px; border-bottom:1px solid var(--border); vertical-align:top}
tbody tr:last-child td{border-bottom:none}
tbody tr:hover{background:var(--surface2)}
td.c{text-align:center; white-space:nowrap}
code.mono,td.prop,.mono{font-family:"SF Mono",ui-monospace,Menlo,Consolas,monospace;
  font-size:13px; color:var(--text)}
td.prop{color:var(--text); font-weight:500}
.badge{
  display:inline-block; padding:3px 11px; border-radius:999px; font-size:12px; font-weight:700;
  letter-spacing:.3px;
}
.badge.true{color:var(--true); background:var(--true-bg)}
.badge.unknown{color:var(--unknown); background:var(--unknown-bg)}
.badge.fail,.badge.timeout{color:var(--fail); background:var(--fail-bg)}
.badge.info{color:var(--accent); background:rgba(91,141,239,.16)}
/* one colour per ctl lifting variant (TRUE cells) */
.badge.v-base{color:#3fb950; background:rgba(63,185,80,.16)}
.badge.v-resilience{color:#5b8def; background:rgba(91,141,239,.16)}
.badge.v-resilience_reachability{color:#1ab2a8; background:rgba(26,178,168,.16)}
.badge.v-robust_reachability{color:#f0883e; background:rgba(240,136,62,.18)}
.chip.v-base{color:#3fb950} .chip.v-resilience{color:#5b8def}
.chip.v-resilience_reachability{color:#1ab2a8} .chip.v-robust_reachability{color:#f0883e}
.tag{font-family:ui-monospace,Menlo,monospace; font-size:12px; color:var(--muted);
  background:var(--surface2); padding:2px 8px; border-radius:6px}
.empty{color:var(--muted); text-align:center; padding:40px}
/* per-test page */
.meta{display:flex; flex-wrap:wrap; gap:22px; background:var(--surface); border:1px solid var(--border);
  border-radius:14px; padding:18px 22px; margin-bottom:22px}
.meta .item{display:flex; flex-direction:column; gap:3px}
.meta .item .k{font-size:11px; text-transform:uppercase; letter-spacing:.6px; color:var(--muted)}
.meta .item .v{font-size:15px; font-family:ui-monospace,Menlo,monospace}
/* tabs */
nav.tabs{display:flex; gap:6px; margin:0 0 22px; border-bottom:1px solid var(--border)}
nav.tabs button{
  background:none; border:none; border-bottom:2px solid transparent; color:var(--muted);
  font-size:15px; font-weight:600; padding:10px 18px; cursor:pointer; margin-bottom:-1px;
}
nav.tabs button:hover{color:var(--text)}
nav.tabs button.active{color:var(--accent); border-bottom-color:var(--accent)}
.panel[hidden]{display:none}
/* summary table */
table.summary{margin-bottom:22px}
table.summary td.num{text-align:right; font-family:ui-monospace,Menlo,monospace}
.rate{display:inline-block; min-width:46px}
.bar{height:7px; border-radius:4px; background:var(--surface2); overflow:hidden; margin-top:4px}
.bar > i{display:block; height:100%; background:var(--true)}
/* decision tree */
.treechips{display:flex; gap:10px; flex-wrap:wrap; margin-bottom:12px}
.tag.true{color:var(--true); background:var(--true-bg)}
.treesvg{background:#fff; padding:14px; text-align:center; overflow:auto}
.treesvg svg{max-width:100%; height:auto}
ul.guards{margin:6px 0; padding-left:22px}
ul.guards li{padding:2px 0; font-size:13px}
h3.sec{font-size:14px; text-transform:uppercase; letter-spacing:1px; color:var(--muted); margin:26px 0 10px}
pre.block{background:#0b0d12; border:1px solid var(--border); border-radius:12px; padding:16px;
  overflow:auto; font-size:13px; line-height:1.45; max-height:560px}
pre.block code{font-family:"SF Mono",ui-monospace,Menlo,Consolas,monospace}
.back{display:inline-block; margin-bottom:18px; font-size:14px}
"""

# kept for backward references
CSS_EXTRA = PAGE_CSS

THEME_JS = """
(function(){
  const root = document.documentElement;
  function fromUrl(){ try{ return new URLSearchParams(location.search).get('theme'); }catch(e){ return null; } }
  function fromStore(){ try{ return localStorage.getItem('ftheme'); }catch(e){ return null; } }
  function persist(t){ try{ localStorage.setItem('ftheme', t); }catch(e){} }
  // URL param wins (survives file:// where localStorage is not shared across pages).
  root.setAttribute('data-theme', fromUrl() || fromStore() || 'dark');
  // Carry the current theme through internal links so navigation keeps it.
  function propagate(t){
    document.querySelectorAll('a[href]').forEach(function(a){
      const href = a.getAttribute('href');
      if(!href || href.indexOf('://')>=0 || href.charAt(0)==='#') return;
      if(href.indexOf('.html')<0) return;
      a.setAttribute('href', href.split('?')[0] + '?theme=' + t);
    });
  }
  function lbl(){ return root.getAttribute('data-theme')==='dark' ? '\\u2600 light' : '\\u263e dark'; }
  document.addEventListener('DOMContentLoaded', function(){
    propagate(root.getAttribute('data-theme'));
    const btn = document.getElementById('theme');
    if(!btn) return;
    btn.textContent = lbl();
    btn.addEventListener('click', function(){
      const next = root.getAttribute('data-theme')==='dark' ? 'light' : 'dark';
      root.setAttribute('data-theme', next);
      persist(next);
      propagate(next);
      btn.textContent = lbl();
    });
  });
})();
"""

INDEX_JS = """
(function(){
  const q = document.getElementById('q');
  const failOnly = document.getElementById('failonly');
  function apply(){
    const term = (q.value||'').toLowerCase();
    const fo = failOnly.checked;
    document.querySelectorAll('section.grp').forEach(sec=>{
      let shown = 0;
      sec.querySelectorAll('tbody tr').forEach(tr=>{
        const txt = tr.getAttribute('data-search');
        const st = tr.getAttribute('data-status');
        let ok = (!term || txt.indexOf(term)>=0);
        if (fo && (st==='true')) ok = false;
        tr.style.display = ok ? '' : 'none';
        if (ok) shown++;
      });
      sec.style.display = shown ? '' : 'none';
    });
  }
  if(q) q.addEventListener('input', apply);
  if(failOnly) failOnly.addEventListener('change', apply);

  // Tabs.
  document.querySelectorAll('nav.tabs button').forEach(b=>{
    b.addEventListener('click', function(){
      const t = b.getAttribute('data-tab');
      document.querySelectorAll('nav.tabs button').forEach(x=>x.classList.toggle('active', x===b));
      document.querySelectorAll('.panel').forEach(p=>{ p.hidden = (p.id !== 'tab-'+t); });
    });
  });

  // Stats: switch the displayed figure + summary table when the grouping changes.
  document.querySelectorAll('.seg button').forEach(b=>{
    b.addEventListener('click', function(){
      const key = b.getAttribute('data-key');
      document.querySelectorAll('.seg button').forEach(x=>x.classList.remove('active'));
      b.classList.add('active');
      document.querySelectorAll('.stats .keyblock').forEach(el=>{
        el.style.display = (el.getAttribute('data-key')===key) ? '' : 'none';
      });
    });
  });
})();
"""


# A leaf is "undefined" (no ranking function, i.e. termination not proven on
# that region) when it carries one of these bottom/top markers.
UNDEFINED_LEAVES = {"", "-", "bot", "bottom", "_|_", "⊥", "top", "⊤", "nan", "none"}


def leaf_defined(value):
    return str(value).strip().lower() not in UNDEFINED_LEAVES


def subtree_defined(node):
    """True if the subtree contains at least one defined (ranked) leaf."""
    return any(leaf_defined(v) for _path, v in tree_leaves(node))


def tree_leaves(node, path=None):
    """Yield (path, leaf_value) for each leaf. path is a list of
    (constraint, negated) pairs giving the conjunction reaching the leaf."""
    path = path or []
    if not isinstance(node, dict):
        return
    if "Leaf" in node:
        yield path, node["Leaf"]
    elif "Node" in node:
        n = node["Node"]
        c = str(n.get("constraint", ""))
        yield from tree_leaves(n.get("left"), path + [(c, False)])
        yield from tree_leaves(n.get("right"), path + [(c, True)])


def tree_stats(node):
    """Quantify the decision tree: #leaves, #defined regions, distinct guards."""
    leaves = list(tree_leaves(node))
    constraints = set()
    defined = 0
    for path, val in leaves:
        for c, _neg in path:
            constraints.add(c)
        if leaf_defined(val):
            defined += 1
    return {"leaves": len(leaves), "defined": defined,
            "constraints": sorted(constraints)}


def _dot_escape(s):
    return str(s).replace("\\", "\\\\").replace('"', '\\"').replace("\n", " ")


def tree_to_dot(node):
    """Build a graphviz 'dot' source for the decision tree from the JSON."""
    out = ["digraph T {", '  bgcolor="transparent";', "  rankdir=TB;",
           '  node [fontname="monospace", fontsize=11];',
           '  edge [fontname="monospace", fontsize=10, color="#888888"];']
    ctr = [0]

    def rec(n):
        i = ctr[0]; ctr[0] += 1; nid = f"n{i}"
        if not isinstance(n, dict):
            out.append(f'  {nid} [shape=box, label="?"];')
            return nid
        if "Leaf" in n:
            val = str(n["Leaf"])
            fill = "#d8f3df" if leaf_defined(val) else "#ffe0e0"
            out.append(f'  {nid} [shape=box, style="rounded,filled", '
                       f'fillcolor="{fill}", color="#bbbbbb", '
                       f'fontcolor="#1b2430", label="{_dot_escape(val)}"];')
            return nid
        nd = n["Node"]
        out.append(f'  {nid} [shape=ellipse, style=filled, fillcolor="#eef1f7", '
                   f'color="#bbbbbb", fontcolor="#1f3a93", '
                   f'label="{_dot_escape(nd.get("constraint", ""))}"];')
        left, right = nd.get("left"), nd.get("right")
        lid = rec(left); rid = rec(right)
        # Edges leading towards a defined region (a proven ranking function)
        # are highlighted in green; dead/undefined branches stay grey.
        lcol = "#2ca02c" if subtree_defined(left) else "#aaaaaa"
        rcol = "#2ca02c" if subtree_defined(right) else "#aaaaaa"
        lw_l = "1.8" if subtree_defined(left) else "1.0"
        lw_r = "1.8" if subtree_defined(right) else "1.0"
        out.append(f'  {nid} -> {lid} [color="{lcol}", penwidth={lw_l}];')
        out.append(f'  {nid} -> {rid} [color="{rcol}", penwidth={lw_r}];')
        return nid

    rec(node)
    out.append("}")
    return "\n".join(out)


def render_tree_svg(node):
    """Render the tree to an inline SVG via graphviz, or None if unavailable."""
    if not shutil.which("dot"):
        return None
    try:
        p = subprocess.run(["dot", "-Tsvg"], input=tree_to_dot(node),
                           capture_output=True, text=True, timeout=20)
        if p.returncode != 0:
            return None
        svg = p.stdout
        i = svg.find("<svg")
        return svg[i:] if i >= 0 else None
    except Exception:
        return None


def region_str(path, esc):
    """Render a path (conjunction of guards) as a readable precondition."""
    if not path:
        return '<span style="color:var(--muted)">true</span>'
    parts = []
    for c, neg in path:
        c = esc(str(c))
        parts.append(f'&not;({c})' if neg else c)
    return ' &and; '.join(parts)


def build_summary(records, keyfn):
    """Aggregate per bucket (inspired by script/stats.ipynb groupby):
    counts per status, success rate (TRUE/total) and total/mean time.
    """
    rows = {}
    for r in records:
        b = keyfn(r)
        d = rows.setdefault(b, {"bucket": b, "n": 0, "TRUE": 0, "UNKNOWN": 0,
                                "FAIL": 0, "TO": 0, "tsum": 0.0})
        d["n"] += 1
        d[status_bucket(r["status"])] += 1
        d["tsum"] += num_time(r)
    out = []
    for d in rows.values():
        d["rate"] = (100.0 * d["TRUE"] / d["n"]) if d["n"] else 0.0
        d["tmean"] = (d["tsum"] / d["n"]) if d["n"] else 0.0
        out.append(d)
    return sorted(out, key=lambda d: d["bucket"])


# Ways to bucket the tests. The stats figures and (optionally) the table
# sections are organised by one of these keys.
GROUP_KEYS = {
    "dir": ("test folder", lambda r: r["group"]),
    "domain": ("abstract domain", lambda r: r["domain"]),
}


def status_bucket(status):
    s = status.upper()
    if s == "TRUE":
        return "TRUE"
    if s in ("UKNOWN", "UNKNOWN"):
        return "UNKNOWN"
    if s == "TO":
        return "TO"
    return "FAIL"


STATUS_COLORS = {"TRUE": "#2ca02c", "UNKNOWN": "#ff9f1c",
                 "FAIL": "#e63946", "TO": "#8a8a8a"}


def generate_stats(records, results_dir, key_name):
    """Render a matplotlib figure (results breakdown · cactus · timing) bucketed
    by GROUP_KEYS[key_name]. Returns the PNG filename, or None if matplotlib is
    unavailable.
    """
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except Exception:
        return None

    _, keyfn = GROUP_KEYS[key_name]
    buckets = sorted({keyfn(r) for r in records})
    statuses = ["TRUE", "UNKNOWN", "FAIL", "TO"]

    # counts[bucket][status]
    counts = {b: {s: 0 for s in statuses} for b in buckets}
    for r in records:
        counts[keyfn(r)][status_bucket(r["status"])] += 1

    fig, axes = plt.subplots(1, 3, figsize=(16, 4.6))
    fig.suptitle(f"Statistics by {GROUP_KEYS[key_name][0]}", fontsize=14, fontweight="bold")

    # (1) stacked bar of statuses
    ax = axes[0]
    bottom = [0] * len(buckets)
    for s in statuses:
        vals = [counts[b][s] for b in buckets]
        ax.bar(buckets, vals, bottom=bottom, label=s, color=STATUS_COLORS[s])
        bottom = [a + b for a, b in zip(bottom, vals)]
    ax.set_title("Results breakdown")
    ax.set_ylabel("# tests")
    ax.legend(fontsize=8)
    ax.tick_params(axis="x", rotation=30)

    # (2) cactus plot: cumulative #TRUE vs time, one line per bucket
    ax = axes[1]
    plotted = False
    for b in buckets:
        times = sorted(num_time(r) for r in records
                       if keyfn(r) == b and status_bucket(r["status"]) == "TRUE")
        if times:
            ax.step(times, range(1, len(times) + 1), where="post", marker=".", label=b)
            plotted = True
    ax.set_title("Solved (TRUE) vs time")
    ax.set_xlabel("time (s)")
    ax.set_ylabel("cumulative # TRUE")
    if plotted:
        ax.legend(fontsize=8)

    # (3) average analysis time per bucket
    ax = axes[2]
    avg = []
    for b in buckets:
        ts = [num_time(r) for r in records if keyfn(r) == b]
        avg.append(sum(ts) / len(ts) if ts else 0)
    ax.bar(buckets, avg, color="#4c78a8")
    ax.set_title("Average analysis time")
    ax.set_ylabel("seconds")
    ax.tick_params(axis="x", rotation=30)

    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fname = f"stats_by_{key_name}.png"
    fig.savefig(os.path.join(results_dir, fname), dpi=110)
    plt.close(fig)
    return fname


def _csv_group(r):
    """Folder path of a test, relative to its group root, for easy pandas
    filtering: e.g. 'prism_games/Communication_protocols', 'classic',
    'resilience/terminating/pulse', 'ctl/koskinen' -- instead of just 'atl'."""
    d = os.path.dirname(r["file"])            # e.g. tests/atl/prism_games/...
    prefix = os.path.join("tests", r.get("group", "")) + os.sep
    d = d[len(prefix):] if d.startswith(prefix) else d
    return d.replace(os.sep, "/")


def write_csv(records, path):
    import csv
    with open(path, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["group", "config", "file", "property", "players", "domain",
                    "expected", "result", "status", "suff_conditions", "leaves",
                    "time_s", "analyzer_time", "vulnerability"])
        for r in records:
            w.writerow([_csv_group(r), r.get("name", ""), r["file"],
                        r["property"], ";".join(r.get("players", [])),
                        r["domain"], r.get("expected", "-"), r["result"],
                        r["status"], r.get("suff", 0), r.get("leaves", 0),
                        r["time"], r["analyzer_time"], r["vulnerability"]])


HL_HEAD = (
    '<link rel="stylesheet" '
    'href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css">'
    '<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>'
)


def _folder_id(folder):
    """A DOM-id-safe slug for a folder name."""
    return re.sub(r'[^A-Za-z0-9]+', '-', folder)


def _write_folder_table(fh, recs, esc, compact):
    """Standard per-folder table: one row per (file, property) run."""
    rows = sorted(recs, key=lambda x: (x["file"], x["name"]))
    fh.write(f'<section class="grp"><h2>tests <span class="tag">{len(rows)}</span></h2>\n'
             '<div class="card"><table>\n')
    fh.write("<thead><tr><th>Test</th><th>Property</th><th>Domain</th>"
             "<th>Result</th><th>Regions</th><th>Time (s)</th>"
             "<th>Vulnerability</th></tr></thead><tbody>\n")
    for r in rows:
        sc = status_class(r["status"])
        search = esc((r["file"] + " " + r["name"] + " " + r["property"]).lower(), quote=True)
        regions = f'{tree_stats(r["tree"])["defined"]}/{tree_stats(r["tree"])["leaves"]}' \
            if r.get("tree") else "—"
        label = esc(r["name"])
        cell = label if compact else f'<a href="{r["key"]}.html">{label}</a>'
        fh.write(
            f'<tr data-status="{sc}" data-search="{search}">'
            f'<td>{cell}</td>'
            f'<td class="prop">{esc(r["property"])}</td>'
            f'<td class="c"><span class="tag">{esc(r["domain"])}</span></td>'
            f'<td class="c"><span class="badge {sc}">{esc(r["status"])}</span></td>'
            f'<td class="c mono">{esc(regions)}</td>'
            f'<td class="c mono">{esc(disp_time(r))}</td>'
            f'<td class="mono">{esc(str(r["vulnerability"]))}</td></tr>\n')
    fh.write("</tbody></table></div></section>\n")


def resilience_alarms(recs):
    """(#files, #critical-alarm files, #less-dangerous files, #unknown files).

    All counted per FILE. A file raises a critical / less-dangerous alarm if
    any property of that category holds (TRUE). A file is UNKNOWN iff NONE of
    its properties could be proven (no TRUE at all), not merely if one of them
    was left unproven.
    """
    files = {r["file"] for r in recs}
    hold = {(r["file"], r["name"]) for r in recs
            if status_bucket(r["status"]) == "TRUE"}
    files_with_true = {f for (f, _) in hold}
    n_crit = sum(1 for f in files if any((f, p) in hold for p in RESILIENCE_CRITICAL))
    n_less = sum(1 for f in files if any((f, p) in hold for p in RESILIENCE_LESS))
    n_unknown = len(files) - len(files_with_true)   # files with no property proven
    return len(files), n_crit, n_less, n_unknown


def _ctl_variant(rec):
    """The lifting variant of a ctl run, derived from its config name."""
    name = rec["name"]
    for v in ("resilience_reachability", "robust_reachability", "resilience"):
        if name.endswith("." + v):
            return v
    return "base"


def _write_matrix(fh, recs, esc, col_of, col_order, folder, col_class=None):
    """Generic pivot: one row per .c file, one column per col_of(record).

    col_class(col) -> CSS class used to colour that column's TRUE cells and its
    count chip (one colour per "alarm"). Defaults to the plain TRUE colour.
    """
    files = sorted({r["file"] for r in recs})
    present = {col_of(r) for r in recs}
    cols = [c for c in col_order if c in present] + \
           sorted(present - set(col_order))
    cell = {(r["file"], col_of(r)): r for r in recs}
    sep = os.sep + folder + os.sep
    klass = col_class or (lambda c: "true")

    fh.write(f'<section class="grp"><h2>{esc(folder)} '
             f'<span class="tag">{len(files)} files</span></h2>\n')
    # per-column TRUE counts, each in its own colour
    fh.write('<div class="chips" style="margin:0 0 14px">'
             f'<span class="chip total"><b>{len(files)}</b> files</span>')
    for c in cols:
        n = sum(1 for f in files
                if (f, c) in cell and status_bucket(cell[(f, c)]["status"]) == "TRUE")
        fh.write(f'<span class="chip {klass(c)}"><b>{n}</b> {esc(c)} TRUE</span>')
    fh.write('</div>\n')

    fh.write('<div class="card" style="overflow:auto"><table>\n<thead><tr><th>File</th>')
    for c in cols:
        fh.write(f'<th class="c">{esc(c)}</th>')
    fh.write("</tr></thead><tbody>\n")
    for f in files:
        rel = f.split(sep, 1)[-1] if sep in f else os.path.basename(f)
        fh.write(f'<tr data-search="{esc(rel.lower(), quote=True)}">'
                 f'<td class="mono">{esc(rel)}</td>')
        for c in cols:
            r = cell.get((f, c))
            if r is None:
                fh.write('<td class="c">—</td>')
            else:
                # TRUE cells take the column's alarm colour; others keep status.
                badge = klass(c) if status_bucket(r["status"]) == "TRUE" \
                    else status_class(r["status"])
                fh.write(f'<td class="c"><span class="badge {badge}">{esc(r["status"])}</span></td>')
        fh.write("</tr>\n")
    fh.write("</tbody></table></div></section>\n")


def _write_resilience_matrix(fh, recs, esc):
    """One row per .c file, one result column per resilience property.

    Resilience is scored by ALARM SEVERITY, not TRUE/UNKNOWN: a property that
    holds (TRUE) raises an alarm -- critical for exploitability / robust
    non-termination, less dangerous for resilience / non-exploitability.
    """
    props = sorted({r["name"] for r in recs})
    files = sorted({r["file"] for r in recs})
    cell = {(r["file"], r["name"]): r for r in recs}

    def holds(f, p):
        r = cell.get((f, p))
        return r is not None and status_bucket(r["status"]) == "TRUE"

    _, n_crit, n_less, n_unknown = resilience_alarms(recs)

    fh.write('<section class="grp"><h2>resilience '
             f'<span class="tag">{len(files)} files</span></h2>\n')
    # severity summary (instead of TRUE/UNKNOWN counts)
    fh.write('<div class="chips" style="margin:0 0 14px">'
             f'<span class="chip total"><b>{len(files)}</b> files</span>'
             f'<span class="chip fail"><b>{n_crit}</b> critical alarms '
             '(exploitability / robust non-termination)</span>'
             f'<span class="chip info"><b>{n_less}</b> less-dangerous '
             '(resilience / non-exploitability)</span>'
             f'<span class="chip unknown"><b>{n_unknown}</b> unknown '
             '(no property proven)</span></div>\n')

    fh.write('<div class="card" style="overflow:auto"><table>\n<thead><tr><th>File</th>')
    for p in props:
        fh.write(f'<th class="c">{esc(p)}</th>')
    fh.write("</tr></thead><tbody>\n")
    for f in files:
        rel = f.split("resilience" + os.sep, 1)[-1] if ("resilience" + os.sep) in f \
            else os.path.basename(f)
        fh.write(f'<tr data-search="{esc(rel.lower(), quote=True)}">'
                 f'<td class="mono">{esc(rel)}</td>')
        for p in props:
            r = cell.get((f, p))
            if r is None:
                fh.write('<td class="c">—</td>')
                continue
            # colour by alarm severity: a dangerous property holding is red /
            # amber; everything else keeps its plain TRUE/UNKNOWN colour.
            if holds(f, p) and p in RESILIENCE_CRITICAL:
                badge = "fail"
            elif holds(f, p) and p in RESILIENCE_LESS:
                badge = "info"
            else:
                badge = status_class(r["status"])
            fh.write(f'<td class="c"><span class="badge {badge}">{esc(r["status"])}</span></td>')
        fh.write("</tr>\n")
    fh.write("</tbody></table></div></section>\n")


def _write_stats_panel(fh, records, charts, group_by, esc):
    """The aggregated-statistics tab (summary tables + matplotlib charts)."""
    fh.write('<div class="panel" id="tab-stats" hidden><div class="stats">\n')
    default_key = group_by if group_by in GROUP_KEYS else next(iter(GROUP_KEYS))
    fh.write('<div class="stat-head"><h2>Aggregated statistics</h2><div class="seg">')
    for k in GROUP_KEYS:
        active = " active" if k == default_key else ""
        fh.write(f'<button class="{active.strip()}" data-key="{k}">'
                 f'by {esc(GROUP_KEYS[k][0])}</button>')
    fh.write('</div></div>\n')

    for k, (klabel, kfn) in GROUP_KEYS.items():
        disp = "" if k == default_key else ' style="display:none"'
        fh.write(f'<div class="keyblock" data-key="{k}"{disp}>\n')
        fh.write('<div class="card"><table class="summary"><thead><tr>'
                 f'<th>{esc(klabel)}</th><th>Tests</th><th>TRUE</th><th>UNKNOWN</th>'
                 '<th>FAIL</th><th>TO</th><th>Success</th>'
                 '<th>Mean time (s)</th><th>Total time (s)</th></tr></thead><tbody>\n')
        for d in build_summary(records, kfn):
            fh.write(
                f'<tr><td>{esc(str(d["bucket"]))}</td>'
                f'<td class="num">{d["n"]}</td>'
                f'<td class="num true">{d["TRUE"]}</td>'
                f'<td class="num unknown">{d["UNKNOWN"]}</td>'
                f'<td class="num fail">{d["FAIL"]}</td>'
                f'<td class="num">{d["TO"]}</td>'
                f'<td class="num"><span class="rate">{d["rate"]:.0f}%</span>'
                f'<div class="bar"><i style="width:{d["rate"]:.0f}%"></i></div></td>'
                f'<td class="num">{d["tmean"]:.3f}</td>'
                f'<td class="num">{d["tsum"]:.2f}</td></tr>\n')
        fh.write("</tbody></table></div>\n")
        if k in charts:
            fh.write(f'<div class="chart"><img src="{charts[k]}" '
                     f'alt="stats by {esc(k)}"></div>\n')
        fh.write("</div>\n")  # end keyblock
    if not charts:
        fh.write('<p style="color:var(--muted)">Charts unavailable '
                 '(matplotlib not installed).</p>\n')
    fh.write("</div></div>\n")  # end stats / tab-stats


def write_html(records, results_dir, charts, group_by, compact=False):
    esc = html.escape
    folders = sorted({r["folder"] for r in records})

    # ---- per-test pages: metadata + config + decision tree + source + log ---
    # Skipped in --compact, and never produced for the matrix folders.
    for r in ([] if compact else
              [x for x in records if x["folder"] not in MATRIX_FOLDERS]):
        page = os.path.join(results_dir, r["key"] + ".html")
        try:
            with open(os.path.join(ROOT, r["file"])) as fh:
                src = fh.read()
        except OSError:
            src = "(source unavailable)"
        sc = status_class(r["status"])

        # Full analyzer config, straight from the JSON it emitted.
        conf = r.get("conf") or {}
        conf_rows = "".join(
            f'<tr><td class="mono" style="color:var(--muted)">{esc(str(k))}</td>'
            f'<td class="mono">{esc(str(v))}</td></tr>'
            for k, v in conf.items()) or '<tr><td colspan="2">(no JSON produced)</td></tr>'

        # Decision tree -> graphviz SVG + quantified preconditions, all from JSON.
        tree_html = ""
        if r.get("tree"):
            st = tree_stats(r["tree"])
            leaves = list(tree_leaves(r["tree"]))
            svg = render_tree_svg(r["tree"])
            svg_block = (f'<div class="card treesvg">{svg}</div>'
                         if svg else
                         '<p style="color:var(--muted)">(graphviz not available '
                         '— install it for the tree diagram)</p>')
            # region / precondition table
            region_rows = ""
            for i, (path, val) in enumerate(sorted(
                    leaves, key=lambda pv: (not leaf_defined(pv[1]), len(pv[0]))), 1):
                d = leaf_defined(val)
                tag = ('<span class="badge true">defined</span>' if d
                       else '<span class="badge fail">undefined</span>')
                region_rows += (
                    f'<tr><td class="num">{i}</td>'
                    f'<td class="prop">{region_str(path, esc)}</td>'
                    f'<td class="mono">{esc(str(val))}</td>'
                    f'<td class="c">{tag}</td></tr>')
            guards = "".join(f'<li class="mono">{esc(c)}</li>' for c in st["constraints"]) \
                or '<li style="color:var(--muted)">none</li>'
            tree_html = f"""<h3 class="sec">Decision tree &amp; preconditions</h3>
<div class="treechips">
  <span class="tag">{st['leaves']} leaves</span>
  <span class="tag true">{st['defined']} defined region(s)</span>
  <span class="tag">{len(st['constraints'])} distinct guard(s)</span>
</div>
{svg_block}
<h3 class="sec">Defined regions (sufficient preconditions)</h3>
<div class="card"><table><thead><tr><th>#</th><th>Region (conjunction of guards)</th>
<th>Ranking function</th><th>Status</th></tr></thead><tbody>{region_rows}</tbody></table></div>
<h3 class="sec">Distinct guards</h3>
<div class="card" style="padding:10px 20px"><ul class="guards">{guards}</ul></div>"""

        vuln = r.get("vulnerability")
        vuln_html = ""
        if vuln and vuln not in ("-", "Not analyzed"):
            vuln_html = (f'<h3 class="sec">Vulnerability</h3>'
                         f'<pre class="block"><code>{esc(str(vuln))}</code></pre>')

        with open(page, "w") as fh:
            fh.write(f"""<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{esc(r['name'])}</title>{HL_HEAD}
<style>{PAGE_CSS}</style><script>{THEME_JS}</script></head><body>
<header class="hero"><div class="inner">
<button id="theme" class="theme-toggle"></button>
<a class="back" href="./index.html">&larr; back to overview</a>
<h1>{esc(r['name'])}</h1>
<div class="sub mono">{esc(r['file'])}</div>
</div></header>
<div class="wrap">
<div class="meta">
  <div class="item"><span class="k">Group</span><span class="v">{esc(r['group'])}</span></div>
  <div class="item"><span class="k">Property</span><span class="v">{esc(r['property'])}</span></div>
  <div class="item"><span class="k">Domain</span><span class="v">{esc(r['domain'])}</span></div>
  <div class="item"><span class="k">Result</span><span class="v"><span class="badge {sc}">{esc(r['status'])}</span></span></div>
  <div class="item"><span class="k">Time</span><span class="v">{esc(disp_time(r))} s</span></div>
  <div class="item"><span class="k">Wall time</span><span class="v">{esc(str(r['time']))} s</span></div>
</div>
<h3 class="sec">Analyzer config</h3>
<div class="card"><table><tbody>{conf_rows}</tbody></table></div>
{tree_html}
{vuln_html}
<h3 class="sec">Source</h3>
<pre class="block"><code class="language-c">{esc(src)}</code></pre>
<h3 class="sec">Analysis log</h3>
<pre class="block"><code>{esc(r['log'])}</code></pre>
</div>
<script>hljs.highlightAll();</script>
</body></html>""")

    # ---- index --------------------------------------------------------------
    index = os.path.join(results_dir, "index.html")
    # Resilience is scored by alarm severity, NOT TRUE/UNKNOWN, so it is kept
    # out of the global status totals and shown as its own alarm chips.
    res_recs = [r for r in records if r["folder"] == RESILIENCE_FOLDER]
    non_res = [r for r in records if r["folder"] != RESILIENCE_FOLDER]
    counts = {}
    for r in non_res:
        counts[r["status"]] = counts.get(r["status"], 0) + 1

    chip_order = ["TRUE", "UKNOWN", "UNKNOWN", "FAIL", "TO"]
    ordered = ([s for s in chip_order if s in counts]
               + [s for s in counts if s not in chip_order])

    # charts: {key_name: png_filename} for those matplotlib produced.
    charts = {k: v for k, v in (charts or {}).items() if v}

    with open(index, "w") as fh:
        fh.write(f"""<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>FuncTion — tests overview</title>
<style>{PAGE_CSS}</style><script>{THEME_JS}</script></head><body>
<header class="hero"><div class="inner">
<button id="theme" class="theme-toggle"></button>
<h1>FuncTion — tests overview</h1>
<div class="sub">{len(records)} run(s) · generated {datetime.datetime.now():%Y-%m-%d %H:%M}</div>
<div class="chips">
<span class="chip total"><b>{len(non_res)}</b> total</span>
""")
        for s in ordered:
            fh.write(f'<span class="chip {status_class(s)}"><b>{counts[s]}</b> {esc(s)}</span>\n')
        if res_recs:
            _, n_crit, n_less, n_unknown = resilience_alarms(res_recs)
            fh.write(f'<span class="chip fail"><b>{n_crit}</b> resilience critical</span>\n')
            fh.write(f'<span class="chip info"><b>{n_less}</b> resilience less-dangerous</span>\n')
            fh.write(f'<span class="chip unknown"><b>{n_unknown}</b> resilience unknown</span>\n')
        fh.write("</div>\n</div></header>\n<div class=\"wrap\">\n")

        # ---- tab bar: one tab per analysed folder (+ Statistics) -----------
        fh.write('<nav class="tabs">')
        for i, folder in enumerate(folders):
            active = ' class="active"' if i == 0 else ''
            fh.write(f'<button{active} data-tab="f-{_folder_id(folder)}">'
                     f'{esc(folder)}</button>')
        if not compact:
            fh.write('<button data-tab="stats">Statistics</button>')
        fh.write('</nav>\n')

        # ---- shared filter controls ----------------------------------------
        fh.write("""<div class="controls">
  <input id="q" type="search" placeholder="Filter by file or property…" autocomplete="off">
  <label><input id="failonly" type="checkbox"> failures only</label>
</div>
""")

        # ---- one panel per folder ------------------------------------------
        for i, folder in enumerate(folders):
            hidden = "" if i == 0 else " hidden"
            fh.write(f'<div class="panel" id="tab-f-{_folder_id(folder)}"{hidden}>\n')
            recs = [r for r in records if r["folder"] == folder]
            if folder == RESILIENCE_FOLDER:
                _write_resilience_matrix(fh, recs, esc)
            elif folder == CTL_FOLDER:
                # columns = lifting variants; E-tests fill base/{resilience,robust}
                # _reachability, A-tests fill base/resilience -> "-" elsewhere.
                _write_matrix(fh, recs, esc, _ctl_variant, CTL_VARIANTS, CTL_FOLDER,
                              col_class=lambda c: "v-" + c)
            else:
                _write_folder_table(fh, recs, esc, compact)
            fh.write("</div>\n")

        # ---- Statistics panel (omitted in --compact) -----------------------
        if not compact:
            _write_stats_panel(fh, records, charts, group_by, esc)

        fh.write(f"</div>\n<script>{INDEX_JS}</script>\n</body></html>")
    return index


def tex_escape(s):
    s = str(s)
    rep = {"&": r"\&", "%": r"\%", "$": r"\$", "#": r"\#", "_": r"\_",
           "{": r"\{", "}": r"\}", "~": r"\textasciitilde{}",
           "^": r"\textasciicircum{}", "\\": r"\textbackslash{}",
           "<": r"\textless{}", ">": r"\textgreater{}"}
    return "".join(rep.get(c, c) for c in s)


def write_latex(records, path):
    with open(path, "w") as fh:
        fh.write("% Generated by script/runtest.py — requires \\usepackage{tabularray}\n")
        fh.write(r"\begin{longtblr}{colspec={|l|l|l|c|r|},hlines,vlines}" + "\n")
        fh.write(r"\textbf{File} & \textbf{Property} & \textbf{Domain} & "
                 r"\textbf{Result} & \textbf{Time (s)} \\" + "\n")
        for group in sorted({r["group"] for r in records}):
            fh.write(r"\SetCell[c=5]{c} \textbf{%s} & & & & \\" % tex_escape(group) + "\n")
            for r in sorted([x for x in records if x["group"] == group],
                            key=lambda x: x["file"]):
                fh.write("%s & %s & %s & %s & %s \\\\\n" % (
                    tex_escape(r["name"]),
                    tex_escape(r["property"]), tex_escape(r["domain"]),
                    tex_escape(r["status"]), tex_escape(disp_time(r))))
        fh.write(r"\end{longtblr}" + "\n")


# --------------------------------------------------------------------------- #
# Experiment tables (implementation.tex / fig:attacks structure)
# --------------------------------------------------------------------------- #
#
# One LaTeX table per experiment, all sharing the columns
#   Benchmark | Configuration | Property | Verified | Alarms | TO | Time (s)
# used in implementation.tex. Verified counts TRUE verdicts, Alarms counts
# UNKNOWN ones; the manual classification / comparison against other analysers
# is filled in by hand.

# resilience / ctl sub-folder (under tests/<grp>/{resilience,ctl}/) -> source.
_RESILIENCE_SOURCE = {
    "sv_comp": "SV-COMP", "svcomp-nla": "SV-COMP", "termination": "SV-COMP",
    "pulse": "Pulse", "pulseinfinite": "Pulse",
    "lit": "Shi et al.", "endwatch": "Shi et al.",
}
_CTL_SOURCE = {
    "koskinen": "Koskinen et al.", "ltl_automizer": "Ultimate",
    "sv_comp": "SV-COMP", "t2_cav13": "T2",
}
# Preferred display order of the source rows, per experiment.
_SOURCE_ORDER = {
    "native": ["classic", "prism_games", "mcmas"],
    "resilience": ["SV-COMP", "Pulse", "Shi et al."],
    "ctl": ["Koskinen et al.", "Ultimate", "SV-COMP", "T2"],
}
_DOMAIN_LABEL = {"boxes": r"\tool-Boxes", "polyhedra": r"\tool-Polyhedra"}
_DOMAIN_ORDER = ["boxes", "polyhedra"]

# (experiment key, output file, LaTeX label, caption).
_EXPERIMENTS = [
    ("native", "exp_native_atl.tex", "tab:atl-bench",
     "Native ATL benchmarks and evaluation. Left: source, ATL property and "
     "expected verdict. Right: abstract domain (boxes / polyhedra), analysis "
     "time (s) and the verdict returned by \\tool. Cells marked ``--'' are "
     "placeholders to be filled from actual runs."),
    ("resilience", "exp_resilience.tex", "tab:term-eval",
     "Evaluation of the termination/non-termination benchmarks."),
    ("ctl", "exp_ctl.tex", "tab:ctl-eval",
     "Evaluation of the CTL benchmarks."),
]

# Native ATL benchmarks: fixed metadata (application domain, source, ATL property,
# expected verdict) plus the config basename used to look up the run result. The
# Dom./Time/\tool columns are filled from actual runs (one sub-row per domain).
# Each row: (benchmark, source, ATL property [LaTeX], expected, config-name).
NATIVE_GROUPS = [
    ("Classical", [
        (r"train\_gate", r"\cite{AlurHK02}", r"$\langle\mathit{ctrl}\rangle\,\mathsf{G}\,\mathit{safe}$", "--", "train_gate"),
        (r"matching\_pennies", r"\cite{AlurHK02}", r"$\langle p_1\rangle\,\mathsf{F}\,\mathit{win}$", "--", "matching_pennies"),
        (r"robots\_carriage", r"\cite{}", r"--", "--", None),
        (r"nim", r"\cite{}", r"$\langle p_1\rangle\,\mathsf{F}\,\mathit{win}$", "--", "nim"),
        (r"bit\_transmission", r"\cite{}", r"$\langle\mathit{snd},\mathit{ch}\rangle\,\mathsf{F}\,\mathit{ack}$", "--", "bit_transmission"),
    ]),
    ("Game theory", [
        (r"microgrid", r"\cite{ChenFKPS13}", r"$\langle\mathit{ctrl}\rangle\,\mathsf{G}\,(\mathit{load}\le\mathit{cap})$", r"\textsc{true}", "microgrid"),
        (r"future\_mi", r"\cite{McIverM07}", r"$\langle\mathit{inv}\rangle\,\mathsf{F}\,(\mathit{gain}\ge\mathit{cap})$", r"\textsc{unknown}", "future_mi"),
    ]),
    ("Planning \\&\\ synthesis", [
        (r"task\_graph", r"\cite{BouyerFLM}", r"$\langle\mathit{sched}\rangle\,\mathsf{F}\,(\mathit{done})$", r"\textsc{true}", "task_graph"),
        (r"uav\_planning", r"\cite{FengWHT15}", r"$\langle\mathit{uav}\rangle\,\mathsf{F}\,(\mathit{wp}\ge\mathit{goal})$", r"\textsc{true}", "uav_planning"),
        (r"uav\_planning (ROZ)", r"\cite{FengWHT15}", r"$\langle\mathit{uav}\rangle\,\mathsf{G}\,(\mathit{roz}=0)$", r"\textsc{unknown}", "uav_planning.roz"),
        (r"autonomous\_driving", r"\cite{ChenKSW13}", r"$\langle\mathit{car}\rangle\,\mathsf{G}\,(\mathit{crash}=0)$", r"\textsc{true}", "autonomous_driving"),
        (r"autonomous\_driving", r"\cite{ChenKSW13}", r"$\langle\mathit{car}\rangle\,\mathsf{F}\,(\mathit{pos}\ge\mathit{goal})$", r"\textsc{true}", "autonomous_driving.reach"),
        (r"vehicle\_control", r"\cite{CizeljDLPB11}", r"$\langle\mathit{veh}\rangle\,\mathsf{F}\,(\mathit{delivered})$", r"\textsc{unknown}", "vehicle_control_hostile"),
        (r"collective\_decision", r"\cite{ChenFKPS13}", r"$\langle\mathit{net}\rangle\,\mathsf{F}\,(\mathit{best}\ge N)$", r"\textsc{unknown}", "collective_decision"),
        (r"robot\_coordination", r"\cite{prismgames}", r"$\langle r_1,r_2\rangle\,\mathsf{F}\,(x_1\!\ge\!\mathit{g}\wedge x_2\!\ge\!\mathit{g})$", r"\textsc{true}", "robot_coordination"),
        (r"self\_adaptive (CAS)", r"\cite{GlazierCSG16}", r"$\langle\mathit{cas}\rangle\,\mathsf{F}\,(\mathit{adapted}\ge1)$", r"\textsc{true}", "self_adaptive"),
        (r"aircraft\_power", r"\cite{BassetKTW15}", r"$\langle\mathit{ctrl}\rangle\,\mathsf{G}\,(\mathit{supplied}\ge\mathit{demand})$", r"\textsc{true}", "aircraft_power"),
    ]),
    ("Power management", [
        (r"dynamic\_power\_mgmt", r"\cite{prismcasestudies}", r"$\langle\mathit{pm}\rangle\,\mathsf{G}\,(\mathit{queue}\le\mathit{cap})$", r"\textsc{true}", "dynamic_power_management"),
        (r"dvs", r"\cite{PillaiS01}", r"$\langle\mathit{dvs}\rangle\,\mathsf{G}\,(\mathit{missed}=0)$", r"\textsc{true}", "dvs"),
    ]),
    ("Comm.\\ protocols", [
        (r"bounded\_retransmission", r"\cite{HelminkSV94}", r"$\langle\mathit{snd}\rangle\,\mathsf{F}\,(\mathit{delivered}\ge\mathit{chunks})$", r"\textsc{true}", "bounded_retransmission"),
        (r"zeroconf", r"\cite{rfc3927}", r"$\langle\mathit{host}\rangle\,\mathsf{F}\,(\mathit{configured})$", r"\textsc{true}", "zeroconf"),
    ]),
    ("Perf.\\ \\&\\ reliability", [
        (r"embedded\_control", r"\cite{MuppalaCT94}", r"$\langle\mathit{ctrl}\rangle\,\mathsf{G}\,(\mathit{operational})$", r"\textsc{true}", "embedded_control"),
        (r"embedded\_control (surv.)", r"\cite{MuppalaCT94}", r"$\langle\mathit{ctrl}\rangle\,(\mathit{operational})\,\mathsf{U}\,(t\ge\mathit{dl})$", r"\textsc{true}", "embedded_control.survive"),
        (r"workstation\_cluster", r"\cite{HaverkortHK00}", r"$\langle\mathit{rep}\rangle\,\mathsf{G}\,(\mathit{qos})$", r"\textsc{true}", "workstation_cluster"),
    ]),
    ("Security", [
        (r"intrusion\_detection", r"\cite{prismgames}", r"$\langle\mathit{def}\rangle\,\mathsf{G}\,(\mathit{compromised}=0)$", r"\textsc{true}", "intrusion_detection"),
        (r"non\_repudiation", r"\cite{prismgames}", r"$\langle\mathit{orig}\rangle\,\mathsf{G}\,(\mathit{fair})$", r"\textsc{true}", "non_repudiation"),
        (r"asw\_fair\_exchange", r"\cite{IslamZ08}", r"$\langle\mathit{orig}\rangle\,\mathsf{G}\,(\neg\mathit{unfair})$", r"\textsc{true}", "asw_fair_exchange"),
        (r"network\_virus", r"\cite{prismcasestudies}", r"$\langle\mathit{admin}\rangle\,\mathsf{G}\,(\mathit{infected}\le\mathit{cap})$", r"\textsc{true}", "network_virus"),
        (r"dns\_amplification", r"\cite{DeshpandeKBS11}", r"$\langle\mathit{atk}\rangle\,\mathsf{F}\,(\mathit{bw}>\mathit{BQUL})$", r"\textsc{true}", "dns_amplification"),
        (r"dos\_quantification", r"\cite{BasagiannisKP08}", r"$\langle\mathit{atk}\rangle\,\mathsf{F}\,(\mathit{queue}\ge B)$", r"\textsc{true}", "dos_quantification"),
        (r"kaminsky\_dns", r"\cite{AlexiouBK10}", r"$\langle\mathit{atk}\rangle\,\mathsf{F}\,(\mathit{poisoned})$", r"\textsc{unknown}", "kaminsky_dns"),
        (r"rfid\_attack\_defence", r"\cite{AslanyanNP16}", r"$\langle\mathit{atk}\rangle\,\mathsf{F}\,(\mathit{breached})$", r"\textsc{true}", "rfid_attack_defence"),
    ]),
]


def _experiment_of(rec):
    if rec["folder"] == RESILIENCE_FOLDER:
        return "resilience"
    if rec["folder"] == CTL_FOLDER:
        return "ctl"
    return "native"


def _source_of(rec, exp):
    parts = rec["file"].split(os.sep)
    if exp == "resilience":
        try:
            i = parts.index(RESILIENCE_FOLDER)
            sub = parts[i + 2] if len(parts) > i + 2 else parts[i + 1]
        except (ValueError, IndexError):
            sub = "?"
        return _RESILIENCE_SOURCE.get(sub, sub)
    if exp == "ctl":
        try:
            i = parts.index(CTL_FOLDER)
            sub = parts[i + 1]
        except (ValueError, IndexError):
            sub = "?"
        return _CTL_SOURCE.get(sub, sub)
    return rec["folder"]


def _property_label(rec, exp):
    if exp == "native":
        # first temporal operator after the coalition <...> (or a ')').
        return rec.get("property", "")
    # resilience / ctl: the config basename is the property / lifting variant.
    return tex_escape(rec.get("name", rec.get("property", "-")))


def _ordered(keys, order):
    seen = list(dict.fromkeys(keys))
    return [k for k in order if k in seen] + sorted(k for k in seen
                                                    if k not in order)


# Resilience: config (property) name -> alarm class, in decreasing severity.
# The first class whose property the analyzer proves (result TRUE) wins, so a
# program is placed in its most severe provable class.
_RES_CLASSES = [
    ("termination-exploitability", "critical++"),
    ("robust_non-termination", "critical"),
    ("termination-non-exploitability", "safe++"),
    ("termination-resilience", "safe"),
]
_RES_CLASS_COLS = ["critical++", "critical", "safe", "safe++"]
_RES_CLASS_HEAD = {
    "critical++": r"\textsc{critical}$^{++}$",
    "critical": r"\textsc{critical}",
    "safe": r"\textsc{safe}",
    "safe++": r"\textsc{safe}$^{++}$",
}


def _write_native_table(fh, records, caption, label):
    """Native ATL: the fixed NATIVE_GROUPS metadata (Domain | Benchmark | Source |
    ATL property | Exp.) with Dom./Time/\\tool filled from runs -- one sub-row per
    domain a benchmark ran under, ``--'' where no run is available."""
    idx = {}  # idx[config-name][domain] = (result, time)
    for r in records:
        idx.setdefault(r.get("name"), {})[str(r.get("domain", "")).lower()] = (
            r.get("result"), num_time(r))

    def verdict(res):
        return {"TRUE": r"\textsc{true}", "UNKNOWN": r"\textsc{unknown}",
                "TO": r"\textsc{t/o}"}.get(res, "--")

    def domlist(cfg):
        d = idx.get(cfg, {})
        return [x for x in _DOMAIN_ORDER if x in d] or [None]

    fh.write("\\begin{table}[t]\n")
    fh.write("  \\caption{%s}\n" % caption)
    fh.write("  \\label{%s}\n" % label)
    fh.write("  \\centering\n")
    fh.write("  \\scalebox{0.62}{\n")
    fh.write("    \\begin{NiceTabular}{c l l l c c c c}\n")
    fh.write("      \\CodeBefore\n")
    fh.write("        \\rowcolor{gray!50}{1}\n")
    fh.write("        \\rowcolors{2}{gray!25}{white}[respect-blocks]\n")
    fh.write("      \\Body\n")
    fh.write("      \\text{Domain} & \\text{Benchmark} & \\text{Source} & "
             "\\text{ATL property} & \\text{Dom.} & \\text{Time (s)} & "
             "\\text{Exp.} & \\text{\\tool} \\\\ \\hline\n")
    for gi, (glabel, rows) in enumerate(NATIVE_GROUPS):
        group_rows = sum(len(domlist(cfg)) for (_b, _s, _p, _e, cfg) in rows)
        gdone = False
        for (bench, src, prop, exp_v, cfg) in rows:
            doms = domlist(cfg)
            n = len(doms)
            for k, dom in enumerate(doms):
                c0 = ("\\Block{%d-1}{%s}" % (group_rows, glabel)
                      if not gdone else "")
                gdone = True
                if k == 0:
                    blk = lambda s: ("\\Block{%d-1}{%s}" % (n, s)) if n > 1 else s
                    cB, cS, cP, cE = blk(bench), blk(src), blk(prop), blk(exp_v)
                else:
                    cB = cS = cP = cE = ""
                if dom is None:
                    dtxt = ttxt = tool = "--"
                else:
                    res, t = idx[cfg][dom]
                    dtxt, ttxt, tool = dom, "%.1f" % t, verdict(res)
                fh.write("      %s & %s & %s & %s & %s & %s & %s & %s \\\\\n"
                         % (c0, cB, cS, cP, dtxt, ttxt, cE, tool))
        if gi < len(NATIVE_GROUPS) - 1:
            fh.write("      \\hline\n")
    fh.write("    \\end{NiceTabular}\n")
    fh.write("  }\n")
    fh.write("\\end{table}\n")


def write_latex_experiments(records, results_dir):
    """Emit one LaTeX table per experiment. Native ATL and CTL use the
    implementation.tex structure (Verified/Alarms/TO/Time); the resilience table
    instead classifies every program into critical++/critical/safe/safe++.
    Returns the paths written."""
    by_exp = {e: [] for e, _, _, _ in _EXPERIMENTS}
    for r in records:
        by_exp[_experiment_of(r)].append(r)

    written = []
    for exp, fname, label, caption in _EXPERIMENTS:
        path = os.path.join(results_dir, fname)
        with open(path, "w") as fh:
            fh.write("% Generated by script/runtest.py -- requires nicematrix.\n")
            recs = by_exp[exp]
            if not recs:
                fh.write("%% (no %s records)\n" % exp)
            elif exp == "resilience":
                _write_resilience_table(fh, recs, caption, label)
            elif exp == "ctl":
                _write_ctl_tables(fh, recs, caption, label)
            else:
                _write_verdict_table(fh, recs, exp, caption, label)
        written.append(path)
    return written


def _write_verdict_table(fh, records, exp, caption, label):
    """Native ATL / CTL per-benchmark table:
    Category | Benchmark | Players | ATL property | Dom. | Time (s) | \\#SC | Exp.
    | \\tool. Category is the application-domain folder; Players lists the game
    agents of the benchmark; there is one row per (benchmark, property, domain).
    A benchmark evaluated on several properties is not duplicated: its Benchmark
    and Players cells span all its rows with a \\Block. \\#SC is the number of
    sufficient conditions (defined leaves) found; Exp. is the expected verdict
    from the config; \\tool the returned verdict."""
    def verdict(res):
        return {"TRUE": r"\textsc{true}", "UNKNOWN": r"\textsc{unknown}",
                "TO": r"\textsc{t/o}"}.get(str(res).upper(), "--")

    def fmt_players(pl):
        return ", ".join(tex_escape(p) for p in pl) if pl else "--"

    # rows_by_cat[cat] = (bench, players, property, domain, result, time, exp, #SC)
    rows_by_cat = {}
    for r in records:
        cat = os.path.basename(os.path.dirname(r["file"]))   # app-domain folder
        bench = os.path.splitext(os.path.basename(r["file"]))[0]
        dom = _DOMAIN_LABEL.get(str(r.get("domain", "")).lower(),
                                tex_escape(str(r.get("domain", ""))))
        res = ("TO" if str(r.get("status", "")).upper() == "TO"
               else r.get("result"))
        rows_by_cat.setdefault(cat, []).append(
            (bench, r.get("players", []), r.get("property", ""), dom, res,
             num_time(r), r.get("expected", "-"), r.get("suff", 0)))

    fh.write("\\begin{table}[t]\n  \\caption{%s}\n  \\label{%s}\n  \\centering\n"
             % (caption, label))
    fh.write("  \\scalebox{0.62}{\n    \\begin{NiceTabular}{c l l l c c c c c}\n")
    fh.write("      \\CodeBefore\n        \\rowcolor{gray!50}{1}\n"
             "        \\rowcolors{2}{gray!25}{white}[respect-blocks]\n      \\Body\n")
    fh.write("      \\text{Category} & \\text{Benchmark} & \\text{Players} & "
             "\\text{ATL property} & \\text{Dom.} & \\text{Time (s)} & "
             "\\text{\\#SC} & \\text{Exp.} & \\text{\\tool} \\\\ \\hline\n")
    for cat in sorted(rows_by_cat):
        rows = sorted(rows_by_cat[cat], key=lambda x: (x[0], x[2], x[3]))
        n = len(rows)
        cat_done = False
        i = 0
        while i < n:
            bench = rows[i][0]
            j = i
            while j < n and rows[j][0] == bench:   # consecutive rows of one benchmark
                j += 1
            k = j - i
            for idx in range(i, j):
                (b, players, prop, dom, res, t, expd, suff) = rows[idx]
                c0 = ("\\Block{%d-1}{%s}" % (n, tex_escape(cat))
                      if not cat_done else "")
                cat_done = True
                if idx == i:
                    bcell = ("\\Block{%d-1}{%s}" % (k, tex_escape(b)) if k > 1
                             else tex_escape(b))
                    pcell = ("\\Block{%d-1}{%s}" % (k, fmt_players(players))
                             if k > 1 else fmt_players(players))
                else:
                    bcell = pcell = ""
                fh.write("      %s & %s & %s & %s & %s & %.1f & %s & %s & %s \\\\\n"
                         % (c0, bcell, pcell, tex_escape(prop), dom, t,
                            suff, verdict(expd), verdict(res)))
            i = j
        fh.write("      \\hline\n")
    fh.write("    \\end{NiceTabular}\n  }\n\\end{table}\n")


def _write_resilience_table(fh, records, caption, label):
    """Resilience: Benchmark | Configuration | critical++ | critical | safe |
    safe++ | TO | Time. Each program is classified once, into the most severe
    class whose property the analyzer proved."""
    class_names = {n for n, _ in _RES_CLASSES}
    # progs[(source, domain, file)] = {property verdicts, total time, timeouts}
    progs = {}
    for r in records:
        src = _source_of(r, "resilience")
        dom = str(r.get("domain", "boxes")).lower()
        p = progs.setdefault((src, dom, r["file"]),
                             {"res": {}, "time": 0.0, "to": set()})
        p["res"][r.get("name")] = r.get("result")
        p["time"] += num_time(r)
        if str(r.get("status", "")).upper() == "TO":
            p["to"].add(r.get("name"))

    # tally[source][domain] = {class: count, ..., "TO": n, "time": t}
    tally = {}
    for (src, dom, _f), p in progs.items():
        b = tally.setdefault(src, {}).setdefault(
            dom, dict({c: 0 for _n, c in _RES_CLASSES}, TO=0, time=0.0))
        b["time"] += p["time"]
        cls = next((c for n, c in _RES_CLASSES if p["res"].get(n) == "TRUE"),
                   None)
        if cls:
            b[cls] += 1
        elif p["to"] & class_names:
            b["TO"] += 1

    fh.write("\\begin{table}[t]\n")
    fh.write("  \\caption{%s}\n" % caption)
    fh.write("  \\label{%s}\n" % label)
    fh.write("  \\centering\n")
    fh.write("  \\scalebox{0.8}{\n")
    fh.write("    \\begin{NiceTabular}{c c r r r r r r}\n")
    fh.write("      \\CodeBefore\n")
    fh.write("        \\rowcolor{gray!50}{1}\n")
    fh.write("        \\rowcolors{2}{gray!25}{white}[respect-blocks]\n")
    fh.write("      \\Body\n")
    fh.write("      \\text{Benchmark} & \\text{Configuration} & %s & ~TO~ & "
             "~Time (s)~ \\\\ \\hline\n"
             % " & ".join(_RES_CLASS_HEAD[c] for c in _RES_CLASS_COLS))
    for src in _ordered(tally.keys(), _SOURCE_ORDER["resilience"]):
        doms = _ordered(tally[src].keys(), _DOMAIN_ORDER)
        src_done = False
        for dom in doms:
            b = tally[src][dom]
            c1 = ("\\Block{%d-1}{%s}" % (len(doms), tex_escape(src))
                  if not src_done else "")
            src_done = True
            counts = " & ".join(str(b[c]) for c in _RES_CLASS_COLS)
            fh.write("      %s & %s & %s & %d & %.1f \\\\\n"
                     % (c1, _DOMAIN_LABEL.get(dom, tex_escape(dom)),
                        counts, b["TO"], b["time"]))
    fh.write("    \\end{NiceTabular}\n")
    fh.write("  }\n")
    fh.write("\\end{table}\n")


# CTL lifting: config-name suffix -> (output column, category E=existential /
# A=universal). A base config (no suffix) is the CTL embedding; its category is
# taken from the base program (which also carries the robust/resilient configs).
_CTL_SUFFIX = [
    ("robust_reachability", "robust", "E"),
    ("resilience_reachability", "resilient", "E"),
    ("resilience", "resilient", "A"),
]
_CTL_HEAD = {"embeddingE": r"$\exists$CTL", "embeddingA": r"$\forall$CTL",
             "robust": r"\textsc{robust}", "resilient": r"\textsc{resilient}"}


def _ctl_output(name):
    """(output column, category, base) for a CTL config basename."""
    for suf, out, cat in _CTL_SUFFIX:
        if name.endswith("." + suf):
            return out, cat, name[:-(len(suf) + 1)]
    return "embedding", None, name


def _write_ctl_tables(fh, records, caption, label):
    """Two CTL tables (like the resilience one): existential properties with three
    ATL outputs (embedding / robust / resilient) and universal properties with two
    (embedding / resilient). Cells count programs proved \\textsc{true} for that
    output, per source and configuration; plus TO and Time (s) columns."""
    # category (E/A) of each base program, from its robust/resilient configs.
    cat = {}
    for r in records:
        _out, c, base = _ctl_output(r.get("name", ""))
        if c == "E":
            cat[base] = "E"
        elif c == "A":
            cat.setdefault(base, "A")

    def cell():
        return {"embedding": 0, "robust": 0, "resilient": 0, "TO": 0, "time": 0.0}

    agg = {"E": {}, "A": {}}          # agg[cat][source][domain] = cell
    for r in records:
        out, _c, base = _ctl_output(r.get("name", ""))
        table = cat.get(base)
        if table is None:
            continue
        src = _source_of(r, "ctl")
        dom = str(r.get("domain", "boxes")).lower()
        b = agg[table].setdefault(src, {}).setdefault(dom, cell())
        if str(r.get("status", "")).upper() == "TO":
            b["TO"] += 1
        else:
            if r.get("result") == "TRUE":
                b[out] += 1
            b["time"] += num_time(r)

    _ctl_one(fh, agg["E"], ["embeddingE", "robust", "resilient"],
             {"embeddingE": "embedding", "robust": "robust", "resilient": "resilient"},
             "CTL benchmarks -- existential properties ($\\mathsf{E}\\psi$): number "
             "of programs proved \\textsc{true} for each ATL lifting (the "
             "$\\exists$CTL embedding, the robust and the resilient version), per "
             "source and configuration.", "tab:ctl-exist")
    _ctl_one(fh, agg["A"], ["embeddingA", "resilient"],
             {"embeddingA": "embedding", "resilient": "resilient"},
             "CTL benchmarks -- universal properties ($\\mathsf{A}\\psi$): number "
             "of programs proved \\textsc{true} for each ATL lifting (the "
             "$\\forall$CTL embedding and the resilient version), per source and "
             "configuration.", "tab:ctl-univ")


def _ctl_one(fh, data, cols, key_of, caption, label):
    """One CTL table. cols are display keys; key_of maps a display key to the
    cell field it counts (both embeddingE and embeddingA count 'embedding')."""
    spec = "c c " + " ".join("r" for _ in range(len(cols) + 2))
    heads = " & ".join(_CTL_HEAD[c] for c in cols)
    fh.write("\\begin{table}[t]\n  \\caption{%s}\n  \\label{%s}\n  \\centering\n"
             % (caption, label))
    fh.write("  \\scalebox{0.8}{\n    \\begin{NiceTabular}{%s}\n" % spec)
    fh.write("      \\CodeBefore\n        \\rowcolor{gray!50}{1}\n"
             "        \\rowcolors{2}{gray!25}{white}[respect-blocks]\n      \\Body\n")
    fh.write("      \\text{Benchmark} & \\text{Configuration} & %s & ~TO~ & "
             "~Time (s)~ \\\\ \\hline\n" % heads)
    for src in _ordered(data.keys(), _SOURCE_ORDER["ctl"]):
        doms = _ordered(data[src].keys(), _DOMAIN_ORDER)
        src_done = False
        for dom in doms:
            b = data[src][dom]
            c1 = ("\\Block{%d-1}{%s}" % (len(doms), tex_escape(src))
                  if not src_done else "")
            src_done = True
            counts = " & ".join(str(b[key_of[c]]) for c in cols)
            fh.write("      %s & %s & %s & %d & %.1f \\\\\n"
                     % (c1, _DOMAIN_LABEL.get(dom, tex_escape(dom)),
                        counts, b["TO"], b["time"]))
    fh.write("    \\end{NiceTabular}\n  }\n\\end{table}\n")


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #

def write_reports(records, results_dir, charts, args):
    """Emit the selected report formats from the current records.

    Cheap enough to call repeatedly (rendering is milliseconds vs. seconds of
    analysis), so it doubles as the --live refresh; pass charts={} mid-run to
    skip the slow matplotlib figures.
    """
    recs = sorted(records, key=lambda r: (r["group"], r["file"]))
    if args.csv:
        write_csv(recs, os.path.join(results_dir, "stats.csv"))
    if args.latex:
        write_latex_experiments(recs, results_dir)
    if args.html:
        write_html(recs, results_dir, charts, args.group_by, args.compact)


def main():
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("-e", "--exec", default="./main.exe", help="analyzer executable")
    ap.add_argument("-o", "--out", default="regression_out",
                    help="scratch dir for the produced JSON summaries")
    ap.add_argument("-d", "--results", default="results", help="report output directory")
    ap.add_argument("--tests", default="tests", help="benchmarks root")
    ap.add_argument("-g", "--groups", default=",".join(GROUP_MODES),
                    help="comma-separated test groups to run")
    ap.add_argument("-t", "--timeout", type=int, default=60, help="per-test timeout (s)")
    ap.add_argument("-j", "--jobs", type=int, default=os.cpu_count() or 1, help="parallel jobs")
    ap.add_argument("-f", "--filter", default="", help="only run tests whose .c path matches this regex")
    ap.add_argument("--html", action="store_true", help="emit the HTML report")
    ap.add_argument("--latex", action="store_true", help="emit the LaTeX table")
    ap.add_argument("--csv", action="store_true", help="emit the CSV stats")
    ap.add_argument("--group-by", choices=list(GROUP_KEYS), default="dir",
                    help="how to bucket the HTML table sections (default: dir)")
    ap.add_argument("--no-stats", action="store_true",
                    help="do not generate the matplotlib stats figures")
    ap.add_argument("--live", action="store_true",
                    help="regenerate the reports after each test completes "
                         "(charts are still deferred to the final pass)")
    ap.add_argument("--compact", action="store_true",
                    help="HTML: only the per-folder result tables -- no "
                         "per-test detail pages, no Statistics tab/charts")
    ap.add_argument("--short", action="store_true",
                    help="quick run: prune the large SV-COMP subtrees "
                         "(%s)" % ", ".join(sorted(SHORT_SKIP_FOLDERS)))
    args = ap.parse_args()

    # No explicit format selected -> emit them all.
    if not (args.html or args.latex or args.csv):
        args.html = args.latex = args.csv = True

    executable = args.exec if os.path.isabs(args.exec) else os.path.join(ROOT, args.exec)
    if not (os.path.isfile(executable) and os.access(executable, os.X_OK)):
        sys.exit(f"error: analyzer '{executable}' not found or not executable")

    out = os.path.join(ROOT, args.out)
    results_dir = os.path.join(ROOT, args.results)
    tests_dir = os.path.join(ROOT, args.tests)
    groups = [g for g in args.groups.split(",") if g]

    bench = list(discover(tests_dir, groups, args.filter, args.short))
    if not bench:
        sys.exit("no benchmarks matched.")

    if os.path.isdir(out):
        shutil.rmtree(out)
    os.makedirs(out)
    os.makedirs(results_dir, exist_ok=True)

    print(f"== running {len(bench)} benchmark(s)  (jobs={args.jobs}, timeout={args.timeout}s) ==")
    records = []
    with cf.ThreadPoolExecutor(max_workers=args.jobs) as ex:
        futs = [ex.submit(run_one, executable, g, fld, c, cfg, out, args.timeout,
                          "isolated", REPORT_FLAGS)
                for (g, fld, c, cfg) in bench]
        for fut in cf.as_completed(futs):
            r = fut.result()
            records.append(r)
            print(f"  {r['status']:<7} {r['file']}")
            if args.live:
                # Refresh the reports as results trickle in (charts deferred).
                write_reports(records, results_dir, {}, args)
    records.sort(key=lambda r: (r["group"], r["file"]))

    # Stats figures (one per grouping key) -- only needed for the HTML report.
    charts = {}
    if args.html and not args.no_stats and not args.compact:
        for key in GROUP_KEYS:
            png = generate_stats(records, results_dir, key)
            if png:
                charts[key] = png
        if not charts:
            print("  (matplotlib unavailable — stats figures skipped)")

    print("\n== reports ==")
    # Final pass: same writers as --live, but with the charts included.
    write_reports(records, results_dir, charts, args)
    if args.csv:
        print(f"  CSV    {os.path.relpath(os.path.join(results_dir, 'stats.csv'), ROOT)}")
    if args.latex:
        for _f in ("exp_native_atl.tex", "exp_resilience.tex", "exp_ctl.tex"):
            print(f"  LaTeX  {os.path.relpath(os.path.join(results_dir, _f), ROOT)}")
    if args.html:
        print(f"  HTML   {os.path.relpath(os.path.join(results_dir, 'index.html'), ROOT)}")

    # Exit nonzero if any test failed/timed out (handy for CI).
    bad = sum(1 for r in records if r["status"] in ("FAIL", "TO"))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
