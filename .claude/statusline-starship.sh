#!/bin/bash

# Starship-inspired status line for Claude Code
# Reads JSON from stdin (Claude Code statusLine protocol)

input=$(cat)
line1=""
line2=""

SEP=$'\033[02;37m  ·  \033[00m'

# ── LINE 1: location + git ────────────────────────────────────────────────────

# Environment indicator
if [ "$CODESPACES" = "true" ]; then
    env_icon="☁️"
elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    env_icon="🌐"
elif [ -f /.dockerenv ]; then
    env_icon="🐳"
else
    env_icon="💻"
fi
line1+=$(printf "\033[01;34m%s\033[00m" "$env_icon")

# Codespace name
if [ -n "$CODESPACE_NAME" ] && [ "$CODESPACES" = "true" ]; then
    cs_name="${CODESPACE_NAME}"
    [ -f ~/.codespace_displayname ] && cs_name=$(cat ~/.codespace_displayname)
    line1+=$(printf " \033[01;36m%s\033[00m" "$cs_name")
fi

# Username@hostname
user=$(whoami)
hostname=$(hostname -s | cut -d'-' -f1)
if [ "$user" = "root" ]; then
    line1+=$(printf " \033[01;37m%s\033[00m@" "$user")
elif [ "$CODESPACES" = "true" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    line1+=$(printf " \033[01;32m%s\033[00m@" "$user")
fi
if [ "$CODESPACES" = "true" ] || [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    line1+=$(printf "\033[02;37m%s\033[00m" "$hostname")
fi

# Directory
cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -z "$cwd" ] && cwd=$(pwd)
[ -d "$cwd" ] && cd "$cwd" 2>/dev/null

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    repo_name=$(basename "$repo_root")
    relative_path="${cwd#$repo_root}"
    [ "$relative_path" = "" ] && relative_path="/"
    [ "${#relative_path}" -gt 40 ] && relative_path="…${relative_path: -37}"
    line1+="${SEP}$(printf "\033[01;36m%s%s\033[00m" "$repo_name" "$relative_path")"
else
    [ "${#cwd}" -gt 50 ] && cwd="…${cwd: -47}"
    line1+="${SEP}$(printf "\033[01;36m%s\033[00m" "$cwd")"
fi

# Git branch + status
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        [ "${#branch}" -gt 15 ] && branch="${branch:0:12}…"
        line1+="${SEP}$(printf "\033[01;35m %s\033[00m" "$branch")"
    fi

    git_status=$(git -c core.fileMode=false status --porcelain 2>/dev/null)
    if [ -n "$git_status" ]; then
        status_info="["
        untracked=$(echo "$git_status" | grep -c "^??")
        modified=$(echo "$git_status" | grep -c "^ M")
        staged=$(echo "$git_status" | grep -c "^M")
        deleted=$(echo "$git_status" | grep -c "^ D")
        [ "$staged" -gt 0 ]    && status_info+="🚀${staged} "
        [ "$modified" -gt 0 ]  && status_info+="📝${modified} "
        [ "$untracked" -gt 0 ] && status_info+="⚠️${untracked} "
        [ "$deleted" -gt 0 ]   && status_info+="🧹${deleted} "
        status_info="${status_info% }]"
        [ "$status_info" != "[]" ] && line1+=$(printf " \033[01;33m%s\033[00m" "$status_info")
    fi
fi

# Python / Node runtime hints
if command -v python3 >/dev/null 2>&1 && { [ -f "$cwd/requirements.txt" ] || [ -f "$cwd/pyproject.toml" ] || [ -f "$cwd/setup.py" ]; }; then
    py_version=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1-2)
    line1+="${SEP}$(printf "\033[33m🐍 %s\033[00m" "$py_version")"
fi
if command -v node >/dev/null 2>&1 && [ -f "$cwd/package.json" ]; then
    node_version=$(node --version | sed 's/v//')
    line1+="${SEP}$(printf "\033[32m⬢ %s\033[00m" "$node_version")"
fi

# ── LINE 2: model + context + cost ───────────────────────────────────────────

# Model name
model=$(echo "$input" | jq -r '.model.display_name // .model.id // empty' 2>/dev/null)
if [ -n "$model" ]; then
    line2+=$(printf "\033[01;36m%s\033[00m" "$model")
fi

# Context window usage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
    used_int=$(printf "%.0f" "$used_pct" 2>/dev/null || echo "$used_pct")
    remaining_int=$((100 - used_int))
    filled=$(( used_int / 10 ))
    empty=$(( 10 - filled ))

    if [ "$used_int" -lt 50 ]; then
        ctx_color="\033[01;32m"
    elif [ "$used_int" -lt 80 ]; then
        ctx_color="\033[01;33m"
    else
        ctx_color="\033[01;31m"
    fi

    spent_bar=""
    remaining_bar=""
    for ((i=0; i<filled; i++)); do spent_bar+="░"; done
    for ((i=0; i<empty; i++));  do remaining_bar+="█"; done

    [ -n "$line2" ] && line2+="$SEP"
    line2+=$(printf "${ctx_color}%s\033[02;37m%s\033[00m ${ctx_color}%d%% context left\033[00m" "$remaining_bar" "$spent_bar" "$remaining_int")
fi

# Cost
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty' 2>/dev/null)
if [ -n "$cost" ] && [ "$cost" != "null" ] && [ "$cost" != "0" ]; then
    cost_fmt=$(printf "%.3f" "$cost" 2>/dev/null)
    [ -n "$line2" ] && line2+="$SEP"
    line2+=$(printf "\033[02;37m\$%s\033[00m" "$cost_fmt")
fi

# Task stats from TASKS.md + CHANGELOG.md in current project
tasks_file="$cwd/TASKS.md"
changelog_file="$cwd/CHANGELOG.md"
if [ -f "$tasks_file" ]; then
    p0=$(grep -c "🔴" "$tasks_file" 2>/dev/null || echo 0)
    blocked=$(grep -c "⛔" "$tasks_file" 2>/dev/null || echo 0)
    inprogress=$(grep -c "🔄" "$tasks_file" 2>/dev/null || echo 0)
    # High priority todo (P1 🟠) — urgent but not P0
    hi=$(grep "🟠" "$tasks_file" 2>/dev/null | grep -c "📋" || echo 0)
    # Medium todo (P2 🟡) — orange
    med=$(grep "🟡" "$tasks_file" 2>/dev/null | grep -c "📋" || echo 0)
    # Low todo (P3 🟢) — yellow
    low=$(grep "🟢" "$tasks_file" 2>/dev/null | grep -c "📋" || echo 0)

    # Done count from CHANGELOG [Unreleased] section (bullet points = shipped items)
    done=0
    if [ -f "$changelog_file" ]; then
        done=$(awk '/^## \[Unreleased\]/{found=1; next} found && /^## /{exit} found && /^- /{count++} END{print count+0}' "$changelog_file" 2>/dev/null || echo 0)
    fi

    tasks_str=""
    [ "$p0" -gt 0 ]         && tasks_str+=$(printf "\033[01;31m🔴%d\033[00m " "$p0")
    [ "$blocked" -gt 0 ]    && tasks_str+=$(printf "\033[01;31m⛔%d\033[00m " "$blocked")
    [ "$inprogress" -gt 0 ] && tasks_str+=$(printf "\033[01;33m🔄%d\033[00m " "$inprogress")
    [ "$hi" -gt 0 ]         && tasks_str+=$(printf "\033[01;37m📋%d\033[00m " "$hi")
    [ "$med" -gt 0 ]        && tasks_str+=$(printf "\033[38;5;214m🟡%d\033[00m " "$med")
    [ "$low" -gt 0 ]        && tasks_str+=$(printf "\033[33m🟢%d\033[00m " "$low")
    [ "$done" -gt 0 ]       && tasks_str+=$(printf "\033[01;32m✅%d\033[00m " "$done")

    if [ -n "$tasks_str" ]; then
        [ -n "$line2" ] && line2+="$SEP"
        line2+="${tasks_str% }"
    fi
fi

# Session name
session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)
if [ -n "$session_id" ]; then
    note_file="$HOME/.claude/session_notes/${session_id}"
    if [ -f "$note_file" ]; then
        session_name=$(cat "$note_file")
        [ -n "$line2" ] && line2+="$SEP"
        line2+=$(printf "\033[01;33m📌 %s\033[00m" "$session_name")
    fi
fi

# ── OUTPUT ────────────────────────────────────────────────────────────────────

if [ -n "$line2" ]; then
    printf "%s\n%s" "$line1" "$line2"
else
    printf "%s" "$line1"
fi
