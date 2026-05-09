#!/bin/bash
# ShipFlow — Gum-styled menu with instant keyboard shortcuts
# Sourced by shipflow.sh when gum is available
#
# Display: gum style (visual polish)
# Input: read -sn1 (instant single keypress, no Enter needed)
# Dynamic lists: gum filter (type-to-search for variable-length lists)

# Flush any buffered stdin (leftover keypresses from previous actions)
_flush_stdin() {
    if [ -r /dev/tty ] && { : < /dev/tty; } 2>/dev/null; then
        while read -rsn1 -t 0.05 _ < /dev/tty 2>/dev/null; do :; done
    fi
}

# Display menu items with gum styling, read single keypress, dispatch
_gum_run_menu() {
    local title="$1"
    local subtitle="$2"
    local action_display_mode="${3:-inline}"
    shift 3

    local items=("$@")

    # Parse items
    local keys=()
    local labels=()
    local actions=()
    local display_lines=()
    local left_lines=()
    local right_lines=()
    local first_section=true
    local left_first_section=true
    local right_first_section=true
    local section_count=0
    local side="left"
    local key_color=$'\033[38;5;212m'
    local color_reset=$'\033[0m'
    for item in "${items[@]}"; do
        local key label action
        IFS='|' read -r key label action <<< "$item"

        if [ "$key" = "---" ]; then
            section_count=$((section_count + 1))
            if [ "$action_display_mode" = "screen" ] && [ "$section_count" -gt 3 ]; then
                side="right"
            else
                side="left"
            fi

            if [ "$first_section" = true ]; then
                first_section=false
            else
                display_lines+=("")
            fi
            display_lines+=("${label}")

            if [ "$side" = "left" ]; then
                if [ "$left_first_section" = true ]; then
                    left_first_section=false
                else
                    left_lines+=("")
                fi
                left_lines+=("${label}")
            else
                if [ "$right_first_section" = true ]; then
                    right_first_section=false
                else
                    right_lines+=("")
                fi
                right_lines+=("${label}")
            fi
        else
            if [ "$action" = "__EXIT__" ] && [ ${#display_lines[@]} -gt 0 ]; then
                display_lines+=("")
                if [ "$side" = "left" ]; then
                    left_lines+=("")
                else
                    right_lines+=("")
                fi
            fi
            display_lines+=("${key_color}${key})${color_reset}  ${label}")
            if [ "$side" = "left" ]; then
                left_lines+=("${key}) ${label}")
            else
                right_lines+=("${key}) ${label}")
            fi
            keys+=("$key")
            labels+=("$label")
            actions+=("$action")
        fi
    done

    local render_lines=("${display_lines[@]}")
    local term_cols="${COLUMNS:-}"
    if ! [[ "$term_cols" =~ ^[0-9]+$ ]]; then
        term_cols=$(tput cols 2>/dev/null || printf '80')
    fi
    if [ "$action_display_mode" = "screen" ] && [ "${term_cols:-80}" -ge 96 ] && [ ${#right_lines[@]} -gt 0 ]; then
        render_lines=()
        local left_width=50
        local max_rows=${#left_lines[@]}
        [ ${#right_lines[@]} -gt "$max_rows" ] && max_rows=${#right_lines[@]}
        local i left right
        for ((i=0; i<max_rows; i++)); do
            left="${left_lines[$i]:-}"
            right="${right_lines[$i]:-}"
            render_lines+=("$(printf "%-${left_width}s  %s" "$left" "$right")")
        done
    fi

    # Render items with gum style (box around the menu)
    # Padding "0 3" ensures uniform left indent — piped content's
    # leading whitespace can be stripped by gum on the first line,
    # so we let --padding handle all indentation instead.
    printf '%s\n' "${render_lines[@]}" | gum style \
        --border rounded --border-foreground 240 \
        --padding "0 3" --margin "0 2"

    echo ""

    # Flush leftover input, then read single keypress
    _flush_stdin
    local choice
    ui_read_choice choice

    # Match and dispatch
    for ((j=0; j<${#keys[@]}; j++)); do
        local k
        k="${keys[$j],,}"
        if [ "$choice" = "$k" ]; then
            local label="${labels[$j]}"
            local act="${actions[$j]}"
            [ "$act" = "__EXIT__" ] && return 1
            ui_run_menu_action "$label" "$act" "$action_display_mode"
            return 0
        fi
    done

    # No match — just redraw
    return 2
}

# Pause after action — simple read, no gum (avoids Ctrl+C issues)
_gum_pause() {
    echo ""
    gum style --foreground 240 "  Appuie sur une touche pour continuer..."
    _flush_stdin
    local pause_key
    ui_read_key pause_key
}

_gum_run_nested_menu() {
    local header="$1"
    shift
    local items=("$@")

    while true; do
        clear
        gum style --foreground 212 --border-foreground 212 --border double \
            --align center --width 50 --margin "1 2" --padding "1 2" \
            "$header"
        echo ""

        _gum_run_menu "$header" "" "inline" "${items[@]}"
        local rc=$?
        if [ $rc -eq 1 ]; then
            ui_return_back
            break
        fi
        if [ $rc -eq 0 ]; then
            if ui_should_skip_next_pause; then
                continue
            fi
            _gum_pause
        fi
    done
}

action_environments_menu() { _gum_run_nested_menu "🧭 Environments" "${ENVIRONMENT_MENU_ITEMS[@]}"; }
action_tools_web_menu() { _gum_run_nested_menu "🧰 Tools" "${TOOLS_WEB_MENU_ITEMS[@]}"; }
action_system_menu() { _gum_run_nested_menu "⚙️ System" "${SYSTEM_MENU_ITEMS[@]}"; }
action_agents_ci_menu() { _gum_run_nested_menu "🤖 Agents" "${AGENTS_CI_MENU_ITEMS[@]}"; }

# Legacy advanced menu entry point
action_advanced() { _gum_run_nested_menu "Advanced Options" "${ADVANCED_MENU_ITEMS[@]}"; }

# Main menu loop — gum styled display, instant keypress
run_menu() {
    while true; do
        clear
        print_header

        _gum_run_menu "Shipflow DevServer" "" "screen" "${MAIN_MENU_ITEMS[@]}"
        local rc=$?
        if [ $rc -eq 0 ]; then
            if ui_should_skip_next_pause; then
                continue
            fi
            _gum_pause
        fi
    done
}
