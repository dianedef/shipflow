#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export SHIPFLOW_ERROR_TRAPS=false
export SHIPFLOW_STRICT_MODE=false

source "$SCRIPT_DIR/config.sh"
source "$SCRIPT_DIR/lib.sh"

trap - ERR 2>/dev/null || true

test_count=0
pass_count=0

assert_ok() {
    local test_name=$1
    shift
    ((test_count++))
    if "$@" >/dev/null 2>&1; then
        echo "✓ $test_name"
        ((pass_count++))
        return 0
    fi
    echo "✗ $test_name"
    return 1
}

expect_fail() {
    "$@" >/dev/null 2>&1
    [ $? -ne 0 ]
}

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

flutter_dir="$tmp_root/flutter_app"
dart_dir="$tmp_root/dart_app"
mkdir -p "$flutter_dir" "$dart_dir"

cat > "$flutter_dir/pubspec.yaml" <<'EOF'
name: flutter_app
flutter:
  uses-material-design: true
EOF

cat > "$dart_dir/pubspec.yaml" <<'EOF'
name: dart_app
environment:
  sdk: ">=3.0.0 <4.0.0"
EOF

assert_ok "detect_pubspec_kind: flutter" test "$(detect_pubspec_kind "$flutter_dir")" = "flutter"
assert_ok "detect_pubspec_kind: dart" test "$(detect_pubspec_kind "$dart_dir")" = "dart"
assert_ok "config preserves Dart package override" bash -lc "export SHIPFLOW_FLOX_DART_PACKAGES='dart@custom'; source '$SCRIPT_DIR/config.sh' && test \"\$SHIPFLOW_FLOX_DART_PACKAGES\" = 'dart@custom'"
assert_ok "config preserves Flutter package override" bash -lc "export SHIPFLOW_FLOX_FLUTTER_PACKAGES='flutter@custom'; source '$SCRIPT_DIR/config.sh' && test \"\$SHIPFLOW_FLOX_FLUTTER_PACKAGES\" = 'flutter@custom'"
assert_ok "detect_dev_command uses project Flox Dart command" bash -lc "source '$SCRIPT_DIR/config.sh' && source '$SCRIPT_DIR/lib.sh' && cmd=\$(detect_dev_command '$dart_dir') && [[ \"\$cmd\" == dart\\ pub\\ get* ]] && [[ \"\$cmd\" != *'/opt/flutter'* ]] && [[ \"\$cmd\" != *'.flutter-sdk'* ]]"
assert_ok "flutter tmux session name is stable" test "$(flutter_web_session_name "My App")" = "shipflow-flutter-my-app"
assert_ok "validate token: dart" validate_flox_runtime_package_token "dart"
assert_ok "validate token: flutter pinned" validate_flox_runtime_package_token "flutter@3.41.5-sdk-links"
assert_ok "validate token: dotted package" validate_flox_runtime_package_token "python312Packages.pytest"
assert_ok "reject token: option --help" expect_fail validate_flox_runtime_package_token "--help"
assert_ok "reject token: option -v" expect_fail validate_flox_runtime_package_token "-v"
assert_ok "reject token: path /tmp/pkg" expect_fail validate_flox_runtime_package_token "/tmp/pkg"
assert_ok "reject token: flake style github:" expect_fail validate_flox_runtime_package_token "github:nixos/nixpkgs"
assert_ok "reject token: quote" expect_fail validate_flox_runtime_package_token "flutter'bad"
assert_ok "reject token: command substitution" expect_fail validate_flox_runtime_package_token "\$(id)"

unsafe_marker="$tmp_root/unsafe-marker"
SHIPFLOW_FLOX_FLUTTER_PACKAGES="flutter;touch $unsafe_marker"
assert_ok "ensure_flox_runtime_packages rejects shell metachar override" expect_fail ensure_flox_runtime_packages "$flutter_dir" "flutter" "flutter"
assert_ok "unsafe override does not execute marker command" test ! -e "$unsafe_marker"

SHIPFLOW_FLOX_FLUTTER_PACKAGES="--help"
assert_ok "ensure_flox_runtime_packages rejects leading-dash override" expect_fail ensure_flox_runtime_packages "$flutter_dir" "flutter" "flutter"

export SHIPFLOW_FLUTTER_WEB_SESSIONS_FILE="$tmp_root/flutter-web-sessions.tsv"
assert_ok "flutter registry writes session entry" flutter_web_write_registry_entry "flutter_app" "3099" "$flutter_dir" "shipflow-flutter-flutter_app"
assert_ok "flutter registry resolves project port" test "$(flutter_web_registered_port_for_project "$flutter_dir")" = "3099"
assert_ok "flutter registry removes session entry" bash -lc "source '$SCRIPT_DIR/config.sh' && source '$SCRIPT_DIR/lib.sh' && export SHIPFLOW_FLUTTER_WEB_SESSIONS_FILE='$SHIPFLOW_FLUTTER_WEB_SESSIONS_FILE' && flutter_web_remove_registry_entry 'shipflow-flutter-flutter_app' && test -z \"\$(flutter_web_registered_line_for_project '$flutter_dir')\""

echo ""
echo "Tests passed: $pass_count/$test_count"
[ "$pass_count" -eq "$test_count" ]
