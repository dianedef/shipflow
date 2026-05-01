#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  capture_tmux_conversation.sh [--tab N] [--title TITLE] [--destination PATH] [--session NAME] [--dry-run] [--yes]

Target:
  --tab N              Optional user-facing 1-based tmux tab/window ordinal.
                       The script resolves the actual tmux window index.
                       Omit to capture the current tmux pane.

Optional:
  --title TITLE        Markdown title. Inferred when omitted.
  --destination PATH   Output file path or directory. Inferred when omitted.
  --session NAME       tmux session name. Defaults to current session or the only session.
  --dry-run            Print the inferred plan without writing.
  --yes                Skip interactive confirmation.
  --force              Allow overwriting an existing output file.
  -h, --help           Show this help.
EOF
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

slugify() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-{2,}/-/g'
}

expand_tilde() {
  case "$1" in
    "~") printf '%s\n' "$HOME" ;;
    "~/"*) printf '%s/%s\n' "$HOME" "${1#~/}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

absolute_path() {
  local path
  path=$(expand_tilde "$1")
  realpath -m "$path"
}

with_md_extension() {
  local path="$1"
  case "$path" in
    *.md|*.markdown) printf '%s\n' "$path" ;;
    *) printf '%s.md\n' "$path" ;;
  esac
}

unique_path() {
  local path="$1"
  local stem ext candidate index

  if [ "${FORCE:-0}" = "1" ] || [ ! -e "$path" ]; then
    printf '%s\n' "$path"
    return 0
  fi

  ext="${path##*.}"
  stem="${path%.*}"
  index=2
  while :; do
    candidate="${stem}-${index}.${ext}"
    if [ ! -e "$candidate" ]; then
      printf '%s\n' "$candidate"
      return 0
    fi
    index=$((index + 1))
  done
}

shell_quote() {
  printf '%q' "$1"
}

neovim_command() {
  local output="$1"
  local output_dir output_file
  output_dir=$(dirname "$output")
  output_file=$(basename "$output")
  printf 'cd %s && nvim %s\n' "$(shell_quote "$output_dir")" "$(shell_quote "$output_file")"
}

resolve_session() {
  local requested="$1"
  local count

  if [ -n "$requested" ]; then
    tmux has-session -t "$requested" 2>/dev/null || fail "tmux session not found: $requested"
    printf '%s\n' "$requested"
    return 0
  fi

  if [ -n "${TMUX:-}" ]; then
    tmux display-message -p '#S'
    return 0
  fi

  count=$(tmux list-sessions -F '#S' 2>/dev/null | wc -l | tr -d ' ')
  case "$count" in
    0) fail "no tmux session is running" ;;
    1) tmux list-sessions -F '#S' ;;
    *) fail "multiple tmux sessions found; pass --session NAME" ;;
  esac
}

render_markdown() {
  local raw_file="$1"
  local output="$2"
  local title="$3"
  local session="$4"
  local source_label="$5"
  local window_index="$6"
  local pane_index="$7"
  local window_name="$8"
  local captured_at="$9"
  local max_tildes fence_len fence

  max_tildes=$(awk '
    {
      line = $0
      while (match(line, /~+/)) {
        if (RLENGTH > max) max = RLENGTH
        line = substr(line, RSTART + RLENGTH)
      }
    }
    END { print max + 0 }
  ' "$raw_file")
  fence_len=$((max_tildes + 1))
  if [ "$fence_len" -lt 3 ]; then
    fence_len=3
  fi
  printf -v fence '%*s' "$fence_len" ''
  fence=${fence// /~}

  {
    printf '# %s\n\n' "$title"
    printf '%s\n' "- Captured at: \`$captured_at\`"
    printf '%s\n' "- tmux session: \`$session\`"
    printf '%s\n' "- tmux source: \`$source_label\`"
    printf '%s\n' "- tmux window index: \`:$window_index\`"
    printf '%s\n' "- tmux pane index: \`.$pane_index\`"
    printf '%s\n\n' "- tmux window name: \`$window_name\`"
    printf '%s\n' "$fence"
    cat "$raw_file"
    printf '\n%s\n' "$fence"
  } > "$output"
}

TAB=""
TITLE=""
DESTINATION=""
SESSION=""
DRY_RUN=0
YES=0
FORCE=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --tab)
      [ "$#" -ge 2 ] || fail "--tab requires a value"
      TAB="$2"
      shift 2
      ;;
    --title)
      [ "$#" -ge 2 ] || fail "--title requires a value"
      TITLE="$2"
      shift 2
      ;;
    --destination|--dest|--output|-o)
      [ "$#" -ge 2 ] || fail "$1 requires a value"
      DESTINATION="$2"
      shift 2
      ;;
    --session)
      [ "$#" -ge 2 ] || fail "--session requires a value"
      SESSION="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --yes|-y)
      YES=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [ -z "$TAB" ] && [[ "$1" =~ ^[0-9]+$ ]]; then
        TAB="$1"
        shift
      else
        fail "unknown argument: $1"
      fi
      ;;
  esac
done

need_cmd tmux
need_cmd awk
need_cmd sed
need_cmd realpath

