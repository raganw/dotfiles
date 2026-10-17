---
name: extract-transcript-images
description: Extract base64-encoded images (screenshots) embedded in a Claude Code session transcript (.jsonl) and decode them to image files. Use when the user asks to pull, save, recover, or convert an image/screenshot from the chat/session logs into a file.
---

# Extract Transcript Images

Claude Code stores each session as a JSONL transcript at
`~/.claude/projects/<project-slug>/<session-id>.jsonl`, where `<project-slug>` is the
absolute working directory with every non-alphanumeric character replaced by `-`.
Screenshots captured during a session (e.g. from browser automation) are embedded
inline as base64 image blocks. This skill lists those images and decodes selected
ones to files.

Use the bundled script — do not hand-roll `python3 -c` one-liners. It lives next to
this file; the examples below call it as `"$SKILL_DIR/extract_images.py"`, where
`$SKILL_DIR` is the **base directory for this skill** shown when the skill loads (this
skill is installed globally at `~/.claude/skills/extract-transcript-images`). Set it
once so the commands are copy-pasteable:

```bash
SKILL_DIR=~/.claude/skills/extract-transcript-images
```

## Instructions

### 1. Locate the transcript

- If you know the current **session id** (it appears in your scratchpad path, e.g.
  `.../<session-id>/scratchpad`), build the path explicitly and pass `--transcript`.
  This is the most reliable option:
  ```bash
  python3 "$SKILL_DIR/extract_images.py" \
    --transcript ~/.claude/projects/<project-slug>/<session-id>.jsonl
  ```
- Otherwise let it auto-detect the newest transcript for the current project
  (derived from `cwd`). Auto-detect picks the most recently modified `.jsonl`, which
  is usually — but not guaranteed to be — the current session:
  ```bash
  python3 "$SKILL_DIR/extract_images.py" --list
  # narrow auto-detect to a known session id:
  python3 "$SKILL_DIR/extract_images.py" --list --session <session-id>
  ```

### 2. List the images and confirm which one

Running with no `--index`/`--all` prints a table of **distinct** images (identical
copies are deduped and counted under `copies`):

```
idx    line  media          ~size  copies
--------------------------------------------
  0     338  image/jpeg      7KB       2
  4     375  image/png      19KB       3
```

If the user was ambiguous about "the image", show this list and let the size / media
type / line order guide the choice (e.g. a `save_to_disk` zoom is often a lone PNG).
Ask which index if it's genuinely unclear.

### 3. Extract

```bash
# one image, with a descriptive name (extension is added automatically)
python3 "$SKILL_DIR/extract_images.py" \
  --transcript <path> --index 4 --out ai-docs --name reason-dropdown

# every distinct image
python3 "$SKILL_DIR/extract_images.py" \
  --transcript <path> --all --out ai-docs
```

- `--out` defaults to `ai-docs`.
- `--name` (no extension) applies only to a single-index extraction; batch extraction
  auto-names files `transcript-image-<idx>.<ext>`.

### 4. Verify

Read the written file back to confirm it decoded to a valid image before reporting the
path to the user.

## Notes

- The script is read-only against the transcript; it never modifies session logs.
- Supported media types map to `.png`, `.jpg`, `.gif`, `.webp`; unknown types write `.bin`.
- Transcripts can be large (multi-MB). The script streams line by line, so it is safe
  to run directly — do not `cat` the JSONL into context.
