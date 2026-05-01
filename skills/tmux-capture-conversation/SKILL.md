---
name: tmux-capture-conversation
description: "Capture the current or selected tmux pane to Markdown with inferred title/path and confirmation."
argument-hint: [optional --tab N, title, destination]
---

# tmux Capture Conversation

## Canonical Paths

Before resolving ShipFlow-owned files, load `$SHIPFLOW_ROOT/skills/references/canonical-paths.md` (`$SHIPFLOW_ROOT` defaults to `$HOME/shipflow`) if present. Resolve this skill's script from `$SHIPFLOW_ROOT/skills/tmux-capture-conversation/scripts/`.

## Chantier Tracking

Trace category: `non-applicable`.
Process role: `helper`.

This skill captures a local terminal transcript and does not write to chantier specs. If invoked inside a spec-first flow, do not modify `Skill Run History`; report `Chantier: non applicable` only when useful.

## Core Rule

Default to the current tmux pane when the user does not provide a tab/window number. This matches `tmux capture-pane -p -S -` from inside the active conversation.

Ask for a tab/window number only when the user wants to capture a different tab and has not identified which one.

When a tab number is provided, interpret it as a 1-based ordinal in the tmux window list. In a zero-based tmux session, tab 2 resolves to window index `:1`, matching `tmux capture-pane -t :1 -p -S -`; in a one-based tmux session, tab 2 resolves to `:2`.

## Workflow

1. Extract the tab number from the request when present. If absent, plan to capture the current tmux pane.
2. Infer missing values:
   - title: use the user's requested title when present; otherwise infer a concise transcript title from the request, tmux window name, `Conversation tmux - panneau courant`, or `Conversation tmux - onglet N`.
   - destination: use the user's path when present; otherwise choose a Markdown file in the current working directory, usually `conversation-tmux-YYYYMMDD-HHMMSS.md`, `conversation-onglet-N-YYYYMMDD-HHMMSS.md`, or a title-based slug.
3. Confirm before writing unless the user already explicitly approved the inferred destination in the current request.
   - Tell the user the chosen title and destination.
   - Ask whether it is OK.
   - Accept a replacement destination path as the answer and use that path instead.
4. Run the bundled script after confirmation.
5. Report the final Markdown path, mention the tmux target that was captured, and relay the printed Neovim command so the user can open the file from its parent directory.

## Script

Use `scripts/capture_tmux_conversation.sh` for the deterministic export.

Preview inferred values without writing:

```bash
SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}"
"$SHIPFLOW_ROOT/skills/tmux-capture-conversation/scripts/capture_tmux_conversation.sh" --dry-run
```

Capture the current pane after confirmation:

```bash
SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}"
"$SHIPFLOW_ROOT/skills/tmux-capture-conversation/scripts/capture_tmux_conversation.sh" --title "Conversation Codex" --destination ./conversation-codex.md --yes
```

Capture another tab after confirmation:

```bash
SHIPFLOW_ROOT="${SHIPFLOW_ROOT:-$HOME/shipflow}"
"$SHIPFLOW_ROOT/skills/tmux-capture-conversation/scripts/capture_tmux_conversation.sh" --tab 2 --title "Conversation Codex" --destination ./conversation-codex.md --yes
```

Arguments:

- `--tab N`: optional user-facing 1-based tab ordinal. Omit to capture the current pane.
- `--title TEXT`: optional Markdown title.
- `--destination PATH`: optional file path or directory. Directories receive an inferred filename. Paths without `.md` get `.md`.
- `--session NAME`: optional tmux session. Omit to use the current session, or the only available session when outside tmux.
- `--dry-run`: show the inferred capture plan without writing.
- `--yes`: skip the script's interactive confirmation. Use only after the user has approved the title and destination in chat or supplied them explicitly with clear approval.

If running interactively without `--yes`, the script asks for confirmation. Press Enter to accept, type a new destination to change it, or type `q`/`no` to abort.

After writing the file, the script prints:

```text
Open with Neovim: cd /path/to/output-dir && nvim output-file.md
```