if [ -n "$TAB" ]; then
  [[ "$TAB" =~ ^[0-9]+$ ]] || fail "--tab must be a positive integer"
  [ "$TAB" -ge 1 ] || fail "--tab must be >= 1"

  SESSION=$(resolve_session "$SESSION")
  WINDOW_INDEX=$(tmux list-windows -t "$SESSION" -F '#{window_index}' | sed -n "${TAB}p")
  [ -n "$WINDOW_INDEX" ] || fail "tmux tab $TAB not found in session $SESSION"
  TARGET="${SESSION}:${WINDOW_INDEX}"

  tmux display-message -p -t "$TARGET" '#{window_index}' >/dev/null 2>&1 \
    || fail "tmux window not found for tab $TAB (target $TARGET)"

  PANE_INDEX=$(tmux display-message -p -t "$TARGET" '#{pane_index}')
  WINDOW_NAME=$(tmux display-message -p -t "$TARGET" '#W')
  SOURCE_LABEL="tab ${TAB}"
else
  [ -z "$SESSION" ] || fail "--session without --tab is ambiguous; omit --session to capture the current pane or pass --tab N"
  tmux display-message -p '#S' >/dev/null 2>&1 \
    || fail "no current tmux pane found; pass --tab N from inside tmux or run from the pane to capture"
  SESSION=$(tmux display-message -p '#S')
  WINDOW_INDEX=$(tmux display-message -p '#{window_index}')
  PANE_INDEX=$(tmux display-message -p '#{pane_index}')
  WINDOW_NAME=$(tmux display-message -p '#W')
  TARGET="${SESSION}:${WINDOW_INDEX}.${PANE_INDEX}"
  SOURCE_LABEL="current pane"
fi
CAPTURED_AT=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

if [ -z "$TITLE" ]; then
  if [ -z "$TAB" ] && [ -n "$WINDOW_NAME" ]; then
    TITLE="Conversation tmux - panneau courant - ${WINDOW_NAME}"
  elif [ -z "$TAB" ]; then
    TITLE="Conversation tmux - panneau courant"
  elif [ -n "$WINDOW_NAME" ]; then
    TITLE="Conversation tmux - onglet ${TAB} - ${WINDOW_NAME}"
  else
    TITLE="Conversation tmux - onglet ${TAB}"
  fi
fi

if [ -z "$DESTINATION" ]; then
  STAMP=$(date -u '+%Y%m%d-%H%M%S')
  SLUG=$(slugify "$TITLE")
  if [ -z "$SLUG" ]; then
    SLUG="conversation-onglet-${TAB}-${STAMP}"
  else
    SLUG="${SLUG}-${STAMP}"
  fi
  DESTINATION="./${SLUG}.md"
elif [ -d "$(expand_tilde "$DESTINATION")" ] || [[ "$DESTINATION" == */ ]]; then
  SLUG=$(slugify "$TITLE")
  [ -n "$SLUG" ] || SLUG="conversation-onglet-${TAB}"
  DESTINATION="${DESTINATION%/}/${SLUG}.md"
else
  DESTINATION=$(with_md_extension "$DESTINATION")
fi

OUTPUT=$(absolute_path "$DESTINATION")
OUTPUT=$(unique_path "$OUTPUT")

print_plan() {
  printf 'Title: %s\n' "$TITLE"
  printf 'Destination: %s\n' "$OUTPUT"
  printf 'tmux target: %s (%s, window index :%s, pane index .%s)\n' "$TARGET" "$SOURCE_LABEL" "$WINDOW_INDEX" "$PANE_INDEX"
  printf 'tmux window name: %s\n' "$WINDOW_NAME"
  printf 'Neovim command: %s' "$(neovim_command "$OUTPUT")"
}

if [ "$DRY_RUN" = "1" ]; then
  print_plan
  exit 0
fi

if [ "$YES" != "1" ]; then
  print_plan
  if [ ! -t 0 ]; then
    fail "confirmation required; rerun with --yes after the user approves this destination"
  fi
  printf 'OK? Press Enter/y to capture, type a new destination, or type q/no to abort: '
  IFS= read -r ANSWER
  case "$ANSWER" in
    ""|y|Y|yes|YES|o|O|oui|OUI)
      ;;
    q|Q|n|N|no|NO|non|NON)
      printf 'Aborted.\n'
      exit 2
      ;;
    *)
      DESTINATION=$(with_md_extension "$ANSWER")
      OUTPUT=$(absolute_path "$DESTINATION")
      OUTPUT=$(unique_path "$OUTPUT")
      printf 'New destination: %s\n' "$OUTPUT"
      ;;
  esac
fi

TMP_RAW=$(mktemp)
trap 'rm -f "$TMP_RAW"' EXIT

tmux capture-pane -t "$TARGET" -p -S - > "$TMP_RAW"
mkdir -p "$(dirname "$OUTPUT")"
render_markdown "$TMP_RAW" "$OUTPUT" "$TITLE" "$SESSION" "$SOURCE_LABEL" "$WINDOW_INDEX" "$PANE_INDEX" "$WINDOW_NAME" "$CAPTURED_AT"

printf 'Captured tmux target %s to %s\n' "$TARGET" "$OUTPUT"
printf 'Open with Neovim: %s' "$(neovim_command "$OUTPUT")"
