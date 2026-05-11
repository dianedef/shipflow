#!/bin/bash
# ============================================================================
# ShipFlow Shared Library
# ============================================================================
#
# Description:
#   Core library containing all reusable functions for ShipFlow CLI.
#   Handles environment management, PM2 operations, port allocation,
#   Flox integration, validation, logging, and caching.
#
# Dependencies:
#   - pm2 (required)
#   - node (required)
#   - flox (optional)
#   - git (optional)
#   - jq (optional, preferred for JSON parsing)
#   - python3 (optional, fallback for JSON parsing)
#
# Author: ShipFlow Team
# Version: 2.0.0
# Date: 2026-01-24
# ============================================================================

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
source "$SCRIPT_DIR/config.sh"

# ============================================================================
# ERROR HANDLING SETUP
# ============================================================================

# Enable strict mode if configured
if [ "$SHIPFLOW_STRICT_MODE" = "true" ]; then
    set -euo pipefail
fi

# Error trap handler
error_trap_handler() {
    local exit_code=$?
    local line_number=$1
    log ERROR "Script failed at line $line_number with exit code $exit_code"
    error "Script execution failed (line $line_number, code $exit_code)"
}

# Install error trap if configured
if [ "$SHIPFLOW_ERROR_TRAPS" = "true" ]; then
    trap 'error_trap_handler ${LINENO}' ERR
fi

# Cleanup trap for temporary files
TEMP_FILES=()
cleanup_temp_files() {
    for file in "${TEMP_FILES[@]}"; do
        [ -f "$file" ] && rm -f "$file" 2>/dev/null || true
    done
}
trap cleanup_temp_files EXIT

# Register a temp file for cleanup
register_temp_file() {
    TEMP_FILES+=("$1")
}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
LIGHT_BLUE='\033[38;5;117m'
NC='\033[0m'

# Config (use centralized config values)
PROJECTS_DIR="${SHIPFLOW_PROJECTS_DIR}"

# ============================================================================
# GUM DETECTION & UI WRAPPERS
# ============================================================================

# Detect gum availability (don't auto-install)
if gum --version >/dev/null 2>&1; then
    HAS_GUM=true
else
    HAS_GUM=false
fi

# -----------------------------------------------------------------------------
# ui_choose - Interactive selection (instant keys for short lists, filter for long lists)
#
# Arguments:
#   $1 - Prompt text
#   Remaining args or stdin - Options to choose from
#
# Outputs:
#   Selected value to stdout
#
# Returns:
#   1 if cancelled or no selection
# -----------------------------------------------------------------------------
_ui_letter_key() {
    local index="$1"
    local alphabet="abcdefghijklmnopqrstuvwyz"
    local base=${#alphabet}
    local key=""
    local n="$index"

    while true; do
        local rem=$((n % base))
        key="${alphabet:rem:1}${key}"
        n=$((n / base - 1))
        [ "$n" -lt 0 ] && break
    done

    printf '%s' "$key"
}

_ui_normalize_choice() {
    local choice="${1:-}"

    choice="${choice//$'\r'/}"
    case "$choice" in
        $'\e'|$'\177'|$'\b') printf 'x'; return 0 ;;
    esac

    choice="${choice#"${choice%%[![:space:]]*}"}"
    choice="${choice%"${choice##*[![:space:]]}"}"
    choice=$(printf '%s' "$choice" | tr '[:upper:]' '[:lower:]')

    case "$choice" in
        esc|escape|backspace) choice="x" ;;
    esac

    if [[ "$choice" =~ ^([[:alnum:]?]+)\).*$ ]]; then
        choice="${BASH_REMATCH[1]}"
    elif [[ "$choice" =~ ^([[:alnum:]?]+)[[:space:]].*$ ]]; then
        choice="${BASH_REMATCH[1]}"
    fi

    printf '%s' "$choice"
}

SHIPFLOW_SKIP_NEXT_PAUSE=false
if [ -z "${SHIPFLOW_SKIP_NEXT_PAUSE_FILE:-}" ]; then
    SHIPFLOW_SKIP_NEXT_PAUSE_FILE=$(mktemp "${TMPDIR:-/tmp}/shipflow-skip-pause.XXXXXX" 2>/dev/null || printf '%s/shipflow-skip-pause-%s' "${TMPDIR:-/tmp}" "$$")
    rm -f "$SHIPFLOW_SKIP_NEXT_PAUSE_FILE" 2>/dev/null || true
fi

ui_skip_next_pause() {
    SHIPFLOW_SKIP_NEXT_PAUSE=true
    if [ -n "${SHIPFLOW_SKIP_NEXT_PAUSE_FILE:-}" ]; then
        : > "$SHIPFLOW_SKIP_NEXT_PAUSE_FILE" 2>/dev/null || true
    fi
}

ui_return_back() {
    ui_skip_next_pause
    return 0
}

ui_should_skip_next_pause() {
    if [ "${SHIPFLOW_SKIP_NEXT_PAUSE:-false}" = "true" ] || { [ -n "${SHIPFLOW_SKIP_NEXT_PAUSE_FILE:-}" ] && [ -f "$SHIPFLOW_SKIP_NEXT_PAUSE_FILE" ]; }; then
        SHIPFLOW_SKIP_NEXT_PAUSE=false
        [ -n "${SHIPFLOW_SKIP_NEXT_PAUSE_FILE:-}" ] && rm -f "$SHIPFLOW_SKIP_NEXT_PAUSE_FILE" 2>/dev/null || true
        return 0
    fi
    return 1
}

ui_flush_pending_input() {
    if [ -r /dev/tty ] && { : < /dev/tty; } 2>/dev/null; then
        while read -rsn1 -t 0.05 _ < /dev/tty 2>/dev/null; do :; done
    fi
}

ui_is_back_choice() {
    local choice
    choice=$(_ui_normalize_choice "${1:-}")
    case "$choice" in
        x|q) return 0 ;;
        *) return 1 ;;
    esac
}

ui_is_back_selection() {
    local selection="${1:-}"
    case "$selection" in
        ""|"Cancel"|"Back"|"Back to menu"|*" Back"|*"Back "*) return 0 ;;
        *) return 1 ;;
    esac
}

_ui_back_label_from_options() {
    local item
    for item in "$@"; do
        if [ -n "$item" ] && ui_is_back_selection "$item"; then
            printf '%s' "$item"
            return 0
        fi
    done
    printf 'Cancel'
}

ui_read_key() {
    local __target_var="$1"
    local __value=""

    if [ -r /dev/tty ] && { : < /dev/tty; } 2>/dev/null; then
        read -rsn1 __value < /dev/tty
        while read -rsn1 -t 0.05 _ < /dev/tty 2>/dev/null; do :; done
        printf '\r\n' >&2
    else
        read -r __value
    fi

    printf -v "$__target_var" '%s' "$__value"
}

ui_box_header() {
    local title="$1"
    local border_color="${2:-$CYAN}"
    local title_color="${3:-$YELLOW}"
    local content_width="${4:-50}"

    if [ ${#title} -gt "$content_width" ]; then
        title="${title:0:$content_width}"
    fi

    local rule=""
    local i
    for ((i=0; i<content_width; i++)); do
        rule+="═"
    done
    local left_pad=$(( (content_width - ${#title}) / 2 ))
    local right_pad=$(( content_width - ${#title} - left_pad ))

    printf "%b╔%s╗%b\n" "$border_color" "$rule" "$NC"
    printf "%b║%b%*s%s%*s%b║%b\n" "$border_color" "$title_color" "$left_pad" "" "$title" "$right_pad" "" "$border_color" "$NC"
    printf "%b╚%s╝%b\n" "$border_color" "$rule" "$NC"
}

center_fixed_width() {
    local text="$1"
    local width="${2:-46}"
    local text_len=${#text}

    if [ "$text_len" -ge "$width" ]; then
        printf "%s" "${text:0:$width}"
        return
    fi

    local left_pad=$(( (width - text_len) / 2 ))
    local right_pad=$(( width - text_len - left_pad ))
    printf "%*s%s%*s" "$left_pad" "" "$text" "$right_pad" ""
}

ui_screen_header() {
    local title="$1"
    local variant="${2:-default}"
    local border_color="$CYAN"
    local title_color="$YELLOW"
    local gum_border_color="212"
    local brand="ShipFlow DevServer"
    local content_width=50
    local inner_width=46

    case "$variant" in
        danger)
            border_color="$RED"
            title_color="$YELLOW"
            gum_border_color="196"
            ;;
        success)
            border_color="$GREEN"
            title_color="$GREEN"
            gum_border_color="46"
            ;;
    esac

    if [ ${#title} -gt "$inner_width" ]; then
        title="${title:0:$inner_width}"
    fi

    if [ "$HAS_GUM" = true ] && command -v gum >/dev/null 2>&1; then
        local brand_line
        local title_line
        local colored_brand_line
        local colored_title_line
        brand_line="$(center_fixed_width "$brand" "$inner_width")"
        title_line="$(center_fixed_width "$title" "$inner_width")"
        printf -v colored_brand_line "%b%s%b" "$YELLOW" "$brand_line" "$NC"
        printf -v colored_title_line "%b%s%b" "$title_color" "$title_line" "$NC"

        gum style \
            --foreground 212 --border-foreground "$gum_border_color" --border double \
            --align left --width 50 --margin "1 2" --padding "1 2" \
            "$colored_brand_line" "$colored_title_line"
        echo ""
        return 0
    fi

    local rule=""
    local i
    for ((i=0; i<content_width; i++)); do
        rule+="═"
    done

    local brand_left=$(( (inner_width - ${#brand}) / 2 ))
    local brand_right=$(( inner_width - ${#brand} - brand_left ))
    local title_left=$(( (inner_width - ${#title}) / 2 ))
    local title_right=$(( inner_width - ${#title} - title_left ))

    printf "%b╔%s╗%b\n" "$border_color" "$rule" "$NC"
    printf "%b║%50s║%b\n" "$border_color" "" "$NC"
    printf "%b║  %b%*s%s%*s%b  ║%b\n" "$border_color" "$YELLOW" "$brand_left" "" "$brand" "$brand_right" "" "$border_color" "$NC"
    printf "%b║  %b%*s%s%*s%b  ║%b\n" "$border_color" "$title_color" "$title_left" "" "$title" "$title_right" "" "$border_color" "$NC"
    printf "%b║%50s║%b\n" "$border_color" "" "$NC"
    printf "%b╚%s╝%b\n" "$border_color" "$rule" "$NC"
    echo ""
}

ui_action_header() {
    ui_screen_header "$@"
}

ui_read_choice() {
    local __target_var="$1"
    local __raw_choice=""

    ui_read_key __raw_choice
    __raw_choice=$(_ui_normalize_choice "$__raw_choice")

    printf -v "$__target_var" '%s' "$__raw_choice"
}

ui_run_menu_action() {
    local _label="${1:-}"
    local action="${2:-}"
    local display_mode="${3:-screen}"

    [ -z "$action" ] && return 1

    case "$display_mode" in
        screen|clear)
            clear
            ;;
        inline|"")
            ;;
        *)
            clear
            ;;
    esac

    "$action"
}

ui_read_line() {
    local __target_var="$1"
    local __value=""

    if [ -r /dev/tty ] && { : < /dev/tty; } 2>/dev/null; then
        read -r __value < /dev/tty
    else
        read -r __value
    fi

    printf -v "$__target_var" '%s' "$__value"
}

ui_filter_choose() {
    local prompt="$1"
    shift

    local items=()
    if [ $# -gt 0 ]; then
        items=("$@")
    else
        while IFS= read -r line; do
            items+=("$line")
        done
    fi

    if [ ${#items[@]} -eq 0 ]; then
        return 1
    fi

    if [ "$HAS_GUM" = true ] && command -v gum >/dev/null 2>&1; then
        ui_flush_pending_input
        local selected
        selected=$(printf '%s\n' "${items[@]}" | gum filter --header "ShipFlow DevServer · $prompt" --placeholder "Type to search...")
        local rc=$?
        if [ $rc -ne 0 ]; then
            ui_skip_next_pause
            return $rc
        fi
        printf '%s\n' "$selected"
        return 0
    fi

    if command -v fzf >/dev/null 2>&1; then
        ui_flush_pending_input
        local selected
        selected=$(printf '%s\n' "${items[@]}" | FZF_DEFAULT_OPTS= fzf \
            --prompt "ShipFlow DevServer · $prompt > " \
            --height "${SHIPFLOW_FZF_HEIGHT:-70%}" \
            --layout reverse \
            --border \
            --cycle \
            --bind "enter:accept")
        local rc=$?
        if [ $rc -ne 0 ]; then
            ui_skip_next_pause
            return $rc
        fi
        printf '%s\n' "$selected"
        return 0
    fi

    local query=""
    local matches=()
    while true; do
        echo -e "${YELLOW}ShipFlow DevServer · $prompt${NC}" >&2
        echo -e "${YELLOW}Search:${NC} \c" >&2
        ui_flush_pending_input
        ui_read_line query

        matches=()
        local item
        for item in "${items[@]}"; do
            if [ -z "$query" ] || printf '%s\n' "$item" | grep -qiF -- "$query"; then
                matches+=("$item")
            fi
        done

        if [ ${#matches[@]} -eq 0 ]; then
            echo -e "${RED}No match${NC}" >&2
            continue
        fi

        if [ ${#matches[@]} -eq 1 ]; then
            echo "${matches[0]}"
            return 0
        fi

        if [ ${#matches[@]} -gt 9 ]; then
            echo -e "${YELLOW}${#matches[@]} matches. Type more letters to narrow the list.${NC}" >&2
            continue
        fi

        local keys=()
        local i=0
        for item in "${matches[@]}"; do
            local key
            key=$(_ui_letter_key "$i")
            keys+=("$key")
            echo -e "  ${CYAN}$key)${NC} $item" >&2
            ((i++))
        done
        echo -e "  ${CYAN}x)${NC} Cancel" >&2
        echo "" >&2
        echo -e "${YELLOW}Choose:${NC} \c" >&2

        local choice
        ui_read_choice choice
        if ui_is_back_choice "$choice" || [ -z "$choice" ]; then
            ui_skip_next_pause
            return 1
        fi
        for ((i=0; i<${#keys[@]}; i++)); do
            if [ "$choice" = "${keys[$i]}" ]; then
                echo "${matches[$i]}"
                return 0
            fi
        done
        echo -e "${RED}Invalid choice${NC}" >&2
    done
}

ui_choose() {
    local prompt="$1"
    shift

    if [ "$HAS_GUM" = true ]; then
        # Collect items
        local items=()
        if [ $# -gt 0 ]; then
            items=("$@")
        else
            while IFS= read -r line; do
                items+=("$line")
            done
        fi

        if [ ${#items[@]} -le 5 ]; then
            local filtered_items=()
            local has_back_item=false
            local back_label
            back_label=$(_ui_back_label_from_options "${items[@]}")
            local item
            for item in "${items[@]}"; do
                if [ -n "$item" ] && ui_is_back_selection "$item"; then
                    has_back_item=true
                    continue
                fi
                filtered_items+=("$item")
            done

            gum style --foreground 11 "$prompt" >&2
            echo "" >&2
            local keys=()
            local i=0
            for item in "${filtered_items[@]}"; do
                local key
                key=$(_ui_letter_key "$i")
                keys+=("$key")
                printf '  %s %s\n' "$(gum style --foreground 212 "${key})")" "$item" >&2
                ((i++))
            done
            echo "" >&2
            printf '  %s %s\n' "$(gum style --foreground 212 "x)")" "$back_label" >&2
            echo "" >&2
            printf '%s' "$(gum style --foreground 11 "Choose: ")" >&2

            local choice
            ui_read_choice choice

            if ui_is_back_choice "$choice" || [ -z "$choice" ]; then
                ui_skip_next_pause
                if [ "$has_back_item" = true ]; then
                echo "$back_label"
                return 0
            fi
            return 1
        fi

        for ((i=0; i<${#keys[@]}; i++)); do
            if [ "$choice" = "${keys[$i]}" ]; then
                echo "${filtered_items[$i]}"
                return 0
            fi
        done

        for ((i=0; i<${#filtered_items[@]}; i++)); do
            local match_candidate=${filtered_items[$i]}
            match_candidate=$(printf '%s' "$match_candidate" | sed 's/^[^ ]* //')
            if [ "${match_candidate,,}" = "${choice}" ]; then
                echo "${filtered_items[$i]}"
                return 0
            fi
        done

                echo -e "${RED}Invalid choice${NC}" >&2
                return 1
        else
            local selected
            selected=$(ui_filter_choose "$prompt" "${items[@]}")
            local rc=$?
            [ $rc -ne 0 ] && return $rc
            if ui_is_back_selection "$selected"; then
                ui_skip_next_pause
            fi
            printf '%s\n' "$selected"
            return 0
        fi
    else
        # Lettered list fallback
        local options=()
        if [ $# -gt 0 ]; then
            options=("$@")
        else
            while IFS= read -r line; do
                options+=("$line")
            done
        fi

        if [ ${#options[@]} -gt 5 ]; then
            local selected
            selected=$(ui_filter_choose "$prompt" "${options[@]}")
            local rc=$?
            [ $rc -ne 0 ] && return $rc
            if ui_is_back_selection "$selected"; then
                ui_skip_next_pause
            fi
            printf '%s\n' "$selected"
            return 0
        fi

        local filtered_options=()
        local has_back_option=false
        local back_label
        back_label=$(_ui_back_label_from_options "${options[@]}")
        local opt
        for opt in "${options[@]}"; do
            if [ -n "$opt" ] && ui_is_back_selection "$opt"; then
                has_back_option=true
                continue
            fi
            filtered_options+=("$opt")
        done
        options=("${filtered_options[@]}")

        if [ ${#options[@]} -eq 0 ]; then
            return 1
        fi

        echo -e "${YELLOW}$prompt${NC}" >&2
        echo "" >&2
        local keys=()
        local i=0
        for opt in "${options[@]}"; do
            local key
            key=$(_ui_letter_key "$i")
            keys+=("$key")
            echo -e "  ${CYAN}$key)${NC} $opt" >&2
            ((i++))
        done
        echo "" >&2
        echo -e "  ${CYAN}x)${NC} $back_label" >&2
        echo "" >&2
        echo -e "${YELLOW}Choose:${NC} \c" >&2
        ui_read_choice choice

        if ui_is_back_choice "$choice" || [ -z "$choice" ]; then
            ui_skip_next_pause
            if [ "$has_back_option" = true ]; then
                echo "$back_label"
                return 0
            fi
            return 1
        fi

        for ((i=0; i<${#keys[@]}; i++)); do
            if [ "$choice" = "${keys[$i]}" ]; then
                echo "${options[$i]}"
                return 0
            fi
        done

        for ((i=0; i<${#options[@]}; i++)); do
            local match_candidate=${options[$i]}
            match_candidate=$(printf '%s' "$match_candidate" | sed 's/^[^ ]* //')
            if [ "${match_candidate,,}" = "${choice}" ]; then
                echo "${options[$i]}"
                return 0
            fi
        done

        echo -e "${RED}Invalid choice${NC}" >&2
        return 1
    fi
}

# -----------------------------------------------------------------------------
# ui_input - Text input (gum input || read)
#
# Arguments:
#   $1 - Prompt text
#   $2 - Placeholder text (optional)
#   $3 - "--password" for hidden input (optional)
#
# Outputs:
#   User input to stdout
# -----------------------------------------------------------------------------
ui_input() {
    local prompt="$1"
    local placeholder="${2:-}"
    local password_flag="${3:-}"

    if [ "$HAS_GUM" = true ]; then
        if [ "$password_flag" = "--password" ]; then
            gum input --placeholder "$placeholder" --password
        elif [ -n "$placeholder" ]; then
            gum input --placeholder "$placeholder"
        else
            gum input --placeholder "$prompt"
        fi
    else
        if [ "$password_flag" = "--password" ]; then
            echo -e "${YELLOW}${prompt}${NC} \c" >&2
            read -rs value
            echo "" >&2
            echo "$value"
        else
            echo -e "${YELLOW}${prompt}${NC} \c" >&2
            read -r value
            echo "$value"
        fi
    fi
}

# -----------------------------------------------------------------------------
# ui_confirm - Yes/no confirmation with one-key input
#
# Arguments:
#   $1 - Prompt text
#
# Returns:
#   0 for yes, 1 for no
# -----------------------------------------------------------------------------
ui_confirm() {
    local prompt="$1"
    local answer=""

    if [ "$HAS_GUM" = true ]; then
        printf '%s' "$(gum style --foreground 11 "${prompt} (y/o/N): ")" >&2
    else
        echo -e "${YELLOW}${prompt} (y/o/N):${NC} \c" >&2
    fi

    ui_read_choice answer

    case "$answer" in
        y|yes|o|oui) return 0 ;;
        *) return 1 ;;
    esac
}

# -----------------------------------------------------------------------------
# ui_header - Styled header (gum style || ANSI echo)
#
# Arguments:
#   $1 - Title text
#   $2 - Subtitle (optional)
#   $3 - Status left (optional, shown at top-left)
#   $4 - Status right (optional, shown at top-right)
#   $5 - Extra header block (optional, newline-delimited)
# -----------------------------------------------------------------------------
ui_header() {
    local title="$1"
    local subtitle="${2:-}"
    local status_left="${3:-}"
    local status_right="${4:-}"
    local extra_block="${5:-}"
    local width=50
    local content_width=46

    local status_line=""
    if [ -n "$status_left" ] || [ -n "$status_right" ]; then
        if [ -n "$status_left" ] && [ -n "$status_right" ]; then
            status_line="${status_left} |  ${status_right}"
        else
            status_line="${status_left}${status_right}"
        fi
        if [ ${#status_line} -gt "$content_width" ]; then
            status_line="${status_line:0:$content_width}"
        else
            local status_pad=$(( (content_width - ${#status_line}) / 2 ))
            status_line="$(printf '%*s%s' "$status_pad" '' "$status_line")"
        fi
    fi

    center_line() {
        local text="$1"
        local text_len=${#text}
        if [ $text_len -ge $content_width ]; then
            echo "${text:0:$content_width}"
            return
        fi
        local pad=$(( (content_width - text_len) / 2 ))
        printf "%*s%s" "$pad" "" "$text"
    }

    if [ "$HAS_GUM" = true ]; then
        local header_lines=()
        local title_line
        local colored_title_line
        if [ -n "$status_line" ]; then
            header_lines+=("$status_line" "")
        fi
        title_line=$(center_line "$title")
        printf -v colored_title_line "%b%s%b" "$YELLOW" "$title_line" "$NC"
        header_lines+=("$colored_title_line")
        if [ -n "$subtitle" ]; then
            header_lines+=("$(center_line "$subtitle")")
        fi
        if [ -n "$extra_block" ]; then
            while IFS= read -r extra_line; do
                header_lines+=("$extra_line")
            done <<< "$extra_block"
        fi

        gum style \
            --foreground 212 --border-foreground 212 --border double \
            --align left --width 50 --margin "1 2" --padding "1 2 0 2" \
            "${header_lines[@]}"
    else
        echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
        if [ -n "$status_line" ]; then
            echo -e " ${GREEN}${status_line}${NC}"
            echo -e "${CYAN}--------------------------------------------------${NC}"
        fi
        printf " %b%s%b\n" "$YELLOW" "$(center_line "$title")" "$NC"
        if [ -n "$subtitle" ]; then
            printf " %b%s%b\n" "$BLUE" "$(center_line "$subtitle")" "$NC"
        fi
        if [ -n "$extra_block" ]; then
            while IFS= read -r extra_line; do
                printf " %b\n" "$extra_line"
            done <<< "$extra_block"
        fi
        echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
    fi
}

# -----------------------------------------------------------------------------
# ui_spinner - Loading indicator (gum spin || echo + run)
#
# Arguments:
#   $1 - Title/message
#   $2+ - Command to run
# -----------------------------------------------------------------------------
ui_spinner() {
    local title="$1"
    shift

    if [ "$HAS_GUM" = true ]; then
        gum spin --spinner dot --title "$title" -- "$@"
    else
        echo -e "${BLUE}${title}${NC}" >&2
        "$@"
    fi
}

# -----------------------------------------------------------------------------
# ui_pause - wait for one keypress with dual-mode support
#
# Arguments:
#   $1 - Optional message (default: "Appuie sur une touche pour continuer...")
# -----------------------------------------------------------------------------
ui_pause() {
    local msg="${1:-Appuie sur une touche pour continuer...}"
    local pause_key=""

    msg="${msg//Entrée/une touche}"
    msg="${msg//Enter/any key}"

    if [ "$HAS_GUM" = true ]; then
        echo ""
        gum style --foreground 240 "$msg" >&2
    else
        echo ""
        echo -e "${YELLOW}${msg}${NC}"
    fi

    ui_read_key pause_key
}

# DISK CLEANUP UTILITIES
# ============================================================================

disk_free_bytes() {
    df -B1 --output=avail / 2>/dev/null | tail -n 1 | tr -d ' '
}

disk_free_human() {
    df -h --output=avail / 2>/dev/null | tail -n 1 | tr -d ' '
}

disk_total_human() {
    df -h --output=size / 2>/dev/null | tail -n 1 | tr -d ' '
}

disk_used_human() {
    df -h --output=used / 2>/dev/null | tail -n 1 | tr -d ' '
}

disk_filesystem() {
    df -P / 2>/dev/null | awk 'NR == 2 {print $1}'
}

header_storage_human() {
    local value="$1"
    case "$value" in
        *[0-9]K) printf '%sKB' "${value%K}" ;;
        *[0-9]M) printf '%sMB' "${value%M}" ;;
        *[0-9]G) printf '%sGB' "${value%G}" ;;
        *[0-9]T) printf '%sTB' "${value%T}" ;;
        *) printf '%s' "$value" ;;
    esac
}

disk_used_pct() {
    df -P / 2>/dev/null | awk 'NR == 2 { gsub("%", "", $5); print $5 }'
}

disk_warn_threshold_bytes() {
    local gb="${SHIPFLOW_DISK_WARN_GB:-5}"
    if ! [[ "$gb" =~ ^[0-9]+$ ]]; then
        gb=5
    fi
    echo $((gb * 1024 * 1024 * 1024))
}

disk_gb_to_bytes() {
    local gb="$1"
    if ! [[ "$gb" =~ ^[0-9]+$ ]]; then
        gb=0
    fi
    echo $((gb * 1024 * 1024 * 1024))
}

disk_pressure_level() {
    local free_bytes="${1:-}"
    local used_pct="${2:-}"

    if [ -z "$free_bytes" ]; then
        free_bytes=$(disk_free_bytes)
    fi
    if [ -z "$used_pct" ]; then
        used_pct=$(disk_used_pct)
    fi

    local critical_free
    critical_free=$(disk_gb_to_bytes "${SHIPFLOW_DISK_CRITICAL_GB:-3}")
    local high_free
    high_free=$(disk_gb_to_bytes "${SHIPFLOW_DISK_HIGH_GB:-5}")
    local warn_free
    warn_free=$(disk_gb_to_bytes "${SHIPFLOW_DISK_WARN_GB:-8}")
    local critical_pct="${SHIPFLOW_DISK_CRITICAL_PCT:-95}"
    local high_pct="${SHIPFLOW_DISK_HIGH_PCT:-90}"
    local warn_pct="${SHIPFLOW_DISK_WARN_PCT:-85}"

    if { [ -n "$used_pct" ] && [ "$used_pct" -ge "$critical_pct" ]; } || \
        { [ -n "$free_bytes" ] && [ "$free_bytes" -lt "$critical_free" ]; }; then
        echo "critical"
    elif { [ -n "$used_pct" ] && [ "$used_pct" -ge "$high_pct" ]; } || \
        { [ -n "$free_bytes" ] && [ "$free_bytes" -lt "$high_free" ]; }; then
        echo "high"
    elif { [ -n "$used_pct" ] && [ "$used_pct" -ge "$warn_pct" ]; } || \
        { [ -n "$free_bytes" ] && [ "$free_bytes" -lt "$warn_free" ]; }; then
        echo "warning"
    else
        echo "ok"
    fi
}

disk_is_low_space() {
    local free_bytes
    free_bytes=$(disk_free_bytes)
    local used_pct
    used_pct=$(disk_used_pct)
    local level
    level=$(disk_pressure_level "$free_bytes" "$used_pct")
    [ "$level" != "ok" ]
}

print_disk_pressure_warning() {
    local level="${1:-}"
    local free_human="${2:-}"
    local used_pct="${3:-}"

    if [ -z "$level" ]; then
        level=$(disk_pressure_level)
    fi
    if [ -z "$free_human" ]; then
        free_human=$(disk_free_human)
    fi
    if [ -z "$used_pct" ]; then
        used_pct=$(disk_used_pct)
    fi

    case "$level" in
        critical)
            echo -e "${RED}🚨 CRITICAL DISK SPACE: / is ${used_pct}% used (${free_human} free). VM freeze risk is high.${NC}"
            echo -e "${RED}   Stop heavy builds. Run aggressive cleanup now or expand the disk before continuing.${NC}"
            ;;
        high)
            echo -e "${RED}⚠️  HIGH DISK PRESSURE: / is ${used_pct}% used (${free_human} free). Builds can fail or stall.${NC}"
            echo -e "${RED}   Run cleanup before Gradle, Flutter, npm, Nix, or Docker-heavy work.${NC}"
            ;;
        warning)
            echo -e "${YELLOW}⚠️  Disk pressure: / is ${used_pct}% used (${free_human} free). Plan cleanup soon.${NC}"
            ;;
    esac
}

format_bytes() {
    local bytes="$1"
    if command -v numfmt >/dev/null 2>&1; then
        numfmt --to=iec --suffix=B "$bytes"
    else
        echo "${bytes}B"
    fi
}

print_usage_bar() {
    local used_pct="${1:-}"
    local bar_width="${2:-30}"
    local red_at="${3:-80}"
    local yellow_at="${4:-60}"

    if ! [[ "$used_pct" =~ ^[0-9]+$ ]]; then
        return 0
    fi
    if ! [[ "$bar_width" =~ ^[0-9]+$ ]] || [ "$bar_width" -le 0 ]; then
        bar_width=30
    fi
    if ! [[ "$red_at" =~ ^[0-9]+$ ]]; then
        red_at=80
    fi
    if ! [[ "$yellow_at" =~ ^[0-9]+$ ]]; then
        yellow_at=60
    fi
    if [ "$used_pct" -gt 100 ]; then
        used_pct=100
    fi

    local filled=$(( used_pct * bar_width / 100 ))
    local empty=$(( bar_width - filled ))
    local bar_color="${GREEN}"
    if [ "$used_pct" -ge "$red_at" ]; then
        bar_color="${RED}"
    elif [ "$used_pct" -ge "$yellow_at" ]; then
        bar_color="${YELLOW}"
    fi

    printf "  ["
    printf "%b" "$bar_color"
    local i
    for ((i = 0; i < filled; i++)); do
        printf '█'
    done
    printf "%b" "$NC"
    for ((i = 0; i < empty; i++)); do
        printf '░'
    done
    printf "] %s%%\n" "$used_pct"
}

cleanup_disk_light() {
    rm -rf "$HOME/.cache/yarn" \
        "$HOME/.cache/pip" \
        "$HOME/.cache/pnpm" \
        "$HOME/.npm/_cacache" \
        "$HOME/.chromium-browser-snapshots" \
        "$HOME/.rustup/tmp"/* 2>/dev/null || true
}

cleanup_disk_aggressive() {
    cleanup_disk_light
    rm -rf "$HOME/.npm" \
        "$HOME/.local/share/pnpm" \
        "$HOME/.cache" 2>/dev/null || true
    # Clean Rust/Tauri build artifacts (target/ dirs)
    local dir
    for dir in "$HOME"/*/src-tauri/target "$HOME"/*/target; do
        if [ -d "$dir" ] && [ -f "${dir%/target}/Cargo.toml" ]; then
            echo -e "  ${CYAN}Cleaning${NC} $dir"
            rm -rf "$dir" 2>/dev/null || true
        fi
    done
}

path_size_bytes() {
    local path="$1"
    [ -e "$path" ] || return 0
    du -sb "$path" 2>/dev/null | awk 'NR == 1 {print $1}'
}

agent_history_old_files() {
    local days="$1"
    local root

    if ! [[ "$days" =~ ^[0-9]+$ ]] || [ "$days" -lt 1 ]; then
        return 1
    fi

    for root in "$HOME/.codex/sessions" "$HOME/.claude/projects" "$HOME/.claude/file-history"; do
        [ -d "$root" ] || continue
        find "$root" -type f -mtime +"$days" -print0 2>/dev/null
    done
}

agent_history_old_sizes() {
    local days="$1"
    local root

    if ! [[ "$days" =~ ^[0-9]+$ ]] || [ "$days" -lt 1 ]; then
        return 1
    fi

    for root in "$HOME/.codex/sessions" "$HOME/.claude/projects" "$HOME/.claude/file-history"; do
        [ -d "$root" ] || continue
        find "$root" -type f -mtime +"$days" -printf '%s\n' 2>/dev/null
    done
}

agent_history_old_count() {
    local days="$1"
    agent_history_old_sizes "$days" | awk 'END {print NR + 0}'
}

agent_history_old_bytes() {
    local days="$1"
    agent_history_old_sizes "$days" | awk '{total += $1} END {print total + 0}'
}

agent_history_prune_empty_dirs() {
    local root
    for root in "$HOME/.codex/sessions" "$HOME/.claude/projects" "$HOME/.claude/file-history"; do
        [ -d "$root" ] || continue
        find "$root" -mindepth 1 -type d -empty -delete 2>/dev/null || true
    done
}

cleanup_agent_history_old() {
    local days="$1"
    local count=0
    local file

    if ! [[ "$days" =~ ^[0-9]+$ ]] || [ "$days" -lt 1 ]; then
        echo -e "${RED}Invalid retention:${NC} $days days"
        return 1
    fi

    while IFS= read -r -d '' file; do
        [ -f "$file" ] || continue
        count=$((count + 1))
        if [ "${SHIPFLOW_DISK_CLEANUP_DRY_RUN:-0}" = "1" ]; then
            echo "rm -f $file"
        else
            rm -f -- "$file" 2>/dev/null || true
        fi
    done < <(agent_history_old_files "$days")

    if [ "${SHIPFLOW_DISK_CLEANUP_DRY_RUN:-0}" != "1" ]; then
        agent_history_prune_empty_dirs
    fi

    echo -e "${GREEN}Removed:${NC} $count old agent history file(s)."
}

agent_cache_log_paths() {
    printf '%s\n' \
        "$HOME/.codex/.tmp" \
        "$HOME/.codex/tmp" \
        "$HOME/.codex/cache" \
        "$HOME/.codex/shell_snapshots" \
        "$HOME/.codex/log/codex-tui.log" \
        "$HOME/.claude/cache" \
        "$HOME/.claude/downloads" \
        "$HOME/.claude/paste-cache" \
        "$HOME/.claude/plugins/cache"
}

agent_cache_log_bytes() {
    local total=0
    local path size

    while IFS= read -r path; do
        [ -n "$path" ] || continue
        size=$(path_size_bytes "$path")
        [ -n "$size" ] || size=0
        total=$((total + size))
    done < <(agent_cache_log_paths)

    printf '%s' "$total"
}

cleanup_agent_cache_logs() {
    local path
    while IFS= read -r path; do
        [ -e "$path" ] || continue
        case "$path" in
            "$HOME/.codex/log/codex-tui.log")
                if [ "${SHIPFLOW_DISK_CLEANUP_DRY_RUN:-0}" = "1" ]; then
                    echo ": > $path"
                else
                    : > "$path" 2>/dev/null || true
                fi
                ;;
            "$HOME/.codex/"*|"$HOME/.claude/"*)
                if [ "${SHIPFLOW_DISK_CLEANUP_DRY_RUN:-0}" = "1" ]; then
                    echo "rm -rf $path"
                else
                    rm -rf -- "$path" 2>/dev/null || true
                fi
                ;;
        esac
    done < <(agent_cache_log_paths)

    echo -e "${GREEN}Agent caches/logs cleaned.${NC}"
}

pm2_home_dir() {
    printf '%s' "${PM2_HOME:-$HOME/.pm2}"
}

pm2_logs_bytes() {
    local pm2_home
    pm2_home=$(pm2_home_dir)
    local total=0
    local path size

    for path in "$pm2_home/pm2.log" "$pm2_home/logs"; do
        [ -e "$path" ] || continue
        size=$(path_size_bytes "$path")
        [ -n "$size" ] || size=0
        total=$((total + size))
    done

    printf '%s' "$total"
}

pm2_logrotate_installed() {
    command -v pm2 >/dev/null 2>&1 || return 1
    pm2 describe pm2-logrotate >/dev/null 2>&1
}

pm2_logrotate_status() {
    if pm2_logrotate_installed; then
        printf 'configured'
    else
        printf 'not configured'
    fi
}

truncate_file_zero() {
    local file="$1"
    [ -f "$file" ] || return 0

    if [ "${SHIPFLOW_PM2_LOG_CLEANUP_DRY_RUN:-0}" = "1" ] || [ "${SHIPFLOW_DISK_CLEANUP_DRY_RUN:-0}" = "1" ]; then
        echo ": > $file"
        return 0
    fi

    : > "$file" 2>/dev/null || true
}

cleanup_pm2_logs() {
    local pm2_home
    pm2_home=$(pm2_home_dir)

    if [ "${SHIPFLOW_PM2_LOG_CLEANUP_DRY_RUN:-0}" = "1" ] || [ "${SHIPFLOW_DISK_CLEANUP_DRY_RUN:-0}" = "1" ]; then
        echo "pm2 flush"
    elif command -v pm2 >/dev/null 2>&1; then
        pm2 flush >/dev/null 2>&1 || true
    fi

    truncate_file_zero "$pm2_home/pm2.log"

    if [ -d "$pm2_home/logs" ]; then
        if [ "${SHIPFLOW_PM2_LOG_CLEANUP_DRY_RUN:-0}" = "1" ] || [ "${SHIPFLOW_DISK_CLEANUP_DRY_RUN:-0}" = "1" ]; then
            find "$pm2_home/logs" -type f -name '*.log' -print 2>/dev/null | while IFS= read -r file; do
                echo ": > $file"
            done
        else
            find "$pm2_home/logs" -type f -name '*.log' -exec sh -c ': > "$1"' _ {} \; 2>/dev/null || true
        fi
    fi

    echo -e "${GREEN}PM2 logs cleaned.${NC}"
}

configure_pm2_logrotate() {
    local max_size="${SHIPFLOW_PM2_LOGROTATE_MAX_SIZE:-50M}"
    local retain="${SHIPFLOW_PM2_LOGROTATE_RETAIN:-5}"

    if [ "${SHIPFLOW_PM2_LOG_CLEANUP_DRY_RUN:-0}" = "1" ] || [ "${SHIPFLOW_DISK_CLEANUP_DRY_RUN:-0}" = "1" ]; then
        echo "pm2 install pm2-logrotate"
        echo "pm2 set pm2-logrotate:max_size $max_size"
        echo "pm2 set pm2-logrotate:retain $retain"
        echo "pm2 set pm2-logrotate:compress true"
        return 0
    fi

    if ! command -v pm2 >/dev/null 2>&1; then
        echo -e "${YELLOW}PM2 not found; log rotation not configured.${NC}"
        return 0
    fi

    if ! pm2_logrotate_installed; then
        echo -e "${YELLOW}Installing pm2-logrotate to cap future PM2 logs...${NC}"
        if ! pm2 install pm2-logrotate; then
            echo -e "${RED}Failed to install pm2-logrotate.${NC}"
            return 1
        fi
    fi

    pm2 set pm2-logrotate:max_size "$max_size" >/dev/null 2>&1 || true
    pm2 set pm2-logrotate:retain "$retain" >/dev/null 2>&1 || true
    pm2 set pm2-logrotate:compress true >/dev/null 2>&1 || true
    echo -e "${GREEN}PM2 log rotation configured:${NC} max_size=$max_size retain=$retain compress=true"
}

cleanup_pm2_logs_with_rotation() {
    cleanup_pm2_logs
    configure_pm2_logrotate || true
}

print_du_top() {
    local title="$1"
    local path="$2"
    local depth="${3:-1}"
    local limit="${4:-12}"

    [ -d "$path" ] || return 0

    echo -e "${BLUE}${title}${NC}"
    du -xhd"$depth" "$path" 2>/dev/null | sort -h | tail -n "$limit" | while IFS=$'\t' read -r size item; do
        [ -n "$size" ] || continue
        printf "  ${YELLOW}%-8s${NC} %s\n" "$size" "$item"
    done
    echo ""
}

print_top_files_by_size() {
    local title="$1"
    local path="$2"
    local limit="${3:-10}"

    [ -d "$path" ] || return 0

    echo -e "${BLUE}${title}${NC}"
    find "$path" -type f -printf '%s %p\n' 2>/dev/null | sort -nr | head -n "$limit" | while read -r bytes file; do
        [ -n "$bytes" ] || continue
        printf "  ${YELLOW}%-8s${NC} %s\n" "$(format_bytes "$bytes")" "$file"
    done
    echo ""
}

print_project_dir_top() {
    local title="$1"
    local path="$2"
    local limit="${3:-12}"

    [ -d "$path" ] || return 0

    echo -e "${BLUE}${title}${NC}"
    for dir in "$path"/*/; do
        [ -d "$dir" ] || continue
        du -xsh "$dir" 2>/dev/null
    done | sort -h | tail -n "$limit" | while IFS=$'\t' read -r size item; do
        [ -n "$size" ] || continue
        printf "  ${YELLOW}%-8s${NC} %s\n" "$size" "${item%/}"
    done
    echo ""
}

disk_usage_details_menu() {
    local pm2_home
    pm2_home=$(pm2_home_dir)

    ui_screen_header "Disk Details"
    echo -e "${BLUE}Filesystem:${NC}"
    df -h / 2>/dev/null | awk 'NR == 1 || NR == 2 {print "  " $0}'
    echo ""
    echo -e "${BLUE}PM2 logs:${NC} ${YELLOW}$(format_bytes "$(pm2_logs_bytes)")${NC} (${CYAN}rotation: $(pm2_logrotate_status)${NC})"
    echo ""

    print_top_files_by_size "Top PM2 log files" "$pm2_home" 8
    print_du_top "Top /home/$USER entries" "$HOME" 1 14
    print_project_dir_top "Top project/work directories in $PROJECTS_DIR" "$PROJECTS_DIR" 12
    print_du_top "Top root filesystem entries" "/" 1 12
}

disk_cleanup_menu() {
    ui_screen_header "Disk Cleanup"

    local before_bytes
    before_bytes=$(disk_free_bytes)
    local before_human
    before_human=$(disk_free_human)
    local before_used_pct
    before_used_pct=$(disk_used_pct)
    local before_level
    before_level=$(disk_pressure_level "$before_bytes" "$before_used_pct")
    local agent_7_bytes agent_14_bytes agent_cache_bytes
    agent_7_bytes=$(agent_history_old_bytes 7)
    agent_14_bytes=$(agent_history_old_bytes 14)
    agent_cache_bytes=$(agent_cache_log_bytes)
    local pm2_log_bytes
    pm2_log_bytes=$(pm2_logs_bytes)

    echo -e "${BLUE}Free space before:${NC} ${GREEN}${before_human}${NC} (${before_used_pct}% used on /)"
    print_disk_pressure_warning "$before_level" "$before_human" "$before_used_pct"
    echo ""

    echo -e "${BLUE}Options:${NC}"
    echo -e "  ${CYAN}v)${NC} Show disk usage details"
    echo -e "  ${CYAN}p)${NC} PM2 logs - flush + enable rotation (${YELLOW}up to $(format_bytes "$pm2_log_bytes")${NC})"
    echo -e "  ${CYAN}a)${NC} Agent histories - keep last 7 days (${YELLOW}up to $(format_bytes "$agent_7_bytes")${NC})"
    echo -e "  ${CYAN}b)${NC} Agent histories - keep last 14 days (${YELLOW}up to $(format_bytes "$agent_14_bytes")${NC})"
    echo -e "  ${CYAN}c)${NC} Agent caches/logs only (${YELLOW}up to $(format_bytes "$agent_cache_bytes")${NC})"
    echo -e "  ${CYAN}l)${NC} Light disk cleanup - package/browser disk caches"
    echo -e "  ${CYAN}g)${NC} Aggressive disk cleanup - includes npm + pnpm caches"
    echo ""
    echo -e "  ${CYAN}x)${NC} Back"
    echo ""
    echo -e "${YELLOW}Choose:${NC} \c"

    local choice
    ui_read_choice choice

    if [ -z "$choice" ] || ui_is_back_choice "$choice"; then
        ui_return_back
        return 0
    fi

    echo ""
    if [ "$choice" = "v" ]; then
        disk_usage_details_menu
        return 0
    elif [ "$choice" = "p" ]; then
        echo -e "${YELLOW}This will truncate PM2 daemon/app log files and configure future rotation:${NC}"
        echo -e "  ${CYAN}•${NC} $(pm2_home_dir)/pm2.log"
        echo -e "  ${CYAN}•${NC} $(pm2_home_dir)/logs/*.log"
        echo -e "  ${CYAN}•${NC} pm2-logrotate max_size=${SHIPFLOW_PM2_LOGROTATE_MAX_SIZE:-50M}, retain=${SHIPFLOW_PM2_LOGROTATE_RETAIN:-5}, compress=true"
        echo -e "${GREEN}Protected:${NC} PM2 process list, project directories, app files, auth, config, skills, and memories."
        echo ""
        if ! ui_confirm "Flush PM2 logs and enable log rotation now?"; then
            echo -e "${BLUE}Cancelled${NC}"
            return 0
        fi
        cleanup_pm2_logs_with_rotation
    elif [ "$choice" = "a" ]; then
        echo -e "${YELLOW}This will remove old agent history files only:${NC}"
        echo -e "  ${CYAN}•${NC} ~/.codex/sessions files older than 7 days"
        echo -e "  ${CYAN}•${NC} ~/.claude/projects transcript files older than 7 days"
        echo -e "  ${CYAN}•${NC} ~/.claude/file-history files older than 7 days"
        echo -e "${GREEN}Protected:${NC} project directories, auth, config, skills, memories, and the last 7 days of histories."
        echo ""
        if ! ui_confirm "Delete old agent histories and keep the last 7 days?"; then
            echo -e "${BLUE}Cancelled${NC}"
            return 0
        fi
        cleanup_agent_history_old 7
    elif [ "$choice" = "b" ]; then
        echo -e "${YELLOW}This will remove old agent history files only:${NC}"
        echo -e "  ${CYAN}•${NC} ~/.codex/sessions files older than 14 days"
        echo -e "  ${CYAN}•${NC} ~/.claude/projects transcript files older than 14 days"
        echo -e "  ${CYAN}•${NC} ~/.claude/file-history files older than 14 days"
        echo -e "${GREEN}Protected:${NC} project directories, auth, config, skills, memories, and the last 14 days of histories."
        echo ""
        if ! ui_confirm "Delete old agent histories and keep the last 14 days?"; then
            echo -e "${BLUE}Cancelled${NC}"
            return 0
        fi
        cleanup_agent_history_old 14
    elif [ "$choice" = "c" ]; then
        echo -e "${YELLOW}This will remove temporary agent caches and truncate the Codex TUI log:${NC}"
        echo -e "  ${CYAN}•${NC} ~/.codex/.tmp"
        echo -e "  ${CYAN}•${NC} ~/.codex/tmp"
        echo -e "  ${CYAN}•${NC} ~/.codex/cache"
        echo -e "  ${CYAN}•${NC} ~/.codex/shell_snapshots"
        echo -e "  ${CYAN}•${NC} ~/.codex/log/codex-tui.log"
        echo -e "  ${CYAN}•${NC} ~/.claude/cache, downloads, paste-cache, plugins/cache"
        echo -e "${GREEN}Protected:${NC} histories, auth, config, skills, memories, and project directories."
        echo ""
        if ! ui_confirm "Clean agent caches/logs now?"; then
            echo -e "${BLUE}Cancelled${NC}"
            return 0
        fi
        cleanup_agent_cache_logs
    elif [ "$choice" = "l" ]; then
        echo -e "${YELLOW}This will remove:${NC}"
        echo -e "  ${CYAN}•${NC} ~/.cache/yarn"
        echo -e "  ${CYAN}•${NC} ~/.cache/pip"
        echo -e "  ${CYAN}•${NC} ~/.cache/pnpm (PNPM disk cache)"
        echo -e "  ${CYAN}•${NC} ~/.npm/_cacache"
        echo -e "  ${CYAN}•${NC} ~/.chromium-browser-snapshots"
        echo -e "  ${CYAN}•${NC} ~/.rustup/tmp/*"
        echo ""
        if ! ui_confirm "Proceed with light cleanup?"; then
            echo -e "${BLUE}Cancelled${NC}"
            return 0
        fi
        cleanup_disk_light
    elif [ "$choice" = "g" ]; then
        echo -e "${YELLOW}This will remove:${NC}"
        echo -e "  ${CYAN}•${NC} ~/.cache (entire cache directory)"
        echo -e "  ${CYAN}•${NC} ~/.npm"
        echo -e "  ${CYAN}•${NC} ~/.local/share/pnpm (PNPM disk store/cache)"
        echo -e "  ${CYAN}•${NC} ~/.chromium-browser-snapshots"
        echo -e "  ${CYAN}•${NC} ~/.rustup/tmp/*"
        echo -e "  ${CYAN}•${NC} Rust/Tauri target/ build artifacts"
        echo -e "  ${CYAN}•${NC} PM2 daemon/app logs + pm2-logrotate"
        echo ""
        if [ "$before_level" = "critical" ] || [ "$before_level" = "high" ]; then
            echo -e "${RED}This cleanup is recommended: current disk pressure is ${before_level}.${NC}"
        fi
        if ! ui_confirm "Proceed with aggressive cleanup?"; then
            echo -e "${BLUE}Cancelled${NC}"
            return 0
        fi
        cleanup_disk_aggressive
        cleanup_pm2_logs_with_rotation
    else
        echo -e "${RED}Invalid option${NC}"
        return 1
    fi

    local after_bytes
    after_bytes=$(disk_free_bytes)
    local after_human
    after_human=$(disk_free_human)
    local after_used_pct
    after_used_pct=$(disk_used_pct)
    local after_level
    after_level=$(disk_pressure_level "$after_bytes" "$after_used_pct")

    echo ""
    echo -e "${BLUE}Free space after:${NC} ${GREEN}${after_human}${NC} (${after_used_pct}% used on /)"

    if [ -n "$before_bytes" ] && [ -n "$after_bytes" ] && [ "$after_bytes" -ge "$before_bytes" ]; then
        local freed=$((after_bytes - before_bytes))
        echo -e "${GREEN}Recovered:${NC} $(format_bytes "$freed")"
    fi

    print_disk_pressure_warning "$after_level" "$after_human" "$after_used_pct"
    if [ "$before_level" != "ok" ] && [ "$after_level" = "ok" ]; then
        echo -e "${GREEN}Disk pressure cleared.${NC}"
    fi
}

# ============================================================================
# MEMORY (RAM) MONITORING UTILITIES
# ============================================================================

# mem_available_kb - Available memory in KB (MemAvailable from /proc/meminfo)
mem_available_kb() {
    awk '/^MemAvailable:/ {print $2}' /proc/meminfo 2>/dev/null
}

# mem_total_kb - Total memory in KB
mem_total_kb() {
    awk '/^MemTotal:/ {print $2}' /proc/meminfo 2>/dev/null
}

# mem_available_human - Human-readable available memory (e.g. "20G")
mem_available_human() {
    local kb
    kb=$(mem_available_kb)
    if [ -z "$kb" ]; then
        echo "?"
        return
    fi
    local bytes=$((kb * 1024))
    if command -v numfmt >/dev/null 2>&1; then
        numfmt --to=iec "$bytes" 2>/dev/null || echo "${kb}K"
    else
        # Fallback: convert to GB
        echo "$((kb / 1024 / 1024))G"
    fi
}

# mem_total_human - Human-readable total memory
mem_total_human() {
    local kb
    kb=$(mem_total_kb)
    if [ -z "$kb" ]; then
        echo "?"
        return
    fi
    local bytes=$((kb * 1024))
    if command -v numfmt >/dev/null 2>&1; then
        numfmt --to=iec "$bytes" 2>/dev/null || echo "${kb}K"
    else
        echo "$((kb / 1024 / 1024))G"
    fi
}

# mem_is_low - Returns 0 if available memory < SHIPFLOW_MEM_WARN_GB
mem_is_low() {
    local avail_kb
    avail_kb=$(mem_available_kb)
    [ -z "$avail_kb" ] && return 1
    local warn_gb="${SHIPFLOW_MEM_WARN_GB:-4}"
    if ! [[ "$warn_gb" =~ ^[0-9]+$ ]]; then
        warn_gb=4
    fi
    local warn_kb=$((warn_gb * 1024 * 1024))
    [ "$avail_kb" -lt "$warn_kb" ]
}

# mem_top_processes - Top N processes sorted by RSS memory
# Output: USER PID %MEM RSS_HUMAN ELAPSED COMMAND
mem_top_processes() {
    local n="${1:-${SHIPFLOW_MONITOR_TOP_N:-15}}"
    # ps with RSS in KB, elapsed time, and command
    ps axo user,pid,pmem,rss,etimes,comm --sort=-rss --no-headers 2>/dev/null | head -n "$n" | while read -r user pid pmem rss etimes comm; do
        local rss_human
        if [ "$rss" -ge 1048576 ]; then
            rss_human="$(( rss / 1048576 ))G"
        elif [ "$rss" -ge 1024 ]; then
            rss_human="$(( rss / 1024 ))M"
        else
            rss_human="${rss}K"
        fi
        # Convert elapsed seconds to human readable
        local elapsed_human
        if [ "$etimes" -ge 86400 ]; then
            elapsed_human="$(( etimes / 86400 ))d$(( (etimes % 86400) / 3600 ))h"
        elif [ "$etimes" -ge 3600 ]; then
            elapsed_human="$(( etimes / 3600 ))h$(( (etimes % 3600) / 60 ))m"
        elif [ "$etimes" -ge 60 ]; then
            elapsed_human="$(( etimes / 60 ))m$(( etimes % 60 ))s"
        else
            elapsed_human="${etimes}s"
        fi
        printf "%s|%s|%s|%s|%s|%s\n" "$user" "$pid" "$pmem" "$rss_human" "$elapsed_human" "$comm"
    done
}

# mem_long_running_processes - Processes running longer than threshold
# Returns processes with etimes > SHIPFLOW_PROCESS_LONG_RUNNING_HOURS (in hours)
mem_long_running_processes() {
    local hours="${SHIPFLOW_PROCESS_LONG_RUNNING_HOURS:-24}"
    local threshold_secs=$((hours * 3600))
    # Only show processes using > 100MB RSS to filter noise
    ps axo user,pid,pmem,rss,etimes,comm --sort=-rss --no-headers 2>/dev/null | while read -r user pid pmem rss etimes comm; do
        if [ "$etimes" -ge "$threshold_secs" ] && [ "$rss" -ge 102400 ]; then
            local rss_human
            if [ "$rss" -ge 1048576 ]; then
                rss_human="$(( rss / 1048576 ))G"
            elif [ "$rss" -ge 1024 ]; then
                rss_human="$(( rss / 1024 ))M"
            else
                rss_human="${rss}K"
            fi
            local days=$(( etimes / 86400 ))
            local hours_rem=$(( (etimes % 86400) / 3600 ))
            local elapsed_human="${days}d${hours_rem}h"
            printf "%s|%s|%s|%s|%s|%s\n" "$user" "$pid" "$pmem" "$rss_human" "$elapsed_human" "$comm"
        fi
    done
}

mcp_process_matches() {
    local args="$1"
    case "$args" in
        *"convex@latest mcp start"*|*"convex mcp start"*|*"@playwright/mcp"*|*"playwright-mcp"*|*"@upstash/context7-mcp"*|*"dataforseo-mcp-server"*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

mcp_process_provider() {
    local args="$1"
    case "$args" in
        *"convex@latest mcp start"*|*"convex mcp start"*) printf 'convex' ;;
        *"@playwright/mcp"*|*"playwright-mcp"*) printf 'playwright' ;;
        *"@upstash/context7-mcp"*) printf 'context7' ;;
        *"dataforseo-mcp-server"*) printf 'dataforseo' ;;
        *) printf 'unknown' ;;
    esac
}

process_codex_ancestor() {
    local pid="$1"
    local depth=0
    local ppid comm args

    while [ -n "$pid" ] && [ "$pid" -gt 1 ] 2>/dev/null && [ "$depth" -lt 25 ]; do
        comm=$(ps -o comm= -p "$pid" 2>/dev/null | awk '{print $1}' || true)
        args=$(ps -o args= -p "$pid" 2>/dev/null || true)
        if [ "$comm" = "codex" ] || [[ "$args" == *"/codex"* ]] || [[ "$args" == *"/bin/codex"* ]]; then
            printf '%s' "$pid"
            return 0
        fi
        ppid=$(ps -o ppid= -p "$pid" 2>/dev/null | awk '{print $1}' || true)
        [ -n "$ppid" ] || break
        pid="$ppid"
        depth=$((depth + 1))
    done

    return 1
}

mcp_process_groups() {
    local raw=""
    local line pid ppid pgid tty etimes rss pcpu comm args provider ancestor

    while read -r pid ppid pgid tty etimes rss pcpu comm args; do
        [ -n "$pid" ] || continue
        if ! mcp_process_matches "$args"; then
            continue
        fi
        provider=$(mcp_process_provider "$args")
        ancestor=$(process_codex_ancestor "$pid" || true)
        raw+="${pgid}|${pid}|${ppid}|${tty}|${etimes}|${rss}|${pcpu}|${provider}|${ancestor:-none}|${comm}|${args}"$'\n'
    done < <(ps -eo pid=,ppid=,pgid=,tty=,etimes=,rss=,pcpu=,comm=,args= --no-headers 2>/dev/null)

    [ -n "$raw" ] || return 0

    printf '%s' "$raw" | awk -F'|' '
        NF >= 11 {
            pgid=$1
            count[pgid]++
            rss[pgid]+=$6
            if ($5 > etime[pgid]) etime[pgid]=$5
            if (providers[pgid] == "") providers[pgid]=$8
            else if (providers[pgid] !~ "(^|,)" $8 "(,|$)") providers[pgid]=providers[pgid] "," $8
            if (ancestors[pgid] == "") ancestors[pgid]=$9
            else if (ancestors[pgid] !~ "(^|,)" $9 "(,|$)") ancestors[pgid]=ancestors[pgid] "," $9
            if (pids[pgid] == "") pids[pgid]=$2
            else pids[pgid]=pids[pgid] "," $2
            tty[pgid]=$4
            if (cmd[pgid] == "") cmd[pgid]=$11
        }
        END {
            for (pgid in count) {
                print pgid "|" count[pgid] "|" rss[pgid] "|" etime[pgid] "|" providers[pgid] "|" ancestors[pgid] "|" pids[pgid] "|" tty[pgid] "|" cmd[pgid]
            }
        }
    ' | sort -t'|' -k4,4nr
}

mcp_format_elapsed() {
    local etimes="${1:-0}"
    if [ "$etimes" -ge 86400 ]; then
        printf '%sd%sh' "$((etimes / 86400))" "$(((etimes % 86400) / 3600))"
    elif [ "$etimes" -ge 3600 ]; then
        printf '%sh%sm' "$((etimes / 3600))" "$(((etimes % 3600) / 60))"
    elif [ "$etimes" -ge 60 ]; then
        printf '%sm%ss' "$((etimes / 60))" "$((etimes % 60))"
    else
        printf '%ss' "$etimes"
    fi
}

mcp_format_rss() {
    local rss="${1:-0}"
    if [ "$rss" -ge 1048576 ]; then
        printf '%sG' "$((rss / 1048576))"
    elif [ "$rss" -ge 1024 ]; then
        printf '%sM' "$((rss / 1024))"
    else
        printf '%sK' "$rss"
    fi
}

pgid_contains_codex() {
    local pgid="$1"
    ps -o comm=,args= -g "$pgid" 2>/dev/null | grep -Eq '(^|[[:space:]])codex([[:space:]]|$)|/codex'
}

show_mcp_process_groups() {
    local groups
    groups=$(mcp_process_groups)
    if [ -z "$groups" ]; then
        echo -e "${GREEN}No local MCP server process groups detected.${NC}"
        return 0
    fi

    echo -e "${BLUE}━━━ Local MCP Process Groups ━━━${NC}"
    printf "  ${CYAN}%-8s %-5s %-8s %-8s %-18s %-14s %-s${NC}\n" "PGID" "PROCS" "RSS" "UPTIME" "PROVIDER" "CODEX_PARENT" "PIDS"
    while IFS='|' read -r pgid count rss etime providers ancestors pids tty cmd; do
        printf "  ${YELLOW}%-8s %-5s %-8s %-8s %-18s %-14s${NC} %-s\n" \
            "$pgid" "$count" "$(mcp_format_rss "$rss")" "$(mcp_format_elapsed "$etime")" "$providers" "$ancestors" "$pids"
    done <<< "$groups"
}

stop_mcp_process_group() {
    local pgid="$1"
    local label="$2"

    if ! [[ "$pgid" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌ Invalid process group:${NC} $pgid"
        return 1
    fi

    if pgid_contains_codex "$pgid"; then
        echo -e "${RED}❌ Refusing to stop PGID $pgid because it contains a Codex process.${NC}"
        return 1
    fi

    echo -e "${YELLOW}Stopping MCP process group:${NC} $label"
    if [ "${SHIPFLOW_MCP_CLEANUP_DRY_RUN:-0}" = "1" ]; then
        echo "kill -TERM -$pgid"
        return 0
    fi

    kill -TERM "-$pgid" 2>/dev/null || true
    sleep 1
    if ps -o pid= -g "$pgid" 2>/dev/null | grep -q '[0-9]'; then
        if ui_confirm "Process group $pgid is still running. Force kill it?"; then
            kill -KILL "-$pgid" 2>/dev/null || true
        fi
    fi
}

mcp_cleanup_menu() {
    local groups
    groups=$(mcp_process_groups)
    if [ -z "$groups" ]; then
        ui_screen_header "MCP Process Cleanup"
        echo -e "${GREEN}✅ No local MCP server process groups detected.${NC}"
        return 0
    fi

    ui_screen_header "MCP Process Cleanup"
    show_mcp_process_groups
    echo ""
    echo -e "${YELLOW}This only targets local MCP server groups. It does not kill Codex conversations.${NC}"
    echo ""

    local options=()
    local labels=()
    local row pgid count rss etime providers ancestors pids tty cmd label
    while IFS='|' read -r pgid count rss etime providers ancestors pids tty cmd; do
        label="PGID $pgid · $providers · $(mcp_format_rss "$rss") · $(mcp_format_elapsed "$etime") · Codex parent: $ancestors"
        options+=("$label")
        labels+=("$pgid|$label")
    done <<< "$groups"
    options+=("Back")

    local selected
    selected=$(printf '%s\n' "${options[@]}" | ui_choose "Stop which MCP group?") || {
        ui_return_back
        return 0
    }
    if ui_is_back_selection "$selected"; then
        ui_return_back
        return 0
    fi

    for row in "${labels[@]}"; do
        pgid="${row%%|*}"
        label="${row#*|}"
        if [ "$selected" = "$label" ]; then
            if ui_confirm "Stop $label ?"; then
                stop_mcp_process_group "$pgid" "$label"
            else
                echo -e "${BLUE}Cancelled - no process stopped.${NC}"
            fi
            return 0
        fi
    done
}

clean_all_safe_targets() {
    local groups pm2_pid target_count=0
    groups=$(mcp_process_groups)
    pm2_pid=$(pm2_daemon_pid)

    ui_screen_header "Clean All Safe Targets"
    echo -e "${YELLOW}Scope:${NC} local MCP server groups, empty PM2 daemon, and Caddy when no PM2 app is online."
    echo -e "${YELLOW}Protected:${NC} Codex conversations, terminals, ssh, tmux, and root/system services other than Caddy."
    echo ""

    if [ -n "$groups" ]; then
        show_mcp_process_groups
        while IFS='|' read -r pgid count rss etime providers ancestors pids tty cmd; do
            [ -n "$pgid" ] || continue
            if pgid_contains_codex "$pgid"; then
                continue
            fi
            target_count=$((target_count + 1))
        done <<< "$groups"
    else
        echo -e "${GREEN}No local MCP server process groups detected.${NC}"
    fi

    if [ -n "$pm2_pid" ] && ! pm2_has_running_apps; then
        echo -e "${YELLOW}Empty PM2 daemon:${NC} PID $pm2_pid"
        target_count=$((target_count + 1))
    elif [ -n "$pm2_pid" ]; then
        echo -e "${YELLOW}PM2 daemon has registered apps; skipping PM2.${NC}"
    fi

    if user_caddy_is_running && ! pm2_has_running_apps; then
        echo -e "${YELLOW}User Caddy:${NC} PID $(user_caddy_pid)"
        target_count=$((target_count + 1))
    fi

    if caddy_service_active && ! pm2_has_running_apps; then
        echo -e "${YELLOW}Legacy system Caddy:${NC} active, no PM2 apps online"
        target_count=$((target_count + 1))
    fi

    if [ "$target_count" -eq 0 ]; then
        echo -e "${GREEN}No safe cleanup targets found.${NC}"
        return 0
    fi

    echo ""
    if ! ui_confirm "Clean all $target_count safe target(s) now?"; then
        echo -e "${BLUE}Cancelled - no process stopped.${NC}"
        return 0
    fi

    if [ -n "$groups" ]; then
        while IFS='|' read -r pgid count rss etime providers ancestors pids tty cmd; do
            [ -n "$pgid" ] || continue
            if pgid_contains_codex "$pgid"; then
                echo -e "${YELLOW}Skipping PGID $pgid because it contains a Codex process.${NC}"
                continue
            fi
            stop_mcp_process_group "$pgid" "PGID $pgid · $providers · $(mcp_format_rss "$rss") · $(mcp_format_elapsed "$etime")"
        done <<< "$groups"
    fi

    if [ -n "$pm2_pid" ] && ! pm2_has_running_apps; then
        if [ "${SHIPFLOW_MCP_CLEANUP_DRY_RUN:-0}" = "1" ]; then
            echo "pm2 kill"
        else
            pm2 kill >/dev/null 2>&1 || true
            invalidate_pm2_cache
            echo -e "${GREEN}Stopped empty PM2 daemon.${NC}"
        fi
    fi

    if ! pm2_has_running_apps; then
        stop_user_caddy || true
        stop_caddy_if_no_pm2_apps || true
    fi
}

user_caddy_enabled() {
    [ "${SHIPFLOW_USER_CADDY_ENABLED:-true}" = "true" ] && command -v caddy >/dev/null 2>&1
}

ensure_user_caddy_dir() {
    mkdir -p "$SHIPFLOW_USER_CADDY_DIR" "$SHIPFLOW_USER_CADDY_STORAGE_DIR" 2>/dev/null || return 1
    chmod 700 "$SHIPFLOW_USER_CADDY_DIR" "$SHIPFLOW_USER_CADDY_STORAGE_DIR" 2>/dev/null || true
}

user_caddy_pid() {
    local pid=""
    if [ -f "$SHIPFLOW_USER_CADDY_PID_FILE" ]; then
        pid=$(sed -n '1p' "$SHIPFLOW_USER_CADDY_PID_FILE" 2>/dev/null)
        if [[ "$pid" =~ ^[0-9]+$ ]] && ps -p "$pid" -o args= 2>/dev/null | grep -Fq "$SHIPFLOW_USER_CADDYFILE"; then
            printf '%s' "$pid"
            return 0
        fi
    fi
    return 1
}

user_caddy_is_running() {
    user_caddy_pid >/dev/null
}

stop_user_caddy() {
    local pid
    pid=$(user_caddy_pid || true)

    if [ -z "$pid" ]; then
        rm -f "$SHIPFLOW_USER_CADDY_PID_FILE" 2>/dev/null || true
        echo -e "${GREEN}User Caddy is not running.${NC}"
        return 0
    fi

    echo -e "${YELLOW}Stopping user Caddy:${NC} PID $pid"
    if [ "${SHIPFLOW_USER_CADDY_DRY_RUN:-0}" = "1" ] || [ "${SHIPFLOW_AGGRESSIVE_CLEANUP_DRY_RUN:-0}" = "1" ]; then
        echo "kill -TERM $pid"
        return 0
    fi

    kill -TERM "$pid" 2>/dev/null || true
    sleep 1
    if ps -p "$pid" >/dev/null 2>&1; then
        kill -KILL "$pid" 2>/dev/null || true
    fi
    rm -f "$SHIPFLOW_USER_CADDY_PID_FILE" 2>/dev/null || true
    echo -e "${GREEN}Stopped user Caddy.${NC}"
}

user_caddy_routes_from_pm2() {
    get_pm2_data_cached 2>/dev/null | awk -F'|' '
        ($2 == "online" || $2 == "launching") && $3 ~ /^[0-9]+$/ && $1 ~ /^[A-Za-z0-9._-]+$/ {
            print $1 "|" $3
        }
    '
}

write_user_caddyfile() {
    local routes="$1"
    local route_lines=""
    local name port

    while IFS='|' read -r name port; do
        [ -n "$name" ] || continue
        route_lines="${route_lines}    handle /${name}* {"$'\n'
        route_lines="${route_lines}        reverse_proxy 127.0.0.1:${port}"$'\n'
        route_lines="${route_lines}    }"$'\n'
    done <<< "$routes"

    ensure_user_caddy_dir || return 1

    cat > "$SHIPFLOW_USER_CADDYFILE" << EOF
{
    admin off
    storage file_system $SHIPFLOW_USER_CADDY_STORAGE_DIR
}

http://$SHIPFLOW_USER_CADDY_BIND:$SHIPFLOW_USER_CADDY_PORT {
    log {
        output file $SHIPFLOW_USER_CADDY_LOG_FILE {
            roll_size 5mb
            roll_keep 3
            roll_keep_for 168h
        }
    }
    encode gzip
${route_lines}    respond "ShipFlow user Caddy: no matching PM2 route" 404
}
EOF
    caddy fmt --overwrite "$SHIPFLOW_USER_CADDYFILE" >/dev/null 2>&1 || true
}

start_user_caddy() {
    if ! user_caddy_enabled; then
        return 0
    fi

    ensure_user_caddy_dir || {
        warning "Impossible de créer le runtime Caddy utilisateur: $SHIPFLOW_USER_CADDY_DIR"
        return 1
    }

    if [ "${SHIPFLOW_USER_CADDY_DRY_RUN:-0}" = "1" ]; then
        echo "caddy run --config $SHIPFLOW_USER_CADDYFILE --adapter caddyfile"
        return 0
    fi

    stop_user_caddy >/dev/null 2>&1 || true

    if is_port_in_use "$SHIPFLOW_USER_CADDY_PORT"; then
        warning "Port user Caddy déjà occupé: $SHIPFLOW_USER_CADDY_PORT"
        return 1
    fi

    if ! caddy validate --config "$SHIPFLOW_USER_CADDYFILE" --adapter caddyfile >/dev/null 2>&1; then
        warning "Caddyfile utilisateur invalide: $SHIPFLOW_USER_CADDYFILE"
        return 1
    fi

    nohup caddy run --config "$SHIPFLOW_USER_CADDYFILE" --adapter caddyfile >> "$SHIPFLOW_USER_CADDY_STDOUT_FILE" 2>&1 &
    printf '%s\n' "$!" > "$SHIPFLOW_USER_CADDY_PID_FILE"
    sleep 0.5

    if user_caddy_is_running; then
        echo -e "${GREEN}User Caddy running:${NC} http://$SHIPFLOW_USER_CADDY_BIND:$SHIPFLOW_USER_CADDY_PORT"
        return 0
    fi

    warning "User Caddy did not stay running; see $SHIPFLOW_USER_CADDY_STDOUT_FILE"
    return 1
}

refresh_user_caddy_from_pm2() {
    if [ "${SHIPFLOW_USER_CADDY_ENABLED:-true}" != "true" ]; then
        return 0
    fi

    if ! command -v caddy >/dev/null 2>&1; then
        warning "Caddy non installé; proxy utilisateur ignoré."
        return 0
    fi

    local routes
    routes=$(user_caddy_routes_from_pm2)
    if [ -z "$routes" ]; then
        stop_user_caddy
        return 0
    fi

    if [ "${SHIPFLOW_USER_CADDY_DRY_RUN:-0}" = "1" ]; then
        echo "User Caddy routes:"
        printf '%s\n' "$routes"
        echo "write $SHIPFLOW_USER_CADDYFILE"
        echo "listen http://$SHIPFLOW_USER_CADDY_BIND:$SHIPFLOW_USER_CADDY_PORT"
        return 0
    fi

    write_user_caddyfile "$routes" || {
        warning "Impossible d'écrire le Caddyfile utilisateur."
        return 1
    }
    start_user_caddy
}

sync_caddy_after_pm2_change() {
    if pm2_has_running_apps; then
        refresh_user_caddy_from_pm2 || true
    else
        stop_user_caddy || true
        stop_caddy_if_no_pm2_apps || true
    fi
}

stop_all_caddy_if_no_pm2_apps() {
    if pm2_has_running_apps; then
        echo -e "${YELLOW}PM2 apps are running; skipping Caddy stop.${NC}"
        return 1
    fi

    stop_user_caddy || true
    stop_caddy_if_no_pm2_apps || true
}

caddy_service_active() {
    systemctl is-active --quiet caddy 2>/dev/null
}

stop_caddy_if_no_pm2_apps() {
    if ! command -v systemctl >/dev/null 2>&1; then
        return 0
    fi

    if ! caddy_service_active; then
        echo -e "${GREEN}Caddy is not running.${NC}"
        return 0
    fi

    if pm2_has_running_apps; then
        echo -e "${YELLOW}PM2 apps are running; skipping Caddy stop.${NC}"
        return 1
    fi

    echo -e "${YELLOW}Caddy is running while no PM2 apps are online.${NC}"
    if [ "${SHIPFLOW_AGGRESSIVE_CLEANUP_DRY_RUN:-0}" = "1" ]; then
        echo "sudo systemctl stop caddy"
        return 0
    fi

    if sudo systemctl stop caddy; then
        echo -e "${GREEN}Stopped Caddy.${NC}"
    else
        echo -e "${RED}Failed to stop Caddy.${NC}"
        return 1
    fi
}

aggressive_user_process_groups() {
    ps -eo pid=,ppid=,pgid=,user=,etimes=,rss=,comm=,args= --no-headers 2>/dev/null | awk -v user="$(id -un)" '
        $4 == user {
            pid=$1; pgid=$3; etime=$5; rss=$6; comm=$7
            args=""
            for (i=8; i<=NF; i++) args=args (args == "" ? "" : " ") $i
            kind=""
            if (comm == "codex" || (comm == "node" && args ~ /\/codex( |$)/)) kind="codex"
            else if (comm == "ranger" || args ~ /\/ranger( |$)/) kind="ranger"
            if (kind != "") {
                count[pgid]++
                rss_sum[pgid]+=rss
                if (etime > etime_max[pgid]) etime_max[pgid]=etime
                if (kinds[pgid] == "") kinds[pgid]=kind
                else if (kinds[pgid] !~ "(^|,)" kind "(,|$)") kinds[pgid]=kinds[pgid] "," kind
                if (pids[pgid] == "") pids[pgid]=pid
                else pids[pgid]=pids[pgid] "," pid
                if (cmd[pgid] == "") cmd[pgid]=comm " " args
            }
        }
        END {
            for (pgid in count) {
                print pgid "|" count[pgid] "|" rss_sum[pgid] "|" etime_max[pgid] "|" kinds[pgid] "|" pids[pgid] "|" cmd[pgid]
            }
        }
    ' | sort -t'|' -k4,4nr
}

show_aggressive_user_process_groups() {
    local groups
    groups=$(aggressive_user_process_groups)
    if [ -z "$groups" ]; then
        echo -e "${GREEN}No Codex/node-wrapper/ranger process groups detected.${NC}"
        return 0
    fi

    echo -e "${BLUE}━━━ Aggressive User Process Groups ━━━${NC}"
    printf "  ${CYAN}%-8s %-5s %-8s %-8s %-14s %-s${NC}\n" "PGID" "PROCS" "RSS" "UPTIME" "KIND" "PIDS"
    while IFS='|' read -r pgid count rss etime kinds pids cmd; do
        printf "  ${YELLOW}%-8s %-5s %-8s %-8s %-14s${NC} %-s\n" \
            "$pgid" "$count" "$(mcp_format_rss "$rss")" "$(mcp_format_elapsed "$etime")" "$kinds" "$pids"
    done <<< "$groups"
}

stop_process_group_term_then_optional_kill() {
    local pgid="$1"
    local label="$2"

    if ! [[ "$pgid" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid process group:${NC} $pgid"
        return 1
    fi

    echo -e "${YELLOW}Stopping:${NC} $label"
    if [ "${SHIPFLOW_AGGRESSIVE_CLEANUP_DRY_RUN:-0}" = "1" ]; then
        echo "kill -TERM -$pgid"
        return 0
    fi

    kill -TERM "-$pgid" 2>/dev/null || true
    sleep 1
    if ps -o pid= -g "$pgid" 2>/dev/null | grep -q '[0-9]'; then
        if ui_confirm "Process group $pgid is still running. Force kill it?"; then
            kill -KILL "-$pgid" 2>/dev/null || true
        fi
    fi
}

aggressive_cleanup_menu() {
    local groups mcp_groups pm2_pid caddy_running target_count=0
    groups=$(aggressive_user_process_groups)
    mcp_groups=$(mcp_process_groups)
    pm2_pid=$(pm2_daemon_pid)

    ui_screen_header "Aggressive Cleanup" danger
    echo -e "${YELLOW}Targets:${NC} Codex conversations, Codex node wrappers, ranger, MCP servers, empty PM2 daemon, and Caddy when no PM2 app is online."
    echo -e "${YELLOW}Protected:${NC} ssh, tmux server, shell sessions, systemd, root services except Caddy."
    echo ""

    if [ -n "$groups" ]; then
        show_aggressive_user_process_groups
        target_count=$((target_count + $(printf '%s\n' "$groups" | sed '/^[[:space:]]*$/d' | wc -l)))
    else
        echo -e "${GREEN}No Codex/node-wrapper/ranger process groups detected.${NC}"
    fi

    if [ -n "$mcp_groups" ]; then
        echo ""
        show_mcp_process_groups
        target_count=$((target_count + $(printf '%s\n' "$mcp_groups" | sed '/^[[:space:]]*$/d' | wc -l)))
    fi

    if [ -n "$pm2_pid" ] && ! pm2_has_running_apps; then
        echo -e "${YELLOW}Empty PM2 daemon:${NC} PID $pm2_pid"
        target_count=$((target_count + 1))
    fi

    if user_caddy_is_running && ! pm2_has_running_apps; then
        echo -e "${YELLOW}User Caddy:${NC} PID $(user_caddy_pid)"
        target_count=$((target_count + 1))
    fi

    if caddy_service_active && ! pm2_has_running_apps; then
        echo -e "${YELLOW}Legacy system Caddy:${NC} active, no PM2 apps online"
        target_count=$((target_count + 1))
    fi

    if [ "$target_count" -eq 0 ]; then
        echo -e "${GREEN}No aggressive cleanup targets found.${NC}"
        return 0
    fi

    echo ""
    if ! ui_confirm "Aggressively stop $target_count target(s) now? This can close Codex conversations."; then
        echo -e "${BLUE}Cancelled - no process stopped.${NC}"
        return 0
    fi

    if [ -n "$groups" ]; then
        while IFS='|' read -r pgid count rss etime kinds pids cmd; do
            [ -n "$pgid" ] || continue
            stop_process_group_term_then_optional_kill "$pgid" "PGID $pgid · $kinds · $(mcp_format_rss "$rss") · $(mcp_format_elapsed "$etime")"
        done <<< "$groups"
    fi

    if [ -n "$mcp_groups" ]; then
        while IFS='|' read -r pgid count rss etime providers ancestors pids tty cmd; do
            [ -n "$pgid" ] || continue
            stop_process_group_term_then_optional_kill "$pgid" "MCP PGID $pgid · $providers · $(mcp_format_rss "$rss") · $(mcp_format_elapsed "$etime")"
        done <<< "$mcp_groups"
    fi

    if [ -n "$pm2_pid" ] && ! pm2_has_running_apps; then
        if [ "${SHIPFLOW_AGGRESSIVE_CLEANUP_DRY_RUN:-0}" = "1" ]; then
            echo "pm2 kill"
        else
            pm2 kill >/dev/null 2>&1 || true
            invalidate_pm2_cache
            echo -e "${GREEN}Stopped empty PM2 daemon.${NC}"
        fi
    fi

    if ! pm2_has_running_apps; then
        stop_user_caddy || true
        stop_caddy_if_no_pm2_apps || true
    fi
}

# mem_alerts - Generate alerts for concerning memory situations
# Output: one alert per line (severity|message)
mem_alerts() {
    local alerts=()

    # Check low memory
    if mem_is_low; then
        local avail
        avail=$(mem_available_human)
        local total
        total=$(mem_total_human)
        alerts+=("critical|RAM critically low: ${avail} available of ${total} total")
    fi

    # Check for long-running heavy processes
    local long_running
    long_running=$(mem_long_running_processes)
    if [ -n "$long_running" ]; then
        local count
        count=$(echo "$long_running" | wc -l)
        alerts+=("warning|${count} process(es) running ${SHIPFLOW_PROCESS_LONG_RUNNING_HOURS:-24}h+ with >100MB RAM")
    fi

    local mcp_groups
    mcp_groups=$(mcp_process_groups)
    if [ -n "$mcp_groups" ]; then
        local mcp_count
        mcp_count=$(printf '%s\n' "$mcp_groups" | wc -l)
        alerts+=("info|${mcp_count} local MCP process group(s) detected; use Health Check -> MCP process cleanup if they are no longer needed")
    fi

    # Check if any single process uses > 25% of total RAM
    local total_kb
    total_kb=$(mem_total_kb)
    if [ -n "$total_kb" ] && [ "$total_kb" -gt 0 ]; then
        local threshold_kb=$(( total_kb / 4 ))
        ps axo pid,rss,comm --sort=-rss --no-headers 2>/dev/null | head -5 | while read -r pid rss comm; do
            if [ "$rss" -ge "$threshold_kb" ]; then
                local rss_mb=$(( rss / 1024 ))
                echo "warning|Process '${comm}' (PID ${pid}) using ${rss_mb}MB — over 25% of total RAM"
            fi
        done
    fi

    # Print collected alerts
    for alert in "${alerts[@]}"; do
        echo "$alert"
    done
}

# system_monitor_menu - Interactive system resource monitor
system_monitor_menu() {
    echo -e "${GREEN}🖥️  System Monitor${NC}"
    echo ""

    # --- RAM Overview ---
    local avail total used_kb avail_kb total_kb used_pct
    avail=$(mem_available_human)
    total=$(mem_total_human)
    avail_kb=$(mem_available_kb)
    total_kb=$(mem_total_kb)
    if [ -n "$avail_kb" ] && [ -n "$total_kb" ] && [ "$total_kb" -gt 0 ]; then
        used_kb=$((total_kb - avail_kb))
        used_pct=$((used_kb * 100 / total_kb))
    else
        used_pct="?"
    fi

    echo -e "${BLUE}━━━ Memory Overview ━━━${NC}"
    echo -e "  Available: ${GREEN}${avail}${NC}  /  Total: ${CYAN}${total}${NC}  (${YELLOW}${used_pct}%${NC} used)"

    # Visual bar
    print_usage_bar "$used_pct"
    echo ""

    # --- Disk Overview ---
    local disk_free disk_total disk_used disk_pct disk_level disk_fs
    disk_free=$(disk_free_human)
    disk_total=$(disk_total_human)
    disk_used=$(disk_used_human)
    disk_pct=$(disk_used_pct)
    disk_level=$(disk_pressure_level "" "$disk_pct")
    disk_fs=$(disk_filesystem)

    echo -e "${BLUE}━━━ Disk Overview ━━━${NC}"
    if [ -n "$disk_free" ] && [ -n "$disk_total" ]; then
        echo -e "  Available: ${GREEN}${disk_free}${NC}  /  Total: ${CYAN}${disk_total}${NC}  (${YELLOW}${disk_pct:-?}%${NC} used)"
        if [ -n "$disk_used" ]; then
            echo -e "  Used: ${YELLOW}${disk_used}${NC}  /  Filesystem: ${CYAN}${disk_fs:-/}${NC} mounted on ${CYAN}/${NC}"
        fi
        print_usage_bar "$disk_pct" 30 "${SHIPFLOW_DISK_HIGH_PCT:-90}" "${SHIPFLOW_DISK_WARN_PCT:-85}"
        if [ "$disk_level" = "ok" ]; then
            echo -e "  Status: ${GREEN}OK${NC}"
        else
            print_disk_pressure_warning "$disk_level" "$disk_free" "$disk_pct"
        fi
    else
        echo -e "  ${YELLOW}Disk metrics unavailable${NC}"
    fi
    echo ""

    # --- Alerts ---
    local alerts
    alerts=$(mem_alerts)
    if [ -n "$alerts" ]; then
        echo -e "${RED}━━━ Alerts ━━━${NC}"
        while IFS='|' read -r severity msg; do
            case "$severity" in
                critical) echo -e "  ${RED}🔴 $msg${NC}" ;;
                warning)  echo -e "  ${YELLOW}🟠 $msg${NC}" ;;
                info)     echo -e "  ${BLUE}🔵 $msg${NC}" ;;
            esac
        done <<< "$alerts"
        echo ""
    fi

    # --- Long-running processes ---
    local long_procs
    long_procs=$(mem_long_running_processes)
    if [ -n "$long_procs" ]; then
        echo -e "${YELLOW}━━━ Long-Running Processes (${SHIPFLOW_PROCESS_LONG_RUNNING_HOURS:-24}h+, >100MB) ━━━${NC}"
        printf "  ${CYAN}%-10s %-7s %5s %7s %8s  %-s${NC}\n" "USER" "PID" "%MEM" "RSS" "UPTIME" "COMMAND"
        while IFS='|' read -r user pid pmem rss elapsed comm; do
            printf "  ${YELLOW}%-10s %-7s %5s %7s %8s${NC}  %s\n" "$user" "$pid" "$pmem" "$rss" "$elapsed" "$comm"
        done <<< "$long_procs"
        echo ""
    fi

    # --- Top processes ---
    echo -e "${BLUE}━━━ Top Processes by Memory ━━━${NC}"
    printf "  ${CYAN}%-10s %-7s %5s %7s %8s  %-s${NC}\n" "USER" "PID" "%MEM" "RSS" "UPTIME" "COMMAND"
    local top_procs
    top_procs=$(mem_top_processes)
    if [ -n "$top_procs" ]; then
        while IFS='|' read -r user pid pmem rss elapsed comm; do
            # Highlight long-running or heavy processes
            local line_color=""
            if [[ "$elapsed" == *d* ]]; then
                line_color="${YELLOW}"
            fi
            printf "  ${line_color}%-10s %-7s %5s %7s %8s${NC}  %s\n" "$user" "$pid" "$pmem" "$rss" "$elapsed" "$comm"
        done <<< "$top_procs"
    fi
    echo ""

    # --- MCP groups ---
    local mcp_groups
    mcp_groups=$(mcp_process_groups)
    if [ -n "$mcp_groups" ]; then
        show_mcp_process_groups
        echo ""
    fi

    # --- Swap ---
    local swap_total swap_used
    swap_total=$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo 2>/dev/null)
    swap_used=$(awk '/^SwapFree:/ {print $2}' /proc/meminfo 2>/dev/null)
    if [ -n "$swap_total" ] && [ "$swap_total" -gt 0 ]; then
        local swap_used_kb=$((swap_total - swap_used))
        echo -e "${BLUE}━━━ Swap ━━━${NC}"
        echo -e "  Used: $(( swap_used_kb / 1024 ))M  /  Total: $(( swap_total / 1024 ))M"
    else
        echo -e "${BLUE}Swap:${NC} none configured"
    fi
}

# ============================================================================
# UPDATE CHECK UTILITIES
# ============================================================================

UPDATE_CACHE_TIME=0
UPDATE_CACHE_TOTAL=""
UPDATE_CACHE_APT=0
UPDATE_CACHE_NPM=0
UPDATE_CACHE_PIP=0
UPDATE_CACHE_RUSTUP=0
UPDATE_CACHE_TTL=300
MENU_STATUS_CACHE_FILE="${SHIPFLOW_SECRETS_DIR}/menu-status.cache"
MENU_STATUS_LOCK_FILE="${SHIPFLOW_SECRETS_DIR}/menu-status.lock"

run_with_timeout() {
    if command -v timeout >/dev/null 2>&1; then
        timeout 6s "$@"
    else
        "$@"
    fi
}

count_apt_updates() {
    if ! command -v apt >/dev/null 2>&1; then
        echo 0
        return
    fi
    local out
    out=$(run_with_timeout apt list --upgradable 2>/dev/null || true)
    echo "$out" | tail -n +2 | sed '/^$/d' | wc -l
}

count_npm_updates() {
    if ! command -v npm >/dev/null 2>&1; then
        echo 0
        return
    fi
    local out
    out=$(run_with_timeout npm -g outdated --parseable --depth=0 2>/dev/null || true)
    echo "$out" | sed '/^$/d' | wc -l
}

count_pip_updates() {
    if command -v python3 >/dev/null 2>&1; then
        local out
        out=$(run_with_timeout python3 -m pip list --outdated --format=columns 2>/dev/null || true)
        echo "$out" | tail -n +3 | sed '/^$/d' | wc -l
        return
    fi
    if command -v pip >/dev/null 2>&1; then
        local out
        out=$(run_with_timeout pip list --outdated --format=columns 2>/dev/null || true)
        echo "$out" | tail -n +3 | sed '/^$/d' | wc -l
        return
    fi
    echo 0
}

count_rustup_updates() {
    if ! command -v rustup >/dev/null 2>&1; then
        echo 0
        return
    fi
    local out
    out=$(run_with_timeout rustup update --check 2>/dev/null || true)
    echo "$out" | grep -ci "available"
}

updates_refresh_cache() {
    local now
    now=$(date +%s)
    if [ $((now - UPDATE_CACHE_TIME)) -lt $UPDATE_CACHE_TTL ] && [ -n "$UPDATE_CACHE_TOTAL" ]; then
        return
    fi

    UPDATE_CACHE_APT=$(count_apt_updates)
    UPDATE_CACHE_NPM=$(count_npm_updates)
    UPDATE_CACHE_PIP=$(count_pip_updates)
    UPDATE_CACHE_RUSTUP=$(count_rustup_updates)

    UPDATE_CACHE_TOTAL=$((UPDATE_CACHE_APT + UPDATE_CACHE_NPM + UPDATE_CACHE_PIP + UPDATE_CACHE_RUSTUP))
    UPDATE_CACHE_TIME=$now
}

updates_total_cached() {
    updates_refresh_cache
    echo "$UPDATE_CACHE_TOTAL"
}

# -----------------------------------------------------------------------------
# read_menu_status_cache - Read cached header status values from disk
#
# Outputs (globals):
#   MENU_STATUS_TS, MENU_STATUS_FREE_HUMAN, MENU_STATUS_UPDATES_TOTAL,
#   MENU_STATUS_LOW_SPACE, MENU_STATUS_MEM_HUMAN, MENU_STATUS_MEM_TOTAL_HUMAN,
#   MENU_STATUS_LOW_MEM
# -----------------------------------------------------------------------------
read_menu_status_cache() {
    MENU_STATUS_TS=0
    MENU_STATUS_FREE_HUMAN=""
    MENU_STATUS_UPDATES_TOTAL=""
    MENU_STATUS_LOW_SPACE=0
    MENU_STATUS_MEM_HUMAN=""
    MENU_STATUS_MEM_TOTAL_HUMAN=""
    MENU_STATUS_LOW_MEM=0

    [ -f "$MENU_STATUS_CACHE_FILE" ] || return 1

    while IFS='=' read -r key value; do
        case "$key" in
            ts) MENU_STATUS_TS="$value" ;;
            free_human) MENU_STATUS_FREE_HUMAN="$value" ;;
            updates_total) MENU_STATUS_UPDATES_TOTAL="$value" ;;
            low_space) MENU_STATUS_LOW_SPACE="$value" ;;
            mem_human) MENU_STATUS_MEM_HUMAN="$value" ;;
            mem_total_human) MENU_STATUS_MEM_TOTAL_HUMAN="$value" ;;
            low_mem) MENU_STATUS_LOW_MEM="$value" ;;
        esac
    done < "$MENU_STATUS_CACHE_FILE"

    return 0
}

# -----------------------------------------------------------------------------
# refresh_menu_status_cache_sync - Recompute and persist menu header status
#
# Returns:
#   0 - Cache written
#   1 - Failed to compute/write cache
# -----------------------------------------------------------------------------
refresh_menu_status_cache_sync() {
    mkdir -p "$SHIPFLOW_SECRETS_DIR" 2>/dev/null || true

    local now
    now=$(date +%s)
    local free_human
    free_human=$(disk_free_human)
    local updates_total
    updates_total=$(updates_total_cached)
    local low_space=0
    if disk_is_low_space; then
        low_space=1
    fi
    local mem_human
    mem_human=$(mem_available_human)
    local mem_total_human
    mem_total_human=$(mem_total_human)
    local low_mem=0
    if mem_is_low; then
        low_mem=1
    fi

    local tmp_file
    tmp_file=$(mktemp "${MENU_STATUS_CACHE_FILE}.tmp.XXXXXX" 2>/dev/null) || return 1
    register_temp_file "$tmp_file"

    {
        echo "ts=$now"
        echo "free_human=$free_human"
        echo "updates_total=$updates_total"
        echo "low_space=$low_space"
        echo "mem_human=$mem_human"
        echo "mem_total_human=$mem_total_human"
        echo "low_mem=$low_mem"
    } > "$tmp_file"

    mv "$tmp_file" "$MENU_STATUS_CACHE_FILE" 2>/dev/null || return 1
    chmod 600 "$MENU_STATUS_CACHE_FILE" 2>/dev/null || true
    return 0
}

# -----------------------------------------------------------------------------
# refresh_menu_status_cache_async_if_stale - Background cache refresh
#
# Behavior:
#   - Returns immediately
#   - Refreshes only when cache is missing/stale
#   - Uses PID lock to avoid concurrent expensive refreshes
# -----------------------------------------------------------------------------
refresh_menu_status_cache_async_if_stale() {
    local ttl="${SHIPFLOW_MENU_STATUS_CACHE_TTL:-120}"
    if ! [[ "$ttl" =~ ^[0-9]+$ ]]; then
        ttl=120
    fi

    local now cache_ts=0
    now=$(date +%s)

    if read_menu_status_cache && [ -n "$MENU_STATUS_TS" ]; then
        cache_ts="$MENU_STATUS_TS"
    fi

    if [ $((now - cache_ts)) -lt "$ttl" ]; then
        return 0
    fi

    if [ -f "$MENU_STATUS_LOCK_FILE" ]; then
        local existing_pid
        existing_pid=$(cat "$MENU_STATUS_LOCK_FILE" 2>/dev/null || true)
        if [ -n "$existing_pid" ] && kill -0 "$existing_pid" 2>/dev/null; then
            return 0
        fi
    fi

    (
        echo $$ > "$MENU_STATUS_LOCK_FILE"
        refresh_menu_status_cache_sync >/dev/null 2>&1 || true
        rm -f "$MENU_STATUS_LOCK_FILE" 2>/dev/null || true
    ) >/dev/null 2>&1 &
}

updates_menu() {
    ui_screen_header "Updates Summary"
    echo -e "${BLUE}Checking package updates...${NC}"
    echo ""
    updates_refresh_cache

    echo -e "${BLUE}Pending updates:${NC}"
    echo -e "  ${CYAN}•${NC} apt:     ${YELLOW}${UPDATE_CACHE_APT}${NC}"
    echo -e "  ${CYAN}•${NC} npm -g:  ${YELLOW}${UPDATE_CACHE_NPM}${NC}"
    echo -e "  ${CYAN}•${NC} pip:     ${YELLOW}${UPDATE_CACHE_PIP}${NC}"
    echo -e "  ${CYAN}•${NC} rustup:  ${YELLOW}${UPDATE_CACHE_RUSTUP}${NC}"
    echo -e "  ${CYAN}•${NC} Total:   ${GREEN}${UPDATE_CACHE_TOTAL}${NC}"
    echo ""

    echo -e "${BLUE}Options:${NC}"
    echo -e "  ${CYAN}u)${NC} Update All"
    echo ""
    echo -e "  ${CYAN}x)${NC} Back"
    echo ""
    echo -e "${YELLOW}Your choice:${NC} \c"
    ui_read_choice update_choice

    case $update_choice in
        u)
            echo -e "${YELLOW}This will run system and global package updates.${NC}"
            if ! ui_confirm "Proceed with Update All?"; then
                echo -e "${BLUE}Cancelled${NC}"
                return 0
            fi

            if command -v apt >/dev/null 2>&1; then
                echo -e "${GREEN}🔧 Updating apt...${NC}"
                sudo apt update && sudo apt upgrade -y
            fi

            if command -v npm >/dev/null 2>&1; then
                echo -e "${GREEN}🔧 Updating npm globals...${NC}"
                npm -g update
            fi

            if command -v python3 >/dev/null 2>&1; then
                echo -e "${GREEN}🔧 Updating pip packages...${NC}"
                python3 -m pip list --outdated --format=freeze 2>/dev/null | cut -d= -f1 | \
                    xargs -n1 python3 -m pip install -U 2>/dev/null || true
            elif command -v pip >/dev/null 2>&1; then
                echo -e "${GREEN}🔧 Updating pip packages...${NC}"
                pip list --outdated --format=freeze 2>/dev/null | cut -d= -f1 | \
                    xargs -n1 pip install -U 2>/dev/null || true
            fi

            if command -v rustup >/dev/null 2>&1; then
                echo -e "${GREEN}🔧 Updating rustup toolchains...${NC}"
                rustup update
            fi

            echo -e "${GREEN}✅ Updates complete${NC}"
            UPDATE_CACHE_TIME=0
            updates_refresh_cache
            ;;
        x|q)
            ui_return_back
            return 0
            ;;
        *)
            ;;
    esac
}

# ============================================================================
# ENVIRONMENT SELECTION
# ============================================================================

# -----------------------------------------------------------------------------
# select_environment - Interactive environment picker with status icons
#
# Arguments:
#   $1 - Prompt text (optional, default: "Select an environment")
#
# Outputs:
#   Selected environment name to stdout
#
# Returns:
#   0 - Selection made
#   1 - Cancelled or no environments
# -----------------------------------------------------------------------------
select_environment() {
    local prompt_text="${1:-Select an environment}"

    local all_envs=$(list_all_environments)

    if [ -z "$all_envs" ]; then
        echo -e "${RED}No environments found${NC}" >&2
        return 1
    fi

    # Build options with status icons
    local options=()
    while IFS= read -r env; do
        local status=$(get_pm2_status "$env")
        local icon=$(get_status_icon "$status")
        options+=("${icon} ${env}")
    done <<< "$all_envs"

    # Use ui_choose for selection
    local selected
    selected=$(ui_choose "$prompt_text" "${options[@]}") || return 1

    # Strip the icon prefix to return just the environment name
    echo "$selected" | sed 's/^[^ ]* //'
    return 0
}

select_stop_target() {
    local prompt_text="${1:-Select environment to stop}"

    local all_envs=$(list_all_stop_targets)

    if [ -z "$all_envs" ]; then
        echo -e "${RED}No environments or PM2 apps found${NC}" >&2
        return 1
    fi

    local options=()
    while IFS= read -r env; do
        local status=$(get_pm2_status_by_name "$env")
        local icon=$(get_status_icon "$status")
        options+=("${icon} ${env}")
    done <<< "$all_envs"

    local selected
    selected=$(ui_choose "$prompt_text" "${options[@]}") || return 1

    echo "$selected" | sed 's/^[^ ]* //'
    return 0
}

# ============================================================================
# CREDENTIAL CACHE
# ============================================================================

# Secrets file path
SHIPFLOW_SECRETS_FILE="${SHIPFLOW_SECRETS_DIR}/secrets"

# -----------------------------------------------------------------------------
# save_secret - Save a key=value pair to the secrets file
#
# Arguments:
#   $1 - Key name
#   $2 - Value (will NOT be logged or echoed)
#
# Side Effects:
#   Creates ~/.shipflow/ (chmod 700) and secrets file (chmod 600) if needed
# -----------------------------------------------------------------------------
save_secret() {
    local key="$1"
    local value="$2"

    if [[ ! "$key" =~ ^[A-Z0-9_]+$ ]]; then
        log ERROR "Invalid secret key name: $key"
        return 1
    fi

    # Create directory with restricted permissions
    if [ ! -d "$SHIPFLOW_SECRETS_DIR" ]; then
        mkdir -p "$SHIPFLOW_SECRETS_DIR"
        chmod 700 "$SHIPFLOW_SECRETS_DIR"
    fi

    # Create or update secrets file
    if [ ! -f "$SHIPFLOW_SECRETS_FILE" ]; then
        touch "$SHIPFLOW_SECRETS_FILE"
        chmod 600 "$SHIPFLOW_SECRETS_FILE"
    else
        # Ensure permissions are correct
        chmod 600 "$SHIPFLOW_SECRETS_FILE"
    fi

    local tmp_file
    tmp_file=$(mktemp "${SHIPFLOW_SECRETS_FILE}.tmp.XXXXXX") || return 1
    chmod 600 "$tmp_file"

    if ! awk -v key="$key" -v value="$value" '
        BEGIN { found = 0 }
        index($0, key "=") == 1 {
            print key "=" value
            found = 1
            next
        }
        { print }
        END {
            if (!found) {
                print key "=" value
            }
        }
    ' "$SHIPFLOW_SECRETS_FILE" > "$tmp_file"; then
        rm -f "$tmp_file"
        return 1
    fi

    mv "$tmp_file" "$SHIPFLOW_SECRETS_FILE"
    chmod 600 "$SHIPFLOW_SECRETS_FILE"

    log INFO "Secret saved: $key (value hidden)"
}

# -----------------------------------------------------------------------------
# load_secret - Load a value from the secrets file
#
# Arguments:
#   $1 - Key name
#
# Outputs:
#   Value to stdout
#
# Returns:
#   0 - Key found
#   1 - Key not found or file doesn't exist
# -----------------------------------------------------------------------------
load_secret() {
    local key="$1"

    if [ ! -f "$SHIPFLOW_SECRETS_FILE" ]; then
        return 1
    fi

    local value
    value=$(grep "^${key}=" "$SHIPFLOW_SECRETS_FILE" 2>/dev/null | head -1 | cut -d'=' -f2-)

    if [ -z "$value" ]; then
        return 1
    fi

    echo "$value"
    return 0
}

# ============================================================================
# STRUCTURED LOGGING
# ============================================================================

# Ensure log directory exists
init_logging() {
    if [ "$SHIPFLOW_LOGGING_ENABLED" = "true" ]; then
        mkdir -p "$SHIPFLOW_LOG_DIR" 2>/dev/null || true
        touch "$SHIPFLOW_LOG_FILE" 2>/dev/null || true

        # Rotate old logs
        if [ -f "$SHIPFLOW_LOG_FILE" ]; then
            local log_size=$(stat -f%z "$SHIPFLOW_LOG_FILE" 2>/dev/null || stat -c%s "$SHIPFLOW_LOG_FILE" 2>/dev/null || echo 0)
            # Rotate if larger than 10MB
            if [ "$log_size" -gt 10485760 ]; then
                mv "$SHIPFLOW_LOG_FILE" "$SHIPFLOW_LOG_FILE.$(date +%s)" 2>/dev/null || true

                # Clean old logs
                find "$SHIPFLOW_LOG_DIR" -name "*.log.*" -mtime +$SHIPFLOW_LOG_RETENTION_DAYS -delete 2>/dev/null || true
            fi
        fi
    fi
}

# Structured logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Check if logging is enabled
    if [ "$SHIPFLOW_LOGGING_ENABLED" != "true" ]; then
        return 0
    fi

    # Check log level filtering
    local level_priority=0
    case "$level" in
        DEBUG) level_priority=0 ;;
        INFO) level_priority=1 ;;
        WARNING) level_priority=2 ;;
        ERROR) level_priority=3 ;;
    esac

    local config_priority=1  # Default to INFO
    case "$SHIPFLOW_LOG_LEVEL" in
        DEBUG) config_priority=0 ;;
        INFO) config_priority=1 ;;
        WARNING) config_priority=2 ;;
        ERROR) config_priority=3 ;;
    esac

    # Only log if level meets threshold
    if [ $level_priority -lt $config_priority ]; then
        return 0
    fi

    # Format: [TIMESTAMP] [LEVEL] message
    local log_entry="[$timestamp] [$level] $message"

    # Append to log file
    echo "$log_entry" >> "$SHIPFLOW_LOG_FILE" 2>/dev/null || true
}

# Initialize logging on load
init_logging

# ============================================================================
# JSON PARSING UTILITIES (Priority 3 #9: jq over Python)
# ============================================================================

# -----------------------------------------------------------------------------
# parse_json - Parse JSON data with jq or python fallback
#
# Description:
#   Parses JSON using jq if available (faster), falls back to python3.
#   Automatically chooses best available tool.
#
# Arguments:
#   $1 - JQ expression (e.g., '.[] | .name')
#   stdin - JSON data to parse
#
# Returns:
#   Parsed output
#
# Example:
#   echo '{"name":"test"}' | parse_json '.name'
# -----------------------------------------------------------------------------
parse_json() {
    local jq_expr=$1

    # Prefer jq if available and configured
    if [ "$SHIPFLOW_PREFER_JQ" = "true" ] && command -v jq >/dev/null 2>&1; then
        jq -r "$jq_expr" 2>/dev/null || {
            log ERROR "jq parsing failed with expression: $jq_expr"
            return 1
        }
    elif command -v python3 >/dev/null 2>&1; then
        # Fallback to python3
        # Convert jq expression to python (basic support)
        python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    # Note: This is a simplified fallback, not full jq compatibility
    print(data)
except Exception as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null || {
            log ERROR "python3 JSON parsing failed"
            return 1
        }
    else
        log ERROR "No JSON parser available (install jq or python3)"
        error "No JSON parser available"
        return 1
    fi
}

# ============================================================================
# PREREQUISITE & VALIDATION FUNCTIONS
# ============================================================================

# -----------------------------------------------------------------------------
# check_prerequisites - Validate required and optional tools are installed
#
# Description:
#   Checks for critical tools (pm2, node) and warns about missing optional
#   tools (flox, git, jq, python3). Shows a clear visual summary so the user
#   always knows the state. Fails if critical tools are missing.
#
# Arguments:
#   $1 - "quiet" to skip the summary (default: verbose)
#
# Returns:
#   0 - All required tools present
#   1 - Missing required tools
# -----------------------------------------------------------------------------
check_prerequisites() {
    local mode="${1:-verbose}"
    local missing=()
    local warnings=()
    local ok_count=0
    local total_count=0

    # All tools: name|required|version_cmd
    local -a tools=(
        "node|required|node --version"
        "pm2|required|pm2 --version"
        "git|optional|git --version"
        "flox|optional|flox --version 2>&1 | head -1"
        "caddy|optional|caddy version 2>&1 | head -1"
        "python3|optional|python3 --version"
        "jq|optional|jq --version"
        "gh|optional|gh --version 2>&1 | head -1"
        "fuser|optional|fuser -V 2>&1 | head -1"
    )

    if [ "$mode" != "quiet" ]; then
        echo -e "${BLUE}🔍 Vérification des outils...${NC}"
        echo ""
    fi

    for entry in "${tools[@]}"; do
        local cmd="${entry%%|*}"
        local rest="${entry#*|}"
        local level="${rest%%|*}"
        local ver_cmd="${rest#*|}"
        total_count=$((total_count + 1))

        if command -v "$cmd" >/dev/null 2>&1; then
            ok_count=$((ok_count + 1))
            if [ "$mode" != "quiet" ]; then
                local ver
                ver=$(eval "$ver_cmd" 2>/dev/null | head -1 | sed 's/^[[:space:]]*//')
                echo -e "  ${GREEN}✅ $cmd${NC} — $ver"
            fi
        else
            if [ "$level" = "required" ]; then
                missing+=("$cmd")
                [ "$mode" != "quiet" ] && echo -e "  ${RED}❌ $cmd${NC} — ${RED}REQUIS, manquant !${NC}"
            else
                warnings+=("$cmd")
                [ "$mode" != "quiet" ] && echo -e "  ${YELLOW}⚠️  $cmd${NC} — optionnel, non installé"
            fi
        fi
    done

    if [ "$mode" != "quiet" ]; then
        echo ""
        if [ ${#missing[@]} -gt 0 ]; then
            echo -e "${RED}╔══════════════════════════════════════════════════════════╗${NC}"
            echo -e "${RED}║  ⛔  Outils requis manquants : ${missing[*]}${NC}"
            echo -e "${RED}║  Lancez : ${YELLOW}sudo ./install.sh${RED} pour installer${NC}"
            echo -e "${RED}╚══════════════════════════════════════════════════════════╝${NC}"
        elif [ ${#warnings[@]} -gt 0 ]; then
            echo -e "  ${GREEN}$ok_count/$total_count outils OK${NC} — ${YELLOW}${#warnings[@]} optionnel(s) manquant(s)${NC}"
        else
            echo -e "  ${GREEN}✅ $ok_count/$total_count outils OK — tout est prêt !${NC}"
        fi
        echo ""
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        return 1
    fi

    return 0
}

# show_tools_status - Display full tools status (for menu use)
show_tools_status() {
    ui_screen_header "État des outils"
    check_prerequisites "verbose"
    echo -e "${BLUE}💡 Pour installer les outils manquants :${NC}"
    echo -e "   ${CYAN}sudo ./install.sh${NC}"
    echo ""
}

# -----------------------------------------------------------------------------
# install_sdk_menu - Interactive menu to install optional development SDKs
#
# Description:
#   Allows manual installation of global SDKs that are NOT required by ShipFlow
#   but useful for development (Flutter/Dart, etc.).
#   Requires sudo for system-wide installation.
# -----------------------------------------------------------------------------
install_sdk_menu() {
    local flutter_install_dir="/opt/flutter"
    local flutter_profile="/etc/profile.d/flutter.sh"

    ui_screen_header "Install SDK"

    # Flutter status
    local flutter_status
    if command -v flutter >/dev/null 2>&1; then
        local flutter_ver
        flutter_ver=$(flutter --version 2>&1 | head -n1)
        flutter_status="${GREEN}installed${NC} — $flutter_ver"
    else
        flutter_status="${YELLOW}not installed${NC}"
    fi

    echo -e "  ${CYAN}f)${NC} Flutter + Dart  [$flutter_status]"
    echo ""
    echo -e "  ${CYAN}x)${NC} Back"
    echo ""
    echo -e "${YELLOW}Your choice:${NC} \c"
    ui_read_choice sdk_choice

    case $sdk_choice in
        f)
            if command -v flutter >/dev/null 2>&1; then
                echo -e "${GREEN}Flutter is already installed.${NC}"
                echo -e "  Version: $(flutter --version 2>&1 | head -n1)"
                echo -e "  Dart:    $(dart --version 2>&1)"
                echo ""
                echo -e "${BLUE}To update: flutter upgrade${NC}"
                return 0
            fi

            # Requires root
            if [ "$EUID" -ne 0 ]; then
                echo -e "${RED}Installation requires root privileges.${NC}"
                echo -e "${YELLOW}Run: ${CYAN}sudo sf${YELLOW} then Tools & Web > Install SDK${NC}"
                return 1
            fi

            echo -e "${BLUE}Installing Flutter SDK to $flutter_install_dir...${NC}"
            echo ""

            # Migration: move existing per-user SDK if present
            local old_sdk="$HOME/.flutter-sdk"
            if [ -d "$old_sdk" ] && [ ! -d "$flutter_install_dir" ]; then
                echo -e "${YELLOW}Found existing SDK at $old_sdk${NC}"
                if ui_confirm "Migrate to $flutter_install_dir?"; then
                    mv "$old_sdk" "$flutter_install_dir"
                    chown -R root:root "$flutter_install_dir"
                    chmod -R a+rX "$flutter_install_dir"
                    echo -e "${GREEN}SDK migrated.${NC}"
                fi
            fi

            # Fresh install if not yet present
            if [ ! -d "$flutter_install_dir" ]; then
                git clone -b stable https://github.com/flutter/flutter.git "$flutter_install_dir"
            fi

            # Configure system-wide PATH
            echo "export PATH=\"$flutter_install_dir/bin:\$PATH\"" > "$flutter_profile"
            export PATH="$flutter_install_dir/bin:$PATH"

            if command -v flutter >/dev/null 2>&1; then
                # Disable telemetry
                flutter config --no-analytics >/dev/null 2>&1 || true
                dart --disable-analytics >/dev/null 2>&1 || true
                # Pre-cache web tools (main use case on server)
                echo -e "${BLUE}Running flutter precache --web...${NC}"
                flutter precache --web >/dev/null 2>&1 || true
                echo ""
                echo -e "${GREEN}Flutter installed successfully!${NC}"
                echo -e "  $(flutter --version 2>&1 | head -n1)"
                echo -e "  $(dart --version 2>&1)"
                echo ""
                echo -e "${BLUE}All users will have flutter/dart in PATH after next login.${NC}"
                echo -e "${BLUE}For current session: ${CYAN}source $flutter_profile${NC}"
            else
                echo -e "${RED}Flutter installation failed.${NC}"
                echo -e "${YELLOW}Manual install: git clone -b stable https://github.com/flutter/flutter.git $flutter_install_dir${NC}"
            fi
            ;;
        x|q)
            ui_return_back
            return 0
            ;;
        *)
            ;;
    esac
}

# -----------------------------------------------------------------------------
# validate_project_path - Validate project directory path for security
#
# Description:
#   Validates a project path to prevent security vulnerabilities:
#   - Path traversal attacks (.. sequences)
#   - Command injection (special characters)
#   - Access to unsafe directories
#   - Non-existent paths
#
# Arguments:
#   $1 - Path to validate
#
# Returns:
#   0 - Path is valid and safe
#   1 - Path is invalid or unsafe
#
# Security:
#   Blocks: .., ;, &, |, $, backticks
#   Allows only: /root/*, /home/*, /opt/*
#
# Example:
#   validate_project_path "/root/myapp" || exit 1
# -----------------------------------------------------------------------------
validate_project_path() {
    local path=$1

    # Must not be empty
    if [ -z "$path" ]; then
        error "Path cannot be empty"
        return 1
    fi

    # Must be absolute path
    if [[ "$path" != /* ]]; then
        error "Path must be absolute (start with /)"
        return 1
    fi

    # Must start with /root or be a known safe directory
    if [[ "$path" != "/root" ]] && [[ "$path" != /root/* ]] && \
       [[ "$path" != "/home" ]] && [[ "$path" != /home/* ]] && \
       [[ "$path" != "/opt" ]] && [[ "$path" != /opt/* ]]; then
        error "Path must be under /root, /home, or /opt for safety"
        return 1
    fi

    # Must not contain path traversal attempts
    if [[ "$path" == *..* ]]; then
        error "Path cannot contain '..' (path traversal blocked)"
        return 1
    fi

    # Must not contain suspicious characters
    if [[ "$path" =~ [\;\&\|\$\`] ]]; then
        error "Path contains invalid characters"
        return 1
    fi

    # ShipFlow convention: project paths are lowercase from creation time.
    # This prevents case-sensitive mismatches between folders, PM2 names, and aliases.
    if [ "$path" != "${path,,}" ]; then
        error "Path must be lowercase: $path"
        return 1
    fi

    # Must exist and be a directory
    if [ ! -d "$path" ]; then
        error "Path does not exist or is not a directory: $path"
        return 1
    fi

    return 0
}

# -----------------------------------------------------------------------------
# validate_env_name - Validate environment/project name
#
# Description:
#   Ensures environment names follow safe naming conventions.
#
# Arguments:
#   $1 - Environment name to validate
#
# Returns:
#   0 - Name is valid
#   1 - Name is invalid
#
# Rules:
#   - Only lowercase alphanumeric, dash, underscore, dot allowed
#   - Cannot start with dash or dot
#   - Cannot be empty
#
# Example:
#   validate_env_name "my-app" || exit 1
# -----------------------------------------------------------------------------
validate_env_name() {
    local name=$1

    if [ -z "$name" ]; then
        error "Environment name cannot be empty"
        return 1
    fi

    # Must contain only lowercase alphanumeric, dash, underscore, dot
    if [[ ! "$name" =~ ^[a-z0-9._-]+$ ]]; then
        error "Environment name can only contain lowercase letters, numbers, dash, underscore, dot"
        return 1
    fi

    # Must not start with dash or dot
    if [[ "$name" =~ ^[-.] ]]; then
        error "Environment name cannot start with dash or dot"
        return 1
    fi

    return 0
}

# -----------------------------------------------------------------------------
# validate_duckdns_subdomain - Validate a DuckDNS subdomain before DNS/Caddy use
#
# Arguments:
#   $1 - Subdomain without .duckdns.org
#
# Returns:
#   0 - Subdomain is valid
#   1 - Subdomain is invalid
# -----------------------------------------------------------------------------
validate_duckdns_subdomain() {
    local subdomain=$1

    if [ -z "$subdomain" ]; then
        error "DuckDNS subdomain cannot be empty"
        return 1
    fi

    if [[ ! "$subdomain" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then
        error "DuckDNS subdomain must be lowercase letters, numbers, or internal dashes only"
        return 1
    fi

    return 0
}

# -----------------------------------------------------------------------------
# validate_duckdns_token - Validate a DuckDNS token before persistence/use
#
# Arguments:
#   $1 - DuckDNS token
#
# Returns:
#   0 - Token shape is acceptable
#   1 - Token shape is invalid
# -----------------------------------------------------------------------------
validate_duckdns_token() {
    local token=$1

    if [ -z "$token" ]; then
        error "DuckDNS token cannot be empty"
        return 1
    fi

    if [[ ! "$token" =~ ^[A-Za-z0-9._-]{16,128}$ ]]; then
        error "DuckDNS token contains invalid characters or length"
        return 1
    fi

    return 0
}

# -----------------------------------------------------------------------------
# validate_public_ipv4 - Validate an IPv4 address used for DuckDNS updates
#
# Arguments:
#   $1 - IPv4 address
#
# Returns:
#   0 - Address is valid
#   1 - Address is invalid
# -----------------------------------------------------------------------------
validate_public_ipv4() {
    local ip=$1

    if [[ ! "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        error "Public IP must be an IPv4 address"
        return 1
    fi

    local IFS=.
    local octets=($ip)
    local octet
    for octet in "${octets[@]}"; do
        if [ "$octet" -gt 255 ]; then
            error "Public IP contains an invalid octet"
            return 1
        fi
    done

    return 0
}

# Helper functions (with logging)
success() {
    echo -e "${GREEN}✅${NC} $1"
    log INFO "SUCCESS: $1"
}

error() {
    echo -e "${RED}❌${NC} $1"
    log ERROR "$1"
}

info() {
    echo -e "${BLUE}ℹ️${NC} $1"
    log INFO "$1"
}

warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
    log WARNING "$1"
}

# ============================================================================
# PM2 DATA CACHING (Performance Optimization)
# ============================================================================

# Global cache variables
PM2_DATA_CACHE=""
PM2_DATA_CACHE_TIME=0

# -----------------------------------------------------------------------------
# get_pm2_data_cached - Fetch and cache all PM2 application data
#
# Description:
#   Retrieves all PM2 app data in a single call and caches the results.
#   Uses jq for JSON parsing (falls back to python3).
#   Cache is valid for SHIPFLOW_PM2_CACHE_TTL seconds (default: 5).
#
# Arguments:
#   None
#
# Returns:
#   0 - Success
#   1 - PM2 not installed or error
#
# Outputs:
#   name|status|port|cwd for each PM2 app (one per line)
#
# Cache Behavior:
#   - Returns cached data if age < TTL
#   - Fetches fresh data if cache expired
#   - Global variables: PM2_DATA_CACHE, PM2_DATA_CACHE_TIME
#
# Example:
#   get_pm2_data_cached
# -----------------------------------------------------------------------------
get_pm2_data_cached() {
    local current_time=$(date +%s)
    local cache_age=$((current_time - PM2_DATA_CACHE_TIME))

    # Return cached data if fresh
    if [ "$SHIPFLOW_PM2_CACHE_ENABLED" = "true" ] && [ $cache_age -lt $SHIPFLOW_PM2_CACHE_TTL ] && [ -n "$PM2_DATA_CACHE" ]; then
        log DEBUG "Using cached PM2 data (age: ${cache_age}s)"
        echo "$PM2_DATA_CACHE"
        return 0
    fi

    # Fetch fresh data
    log DEBUG "Fetching fresh PM2 data"
    if ! command -v pm2 >/dev/null 2>&1; then
        log WARNING "PM2 not installed"
        return 1
    fi

    # Get all PM2 data in one call: name|status|port|cwd
    # Use jq if available (faster), fallback to python3
    if [ "$SHIPFLOW_PREFER_JQ" = "true" ] && command -v jq >/dev/null 2>&1; then
        PM2_DATA_CACHE=$(pm2 jlist 2>/dev/null | jq -r '.[] | "\(.name)|\(.pm2_env.status // "unknown")|\(.pm2_env.env.PORT // "")|\(.pm2_env.pm_cwd // "")"' 2>/dev/null)
    elif command -v python3 >/dev/null 2>&1; then
        PM2_DATA_CACHE=$(pm2 jlist 2>/dev/null | python3 -c "
import sys, json
try:
    apps = json.load(sys.stdin)
    for app in apps:
        name = app.get('name', '')
        status = app.get('pm2_env', {}).get('status', 'unknown')
        port = app.get('pm2_env', {}).get('env', {}).get('PORT', '')
        cwd = app.get('pm2_env', {}).get('pm_cwd', '')
        print(f'{name}|{status}|{port}|{cwd}')
except Exception as e:
    import sys
    print(f'ERROR: {e}', file=sys.stderr)
" 2>/dev/null)
    else
        log ERROR "No JSON parser available (jq or python3 required)"
        return 1
    fi

    PM2_DATA_CACHE_TIME=$current_time
    echo "$PM2_DATA_CACHE"
}

# -----------------------------------------------------------------------------
# invalidate_pm2_cache - Clear PM2 data cache
#
# Description:
#   Invalidates the PM2 data cache to force a fresh fetch on next access.
#   Should be called after any PM2 state changes (start, stop, delete).
#
# Arguments:
#   None
#
# Returns:
#   0 - Always succeeds
#
# Example:
#   pm2 start app.js
#   invalidate_pm2_cache
# -----------------------------------------------------------------------------
invalidate_pm2_cache() {
    log DEBUG "Invalidating PM2 cache"
    PM2_DATA_CACHE=""
    PM2_DATA_CACHE_TIME=0
}

# -----------------------------------------------------------------------------
# get_pm2_app_data - Extract specific PM2 app data from cache
#
# Description:
#   Retrieves a specific field for a PM2 app from the cached data.
#
# Arguments:
#   $1 - App name
#   $2 - Field to retrieve: "status", "port", "cwd", or empty for all
#
# Returns:
#   0 - App found
#   1 - App not found or cache empty
#
# Outputs:
#   Requested field value(s)
#
# Example:
#   port=$(get_pm2_app_data "myapp" "port")
# -----------------------------------------------------------------------------
get_pm2_app_data() {
    local app_name=$1
    local field=$2  # status, port, or cwd

    local data=$(get_pm2_data_cached)
    if [ -z "$data" ]; then
        return 1
    fi

    # Parse cached data
    echo "$data" | while IFS='|' read -r name status port cwd; do
        if [ "$name" = "$app_name" ]; then
            case "$field" in
                status) echo "$status" ;;
                port) echo "$port" ;;
                cwd) echo "$cwd" ;;
                *) echo "$status|$port|$cwd" ;;
            esac
            return 0
        fi
    done
}

list_pm2_app_names() {
    if ! command -v pm2 >/dev/null 2>&1; then
        return 1
    fi

    if command -v jq >/dev/null 2>&1; then
        pm2 jlist 2>/dev/null | jq -r '.[].name // empty' 2>/dev/null
    else
        pm2 jlist 2>/dev/null | python3 -c "
import json
import sys
try:
    apps = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for app in apps:
    name = app.get('name')
    if name:
        print(name)
" 2>/dev/null
    fi
}

pm2_app_exists_by_name() {
    local app_name="$1"
    [ -z "$app_name" ] && return 1

    list_pm2_app_names | awk -v name="$app_name" '$0 == name {found=1} END {exit found ? 0 : 1}'
}

pm2_daemon_pid() {
    pgrep -u "$(id -u)" -f 'PM2 v[0-9.]+: God Daemon' 2>/dev/null | head -n 1
}

pm2_has_apps() {
    [ -n "$(list_pm2_app_names 2>/dev/null)" ]
}

pm2_has_running_apps() {
    get_pm2_data_cached 2>/dev/null | awk -F'|' '$2 == "online" || $2 == "launching" {found=1} END {exit found ? 0 : 1}'
}

stop_empty_pm2_daemon() {
    local pid
    pid=$(pm2_daemon_pid)

    if [ -z "$pid" ]; then
        echo -e "${GREEN}No PM2 daemon is running for this user.${NC}"
        return 0
    fi

    if pm2_has_running_apps; then
        echo -e "${YELLOW}PM2 apps are running; refusing to stop the PM2 daemon from this cleanup action.${NC}"
        return 1
    fi

    echo -e "${YELLOW}PM2 daemon is running with no registered apps.${NC}"
    if ! ui_confirm "Stop the empty PM2 daemon now?"; then
        echo -e "${BLUE}Skipped.${NC}"
        return 0
    fi

    pm2 kill >/dev/null 2>&1 || true
    invalidate_pm2_cache
    echo -e "${GREEN}Stopped empty PM2 daemon.${NC}"
}

get_pm2_status_by_name() {
    local app_name="$1"
    local status

    if [ -z "$app_name" ]; then
        echo "not-found"
        return 1
    fi

    status=$(get_pm2_app_data "$app_name" "status")
    if [ -n "$status" ]; then
        echo "$status"
        return 0
    fi

    echo "not-found"
    return 1
}

list_all_stop_targets() {
    {
        list_all_environments
        list_pm2_app_names
    } 2>/dev/null | sed '/^[[:space:]]*$/d' | sort -u
}

pm2_stop_app_by_name() {
    local app_name="$1"

    if [ -z "$app_name" ]; then
        error "PM2 app name is required"
        return 1
    fi

    if ! command -v pm2 >/dev/null 2>&1; then
        error "PM2 is not installed"
        return 1
    fi

    if pm2 stop "$app_name" 2>/dev/null; then
        pm2 save --force >/dev/null 2>&1
        invalidate_pm2_cache
        success "Projet $app_name arrêté"
        log INFO "Stopped PM2 app: $app_name"
        return 0
    fi

    if pm2_app_exists_by_name "$app_name"; then
        info "Projet $app_name n'est pas en cours d'exécution"
        pm2 save --force >/dev/null 2>&1
        invalidate_pm2_cache
        log DEBUG "PM2 app $app_name exists but was not running"
        return 0
    fi

    info "Projet $app_name n'est pas en cours d'exécution"
    invalidate_pm2_cache
    log DEBUG "PM2 app $app_name does not exist; stop treated as idempotent"
    return 0
}

# ============================================================================
# PORT MANAGEMENT FUNCTIONS
# ============================================================================

# -----------------------------------------------------------------------------
# is_port_in_use - Check if a TCP port is currently in use
#
# Description:
#   Uses ss command to check if a port is listening.
#
# Arguments:
#   $1 - Port number to check
#
# Returns:
#   0 - Port is in use
#   1 - Port is available
#
# Example:
#   if is_port_in_use 3000; then
#       echo "Port 3000 is busy"
#   fi
# -----------------------------------------------------------------------------
is_port_in_use() {
    local port=$1
    ss -ltn 2>/dev/null | awk '{print $4}' | grep -E "[:.]${port}$" >/dev/null 2>&1
}

# Get all ports used by PM2 apps (even stopped ones) - OPTIMIZED
get_all_pm2_ports() {
    if ! command -v pm2 >/dev/null 2>&1; then
        return 0
    fi

    local data=$(get_pm2_data_cached)
    if [ -z "$data" ]; then
        return 0
    fi

    # Extract ports from cached data
    echo "$data" | awk -F'|' '{if ($3 != "") print $3}' | tr '\n' ' '
}

# -----------------------------------------------------------------------------
# find_available_port - Find next available port in range
#
# Description:
#   Searches for an available port starting from base_port.
#   Checks both active ports (via ss) and PM2-assigned ports.
#
# Arguments:
#   $1 - Base port to start search (default: SHIPFLOW_PORT_RANGE_START)
#
# Returns:
#   0 - Available port found
#   1 - No available port in range
#
# Outputs:
#   Available port number to stdout
#
# Notes:
#   - Searches up to SHIPFLOW_PORT_MAX_ATTEMPTS ports
#   - Avoids race conditions by checking both active and reserved ports
#
# Example:
#   port=$(find_available_port 3000)
# -----------------------------------------------------------------------------
find_available_port() {
    local base_port=${1:-$SHIPFLOW_PORT_RANGE_START}
    local max_range=$SHIPFLOW_PORT_MAX_ATTEMPTS
    local port=$base_port

    # Get all ports already assigned in PM2 (atomic read)
    local pm2_ports=$(get_all_pm2_ports)

    # Search for available port
    while [ $((port - base_port)) -lt $max_range ]; do
        # Double-check: not in use AND not already assigned in PM2
        # This reduces race condition window
        if ! is_port_in_use $port && ! echo "$pm2_ports" | grep -q "\<$port\>"; then
            # Final verification before returning
            if ! is_port_in_use $port; then
                echo $port
                log DEBUG "Found available port: $port"
                return 0
            fi
        fi
        port=$((port + 1))
    done

    error "Impossible de trouver un port disponible après $max_range tentatives"
    log ERROR "Port exhaustion: no ports available in range $base_port-$((base_port + max_range))"
    return 1
}

# Get project status from PM2 - OPTIMIZED
get_pm2_status() {
    local identifier=$1
    local project_dir=$(resolve_project_path "$identifier")

    if [ -z "$project_dir" ]; then
        echo "not-found"
        return 1
    fi

    local env_name=$(basename "$project_dir") # Use basename as the PM2 app name

    if ! command -v pm2 >/dev/null 2>&1; then
        echo "pm2-not-installed"
        return 1
    fi

    # Use cached data
    local status=$(get_pm2_app_data "$env_name" "status")

    if [ -n "$status" ]; then
        echo "$status"
        return 0
    else
        echo "not_found"
        return 0
    fi
}

# Get project directory path


# Get port from PM2 env vars for a project - OPTIMIZED
get_port_from_pm2() {
    local identifier=$1
    local project_dir=$(resolve_project_path "$identifier")

    if [ -z "$project_dir" ]; then
        return 1
    fi

    local env_name=$(basename "$project_dir") # Use basename as the PM2 app name

    if ! command -v pm2 >/dev/null 2>&1; then
        return 1
    fi

    # Use cached data
    local port=$(get_pm2_app_data "$env_name" "port")

    if [ -n "$port" ]; then
        echo "$port"
        return 0
    fi

    return 1
}


# -----------------------------------------------------------------------------
# resolve_project_path - Resolve project directory from identifier
#
# Description:
#   Converts an environment name or path to an absolute project directory.
#   Searches for .flox directory to confirm valid project.
#
# Arguments:
#   $1 - Environment name or absolute path
#
# Returns:
#   0 - Project found
#   1 - Project not found
#
# Outputs:
#   Absolute path to project directory
#
# Search Strategy:
#   1. If absolute path with .flox, return as-is
#   2. Search PROJECTS_DIR for matching name with .flox
#
# Example:
#   path=$(resolve_project_path "myapp")
#   path=$(resolve_project_path "/root/myapp")
# -----------------------------------------------------------------------------
resolve_project_path() {
    local identifier=$1

    # Case 1: Identifier is already an absolute path
    # Accept paths with OR without .flox — env_start handles Flox initialization
    if [[ "$identifier" == /* && -d "$identifier" ]]; then
        echo "$identifier"
        return 0
    fi

    # Case 2: Identifier is an environment name, search within PROJECTS_DIR
    local found_path
    found_path=$(find "$PROJECTS_DIR" -maxdepth 4 \
        \( -name "node_modules" -o -name ".git" -o -name "venv" -o -name ".venv" \
           -o -name "__pycache__" -o -name "target" -o -name ".next" -o -name ".nuxt" \
           -o -name "dist" -o -name ".cache" -o -name ".pnpm" -o -name ".yarn" \) -prune \
        -o -type d -name "$identifier" -print 2>/dev/null | while read -r project_dir; do
        if [ -d "$project_dir/.flox" ]; then
            echo "$project_dir"
            exit 0
        fi
    done)

    if [ -n "$found_path" ]; then
        echo "$found_path"
        return 0
    fi
    
    return 1 # Project not found
}

# List all environments (projects with Flox env)
list_all_environments() {
    if [ -d "$PROJECTS_DIR" ]; then
        find "$PROJECTS_DIR" -maxdepth 4 \
            \( -name "node_modules" -o -name ".git" -o -name "venv" -o -name ".venv" \
               -o -name "__pycache__" -o -name "target" -o -name ".next" -o -name ".nuxt" \
               -o -name "dist" -o -name ".cache" -o -name ".pnpm" -o -name ".yarn" \) -prune \
            -o -type d -name ".flox" -print 2>/dev/null | while read -r flox_dir; do
            # Extract the project name from the path, e.g., /root/my-robots/chatbot/.flox -> chatbot
            echo "$(basename "$(dirname "$flox_dir")")"
        done | grep -v "^\.$" | sort
    fi
}

# List all environment identifiers (for menu selection)
list_all_environment_identifiers() {
    list_all_environments
    # Add one level of direct project folders that contain a Flox environment but
    # might not be returned by the broader environment scan above.
    if [ -d "$PROJECTS_DIR" ]; then
        find "$PROJECTS_DIR" -maxdepth 3 -type d -name ".flox" -print 2>/dev/null | while read -r flox_dir; do
            dirname "$flox_dir"
        done | sort -u
    fi
}


# Cleanup orphan projects
cleanup_orphan_projects() {
    echo -e "${YELLOW}🔍 Recherche de projets orphelins...${NC}"
    
    if [ -d "$PROJECTS_DIR" ]; then
        find "$PROJECTS_DIR" -maxdepth 1 -type d ! -path "$PROJECTS_DIR" | while read -r dir; do
            if [ ! -d "$dir/.flox" ]; then
                project_name=$(basename "$dir")
                echo -e "${YELLOW}🗑️  Projet sans Flox détecté: $project_name${NC}"
                echo -e "${YELLOW}   (pas d'environnement Flox)${NC}"
            fi
        done
    fi
    
    echo -e "${GREEN}✅ Nettoyage terminé${NC}"
}

# ============================================================================
# SESSION IDENTITY FUNCTIONS
# ============================================================================

# Word list for human-readable session codes
SESSION_WORDS=(
    "CORAL" "WAVE" "STORM" "TIGER" "EMBER" "FROST" "SOLAR" "LUNAR" "DELTA" "ALPHA"
    "CYBER" "NEXUS" "PULSE" "DRIFT" "SPARK" "BLAZE" "CLOUD" "SWIFT" "GHOST" "PRIME"
    "OMEGA" "SIGMA" "AZURE" "FLAME" "SHADE" "LIGHT" "STONE" "RIVER" "FORGE" "STEEL"
    "NOVA" "QUEST" "PIXEL" "VORTEX" "COMET" "ORBIT" "PRISM" "QUARK" "SONIC" "TURBO"
    "BOLT" "FLASH" "FROST" "GLEAM" "HAZE" "JADE" "KARMA" "LOTUS" "MAGIC" "NEON"
)

# -----------------------------------------------------------------------------
# init_session - Initialize session identity for this server/user
#
# Description:
#   Creates the session directory and generates a unique session ID if not
#   already present. The session ID is based on USER, HOSTNAME, and creation
#   timestamp, making it unique and persistent.
#
# Arguments:
#   None
#
# Returns:
#   0 - Success
#   1 - Error creating directory
#
# Side Effects:
#   - Creates ~/.shipflow/session/ directory
#   - Creates session_id file if not present
#
# Example:
#   init_session
# -----------------------------------------------------------------------------
init_session() {
    if [ "$SHIPFLOW_SESSION_ENABLED" != "true" ]; then
        return 0
    fi

    # Create session directory
    if ! mkdir -p "$SHIPFLOW_SESSION_DIR" 2>/dev/null; then
        log ERROR "Failed to create session directory: $SHIPFLOW_SESSION_DIR"
        return 1
    fi

    local session_file="$SHIPFLOW_SESSION_DIR/session_id"

    # Generate session ID if not present
    if [ ! -f "$session_file" ]; then
        local timestamp=$(date +%s)
        local user="${USER:-unknown}"
        local host="${HOSTNAME:-$(hostname 2>/dev/null || echo 'unknown')}"
        local random_part=$(head -c 16 /dev/urandom 2>/dev/null | od -An -tx1 | tr -d ' \n' || echo "$RANDOM$RANDOM")

        # Create unique session ID
        local session_id="${user}@${host}:${timestamp}:${random_part}"

        echo "$session_id" > "$session_file"
        log INFO "Created new session ID for $user@$host"
    fi

    return 0
}

# -----------------------------------------------------------------------------
# get_session_id - Retrieve the current session ID
#
# Description:
#   Returns the session ID, initializing the session if needed.
#
# Arguments:
#   None
#
# Returns:
#   0 - Success
#   1 - Session disabled or error
#
# Outputs:
#   Session ID string to stdout
#
# Example:
#   session_id=$(get_session_id)
# -----------------------------------------------------------------------------
get_session_id() {
    if [ "$SHIPFLOW_SESSION_ENABLED" != "true" ]; then
        return 1
    fi

    local session_file="$SHIPFLOW_SESSION_DIR/session_id"

    # Initialize if needed
    if [ ! -f "$session_file" ]; then
        init_session || return 1
    fi

    cat "$session_file" 2>/dev/null
}

# -----------------------------------------------------------------------------
# generate_hash_art - Generate deterministic ASCII art from session ID
#
# Description:
#   Creates a unique 5x20 ASCII pattern from a session ID using SHA256 hash.
#   The pattern is deterministic - same session ID always produces same art.
#
# Arguments:
#   $1 - Session ID string
#
# Returns:
#   0 - Success
#
# Outputs:
#   5-line ASCII art pattern to stdout
#
# Example:
#   generate_hash_art "user@host:123456:abc"
# -----------------------------------------------------------------------------
generate_hash_art() {
    local session_id="$1"

    if [ -z "$session_id" ]; then
        return 1
    fi

    # Generate SHA256 hash
    local hash
    if command -v sha256sum >/dev/null 2>&1; then
        hash=$(echo -n "$session_id" | sha256sum | cut -d' ' -f1)
    elif command -v shasum >/dev/null 2>&1; then
        hash=$(echo -n "$session_id" | shasum -a 256 | cut -d' ' -f1)
    else
        # Fallback: use md5 if available
        if command -v md5sum >/dev/null 2>&1; then
            hash=$(echo -n "$session_id" | md5sum | cut -d' ' -f1)
            hash="${hash}${hash}"  # Double it for length
        else
            log ERROR "No hash utility available (sha256sum, shasum, or md5sum)"
            return 1
        fi
    fi

    # Characters for the art (from sparse to dense)
    local chars=("·" "░" "▒" "▓" "█")
    local width=20
    local height=5
    local art=""

    for ((row=0; row<height; row++)); do
        local line=""
        for ((col=0; col<width; col++)); do
            # Extract 2 characters from hash based on position
            local pos=$(( (row * width + col) * 2 % 64 ))
            local hex_val="${hash:$pos:2}"

            # Convert hex to decimal and map to character index (0-4)
            local dec_val=$((16#$hex_val % 5))
            line+="${chars[$dec_val]}"
        done

        if [ $row -lt $((height - 1)) ]; then
            art+="$line\n"
        else
            art+="$line"
        fi
    done

    echo -e "$art"
}

# -----------------------------------------------------------------------------
# get_session_code - Generate human-readable session code
#
# Description:
#   Creates a memorable code in format WORD-WORD-XX from session ID.
#   Deterministic - same session ID always produces same code.
#
# Arguments:
#   $1 - Session ID string
#
# Returns:
#   0 - Success
#
# Outputs:
#   Session code string (e.g., "CORAL-WAVE-7F") to stdout
#
# Example:
#   code=$(get_session_code "user@host:123456:abc")
# -----------------------------------------------------------------------------
get_session_code() {
    local session_id="$1"

    if [ -z "$session_id" ]; then
        return 1
    fi

    # Generate hash
    local hash
    if command -v sha256sum >/dev/null 2>&1; then
        hash=$(echo -n "$session_id" | sha256sum | cut -d' ' -f1)
    elif command -v shasum >/dev/null 2>&1; then
        hash=$(echo -n "$session_id" | shasum -a 256 | cut -d' ' -f1)
    elif command -v md5sum >/dev/null 2>&1; then
        hash=$(echo -n "$session_id" | md5sum | cut -d' ' -f1)
    else
        echo "UNKNOWN"
        return 1
    fi

    # Get word indices from hash
    local word_count=${#SESSION_WORDS[@]}
    local idx1=$((16#${hash:0:4} % word_count))
    local idx2=$((16#${hash:4:4} % word_count))
    local hex_suffix="${hash:8:2}"

    # Build code
    local word1="${SESSION_WORDS[$idx1]}"
    local word2="${SESSION_WORDS[$idx2]}"

    echo "${word1}-${word2}-${hex_suffix^^}"
}

center_session_banner_text() {
    local text="$1"
    local width="${2:-50}"
    local text_len=${#text}

    if [ "$text_len" -ge "$width" ]; then
        printf "%s" "$text"
        return
    fi

    local pad=$(( (width - text_len) / 2 ))
    printf "%*s%s" "$pad" "" "$text"
}

# -----------------------------------------------------------------------------
# display_session_banner - Display formatted session identity banner
#
# Description:
#   Shows the hash art and session code in a formatted box.
#   Used by server-side menus to display identity.
#
# Arguments:
#   None
#
# Returns:
#   0 - Success
#   1 - Session disabled
#
# Outputs:
#   Formatted banner to stdout
#
# Example:
#   display_session_banner
# -----------------------------------------------------------------------------
display_session_banner() {
    if [ "$SHIPFLOW_SESSION_ENABLED" != "true" ]; then
        return 1
    fi

    local session_id=$(get_session_id)
    if [ -z "$session_id" ]; then
        return 1
    fi

    local hash_art=$(generate_hash_art "$session_id")
    local session_code=$(get_session_code "$session_id")
    local user="${USER:-unknown}"
    local host="${HOSTNAME:-$(hostname 2>/dev/null || echo 'unknown')}"

    echo -e "                 ${MAGENTA}Session Identity${NC}"
    echo -e "${CYAN}──────────────────────────────────────────────────${NC}"

    # Display hash art (centered visually)
    while IFS= read -r line; do
        echo -e "              ${BLUE}$line${NC}"
    done <<< "$hash_art"

    echo -e "${GREEN}$(center_session_banner_text "$user@$host")${NC}"
    echo -e "${YELLOW}$(center_session_banner_text "$session_code")${NC}"
    echo -e "${CYAN}──────────────────────────────────────────────────${NC}"
}

session_banner_header_block() {
    if [ "$SHIPFLOW_SESSION_ENABLED" != "true" ]; then
        return 1
    fi

    local session_id
    session_id=$(get_session_id)
    if [ -z "$session_id" ]; then
        return 1
    fi

    local hash_art
    local session_code
    local user
    local host
    hash_art=$(generate_hash_art "$session_id")
    session_code=$(get_session_code "$session_id")
    user="${USER:-unknown}"
    host="${HOSTNAME:-$(hostname 2>/dev/null || echo 'unknown')}"

    printf "%b%s%b\n" $'\033[38;5;141m' "$(center_session_banner_text "Session Identity" 46)" "$NC"
    printf "%b══════════════════════════════════════════════%b\n" "$CYAN" "$NC"
    while IFS= read -r line; do
        printf "              %b%s%b\n" "$BLUE" "$line" "$NC"
    done <<< "$hash_art"
    printf "%b%s%b\n" "$GREEN" "$(center_session_banner_text "$user@$host" 46)" "$NC"
    printf "%b%s%b\n" $'\033[38;5;117m' "$(center_session_banner_text "$session_code" 46)" "$NC"
    printf "%b──────────────────────────────────────────────%b" "$YELLOW" "$NC"
}

# -----------------------------------------------------------------------------
# reset_session - Regenerate session identity
#
# Description:
#   Deletes the existing session ID and creates a new one.
#   Use this if you want a fresh identity or if the session was compromised.
#
# Arguments:
#   None
#
# Returns:
#   0 - Success
#   1 - Error
#
# Side Effects:
#   - Deletes existing session_id file
#   - Creates new session_id with fresh timestamp
#
# Example:
#   reset_session
# -----------------------------------------------------------------------------
reset_session() {
    if [ "$SHIPFLOW_SESSION_ENABLED" != "true" ]; then
        echo "Session identity is disabled"
        return 1
    fi

    local session_file="$SHIPFLOW_SESSION_DIR/session_id"

    # Remove existing session
    if [ -f "$session_file" ]; then
        rm -f "$session_file"
        log INFO "Removed existing session ID"
    fi

    # Create new session
    init_session

    local new_id=$(get_session_id)
    local new_code=$(get_session_code "$new_id")

    echo -e "${GREEN}✅ Session identity reset${NC}"
    echo -e "${YELLOW}New session code: ${CYAN}$new_code${NC}"
    log INFO "Session identity reset - new code: $new_code"

    return 0
}

# -----------------------------------------------------------------------------
# get_session_info - Get detailed session information
#
# Description:
#   Returns detailed information about the current session including
#   creation time and user/host info.
#
# Arguments:
#   None
#
# Returns:
#   0 - Success
#
# Outputs:
#   Formatted session info to stdout
#
# Example:
#   get_session_info
# -----------------------------------------------------------------------------
get_session_info() {
    if [ "$SHIPFLOW_SESSION_ENABLED" != "true" ]; then
        echo "Session identity is disabled"
        return 1
    fi

    local session_id=$(get_session_id)
    if [ -z "$session_id" ]; then
        echo "No session found"
        return 1
    fi

    # Parse session ID components
    local user_host=$(echo "$session_id" | cut -d: -f1)
    local timestamp=$(echo "$session_id" | cut -d: -f2)
    local session_code=$(get_session_code "$session_id")

    # Convert timestamp to readable date
    local created_date
    if date -d "@$timestamp" &>/dev/null; then
        created_date=$(date -d "@$timestamp" '+%Y-%m-%d %H:%M:%S')
    else
        created_date=$(date -r "$timestamp" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "Unknown")
    fi

    echo -e "${CYAN}Session Information:${NC}"
    echo -e "  ${BLUE}User@Host:${NC}    $user_host"
    echo -e "  ${BLUE}Session Code:${NC} ${YELLOW}$session_code${NC}"
    echo -e "  ${BLUE}Created:${NC}      $created_date"
    echo -e "  ${BLUE}File:${NC}         $SHIPFLOW_SESSION_DIR/session_id"
}

# -----------------------------------------------------------------------------
# get_session_info_for_ssh - Get session info formatted for SSH retrieval
#
# Description:
#   Returns session information in a parseable format for SSH.
#   Used by client scripts to retrieve server session identity.
#
# Arguments:
#   None
#
# Returns:
#   0 - Success
#
# Outputs:
#   SESSION_ID, HASH_ART, and SESSION_CODE separated by markers
#
# Example:
#   ssh server "source lib.sh && get_session_info_for_ssh"
# -----------------------------------------------------------------------------
get_session_info_for_ssh() {
    if [ "$SHIPFLOW_SESSION_ENABLED" != "true" ]; then
        echo "SESSION_DISABLED"
        return 1
    fi

    local session_id=$(get_session_id)
    if [ -z "$session_id" ]; then
        echo "SESSION_ERROR"
        return 1
    fi

    local hash_art=$(generate_hash_art "$session_id")
    local session_code=$(get_session_code "$session_id")
    local user="${USER:-unknown}"
    local host="${HOSTNAME:-$(hostname 2>/dev/null || echo 'unknown')}"

    # Output in parseable format
    echo "---SESSION_START---"
    echo "USER:$user"
    echo "HOST:$host"
    echo "CODE:$session_code"
    echo "---HASH_ART_START---"
    echo "$hash_art"
    echo "---HASH_ART_END---"
    echo "---SESSION_END---"
}

# GitHub repo operations
list_github_repos() {
    if ! command -v gh >/dev/null 2>&1; then
        error "GitHub CLI (gh) n'est pas installé"
        info "Installation: apt install gh"
        return 1
    fi

    if ! gh auth status >/dev/null 2>&1; then
        error "Non authentifié sur GitHub"
        info "Authentification: gh auth login"
        return 1
    fi

    local all_repos
    all_repos=$(gh repo list --limit "$SHIPFLOW_GITHUB_REPO_LIMIT" --json name,description --jq '.[] | "\(.name): \(.description)"' 2>/dev/null)

    if [ -z "$all_repos" ]; then
        return 0
    fi

    # Filter out repos already deployed (directory exists in PROJECTS_DIR)
    while IFS= read -r line; do
        local repo_name="${line%%:*}"
        local repo_name_lower="${repo_name,,}"
        if [ ! -d "$PROJECTS_DIR/$repo_name_lower" ] && [ ! -d "$PROJECTS_DIR/$repo_name" ]; then
            echo "$line"
        fi
    done <<< "$all_repos"
}

# Validate GitHub repo name
validate_repo_name() {
    local repo=$1

    if [ -z "$repo" ]; then
        error "Repository name cannot be empty"
        return 1
    fi

    # GitHub repo names: alphanumeric, dash, underscore, dot
    if [[ ! "$repo" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        error "Invalid repository name: $repo"
        return 1
    fi

    return 0
}

get_github_username() {
    gh api user --jq .login 2>/dev/null
}

github_auth_is_logged_in() {
    command -v gh >/dev/null 2>&1 || return 1
    gh auth status -h github.com >/dev/null 2>&1
}

action_github_auth() {
    ui_screen_header "GitHub Login"

    if ! command -v gh >/dev/null 2>&1; then
        echo -e "${RED}❌ GitHub CLI (gh) is not installed.${NC}"
        echo -e "${YELLOW}Run the ShipFlow installer or install GitHub CLI, then retry.${NC}"
        return 1
    fi

    echo -e "${BLUE}GitHub CLI:${NC} ${GREEN}$(gh --version | head -n1)${NC}"
    echo ""

    if github_auth_is_logged_in; then
        local github_user
        github_user=$(get_github_username)
        echo -e "${GREEN}✓ GitHub authenticated${NC}"
        [ -n "$github_user" ] && echo -e "  ${BLUE}Account:${NC} ${GREEN}$github_user${NC}"
        echo ""
        echo -e "${BLUE}Current gh auth status:${NC}"
        gh auth status -h github.com || true
        echo ""
        echo -e "${YELLOW}ShipFlow uses this auth for Deploy from GitHub and repo listing.${NC}"
        return 0
    fi

    echo -e "${YELLOW}GitHub is not authenticated for this server user.${NC}"
    echo -e "${BLUE}ShipFlow will use the official GitHub CLI login flow.${NC}"
    echo -e "${YELLOW}Tokens stay in gh's credential storage; ShipFlow does not read or store them.${NC}"
    echo ""
    echo -e "${BLUE}Recommended command:${NC}"
    echo -e "  ${GREEN}gh auth login --hostname github.com --git-protocol ssh --scopes repo,read:org${NC}"
    echo ""

    if ! ui_confirm "Start GitHub login now?"; then
        echo -e "${BLUE}Cancelled${NC}"
        return 0
    fi

    if [ "${SHIPFLOW_GITHUB_AUTH_DRY_RUN:-0}" = "1" ]; then
        echo "gh auth login --hostname github.com --git-protocol ssh --scopes repo,read:org"
        return 0
    fi

    gh auth login --hostname github.com --git-protocol ssh --scopes repo,read:org
    local rc=$?
    echo ""
    if [ "$rc" -eq 0 ] && github_auth_is_logged_in; then
        echo -e "${GREEN}✓ GitHub login complete${NC}"
        gh auth setup-git >/dev/null 2>&1 || true
    else
        echo -e "${RED}❌ GitHub login did not complete.${NC}"
        echo -e "${YELLOW}You can retry from this menu or run the command manually.${NC}"
        return "${rc:-1}"
    fi
}

# Detect whether a pubspec project is Flutter or plain Dart
detect_pubspec_kind() {
    local project_dir=$1

    cd "$project_dir" || return 1

    if [ ! -f "pubspec.yaml" ]; then
        return 1
    fi

    if grep -Eq '^[[:space:]]*flutter:' "pubspec.yaml"; then
        echo "flutter"
    else
        echo "dart"
    fi
}

# Detect a likely Dart entrypoint for server-style apps
detect_dart_entrypoint() {
    local project_dir=$1

    cd "$project_dir" || return 1

    if [ -f "bin/server.dart" ]; then
        echo "bin/server.dart"
    elif [ -f "bin/main.dart" ]; then
        echo "bin/main.dart"
    elif [ -f "main.dart" ]; then
        echo "main.dart"
    elif [ -f "bin/${project_dir##*/}.dart" ]; then
        echo "bin/${project_dir##*/}.dart"
    fi
}

# Detect project type and return package manager info
detect_project_type() {
    local project_dir=$1
    local pubspec_kind=""
    
    cd "$project_dir" || return 1
    
    if [ -f "package-lock.json" ]; then
        echo "nodejs:npm"
    elif [ -f "pnpm-lock.yaml" ]; then
        echo "nodejs:pnpm"
    elif [ -f "yarn.lock" ]; then
        echo "nodejs:yarn"
    elif [ -f "package.json" ]; then
        echo "nodejs:npm"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        echo "python:pip"
    elif [ -f "Cargo.toml" ]; then
        echo "rust:cargo"
    elif [ -f "go.mod" ]; then
        echo "go:go"
    elif [ -f "pubspec.yaml" ]; then
        pubspec_kind=$(detect_pubspec_kind "$project_dir")
        if [ "$pubspec_kind" = "dart" ]; then
            echo "dart:dart"
        else
            echo "flutter:flutter"
        fi
    else
        echo "generic:none"
    fi
}

validate_flox_runtime_package_token() {
    local token=$1

    if [ -z "$token" ]; then
        return 1
    fi

    if [[ ! "$token" =~ ^[A-Za-z0-9][A-Za-z0-9._+-]*(@[A-Za-z0-9][A-Za-z0-9._+-]*)?$ ]]; then
        return 1
    fi

    if [[ "$token" == -* ]]; then
        return 1
    fi

    if [[ "$token" == *"@"* ]]; then
        local version_part="${token#*@}"
        if [[ "$version_part" == -* ]] || [ -z "$version_part" ]; then
            return 1
        fi
    fi

    return 0
}

ensure_flox_runtime_packages() {
    local project_dir=$1
    local lang=$2
    local pm=$3
    local package_var_name=""
    local package_spec=""
    local runtime_label=""
    local runtime_check_cmd=""
    local -a runtime_packages=()
    local token=""

    case "$lang" in
        dart)
            package_var_name="SHIPFLOW_FLOX_DART_PACKAGES"
            package_spec="${SHIPFLOW_FLOX_DART_PACKAGES:-}"
            runtime_label="Dart"
            runtime_check_cmd="dart --version"
            ;;
        flutter)
            package_var_name="SHIPFLOW_FLOX_FLUTTER_PACKAGES"
            package_spec="${SHIPFLOW_FLOX_FLUTTER_PACKAGES:-}"
            runtime_label="Flutter"
            runtime_check_cmd="flutter --version"
            ;;
        *)
            return 0
            ;;
    esac

    read -r -a runtime_packages <<< "$package_spec"
    if [ ${#runtime_packages[@]} -eq 0 ]; then
        error "Aucun paquet Flox configuré pour le runtime $runtime_label"
        info "Projet: $project_dir"
        info "Type détecté: $lang ($pm)"
        info "Variable attendue: $package_var_name"
        return 1
    fi

    for token in "${runtime_packages[@]}"; do
        if ! validate_flox_runtime_package_token "$token"; then
            error "Valeur invalide pour $package_var_name: $token"
            info "Projet: $project_dir"
            info "Type détecté: $lang ($pm)"
            info "Format accepté: package ou package@version (ex: flutter@3.41.5-sdk-links)"
            info "Refusés: chemins, flake installables, tokens commençant par '-', quotes et caractères shell"
            return 1
        fi
    done

    if (cd "$project_dir" && flox activate -- bash -lc "$runtime_check_cmd" >/dev/null 2>&1); then
        echo -e "${GREEN}✅ Runtime $runtime_label déjà disponible dans Flox${NC}"
        return 0
    fi

    local package_string="${runtime_packages[*]}"
    echo -e "${BLUE}📦 Projet $runtime_label détecté — provisioning Flox (${package_string})...${NC}"

    if ! flox install -d "$project_dir" "${runtime_packages[@]}"; then
        error "Échec du provisioning runtime Flox"
        info "Projet: $project_dir"
        info "Type détecté: $lang ($pm)"
        info "Paquet(s): $package_string"
        info "Retry: flox install -d \"$project_dir\" $package_string"
        info "Override: export $package_var_name='<package>'"
        return 1
    fi

    if ! (cd "$project_dir" && flox activate -- bash -lc "$runtime_check_cmd" >/dev/null 2>&1); then
        error "Le runtime $runtime_label n'est pas disponible après installation Flox"
        info "Projet: $project_dir"
        info "Type détecté: $lang ($pm)"
        info "Paquet(s): $package_string"
        info "Vérification manuelle: (cd \"$project_dir\" && flox activate -- $runtime_check_cmd)"
        info "Override: export $package_var_name='<package>'"
        return 1
    fi

    echo -e "${GREEN}✅ Runtime $runtime_label prêt dans Flox${NC}"
    return 0
}

python_runtime_command() {
    local project_dir=$1

    cd "$project_dir" || return 1

    if [ -d ".shipflow-pydeps" ]; then
        echo "PYTHONPATH=./.shipflow-pydeps python3"
    elif [ -x ".venv/bin/python" ] && ./.venv/bin/python -m pip --version >/dev/null 2>&1; then
        echo "./.venv/bin/python"
    elif [ -x "venv/bin/python" ] && ./venv/bin/python -m pip --version >/dev/null 2>&1; then
        echo "./venv/bin/python"
    else
        echo "python3"
    fi
}

# Create or init Flox environment for project
init_flox_env() {
    local project_dir=$1
    local project_name=$2

    log INFO "Initializing Flox environment: $project_name at $project_dir"

    # Check if flox is installed
    if ! command -v flox >/dev/null 2>&1; then
        error "Flox is not installed"
        info "Install with: curl -fsSL https://flox.dev/install | bash"
        return 1
    fi

    cd "$project_dir" || return 1

    # Detect project type
    local project_type
    project_type=$(detect_project_type "$project_dir")
    local lang
    lang=$(echo "$project_type" | cut -d: -f1)
    local pm
    pm=$(echo "$project_type" | cut -d: -f2)

    if [ -d ".flox" ]; then
        if [ "$lang" = "dart" ] || [ "$lang" = "flutter" ]; then
            echo -e "${BLUE}🔄 Environnement Flox existant — vérification runtime $lang...${NC}"
            ensure_flox_runtime_packages "$project_dir" "$lang" "$pm" || return 1
        else
            echo -e "${GREEN}✅ Environnement Flox existe déjà${NC}"
        fi
        log DEBUG "Flox environment already exists for $project_name ($lang)"
        return 0
    fi

    echo -e "${BLUE}🔧 Création de l'environnement Flox...${NC}"

    echo -e "${BLUE}📦 Type détecté: $lang ($pm)${NC}"

    # Init flox environment
    if ! flox init -d "$project_dir" 2>/dev/null; then
        error "Échec de l'initialisation Flox"
        return 1
    fi

    # Install packages based on project type
    case "$lang" in
        nodejs)
            echo -e "${BLUE}📦 Installation de Node.js...${NC}"
            flox install nodejs 2>&1 | tail -1
            # Install package manager if needed
            if [ "$pm" = "pnpm" ]; then
                echo -e "${BLUE}📦 Installation de pnpm...${NC}"
                flox install pnpm 2>&1 | tail -1
            elif [ "$pm" = "yarn" ]; then
                echo -e "${BLUE}📦 Installation de yarn...${NC}"
                flox install yarn 2>&1 | tail -1
            fi
            ;;
        python)
            echo -e "${BLUE}🐍 Installation de Python et pip...${NC}"
            if ! flox install $SHIPFLOW_FLOX_PYTHON_PACKAGES 2>&1 | tail -1; then
                warning "Impossible d'installer les paquets Python Flox configurés"
            fi
            ;;
        rust)
            echo -e "${BLUE}🦀 Installation de Rust...${NC}"
            flox install rustc cargo
            ;;
        go)
            echo -e "${BLUE}🐹 Installation de Go...${NC}"
            flox install go
            ;;
        dart)
            ensure_flox_runtime_packages "$project_dir" "$lang" "$pm" || return 1
            ;;
        flutter)
            ensure_flox_runtime_packages "$project_dir" "$lang" "$pm" || return 1
            ;;
        generic)
            echo -e "${YELLOW}📄 Projet générique - environnement Flox de base${NC}"
            ;;
    esac
    
    # Install project dependencies if needed
    if [ "$lang" = "nodejs" ]; then
        echo -e "${BLUE}📦 Installation des dépendances du projet...${NC}"
        cd "$project_dir"
        if [ "$pm" = "pnpm" ] && [ -f "pnpm-lock.yaml" ]; then
            flox activate -- pnpm install 2>&1 | grep -v "Progress:" || true
        elif [ "$pm" = "yarn" ] && [ -f "yarn.lock" ]; then
            flox activate -- yarn install 2>&1 | grep -v "Progress:" || true
        elif [ -f "package.json" ]; then
            local npm_output
            npm_output=$(flox activate -- npm install 2>&1)
            if echo "$npm_output" | grep -q "ERESOLVE"; then
                echo -e "${YELLOW}⚠️  Conflit de peer deps détecté, retry avec --legacy-peer-deps...${NC}"
                flox activate -- npm install --legacy-peer-deps 2>&1 | grep -v "npm WARN" || true
            else
                echo "$npm_output" | grep -v "npm WARN" || true
            fi
        fi
        echo -e "${GREEN}✅ Dépendances installées${NC}"
    elif [ "$lang" = "python" ]; then
        echo -e "${BLUE}🐍 Configuration de l'environnement Python...${NC}"
        cd "$project_dir"
        local py_runtime_cmd="python3"
        local pydeps_dir=".shipflow-pydeps"
        local installed_ok=false

        if ! flox activate -- python3 --version >/dev/null 2>&1; then
            warning "Python3 n'est pas disponible dans Flox après l'initialisation"
        fi

        # Prefer an isolated venv when the host Python supports it.
        if [ ! -x ".venv/bin/python" ] && [ ! -x "venv/bin/python" ]; then
            echo -e "${BLUE}   Creating Python venv...${NC}"
            flox activate -- python3 -m venv .venv >/dev/null 2>&1 || true
        fi

        if [ -x ".venv/bin/python" ]; then
            py_runtime_cmd="./.venv/bin/python"
        elif [ -x "venv/bin/python" ]; then
            py_runtime_cmd="./venv/bin/python"
        fi

        # Install requirements if they exist
        if [ -f "requirements.txt" ]; then
            echo -e "${BLUE}   Installing requirements.txt...${NC}"
            if [ "$py_runtime_cmd" = "./.venv/bin/python" ] || [ "$py_runtime_cmd" = "./venv/bin/python" ]; then
                "$py_runtime_cmd" -m ensurepip --upgrade >/dev/null 2>&1 || true
                "$py_runtime_cmd" -m pip install -r requirements.txt -q 2>&1 && installed_ok=true || true
            fi

            if [ "$installed_ok" != "true" ]; then
                mkdir -p "$pydeps_dir"
                flox activate -- python3 -m pip install --break-system-packages --target "$pydeps_dir" -r requirements.txt -q 2>&1 && installed_ok=true || true
            fi
        elif [ -f "pyproject.toml" ]; then
            echo -e "${BLUE}   Installing from pyproject.toml...${NC}"
            if [ "$py_runtime_cmd" = "./.venv/bin/python" ] || [ "$py_runtime_cmd" = "./venv/bin/python" ]; then
                "$py_runtime_cmd" -m ensurepip --upgrade >/dev/null 2>&1 || true
                "$py_runtime_cmd" -m pip install -e . -q 2>&1 && installed_ok=true || true
            fi

            if [ "$installed_ok" != "true" ]; then
                mkdir -p "$pydeps_dir"
                flox activate -- python3 -m pip install --break-system-packages --target "$pydeps_dir" . -q 2>&1 && installed_ok=true || true
            fi
        fi

        if [ "$installed_ok" = "true" ]; then
            echo -e "${GREEN}✅ Dépendances Python installées${NC}"
        else
            warning "Les dépendances Python n'ont pas pu être installées automatiquement"
        fi
        echo -e "${GREEN}✅ Environnement Python configuré${NC}"
    fi
    
    # Fix port configuration in project files
    fix_port_config "$project_dir"
        
    success "Environnement Flox créé pour $project_name"
    return 0
}

# Fix port configuration in project config files
fix_port_config() {
    local project_dir=$1
    
    cd "$project_dir" || return 1
    
    # Astro: astro.config.mjs or astro.config.ts
    if [ -f "astro.config.mjs" ] || [ -f "astro.config.ts" ]; then
        local config_file=""
        [ -f "astro.config.mjs" ] && config_file="astro.config.mjs"
        [ -f "astro.config.ts" ] && config_file="astro.config.ts"
        
        if [ -n "$config_file" ]; then
            echo -e "${BLUE}🔧 Configuration d'Astro pour utiliser PORT...${NC}"
            
            # Check if server config exists with hardcoded port
            if grep -q "server.*:.*{" "$config_file" && grep -q "port.*:.*[0-9]" "$config_file"; then
                # Replace hardcoded port with process.env.PORT or default
                sed -i 's/port: *[0-9]\+/port: parseInt(process.env.PORT) || 3000/' "$config_file"
                echo -e "${GREEN}✅ Configuration Astro mise à jour${NC}"
            elif ! grep -q "server.*:" "$config_file"; then
                # Add server config if not exists
                sed -i '/export default defineConfig({/a\  server: {\n    port: parseInt(process.env.PORT) || 3000\n  },' "$config_file"
                echo -e "${GREEN}✅ Configuration Astro ajoutée${NC}"
            fi
        fi
    fi
    
    # Next.js: next.config.js or next.config.mjs
    if [ -f "next.config.js" ] || [ -f "next.config.mjs" ]; then
        echo -e "${BLUE}ℹ️  Next.js utilise -p pour le port (déjà géré)${NC}"
    fi
    
    # Vite: vite.config.js/ts
    if [ -f "vite.config.js" ] || [ -f "vite.config.ts" ]; then
        local config_file=""
        [ -f "vite.config.js" ] && config_file="vite.config.js"
        [ -f "vite.config.ts" ] && config_file="vite.config.ts"
        
        if [ -n "$config_file" ]; then
            echo -e "${BLUE}🔧 Configuration de Vite pour utiliser PORT...${NC}"
            
            if grep -q "server.*:.*{" "$config_file" && grep -q "port.*:.*[0-9]" "$config_file"; then
                sed -i 's/port: *[0-9]\+/port: parseInt(process.env.PORT) || 3000/' "$config_file"
                # Add HMR configuration if not present
                if ! grep -q "hmr.*:.*{" "$config_file"; then
                    sed -i '/server.*:.*{/a\    hmr: {\n      protocol: '\''ws'\'',\n      host: '\''localhost'\'',\n      port: parseInt(process.env.PORT) || 3000\n    },' "$config_file"
                fi
                echo -e "${GREEN}✅ Configuration Vite mise à jour avec HMR${NC}"
            elif grep -q "export default defineConfig({" "$config_file"; then
                sed -i '/export default defineConfig({/a\  server: {\n    port: parseInt(process.env.PORT) || 3000,\n    host: true,\n    hmr: {\n      protocol: '\''ws'\'',\n      host: '\''localhost'\'',\n      port: parseInt(process.env.PORT) || 3000\n    }\n  },' "$config_file"
                echo -e "${GREEN}✅ Configuration Vite ajoutée avec HMR${NC}"
            fi
        fi
    fi
    
    # Nuxt: nuxt.config.ts
    if [ -f "nuxt.config.ts" ]; then
        echo -e "${BLUE}ℹ️  Nuxt utilise --port pour le port (déjà géré)${NC}"
    fi
}

# Detect dev command for project
detect_dev_command() {
    local project_dir=$1
    local port=$2  # Port à utiliser
    local pubspec_kind=""
    
    cd "$project_dir" || return 1
    
    if [ -f "package.json" ]; then
        # Detect framework from package.json
        local framework=""
        if grep -q '"expo"' package.json || grep -q '"expo-router"' package.json; then
            framework="expo"
        elif grep -q '"astro"' package.json; then
            framework="astro"
        elif grep -q '"next"' package.json; then
            framework="next"
        elif grep -q '"vite"' package.json; then
            framework="vite"
        elif grep -q '"nuxt"' package.json; then
            framework="nuxt"
        fi
        
        # Determine package manager
        local pm_cmd=""
        if [ -f "pnpm-lock.yaml" ]; then
            pm_cmd="pnpm"
        elif [ -f "yarn.lock" ]; then
            pm_cmd="yarn"
        else
            pm_cmd="npm run"
        fi
        
        # Build command based on framework and port
        if [ -n "$framework" ]; then
            case "$framework" in
                expo)
                    echo "npx expo start --dev-client --tunnel"
                    ;;
                astro)
                    echo "$pm_cmd dev -- --port \$PORT"
                    ;;
                next)
                    # Next.js reads PORT env var natively - no -p flag needed
                    # Using -p with pnpm causes quoting issues ("-p" "3023")
                    echo "$pm_cmd dev"
                    ;;
                vite)
                    echo "$pm_cmd dev -- --port \$PORT --host"
                    ;;
                nuxt)
                    echo "$pm_cmd dev --port \$PORT"
                    ;;
                *)
                    echo "$pm_cmd dev"
                    ;;
            esac
            return 0
        elif grep -q '"dev"' package.json; then
            echo "$pm_cmd dev"
            return 0
        elif grep -q '"start"' package.json; then
            echo "$pm_cmd start"
            return 0
        fi
    fi

    if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
        local py_cmd=""
        py_cmd=$(python_runtime_command "$project_dir")
        if [ -f "manage.py" ]; then
            echo "$py_cmd manage.py runserver 0.0.0.0:\$PORT"
        elif [ -f "app.py" ]; then
            echo "$py_cmd app.py"
        elif [ -f "main.py" ]; then
            echo "$py_cmd main.py"
        else
            echo "$py_cmd -m http.server \$PORT"
        fi
    elif [ -f "Cargo.toml" ]; then
        echo "cargo run"
    elif [ -f "go.mod" ]; then
        echo "go run ."
    elif [ -f "pubspec.yaml" ]; then
        pubspec_kind=$(detect_pubspec_kind "$project_dir")
        if [ "$pubspec_kind" = "dart" ]; then
            local dart_entrypoint=""
            dart_entrypoint=$(detect_dart_entrypoint "$project_dir")
            if [ -n "$dart_entrypoint" ]; then
                echo "dart pub get && dart run $dart_entrypoint"
            else
                echo "dart pub get && dart run"
            fi
        elif [ -x "./pm2-web.sh" ]; then
            echo "./pm2-web.sh"
        elif [ -x "./build.sh" ]; then
            echo "./build.sh --serve"
        elif [ -d "web" ]; then
            echo "flutter config --enable-web >/dev/null 2>&1 || true && flutter pub get && flutter run -d web-server --web-hostname 0.0.0.0 --web-port \$PORT"
        else
            echo "echo 'Flutter project detected but no web target or pm2 entrypoint found' && exit 1"
        fi
    else
        echo "echo 'No dev command detected'"
    fi
}

escape_single_quotes_for_bash() {
    printf "%s" "$1" | sed "s/'/'\"'\"'/g"
}

flutter_web_sessions_file() {
    printf '%s\n' "${SHIPFLOW_FLUTTER_WEB_SESSIONS_FILE:-$SHIPFLOW_SECRETS_DIR/flutter-web-sessions.tsv}"
}

ensure_flutter_web_sessions_file() {
    local sessions_file
    sessions_file=$(flutter_web_sessions_file)
    local sessions_dir
    sessions_dir=$(dirname "$sessions_file")

    mkdir -p "$sessions_dir" 2>/dev/null || return 1
    touch "$sessions_file" 2>/dev/null || return 1
    chmod 600 "$sessions_file" 2>/dev/null || true
}

flutter_web_session_name() {
    local env_name="$1"
    local safe_name
    safe_name=$(printf '%s' "$env_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_.-]/-/g')
    safe_name="${safe_name#.}"
    safe_name="${safe_name#-}"
    safe_name="${safe_name:-flutter}"
    printf 'shipflow-flutter-%s\n' "$safe_name"
}

is_flutter_web_project() {
    local project_dir="$1"

    [ -d "$project_dir" ] || return 1
    [ -f "$project_dir/pubspec.yaml" ] || return 1
    [ "$(detect_pubspec_kind "$project_dir" 2>/dev/null)" = "flutter" ] || return 1
}

list_flutter_web_projects() {
    if [ ! -d "$PROJECTS_DIR" ]; then
        return 0
    fi

    find "$PROJECTS_DIR" -maxdepth "$SHIPFLOW_MAX_SEARCH_DEPTH" \
        \( -name "node_modules" -o -name ".git" -o -name "venv" -o -name ".venv" \
           -o -name "__pycache__" -o -name "target" -o -name ".next" -o -name ".nuxt" \
           -o -name "dist" -o -name ".cache" -o -name ".pnpm" -o -name ".yarn" \) -prune \
        -o -type f -name "pubspec.yaml" -print 2>/dev/null | while read -r pubspec; do
        local project_dir
        project_dir=$(dirname "$pubspec")
        case "$project_dir" in
            "$PROJECTS_DIR"/.*) continue ;;
        esac
        if is_flutter_web_project "$project_dir"; then
            echo "$project_dir"
        fi
    done | sort -u
}

flutter_web_registry_lines() {
    local active_only="${1:-false}"
    local sessions_file
    sessions_file=$(flutter_web_sessions_file)

    [ -f "$sessions_file" ] || return 0

    while IFS='|' read -r name port project_dir session_name; do
        [ -n "$name" ] || continue
        [[ "$port" =~ ^[0-9]+$ ]] || continue
        [ "$port" -ge 1 ] && [ "$port" -le 65535 ] || continue
        [ -n "$project_dir" ] || continue
        [ -n "$session_name" ] || continue
        if [ "$active_only" = "true" ]; then
            command -v tmux >/dev/null 2>&1 || continue
            tmux has-session -t "$session_name" 2>/dev/null || continue
        fi
        printf '%s|%s|%s|%s\n' "$name" "$port" "$project_dir" "$session_name"
    done < "$sessions_file"
}

flutter_web_registered_line_for_project() {
    local project_dir="$1"
    flutter_web_registry_lines false | awk -F'|' -v p="$project_dir" '$3 == p { print; exit }'
}

flutter_web_registered_port_for_project() {
    local project_dir="$1"
    local line
    line=$(flutter_web_registered_line_for_project "$project_dir")
    [ -n "$line" ] || return 1
    printf '%s\n' "$line" | cut -d'|' -f2
}

flutter_web_write_registry_entry() {
    local name="$1"
    local port="$2"
    local project_dir="$3"
    local session_name="$4"

    [[ "$port" =~ ^[0-9]+$ ]] || return 1
    [ "$port" -ge 1 ] && [ "$port" -le 65535 ] || return 1
    [ -n "$name" ] && [ -n "$project_dir" ] && [ -n "$session_name" ] || return 1
    ensure_flutter_web_sessions_file || return 1

    local sessions_file
    sessions_file=$(flutter_web_sessions_file)
    local tmp_file
    tmp_file=$(mktemp "${sessions_file}.tmp.XXXXXX") || return 1
    register_temp_file "$tmp_file"

    awk -F'|' -v p="$project_dir" -v s="$session_name" '$3 != p && $4 != s' "$sessions_file" > "$tmp_file" 2>/dev/null || true
    printf '%s|%s|%s|%s\n' "$name" "$port" "$project_dir" "$session_name" >> "$tmp_file"
    mv "$tmp_file" "$sessions_file" || return 1
    chmod 600 "$sessions_file" 2>/dev/null || true
}

flutter_web_remove_registry_entry() {
    local session_name="$1"
    local sessions_file
    sessions_file=$(flutter_web_sessions_file)

    [ -f "$sessions_file" ] || return 0

    local tmp_file
    tmp_file=$(mktemp "${sessions_file}.tmp.XXXXXX") || return 1
    register_temp_file "$tmp_file"

    awk -F'|' -v s="$session_name" '$4 != s' "$sessions_file" > "$tmp_file" 2>/dev/null || true
    mv "$tmp_file" "$sessions_file" || return 1
    chmod 600 "$sessions_file" 2>/dev/null || true
}

select_flutter_web_project() {
    local projects
    projects=$(list_flutter_web_projects)

    local options=()
    if [ -n "$projects" ]; then
        while IFS= read -r project_dir; do
            [ -n "$project_dir" ] && options+=("$project_dir")
        done <<< "$projects"
    fi
    options+=("Custom path")

    local selected
    selected=$(ui_choose "Select Flutter project:" "${options[@]}") || return 1
    if [ "$selected" = "Custom path" ]; then
        selected=$(ui_input "Path (absolute):" "$PROJECTS_DIR/my-flutter-app")
        [ -n "$selected" ] || return 1
    fi

    if ! validate_project_path "$selected"; then
        error "Chemin de projet invalide ou non sûr: $selected"
        return 1
    fi
    if ! is_flutter_web_project "$selected"; then
        error "Ce projet n'est pas un projet Flutter détecté: $selected"
        return 1
    fi

    printf '%s\n' "$selected"
}

select_flutter_web_session() {
    local prompt="${1:-Select Flutter Web session}"
    local lines
    lines=$(flutter_web_registry_lines true)

    if [ -z "$lines" ]; then
        error "Aucune session Flutter Web active"
        info "Lance d'abord: Flutter Web Dev → Start session"
        return 1
    fi

    local registry_lines=()
    local options=()
    local line name port project_dir session_name
    while IFS= read -r line; do
        [ -n "$line" ] || continue
        registry_lines+=("$line")
        IFS='|' read -r name port project_dir session_name <<< "$line"
        options+=("$name — localhost:$port — $project_dir")
    done <<< "$lines"

    local selected
    selected=$(ui_choose "$prompt" "${options[@]}") || return 1

    local i
    for ((i=0; i<${#options[@]}; i++)); do
        if [ "$selected" = "${options[$i]}" ]; then
            printf '%s\n' "${registry_lines[$i]}"
            return 0
        fi
    done

    return 1
}

start_flutter_web_tmux_session() {
    local project_dir="$1"

    if ! command -v tmux >/dev/null 2>&1; then
        error "tmux n'est pas installé"
        info "Installe tmux sur le serveur puis relance cette action."
        return 1
    fi

    if ! is_flutter_web_project "$project_dir"; then
        error "Projet Flutter invalide: $project_dir"
        return 1
    fi
    if [ ! -d "$project_dir/web" ]; then
        error "Cible web Flutter absente pour $project_dir"
        info "Dans le projet: flutter create . --platforms web"
        return 1
    fi

    local env_name
    env_name=$(basename "$project_dir")
    local session_name
    session_name=$(flutter_web_session_name "$env_name")

    local existing_line=""
    existing_line=$(flutter_web_registered_line_for_project "$project_dir" || true)
    if [ -n "$existing_line" ]; then
        local existing_name existing_port existing_project existing_session
        IFS='|' read -r existing_name existing_port existing_project existing_session <<< "$existing_line"
        if tmux has-session -t "$existing_session" 2>/dev/null; then
            success "Session Flutter Web déjà active"
            echo -e "  ${BLUE}Projet:${NC} $existing_project"
            echo -e "  ${BLUE}Session:${NC} ${CYAN}$existing_session${NC}"
            echo -e "  ${BLUE}URL:${NC} ${CYAN}http://localhost:$existing_port${NC}"
            echo -e "  ${YELLOW}Utilise Flutter Web Dev → Hot Reload pour envoyer r.${NC}"
            return 0
        fi
    fi

    init_flox_env "$project_dir" "$env_name" || return 1

    local port=""
    if [ -n "$existing_line" ]; then
        port=$(printf '%s\n' "$existing_line" | cut -d'|' -f2)
        if ! [[ "$port" =~ ^[0-9]+$ ]] || is_port_in_use "$port"; then
            port=""
        fi
    fi
    if [ -z "$port" ]; then
        port=$(find_available_port "$SHIPFLOW_PORT_RANGE_START")
        [ -n "$port" ] || return 1
    fi

    if tmux has-session -t "$session_name" 2>/dev/null; then
        error "Une session tmux existe déjà: $session_name"
        info "Attache-la ou arrête-la depuis Flutter Web Dev."
        return 1
    fi

    local flutter_cmd
    flutter_cmd="export PORT=$port; flutter config --enable-web >/dev/null 2>&1 || true; flutter pub get && flutter run -d web-server --web-hostname 0.0.0.0 --web-port $port"
    local escaped_flutter_cmd
    escaped_flutter_cmd=$(escape_single_quotes_for_bash "$flutter_cmd")
    local runtime_cmd="flox activate -- bash -lc '$escaped_flutter_cmd'"
    local escaped_runtime_cmd
    escaped_runtime_cmd=$(escape_single_quotes_for_bash "$runtime_cmd")

    echo -e "${BLUE}🚀 Démarrage Flutter Web dans tmux...${NC}"
    echo -e "  ${BLUE}Projet:${NC} $project_dir"
    echo -e "  ${BLUE}Session:${NC} ${CYAN}$session_name${NC}"
    echo -e "  ${BLUE}Port:${NC} ${CYAN}$port${NC}"

    if ! tmux new-session -d -s "$session_name" -c "$project_dir" "bash -lc '$escaped_runtime_cmd'"; then
        error "Impossible de créer la session tmux Flutter"
        return 1
    fi

    sleep 0.5
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        error "La session Flutter Web s'est arrêtée immédiatement"
        info "Relance et attache la session pour voir les logs: tmux attach -t $session_name"
        return 1
    fi

    flutter_web_write_registry_entry "$env_name" "$port" "$project_dir" "$session_name" || return 1

    success "Flutter Web lancé en session interactive"
    echo -e "  ${BLUE}URL tunnelable:${NC} ${CYAN}http://localhost:$port${NC}"
    echo -e "  ${BLUE}Hot reload:${NC} Flutter Web Dev → Hot Reload"
    echo -e "  ${BLUE}Terminal:${NC} ${CYAN}tmux attach -t $session_name${NC}"
    echo -e "  ${YELLOW}Côté téléphone, relance urls/tunnel pour exposer ce port si besoin.${NC}"
}

send_flutter_web_key() {
    local key="$1"
    local label="$2"
    local line
    line=$(select_flutter_web_session "Select Flutter Web session") || return 1

    local name port project_dir session_name
    IFS='|' read -r name port project_dir session_name <<< "$line"

    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        error "Session tmux introuvable: $session_name"
        flutter_web_remove_registry_entry "$session_name" || true
        return 1
    fi

    tmux send-keys -t "$session_name" "$key"
    success "$label envoyé à $name"
    echo -e "  ${BLUE}Session:${NC} ${CYAN}$session_name${NC}"
    echo -e "  ${BLUE}URL:${NC} ${CYAN}http://localhost:$port${NC}"
}

attach_flutter_web_session() {
    local line
    line=$(select_flutter_web_session "Select Flutter Web session to attach") || return 1

    local name port project_dir session_name
    IFS='|' read -r name port project_dir session_name <<< "$line"
    echo -e "${BLUE}Attache tmux:${NC} ${CYAN}$session_name${NC}"
    tmux attach-session -t "$session_name"
}

stop_flutter_web_session() {
    local line
    line=$(select_flutter_web_session "Select Flutter Web session to stop") || return 1

    local name port project_dir session_name
    IFS='|' read -r name port project_dir session_name <<< "$line"
    if tmux kill-session -t "$session_name" 2>/dev/null; then
        flutter_web_remove_registry_entry "$session_name" || true
        success "Session Flutter Web arrêtée: $name"
    else
        error "Impossible d'arrêter la session: $session_name"
        return 1
    fi
}

show_flutter_web_sessions() {
    local lines
    lines=$(flutter_web_registry_lines false)

    echo -e "${GREEN}🧩 Flutter Web sessions${NC}"
    echo ""
    if [ -z "$lines" ]; then
        echo -e "${YELLOW}Aucune session enregistrée${NC}"
        return 0
    fi

    local name port project_dir session_name status
    while IFS='|' read -r name port project_dir session_name; do
        if command -v tmux >/dev/null 2>&1 && tmux has-session -t "$session_name" 2>/dev/null; then
            status="${GREEN}active${NC}"
        else
            status="${YELLOW}inactive${NC}"
        fi
        echo -e "  ${CYAN}•${NC} $name ${BLUE}http://localhost:$port${NC} [$status]"
        echo -e "    ${BLUE}Session:${NC} $session_name"
        echo -e "    ${BLUE}Projet:${NC} $project_dir"
    done <<< "$lines"
}

project_has_doppler_manifest() {
    local project_dir=$1

    [ -f "$project_dir/doppler.yaml" ] || [ -f "$project_dir/.doppler.yaml" ]
}

project_has_doppler_scope() {
    local project_dir=$1
    local doppler_state_file="$HOME/.doppler/.doppler.yaml"

    [ -f "$doppler_state_file" ] || return 1
    grep -Fq "    $project_dir:" "$doppler_state_file"
}

should_enable_doppler() {
    local project_dir=$1
    local mode="${SHIPFLOW_DOPPLER_MODE:-auto}"

    if ! command -v doppler >/dev/null 2>&1; then
        return 1
    fi

    case "$mode" in
        always)
            return 0
            ;;
        never)
            return 1
            ;;
        auto|*)
            if project_has_doppler_manifest "$project_dir" || project_has_doppler_scope "$project_dir"; then
                return 0
            fi
            return 1
            ;;
    esac
}

# ============================================================================
# ENVIRONMENT LIFECYCLE OPERATIONS
# ============================================================================

# -----------------------------------------------------------------------------
# env_start - Start a development environment with PM2 + Flox
#
# Description:
#   Starts a project environment using PM2 for process management and
#   Flox for dependency isolation. Automatically:
#   - Validates identifier
#   - Initializes Flox environment if needed
#   - Detects dev command for project
#   - Allocates/reuses port
#   - Creates PM2 ecosystem config
#   - Injects web inspector
#   - Starts PM2 process
#
# Arguments:
#   $1 - Environment identifier (name or absolute path)
#
# Returns:
#   0 - Environment started successfully
#   1 - Error occurred
#
# Side Effects:
#   - Creates ecosystem.config.cjs in project directory
#   - Invalidates PM2 cache
#   - Kills existing PM2 process if running
#   - May modify vite.config.js or astro.config.mjs for port config
#
# Example:
#   env_start "myapp"
#   env_start "/root/custom/path"
# -----------------------------------------------------------------------------
env_start() {
    local identifier=$1 # Can be env_name or custom_path
    local project_dir=""
    local env_name=""
    local pm2_config=""

    # Validate identifier
    if [ -z "$identifier" ]; then
        error "Environment identifier is required"
        return 1
    fi

    # If it looks like a path, validate it
    if [[ "$identifier" == /* ]]; then
        if ! validate_project_path "$identifier"; then
            return 1
        fi
    else
        if ! validate_env_name "$identifier"; then
            return 1
        fi
    fi

    project_dir=$(resolve_project_path "$identifier")
    if [ -z "$project_dir" ]; then
        error "Projet introuvable pour l'identifiant: $identifier"
        return 1
    fi
    
    env_name=$(basename "$project_dir") # Derive env_name from the resolved path
    pm2_config="$project_dir/ecosystem.config.cjs"

    local project_type
    project_type=$(detect_project_type "$project_dir")
    local project_lang="${project_type%%:*}"

    # Check if Flox env exists, create if not
    if [ ! -d "$project_dir/.flox" ]; then
        echo -e "${YELLOW}⚠️  Pas d'environnement Flox détecté${NC}"
        init_flox_env "$project_dir" "$env_name" || return 1
    elif [ "$project_lang" = "dart" ] || [ "$project_lang" = "flutter" ]; then
        init_flox_env "$project_dir" "$env_name" || return 1
    fi

    # Detect dev command
    local dev_cmd=$(detect_dev_command "$project_dir")

    if [ -z "$dev_cmd" ] || [ "$dev_cmd" = "echo 'No dev command detected'" ]; then
        warning "Aucune commande de dev détectée pour $env_name"
        return 1
    fi

    # Expo/React Native projects use a tunnel — no fixed port needed
    local is_expo=false
    if [[ "$dev_cmd" == *"expo start"* ]]; then
        is_expo=true
    fi

    local port=""
    local doppler_prefix=""
    local doppler_enabled=false
    # Check for existing port and doppler in ecosystem.config.cjs - PROPER PARSING
    if [ -f "$pm2_config" ]; then
        # Use Node.js to properly parse the config file
        local config_data=$(node -e "
            try {
                const cfg = require('$pm2_config');
                const app = cfg.apps[0];
                const port = app.env && app.env.PORT ? app.env.PORT : '';
                const hasDoppler = app.args && Array.isArray(app.args) && app.args.join(' ').includes('doppler run');
                console.log(JSON.stringify({ port: port, hasDoppler: hasDoppler }));
            } catch (e) {
                console.log(JSON.stringify({ port: '', hasDoppler: false }));
            }
        " 2>/dev/null)

        if [ -n "$config_data" ]; then
            port=$(echo "$config_data" | python3 -c "import sys, json; d = json.load(sys.stdin); print(d.get('port', ''))" 2>/dev/null)
            local has_doppler=$(echo "$config_data" | python3 -c "import sys, json; d = json.load(sys.stdin); print('true' if d.get('hasDoppler') else 'false')" 2>/dev/null)
            if [ "$has_doppler" = "true" ]; then
                doppler_prefix="doppler run -- "
                doppler_enabled=true
            fi
        fi
    fi

    if [ "$doppler_enabled" != "true" ] && should_enable_doppler "$project_dir"; then
        doppler_prefix="doppler run -- "
        doppler_enabled=true
    fi

    # If no persistent port found, find an available one (skip for Expo tunnel projects)
    if [ "$is_expo" = "true" ]; then
        echo -e "${BLUE}📱 Projet Expo — pas de port fixe (tunnel Metro)${NC}"
    elif [ -z "$port" ]; then
        port=$(find_available_port 3000)
        [ -z "$port" ] && return 1
        echo -e "${BLUE}🔌 Nouveau port assigné: $port${NC}"
    else
        # Refresh cache to avoid using stale PM2 state when deciding port reuse
        invalidate_pm2_cache

        # Verify persistent port isn't already taken by another PM2 app
        local other_app=$(get_pm2_data_cached | awk -F'|' -v p="$port" -v n="$env_name" '$3 == p && $1 != n {print $1}')

        # Detect if the port is currently used by this same app (normal during start/redeploy)
        local self_status=$(get_pm2_app_data "$env_name" "status")
        local self_port=$(get_pm2_app_data "$env_name" "port")
        local self_owns_port="false"
        if [ "$self_status" = "online" ] && [ "$self_port" = "$port" ] && is_port_in_use "$port"; then
            self_owns_port="true"
        fi

        if [ -n "$other_app" ]; then
            warning "Port $port (persistant) déjà utilisé par $other_app, recherche d'un nouveau port..."
            port=$(find_available_port 3000)
            [ -z "$port" ] && return 1
            echo -e "${BLUE}🔌 Nouveau port assigné: $port${NC}"
        elif is_port_in_use "$port" && [ "$self_owns_port" != "true" ]; then
            warning "Port $port (persistant) déjà utilisé par un autre processus, recherche d'un nouveau port..."
            port=$(find_available_port 3000)
            [ -z "$port" ] && return 1
            echo -e "${BLUE}🔌 Nouveau port assigné: $port${NC}"
        else
            echo -e "${BLUE}🔌 Port persistant réutilisé: $port${NC}"
        fi
    fi
    
    echo -e "${BLUE}🚀 Commande: $dev_cmd${NC}"
    if [ "$doppler_enabled" = "true" ]; then
        echo -e "${BLUE}🔐 Doppler: activé (${SHIPFLOW_DOPPLER_MODE:-auto})${NC}"
    else
        echo -e "${BLUE}🔐 Doppler: désactivé${NC}"
    fi

    # Replace $PORT in dev_cmd with actual port value
    local final_cmd="${dev_cmd//\$PORT/$port}"
    local runtime_cmd="$final_cmd"

    # For Doppler projects, override PORT after doppler injects its env vars
    # to prevent Doppler's PORT value from taking precedence over ShipFlow's assignment
    if [ -n "$doppler_prefix" ]; then
        runtime_cmd="env PORT=$port $final_cmd"
    fi

    local escaped_runtime_cmd
    escaped_runtime_cmd=$(escape_single_quotes_for_bash "$runtime_cmd")

    local pm2_launch_cmd=""
    if [ "$is_expo" = "true" ]; then
        pm2_launch_cmd="flox activate -- bash -lc '$escaped_runtime_cmd'"
    else
        pm2_launch_cmd="export PORT=$port && flox activate -- ${doppler_prefix}bash -lc '$escaped_runtime_cmd'"
    fi

    # Create persistent ecosystem file (Expo has no PORT)
    if [ "$is_expo" = "true" ]; then
        cat > "$pm2_config" <<EOF
module.exports = {
  apps: [{
    name: "$env_name",
    cwd: "$project_dir",
    script: "bash",
    args: ["-lc", "$pm2_launch_cmd"],
    autorestart: false,
    watch: false
  }]
};
EOF
    else
        cat > "$pm2_config" <<EOF
module.exports = {
  apps: [{
    name: "$env_name",
    cwd: "$project_dir",
    script: "bash",
    args: ["-lc", "$pm2_launch_cmd"],
    env: {
      PORT: $port
    },
    autorestart: true,
    max_restarts: 3,
    min_uptime: "10s",
    restart_delay: 2000,
    watch: false
  }]
};
EOF
    fi

    if [ ! -f "$pm2_config" ]; then
        error "Impossible de créer $pm2_config"
        return 1
    fi

    echo -e "${GREEN}✅ Fichier ecosystem.config.cjs créé/mis à jour${NC}"

    # Atomic cleanup of existing process (Priority 3 #11: Fix race condition)
    # Use pm2 delete with idempotent operation (no check-then-act)
    pm2 delete "$env_name" 2>/dev/null || true

    # Kill any lingering processes on the port to avoid zombies (skip for Expo)
    if [ "$is_expo" = "false" ] && command -v fuser >/dev/null 2>&1; then
        fuser -k "$port/tcp" 2>/dev/null || true
    fi

    # Small delay to ensure port is fully released
    sleep 0.5

    if ! pm2 start "$pm2_config"; then
        error "Échec du démarrage PM2 pour $env_name"
        return 1
    fi
    pm2 save >/dev/null 2>&1

    # Invalidate cache after PM2 state change
    invalidate_pm2_cache

    local started_status
    started_status=$(get_pm2_status "$env_name")
    if [ "$started_status" != "online" ] && [ "$started_status" != "launching" ]; then
        error "PM2 n'a pas démarré $env_name correctement (statut: ${started_status:-unknown})"
        return 1
    fi

    if [ "$is_expo" = "true" ]; then
        success "Projet $env_name (Expo) démarré — URL tunnel dans: pm2 logs $env_name"
        log INFO "Started Expo environment: $env_name at $project_dir"
    else
        success "Projet $env_name démarré sur le port $port"
        log INFO "Started environment: $env_name on port $port at $project_dir"
        refresh_user_caddy_from_pm2 || true
    fi

    # Initialize ShipFlow tracking on first start or clean up legacy tracker symlinks.
    local project_tracking_dir="${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}/projects/$env_name"
    local should_init_tracking=false
    if [ ! -f "$project_tracking_dir/TASKS.md" ]; then
        should_init_tracking=true
    elif [ -L "$project_dir/TASKS.md" ]; then
        local project_tasks_target=""
        project_tasks_target=$(readlink "$project_dir/TASKS.md" 2>/dev/null || true)
        case "$project_tasks_target" in
            *"/shipflow_data/projects/"*"/TASKS.md")
                should_init_tracking=true
                ;;
        esac
    fi

    if [ "$should_init_tracking" = "true" ]; then
        shipflow_init_project "$env_name" "$project_dir"
    fi
}

# -----------------------------------------------------------------------------
# env_stop - Stop a running environment
#
# Description:
#   Stops a PM2-managed environment gracefully.
#
# Arguments:
#   $1 - Environment identifier (name or path)
#
# Returns:
#   0 - Environment stopped or already stopped
#   1 - Error occurred
#
# Side Effects:
#   - Invalidates PM2 cache
#   - Saves PM2 process list
#
# Example:
#   env_stop "myapp"
# -----------------------------------------------------------------------------
env_stop() {
    local identifier=$1

    # Validate identifier
    if [ -z "$identifier" ]; then
        error "Environment identifier is required"
        return 1
    fi

    local project_dir=$(resolve_project_path "$identifier")
    local pm2_app_name=""

    if [ -n "$project_dir" ]; then
        pm2_app_name=$(basename "$project_dir")
    elif pm2_app_exists_by_name "$identifier"; then
        pm2_app_name="$identifier"
        warning "Projet $identifier introuvable sur disque; arrêt de l'entrée PM2 orpheline."
    else
        warning "Projet $identifier introuvable ou chemin invalide."
        return 1
    fi

    local stop_rc=0
    pm2_stop_app_by_name "$pm2_app_name" || stop_rc=$?
    if [ "$stop_rc" -eq 0 ]; then
        sync_caddy_after_pm2_change
    fi
    return "$stop_rc"
}

# Web Inspector Functions
# Generate CSS selector for an element
generate_css_selector() {
    local element="$1"
    echo "css-selector-for-$element" | sed 's/[^a-zA-Z0-9_-]/-/g'
}

remove_next_script_import_if_unused() {
    local layout_file=$1

    [ -f "$layout_file" ] || return 0

    if grep -q 'shipflow-inspector' "$layout_file"; then
        return 0
    fi

    if grep -q 'import Script from "next/script";' "$layout_file" && ! grep -q '<Script' "$layout_file"; then
        sed -i '/import Script from "next\/script";/d' "$layout_file"
    fi
}

remove_web_inspector_snippet() {
    local target_file=$1

    [ -f "$target_file" ] || return 0

    perl -0pi -e 's/\s*<!-- shipflow-inspector -->\s*<script src="\/shipflow-inspector\.js" defer><\/script>\s*//g' "$target_file"
    perl -0pi -e 's/\s*<Script src="\/shipflow-inspector\.js" strategy="afterInteractive" id="shipflow-inspector" \/>\s*//g' "$target_file"
}

web_inspector_is_enabled() {
    if [ -f "public/shipflow-inspector.js" ]; then
        return 0
    fi

    if [ -f "index.html" ] && grep -q 'shipflow-inspector' "index.html"; then
        return 0
    fi

    local layout=""
    for layout in src/layouts/*.astro \
        app/layout.tsx app/layout.jsx src/app/layout.tsx src/app/layout.jsx \
        apps/*/app/layout.tsx apps/*/app/layout.jsx apps/*/src/app/layout.tsx apps/*/src/app/layout.jsx \
        packages/*/app/layout.tsx packages/*/app/layout.jsx packages/*/src/app/layout.tsx packages/*/src/app/layout.jsx; do
        [ -f "$layout" ] || continue
        if grep -q 'shipflow-inspector' "$layout"; then
            return 0
        fi
    done

    local app_dir=""
    for app_dir in apps/* packages/*; do
        [ -d "$app_dir" ] || continue
        if [ -f "$app_dir/public/shipflow-inspector.js" ]; then
            return 0
        fi
    done

    return 1
}

# Initialize web inspector
init_web_inspector() {
    local script_path="${SCRIPT_DIR}/injectors/web-inspector.js"
    local script_name="shipflow-inspector.js"
    local marker="<!-- shipflow-inspector -->"
    local script_tag='<script src="/shipflow-inspector.js" defer></script>'

    if [ ! -f "$script_path" ]; then
        log ERROR "Web inspector script not found at $script_path"
        echo "Error: Web inspector script not found at $script_path"
        return 1
    fi

    # Step 1: Copy script to project's public/ directory
    mkdir -p public
    cp "$script_path" "public/$script_name"
    echo "Copied web inspector to public/$script_name"

    # Step 2: Add script tag to the appropriate file
    if [ -f "index.html" ]; then
        # Vite/React/Vue projects with root index.html
        if ! grep -q "shipflow-inspector" "index.html"; then
            sed -i "s|</body>|  ${marker}\n  ${script_tag}\n</body>|" "index.html"
            echo "Injected script tag into index.html"
        else
            echo "Script tag already present in index.html"
        fi
    elif [ -f "package.json" ] && grep -q '"astro"' package.json; then
        # Astro projects: inject into layout files
        local injected=false
        for layout in src/layouts/*.astro; do
            [ -f "$layout" ] || continue
            if grep -q "</body>" "$layout" && ! grep -q "shipflow-inspector" "$layout"; then
                sed -i "s|</body>|  ${marker}\n  ${script_tag}\n</body>|" "$layout"
                echo "Injected script tag into $layout"
                injected=true
            elif grep -q "shipflow-inspector" "$layout"; then
                echo "Script tag already present in $layout"
                injected=true
            fi
        done
        if [ "$injected" = false ]; then
            log WARNING "No layout with </body> found for Astro project"
            echo "Warning: No layout with </body> found for Astro project"
        fi
    else
        # Check for Next.js project (direct or monorepo)
        local is_nextjs=false
        local layout_file=""
        local public_dir="public"

        # Direct Next.js detection (next.config.*, next-env.d.ts, or "next" in package.json)
        if [ -f "next.config.ts" ] || [ -f "next.config.js" ] || [ -f "next.config.mjs" ] || [ -f "next-env.d.ts" ] || ([ -f "package.json" ] && grep -q '"next"' package.json); then
            is_nextjs=true
            for candidate in "app/layout.tsx" "app/layout.jsx" "src/app/layout.tsx" "src/app/layout.jsx"; do
                if [ -f "$candidate" ]; then
                    layout_file="$candidate"
                    break
                fi
            done
        fi

        # Monorepo detection (check apps/* and packages/* for Next.js indicators)
        if [ "$is_nextjs" = false ]; then
            for app_dir in apps/* packages/*; do
                [ -d "$app_dir" ] || continue
                # Check for Next.js indicators in this app
                if [ -f "$app_dir/next.config.ts" ] || [ -f "$app_dir/next.config.js" ] || [ -f "$app_dir/next.config.mjs" ] || [ -f "$app_dir/next-env.d.ts" ] || ([ -f "$app_dir/package.json" ] && grep -q '"next"' "$app_dir/package.json"); then
                    is_nextjs=true
                    # Find layout in this app directory
                    for candidate in "$app_dir/app/layout.tsx" "$app_dir/app/layout.jsx" "$app_dir/src/app/layout.tsx" "$app_dir/src/app/layout.jsx"; do
                        if [ -f "$candidate" ]; then
                            layout_file="$candidate"
                            # For monorepos, also copy to the app's public dir
                            if [ -d "$app_dir/public" ]; then
                                cp "$script_path" "$app_dir/public/$script_name"
                                echo "Copied web inspector to $app_dir/public/$script_name"
                            fi
                            break 2
                        fi
                    done
                fi
            done
        fi

        if [ "$is_nextjs" = true ]; then
            if [ -z "$layout_file" ]; then
                log WARNING "Next.js project detected but no app/layout found"
                echo "Warning: Next.js project detected but no app/layout found"
            elif grep -q "shipflow-inspector" "$layout_file"; then
                echo "Script already present in $layout_file"
            else
                # Add Script import if not present
                if ! grep -q "from ['\"]next/script['\"]" "$layout_file"; then
                    # Add import after the first import line
                    sed -i '0,/^import /s//import Script from "next\/script";\n&/' "$layout_file"
                    echo "Added Script import to $layout_file"
                fi

                # Add Script component before </body>
                local nextjs_script='<Script src="/shipflow-inspector.js" strategy="afterInteractive" id="shipflow-inspector" />'
                if grep -q "</body>" "$layout_file"; then
                    sed -i "s|</body>|        ${nextjs_script}\n      </body>|" "$layout_file"
                    echo "Injected Script component into $layout_file"
                else
                    log WARNING "No </body> tag found in $layout_file"
                    echo "Warning: No </body> tag found in $layout_file"
                fi
            fi
        else
            log WARNING "Could not find injection target (no index.html, Astro layout, or Next.js layout)"
            echo "Warning: Could not find injection target (no index.html, Astro layout, or Next.js layout)"
        fi
    fi

    echo "Web inspector configured"
}

# -----------------------------------------------------------------------------
# toggle_web_inspector - Enable or disable web inspector for a project
#
# Description:
#   Toggles the web inspector injection. If the inspector JS file exists in
#   the project's public/ directory, it removes it and strips injected script
#   tags. If not present, calls init_web_inspector to inject it.
#
# Arguments:
#   $1 - Project directory (absolute path)
#
# Returns:
#   0 - Success
#   1 - Invalid directory
#
# Outputs:
#   "Web inspector enabled" or "Web inspector disabled"
#
# Example:
#   toggle_web_inspector "/root/myapp"
# -----------------------------------------------------------------------------
toggle_web_inspector() {
    local project_dir=$1

    if [ -z "$project_dir" ] || [ ! -d "$project_dir" ]; then
        error "Invalid project directory: $project_dir"
        return 1
    fi

    cd "$project_dir" || return 1

    if web_inspector_is_enabled; then
        # Disable: remove JS file
        rm -f "public/shipflow-inspector.js"

        # Remove injected lines from index.html
        if [ -f "index.html" ]; then
            remove_web_inspector_snippet "index.html"
        fi

        # Remove from Astro layouts
        for layout in src/layouts/*.astro; do
            [ -f "$layout" ] || continue
            remove_web_inspector_snippet "$layout"
        done

        # Remove from Next.js layouts
        for candidate in "app/layout.tsx" "app/layout.jsx" "src/app/layout.tsx" "src/app/layout.jsx"; do
            [ -f "$candidate" ] || continue
            remove_web_inspector_snippet "$candidate"
            remove_next_script_import_if_unused "$candidate"
        done

        # Remove from monorepo app layouts
        for app_dir in apps/* packages/*; do
            [ -d "$app_dir" ] || continue
            rm -f "$app_dir/public/shipflow-inspector.js" 2>/dev/null
            for candidate in "$app_dir/app/layout.tsx" "$app_dir/app/layout.jsx" "$app_dir/src/app/layout.tsx" "$app_dir/src/app/layout.jsx"; do
                [ -f "$candidate" ] || continue
                remove_web_inspector_snippet "$candidate"
                remove_next_script_import_if_unused "$candidate"
            done
        done

        echo "Web inspector disabled"
        log INFO "Web inspector disabled for $project_dir"
    else
        # Enable: call init_web_inspector
        init_web_inspector
        echo "Web inspector enabled"
        log INFO "Web inspector enabled for $project_dir"
    fi

    return 0
}

# -----------------------------------------------------------------------------
# env_remove - Remove an environment completely
#
# Description:
#   Stops the PM2 process and deletes the project directory.
#   This operation is DESTRUCTIVE and cannot be undone.
#
# Arguments:
#   $1 - Environment identifier (name or path)
#
# Returns:
#   0 - Environment removed
#   1 - Error occurred
#
# Side Effects:
#   - Deletes PM2 process
#   - Removes entire project directory (DESTRUCTIVE!)
#   - Invalidates PM2 cache
#
# Warning:
#   This permanently deletes all project files!
#
# Example:
#   env_remove "myapp"
# -----------------------------------------------------------------------------
env_remove() {
    local identifier=$1

    # Validate identifier
    if [ -z "$identifier" ]; then
        error "Environment identifier is required"
        return 1
    fi

    local project_dir=$(resolve_project_path "$identifier")

    if [ -z "$project_dir" ]; then
        warning "Projet $identifier introuvable ou chemin invalide. Impossible de supprimer."
        return 1
    fi

    local env_name=$(basename "$project_dir")

    # Atomic deletion of PM2 process (Priority 3 #11: Fix race condition)
    # Use pm2 delete with idempotent operation (no check-then-act)
    if pm2 delete "$env_name" 2>/dev/null; then
        echo -e "${YELLOW}🛑 Arrêt du processus PM2 $env_name...${NC}"
        pm2 save >/dev/null 2>&1
        # Invalidate cache after PM2 state change
        invalidate_pm2_cache
    fi

    # Remove project directory (atomic operation)
    if [ -d "$project_dir" ]; then
        log INFO "Removing environment: $env_name at $project_dir"
        rm -rf "$project_dir" || {
            error "Failed to remove directory: $project_dir"
            log ERROR "Failed to remove $project_dir"
            return 1
        }
        success "Projet $env_name supprimé"
    else
        warning "Répertoire $project_dir introuvable (peut-être déjà supprimé ou chemin incorrect)"
    fi

    return 0
}

# -----------------------------------------------------------------------------
# env_rename - Rename an environment (PM2 + Flox + directory)
#
# Description:
#   Stops and deletes the PM2 process under the old name, cleans up Flox,
#   renames the project directory, and re-initializes Flox under the new name.
#   Project files are preserved. The environment is NOT restarted automatically.
#
# Arguments:
#   $1 - Old environment identifier (name or path)
#   $2 - New environment name
#
# Returns:
#   0 - Environment renamed
#   1 - Error occurred
#
# Example:
#   env_rename "my-robots-app" "ContentFlowz-app"
# -----------------------------------------------------------------------------
env_rename() {
    local old_identifier=$1
    local new_name="${2,,}"

    # Validate arguments
    if [ -z "$old_identifier" ] || [ -z "$new_name" ]; then
        error "Usage: env_rename <old_name> <new_name>"
        return 1
    fi

    if ! validate_env_name "$new_name"; then
        return 1
    fi

    local old_dir=$(resolve_project_path "$old_identifier")
    if [ -z "$old_dir" ]; then
        warning "Projet $old_identifier introuvable ou chemin invalide."
        return 1
    fi

    local old_name=$(basename "$old_dir")
    local parent_dir=$(dirname "$old_dir")
    local new_dir="$parent_dir/$new_name"

    # Check old and new are different
    if [ "$old_name" = "$new_name" ]; then
        warning "L'ancien et le nouveau nom sont identiques."
        return 1
    fi

    # Check new directory doesn't already exist
    if [ -d "$new_dir" ]; then
        error "Le dossier $new_dir existe déjà."
        return 1
    fi

    # Check new name not already used by another PM2 process
    local existing_pm2=$(get_pm2_data_cached | awk -F'|' -v n="$new_name" '$1 == n {print $1}')
    if [ -n "$existing_pm2" ]; then
        error "Un process PM2 '$new_name' existe déjà."
        return 1
    fi

    log INFO "Renaming environment: $old_name -> $new_name"

    # 1. Stop & delete PM2 process (idempotent)
    pm2 delete "$old_name" 2>/dev/null && {
        echo -e "${YELLOW}🛑 Process PM2 $old_name supprimé${NC}"
    }
    invalidate_pm2_cache

    # 2. Clean up Flox environment (registry + watchdog)
    if [ -d "$old_dir/.flox" ] && command -v flox >/dev/null 2>&1; then
        flox delete -f -d "$old_dir" 2>/dev/null && {
            echo -e "${YELLOW}🧹 Environnement Flox nettoyé${NC}"
        }
    fi

    # 3. Rename directory
    mv "$old_dir" "$new_dir" || {
        error "Impossible de renommer $old_dir -> $new_dir"
        return 1
    }
    echo -e "${BLUE}📁 $old_name -> $new_name${NC}"

    # 4. Remove old ecosystem.config.cjs (will be regenerated on next start)
    rm -f "$new_dir/ecosystem.config.cjs"

    # 5. Re-initialize Flox in new directory
    if command -v flox >/dev/null 2>&1; then
        init_flox_env "$new_dir" "$new_name" || {
            warning "Flox init failed — you can re-init manually with env_start"
        }
    fi

    # 6. Save PM2 state (old process removed from dump)
    pm2 save >/dev/null 2>&1
    invalidate_pm2_cache

    success "Projet renommé: $old_name → $new_name"
    info "Lance 'env_start \"$new_name\"' pour démarrer avec le nouveau nom"

    return 0
}

# -----------------------------------------------------------------------------
# get_status_icon - Return emoji status icon for a PM2 status string
#
# Arguments:
#   $1 - PM2 status string (online, stopped, errored, error, etc.)
#
# Outputs:
#   Emoji icon to stdout
#
# Example:
#   icon=$(get_status_icon "online")  # Returns 🟢
# -----------------------------------------------------------------------------
get_status_icon() {
    local status=$1
    case "$status" in
        online)        echo "🟢";;
        stopped)       echo "🟡";;
        errored|error) echo "🔴";;
        *)             echo "⚪";;
    esac
}

# ============================================================================
# HEALTH MONITORING FUNCTIONS
# ============================================================================

# -----------------------------------------------------------------------------
# get_pm2_health_data - Get restart count and uptime for all PM2 apps
#
# Description:
#   Fetches extended PM2 data including restart_time and pm_uptime fields
#   that are not included in the standard cached data. This is a separate
#   call from get_pm2_data_cached() because it needs additional fields.
#
# Returns:
#   0 - Success
#   1 - PM2 not available
#
# Outputs:
#   Lines of: name|status|restarts|uptime_ms|error_log_path
# -----------------------------------------------------------------------------
get_pm2_health_data() {
    if ! command -v pm2 >/dev/null 2>&1; then
        return 1
    fi

    if [ "$SHIPFLOW_PREFER_JQ" = "true" ] && command -v jq >/dev/null 2>&1; then
        pm2 jlist 2>/dev/null | jq -r '.[] | "\(.name)|\(.pm2_env.status // "unknown")|\(.pm2_env.restart_time // 0)|\(.pm2_env.pm_uptime // 0)|\(.pm2_env.pm_err_log_path // "")"' 2>/dev/null
    elif command -v python3 >/dev/null 2>&1; then
        pm2 jlist 2>/dev/null | python3 -c "
import sys, json
try:
    apps = json.load(sys.stdin)
    for app in apps:
        name = app.get('name', '')
        env = app.get('pm2_env', {})
        status = env.get('status', 'unknown')
        restarts = env.get('restart_time', 0)
        uptime = env.get('pm_uptime', 0)
        err_log = env.get('pm_err_log_path', '')
        print(f'{name}|{status}|{restarts}|{uptime}|{err_log}')
except Exception:
    pass
" 2>/dev/null
    else
        return 1
    fi
}

# -----------------------------------------------------------------------------
# detect_crash_loop - Check if a specific app is in a crash loop
#
# Arguments:
#   $1 - App name
#   $2 - Restart count
#   $3 - Uptime in milliseconds
#   $4 - Status
#
# Returns:
#   0 - App is in a crash loop
#   1 - App is healthy
#
# Outputs:
#   "crash_loop" | "unstable" | "healthy"
# -----------------------------------------------------------------------------
detect_crash_loop() {
    local name=$1
    local restarts=$2
    local uptime_ms=$3
    local status=$4

    local threshold=${SHIPFLOW_CRASH_LOOP_THRESHOLD:-10}
    local unstable_secs=${SHIPFLOW_UNSTABLE_UPTIME_SECS:-30}
    local unstable_ms=$((unstable_secs * 1000))

    # Errored with high restarts = crash loop
    if [ "$status" = "errored" ] && [ "$restarts" -gt "$threshold" ]; then
        echo "crash_loop"
        return 0
    fi

    # Online but high restarts + low uptime = crash loop (just restarted again)
    if [ "$restarts" -gt "$threshold" ] && [ "$uptime_ms" -lt "$unstable_ms" ]; then
        echo "crash_loop"
        return 0
    fi

    # Online but high restarts (recovered but was looping)
    if [ "$restarts" -gt "$threshold" ]; then
        echo "unstable"
        return 0
    fi

    echo "healthy"
    return 1
}

# -----------------------------------------------------------------------------
# diagnose_app_errors - Analyze error logs for known patterns
#
# Description:
#   Reads the last 50 lines of an app's PM2 error log and matches
#   against known error patterns from config.
#
# Arguments:
#   $1 - Path to PM2 error log
#
# Returns:
#   0 - Known error found
#   1 - No known error matched
#
# Outputs:
#   "label|hint" for the first matching pattern
# -----------------------------------------------------------------------------
diagnose_app_errors() {
    local err_log=$1

    if [ ! -f "$err_log" ] || [ ! -s "$err_log" ]; then
        return 1
    fi

    local recent_errors
    recent_errors=$(tail -50 "$err_log" 2>/dev/null)

    for pattern_entry in "${SHIPFLOW_KNOWN_ERROR_PATTERNS[@]}"; do
        local pattern label hint
        pattern=$(echo "$pattern_entry" | cut -d'|' -f1)
        label=$(echo "$pattern_entry" | cut -d'|' -f2)
        hint=$(echo "$pattern_entry" | cut -d'|' -f3)

        if echo "$recent_errors" | grep -qiE "$pattern"; then
            echo "${label}|${hint}"
            return 0
        fi
    done

    return 1
}

# -----------------------------------------------------------------------------
# health_check_all - Run health checks on all PM2 apps
#
# Description:
#   Scans all PM2 apps for crash loops and known error patterns.
#   Outputs a formatted health report. Used by dashboard and
#   standalone health check command.
#
# Arguments:
#   $1 - "quiet" for machine-readable, "verbose" for full report (default)
#
# Returns:
#   0 - All apps healthy
#   1 - One or more apps unhealthy
#
# Outputs:
#   Formatted health report
# -----------------------------------------------------------------------------
health_check_all() {
    local mode=${1:-verbose}
    local health_data
    health_data=$(get_pm2_health_data)

    if [ -z "$health_data" ]; then
        if [ "$mode" = "verbose" ]; then
            echo -e "${YELLOW}⚠️  No PM2 apps found or PM2 unavailable${NC}"
        fi
        return 0
    fi

    local unhealthy_count=0
    local crash_loop_count=0
    local total_count=0
    local alerts=""

    while IFS='|' read -r name status restarts uptime_ms err_log; do
        [ -z "$name" ] && continue
        ((total_count++))

        # Skip stopped apps (they're intentionally stopped)
        [ "$status" = "stopped" ] && continue

        local health
        health=$(detect_crash_loop "$name" "$restarts" "$uptime_ms" "$status")

        if [ "$health" = "crash_loop" ]; then
            ((crash_loop_count++))
            ((unhealthy_count++))

            local diagnosis=""
            if [ -n "$err_log" ]; then
                diagnosis=$(diagnose_app_errors "$err_log")
            fi

            local diag_label diag_hint
            if [ -n "$diagnosis" ]; then
                diag_label=$(echo "$diagnosis" | cut -d'|' -f1)
                diag_hint=$(echo "$diagnosis" | cut -d'|' -f2)
            fi

            if [ "$mode" = "verbose" ]; then
                alerts+="  🔴 ${RED}${name}${NC} — crash loop (${restarts} restarts)\n"
                if [ -n "$diag_label" ]; then
                    alerts+="     ${YELLOW}Cause:${NC} ${diag_label}\n"
                    alerts+="     ${CYAN}Fix:${NC}   ${diag_hint}\n"
                else
                    alerts+="     ${YELLOW}Cause:${NC} Unknown — check: ${CYAN}pm2 logs ${name} --lines 30${NC}\n"
                fi
                alerts+="\n"
            else
                echo "CRASH_LOOP|${name}|${restarts}|${diag_label:-unknown}"
            fi

            log WARNING "Crash loop detected: $name ($restarts restarts) — ${diag_label:-unknown cause}"

        elif [ "$health" = "unstable" ]; then
            ((unhealthy_count++))

            if [ "$mode" = "verbose" ]; then
                alerts+="  🟠 ${YELLOW}${name}${NC} — unstable (${restarts} restarts, now running)\n"
            else
                echo "UNSTABLE|${name}|${restarts}"
            fi

            log WARNING "Unstable app: $name ($restarts restarts, currently online)"
        fi

    done <<< "$health_data"

    if [ "$mode" = "verbose" ]; then
        if [ "$unhealthy_count" -gt 0 ]; then
            echo -e "${RED}⚠️  Health Issues Detected ($unhealthy_count/$total_count apps):${NC}"
            echo ""
            echo -e "$alerts"
        else
            echo -e "${GREEN}✅ All $total_count app(s) healthy${NC}"
        fi
    fi

    [ "$unhealthy_count" -eq 0 ]
}

# -----------------------------------------------------------------------------
# auto_fix_known_issues - Attempt automatic fixes for common crash causes
#
# Description:
#   For each app in crash loop, checks for known fixable issues:
#   - Stale .next/dev/lock files (Next.js)
#   - Empty content files in Astro collections
#   Prompts before applying fixes.
#
# Arguments:
#   None (scans all PM2 apps)
#
# Returns:
#   0 - Fixes applied or nothing to fix
#   1 - Errors during fix
# -----------------------------------------------------------------------------
auto_fix_known_issues() {
    local health_data
    health_data=$(get_pm2_health_data)
    local fixed=0

    while IFS='|' read -r name status restarts uptime_ms err_log; do
        [ -z "$name" ] && continue

        local health
        health=$(detect_crash_loop "$name" "$restarts" "$uptime_ms" "$status")
        [ "$health" = "healthy" ] && continue

        local cwd
        cwd=$(get_pm2_app_data "$name" "cwd")
        [ -z "$cwd" ] && continue

        # --- Fix 1: Stale Next.js lock file ---
        if [ -f "${cwd}/.next/dev/lock" ]; then
            echo -e "  ${YELLOW}🔧 ${name}:${NC} Stale .next/dev/lock found"
            echo -e "     Removing lock file and restarting..."
            pm2 stop "$name" 2>/dev/null || true
            rm -f "${cwd}/.next/dev/lock"
            pm2 start "$name" 2>/dev/null
            pm2 save 2>/dev/null
            invalidate_pm2_cache
            ((fixed++))
            log INFO "Auto-fix: removed stale .next/dev/lock for $name"
            echo -e "     ${GREEN}✅ Fixed${NC}"
            echo ""
        fi

        # --- Fix 2: Check for empty .md files in Astro content dirs ---
        if [ -d "${cwd}/src/data" ] || [ -d "${cwd}/src/content" ]; then
            local content_dir
            for content_dir in "${cwd}/src/data" "${cwd}/src/content"; do
                [ ! -d "$content_dir" ] && continue
                local empty_files
                empty_files=$(find "$content_dir" -name "*.md" -empty ! -name "_*" 2>/dev/null)
                if [ -n "$empty_files" ]; then
                    echo -e "  ${YELLOW}🔧 ${name}:${NC} Empty .md file(s) in content collection"
                    while IFS= read -r empty_file; do
                        local dir_name base_name new_name
                        dir_name=$(dirname "$empty_file")
                        base_name=$(basename "$empty_file")
                        new_name="${dir_name}/_${base_name}"
                        mv "$empty_file" "$new_name"
                        echo -e "     Renamed: ${base_name} → _${base_name}"
                        log INFO "Auto-fix: renamed empty content file $empty_file → $new_name for $name"
                    done <<< "$empty_files"
                    pm2 restart "$name" 2>/dev/null
                    pm2 save 2>/dev/null
                    invalidate_pm2_cache
                    ((fixed++))
                    echo -e "     ${GREEN}✅ Fixed — restarted $name${NC}"
                    echo ""
                fi
            done
        fi

    done <<< "$health_data"

    if [ "$fixed" -eq 0 ]; then
        echo -e "${YELLOW}No PM2 app auto-fixable issues found.${NC}"
        echo -e "Run ${CYAN}pm2 logs <app> --lines 30${NC} if you expected a PM2 app to be running."
    else
        echo -e "${GREEN}✅ Applied $fixed fix(es). Waiting for apps to stabilize...${NC}"
        sleep 3
        invalidate_pm2_cache
    fi
}

# ============================================================================
# BATCH OPERATIONS
# ============================================================================

# -----------------------------------------------------------------------------
# batch_stop_all - Stop all PM2-managed environments
#
# Description:
#   Iterates all environments and stops each using env_stop().
#
# Returns:
#   0 - Completed (even if some environments failed)
# -----------------------------------------------------------------------------
batch_stop_all() {
    local all_envs=$(list_all_stop_targets)

    if [ -z "$all_envs" ]; then
        echo -e "${YELLOW}No environments or PM2 apps found${NC}"
        return 0
    fi

    local total=$(echo "$all_envs" | wc -l)
    log INFO "Batch stop initiated for $total environment(s)"
    echo -e "${BLUE}Stopping $total environment(s)...${NC}"
    echo ""

    local count=0
    local failed=0
    while IFS= read -r name; do
        ((count++))
        echo -e "${BLUE}[$count/$total] Stopping $name...${NC}"
        if pm2_stop_app_by_name "$name" >/dev/null 2>&1; then
            echo -e "  ${GREEN}✅ $name stopped${NC}"
        else
            echo -e "  ${RED}❌ $name failed to stop${NC}"
            log ERROR "Batch stop failed for $name"
            ((failed++))
        fi
    done <<< "$all_envs"

    pm2 save --force >/dev/null 2>&1
    invalidate_pm2_cache
    sync_caddy_after_pm2_change
    echo ""
    echo -e "${GREEN}Summary: $((count - failed))/$total stopped successfully${NC}"
    log INFO "Batch stop complete: $((count - failed))/$total succeeded, $failed failed"
    if [ $failed -gt 0 ]; then
        echo -e "${RED}$failed environment(s) failed to stop${NC}"
    fi
    return 0
}

# -----------------------------------------------------------------------------
# batch_start_all - Start all PM2-managed environments
#
# Description:
#   Iterates all environments and starts each using env_start().
#   Continues on individual failures.
#
# Returns:
#   0 - Completed (even if some environments failed)
# -----------------------------------------------------------------------------
batch_start_all() {
    local all_envs=$(list_all_environments)

    if [ -z "$all_envs" ]; then
        echo -e "${YELLOW}No environments found${NC}"
        return 0
    fi

    local total=$(echo "$all_envs" | wc -l)
    log INFO "Batch start initiated for $total environment(s)"
    echo -e "${BLUE}Starting $total environment(s)...${NC}"
    echo ""

    local count=0
    local failed=0
    while IFS= read -r name; do
        ((count++))
        echo -e "${BLUE}[$count/$total] Starting $name...${NC}"
        if env_start "$name" >/dev/null 2>&1; then
            local port=$(get_pm2_app_data "$name" "port")
            if [ -n "$port" ]; then
                echo -e "  ${GREEN}✅ $name${NC} ${CYAN}→ :$port${NC}"
            else
                echo -e "  ${GREEN}✅ $name${NC} ${CYAN}→ tunnel (expo logs)${NC}"
            fi
        else
            echo -e "  ${RED}❌ $name failed to start${NC}"
            log ERROR "Batch start failed for $name"
            ((failed++))
        fi
    done <<< "$all_envs"

    invalidate_pm2_cache
    echo ""
    echo -e "${GREEN}Summary: $((count - failed))/$total started successfully${NC}"
    log INFO "Batch start complete: $((count - failed))/$total succeeded, $failed failed"
    if [ $failed -gt 0 ]; then
        echo -e "${RED}$failed environment(s) failed to start${NC}"
    fi
    return 0
}

# -----------------------------------------------------------------------------
# batch_restart_all - Restart all PM2-managed environments
#
# Description:
#   Iterates all environments and restarts each using env_restart().
#
# Returns:
#   0 - Completed (even if some environments failed)
# -----------------------------------------------------------------------------
batch_restart_all() {
    local all_envs=$(list_all_environments)

    if [ -z "$all_envs" ]; then
        echo -e "${YELLOW}No environments found${NC}"
        return 0
    fi

    local total=$(echo "$all_envs" | wc -l)
    log INFO "Batch restart initiated for $total environment(s)"
    echo -e "${BLUE}Restarting $total environment(s)...${NC}"
    echo ""

    local count=0
    local failed=0
    while IFS= read -r name; do
        ((count++))
        echo -e "${BLUE}[$count/$total] Restarting $name...${NC}"
        if env_restart "$name" >/dev/null 2>&1; then
            local port=$(get_pm2_app_data "$name" "port")
            if [ -n "$port" ]; then
                echo -e "  ${GREEN}✅ $name${NC} ${CYAN}→ :$port${NC}"
            else
                echo -e "  ${GREEN}✅ $name${NC} ${CYAN}→ tunnel (expo logs)${NC}"
            fi
        else
            echo -e "  ${RED}❌ $name failed to restart${NC}"
            log ERROR "Batch restart failed for $name"
            ((failed++))
        fi
    done <<< "$all_envs"

    invalidate_pm2_cache
    echo ""
    echo -e "${GREEN}Summary: $((count - failed))/$total restarted successfully${NC}"
    log INFO "Batch restart complete: $((count - failed))/$total succeeded, $failed failed"
    if [ $failed -gt 0 ]; then
        echo -e "${RED}$failed environment(s) failed to restart${NC}"
    fi
    return 0
}

# -----------------------------------------------------------------------------
# show_dashboard - Display comprehensive dashboard with all environments
#
# Description:
#   Shows a unified view combining environment list, ports, status, and URLs.
#   Replaces separate "List environments" and "Show URLs" commands for better UX.
#   Displays local URLs (localhost) and web URLs (DuckDNS) in one view.
#
# Arguments:
#   None
#
# Returns:
#   0 - Success
#   1 - No environments found
#
# Outputs:
#   Formatted dashboard to stdout with environment status, ports, and URLs
#
# Example:
#   show_dashboard
# -----------------------------------------------------------------------------
show_dashboard() {
    ui_screen_header "Environment Dashboard"

    # Get all environments
    local all_envs=$(list_all_environments)

    if [ -z "$all_envs" ]; then
        echo -e "${YELLOW}⚠️  No environments found${NC}"
        echo ""
        echo -e "${BLUE}💡 Tip: Use 'Start/Deploy' to create a new environment${NC}"
        return 1
    fi

    # Pre-fetch health data for restart counts (one PM2 call)
    local health_data=""
    if [ "${SHIPFLOW_HEALTH_CHECK_ENABLED:-true}" = "true" ]; then
        health_data=$(get_pm2_health_data 2>/dev/null)
    fi

    # Display environments with status
    echo -e "${GREEN}📊 Active Environments:${NC}"
    echo ""

    local count=0
    local unhealthy_names=""
    local idle_names=""
    while IFS= read -r name; do
        ((count++))
        local status=$(get_pm2_status "$name")
        local port=$(get_port_from_pm2 "$name")
        local project_dir=$(resolve_project_path "$name")

        # Status indicator
        local status_icon=$(get_status_icon "$status")

        # Check for crash loop via pre-fetched health data
        local restart_tag=""
        if [ -n "$health_data" ]; then
            local app_health_line
            app_health_line=$(echo "$health_data" | grep "^${name}|")
            if [ -n "$app_health_line" ]; then
                local h_restarts h_uptime h_status
                h_restarts=$(echo "$app_health_line" | cut -d'|' -f3)
                h_uptime=$(echo "$app_health_line" | cut -d'|' -f4)
                h_status=$(echo "$app_health_line" | cut -d'|' -f2)
                local health_state
                health_state=$(detect_crash_loop "$name" "$h_restarts" "$h_uptime" "$h_status")
                if [ "$health_state" = "crash_loop" ]; then
                    restart_tag=" ${RED}⚠ CRASH LOOP (${h_restarts}x)${NC}"
                    unhealthy_names+="$name "
                elif [ "$health_state" = "unstable" ]; then
                    restart_tag=" ${YELLOW}⚠ ${h_restarts} restarts${NC}"
                    unhealthy_names+="$name "
                fi
            fi
        fi

        # Compute uptime from pm_uptime (epoch ms when app started)
        local uptime_tag=""
        local uptime_human=""
        local idle_flag=false
        if [ -n "$health_data" ] && [ -n "$app_health_line" ]; then
            local pm_uptime_ms
            pm_uptime_ms=$(echo "$app_health_line" | cut -d'|' -f4)
            if [ -n "$pm_uptime_ms" ] && [ "$pm_uptime_ms" != "0" ] && [ "$status" = "online" ]; then
                local now_ms=$(( $(date +%s) * 1000 ))
                local running_ms=$(( now_ms - pm_uptime_ms ))
                local running_secs=$(( running_ms / 1000 ))
                if [ "$running_secs" -ge 86400 ]; then
                    local days=$(( running_secs / 86400 ))
                    local hours=$(( (running_secs % 86400) / 3600 ))
                    uptime_human="${days}d${hours}h"
                elif [ "$running_secs" -ge 3600 ]; then
                    local hours=$(( running_secs / 3600 ))
                    local mins=$(( (running_secs % 3600) / 60 ))
                    uptime_human="${hours}h${mins}m"
                elif [ "$running_secs" -ge 60 ]; then
                    uptime_human="$(( running_secs / 60 ))m"
                else
                    uptime_human="${running_secs}s"
                fi
                # Flag as idle if running longer than threshold
                local idle_hours="${SHIPFLOW_PROCESS_LONG_RUNNING_HOURS:-24}"
                local idle_secs=$(( idle_hours * 3600 ))
                if [ "$running_secs" -ge "$idle_secs" ]; then
                    idle_flag=true
                fi
            fi
        fi

        # Display environment info
        printf "  %s %-20s" "$status_icon" "$name"

        if [ -n "$port" ]; then
            printf "${BLUE}Port: %-6s${NC}" ":$port"
            printf "${CYAN}http://localhost:$port${NC}"
        else
            printf "${YELLOW}No port${NC}"
        fi

        # Append uptime
        if [ -n "$uptime_human" ]; then
            if [ "$idle_flag" = true ]; then
                printf "  ${YELLOW}⏱ %s${NC}" "$uptime_human"
            else
                printf "  ${GREEN}⏱ %s${NC}" "$uptime_human"
            fi
        fi

        # Append crash loop tag
        if [ -n "$restart_tag" ]; then
            printf "%b" "$restart_tag"
        fi

        echo ""

        if [ "$idle_flag" = true ]; then
            idle_names+="$name "
        fi
    done <<< "$all_envs"

    echo ""
    echo -e "${BLUE}Total: $count environment(s)${NC}"

    # Idle apps — propose stopping directly
    if [ -n "${idle_names:-}" ]; then
        echo ""
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${YELLOW}💤 Long-running apps (${SHIPFLOW_PROCESS_LONG_RUNNING_HOURS:-24}h+):${NC} ${idle_names}"
        echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""

        # Build list for selection
        local idle_arr=()
        for n in $idle_names; do
            idle_arr+=("$n")
        done

        local stop_options=""
        for n in "${idle_arr[@]}"; do
            stop_options+="${n}"$'\n'
        done
        if [ "${#idle_arr[@]}" -gt 1 ]; then
            stop_options+="Stop all idle"$'\n'
        fi
        stop_options+="Skip"

        local stop_choice
        stop_choice=$(echo "$stop_options" | ui_choose "Stop an idle app to free RAM:")

        if [ -n "$stop_choice" ] && [ "$stop_choice" != "Skip" ]; then
            if [ "$stop_choice" = "Stop all idle" ]; then
                if ui_confirm "Stop all idle apps now?"; then
                    for n in "${idle_arr[@]}"; do
                        echo -e "${YELLOW}🛑 Stopping $n...${NC}"
                        env_stop "$n"
                        echo -e "${GREEN}✅ $n stopped${NC}"
                    done
                    log INFO "Dashboard: stopped all idle apps: ${idle_names}"
                else
                    echo -e "${BLUE}Skipped idle app stop.${NC}"
                fi
            else
                if ui_confirm "Stop idle app '$stop_choice' now?"; then
                    echo -e "${YELLOW}🛑 Stopping $stop_choice...${NC}"
                    env_stop "$stop_choice"
                    echo -e "${GREEN}✅ $stop_choice stopped${NC}"
                    log INFO "Dashboard: stopped idle app $stop_choice"
                else
                    echo -e "${BLUE}Skipped idle app stop.${NC}"
                fi
            fi
        fi
    fi

    # Health alert banner
    if [ -n "$unhealthy_names" ]; then
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}⚠️  Unhealthy apps detected!${NC} Run ${CYAN}health check${NC} (${CYAN}h${NC}) for diagnostics & auto-fix."
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    fi

    # Check for web URLs (Caddyfile)
    if [ -f "/etc/caddy/Caddyfile" ]; then
        echo ""
        echo -e "${GREEN}🌐 Web URLs (HTTPS):${NC}"
        echo ""

        # Parse Caddyfile for domains
        local domains=$(grep -E "^[a-zA-Z0-9\-]+\.duckdns\.org" /etc/caddy/Caddyfile 2>/dev/null | sort -u)

        if [ -n "$domains" ]; then
            while IFS= read -r domain; do
                echo -e "  ${CYAN}https://$domain${NC}"
            done <<< "$domains"
        else
            echo -e "  ${YELLOW}No web URLs configured${NC}"
        fi
    fi

    echo ""
    return 0
}

# -----------------------------------------------------------------------------
# env_restart - Restart an environment
#
# Description:
#   Restarts a PM2 environment in one step (stop + start).
#   Faster than manual stop → start workflow.
#   Invalidates PM2 cache to ensure fresh data.
#
# Arguments:
#   $1 - Environment identifier (name or path)
#
# Returns:
#   0 - Successfully restarted
#   1 - Error occurred
#
# Outputs:
#   Status messages to stdout
#
# Side Effects:
#   - Restarts PM2 process
#   - Invalidates PM2 cache
#   - Saves PM2 state
#
# Example:
#   env_restart "my-app"
#   env_restart "/root/my-app"
# -----------------------------------------------------------------------------
env_restart() {
    local identifier=$1

    if [ -z "$identifier" ]; then
        error "Usage: env_restart <environment-name-or-path>"
        return 1
    fi

    # Resolve project directory
    local project_dir=$(resolve_project_path "$identifier")
    if [ -z "$project_dir" ]; then
        error "Environment not found: $identifier"
        return 1
    fi

    local env_name=$(basename "$project_dir")

    echo -e "${BLUE}🔄 Restarting environment: $env_name${NC}"
    log INFO "Restarting environment: $env_name"

    # Check if environment exists in PM2
    local status=$(get_pm2_status "$env_name")

    if [ "$status" = "not_found" ]; then
        warning "Environment $env_name not running in PM2"
        echo -e "${YELLOW}Starting instead...${NC}"
        env_start "$project_dir"
        return $?
    fi

    # Restart PM2 process (atomic operation)
    if pm2 restart "$env_name" >/dev/null 2>&1; then
        pm2 save >/dev/null 2>&1
        invalidate_pm2_cache

        local port=$(get_port_from_pm2 "$env_name")
        success "Environment $env_name restarted successfully"

        if [ -n "$port" ]; then
            echo -e "${GREEN}✅ URL: ${CYAN}http://localhost:$port${NC}"
        fi

        log INFO "Successfully restarted: $env_name"
        return 0
    else
        error "Failed to restart $env_name"
        log ERROR "Failed to restart: $env_name"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# view_environment_logs - Display PM2 logs for an environment
#
# Description:
#   Shows the last 50 lines of PM2 logs for debugging and monitoring.
#   Useful for troubleshooting errors and checking application output.
#
# Arguments:
#   $1 - Environment identifier (name or path)
#   $2 - Number of lines to show (optional, default: 50)
#
# Returns:
#   0 - Successfully displayed logs
#   1 - Error occurred
#
# Outputs:
#   PM2 logs to stdout
#
# Example:
#   view_environment_logs "my-app"
#   view_environment_logs "my-app" 100
# -----------------------------------------------------------------------------
view_environment_logs() {
    local identifier=$1
    local lines=${2:-50}

    if [ -z "$identifier" ]; then
        error "Usage: view_environment_logs <environment-name-or-path> [lines]"
        return 1
    fi

    # Resolve project directory
    local project_dir=$(resolve_project_path "$identifier")
    if [ -z "$project_dir" ]; then
        error "Environment not found: $identifier"
        return 1
    fi

    local env_name=$(basename "$project_dir")

    # Check if environment exists in PM2
    local status=$(get_pm2_status "$env_name")

    if [ "$status" = "not_found" ]; then
        error "Environment $env_name not found in PM2"
        return 1
    fi

    ui_screen_header "Logs: $env_name (last $lines lines)"

    # Display logs
    pm2 logs "$env_name" --lines "$lines" --nostream

    echo ""
    echo -e "${BLUE}💡 Tip: Use Ctrl+C to stop, or 'pm2 logs $env_name' for live tail${NC}"
    echo ""

    return 0
}

# -----------------------------------------------------------------------------
# shipflow_init_project - Initialize ShipFlow tracking files for a project
#
# Description:
#   Creates TASKS.md in shipflow_data/projects/[name]/ and leaves the project
#   directory's TASKS.md untouched. Creates CHANGELOG.md directly in the project dir.
#   Safe to call multiple times — skips files that already exist.
#
# Arguments:
#   $1 - project_name (e.g. "myapp")
#   $2 - project_dir  (e.g. "/root/myapp")
#
# Side Effects:
#   - Creates shipflow_data/projects/[name]/TASKS.md
#   - Removes legacy project TASKS.md symlinks that point into shipflow_data
#   - Creates [project_dir]/CHANGELOG.md (if missing)
#   - Adds entry to shipflow_data/PROJECTS.md (if missing)
# -----------------------------------------------------------------------------
shipflow_init_project() {
    local project_name="$1"
    local project_dir="$2"
    local shipflow_data="${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}"
    local project_data_dir="$shipflow_data/projects/$project_name"
    local project_tasks_file="$project_dir/TASKS.md"

    # Ensure shipflow_data/projects/[name]/ exists
    mkdir -p "$project_data_dir"

    # Create TASKS.md in shipflow_data (if not already there)
    if [ ! -f "$project_data_dir/TASKS.md" ]; then
        cat > "$project_data_dir/TASKS.md" << TASKS_EOF
# Tasks — $project_name

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Setup

| Pri | Task | Status |
|-----|------|--------|
| 🟠 | Review project structure and configure environment | 📋 todo |

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|

---

## Audit Findings
<!-- Populated by /sf-audit — dated sections added automatically -->
TASKS_EOF
        log INFO "Created TASKS.md for $project_name in shipflow_data"
    fi

    if [ -L "$project_tasks_file" ]; then
        local current_tasks_target=""
        current_tasks_target=$(readlink "$project_tasks_file" 2>/dev/null || true)
        case "$current_tasks_target" in
            *"/shipflow_data/projects/"*"/TASKS.md")
            rm -f "$project_tasks_file"
            log INFO "Removed legacy ShipFlow TASKS.md symlink for $project_name: $current_tasks_target"
            ;;
            *)
            log INFO "Left project TASKS.md symlink untouched for $project_name: $current_tasks_target"
            ;;
        esac
    fi

    # Create CHANGELOG.md directly in project dir (lives in git repo)
    if [ ! -f "$project_dir/CHANGELOG.md" ]; then
        local today
        today=$(date +%Y-%m-%d)
        cat > "$project_dir/CHANGELOG.md" << CHANGELOG_EOF
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased] — $today

### Added
- Initial project setup
CHANGELOG_EOF
        log INFO "Created CHANGELOG.md for $project_name"
    fi

    # Register project in shipflow_data/PROJECTS.md (if not already listed)
    local projects_file="$shipflow_data/PROJECTS.md"
    if [ -f "$projects_file" ] && ! grep -q "| $project_name |" "$projects_file"; then
        # Detect basic stack info
        local stack="unknown"
        if [ -f "$project_dir/package.json" ]; then
            stack="Node.js"
            grep -q '"next"' "$project_dir/package.json" 2>/dev/null && stack="Next.js"
            grep -q '"astro"' "$project_dir/package.json" 2>/dev/null && stack="Astro"
            grep -q '"nuxt"' "$project_dir/package.json" 2>/dev/null && stack="Nuxt"
            grep -q '"vite"' "$project_dir/package.json" 2>/dev/null && stack="Vite"
        elif [ -f "$project_dir/requirements.txt" ]; then
            stack="Python"
        elif ls "$project_dir"/*.sh >/dev/null 2>&1; then
            stack="Bash"
        fi
        # Store home-scoped project paths in a portable form so the registry
        # survives username changes across machines.
        local registry_project_dir="$project_dir"
        if [ "$registry_project_dir" = "$HOME" ]; then
            registry_project_dir="~"
        elif [[ "$registry_project_dir" == "$HOME/"* ]]; then
            registry_project_dir="~/${registry_project_dir#$HOME/}"
        fi

        # Append row to Project Registry table
        sed -i "/^| Name | Path | Stack |/,/^$/{/^$/i | $project_name | $registry_project_dir | $stack |
}" "$projects_file" 2>/dev/null || \
            echo "| $project_name | $registry_project_dir | $stack |" >> "$projects_file"
    fi

    # Detect project-scoped MCP integrations from explicit project signals.
    local enable_clerk_mcp=0
    local enable_vercel_mcp=0
    local enable_convex_mcp=0
    local enable_supabase_mcp=0
    if [ -f "$project_dir/package.json" ] && grep -Eq '"@clerk/[^"]+"' "$project_dir/package.json" 2>/dev/null; then
        enable_clerk_mcp=1
    elif grep -RIsE \
        --exclude-dir=node_modules \
        --exclude-dir=.git \
        --exclude-dir=.next \
        --exclude-dir=dist \
        --exclude-dir=build \
        --exclude-dir=.vercel \
        'clerkMiddleware|ClerkProvider|@clerk/' \
        "$project_dir" >/dev/null 2>&1; then
        enable_clerk_mcp=1
    fi
    if [ -f "$project_dir/vercel.json" ] || [ -f "$project_dir/.vercel/project.json" ]; then
        enable_vercel_mcp=1
    elif [ -f "$project_dir/package.json" ] && grep -Eq '"(@vercel/[^"]+|vercel)"' "$project_dir/package.json" 2>/dev/null; then
        enable_vercel_mcp=1
    fi
    if [ -d "$project_dir/convex" ] || [ -f "$project_dir/convex.json" ] || [ -f "$project_dir/convex.config.ts" ] || [ -f "$project_dir/convex.config.js" ]; then
        enable_convex_mcp=1
    elif [ -f "$project_dir/package.json" ] && grep -Eq '"(convex|@convex-dev/[^"]+)"' "$project_dir/package.json" 2>/dev/null; then
        enable_convex_mcp=1
    fi
    if [ -d "$project_dir/supabase" ] || [ -f "$project_dir/supabase/config.toml" ] || [ -f "$project_dir/supabase/.temp/project-ref" ]; then
        enable_supabase_mcp=1
    elif [ -f "$project_dir/package.json" ] && grep -Eq '"(@supabase/[^"]+|supabase)"' "$project_dir/package.json" 2>/dev/null; then
        enable_supabase_mcp=1
    elif grep -RIsE \
        --exclude-dir=node_modules \
        --exclude-dir=.git \
        --exclude-dir=.next \
        --exclude-dir=dist \
        --exclude-dir=build \
        --exclude-dir=.vercel \
        '@supabase/|supabase\.auth|createClient\(' \
        "$project_dir" >/dev/null 2>&1; then
        enable_supabase_mcp=1
    fi

    local clerk_block=""
    local vercel_block=""
    local convex_block=""
    local supabase_block=""
    [ "$enable_clerk_mcp" -eq 1 ] && clerk_block=$',\n    "clerk": {\n      "url": "https://mcp.clerk.com/mcp"\n    }'
    [ "$enable_vercel_mcp" -eq 1 ] && vercel_block=$',\n    "vercel": {\n      "url": "https://mcp.vercel.com"\n    }'
    [ "$enable_convex_mcp" -eq 1 ] && convex_block=$',\n    "convex": {\n      "command": "npx",\n      "args": ["-y", "convex@latest", "mcp", "start"]\n    }'
    [ "$enable_supabase_mcp" -eq 1 ] && supabase_block=$',\n    "supabase": {\n      "url": "https://mcp.supabase.com/mcp"\n    }'

    # Configure codebase-mcp, Context7, and detected project MCPs using the current ShipFlow checkout.
    local shipflow_root
    shipflow_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local mcp_server="$shipflow_root/tools/codebase-mcp/server.py"
    if [ -f "$mcp_server" ]; then
        local claude_dir="$project_dir/.claude"
        local settings_file="$claude_dir/settings.json"
        mkdir -p "$claude_dir"
        if [ ! -f "$settings_file" ]; then
            cat > "$settings_file" << MCP_EOF
{
  "mcpServers": {
    "codebase": {
      "command": "python3",
      "args": ["$mcp_server", "$project_dir"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }${clerk_block}${vercel_block}${convex_block}${supabase_block}
  },
  "disabledMcpServers": ["codebase"]
}
MCP_EOF
            log INFO "Configured project MCPs for $project_name"
        elif ! grep -q "codebase-mcp" "$settings_file"; then
            # settings.json exists but no codebase entry — merge it
            local tmp_file
            tmp_file=$(mktemp)
            python3 -c "
import json, sys
with open('$settings_file') as f:
    cfg = json.load(f)
cfg.setdefault('mcpServers', {})['codebase'] = {
    'command': 'python3',
    'args': ['$mcp_server', '$project_dir']
}
disabled = cfg.setdefault('disabledMcpServers', [])
if 'codebase' not in disabled:
    disabled.append('codebase')
print(json.dumps(cfg, indent=2))
" > "$tmp_file" && mv "$tmp_file" "$settings_file"
            log INFO "Merged codebase-mcp into existing settings.json for $project_name"
        fi
        if ! grep -q '"context7"' "$settings_file"; then
            local tmp_file
            tmp_file=$(mktemp)
            python3 -c "
import json, sys
with open('$settings_file') as f:
    cfg = json.load(f)
cfg.setdefault('mcpServers', {})['context7'] = {
    'command': 'npx',
    'args': ['-y', '@upstash/context7-mcp@latest']
}
print(json.dumps(cfg, indent=2))
" > "$tmp_file" && mv "$tmp_file" "$settings_file"
            log INFO "Merged Context7 MCP into existing settings.json for $project_name"
        fi
        if [ "$enable_clerk_mcp" -eq 1 ] && ! grep -q '"clerk"' "$settings_file"; then
            local tmp_file
            tmp_file=$(mktemp)
            python3 -c "
import json, sys
with open('$settings_file') as f:
    cfg = json.load(f)
cfg.setdefault('mcpServers', {})['clerk'] = {
    'url': 'https://mcp.clerk.com/mcp'
}
print(json.dumps(cfg, indent=2))
" > "$tmp_file" && mv "$tmp_file" "$settings_file"
            log INFO "Merged Clerk MCP into existing settings.json for $project_name"
        fi
        if [ "$enable_vercel_mcp" -eq 1 ] && ! grep -q '"vercel"' "$settings_file"; then
            local tmp_file
            tmp_file=$(mktemp)
            python3 -c "
import json, sys
with open('$settings_file') as f:
    cfg = json.load(f)
cfg.setdefault('mcpServers', {})['vercel'] = {
    'url': 'https://mcp.vercel.com'
}
print(json.dumps(cfg, indent=2))
" > "$tmp_file" && mv "$tmp_file" "$settings_file"
            log INFO "Merged Vercel MCP into existing settings.json for $project_name"
        fi
        if [ "$enable_convex_mcp" -eq 1 ] && ! grep -q '"convex"' "$settings_file"; then
            local tmp_file
            tmp_file=$(mktemp)
            python3 -c "
import json, sys
with open('$settings_file') as f:
    cfg = json.load(f)
cfg.setdefault('mcpServers', {})['convex'] = {
    'command': 'npx',
    'args': ['-y', 'convex@latest', 'mcp', 'start']
}
print(json.dumps(cfg, indent=2))
" > "$tmp_file" && mv "$tmp_file" "$settings_file"
            log INFO "Merged Convex MCP into existing settings.json for $project_name"
        fi
        if [ "$enable_supabase_mcp" -eq 1 ] && ! grep -q '"supabase"' "$settings_file"; then
            local tmp_file
            tmp_file=$(mktemp)
            python3 -c "
import json, sys
with open('$settings_file') as f:
    cfg = json.load(f)
cfg.setdefault('mcpServers', {})['supabase'] = {
    'url': 'https://mcp.supabase.com/mcp'
}
print(json.dumps(cfg, indent=2))
" > "$tmp_file" && mv "$tmp_file" "$settings_file"
            log INFO "Merged Supabase MCP into existing settings.json for $project_name"
        fi
    fi

    echo -e "${GREEN}📋 ShipFlow tracking initialized for $project_name${NC}"
}

# -----------------------------------------------------------------------------
# deploy_github_project - Deploy a project from GitHub repository
#
# Description:
#   Complete workflow to deploy a GitHub repository:
#   - Creates project directory
#   - Clones repository from GitHub
#   - Initializes Flox environment
#   - Starts the application with PM2
#   - Handles existing projects (asks to replace)
#
# Arguments:
#   $1 - Repository name (e.g., "my-repo")
#
# Returns:
#   0 - Successfully deployed
#   1 - Error occurred
#
# Outputs:
#   Progress messages and final URLs to stdout
#
# Side Effects:
#   - Creates directory in PROJECTS_DIR
#   - Clones git repository
#   - Initializes Flox environment
#   - Starts PM2 process
#
# Example:
#   deploy_github_project "my-awesome-app"
# -----------------------------------------------------------------------------
deploy_github_project() {
    local repo_name=$1

    if [ -z "$repo_name" ]; then
        error "Usage: deploy_github_project <repo-name>"
        return 1
    fi

    # Validate repo name
    if ! validate_repo_name "$repo_name"; then
        error "Invalid repository name: $repo_name"
        return 1
    fi

    echo ""
    echo -e "${GREEN}📦 Repository: $repo_name${NC}"
    echo -e "${BLUE}🚀 Starting deployment...${NC}"
    echo ""

    # Project setup
    local project_name="${repo_name,,}"  # lowercase
    local project_dir="$PROJECTS_DIR/$project_name"

    # Check if project already exists
    local existing_project=$(resolve_project_path "$project_name")
    if [ -n "$existing_project" ]; then
        echo -e "${YELLOW}⚠️  Project $project_name already exists at $existing_project${NC}"
        if ! ui_confirm "Replace it?"; then
            echo -e "${BLUE}❌ Cancelled${NC}"
            return 1
        fi

        # Remove old project
        echo -e "${YELLOW}Removing old project...${NC}"
        env_remove "$project_name"
    fi

    # Create project directory
    echo -e "${YELLOW}Creating project directory: $project_dir${NC}"
    mkdir -p "$project_dir"

    # Clone repository
    local github_user=$(get_github_username)
    if [ -z "$github_user" ]; then
        error "Could not determine GitHub username"
        rm -rf "$project_dir"
        return 1
    fi

    local repo_url="git@github.com:$github_user/$repo_name.git"
    echo -e "${YELLOW}Cloning (SSH): $repo_url${NC}"
    echo ""

    if git clone "$repo_url" "$project_dir"; then
        echo ""
        echo -e "${GREEN}✅ Repository cloned successfully${NC}"
    else
        echo ""
        log ERROR "Failed to clone repository: $repo_url"
        echo -e "${RED}❌ Failed to clone repository${NC}"
        echo -e "${YELLOW}Please check:${NC}"
        echo -e "  • Repository exists: https://github.com/$github_user/$repo_name"
        echo -e "  • SSH key is configured: ssh -T git@github.com"
        echo -e "  • Or use: gh auth login --with-token"
        rm -rf "$project_dir"
        return 1
    fi

    # Initialize Flox environment
    echo ""
    echo -e "${YELLOW}🔧 Initializing Flox environment...${NC}"
    if ! init_flox_env "$project_dir" "$project_name"; then
        log ERROR "Flox initialization failed for $project_name at $project_dir"
        echo -e "${RED}❌ Flox initialization failed${NC}"
        echo -e "${YELLOW}Cleanup: Removing project directory${NC}"
        rm -rf "$project_dir"
        return 1
    fi

    # Start the environment
    echo ""
    echo -e "${GREEN}🚀 Starting application...${NC}"
    if ! env_start "$project_name"; then
        log ERROR "Failed to start application after deploy: $project_name"
        echo -e "${RED}❌ Failed to start application${NC}"
        echo -e "${YELLOW}Project cloned but not started. Try manually:${NC}"
        echo -e "  cd $project_dir"
        echo -e "  flox activate"
        return 1
    fi

    # Initialize ShipFlow tracking (TASKS.md + CHANGELOG.md)
    shipflow_init_project "$project_name" "$project_dir"

    # Get port and display success
    local port=$(get_port_from_pm2 "$project_name")

    echo ""
    ui_screen_header "Deployment Successful!" success
    echo -e "${BLUE}📊 Project Information:${NC}"
    echo -e "  • Name: $project_name"
    echo -e "  • Directory: $project_dir"

    if [ -n "$port" ]; then
        echo -e "  • Port: $port"
        echo ""
        echo -e "${BLUE}🌐 Access URLs:${NC}"
        echo -e "  • Local: ${CYAN}http://localhost:$port${NC}"
    else
        echo ""
        echo -e "${BLUE}📱 Projet mobile (Expo)${NC}"
        echo -e "  • URL tunnel: ${CYAN}pm2 logs $project_name --lines 30${NC}"
        echo -e "  • Installe l'APK dev build sur ton téléphone, puis scan le QR"
    fi

    echo ""
    echo -e "${YELLOW}📝 Next steps:${NC}"
    echo -e "  • View logs: Option 7 → View Logs → Select '$project_name'"
    echo -e "  • Edit code: cd $project_dir"
    if [ -z "$port" ]; then
        echo -e "  • APK build (1 seule fois): eas build --profile development --platform android"
    else
        echo -e "  • Publish web: Option 6 (Publish to Web)"
    fi
    echo ""

    log INFO "Successfully deployed GitHub project: $repo_name"
    return 0
}

# ============================================================================
# HEADER & STATUS DISPLAY
# ============================================================================

print_header() {
    read_menu_status_cache >/dev/null 2>&1 || true
    refresh_menu_status_cache_async_if_stale

    local status_left="FREE Disk: ..."
    local status_right="Up: ..."
    local free_human="${MENU_STATUS_FREE_HUMAN:-}"
    local mem_human="${MENU_STATUS_MEM_HUMAN:-}"

    # Disk and RAM probes are cheap, so fall back to live values on first paint
    # instead of showing placeholders while the async cache warms up.
    if [ -z "$free_human" ]; then
        free_human=$(disk_free_human 2>/dev/null || true)
    fi
    if [ -z "$mem_human" ]; then
        mem_human=$(mem_available_human 2>/dev/null || true)
    fi

    if [ -n "$free_human" ]; then
        status_left="FREE Disk: $(header_storage_human "$free_human")"
        if [ -n "$mem_human" ] && [ "$mem_human" != "?" ]; then
            status_left="${status_left} | FREE RAM: $(header_storage_human "$mem_human")"
        fi
    elif [ -n "$mem_human" ] && [ "$mem_human" != "?" ]; then
        status_left="FREE RAM: $(header_storage_human "$mem_human")"
    fi
    if [ -n "$MENU_STATUS_UPDATES_TOTAL" ]; then
        status_right="Up: $MENU_STATUS_UPDATES_TOTAL"
    fi

    local session_header_block=""
    if [ "$SHIPFLOW_SESSION_ENABLED" = "true" ]; then
        init_session 2>/dev/null
        session_header_block=$(session_banner_header_block 2>/dev/null || true)
    fi

    ui_header "Shipflow DevServer" "" "$status_left" "$status_right" "$session_header_block"

    if [ "${MENU_STATUS_LOW_SPACE:-0}" = "1" ]; then
        local header_used_pct
        header_used_pct=$(disk_used_pct 2>/dev/null || true)
        local header_free_human="${free_human:-}"
        if [ -z "$header_free_human" ]; then
            header_free_human=$(disk_free_human 2>/dev/null || true)
        fi
        local header_level
        header_level=$(disk_pressure_level "" "$header_used_pct" 2>/dev/null || echo "warning")
        print_disk_pressure_warning "$header_level" "$header_free_human" "$header_used_pct"
    fi
    if [ "${MENU_STATUS_LOW_MEM:-0}" = "1" ]; then
        echo -e "${RED}⚠️  Low memory (RAM). Press h) Health Check.${NC}"
    fi

    local long_count
    long_count=$(mem_long_running_processes 2>/dev/null | wc -l)
    if [ "${long_count:-0}" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  ${long_count} process(es) running ${SHIPFLOW_PROCESS_LONG_RUNNING_HOURS:-24}h+ — press h) Health Check${NC}"
    fi

    echo ""
}

# ============================================================================
# ACTION HANDLERS — Main Menu
# ============================================================================

action_dashboard() { show_dashboard; }
action_shipflow_overview() { show_shipflow_menu; }

action_deploy() {
    ui_screen_header "Deploy Environment"

    local deploy_choice
    deploy_choice=$(printf '%s\n' \
        "🔍 Auto-detect project in $PROJECTS_DIR" \
        "📁 Custom local path" \
        "🚀 Deploy from GitHub" \
        "Cancel" | ui_choose "Choose source:") || {
        ui_return_back
        return 0
    }

    if ui_is_back_selection "$deploy_choice"; then
        ui_return_back
        return 0
    fi

    case "$deploy_choice" in
        *Auto-detect*)
            echo -e "${BLUE}🔍 Scanning $PROJECTS_DIR for projects...${NC}"

            EXISTING_ENVS=$(find "$PROJECTS_DIR" -maxdepth 4 \
                \( -name "node_modules" -o -name ".git" -o -name "venv" -o -name ".venv" \
                   -o -name "__pycache__" -o -name "target" -o -name ".next" -o -name ".nuxt" \
                   -o -name "dist" -o -name ".cache" -o -name ".pnpm" -o -name ".yarn" \) -prune \
                -o -type d -name ".flox" -print 2>/dev/null | while read -r flox_dir; do
                proj_dir=$(dirname "$flox_dir")
                case "$proj_dir" in
                    "$PROJECTS_DIR"/.*) continue ;;
                    *) echo "$proj_dir" ;;
                esac
            done | sort -u)

            NEW_PROJECTS=$(find "$PROJECTS_DIR" -maxdepth 4 \
                \( -name "node_modules" -o -name ".git" -o -name "venv" -o -name ".venv" \
                   -o -name "__pycache__" -o -name "target" -o -name ".next" -o -name ".nuxt" \
                   -o -name "dist" -o -name ".cache" -o -name ".pnpm" -o -name ".yarn" \) -prune \
                -o -type f \( -name "package.json" -o -name "requirements.txt" -o -name "Cargo.toml" -o -name "go.mod" -o -name "pubspec.yaml" \) -print 2>/dev/null | while read -r manifest; do
                proj_dir=$(dirname "$manifest")
                case "$proj_dir" in
                    "$PROJECTS_DIR"/.*) continue ;;
                esac
                if [ ! -d "$proj_dir/.flox" ]; then
                    echo "$proj_dir"
                fi
            done | sort -u)

            PROJECTS=$(printf "%s\n%s" "$EXISTING_ENVS" "$NEW_PROJECTS" | grep -v "^$" | sort -u)

            if [ -z "$PROJECTS" ]; then
                echo -e "${YELLOW}⚠️  No projects detected${NC}"
                echo -e "${BLUE}💡 Tip: Use Custom path or Deploy from GitHub${NC}"
            else
                SELECTED_PROJECT=$(echo "$PROJECTS" | ui_choose "Detected projects:")
                if [ -n "$SELECTED_PROJECT" ]; then
                    log INFO "Menu: starting project $SELECTED_PROJECT"
                    echo -e "${GREEN}✅ Starting: $SELECTED_PROJECT${NC}"
                    env_start "$SELECTED_PROJECT"
                fi
            fi
            ;;
        *Custom*)
            CUSTOM_PATH=$(ui_input "Path (absolute):" "$PROJECTS_DIR/my-project")
            if [ -z "$CUSTOM_PATH" ]; then
                echo -e "${RED}❌ Path required${NC}"
            elif ! validate_project_path "$CUSTOM_PATH"; then
                echo -e "${RED}❌ Invalid or unsafe path${NC}"
            else
                env_start "$CUSTOM_PATH"
            fi
            ;;
        *GitHub*)
            ui_screen_header "Deploy from GitHub"
            echo -e "${BLUE}🔍 Fetching your GitHub repos...${NC}"
            echo ""
            GITHUB_REPOS=$(list_github_repos)
            if [ -z "$GITHUB_REPOS" ]; then
                echo -e "${YELLOW}All your GitHub repos are already deployed (or no repos found).${NC}"
                return
            fi
            local selected_repo_line
            selected_repo_line=$(echo "$GITHUB_REPOS" | ui_filter_choose "Search GitHub repo")
            SELECTED_REPO="${selected_repo_line%%:*}"
            if [ -n "$SELECTED_REPO" ]; then
                if ! validate_repo_name "$SELECTED_REPO"; then
                    echo -e "${RED}❌ Invalid repository name${NC}"
                    return
                fi
                echo ""
                echo -e "${GREEN}📦 Selected repo: $SELECTED_REPO${NC}"
                echo -e "${BLUE}🚀 Deploying...${NC}"
                echo ""
                deploy_github_project "$SELECTED_REPO"
            fi
            ;;
        *)
            ui_return_back
            return 0
            ;;
    esac
}

action_restart() {
    ui_screen_header "Restart Environment"
    ENV_NAME=$(select_environment "Select environment to restart")
    if [ -n "$ENV_NAME" ]; then
        log INFO "Menu: restarting $ENV_NAME"
        env_restart "$ENV_NAME"
    fi
}

action_stop() {
    ui_screen_header "Stop Environment"
    ENV_NAME=$(select_stop_target "Select environment to stop")
    if [ -n "$ENV_NAME" ]; then
        log INFO "Menu: stopping $ENV_NAME"
        echo -e "${YELLOW}🛑 Stopping $ENV_NAME...${NC}"
        env_stop "$ENV_NAME"
        echo -e "${GREEN}✅ Environment $ENV_NAME stopped!${NC}"
    fi
}

action_remove() {
    ui_screen_header "Remove Environment" danger
    echo -e "${YELLOW}⚠️  WARNING: This will permanently delete the project!${NC}"
    echo ""
    ENV_NAME=$(select_environment "Select environment to remove")
    if [ -n "$ENV_NAME" ]; then
        PROJECT_DIR=$(resolve_project_path "$ENV_NAME")
        echo ""
        echo -e "${RED}⚠️  You are about to delete:${NC}"
        echo -e "${YELLOW}   Environment: $ENV_NAME${NC}"
        echo -e "${YELLOW}   Directory: $PROJECT_DIR${NC}"
        echo ""
        if ui_confirm "Confirm deletion?"; then
            log INFO "Menu: removing environment $ENV_NAME (dir: $PROJECT_DIR)"
            env_remove "$ENV_NAME"
            echo -e "${GREEN}✅ Environment removed!${NC}"
        else
            echo -e "${BLUE}Cancelled - nothing was deleted${NC}"
        fi
    fi
}

action_rename() {
    ui_screen_header "Rename Environment"
    ENV_NAME=$(select_environment "Select environment to rename")
    if [ -n "$ENV_NAME" ]; then
        PROJECT_DIR=$(resolve_project_path "$ENV_NAME")
        echo ""
        echo -e "${BLUE}   Current name: $ENV_NAME${NC}"
        echo -e "${BLUE}   Directory: $PROJECT_DIR${NC}"
        echo ""
        echo -e "${YELLOW}Enter new name:${NC}"
        local new_name
        new_name=$(ui_input "New name" "$ENV_NAME")
        if [ -n "$new_name" ]; then
            new_name="${new_name,,}"
            if ui_confirm "Rename '$ENV_NAME' → '$new_name'?"; then
                log INFO "Menu: renaming environment $ENV_NAME -> $new_name"
                env_rename "$ENV_NAME" "$new_name"
            else
                echo -e "${BLUE}Cancelled${NC}"
            fi
        fi
    fi
}

action_start_all() { ui_screen_header "Start All Environments"; batch_start_all; }
action_stop_all() { ui_screen_header "Stop All Environments"; batch_stop_all; }
action_restart_all() { ui_screen_header "Restart All Environments"; batch_restart_all; }
action_mobile() { show_mobile_guide; }

action_flutter_web() {
    ui_screen_header "Flutter Web Dev"
    local choice
    echo -e "  ${CYAN}s)${NC} Start session"
    echo -e "  ${CYAN}l)${NC} Hot Reload"
    echo -e "  ${CYAN}r)${NC} Hot Restart"
    echo -e "  ${CYAN}a)${NC} Attach terminal"
    echo -e "  ${CYAN}t)${NC} Stop session"
    echo -e "  ${CYAN}v)${NC} Show sessions"
    echo ""
    echo -e "  ${CYAN}x)${NC} Back"
    echo ""
    echo -e "${YELLOW}Choose:${NC} \c"
    ui_read_choice choice

    if [ -z "$choice" ] || ui_is_back_choice "$choice"; then
        ui_return_back
        return 0
    fi

    case "$choice" in
        s)
            local project_dir
            project_dir=$(select_flutter_web_project) || return 1
            start_flutter_web_tmux_session "$project_dir"
            ;;
        l)
            send_flutter_web_key "r" "Hot reload"
            ;;
        r)
            send_flutter_web_key "R" "Hot restart"
            ;;
        a)
            attach_flutter_web_session
            ;;
        t)
            stop_flutter_web_session
            ;;
        v)
            show_flutter_web_sessions
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
}

action_health() {
    ui_screen_header "Health Check"
    system_monitor_menu
    echo ""
    echo -e "${BLUE}━━━ App Health (PM2) ━━━${NC}"
    health_check_all verbose
    echo ""
    ui_flush_pending_input
    echo -e "${BLUE}Options:${NC}"
    echo -e "  ${CYAN}r)${NC} Refresh current processes"
    echo -e "  ${CYAN}v)${NC} Disk details (largest files/directories)"
    echo -e "  ${CYAN}d)${NC} Disk cleanup (files: agent histories/caches/package caches)"
    echo -e "  ${CYAN}s)${NC} Safe process cleanup (RAM/processes only)"
    echo -e "  ${CYAN}m)${NC} MCP process cleanup (local servers)"
    echo -e "  ${CYAN}p)${NC} Stop empty PM2 daemon"
    echo -e "  ${CYAN}c)${NC} Stop all Caddy if no PM2 apps"
    echo -e "  ${CYAN}a)${NC} Auto-fix PM2 app issues"
    echo -e "  ${CYAN}g)${NC} Aggressive process cleanup"
    echo ""
    echo -e "  ${CYAN}x)${NC} Back"
    echo ""
    echo -e "${YELLOW}Choose:${NC} \c"

    local health_choice
    ui_read_choice health_choice

    if [ -z "$health_choice" ] || ui_is_back_choice "$health_choice"; then
        ui_return_back
        return 0
    fi

    case "$health_choice" in
        r)
            ui_skip_next_pause
            return 0
            ;;
        v)
            clear
            disk_usage_details_menu
            ;;
        g)
            clear
            aggressive_cleanup_menu
            ;;
        d)
            clear
            disk_cleanup_menu
            refresh_menu_status_cache_sync >/dev/null 2>&1 || true
            ;;
        s)
            clear
            clean_all_safe_targets
            ;;
        m)
            clear
            mcp_cleanup_menu
            ;;
        p)
            clear
            ui_screen_header "Stop Empty PM2 Daemon"
            stop_empty_pm2_daemon
            ;;
        c)
            clear
            ui_screen_header "Stop Caddy"
            stop_all_caddy_if_no_pm2_apps
            ;;
        a)
            clear
            ui_screen_header "Auto-fix PM2 App Issues"
            auto_fix_known_issues
            echo ""
            echo -e "${BLUE}Updated health status:${NC}"
            echo ""
            health_check_all verbose
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            ;;
    esac
}

action_reboot_vm() {
    ui_screen_header "Reboot VM" danger
    echo -e "${YELLOW}Cette action redémarre toute la machine.${NC}"
    echo -e "${YELLOW}Elle coupera les sessions SSH, tmux, Codex, PM2, Caddy et tous les process utilisateur.${NC}"
    echo ""

    if ! ui_confirm "Reboot this VM now?"; then
        echo -e "${BLUE}Cancelled - VM not rebooted.${NC}"
        return 0
    fi

    log WARNING "VM reboot requested from ShipFlow menu"
    if [ "${SHIPFLOW_REBOOT_DRY_RUN:-0}" = "1" ]; then
        if [ "$(id -u)" -eq 0 ]; then
            echo "systemctl reboot"
        else
            echo "sudo systemctl reboot"
        fi
        return 0
    fi

    echo -e "${RED}Rebooting now...${NC}"
    if [ "$(id -u)" -eq 0 ]; then
        systemctl reboot
    else
        sudo systemctl reboot
    fi
}

action_exit() { echo -e "${GREEN}👋 Goodbye!${NC}"; exit 0; }

# ============================================================================
# ACTION HANDLERS — Grouped Menus
# ============================================================================

action_view_logs() {
    ui_screen_header "View Application Logs"
    ENV_NAME=$(select_environment "Select environment to view logs")
    if [ -n "$ENV_NAME" ]; then view_environment_logs "$ENV_NAME"; fi
}

action_navigate() {
    ui_screen_header "Navigate Projects"
    local HOME_DIR
    HOME_DIR=$(eval echo "~")
    local FOLDERS
    FOLDERS=$(find "$HOME_DIR" -maxdepth 1 -type d ! -name ".*" ! -path "$HOME_DIR" 2>/dev/null | sort)
    if [ -z "$FOLDERS" ]; then
        echo -e "${RED}❌ No folders found in $HOME_DIR${NC}"
    else
        local SELECTED
        SELECTED=$(echo "$FOLDERS" | ui_choose "Select folder to open:")
        if [ -n "$SELECTED" ]; then
            echo -e "${GREEN}📁 Opening: $SELECTED${NC}"
            cd "$SELECTED" && exec $SHELL
        fi
    fi
}

action_open_code() {
    ui_screen_header "Open Code Directory"
    local HOME_DIR
    HOME_DIR=$(eval echo "~")
    local FOLDERS
    FOLDERS=$(find "$HOME_DIR" -maxdepth 1 -type d ! -name ".*" ! -path "$HOME_DIR" 2>/dev/null | sort)
    if [ -z "$FOLDERS" ]; then
        echo -e "${RED}❌ No folders found in $HOME_DIR${NC}"
    else
        local SELECTED
        SELECTED=$(echo "$FOLDERS" | ui_choose "Select folder to open:")
        if [ -n "$SELECTED" ]; then
            echo -e "${GREEN}📂 Opening: $SELECTED${NC}"
            cd "$SELECTED" && exec $SHELL
        fi
    fi
}

action_inspector() {
    ui_screen_header "Toggle Web Inspector"
    ENV_NAME=$(select_environment "Select environment for web inspector")
    if [ -n "$ENV_NAME" ]; then
        PROJECT_DIR=$(resolve_project_path "$ENV_NAME")
        if [ -z "$PROJECT_DIR" ]; then
            echo -e "${RED}❌ Project not found: $ENV_NAME${NC}"
        else
            log INFO "Menu: toggling web inspector for $ENV_NAME ($PROJECT_DIR)"
            toggle_web_inspector "$PROJECT_DIR"
            env_restart "$ENV_NAME"
        fi
    fi
}

action_session() {
    ui_screen_header "Session Identity Management"
    display_session_banner
    echo ""
    get_session_info
    echo ""
    local session_choice
    session_choice=$(printf '%s\n' "Reset Session Identity" "Back" | ui_choose "Options:") || {
        ui_return_back
        return 0
    }
    if ui_is_back_selection "$session_choice"; then
        ui_return_back
        return 0
    fi
    if [ "$session_choice" = "Reset Session Identity" ]; then
        reset_session
        echo ""
        echo -e "${GREEN}New session identity:${NC}"
        display_session_banner
    fi
}

action_local_connection_info() {
    ui_screen_header "Local Connection Setup"
    echo -e "${BLUE}This screen gives the address to enter in the local ShipFlow menu.${NC}"
    echo -e "${YELLOW}On your local machine: open 'urls', press 'c', then enter this server address.${NC}"
    echo ""

    local public_ip
    public_ip=$(curl -4 -s --max-time 5 https://ip.me 2>/dev/null || true)
    if [[ "$public_ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        echo -e "  ${BLUE}Server IP:${NC}   ${GREEN}$public_ip${NC}"
    else
        echo -e "  ${BLUE}Server IP:${NC}   ${YELLOW}not detected automatically${NC}"
    fi

    echo -e "  ${BLUE}SSH user:${NC}    ${GREEN}$(whoami)${NC}"
    echo -e "  ${BLUE}SSH target:${NC}  ${GREEN}$(whoami)@${public_ip:-SERVER_IP}${NC}"
    echo ""
    echo -e "${YELLOW}The server does not need your local IP for tunnels.${NC}"
    echo -e "${YELLOW}Your local machine initiates SSH to this server, then ShipFlow opens tunnels from there.${NC}"
}

action_mcp_auth_setup() {
    ui_screen_header "MCP Auth Setup"
    echo -e "${BLUE}Run MCP OAuth from your local machine, not from this remote server.${NC}"
    echo -e "${YELLOW}Your browser receives a localhost callback, so the local ShipFlow helper must create the temporary SSH tunnel.${NC}"
    echo ""

    echo -e "${CYAN}1. Install the local ShipFlow scripts on your local machine:${NC}"
    echo -e "   ${GREEN}git clone <shipflow-repo-url> ~/shipflow${NC}"
    echo -e "   ${GREEN}cd ~/shipflow/local${NC}"
    echo -e "   ${GREEN}./install.sh${NC}"
    echo ""
    echo -e "${BLUE}   macOS/Linux/WSL:${NC} use ${GREEN}./install.sh${NC}"
    echo -e "${BLUE}   Windows PowerShell:${NC} use ${GREEN}.\\install_local.ps1${NC}"
    echo ""

    echo -e "${CYAN}2. Configure this server from your local machine:${NC}"
    echo -e "   ${GREEN}source ~/.bashrc${NC}  ${YELLOW}# or restart your terminal${NC}"
    echo -e "   ${GREEN}urls${NC}"
    echo -e "   ${YELLOW}Choose:${NC} c) Configure new server"
    echo -e "   ${YELLOW}Enter:${NC} user@server-ip, plus your SSH key path if needed"
    echo ""
    echo -e "${BLUE}Need this server address?${NC} In this remote ShipFlow menu, use:"
    echo -e "   ${GREEN}c) Local Setup - Show server address for tunnels${NC}"
    echo ""

    echo -e "${CYAN}3. Run the MCP login command on your local machine:${NC}"
    echo -e "   ${GREEN}shipflow-mcp-login vercel${NC}"
    echo -e "   ${GREEN}shipflow-mcp-login supabase${NC}"
    echo -e "   ${GREEN}shipflow-mcp-login all${NC}"
    echo ""
    echo -e "${YELLOW}If Codex says the provider is missing on the remote server, add it there first:${NC}"
    echo -e "   ${GREEN}codex mcp add vercel --url https://mcp.vercel.com${NC}"
    echo -e "   ${GREEN}codex mcp add supabase --url https://mcp.supabase.com/mcp${NC}"
    echo ""
    echo -e "${BLUE}ShipFlow does not read or store OAuth tokens; Codex and the provider own the token exchange.${NC}"
}

CODEX_MCP_DEFINITIONS=(
    "openaiDeveloperDocs|OpenAI Docs - official API docs"
    "context7|Context7 - library docs"
    "playwright|Playwright - browser"
    "convex|Convex - backend"
    "supabase|Supabase - database/auth/storage"
    "vercel|Vercel - deploys/logs"
    "vercel-gocharbon|Vercel GoCharbon - project deploys/logs"
    "clerk|Clerk - auth docs"
    "dataforseo|DataForSEO - SEO data"
)

codex_mcp_known_names() {
    local definition
    for definition in "${CODEX_MCP_DEFINITIONS[@]}"; do
        printf '%s\n' "${definition%%|*}"
    done
}

codex_mcp_label_for_name() {
    local name="$1"
    local definition
    for definition in "${CODEX_MCP_DEFINITIONS[@]}"; do
        if [ "${definition%%|*}" = "$name" ]; then
            printf '%s' "${definition#*|}"
            return 0
        fi
    done
    printf '%s' "$name"
}

codex_mcp_name_for_label() {
    local label="$1"
    local definition
    for definition in "${CODEX_MCP_DEFINITIONS[@]}"; do
        if [ "${definition#*|}" = "$label" ]; then
            printf '%s' "${definition%%|*}"
            return 0
        fi
    done
    return 1
}

codex_mcp_is_valid_name() {
    [[ "${1:-}" =~ ^[A-Za-z0-9_.-]+$ ]]
}

codex_mcp_contains() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [ "$item" = "$needle" ] && return 0
    done
    return 1
}

codex_configured_mcp_names() {
    local config_file="${CODEX_HOME:-$HOME/.codex}/config.toml"
    [ -f "$config_file" ] || return 0

    awk '
        match($0, /^\[mcp_servers\.([A-Za-z0-9_-]+)\][[:space:]]*$/, m) {
            print m[1]
        }
    ' "$config_file" | sort -u
}

codex_mcp_selection_summary() {
    if [ "$#" -eq 0 ]; then
        printf 'aucun MCP'
        return 0
    fi

    local first=true
    local name
    for name in "$@"; do
        if [ "$first" = true ]; then
            first=false
        else
            printf ', '
        fi
        printf '%s' "$name"
    done
}

codex_select_workspace() {
    local current_label="Current directory: $PWD"
    local home_label="Home: $HOME"
    local choose_label="Choose a project folder"
    local selected

    selected=$(printf '%s\n' "$current_label" "$choose_label" "$home_label" "Back" | ui_choose "Codex workspace:") || return 1
    if ui_is_back_selection "$selected"; then
        ui_return_back
        return 1
    fi

    case "$selected" in
        "$current_label")
            printf '%s\n' "$PWD"
            ;;
        "$home_label")
            printf '%s\n' "$HOME"
            ;;
        "$choose_label")
            local folders=()
            local folder
            while IFS= read -r folder; do
                folders+=("$folder")
            done < <(find "$HOME" -maxdepth 1 -type d ! -name ".*" ! -path "$HOME" 2>/dev/null | sort)

            if [ ${#folders[@]} -eq 0 ]; then
                echo -e "${RED}❌ No project folders found in $HOME${NC}" >&2
                return 1
            fi

            selected=$(printf '%s\n' "${folders[@]}" "Back" | ui_choose "Choose workspace folder:") || return 1
            if ui_is_back_selection "$selected"; then
                ui_return_back
                return 1
            fi
            printf '%s\n' "$selected"
            ;;
        *)
            return 1
            ;;
    esac
}

codex_select_custom_mcps() {
    if [ "$HAS_GUM" = true ] && command -v gum >/dev/null 2>&1; then
        local labels=()
        local definition
        for definition in "${CODEX_MCP_DEFINITIONS[@]}"; do
            labels+=("${definition#*|}")
        done

        local selected_labels
        selected_labels=$(printf '%s\n' "${labels[@]}" | gum choose --no-limit --header "ShipFlow DevServer · Select MCPs, then Enter")
        local rc=$?
        [ $rc -ne 0 ] && return $rc

        local label name
        while IFS= read -r label; do
            [ -z "$label" ] && continue
            name=$(codex_mcp_name_for_label "$label") || continue
            printf '%s\n' "$name"
        done <<< "$selected_labels"
        return 0
    fi

    local selected=()
    local keys=()
    local choice=""
    local definition key name label mark

    while true; do
        clear
        ui_screen_header "Codex MCPs"
        echo -e "${BLUE}Toggle MCPs. Press Enter to launch.${NC}"
        echo ""

        keys=()
        local i=0
        for definition in "${CODEX_MCP_DEFINITIONS[@]}"; do
            name="${definition%%|*}"
            label="${definition#*|}"
            key=$(_ui_letter_key "$i")
            keys+=("$key|$name")
            if codex_mcp_contains "$name" "${selected[@]}"; then
                mark="[x]"
            else
                mark="[ ]"
            fi
            echo -e "  ${CYAN}${key})${NC} $mark $label"
            ((i++))
        done

        echo ""
        echo -e "  ${CYAN}Enter)${NC} Launch"
        echo -e "  ${CYAN}x)${NC} Back"
        echo ""
        echo -e "${YELLOW}Choose:${NC} \c"
        ui_read_choice choice

        if [ -z "$choice" ]; then
            printf '%s\n' "${selected[@]}"
            return 0
        fi
        if ui_is_back_choice "$choice"; then
            ui_return_back
            return 1
        fi

        local matched_name=""
        for definition in "${keys[@]}"; do
            key="${definition%%|*}"
            name="${definition#*|}"
            if [ "$choice" = "$key" ]; then
                matched_name="$name"
                break
            fi
        done

        if [ -z "$matched_name" ]; then
            echo -e "${RED}Invalid choice${NC}" >&2
            sleep 1
            continue
        fi

        if codex_mcp_contains "$matched_name" "${selected[@]}"; then
            local next=()
            for name in "${selected[@]}"; do
                [ "$name" != "$matched_name" ] && next+=("$name")
            done
            selected=("${next[@]}")
        else
            selected+=("$matched_name")
        fi
    done
}

codex_select_mcp_preset() {
    local choice
    echo -e "${BLUE}Codex MCP preset:${NC}" >&2
    echo -e "  ${CYAN}f)${NC} Fast - no MCP" >&2
    echo -e "  ${CYAN}b)${NC} Browser - Playwright" >&2
    echo -e "  ${CYAN}k)${NC} Backend - Convex + Supabase" >&2
    echo -e "  ${CYAN}d)${NC} Deploy - Vercel" >&2
    echo -e "  ${CYAN}a)${NC} Auth - Clerk + Supabase" >&2
    echo -e "  ${CYAN}o)${NC} Docs - Context7" >&2
    echo -e "  ${CYAN}c)${NC} Custom selection" >&2
    echo "" >&2
    echo -e "  ${CYAN}x)${NC} Back" >&2
    echo "" >&2
    echo -e "${YELLOW}Choose:${NC} \c" >&2
    ui_read_choice choice

    if [ -z "$choice" ] || ui_is_back_choice "$choice"; then
        ui_return_back
        return 1
    fi

    case "$choice" in
        f) ;;
        b) printf 'playwright\n' ;;
        k) printf 'convex\nsupabase\n' ;;
        d) printf 'vercel\n' ;;
        a) printf 'clerk\nsupabase\n' ;;
        o) printf 'context7\nopenaiDeveloperDocs\n' ;;
        c) codex_select_custom_mcps ;;
        *) return 1 ;;
    esac
}

codex_launcher_help() {
    echo -e "${BLUE}Usage:${NC} sf codex [--dir PATH] [mcp ...]"
    echo ""
    echo "Without MCP arguments, ShipFlow opens the interactive launcher."
    echo ""
    echo "Known MCP names:"
    codex_mcp_known_names | sed 's/^/  - /'
}

codex_launch_with_mcps() {
    local workspace="$1"
    shift || true

    if [ -z "$workspace" ] || [ ! -d "$workspace" ]; then
        echo -e "${RED}❌ Invalid Codex workspace:${NC} ${workspace:-<empty>}" >&2
        return 1
    fi

    if ! command -v codex >/dev/null 2>&1; then
        echo -e "${RED}❌ Codex CLI not found in PATH.${NC}" >&2
        echo -e "${YELLOW}Run the ShipFlow installer or install @openai/codex for this user.${NC}" >&2
        return 1
    fi

    local args=("-C" "$workspace")
    local configured_names=()
    local configured_name
    while IFS= read -r configured_name; do
        [ -n "$configured_name" ] && configured_names+=("$configured_name")
    done < <(codex_configured_mcp_names)

    for configured_name in "${configured_names[@]}"; do
        if codex_mcp_is_valid_name "$configured_name"; then
            args+=("-c" "mcp_servers.${configured_name}.enabled=false")
        fi
    done

    local name
    for name in "$@"; do
        if ! codex_mcp_is_valid_name "$name"; then
            echo -e "${RED}❌ Invalid MCP name:${NC} $name" >&2
            return 1
        fi
        if ! codex_mcp_contains "$name" "${configured_names[@]}"; then
            echo -e "${RED}❌ MCP not registered in Codex config:${NC} $name" >&2
            echo -e "${YELLOW}Run the ShipFlow installer or add this MCP before launching it.${NC}" >&2
            return 1
        fi
        args+=("-c" "mcp_servers.${name}.enabled=true")
    done

    echo -e "${GREEN}Launching Codex${NC}"
    echo -e "  ${BLUE}Workspace:${NC} $workspace"
    echo -e "  ${BLUE}MCP:${NC} $(codex_mcp_selection_summary "$@")"
    echo ""

    if [ "${SHIPFLOW_CODEX_DRY_RUN:-0}" = "1" ]; then
        printf 'codex'
        printf ' %q' "${args[@]}"
        printf '\n'
        return 0
    fi

    exec codex "${args[@]}"
}

action_codex_launcher() {
    local workspace="$PWD"
    local selected_mcps=()

    if [ "$#" -gt 0 ]; then
        while [ "$#" -gt 0 ]; do
            case "$1" in
                -h|--help)
                    codex_launcher_help
                    return 0
                    ;;
                -C|--dir|--cd)
                    if [ -z "${2:-}" ]; then
                        echo -e "${RED}❌ Missing path after $1${NC}" >&2
                        return 2
                    fi
                    workspace="$2"
                    shift 2
                    ;;
                --all|all)
                    while IFS= read -r name; do
                        selected_mcps+=("$name")
                    done < <(codex_mcp_known_names)
                    shift
                    ;;
                --none|none|fast)
                    selected_mcps=()
                    shift
                    ;;
                *)
                    local raw="$1"
                    local parts=()
                    local part
                    IFS=',' read -ra parts <<< "$raw"
                    for part in "${parts[@]}"; do
                        [ -n "$part" ] && selected_mcps+=("$part")
                    done
                    shift
                    ;;
            esac
        done
    else
        clear
        ui_screen_header "Codex Launcher"
        echo -e "${BLUE}MCPs stay disabled globally. This launch enables only what you choose.${NC}"
        echo ""

        workspace=$(codex_select_workspace) || return 0
        local preset_output=""
        preset_output=$(codex_select_mcp_preset) || return 0
        while IFS= read -r name; do
            [ -n "$name" ] && selected_mcps+=("$name")
        done <<< "$preset_output"
    fi

    codex_launch_with_mcps "$workspace" "${selected_mcps[@]}"
}

action_mcp_menu() {
    ui_screen_header "MCP / Codex"

    local choice
    choice=$(printf '%s\n' \
        "Launch Codex with selected MCPs" \
        "MCP Auth Setup - Local OAuth login tunnel" \
        "Back" | ui_choose "MCP / Codex:") || {
        ui_return_back
        return 0
    }

    case "$choice" in
        "Launch Codex with selected MCPs")
            action_codex_launcher
            ;;
        "MCP Auth Setup - Local OAuth login tunnel")
            action_mcp_auth_setup
            ;;
        *)
            ui_return_back
            ;;
    esac
}

turso_cli_path() {
    command -v turso 2>/dev/null || true
}

turso_auth_output_is_logged_in() {
    local output="$1"
    [ -n "$output" ] || return 1
    ! printf '%s\n' "$output" | grep -Eqi 'not logged in|please login|not authenticated|unauthenticated'
}

turso_print_status() {
    local cli_path
    cli_path=$(turso_cli_path)

    echo -e "${BLUE}Statut Turso côté serveur${NC}"
    if [ -n "$cli_path" ]; then
        local version
        version=$(turso --version 2>/dev/null | head -1 || true)
        echo -e "  ${GREEN}✓${NC} CLI installé: ${CYAN}$cli_path${NC}"
        [ -n "$version" ] && echo -e "  ${BLUE}Version:${NC} $version"

        local auth_output
        auth_output=$(turso auth whoami 2>&1 || true)
        if turso_auth_output_is_logged_in "$auth_output"; then
            echo -e "  ${GREEN}✓${NC} Auth Turso active pour cet utilisateur serveur"
            printf '%s\n' "$auth_output"
        else
            echo -e "  ${YELLOW}⚠${NC} Auth Turso non détectée pour cet utilisateur serveur"
            [ -n "$auth_output" ] && printf '%s\n' "$auth_output"
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} CLI Turso non installé dans le PATH global"
        echo -e "  ${BLUE}Si Turso est fourni par Flox projet:${NC} utilise le login local avec --project-dir."
    fi

    echo ""
    echo -e "${YELLOW}ShipFlow ne lit pas et ne stocke pas le token Turso.${NC}"
}

turso_show_login_guide() {
    ui_screen_header "Turso Login distant"
    turso_print_status
    echo ""
    echo -e "${CYAN}Flow recommandé depuis ta machine locale${NC}"
    echo -e "  ${GREEN}1.${NC} Installer les scripts locaux ShipFlow si besoin:"
    echo -e "     ${GREEN}cd ~/shipflow/local && ./install.sh${NC}"
    echo -e "  ${GREEN}2.${NC} Configurer ce serveur dans le menu local:"
    echo -e "     ${GREEN}urls${NC} ${YELLOW}→${NC} ${GREEN}c) Configurer nouveau serveur${NC}"
    echo -e "  ${GREEN}3.${NC} Lancer le login Turso distant:"
    echo -e "     ${GREEN}urls${NC} ${YELLOW}→${NC} ${GREEN}d) Turso - Login et checks distants${NC}"
    echo -e "     ${GREEN}puis${NC} ${YELLOW}→${NC} ${GREEN}l) Login Turso distant${NC}"
    echo -e "     ${BLUE}ou:${NC} ${GREEN}shipflow-turso-login${NC}"
    echo ""
    echo -e "${CYAN}Si Turso est dans un env Flox projet côté serveur${NC}"
    echo -e "     ${GREEN}urls${NC} détecte les env Flox Turso et te propose la bonne liste."
    echo -e "     ${BLUE}En manuel seulement:${NC} ${GREEN}shipflow-turso-login --project-dir /home/<user>/<projet>${NC}"
    echo ""
    echo -e "${BLUE}Ce flow lance Turso en mode headless sur le serveur, ouvre ou affiche l'URL locale, puis vérifie l'auth.${NC}"
    echo -e "${YELLOW}Turso ne suit pas toujours le modèle callback de Blacksmith/Supabase; le mode headless est le chemin remote recommandé.${NC}"
}

turso_show_contentflow_checks() {
    ui_screen_header "Turso ContentFlow Checks"
    turso_print_status
    echo ""
    echo -e "${CYAN}Après login Turso distant, depuis ta machine locale:${NC}"
    echo -e "  ${GREEN}shipflow-turso-ssh contentflow-prod2${NC}"
    echo ""
    echo -e "${CYAN}Si Turso est dans l'env Flox ContentFlow côté serveur:${NC}"
    echo -e "  ${GREEN}urls${NC} ${YELLOW}→${NC} ${GREEN}d) Turso - Login et checks distants${NC} ${YELLOW}→${NC} ${GREEN}c) Checks ContentFlow${NC}"
    echo -e "  ${BLUE}En manuel seulement:${NC} ${GREEN}shipflow-turso-ssh --project-dir /home/<user>/<projet> contentflow-prod2${NC}"
    echo ""
    echo -e "${BLUE}Checks lancés par le helper:${NC}"
    echo -e "  ${GREEN}SELECT name FROM sqlite_master WHERE type='table' AND name IN ('jobs','CustomerPersona','UserSettings','Project','UserProviderCredential');${NC}"
    echo -e "  ${GREEN}PRAGMA table_info(jobs);${NC}"
    echo -e "  ${GREEN}PRAGMA table_info(CustomerPersona);${NC}"
}

turso_show_security_note() {
    ui_screen_header "Turso Security"
    echo -e "${CYAN}Politique ShipFlow${NC}"
    echo -e "  ${GREEN}✓${NC} Utiliser le CLI officiel Turso."
    echo -e "  ${GREEN}✓${NC} Laisser Turso gérer son fichier de session sous ~/.config/turso."
    echo -e "  ${GREEN}✓${NC} Vérifier l'auth via ${CYAN}turso auth whoami${NC} seulement."
    echo -e "  ${YELLOW}•${NC} Ne jamais afficher, copier dans un rapport, ou stocker un token Turso."
    echo -e "  ${YELLOW}•${NC} Préférer ${CYAN}shipflow-turso-login${NC} au transfert de config quand un login navigateur est possible."
    echo ""
    echo -e "${BLUE}Fallback disponible:${NC} ${GREEN}shipflow-turso-ssh${NC} peut copier ~/.config/turso vers le serveur si tu veux transférer une session déjà connectée."
}

action_turso_setup() {
    while true; do
        clear
        ui_screen_header "Turso"
        turso_print_status
        echo ""

        local choice
        choice=$(printf '%s\n' \
            "Login distant guidé" \
            "Checks ContentFlow jobs/CustomerPersona" \
            "Sécurité / auth" \
            "Back" | ui_choose "Turso:") || {
            ui_return_back
            return 0
        }

        if ui_is_back_selection "$choice"; then
            ui_return_back
            return 0
        fi

        clear
        case "$choice" in
            "Login distant guidé")
                turso_show_login_guide
                ;;
            "Checks ContentFlow jobs/CustomerPersona")
                turso_show_contentflow_checks
                ;;
            "Sécurité / auth")
                turso_show_security_note
                ;;
            *)
                ui_return_back
                return 0
                ;;
        esac

        ui_pause "Appuie sur une touche pour revenir au menu Turso..."
    done
}

blacksmith_cli_path() {
    command -v blacksmith 2>/dev/null || true
}

blacksmith_credentials_file() {
    printf '%s/.blacksmith/credentials\n' "$HOME"
}

blacksmith_is_connected() {
    local credentials_file
    credentials_file=$(blacksmith_credentials_file)
    [ -s "$credentials_file" ]
}

blacksmith_print_status() {
    local cli_path
    cli_path=$(blacksmith_cli_path)

    echo -e "${BLUE}Statut local Blacksmith${NC}"
    if [ -n "$cli_path" ]; then
        local version
        version=$(blacksmith --version 2>/dev/null | head -1 || true)
        echo -e "  ${GREEN}✓${NC} CLI installé: ${CYAN}$cli_path${NC}"
        [ -n "$version" ] && echo -e "  ${BLUE}Version:${NC} $version"
    else
        echo -e "  ${YELLOW}⚠${NC} CLI non installé"
    fi

    if [ -n "$cli_path" ] && blacksmith_is_connected; then
        echo -e "  ${GREEN}✓${NC} T'inquiète, c'est bon, t'es connecté."
    elif [ -n "$cli_path" ]; then
        echo -e "  ${YELLOW}⚠${NC} Connexion non détectée"
        echo -e "  ${BLUE}À faire depuis ta machine locale:${NC}"
        echo -e "     ${GREEN}urls${NC} ${YELLOW}→${NC} ${GREEN}Login Blacksmith (distant)${NC}"
        echo -e "  ${YELLOW}Blacksmith utilise un callback localhost; en remote il faut le tunnel SSH local.${NC}"
    else
        echo -e "  ${BLUE}À lancer dans un terminal pour installer l'outil officiel:${NC}"
        echo -e "     ${GREEN}curl -fsSL https://get.blacksmith.sh | sh${NC}"
    fi

    echo ""
    echo -e "${BLUE}GitHub App:${NC} se configure dans le navigateur sur ${CYAN}https://app.blacksmith.sh${NC}"
    echo -e "${BLUE}SSH Access:${NC} réglage organisation Blacksmith; commande SSH affichée dans le step ${CYAN}Setup runner${NC} quand le job tourne."
    echo -e "${YELLOW}ShipFlow ne lit pas et ne stocke pas le token Blacksmith.${NC}"
}

blacksmith_show_setup_checklist() {
    ui_screen_header "Blacksmith Setup"
    blacksmith_print_status
    echo ""
    echo -e "${CYAN}Checklist officielle-first${NC}"
    echo -e "  ${GREEN}1.${NC} Installer le CLI officiel si absent:"
    echo -e "     ${GREEN}curl -fsSL https://get.blacksmith.sh | sh${NC}"
    echo -e "  ${GREEN}2.${NC} Connecter le compte GitHub/Blacksmith depuis ta machine locale:"
    echo -e "     ${GREEN}urls${NC} ${YELLOW}→${NC} ${GREEN}Login Blacksmith (distant)${NC}"
    echo -e "  ${GREEN}3.${NC} Installer la GitHub App Blacksmith sur les repos concernés:"
    echo -e "     ${CYAN}https://app.blacksmith.sh${NC}"
    echo -e "  ${GREEN}4.${NC} Activer SSH Access côté organisation si tu veux debugger les runners:"
    echo -e "     ${CYAN}https://app.blacksmith.sh${NC} ${YELLOW}→${NC} ${CYAN}Settings > Features > SSH Access${NC}"
    echo -e "  ${GREEN}5.${NC} Dans chaque repo projet, utiliser le menu Blacksmith > Testbox projet si besoin."
    echo ""
    echo -e "${BLUE}Note:${NC} le MCP Blacksmith non officiel n'est pas installé par défaut."
}

blacksmith_select_project_path() {
    local choice
    choice=$(printf '%s\n' \
        "Répertoire courant ($(pwd -P))" \
        "Environnement ShipFlow déployé" \
        "Chemin personnalisé" \
        "Back" | ui_choose "Projet pour Testbox:") || return 1

    if ui_is_back_selection "$choice"; then
        return 1
    fi

    local project_dir=""
    case "$choice" in
        "Répertoire courant "*)
            project_dir=$(pwd -P)
            ;;
        "Environnement ShipFlow déployé")
            local env_name
            env_name=$(select_environment "Sélectionne l'environnement projet") || return 1
            project_dir=$(resolve_project_path "$env_name" 2>/dev/null || true)
            ;;
        "Chemin personnalisé")
            project_dir=$(ui_input "Chemin projet absolu:" "$PROJECTS_DIR/my-project")
            ;;
        *)
            return 1
            ;;
    esac

    [ -n "$project_dir" ] || return 1
    if ! validate_project_path "$project_dir"; then
        echo -e "${RED}❌ Chemin projet invalide ou non sûr: $project_dir${NC}" >&2
        return 1
    fi
    printf '%s\n' "$project_dir"
}

blacksmith_show_testbox_project_guide() {
    ui_screen_header "Blacksmith Testbox"
    blacksmith_print_status
    echo ""

    local project_dir
    project_dir=$(blacksmith_select_project_path) || {
        ui_should_skip_next_pause >/dev/null 2>&1 || true
        echo -e "${BLUE}Retour au menu Blacksmith.${NC}"
        return 0
    }

    local quoted_project_dir
    printf -v quoted_project_dir '%q' "$project_dir"

    echo ""
    echo -e "${CYAN}Projet sélectionné:${NC} ${GREEN}$project_dir${NC}"
    if [ ! -d "$project_dir/.git" ]; then
        echo -e "${YELLOW}⚠ Ce dossier ne semble pas être un repo Git. Testbox s'appuie sur GitHub Actions.${NC}"
    fi
    if [ ! -d "$project_dir/.github/workflows" ]; then
        echo -e "${YELLOW}⚠ Aucun workflow GitHub Actions détecté dans .github/workflows.${NC}"
        echo -e "${YELLOW}  Crée ou récupère d'abord un workflow CI, puis relance l'init Testbox.${NC}"
    fi

    echo ""
    echo -e "${BLUE}À lancer dans un terminal depuis ce serveur quand tu veux initialiser Testbox:${NC}"
    echo -e "   ${GREEN}cd $quoted_project_dir${NC}"
    echo -e "   ${GREEN}blacksmith testbox init${NC}"
    echo ""
    echo -e "${BLUE}Après init, Blacksmith génère un workflow .github/workflows/blacksmith-testbox.yml et une skill agent côté repo.${NC}"
    echo -e "${YELLOW}Le menu ne lance pas cette commande automatiquement, car c'est un assistant interactif qui peut écrire dans le repo.${NC}"
}

blacksmith_show_runner_tags() {
    ui_screen_header "Blacksmith Runners"
    blacksmith_print_status
    echo ""
    echo -e "${CYAN}Tags courants${NC}"
    echo -e "  ${GREEN}ubuntu-latest${NC}  → ${GREEN}blacksmith-2vcpu-ubuntu-2404${NC}"
    echo -e "  ${GREEN}windows-latest${NC} → ${GREEN}blacksmith-2vcpu-windows-2025${NC}"
    echo -e "  ${GREEN}macos-latest${NC}   → ${GREEN}blacksmith-6vcpu-macos-latest${NC}"
    echo ""
    echo -e "${CYAN}Android release depuis un hôte ARM64${NC}"
    echo -e "  ${YELLOW}Ne lance pas de build APK/AAB release local.${NC}"
    echo -e "  ${BLUE}Utilise un workflow GitHub Actions sur un runner x64 Blacksmith, par exemple:${NC}"
    echo -e "     ${GREEN}runs-on: blacksmith-4vcpu-ubuntu-2404${NC}"
    echo ""
    echo -e "${BLUE}Pour une migration manuelle, remplace seulement le tag runs-on du job concerné.${NC}"
    echo -e "${BLUE}ShipFlow guide la décision, mais ne patche pas les workflows automatiquement dans cette version.${NC}"
}

blacksmith_show_ssh_access_guide() {
    ui_screen_header "Blacksmith SSH Access"
    blacksmith_print_status
    echo ""
    echo -e "${CYAN}Quand l'utiliser${NC}"
    echo -e "  ${GREEN}✓${NC} Build APK/AAB ou CI Blacksmith en échec avec logs insuffisants."
    echo -e "  ${GREEN}✓${NC} Besoin d'inspecter outputs, Gradle, Android SDK/NDK, disque, CPU/RAM."
    echo -e "  ${YELLOW}•${NC} Pas nécessaire pour un simple typecheck/lint dont les logs sont clairs."
    echo ""
    echo -e "${CYAN}Prérequis${NC}"
    echo -e "  ${GREEN}1.${NC} SSH Access activé par un admin dans Blacksmith ${YELLOW}→${NC} Settings > Features."
    echo -e "  ${GREEN}2.${NC} Ta clé SSH est ajoutée à ton compte GitHub."
    echo -e "  ${GREEN}3.${NC} Tu es l'utilisateur GitHub qui a déclenché le job."
    echo -e "  ${GREEN}4.${NC} Le job est encore vivant, ou retenu par Monitor VM retention / keepalive."
    echo ""
    echo -e "${CYAN}Connexion${NC}"
    echo -e "  ${GREEN}1.${NC} Ouvre le run GitHub Actions / Blacksmith."
    echo -e "  ${GREEN}2.${NC} Ouvre le step ${CYAN}Setup runner${NC}."
    echo -e "  ${GREEN}3.${NC} Copie la commande complète ${GREEN}ssh -p ... runner@...vm.blacksmith.sh${NC}."
    echo -e "  ${GREEN}4.${NC} Colle-la dans ton terminal local."
    echo -e "  ${YELLOW}Le port peut changer selon le job; ne suppose jamais ${GREEN}-p 64000${YELLOW}.${NC}"
    echo ""
    echo -e "${CYAN}Option confort dans ~/.ssh/config local${NC}"
    echo -e "  ${GREEN}Host *.vm.blacksmith.sh${NC}"
    echo -e "  ${GREEN}    StrictHostKeyChecking no${NC}"
    echo -e "  ${GREEN}    UserKnownHostsFile /dev/null${NC}"
    echo ""
    echo -e "${CYAN}Keepalive workflow en cas d'échec${NC}"
    echo -e "  ${BLUE}Place ce step à la fin du job à debugger, après les steps de build/upload.${NC}"
    echo -e "  ${BLUE}Il ne tourne qu'après un échec et garde la VM SSH ouverte 30 minutes.${NC}"
    echo -e "  ${GREEN}- name: Keep runner available after failure${NC}"
    echo -e "  ${GREEN}  if: failure()${NC}"
    echo -e "  ${GREEN}  run: |${NC}"
    echo -e "  ${GREEN}    echo \"Failure detected; use the Blacksmith setup step SSH command.\"${NC}"
    echo -e "  ${GREEN}    sleep 1800${NC}"
    echo -e "  ${YELLOW}Sans keepalive ou VM retention, Blacksmith supprime le host dès la fin du job.${NC}"
    echo ""
    echo -e "${BLUE}Agents:${NC} ${GREEN}sf-prod${NC} possède le debug Logs/Run History/Metrics/SSH; ${GREEN}sf-deploy${NC} doit router vers sf-prod."
    echo -e "${YELLOW}Ne jamais copier de secrets, tokens, cookies ou valeurs d'env depuis le runner dans un rapport.${NC}"
}

blacksmith_show_security_note() {
    ui_screen_header "Blacksmith Security"
    echo -e "${CYAN}Politique ShipFlow${NC}"
    echo -e "  ${GREEN}✓${NC} Utiliser l'intégration officielle Blacksmith: GitHub App, runners, CLI Testbox."
    echo -e "  ${GREEN}✓${NC} Laisser Blacksmith et GitHub gérer l'auth."
    echo -e "  ${GREEN}✓${NC} Vérifier seulement la présence locale du CLI et du fichier credentials."
    echo -e "  ${GREEN}✓${NC} Utiliser SSH Access seulement pour inspecter un runner live ou retenu."
    echo -e "  ${YELLOW}•${NC} Ne pas lire, afficher, copier ou stocker le contenu du token."
    echo -e "  ${YELLOW}•${NC} Ne pas copier les valeurs de variables d'environnement depuis un runner SSH."
    echo -e "  ${YELLOW}•${NC} Ne pas installer le MCP Blacksmith non officiel par défaut."
    echo ""
    echo -e "${BLUE}Le statut connecté repose sur la présence du fichier credentials Blacksmith côté serveur.${NC}"
    echo -e "${BLUE}Si Blacksmith refuse ensuite une commande, repasse par le menu local et suis le message du CLI.${NC}"
}

action_blacksmith_setup() {
    while true; do
        clear
        ui_screen_header "Blacksmith"
        blacksmith_print_status
        echo ""

        local choice
        choice=$(printf '%s\n' \
            "Setup checklist" \
            "Testbox projet" \
            "Runner tags / Android release" \
            "SSH Access / debug runner" \
            "Sécurité / auth" \
            "Back" | ui_choose "Blacksmith:") || {
            ui_return_back
            return 0
        }

        if ui_is_back_selection "$choice"; then
            ui_return_back
            return 0
        fi

        clear
        case "$choice" in
            "Setup checklist")
                blacksmith_show_setup_checklist
                ;;
            "Testbox projet")
                blacksmith_show_testbox_project_guide
                ;;
            "Runner tags / Android release")
                blacksmith_show_runner_tags
                ;;
            "SSH Access / debug runner")
                blacksmith_show_ssh_access_guide
                ;;
            "Sécurité / auth")
                blacksmith_show_security_note
                ;;
            *)
                ui_return_back
                return 0
                ;;
        esac

        ui_pause "Appuie sur une touche pour revenir au menu Blacksmith..."
    done
}

action_publish() {
    ui_screen_header "Publish to Web"
    if ! command -v caddy >/dev/null 2>&1; then
        echo -e "${RED}❌ Caddy not installed${NC}"
        echo -e "${YELLOW}Install with: sudo apt install caddy${NC}"
        return
    fi
    echo -e "${BLUE}📡 Detecting public IP...${NC}"
    PUBLIC_IP=$(curl -4 -s https://ip.me 2>/dev/null)
    if [ -n "$PUBLIC_IP" ] && validate_public_ipv4 "$PUBLIC_IP"; then
        echo -e "${BLUE}📡 Detected Public IP: ${GREEN}$PUBLIC_IP${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not detect public IP${NC}"
        PUBLIC_IP=$(ui_input "Enter public IP:")
        validate_public_ipv4 "$PUBLIC_IP" || return
    fi
    echo ""
    CACHED_SUBDOMAIN=$(load_secret "DUCKDNS_SUBDOMAIN" 2>/dev/null) || true
    CACHED_TOKEN=$(load_secret "DUCKDNS_TOKEN" 2>/dev/null) || true
    if [ -n "$CACHED_SUBDOMAIN" ] && [ -n "$CACHED_TOKEN" ]; then
        if validate_duckdns_subdomain "$CACHED_SUBDOMAIN" && validate_duckdns_token "$CACHED_TOKEN"; then
            echo -e "${GREEN}📋 Cached subdomain: ${CYAN}$CACHED_SUBDOMAIN${NC}"
            if ui_confirm "Use cached DuckDNS credentials?"; then
                DUCKDNS_SUBDOMAIN="$CACHED_SUBDOMAIN"
                DUCKDNS_TOKEN="$CACHED_TOKEN"
            else
                CACHED_SUBDOMAIN=""
                CACHED_TOKEN=""
            fi
        else
            warning "Cached DuckDNS credentials are invalid and will be ignored"
            CACHED_SUBDOMAIN=""
            CACHED_TOKEN=""
        fi
    fi
    if [ -z "$CACHED_SUBDOMAIN" ] || [ -z "$CACHED_TOKEN" ]; then
        DUCKDNS_SUBDOMAIN=$(ui_input "DuckDNS Subdomain (without .duckdns.org):" "my-subdomain")
        validate_duckdns_subdomain "$DUCKDNS_SUBDOMAIN" || return
        DUCKDNS_TOKEN=$(ui_input "DuckDNS Token:" "your-token-here" "--password")
        validate_duckdns_token "$DUCKDNS_TOKEN" || return
        save_secret "DUCKDNS_SUBDOMAIN" "$DUCKDNS_SUBDOMAIN"
        save_secret "DUCKDNS_TOKEN" "$DUCKDNS_TOKEN"
    fi
    echo ""
    echo -e "${BLUE}🌐 Updating DuckDNS...${NC}"
    DUCKDNS_RESPONSE=$(
        curl -fsS --get "https://www.duckdns.org/update" \
            --data-urlencode "domains=$DUCKDNS_SUBDOMAIN" \
            --data-urlencode "token=$DUCKDNS_TOKEN" \
            --data-urlencode "ip=$PUBLIC_IP" \
            2>/dev/null
    )
    if [ "$DUCKDNS_RESPONSE" = "OK" ]; then
        log INFO "DuckDNS updated: $DUCKDNS_SUBDOMAIN → $PUBLIC_IP"
        echo -e "${GREEN}✅ DuckDNS updated successfully${NC}"
    else
        log ERROR "DuckDNS update failed for $DUCKDNS_SUBDOMAIN: $DUCKDNS_RESPONSE"
        echo -e "${RED}❌ DuckDNS update failed: $DUCKDNS_RESPONSE${NC}"
        return
    fi
    echo ""
    ENV_NAME=$(select_environment "Select environment to publish")
    [ -z "$ENV_NAME" ] && return
    PORT=$(get_port_from_pm2 "$ENV_NAME")
    if [ -z "$PORT" ]; then echo -e "${RED}❌ Could not get port for $ENV_NAME${NC}"; return; fi
    DOMAIN="${DUCKDNS_SUBDOMAIN}.duckdns.org"
    CADDYFILE="/etc/caddy/Caddyfile"
    [ -f "$CADDYFILE" ] && sudo cp "$CADDYFILE" "${CADDYFILE}.backup.$(date +%s)" 2>/dev/null
    echo -e "${BLUE}🔧 Generating Caddyfile with all online environments...${NC}"
    ROUTES=""
    ALL_ENVS=$(list_all_environments)
    SELECTED_INCLUDED=false
    if [ -n "$ALL_ENVS" ]; then
        while IFS= read -r env; do
            [ -z "$env" ] && continue
            local env_status=$(get_pm2_status "$env")
            local env_port=$(get_port_from_pm2 "$env")
            if [ "$env_status" = "online" ] && [ -n "$env_port" ]; then
                ROUTES="${ROUTES}    reverse_proxy /${env}* localhost:${env_port}"$'\n'
                echo -e "  ${GREEN}✓${NC} /${env} → localhost:${env_port}"
                [ "$env" = "$ENV_NAME" ] && SELECTED_INCLUDED=true
            fi
        done <<< "$ALL_ENVS"
    fi
    if [ "$SELECTED_INCLUDED" = "false" ]; then
        ROUTES="${ROUTES}    reverse_proxy /${ENV_NAME}* localhost:${PORT}"$'\n'
        echo -e "  ${GREEN}✓${NC} /${ENV_NAME} → localhost:${PORT} (selected)"
    fi
    sudo tee "$CADDYFILE" > /dev/null << EOF
${DOMAIN} {
${ROUTES}    encode gzip
}
EOF
    log INFO "Caddyfile generated for $DOMAIN with routes for all online environments"
    echo -e "${GREEN}✅ Caddyfile generated with all routes${NC}"
    echo -e "${BLUE}🔄 Starting/reloading system Caddy for explicit HTTPS publish...${NC}"
    sudo systemctl start caddy 2>/dev/null || true
    if sudo systemctl reload caddy; then
        log INFO "Caddy reloaded successfully for $DOMAIN"
        echo -e "${GREEN}✅ Caddy reloaded${NC}"
        echo ""
        echo -e "${GREEN}🎉 SUCCESS! Published URLs:${NC}"
        if [ -n "$ALL_ENVS" ]; then
            while IFS= read -r env; do
                [ -z "$env" ] && continue
                local env_s=$(get_pm2_status "$env")
                local env_p=$(get_port_from_pm2 "$env")
                [ "$env_s" = "online" ] && [ -n "$env_p" ] && echo -e "${CYAN}   https://$DOMAIN/$env${NC}"
            done <<< "$ALL_ENVS"
        fi
        if ! echo "$ALL_ENVS" | grep -q "^${ENV_NAME}$" || [ "$(get_pm2_status "$ENV_NAME")" != "online" ]; then
            echo -e "${CYAN}   https://$DOMAIN/$ENV_NAME${NC} (selected)"
        fi
        echo ""
    else
        log ERROR "Failed to reload Caddy for $DOMAIN"
        echo -e "${RED}❌ Failed to reload Caddy${NC}"
        echo -e "${YELLOW}Check logs with: sudo journalctl -u caddy -n 50${NC}"
    fi
}

action_adv_help() { show_help; }
action_cleanup() {
    local rc=0
    disk_cleanup_menu || rc=$?
    if ui_should_skip_next_pause; then
        ui_skip_next_pause
        return "$rc"
    fi
    refresh_menu_status_cache_sync >/dev/null 2>&1 || true
    return "$rc"
}
action_updates() {
    local rc=0
    updates_menu || rc=$?
    if ui_should_skip_next_pause; then
        ui_skip_next_pause
        return "$rc"
    fi
    refresh_menu_status_cache_sync >/dev/null 2>&1 || true
    return "$rc"
}
action_tools() { show_tools_status; }
action_install_sdk() { install_sdk_menu; }

# ============================================================================
# MENU ITEM DEFINITIONS (shared between gum and bash menus)
# ============================================================================

MAIN_MENU_ITEMS=(
    "d|📊 Dashboard|action_dashboard"
    "e|🚀 Deploy / Start|action_deploy"
    "m|🧭 Environments|action_environments_menu"
    "t|🧰 Tools|action_tools_web_menu"
    "s|⚙️ System|action_system_menu"
    "a|🤖 Agents|action_agents_ci_menu"
    "f|🚢 ShipFlow|action_shipflow_overview"
    "h|❓ Help|action_adv_help"
    "x|👋 Exit|action_exit"
)

ENVIRONMENT_MENU_ITEMS=(
    "r|🔄 Restart|action_restart"
    "t|🛑 Stop|action_stop"
    "w|🗑️ Remove|action_remove"
    "y|✏️ Rename|action_rename"
    "a|▶️ Start All|action_start_all"
    "o|⏹️ Stop All|action_stop_all"
    "b|🔁 Restart All|action_restart_all"
    "l|📝 Logs|action_view_logs"
    "n|📁 Navigate|action_navigate"
    "x|↩️ Back|__EXIT__"
)

TOOLS_WEB_MENU_ITEMS=(
    "g|📱 Flutter Web - tmux hot reload|action_flutter_web"
    "p|🌐 Publish - Configure HTTPS (Caddy + DuckDNS)|action_publish"
    "i|🔍 Inspector - Toggle browser web inspector|action_inspector"
    "m|🤳 Mobile Guide - Setup Android + Expo|action_mobile"
    "f|📦 Install SDK - Flutter, Dart...|action_install_sdk"
    "v|🧪 Tools Status - Voir les outils installés|action_tools"
    "x|↩️ Back|__EXIT__"
)

SYSTEM_MENU_ITEMS=(
    "h|🩺 Health Check - RAM, disk, processes, crash loops|action_health"
    "u|⬆️ Updates - Check & update packages|action_updates"
    "k|🧹 Cleanup - Disk details, PM2 logs, caches|action_cleanup"
    "0|🔌 Reboot VM - Restart this server|action_reboot_vm"
    "j|🔐 Session Identity - View or reset session|action_session"
    "c|🌐 Local Setup - Show server address for tunnels|action_local_connection_info"
    "x|↩️ Back|__EXIT__"
)

AGENTS_CI_MENU_ITEMS=(
    "g|🐙 GitHub Login - gh auth for deploys|action_github_auth"
    "q|🧠 MCP / Codex - Auth and launcher|action_mcp_menu"
    "u|🗄️ Turso - DB auth and schema checks|action_turso_setup"
    "z|🏗️ Blacksmith - CI runners and Testbox setup|action_blacksmith_setup"
    "x|↩️ Back|__EXIT__"
)

# Legacy: ADVANCED_MENU_ITEMS kept for action_advanced fallback
ADVANCED_MENU_ITEMS=(
    "x|↩️ Back|__EXIT__"
)

print_menu_shortcut_usage() {
    echo -e "${BLUE}Usage:${NC} sf [menu shortcut]" >&2
    echo -e "${BLUE}Example:${NC} sf t" >&2
    echo -e "${BLUE}Codex launcher:${NC} sf codex [mcp ...]" >&2
    echo "" >&2
    echo -e "${BLUE}Available menu keys:${NC}" >&2

    local item key label action
    for item in "${MAIN_MENU_ITEMS[@]}"; do
        IFS='|' read -r key label action <<< "$item"
        [ "$key" = "---" ] && continue
        [ -z "$action" ] && continue
        echo -e "  ${CYAN}${key})${NC} ${label}" >&2
    done
}

resolve_menu_shortcut_action() {
    local raw_choice="${1:-}"
    local choice
    choice=$(_ui_normalize_choice "$raw_choice")

    [ -n "$choice" ] || return 1

    local item key label action label_choice
    for item in "${MAIN_MENU_ITEMS[@]}"; do
        IFS='|' read -r key label action <<< "$item"
        [ "$key" = "---" ] && continue
        [ -z "$action" ] && continue

        if [ "$choice" = "$(_ui_normalize_choice "$key")" ]; then
            printf '%s\n' "$action"
            return 0
        fi

        label_choice=$(_ui_normalize_choice "$label")
        if [ "$choice" = "$label_choice" ]; then
            printf '%s\n' "$action"
            return 0
        fi
    done

    return 1
}

run_menu_shortcut() {
    if [ "${1:-}" = "codex" ] || [ "${1:-}" = "co" ]; then
        shift
        action_codex_launcher "$@"
        return $?
    fi

    if [ "$#" -ne 1 ]; then
        error "Expected exactly one menu shortcut argument."
        print_menu_shortcut_usage
        return 2
    fi

    local action
    if ! action=$(resolve_menu_shortcut_action "$1"); then
        error "Unknown ShipFlow menu shortcut: $1"
        print_menu_shortcut_usage
        return 2
    fi

    log INFO "Menu shortcut: $1 -> $action"
    "$action"
}

# action_advanced needs to be defined after ADVANCED_MENU_ITEMS
# Each menu file (menu_gum.sh / menu_bash.sh) provides its own implementation
show_shipflow_menu() {
    local SHIPFLOW_DATA="${SHIPFLOW_DATA_DIR:-$HOME/shipflow_data}"
    local TASKS_FILE="$SHIPFLOW_DATA/TASKS.md"
    local AUDIT_FILE="$SHIPFLOW_DATA/AUDIT_LOG.md"

    # First-run: create data directory with starter files if missing
    if [ ! -d "$SHIPFLOW_DATA" ]; then
        mkdir -p "$SHIPFLOW_DATA"
        cat > "$SHIPFLOW_DATA/TASKS.md" << 'TASKS_EOF'
# Master Project Tracker

> **Priority:** 🔴 P0 blocker · 🟠 P1 high · 🟡 P2 normal · 🟢 P3 low · ⚪ deferred
> **Status:** 📋 todo · 🔄 in progress · ✅ done · ⛔ blocked · 💤 deferred

---

## Dashboard

| # | Project | Phase | Status | Top Priority |
|---|---------|-------|--------|--------------|

**Legend:** 🟢 Stable · 🟡 Active · 🟠 Planning · 🔴 Blocked · ⚪ Empty

---

## Backlog

| Pri | Task | Status |
|-----|------|--------|
| 🟡 | Add first project with /sf-init | 📋 todo |
TASKS_EOF
        cat > "$SHIPFLOW_DATA/AUDIT_LOG.md" << 'AUDIT_EOF'
# Audit Log

> Populated by `/sf-audit` skills. Each entry follows the format:
> `### Audit: [Domain] — [Project] (YYYY-MM-DD)`

---
AUDIT_EOF
        cat > "$SHIPFLOW_DATA/PROJECTS.md" << 'PROJECTS_EOF'
# Projects

## Project Registry

| Name | Path | Stack |
|------|------|-------|

## Domain Applicability

| Project | Code | Design | Copy | SEO | GTM | Translate | Deps | Perf |
|---------|------|--------|------|-----|-----|-----------|------|------|
PROJECTS_EOF
        echo -e "${GREEN}✅ Created data directory: $SHIPFLOW_DATA${NC}"
        sleep 1
    fi
    local CHANGELOG_FILE="$(dirname "${BASH_SOURCE[0]}")/CHANGELOG.md"

    while true; do
        clear
        ui_screen_header "ShipFlow Overview"

        # Mini dashboard: show project table from TASKS.md
        if [ -f "$TASKS_FILE" ]; then
            grep -E "^\| [0-9]+" "$TASKS_FILE" 2>/dev/null | head -12 | while IFS= read -r line; do
                echo -e "  $line"
            done
            echo ""
        fi

        echo -e "${GREEN}Choose:${NC}"
        echo ""
        echo -e "  ${CYAN}t)${NC} 📋 Tasks       — Browse all projects & tasks"
        echo -e "  ${CYAN}p)${NC} 🔴 Priorities  — Show P0 & P1 tasks only"
        echo -e "  ${CYAN}c)${NC} 📝 Changelog   — View recent changes"
        echo -e "  ${CYAN}a)${NC} 📊 Audit Log   — Review quality scores"
        echo ""
        echo -e "  ${CYAN}x)${NC} ← Back"
        echo ""
        echo -e "${YELLOW}Your choice:${NC} \c"
        ui_read_choice sf_choice

        case $sf_choice in
            t)
                if [ -f "$TASKS_FILE" ]; then
                    less -R "$TASKS_FILE"
                else
                    echo -e "${RED}❌ TASKS.md not found at:${NC} $TASKS_FILE"
                    sleep 2
                fi
                ;;
            p)
                if [ -f "$TASKS_FILE" ]; then
                    clear
                    ui_screen_header "P0 Blockers & P1 High Priority" danger
                    local current_project=""
                    while IFS= read -r line; do
                        if echo "$line" | grep -qE "^## [0-9]+\."; then
                            current_project=$(echo "$line" | sed 's/^## //')
                        fi
                        if echo "$line" | grep -qE "^\| (🔴|🟠)"; then
                            if [ -n "$current_project" ]; then
                                echo -e "${BLUE}── $current_project${NC}"
                                current_project=""
                            fi
                            echo "  $line"
                        fi
                    done < "$TASKS_FILE"
                    echo ""
                    ui_pause "Press any key to continue..."
                else
                    echo -e "${RED}❌ TASKS.md not found${NC}"
                    sleep 2
                fi
                ;;
            c)
                if [ -f "$CHANGELOG_FILE" ]; then
                    less -R "$CHANGELOG_FILE"
                else
                    echo -e "${RED}❌ CHANGELOG.md not found at:${NC} $CHANGELOG_FILE"
                    sleep 2
                fi
                ;;
            a)
                if [ -f "$AUDIT_FILE" ]; then
                    less -R "$AUDIT_FILE"
                else
                    echo -e "${RED}❌ AUDIT_LOG.md not found at:${NC} $AUDIT_FILE"
                    sleep 2
                fi
                ;;
            x|q)
                ui_return_back
                return 0
                ;;
            *)
                echo -e "${RED}❌ Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Help documentation (paginated)
show_help() {
    local page=1
    local total_pages=4

    while true; do
        clear
        ui_screen_header "ShipFlow Help (Page $page/$total_pages)"

        case $page in
            1)
                echo -e "${GREEN}🚀 QUICKSTART GUIDE${NC}"
                echo ""
                echo -e "${YELLOW}First time? Follow these steps:${NC}"
                echo ""
                echo -e "  ${CYAN}Step 1:${NC} ${GREEN}Have a project ready${NC}"
                echo -e "         Place your project in ${YELLOW}$PROJECTS_DIR${NC}"
                echo -e "         (or clone from GitHub using Deploy → ${YELLOW}c${NC} Deploy from GitHub)"
                echo ""
                echo -e "  ${CYAN}Step 2:${NC} ${GREEN}Start your project${NC}"
                echo -e "         From main menu, press ${YELLOW}e${NC} (Deploy)"
                echo -e "         Then press ${YELLOW}a${NC} (Auto-detect)"
                echo -e "         Select your project from the list"
                echo ""
                echo -e "  ${CYAN}Step 3:${NC} ${GREEN}Access your app${NC}"
                echo -e "         Your app runs on ${YELLOW}http://localhost:<port>${NC}"
                echo -e "         Check the Dashboard (${YELLOW}d${NC}) to see the port"
                echo ""
                echo -e "  ${CYAN}Step 4:${NC} ${GREEN}Publish to web (optional)${NC}"
                echo -e "         Press ${YELLOW}t${NC} (Tools) then ${YELLOW}p${NC} (Publish)"
                echo ""
                echo -e "${BLUE}┌───────────────────────────────────────────────────────────────┐${NC}"
                echo -e "${BLUE}│${NC} ${YELLOW}Quick Reference:${NC}                                              ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}   ${CYAN}d${NC} Dashboard  ${CYAN}e${NC} Deploy/Start  ${CYAN}m${NC} Environments  ${CYAN}t${NC} Tools       ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}   ${CYAN}s${NC} System  ${CYAN}a${NC} Agents  ${CYAN}f${NC} ShipFlow  ${CYAN}h${NC} Help  ${CYAN}x${NC} Exit         ${BLUE}│${NC}"
                echo -e "${BLUE}└───────────────────────────────────────────────────────────────┘${NC}"
                ;;
            2)
                echo -e "${GREEN}📐 HOW SHIPFLOW WORKS${NC}"
                echo ""
                echo -e "${BLUE}┌─────────────────────────────────────────────────────────┐${NC}"
                echo -e "${BLUE}│${NC}  You select a project from the menu                      ${BLUE}│${NC}"
                echo -e "${BLUE}└─────────────────────────────────────────────────────────┘${NC}"
                echo -e "                              ${YELLOW}│${NC}"
                echo -e "                              ${YELLOW}▼${NC}"
                echo -e "${BLUE}┌─────────────────────────────────────────────────────────┐${NC}"
                echo -e "${BLUE}│${NC}  ShipFlow checks: does project have ${CYAN}.flox${NC} directory?    ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}  ${GREEN}✓ Yes${NC} → use existing    ${YELLOW}✗ No${NC} → create & configure     ${BLUE}│${NC}"
                echo -e "${BLUE}└─────────────────────────────────────────────────────────┘${NC}"
                echo -e "                              ${YELLOW}│${NC}"
                echo -e "                              ${YELLOW}▼${NC}"
                echo -e "${BLUE}┌─────────────────────────────────────────────────────────┐${NC}"
                echo -e "${BLUE}│${NC}  Auto-detect project type & dev command:                 ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}  • package.json → ${CYAN}npm/yarn/pnpm dev${NC}                     ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}  • requirements.txt → ${CYAN}./venv/bin/python main.py${NC}        ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}  • Cargo.toml → ${CYAN}cargo run${NC}                              ${BLUE}│${NC}"
                echo -e "${BLUE}└─────────────────────────────────────────────────────────┘${NC}"
                echo -e "                              ${YELLOW}│${NC}"
                echo -e "                              ${YELLOW}▼${NC}"
                echo -e "${BLUE}┌─────────────────────────────────────────────────────────┐${NC}"
                echo -e "${BLUE}│${NC}  Create ${CYAN}ecosystem.config.cjs${NC} for PM2:                   ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}  ${YELLOW}script:${NC} bash -c \"flox activate -- <dev command>\"       ${BLUE}│${NC}"
                echo -e "${BLUE}└─────────────────────────────────────────────────────────┘${NC}"
                echo -e "                              ${YELLOW}│${NC}"
                echo -e "                              ${YELLOW}▼${NC}"
                echo -e "${BLUE}┌─────────────────────────────────────────────────────────┐${NC}"
                echo -e "${BLUE}│${NC}  PM2 manages the process:                                ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}  ${GREEN}• Auto-restart on crash${NC}                                ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}  ${GREEN}• Logs captured${NC}                                        ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}  ${GREEN}• Port management${NC}                                      ${BLUE}│${NC}"
                echo -e "${BLUE}└─────────────────────────────────────────────────────────┘${NC}"
                ;;
            3)
                echo -e "${GREEN}🛠️  SUPPORTED TECHNOLOGIES${NC}"
                echo ""
                echo -e "${BLUE}┌──────────────────┬────────────────────────────────────┐${NC}"
                echo -e "${BLUE}│${NC} ${YELLOW}Language/Stack${NC}   ${BLUE}│${NC} ${YELLOW}Detection & Commands${NC}               ${BLUE}│${NC}"
                echo -e "${BLUE}├──────────────────┼────────────────────────────────────┤${NC}"
                echo -e "${BLUE}│${NC} ${CYAN}Node.js${NC}          ${BLUE}│${NC} package.json                       ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}                  ${BLUE}│${NC} → npm/yarn/pnpm install & dev      ${BLUE}│${NC}"
                echo -e "${BLUE}├──────────────────┼────────────────────────────────────┤${NC}"
                echo -e "${BLUE}│${NC} ${CYAN}Python${NC}           ${BLUE}│${NC} requirements.txt / pyproject.toml  ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}                  ${BLUE}│${NC} → venv + pip install + python      ${BLUE}│${NC}"
                echo -e "${BLUE}├──────────────────┼────────────────────────────────────┤${NC}"
                echo -e "${BLUE}│${NC} ${CYAN}Rust${NC}             ${BLUE}│${NC} Cargo.toml                         ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}                  ${BLUE}│${NC} → cargo run                        ${BLUE}│${NC}"
                echo -e "${BLUE}├──────────────────┼────────────────────────────────────┤${NC}"
                echo -e "${BLUE}│${NC} ${CYAN}Go${NC}               ${BLUE}│${NC} go.mod                             ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}                  ${BLUE}│${NC} → go run .                         ${BLUE}│${NC}"
                echo -e "${BLUE}├──────────────────┼────────────────────────────────────┤${NC}"
                echo -e "${BLUE}│${NC} ${CYAN}Flutter/Dart${NC}     ${BLUE}│${NC} pubspec.yaml                       ${BLUE}│${NC}"
                echo -e "${BLUE}│${NC}                  ${BLUE}│${NC} → flutter web / dart run          ${BLUE}│${NC}"
                echo -e "${BLUE}└──────────────────┴────────────────────────────────────┘${NC}"
                echo ""
                echo -e "${GREEN}📦 FRAMEWORKS AUTO-DETECTED${NC}"
                echo ""
                echo -e "  ${CYAN}•${NC} Next.js     → ${YELLOW}npm dev -p \$PORT${NC}"
                echo -e "  ${CYAN}•${NC} Astro       → ${YELLOW}npm dev -- --port \$PORT --host${NC}"
                echo -e "  ${CYAN}•${NC} Vite        → ${YELLOW}npm dev -- --port \$PORT --host${NC}"
                echo -e "  ${CYAN}•${NC} Nuxt        → ${YELLOW}npm dev --port \$PORT${NC}"
                echo -e "  ${CYAN}•${NC} Expo        → ${YELLOW}npx expo start --dev-client --tunnel${NC}"
                echo -e "  ${CYAN}•${NC} Flutter Web → ${YELLOW}flutter run -d web-server --web-port \$PORT${NC}"
                echo -e "  ${CYAN}•${NC} Dart        → ${YELLOW}dart pub get && dart run${NC}"
                echo -e "  ${CYAN}•${NC} Django      → ${YELLOW}python manage.py runserver 0.0.0.0:\$PORT${NC}"
                echo -e "  ${CYAN}•${NC} Flask/FastAPI → ${YELLOW}python app.py${NC} or ${YELLOW}python main.py${NC}"
                echo ""
                echo -e "${GREEN}🔧 ENVIRONMENT ISOLATION${NC}"
                echo ""
                echo -e "  ${CYAN}Flox${NC} provides reproducible, isolated environments"
                echo -e "  Each project gets its own dependencies via Nix"
                ;;
            4)
                echo -e "${GREEN}🔍 WEB INSPECTOR (Visual Selection)${NC}"
                echo ""
                echo -e "  Inject a visual element selector into your web app:"
                echo ""
                echo -e "  ${CYAN}•${NC} Inject/remove manually via ${YELLOW}Tools & Web → Inspector${NC}"
                echo -e "  ${CYAN}•${NC} Shows numbered buttons on every ${YELLOW}<div>${NC} element"
                echo -e "  ${CYAN}•${NC} ${GREEN}Click${NC} → Copy XPath to clipboard"
                echo -e "  ${CYAN}•${NC} ${GREEN}Long-press${NC} → Screenshot menu:"
                echo -e "      - Copy to clipboard"
                echo -e "      - Download PNG"
                echo -e "      - Upload & copy URL (imgbb)"
                echo ""
                echo -e "${GREEN}🖥️  ERUDA CONSOLE${NC}"
                echo ""
                echo -e "  Mobile-friendly developer console injected with the inspector script:"
                echo ""
                echo -e "  ${CYAN}•${NC} View console.log output"
                echo -e "  ${CYAN}•${NC} Inspect network requests"
                echo -e "  ${CYAN}•${NC} View DOM elements"
                echo -e "  ${CYAN}•${NC} Debug JavaScript errors"
                echo -e "  ${CYAN}•${NC} Check storage (localStorage, cookies)"
                echo ""
                echo -e "${YELLOW}💡 Both tools are injected via:${NC}"
                echo -e "   ${CYAN}injectors/web-inspector.js${NC}"
                ;;
        esac

        echo ""
        echo -e "${CYAN}──────────────────────────────────────────────────${NC}"
        echo -e "  ${CYAN}p${NC} Previous   ${CYAN}n${NC} Next   ${CYAN}a-d${NC} Jump   ${CYAN}x${NC} Back"
        echo -e "${CYAN}──────────────────────────────────────────────────${NC}"
        echo ""
        echo -e "${YELLOW}[$page/$total_pages]:${NC} \c"
        ui_read_choice help_choice

        case $help_choice in
            ""|n)
                if [ $page -lt $total_pages ]; then
                    page=$((page + 1))
                fi
                ;;
            p|b)
                if [ $page -gt 1 ]; then
                    page=$((page - 1))
                fi
                ;;
            x|q)
                ui_return_back
                return
                ;;
            a) page=1 ;;
            b) page=2 ;;
            c) page=3 ;;
            d) page=4 ;;
        esac
    done
}
show_mobile_guide() {
    clear
    ui_screen_header "Guide Mobile — Expo + Android"
    echo -e "Ce guide configure ton téléphone Android pour le dev en live."
    echo -e "Suis les étapes dans l'ordre. Ce qui est déjà fait sera ignoré."
    echo ""
    ui_pause "Appuie sur une touche pour commencer..."

    # ── ÉTAPE 1 : EAS CLI ──────────────────────────────────────────────────
    clear
    ui_screen_header "ÉTAPE 1/4 — Installation de EAS CLI"
    if command -v eas >/dev/null 2>&1; then
        local eas_ver
        eas_ver=$(eas --version 2>/dev/null | head -1)
        echo -e "  ${GREEN}✅ EAS CLI déjà installé${NC} ($eas_ver)"
    else
        echo -e "  ${YELLOW}⚠️  EAS CLI non trouvé. Installation...${NC}"
        echo ""
        npm install -g eas-cli
        if command -v eas >/dev/null 2>&1; then
            echo -e "  ${GREEN}✅ EAS CLI installé${NC}"
        else
            echo -e "  ${RED}❌ Échec de l'installation. Vérifie que npm est dispo.${NC}"
            echo ""
            ui_pause "Appuie sur une touche pour quitter le guide..."
            return 1
        fi
    fi
    echo ""
    ui_pause "Appuie sur une touche pour l'étape suivante..."

    # ── ÉTAPE 2 : Connexion EAS ────────────────────────────────────────────
    clear
    ui_screen_header "ÉTAPE 2/4 — Connexion Expo"
    local eas_user
    eas_user=$(eas whoami 2>/dev/null)
    if [ -n "$eas_user" ] && [[ "$eas_user" != *"Not logged"* ]]; then
        echo -e "  ${GREEN}✅ Connecté en tant que: $eas_user${NC}"
    else
        echo -e "  ${YELLOW}⚠️  Pas connecté à Expo. Lance la connexion...${NC}"
        echo ""
        eas login
        eas_user=$(eas whoami 2>/dev/null)
        if [ -n "$eas_user" ] && [[ "$eas_user" != *"Not logged"* ]]; then
            echo -e "  ${GREEN}✅ Connecté en tant que: $eas_user${NC}"
        else
            echo -e "  ${RED}❌ Connexion échouée. Réessaie depuis le guide.${NC}"
            echo ""
            ui_pause "Appuie sur une touche pour quitter..."
            return 1
        fi
    fi
    echo ""
    ui_pause "Appuie sur une touche pour l'étape suivante..."

    # ── ÉTAPE 3 : Build APK ────────────────────────────────────────────────
    clear
    ui_screen_header "ÉTAPE 3/4 — Build APK développement"
    echo -e "  ${BLUE}ℹ️  C'est la seule étape longue (10-15 min).${NC}"
    echo -e "  ${BLUE}   Le build tourne sur les serveurs Expo, pas sur ce serveur.${NC}"
    echo -e "  ${BLUE}   Tu fais ça UNE SEULE FOIS. Ensuite, l'APK reste sur ton tel.${NC}"
    echo ""

    # Lister les projets Expo disponibles
    local expo_projects=""
    for d in "$PROJECTS_DIR"/*/; do
        [ -f "${d}package.json" ] || continue
        if grep -q '"expo"' "${d}package.json" 2>/dev/null || grep -q '"expo-router"' "${d}package.json" 2>/dev/null; then
            expo_projects="$expo_projects$(basename "$d")\n"
        fi
    done
    expo_projects=$(printf "%b" "$expo_projects" | grep -v "^$")

    if [ -z "$expo_projects" ]; then
        echo -e "  ${YELLOW}⚠️  Aucun projet Expo trouvé dans $PROJECTS_DIR${NC}"
        echo -e "  ${BLUE}   Déploie d'abord ton projet depuis le menu principal (e = Deploy).${NC}"
        echo ""
        ui_pause "Appuie sur une touche pour quitter..."
        return 0
    fi

    local selected_project
    selected_project=$(echo "$expo_projects" | ui_choose "Sélectionne ton projet Expo:")

    if [ -z "$selected_project" ]; then
        echo -e "${BLUE}Annulé${NC}"
        return 0
    fi

    local project_dir="$PROJECTS_DIR/$selected_project"
    echo ""
    echo -e "  ${GREEN}Projet: $selected_project${NC}"
    echo ""
    echo -e "  ${YELLOW}Lancer le build Android? (o/y/N):${NC} \c"
    ui_read_choice build_confirm
    echo ""

    if [[ "$build_confirm" =~ ^(o|oui|y|yes)$ ]]; then
        echo ""
        echo -e "  ${BLUE}🔨 Build en cours... (ne ferme pas ce terminal)${NC}"
        echo ""
        cd "$project_dir" && eas build --profile development --platform android
        echo ""
        echo -e "  ${GREEN}✅ Build terminé ! Télécharge l'APK depuis le lien ci-dessus.${NC}"
        echo -e "  ${BLUE}   Installe-le sur ton téléphone Android.${NC}"
    else
        echo -e "  ${BLUE}Build ignoré — si tu as déjà l'APK sur ton tel, c'est bon.${NC}"
    fi
    echo ""
    ui_pause "Appuie sur une touche pour l'étape suivante..."

    # ── ÉTAPE 4 : Démarrer le serveur Metro ───────────────────────────────
    clear
    ui_screen_header "ÉTAPE 4/4 — Serveur développement"
    echo -e "  ${BLUE}Démarrage de $selected_project avec tunnel Expo...${NC}"
    echo ""
    env_start "$selected_project"
    echo ""

    # Attendre quelques secondes que le tunnel s'initialise
    echo -e "  ${BLUE}⏳ Attente de l'URL du tunnel (15 sec)...${NC}"
    sleep 15

    # Extraire l'URL du tunnel depuis les logs PM2
    local tunnel_url
    tunnel_url=$(pm2 logs "$selected_project" --lines 50 --nostream 2>/dev/null \
        | grep -oE 'https?://[a-zA-Z0-9._-]+\.exp\.direct[^ ]*' \
        | tail -1)

    echo ""
    ui_screen_header "Tout est prêt !" success
    if [ -n "$tunnel_url" ]; then
        echo -e "  ${YELLOW}URL du tunnel:${NC}"
        echo -e "  ${CYAN}$tunnel_url${NC}"
        echo ""
        echo -e "  ${BLUE}1. Ouvre l'APK dev build sur ton téléphone${NC}"
        echo -e "  ${BLUE}2. Entre cette URL ou scanne le QR${NC}"
        echo -e "  ${BLUE}3. Modifie ton code → l'app se recharge automatiquement 🎉${NC}"
    else
        echo -e "  ${YELLOW}URL pas encore visible — vérifie les logs:${NC}"
        echo -e "  ${CYAN}pm2 logs $selected_project --lines 30${NC}"
        echo ""
        echo -e "  ${BLUE}1. Ouvre l'APK dev build sur ton téléphone${NC}"
        echo -e "  ${BLUE}2. Entre l'URL exp:// depuis les logs${NC}"
        echo -e "  ${BLUE}3. Modifie ton code → l'app se recharge automatiquement 🎉${NC}"
    fi
    echo ""
    ui_pause "Appuie sur une touche pour revenir au menu..."
}
