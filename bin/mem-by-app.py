#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""mem-by-app - group memory usage by application (Linux / cgroup v2).

Two numbers per application, both from /proc/<pid>/status, summed over the app's
processes (so they follow the usual top(1) RES / %MEM convention):

  rss (%mem)   sum of VmRSS ("RES" in top/ps) and its share of MemTotal.
               This is the number people normally look at, but it counts every
               shared page once per process, so it overstates real footprint.

  reclaimable  sum of RssFile: the file-backed part of that rss. Under memory
               pressure the kernel can drop these pages (dirty ones are written
               back first), so this is the most it can take back from the app.
               rss - reclaimable = anon + shmem, which cannot be dropped.

Usage:
  ./mem-by-app.py                     table sorted by rss (default)
  ./mem-by-app.py --sort after        sort by memory left after reclaiming file cache
  ./mem-by-app.py --top 40            show top 40 rows
  ./mem-by-app.py --others 1          merge apps below 1%% of memory into "Others" (default)
  ./mem-by-app.py --no-others         list every application separately
  ./mem-by-app.py --detail chrome     expand matching apps (processes + cgroups)
  ./mem-by-app.py --verbose           full legend, reconciliation, orphan cgroup list
  ./mem-by-app.py --csv > mem.csv     CSV output
  ./mem-by-app.py --json              JSON output

