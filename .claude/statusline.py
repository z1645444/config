#!/usr/bin/env python3
"""Claude Code statusLine command.

Reads JSON from stdin (Claude Code), renders a status line.

Context section notes:
- Prefers stdin context_window.current_usage over transcript-derived usage.
- Excludes output_tokens: next-turn input/cache_read already includes them.
- RESERVE_OUTPUT_TOKENS is subtracted from the limit to better match
  Claude Code's effective window for auto-compact thresholds.
"""

import json
import os
import subprocess
import sys

# Max output tokens Claude Code may reserve per model.
# Tune after comparing against /context output if needed.
RESERVE_OUTPUT_TOKENS = 32000

E = chr(27) + "["  # ESC [
Z = E + "0m"


def C(n, s):
    return E + "38;5;" + str(n) + "m" + s + Z


def T(n):
    n = int(n)
    if n >= 1000000:
        return str(round(n / 1000000.0, 1)).rstrip("0").rstrip(".") + "M"
    if n >= 1000:
        return str(int(round(n / 1000.0))) + "K"
    return str(n)


def G(o, k):
    v = o.get(k)
    return v if isinstance(v, dict) else {}


def S(o, k):
    v = o.get(k)
    return v if isinstance(v, str) else ""


def main():
    try:
        raw = sys.stdin.read()
    except Exception:
        raw = ""
    try:
        d = json.loads(raw) if raw.strip() else {}
    except Exception:
        d = {}
    if not isinstance(d, dict):
        d = {}

    md = G(d, "model")
    mid = S(md, "id") or S(md, "model")
    mnm = S(md, "display_name") or S(md, "name")
    h, sep, tl = mid.partition("--")
    prov, tail = (h, tl) if sep else ("", "")
    name = mnm or tail or mid
    if not prov and (mid == "claude" or mid.startswith("claude-")):
        prov = "anthropic"
    mseg = (prov + "/" + name) if (prov and name) else name

    tp = S(d, "transcript_path")
    usage = None
    effort = None
    edits = []
    if tp and os.path.isfile(tp):
        try:
            for ln in open(tp, "rb"):
                if (
                    b"usage" not in ln
                    and b"tool_use" not in ln
                    and b"effort" not in ln
                    and b"reasoning" not in ln
                    and b"thinking" not in ln
                ):
                    continue
                try:
                    o = json.loads(ln)
                except Exception:
                    continue
                if not isinstance(o, dict):
                    continue
                if o.get("type") != "assistant" or o.get("isSidechain") is True:
                    continue
                m = o.get("message") if isinstance(o.get("message"), dict) else {}
                u = m.get("usage")
                if isinstance(u, dict) and (m.get("model") or "") != "<synthetic>":
                    usage = u
                for k in ("reasoning_effort", "effort", "reasoning", "thinking"):
                    v = o.get(k)
                    if v is None:
                        v = m.get(k)
                    lv = ""
                    if isinstance(v, str):
                        lv = v
                    elif isinstance(v, dict):
                        for kk in ("level", "effort", "reasoning_effort"):
                            if isinstance(v.get(kk), str) and v.get(kk):
                                lv = v.get(kk)
                                break
                    if lv:
                        effort = lv
                cl = m.get("content")
                if isinstance(cl, list):
                    for blk in cl:
                        if not isinstance(blk, dict) or blk.get("type") != "tool_use":
                            continue
                        nm = blk.get("name") or ""
                        inp = blk.get("input") if isinstance(blk.get("input"), dict) else {}
                        p = inp.get("file_path") or inp.get("notebook_path") or ""
                        if not p:
                            continue
                        if nm == "Write":
                            edits.append(("+", p))
                        elif nm in ("Edit", "MultiEdit", "NotebookEdit"):
                            edits.append(("-", p))
        except Exception:
            pass

    cw = G(d, "context_window")
    try:
        limit = int(cw.get("context_window_size") or 0)
    except Exception:
        limit = 0

    used = 0
    # Only input-side tokens; output_tokens are already included in
    # next-turn input/cache_read and would double-count here.
    keys = ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens")
    # Prefer Claude Code's own current_usage over transcript-derived usage.
    for uu in (G(cw, "current_usage"), usage):
        if used > 0:
            break
        if isinstance(uu, dict):
            for k in keys:
                try:
                    used += int(uu.get(k) or 0)
                except Exception:
                    pass

    pct = None
    if limit > 0 and used > 0:
        denominator = limit - RESERVE_OUTPUT_TOKENS if limit > RESERVE_OUTPUT_TOKENS else limit
        pct = used * 100.0 / denominator
    else:
        v = cw.get("used_percentage")
        if isinstance(v, (int, float)):
            pct = float(v)
    if pct is not None:
        pct = max(0.0, min(100.0, pct))

    segs = []
    colr = 245
    if name:
        segs.append(C(colr, mseg))
    ep = S(G(d, "effort"), "level") or effort
    if ep:
        segs.append(C(colr, "think:" + ep))
    elif G(d, "thinking").get("enabled") is True:
        segs.append(C(colr, "think"))
    if limit > 0:
        segs.append(C(colr, "ctx " + T(limit)))
    if pct is not None:
        pct_colr = 196 if pct > 80 else (178 if pct > 50 else 245)
        fill = max(0, min(10, int(pct // 10)))
        bar = chr(9608) * fill + chr(9617) * (10 - fill)
        txt = bar + " " + str(int(round(pct))) + "%"
        if used > 0:
            txt += " " + T(used)
        segs.append(C(pct_colr, txt))
    cwd = S(G(d, "workspace"), "current_dir") or S(d, "cwd") or os.getcwd()
    if not os.path.isdir(cwd):
        cwd = os.getcwd()
    home = os.path.expanduser("~")
    disp = cwd
    if home and disp == home:
        disp = "~"
    elif home and disp.startswith(home + "/"):
        disp = "~" + disp[len(home):]
    parent, base = os.path.split(disp)
    dseg = C(colr, parent) + " " if parent else ""
    dseg += C(colr, base)
    env = dict(os.environ)
    env["GIT_OPTIONAL_LOCKS"] = "0"

    def git(*a):
        try:
            r = subprocess.run(
                ["git"] + list(a),
                cwd=cwd,
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.DEVNULL,
                timeout=0.25,
            )
            return r.stdout.decode("utf-8", "replace").strip()
        except Exception:
            return ""

    if git("rev-parse", "--is-inside-work-tree") == "true":
        br = git("--no-optional-locks", "rev-parse", "--abbrev-ref", "HEAD")
        if br and br != "HEAD":
            dseg += " " + C(colr, br)
        if git("--no-optional-locks", "status", "--porcelain"):
            dseg += " " + C(colr, "*")
    segs.append(dseg)
    if edits:
        seen = set()
        plus = 0
        minus = 0
        for mark, p in edits:
            ap = os.path.normpath(p if os.path.isabs(p) else os.path.join(cwd, p))
            if ap in seen:
                continue
            seen.add(ap)
            if mark == "+":
                plus += 1
            else:
                minus += 1
        cnt = []
        if plus > 0:
            cnt.append(C(149, "+" + str(plus)))
        if minus > 0:
            cnt.append(C(204, "-" + str(minus)))
        if cnt:
            segs.append(" ".join(cnt))
    sys.stdout.write("  ".join([s for s in segs if s]))


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        sys.stderr.write("statusline error: %s\n" % exc)
        sys.exit(0)
