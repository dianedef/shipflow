#!/bin/bash
# ShipFlow — Pure bash menu (no gum dependency)
# Sourced by shipflow.sh when gum is NOT available

_bash_flush_stdin() {
    if [ -r /dev/tty ] && { : < /dev/tty; } 2>/dev/null; then
        while read -rsn1 -t 0.05 _ < /dev/tty 2>/dev/null; do :; done
    fi
}

# Display menu items from array with sections and read choice
_bash_run_menu() {
    local action_display_mode="${1:-inline}"
    shift || true
    local items=("$@")

    local keys=()
    local labels=()
    local actions=()
    local item_count=0
    local display_lines=()
    local left_lines=()
    local right_lines=()
    local first_section=true
    local left_first_section=true
    local right_first_section=true
    local section_count=0
    local side="left"

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
            display_lines+=("  ${key}) ${label}")
            if [ "$side" = "left" ]; then
                left_lines+=("  ${key}) ${label}")
            else
                right_lines+=("  ${key}) ${label}")
            fi
            keys+=("$key")
            labels+=("$label")
            actions+=("$action")
            ((item_count++))
        fi
    done

    local term_cols="${COLUMNS:-}"
    if ! [[ "$term_cols" =~ ^[0-9]+$ ]]; then
        term_cols=$(tput cols 2>/dev/null || printf '80')
    fi
    if [ "$action_display_mode" = "screen" ] && [ "${term_cols:-80}" -ge 96 ] && [ ${#right_lines[@]} -gt 0 ]; then
        local left_width=52
        local max_rows=${#left_lines[@]}
        [ ${#right_lines[@]} -gt "$max_rows" ] && max_rows=${#right_lines[@]}
        local i left right
        for ((i=0; i<max_rows; i++)); do
            left="${left_lines[$i]:-}"
            right="${right_lines[$i]:-}"
            printf "%-${left_width}s  %s\n" "$left" "$right"
        done
    else
        local line
        for line in "${display_lines[@]}"; do
            if [ -z "$line" ]; then
                echo ""
            elif [[ "$line" == ---* ]]; then
                echo -e "${BLUE}${line}${NC}"
            elif [[ "$line" != "  "* && ( "$line" == *ENVIRONMENT* || "$line" == *BATCH* || "$line" == *INSPECT* || "$line" == *WEB* || "$line" == *SDKS* || "$line" == *SYSTEM* || "$line" == *ACCESS* || "$line" == *AGENTS* || "$line" == *CI* ) ]]; then
                echo -e "${BLUE}${line}${NC}"
            else
                echo "$line"
            fi
        done
    fi
    echo ""
    echo -e "${YELLOW}Your choice:${NC} \c"

    local choice
    ui_read_choice choice

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

    if [ -n "$choice" ]; then
        echo -e "${RED}Invalid option${NC}"
    fi
    return 0
}

_bash_run_nested_menu() {
    local header="$1"
    shift
    local items=("$@")

    while true; do
        clear
        echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
        printf "                 ${YELLOW}%s${NC}\n" "$header"
        echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
        echo ""

        _bash_run_menu "inline" "${items[@]}"
        local rc=$?
        if [ $rc -eq 1 ]; then
            ui_return_back
            break
        fi
        if [ $rc -eq 0 ]; then
            if ui_should_skip_next_pause; then
                continue
            fi
            ui_pause "Appuie sur une touche pour continuer..."
        fi
    done
}

action_environments_menu() { _bash_run_nested_menu "🧭 Environments" "${ENVIRONMENT_MENU_ITEMS[@]}"; }
action_tools_web_menu() { _bash_run_nested_menu "🧰 Tools" "${TOOLS_WEB_MENU_ITEMS[@]}"; }
action_system_menu() { _bash_run_nested_menu "⚙️ System" "${SYSTEM_MENU_ITEMS[@]}"; }
action_agents_ci_menu() { _bash_run_nested_menu "🤖 Agents" "${AGENTS_CI_MENU_ITEMS[@]}"; }

# Legacy advanced menu entry point
action_advanced() { _bash_run_nested_menu "Advanced Options" "${ADVANCED_MENU_ITEMS[@]}"; }

# Main menu loop — pure bash
run_menu() {
    while true; do
        clear
        print_header

        _bash_run_menu "screen" "${MAIN_MENU_ITEMS[@]}"
        local rc=$?
        if [ $rc -eq 0 ]; then
            if ui_should_skip_next_pause; then
                continue
            fi
            ui_pause "Appuie sur une touche pour continuer..."
        fi
    done
}