If this script runs inside a container it automatically reads the host through the
read-only /run/host mounts.
"""
import os, re, sys, json, argparse, unicodedata

# ---------- data source: prefer host bind mounts, else this machine ----------
def pick_source():
    for proc, cg, desc in (
        ("/run/host/proc", "/run/host/sys/fs/cgroup", "host (read through read-only /run/host mounts)"),
        ("/proc", "/sys/fs/cgroup", "local machine"),
    ):
        try:
            if os.path.isdir(proc + "/1") and os.path.isdir(cg + "/user.slice"):
                return proc, cg, desc
        except OSError:
            pass
        try:
            if os.path.isfile(cg + "/cgroup.controllers") and os.path.isdir(proc + "/1"):
                return proc, cg, desc
        except OSError:
            pass
    return "/proc", "/sys/fs/cgroup", "local machine"

# ---------- application identification rules (first match wins) ----------
RULES = [
    (r"/opt/google/chrome",                        "Google Chrome"),
    (r"chrome_crashpad",                           "Google Chrome"),
    (r"/usr/lib/chromium|/usr/bin/chromium|chromium-browser|/snap/chromium", "Chromium"),
    (r"/extension-host$|openai-bundled/chrome/",   "Chrome extension host (Codex plugin)"),
    (r"/opt/codex-desktop/ChatGPT",                "Codex Desktop (Electron)"),
    (r"/opt/codex-desktop/resources/codex",        "Codex engine (app-server)"),
    (r"codex-linux-sandbox|codex-sandbox|/\.codex/tmp/arg0/", "Codex engine (app-server)"),
    (r"/usr/bin/konsole|/usr/bin/yakuake",         "Konsole terminal"),
    (r"(^|/)tmux(:|$)",                            "tmux sessions"),
    (r"/usr/bin/dolphin",                          "Dolphin (file manager)"),
    (r"plasmashell",                               "KDE: plasmashell"),
    (r"kwin_wayland|kwin_x11|Xwayland",            "KDE: KWin (compositor)"),
    (r"kded5|kded6|kdeinit",                       "KDE: kded (daemons)"),
    (r"krunner",                                   "KDE: krunner"),
    (r"xdg-desktop-portal|xdg-document-portal|xdg-permission-store", "KDE: xdg-desktop-portal"),
    (r"plasma-ksmserver|ksmserver|startplasma",    "KDE: ksmserver (session)"),
    (r"polkit",                                    "KDE: polkit agent"),
    (r"powerdevil",                                "KDE: powerdevil"),
    (r"kaccess|kactivitymanager|ksystemstats|kdeconnect", "KDE: misc components"),
    (r"discover",                                  "KDE: Discover notifier"),
    (r"colord|kwalletd|gvfs|geoclue|dconf|xdg-user-dirs|fcitx|ibus", "Other desktop services"),
    (r"pipewire|wireplumber",                      "PipeWire (audio)"),
    (r"tailscaled",                                "Tailscale VPN"),
    (r"dockerd|containerd",                        "Container runtime (docker/containerd)"),
    (r"conmon|runc|podman",                        "Container supervisor (conmon/podman)"),
    (r"systemd-journald",                          "systemd-journald (logs)"),
    (r"^systemd$|/usr/lib/systemd/systemd$",        "systemd (init)"),
    (r"systemd-",                                  "systemd services"),
    (r"sshd",                                      "SSH server (sshd)"),
    (r"^ssh[: ]|/usr/bin/ssh|ssh-agent",           "SSH client (incl. mux)"),
    (r"fail2ban",                                  "fail2ban"),
    (r"snapd",                                     "snapd"),
    (r"fwupd|cups|upower|sddm|/Xorg|ModemManager|NetworkManager|dbus-daemon|udisksd|accounts-daemon|rtkit|avahi", "System services (sddm/Xorg/upower/cups)"),
    (r"synology|cloud-drive",                      "Synology Drive"),
    (r"(^|/)codex( |$)|/codex/|codex-",            "Codex CLI (misc)"),
    (r"^bash$|^zsh$|^sh$|/bin/bash|/bin/sh|^dash$", "Shell / scripts"),
]
RULES = [(re.compile(p, re.I), n) for p, n in RULES]
MONITOR_APP = "Container supervisor (conmon/podman)"
RESIDUAL = "orphan container cgroup (conmon only)"

def read(path, limit=None):
    try:
        with open(path, "r", errors="replace") as fh:
            return fh.read(limit) if limit else fh.read()
    except OSError:
        return None

def self_container_id():
    txt = read("/run/.containerenv") or read("/.dockerenv") or ""
    m = re.search(r'id="([0-9a-f]{12})', txt)
    return m.group(1) if m else None

def key_of(path):
    """'/../../app.slice/x.scope' -> 'app.slice/x.scope'; root cgroup -> ''"""
    return "/".join(p for p in path.split("/") if p and p != "..")

def resolve_app(pid, hp):
    cmd = read(f"{hp}/{pid}/cmdline") or ""
    argv0 = (cmd.split("\x00") or [""])[0]
    status = read(f"{hp}/{pid}/status") or ""
    m = re.search(r"^Name:\s*(.+)$", status, re.M)
    comm = m.group(1).strip() if m else ""
    try:
        exe = os.readlink(f"{hp}/{pid}/exe")
    except OSError:
        exe = ""
    for pat, name in RULES:
        for k in (exe, argv0, comm):
            if k and pat.search(k):
                return name
    base = os.path.basename(argv0 or exe or comm) or comm or "unknown"
    if base in ("python3", "python", "node"):
        return f"{comm} ({base})" if comm else base
    return base

def collect_procs(hp):
    procs, kernel = [], 0
    for entry in os.listdir(hp):
        if not entry.isdigit():
            continue
        cmd = read(f"{hp}/{entry}/cmdline") or ""
        if not cmd.strip("\x00").strip():          # kernel thread: no cmdline
            kernel += 1
            continue
        status = read(f"{hp}/{entry}/status")
        if not status:
            continue
        p = {"pid": int(entry), "rss": 0, "swap": 0, "rss_anon": 0, "rss_file": 0, "rss_shmem": 0}
        for line in status.splitlines():
            if line.startswith("Name:"):
                p["name"] = line.split(":", 1)[1].strip()
            elif line.startswith("VmRSS:"):
                p["rss"] = int(line.split()[1])
            elif line.startswith("VmSwap:"):
                p["swap"] = int(line.split()[1])
            elif line.startswith("RssAnon:"):
                p["rss_anon"] = int(line.split()[1])
            elif line.startswith("RssFile:"):
                p["rss_file"] = int(line.split()[1])
            elif line.startswith("RssShmem:"):
                p["rss_shmem"] = int(line.split()[1])
        cg = read(f"{hp}/{entry}/cgroup") or ""
        raw = next((l[3:].strip() for l in cg.splitlines() if l.startswith("0::")), "")
        p["raw_cgroup"] = raw
        p["key"] = key_of(raw)
        p["cmd"] = cmd.replace("\x00", " ").strip()[:200]
        p["app"] = resolve_app(entry, hp)
        procs.append(p)
    return procs, kernel

def collect_tree(cgroot):
    nodes = {}
    for root, dirs, files in os.walk(cgroot):
        if "memory.stat" not in files:
            dirs[:] = []
            continue
        rel = os.path.relpath(root, cgroot)
        rel = "/" if rel == "." else "/" + rel
        node = {"path": rel, "key": key_of(rel), "kids": []}
        cur = read(os.path.join(root, "memory.current"))
        node["current"] = int(cur) if cur and cur.strip().isdigit() else 0
        st = read(os.path.join(root, "memory.stat")) or ""
        for line in st.splitlines():
            f = line.split()
            if len(f) == 2 and f[1].isdigit():
                node[f[0]] = int(f[1])
        nodes[rel] = node
    for path, node in nodes.items():
        parent = os.path.dirname(path.rstrip("/"))
        if parent in nodes:
            nodes[parent]["kids"].append(path)
    for node in nodes.values():                    # own charge = self - sum(children)
        for f in ("current", "anon", "shmem", "file", "kernel", "slab_reclaimable"):
            node["own_" + f] = max(0, node.get(f, 0) - sum(k.get(f, 0) for k in (nodes[c] for c in node["kids"])))
    return nodes

def match_node(p, nodes, cid):
    k = p["key"]
    if k:
        best = None
        for path, node in nodes.items():
            nk = node["key"]
            if nk and (nk == k or nk.endswith("/" + k) or k.endswith("/" + nk)):
                if best is None or len(nk) > len(nodes[best]["key"]):
                    best = path
        return best
    if cid:                                        # container process: cgroup view truncated to "/"
        for path in nodes:
            if cid in path:
                return path
    return None

def container_names():
    import sqlite3, glob
    out = {}
    for cand in glob.glob("/run/host/home/*/.local/share/containers/storage/db.sql"):
        try:
            con = sqlite3.connect(f"file:{cand}?immutable=1", uri=True)
            out.update({i[:12]: n for i, n in con.execute("select ID, Name from ContainerConfig")})
            con.close()
        except Exception:
            pass
    return out

def label(path, names):
    m = re.search(r"libpod-([0-9a-f]{12})", path)
    if m:
        return f"container {names.get(m.group(1), m.group(1))}"
    if path in ("/", ""):
        return "this container (cgroup view truncated)"
    return path.rstrip("/").split("/")[-1].replace("\\x2d", "-")

def hum(b):
    b = float(b or 0)
    for u in ("B", "K", "M", "G", "T"):
        if b < 1024 or u == "T":
            return f"{b:.1f}{u}" if b else "0"
        b /= 1024

def h0(b):
    return "-" if not b else hum(b)

# ---------- terminal alignment: CJK/fullwidth chars occupy 2 columns ----------
def disp_width(s):
    w = 0
    for ch in s:
        if unicodedata.combining(ch):
            continue
        w += 2 if unicodedata.east_asian_width(ch) in ("W", "F") else 1
    return w

def trunc(s, width):
    s = str(s)
    if disp_width(s) <= width:
        return s
    out, w = "", 0
    for ch in s:
        cw = disp_width(ch)
        if w + cw > width - 1:
            break
        out += ch
        w += cw
    return out + "..."

def pad(s, width, align="<"):
    s = trunc(s, width)
    fill = max(0, width - disp_width(s))
    if align == ">":
        return " " * fill + s
    if align == "^":
        left = fill // 2
        return " " * left + s + " " * (fill - left)
    return s + " " * fill

def procs_label(n):
    return f"{n} proc" if n == 1 else f"{n} procs"

RSS_PARTS = ("rss", "swap", "rss_anon", "rss_file", "rss_shmem")

def new_app(name):
    a = {"app": name, "procs": [], "current": 0, "anon": 0, "shmem": 0, "file": 0, "kde": 0, "seats": {}}
    for k in RSS_PARTS:
        a[k] = 0
    return a

def main():
    ap = argparse.ArgumentParser(description="Group memory usage by application (cgroup v2).")
    ap.add_argument("--top", type=int, default=25, help="rows to show (default 25)")
    ap.add_argument("--others", type=float, default=1.0,
                    help="merge apps whose rss is below this percentage of memory (default 1)")
    ap.add_argument("--others-basis", choices=["total", "used"], default="total",
                    help="denominator for the Others threshold: total memory (default) or used memory")
    ap.add_argument("--no-others", action="store_true", help="do not merge small apps")
    ap.add_argument("--sort", choices=["rss", "after", "reclaimable"], default="rss",
                    help="sort key: rss (default), after (= rss - reclaimable) or reclaimable")
    ap.add_argument("--detail", default=None, help="regex: expand matching apps (processes + cgroups)")
    ap.add_argument("--csv", action="store_true", help="CSV output")
    ap.add_argument("--json", action="store_true", help="JSON output")
    ap.add_argument("--verbose", action="store_true",
                    help="print full legend, reconciliation and orphan cgroup list")
    ap.add_argument("--residual-min", type=float, default=128,
                    help="only list orphan cgroups above this size in MiB (default 128)")
    ap.add_argument("--proc-root", default=None, help="override /proc path")
    ap.add_argument("--cgroup-root", default=None, help="override cgroup2 mount point")
    args = ap.parse_args()

    hp, cgroot, src = pick_source()
    if args.proc_root or args.cgroup_root:
        hp = args.proc_root or hp
        cgroot = args.cgroup_root or cgroot
        src = f"manual {hp} / {cgroot}"
    procs, kernel = collect_procs(hp)
    nodes = collect_tree(cgroot)
    cid = self_container_id()
    names = container_names()

    by_node, presence = {}, {}
    for p in procs:
        path = match_node(p, nodes, cid)
        p["cgroup_path"] = path
        if path:
            by_node.setdefault(path, []).append(p)
            presence.setdefault(p["app"], {}).setdefault(path, 0)
            presence[p["app"]][path] += 1

    apps, residual = {}, []
    for path, node in nodes.items():
        own = node["own_current"]
        inside = by_node.get(path, [])
        if not inside:
            if own > args.residual_min * 1024 * 1024:
                residual.append((path, node))
            continue
        owner = max(inside, key=lambda p: p["rss"])["app"]
        if all(p["app"] == MONITOR_APP for p in inside):
            owner = RESIDUAL
        a = apps.setdefault(owner, new_app(owner))
        a["current"] += own
        a["anon"] += node["own_anon"]
        a["shmem"] += node["own_shmem"]
        a["file"] += node["own_file"]
        a["kde"] += (node["own_anon"] + node["own_shmem"]
                     + max(0, node["own_kernel"] - node["own_slab_reclaimable"]))
        a["seats"][path] = a["seats"].get(path, 0) + own

    for p in procs:
        a = apps.setdefault(p["app"], new_app(p["app"]))
        a["procs"].append(p)
        for k in RSS_PARTS:
            a[k] += p.get(k, 0)

    mi = {}
    for line in (read(hp + "/meminfo") or "").splitlines():
        if ":" in line:
            k, v = line.split(":", 1)
            m = re.match(r"\s*(\d+)", v)
            if m:
                mi[k] = int(m.group(1))
    tot, av = mi.get("MemTotal", 0), mi.get("MemAvailable", 0)
    used = tot - av

    keyf = {"rss": lambda a: a["rss"],
            "after": lambda a: a["rss"] - a["rss_file"],
            "reclaimable": lambda a: a["rss_file"]}[args.sort]
    rows = sorted([a for a in apps.values() if a["procs"]], key=lambda a: -keyf(a))

    # merge small apps into a single "Others" row (threshold on rss)
    others = None
    if not args.no_others:
        base = used if args.others_basis == "used" else tot
        thresh = args.others / 100.0 * base            # rss is in kB, meminfo base in kB
        big = [a for a in rows if a["rss"] >= thresh]
        small = [a for a in rows if a["rss"] < thresh]
        if small:
            basis = "used" if args.others_basis == "used" else "total"
            others = new_app(f"Others ({len(small)} apps, <{args.others:g}% of {basis})")
            for a in small:
                for k in ("current", "anon", "shmem", "file", "kde") + RSS_PARTS:
                    others[k] += a[k]
                others["procs"] += a["procs"]
                others.setdefault("members", []).append(a)
                for path, own in a["seats"].items():
                    others["seats"][path] = others["seats"].get(path, 0) + own
        rows = big + ([others] if others else [])
    all_rows = rows

    def capital(obj):
        """snake_case keys -> CapitalCase (each part capitalized), recursively."""
        if isinstance(obj, list):
            return [capital(x) for x in obj]
        if isinstance(obj, dict):
            out = {}
            for k, v in obj.items():
                key = "".join(w[:1].upper() + w[1:] for w in str(k).split("_") if w)
                out[key] = capital(v)
            return out
        return obj

    if args.json:
        print(json.dumps(capital({"source": src,
                          "apps": [{**{k: v for k, v in a.items() if k != "procs"},
                                    "mem_pct": round(a["rss"] / tot * 100, 2) if tot else 0,
                                    "after_reclaim": a["rss"] - a["rss_file"],
                                    "after_reclaim_pct": round((a["rss"] - a["rss_file"]) / tot * 100, 2) if tot else 0,
                                    "pinned": a["rss"] - a["rss_file"],
                                    "kde": a["kde"],
                                    "kdePct": round((a["kde"]/1024) / tot * 100, 2) if tot else 0,
                                    "reclaimable": a["rss_file"]} for a in all_rows],
                          "orphan_cgroups": [{"path": p, "own": n["own_current"], "shmem": n["own_shmem"]}
                                             for p, n in residual]}),
                         ensure_ascii=False, indent=2))
        return
    if args.csv:
        print("App,TopRssMiB,TopRssPct,PinnedMiB,PinnedPct,KdeMiB,KdePct,Procs")
        for a in all_rows[:args.top]:
            after = a["rss"] - a["rss_file"]
            pr = a["rss"] / tot * 100 if tot else 0
            pa = after / tot * 100 if tot else 0
            print(f'"{a["app"]}",{a["rss"]/1024:.1f},{pr:.2f},{after/1024:.1f},{pa:.2f},'
                  f'{a["kde"]/2**20:.1f},{(a["kde"]/1024)/tot*100 if tot else 0:.2f},{len(a["procs"])}')
        return

    swap_used = mi.get("SwapTotal", 0) - mi.get("SwapFree", 0)
    if args.verbose:
        print(f"source: {src}")
        print(f"system: total {hum(tot*1024)}  used {hum(used*1024)} ({used/tot*100:.0f}%)  "
              f"available {hum(av*1024)}  swap {hum(swap_used*1024)}/{hum(mi.get('SwapTotal',0)*1024)} used")
        print("columns: TopRss = sum of VmRSS over the app processes (top/ps \"RES\"), share of "
              "MemTotal - the usual number, but a shared page is counted once per process")
        print("         KDE = the app's own cgroup charge that cannot be reclaimed (anon + shmem + "
              "unreclaimable kernel) - the per-app counterpart of KDE's Memory Usage widget")
        print("         Pinned = that rss minus its file-backed pages = anon + shmem: what stays "
              "resident after the kernel drops the reclaimable pages (its share of MemTotal)")
        print("         the Total row shows the system value for KDE: (MemTotal - MemAvailable) / "
              "MemTotal, i.e. exactly what the KDE widget displays")
        print()

    def after_of(a):
        return a["rss"] - a["rss_file"]                 # kB, = anon + shmem

    def pct(kb):
        return kb / tot * 100 if tot else 0.0

    def fp(p):
        """百分比：>=1 取整；<1 保留 1 位小数并去掉前导 0（.7%）；进位到 1.0 时显示 1%"""
        if p >= 1:
            return f"{p:.0f}%"
        txt = f"{p:.1f}"
        return "1%" if txt.startswith("1") else txt[1:] + "%"

    SIZE_W, PCT_W = 7, 6          # 数值列内部再分两段：尺寸右对齐、百分比右对齐，保证竖向对齐
    def cell(kb_or_bytes, is_bytes=False):
        kb = kb_or_bytes / 1024 if is_bytes else kb_or_bytes
        return pad(hum(kb * 1024), SIZE_W, ">") + " " + pad("(" + fp(pct(kb)) + ")", PCT_W, ">")

    COLS = [("App", 40, "<"), ("TopRss", 14, "^"), ("KDE", 14, "^"), ("Pinned", 14, "^")]
    SEP = "  "                                          # 列间距比原来加宽 50%（1 -> 2 空格）

    def render(cells):
        return SEP.join(pad(c, w, a) for c, (_, w, a) in zip(cells, COLS))

    def cells_of(a, name=None):
        return [a["app"] if name is None else name,
                cell(a["rss"]),
                cell(a["kde"], is_bytes=True),
                cell(after_of(a))]

    line = "-" * (sum(w for _, w, _ in COLS) + len(SEP) * (len(COLS) - 1))
    print(render([h for h, _, _ in COLS]).rstrip())
    print(line)
    shown = list(all_rows[:args.top])
    if others is not None and others not in shown:
        shown.append(others)                           # the Others row is always printed last
    for a in shown:
        print(render(cells_of(a)))
    print(line)
    t_rss = sum(a["rss"] for a in all_rows)
    t_after = sum(after_of(a) for a in all_rows)
    # KDE 列的 Total 用系统真值（= KDE 部件显示的那个百分比），应用行是同口径的可归属部分
    kde_sys = tot - av
    print(render(["Total", cell(t_rss), cell(kde_sys), cell(t_after)]))
    print(line)
    for name, formula in (
        ("TopRss", "= ΣVmRSS"),
        ("KDE", "= Σcg(anon+shmem+kernel-reclSlab)"),
        ("Pinned", "= TopRss - ΣRssFile"),
    ):
        print(f"{pad(name, 7)}{formula}")

    if args.verbose:
        r_cur = sum(n["own_current"] for _, n in residual)
        print(f'  reconciliation: cgroup accounted total '
              f'{hum(sum(a["current"] for a in all_rows) + r_cur)}; '
              f'anon {hum(mi.get("AnonPages",0)*1024)} = AnonPages; '
              f'tmpfs-shared {hum(mi.get("Shmem",0)*1024)} = Shmem; {kernel} kernel threads excluded')
        if residual:
            print("  orphan cgroups (charged but no processes - page cache/tmpfs of exited scopes):")
            for path, n in sorted(residual, key=lambda x: -x[1]["own_current"])[:12]:
                print(f'    {pad("own", 6)}{pad(hum(n["own_current"]), 9, ">")}  '
                      f'{pad("anon", 6)}{pad(hum(n["own_anon"]), 9, ">")}  '
                      f'{pad("shmem", 6)}{pad(hum(n["own_shmem"]), 9, ">")}  {path}')

    if args.detail:
        pat = re.compile(args.detail, re.I)
        for a in all_rows:
            if not pat.search(a["app"]):
                continue
            print(f'\n===== detail: {a["app"]} =====')
            if a.get("members"):
                for m in sorted(a["members"], key=lambda m: -m["current"])[:30]:
                    print(f'  {pad(h0(m["current"]), 9, ">")}  {pad(h0(m["anon"]), 9, ">")}  '
                          f'{pad(procs_label(len(m["procs"])), 10)}  {m["app"]}')
                if len(a["members"]) > 30:
                    print(f'  ... {len(a["members"])-30} more applications')
            else:
                for p in sorted(a["procs"], key=lambda p: -p["rss"])[:25]:
                    print(f'  {pad(hum(p["rss"]*1024), 9, ">")}  pid={pad(p["pid"], 8)}'
                          f' {pad(p["name"][:18], 18)} {p["cmd"][:92]}')
                if len(a["procs"]) > 25:
                    print(f'  ... {len(a["procs"])-25} more processes')
                print(f'  rss sum   {hum(a["rss"]*1024):>8} = anon {hum(a["rss_anon"]*1024)} '
                      f'+ file {hum(a["rss_file"]*1024)} (reclaimable) + shmem {hum(a["rss_shmem"]*1024)}')
                print(f'  cgroup    {hum(a["current"]):>8} = anon {hum(a["anon"])} '
                      f'+ file cache {hum(a["file"])} + tmpfs-shared {hum(a["shmem"])}')
                over = a["rss_file"] * 1024 - a["file"]
                if over > 0:
                    print(f'  overlap   {hum(over):>8} of file-backed pages (libraries/resources) '
                          f'counted once per process')
                where = dict(presence.get(a["app"], {}))
                if where:
                    print("  cgroups holding this app (own charge goes to the dominant app inside each cgroup):")
                    for path, cnt in sorted(where.items(),
                                            key=lambda kv: -(nodes[kv[0]]["own_current"] if kv[0] in nodes else 0)):
                        n = nodes.get(path, {})
                        print(f'    {pad("own", 5)}{pad(hum(n.get("own_current",0)), 9, ">")}  '
                              f'{pad("anon", 5)}{pad(hum(n.get("own_anon",0)), 9, ">")}  '
                              f'{pad("shmem", 5)}{pad(hum(n.get("own_shmem",0)), 9, ">")}  '
                              f'{pad(procs_label(cnt), 10)}{label(path, names)}')

if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:      # allow `| head`, `| less`
        os._exit(0)
    except KeyboardInterrupt:
        sys.exit(130)
