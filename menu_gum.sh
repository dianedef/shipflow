#!/bin/bash
# ShipFlow — Gum-styled menu with instant keyboard shortcuts
# Sourced by shipflow.sh when gum is available
#
# Display: gum style (visual polish)
# Input: read -sn1 (instant single keypress, no Enter needed)
# Dynamic lists: gum filter (type-to-search for variable-length lists)

# Flush any buffered stdin (leftover keypresses from previous actions)
_flush_stdin() {
    while read -rsn1 -t 0.05 2>/dev/null; do :; done
}

# Display menu items with gum styling, read single keypress, dispatch
_gum_run_menu() {
    local title="$1"
    local subtitle="$2"
    shift 2

    local items=("$@")

    # Parse items
    local keys=()
    local actions=()
    local display_lines=()
    local first_section=true
    for item in "${items[@]}"; do
        local key label action
        key=$(echo "$item" | cut -d'|' -f1)
        label=$(echo "$item" | cut -d'|' -f2)
        action=$(echo "$item" | cut -d'|' -f3)

        if [ "$key" = "---" ]; then
            if [ "$first_section" = true ]; then
                first_section=false
            else
                display_lines+=("")
            fi
            display_lines+=("${label}")
        else
            display_lines+=("$(gum style --foreground 212 "${key})")  ${label}")
            keys+=("$key")
            actions+=("$action")
        fi
    done

    # Render items with gum style (box around the menu)
    # Padding "0 3" ensures uniform left indent — piped content's
    # leading whitespace can be stripped by gum on the first line,
    # so we let --padding handle all indentation instead.
    printf '%s\n' "${display_lines[@]}" | gum style \
        --border rounded --border-foreground 240 \
        --padding "0 3" --margin "0 2"

    echo ""

    # Flush leftover input, then read single keypress
    _flush_stdin
    local choice
    read -rsn1 choice
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    # Match and dispatch
    for ((j=0; j<${#keys[@]}; j++)); do
        local k
        k=$(echo "${keys[$j]}" | tr '[:upper:]' '[:lower:]')
        if [ "$choice" = "$k" ]; then
            local act="${actions[$j]}"
            [ "$act" = "__EXIT__" ] && return 1
            "$act"
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
    read -rsn1
}

# Advanced menu — loop with gum style
action_advanced() {
    while true; do
        clear
        gum style --foreground 212 --border-foreground 212 --border double \
            --align center --width 50 --margin "1 2" --padding "1 2" \
            "Advanced Options"

        _gum_run_menu "Advanced Options" "" "${ADVANCED_MENU_ITEMS[@]}"
        local rc=$?
        [ $rc -eq 1 ] && break
        [ $rc -eq 0 ] && _gum_pause
    done
}

# Main menu loop — gum styled display, instant keypress
run_menu() {
    while true; do
        clear
        print_header

        _gum_run_menu "Shipflow DevServer" "" "${MAIN_MENU_ITEMS[@]}"
        local rc=$?
        [ $rc -eq 0 ] && _gum_pause
    done
}
