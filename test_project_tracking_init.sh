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

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

export SHIPFLOW_DATA_DIR="$tmp_root/shipflow_data"

project_dir="$tmp_root/stale_symlink_project"
real_tasks_project_dir="$tmp_root/real_tasks_project"
clean_project_dir="$tmp_root/clean_project"
external_symlink_project_dir="$tmp_root/external_symlink_project"
external_target="$tmp_root/external-tasks.md"
mkdir -p "$project_dir" "$real_tasks_project_dir" "$clean_project_dir" "$external_symlink_project_dir"

ln -s "/home/claude/shipflow_data/projects/old-project/TASKS.md" "$project_dir/TASKS.md"
echo "# App-owned tasks" > "$real_tasks_project_dir/TASKS.md"
echo "# External tasks" > "$external_target"
ln -s "$external_target" "$external_symlink_project_dir/TASKS.md"

assert_ok "fixture has a broken TASKS.md symlink" test -L "$project_dir/TASKS.md"
assert_ok "fixture symlink target is missing" bash -lc "test ! -e '$project_dir/TASKS.md'"
assert_ok "shipflow_init_project removes stale ShipFlow TASKS.md symlink" shipflow_init_project "stale-symlink-project" "$project_dir"
assert_ok "stale project TASKS.md symlink was removed" test ! -e "$project_dir/TASKS.md"
assert_ok "ShipFlow-owned TASKS.md exists in shipflow_data" test -f "$SHIPFLOW_DATA_DIR/projects/stale-symlink-project/TASKS.md"
assert_ok "shipflow_init_project does not create project TASKS.md symlink" shipflow_init_project "clean-project" "$clean_project_dir"
assert_ok "clean project has no local TASKS.md" test ! -e "$clean_project_dir/TASKS.md"
assert_ok "clean project tracking exists only in shipflow_data" test -f "$SHIPFLOW_DATA_DIR/projects/clean-project/TASKS.md"
assert_ok "shipflow_init_project leaves real project TASKS.md untouched" shipflow_init_project "real-tasks-project" "$real_tasks_project_dir"
assert_ok "real project TASKS.md remains a regular file" test -f "$real_tasks_project_dir/TASKS.md"
assert_ok "real project TASKS.md content is preserved" grep -q "App-owned tasks" "$real_tasks_project_dir/TASKS.md"
assert_ok "shipflow_init_project leaves non-ShipFlow TASKS.md symlink untouched" shipflow_init_project "external-symlink-project" "$external_symlink_project_dir"
assert_ok "external project TASKS.md remains a symlink" test -L "$external_symlink_project_dir/TASKS.md"
assert_ok "external project TASKS.md symlink target is preserved" test "$(readlink "$external_symlink_project_dir/TASKS.md")" = "$external_target"

echo ""
echo "Tests passed: $pass_count/$test_count"
[ "$pass_count" -eq "$test_count" ]
