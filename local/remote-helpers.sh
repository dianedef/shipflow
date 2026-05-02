#!/bin/bash
# Shared SSH and remote PM2 helpers for ShipFlow local tunnel tools.

expand_identity_path() {
    local identity_file="$1"
    case "$identity_file" in
        "~") echo "$HOME" ;;
        "~/"*) echo "$HOME/${identity_file#~/}" ;;
        *) echo "$identity_file" ;;
    esac
}

normalize_identity_path() {
    local identity_file="$1"
    [ -z "$identity_file" ] && return 0

    local expanded
    expanded=$(expand_identity_path "$identity_file")

    case "$expanded" in
        /*)
            echo "$expanded"
            ;;
        *)
            local dir="${expanded%/*}"
            local base="${expanded##*/}"
            if [ "$dir" = "$expanded" ]; then
                dir="."
            fi

            local abs_dir
            if abs_dir=$(cd "$dir" 2>/dev/null && pwd -P); then
                echo "$abs_dir/$base"
            else
                echo "$(pwd -P)/$expanded"
            fi
            ;;
    esac
}

validate_connection_target() {
    local target="$1"
    [[ -n "$target" ]] || return 1
    [[ "$target" != -* ]] || return 1
    [[ "$target" =~ ^[a-zA-Z0-9._@-]+$ ]] || return 1
}

validate_identity_file() {
    local identity_file="$1"
    [ -z "$identity_file" ] && return 0
    [[ "$identity_file" != -* ]] || return 1
    [[ "$identity_file" != *$'\n'* ]] || return 1
    [ -f "$(normalize_identity_path "$identity_file")" ] || return 1
}

validate_tcp_port() {
    local port="$1"
    [[ "$port" =~ ^[0-9]+$ ]] || return 1
    [ "$((10#$port))" -ge 1 ] && [ "$((10#$port))" -le 65535 ]
}

ssh_args() {
    printf '%s\n' "-o" "ConnectTimeout=7"
    if [ -n "${SSH_IDENTITY_FILE:-}" ]; then
        printf '%s\n' "-i" "$(normalize_identity_path "$SSH_IDENTITY_FILE")" "-o" "IdentitiesOnly=yes"
    fi
}

run_remote_ssh() {
    local args=()
    while IFS= read -r arg; do
        args+=("$arg")
    done < <(ssh_args)
    ssh "${args[@]}" "$REMOTE_HOST" "$@"
}

shipflow_remote_pm2_ports_command() {
    local format="${1:-lines}"
    local separator="\\n"
    if [ "$format" = "comma" ]; then
        separator=","
    fi

    cat <<EOF
pm2 jlist 2>/dev/null | node -e '
const fs = require("fs");
try {
  const apps = JSON.parse(fs.readFileSync(0, "utf8"));
  const ports = [];
  for (const app of apps) {
    const pm2Env = app.pm2_env || {};
    if (pm2Env.status !== "online") continue;
    const env = pm2Env.env || {};
    const portValue = String(env.PORT || env.port || "");
    if (!/^[0-9]+$/.test(portValue)) continue;
    const port = Number(portValue);
    if (port < 1 || port > 65535) continue;
    const name = String(app.name || "unknown").replace(/[,:\\n\\r]/g, " ").trim() || "unknown";
    ports.push(\`\${port}:\${name}\`);
  }
  process.stdout.write(ports.join("$separator"));
} catch {}
'
EOF
}
