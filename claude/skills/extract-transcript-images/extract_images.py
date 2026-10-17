#!/usr/bin/env python3
"""Extract base64-encoded images from a Claude Code session transcript (JSONL).

Transcripts live at ~/.claude/projects/<project-slug>/<session-id>.jsonl, where
<project-slug> is the absolute cwd with every non-alphanumeric char replaced by '-'.
Screenshots (e.g. from browser automation) are stored inline as base64 image blocks.

Usage:
  # List the distinct images in a transcript (default action)
  python3 extract_images.py --transcript /path/to/<session>.jsonl

  # Auto-detect the newest transcript for the current project (cwd)
  python3 extract_images.py --list

  # Extract one image (by index from --list) to ai-docs/
  python3 extract_images.py --transcript <path> --index 4 --out ai-docs --name my-image

  # Extract every distinct image
  python3 extract_images.py --transcript <path> --all --out ai-docs
"""
import argparse
import base64
import glob
import hashlib
import json
import os
import sys

EXT = {"image/png": "png", "image/jpeg": "jpg", "image/gif": "gif", "image/webp": "webp"}


def project_slug(path):
    return "".join(c if c.isalnum() else "-" for c in os.path.abspath(path))


def find_transcript(session=None):
    base = os.path.expanduser("~/.claude/projects")
    proj_dir = os.path.join(base, project_slug(os.getcwd()))
    search_dirs = [proj_dir] if os.path.isdir(proj_dir) else [base]
    files = []
    for d in search_dirs:
        files += glob.glob(os.path.join(d, "**", "*.jsonl"), recursive=True)
    if session:
        files = [f for f in files if session in os.path.basename(f)]
    files.sort(key=os.path.getmtime, reverse=True)
    return files[0] if files else None


def iter_images(obj):
    if isinstance(obj, dict):
        if obj.get("type") == "image" and isinstance(obj.get("source"), dict):
            src = obj["source"]
            if src.get("data"):
                yield {"media": src.get("media_type", "image/png"), "data": src["data"]}
        for v in obj.values():
            yield from iter_images(v)
    elif isinstance(obj, list):
        for v in obj:
            yield from iter_images(v)


def collect(path):
    seen = {}
    order = []
    with open(path) as f:
        for lineno, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue
            for img in iter_images(rec):
                key = hashlib.sha1(img["data"].encode()).hexdigest()
                if key in seen:
                    seen[key]["dupes"] += 1
                    continue
                entry = {
                    "idx": len(order),
                    "line": lineno,
                    "media": img["media"],
                    "data": img["data"],
                    "dupes": 1,
                }
                seen[key] = entry
                order.append(entry)
    return order


def approx_kb(b64len):
    return b64len * 3 // 4 // 1024


def print_list(images, path):
    print(f"transcript: {path}")
    print(f"distinct images: {len(images)}\n")
    print(f"{'idx':>3}  {'line':>6}  {'media':<11}  {'~size':>7}  {'copies':>6}")
    print("-" * 44)
    for im in images:
        print(
            f"{im['idx']:>3}  {im['line']:>6}  {im['media']:<11}  "
            f"{approx_kb(len(im['data'])):>4}KB  {im['dupes']:>6}"
        )


def write_image(entry, out_dir, name=None):
    os.makedirs(out_dir, exist_ok=True)
    ext = EXT.get(entry["media"], "bin")
    fname = f"{name}.{ext}" if name else f"transcript-image-{entry['idx']}.{ext}"
    dest = os.path.join(out_dir, fname)
    with open(dest, "wb") as f:
        f.write(base64.b64decode(entry["data"]))
    print(f"wrote {dest} ({os.path.getsize(dest)} bytes)")
    return dest


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--transcript", help="Path to the .jsonl transcript (auto-detected if omitted)")
    ap.add_argument("--session", help="Session id substring to disambiguate during auto-detect")
    ap.add_argument("--list", action="store_true", help="List distinct images (default when no --index/--all)")
    ap.add_argument("--index", type=int, action="append", help="Index (from --list) to extract; repeatable")
    ap.add_argument("--all", action="store_true", help="Extract every distinct image")
    ap.add_argument("--out", default="ai-docs", help="Output directory (default: ai-docs)")
    ap.add_argument("--name", help="Base filename for a single --index extraction (no extension)")
    args = ap.parse_args()

    path = args.transcript or find_transcript(args.session)
    if not path or not os.path.isfile(path):
        sys.exit("error: could not locate a transcript; pass --transcript explicitly")

    images = collect(path)
    if not images:
        sys.exit(f"no base64 images found in {path}")

    if not args.all and not args.index:
        print_list(images, path)
        return

    by_idx = {im["idx"]: im for im in images}
    targets = images if args.all else []
    if args.index:
        for i in args.index:
            if i not in by_idx:
                sys.exit(f"error: index {i} out of range (0..{len(images) - 1})")
            targets.append(by_idx[i])

    if args.name and len(targets) != 1:
        sys.exit("error: --name only applies when extracting exactly one image")

    for t in targets:
        write_image(t, args.out, args.name if len(targets) == 1 else None)


if __name__ == "__main__":
    main()
