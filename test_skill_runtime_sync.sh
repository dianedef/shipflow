#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPER="$ROOT_DIR/tools/shipflow_sync_skills.sh"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

make_skill() {
    local root="$1"
    local name="$2"
    mkdir -p "$root/skills/$name"
    printf -- '---\nname: %s\ndescription: test\n---\n' "$name" > "$root/skills/$name/SKILL.md"
}

assert_link() {
    local path="$1"
    local target="$2"
    test -L "$path"
    test "$(readlink -f "$path")" = "$(readlink -f "$target")"
    test -f "$path/SKILL.md"
}

run_helper() {
    "$HELPER" --shipflow-root "$SHIPFLOW_ROOT_TEST" --target-home "$TARGET_HOME_TEST" "$@"
}

SHIPFLOW_ROOT_TEST="$TMP_DIR/shipflow"
TARGET_HOME_TEST="$TMP_DIR/home"
mkdir -p "$SHIPFLOW_ROOT_TEST/skills" "$TARGET_HOME_TEST"
make_skill "$SHIPFLOW_ROOT_TEST" "sf-alpha"
make_skill "$SHIPFLOW_ROOT_TEST" "sf-beta"
make_skill "$SHIPFLOW_ROOT_TEST" "sf-gamma"

if run_helper --check --skill sf-alpha >/tmp/shipflow-sync-check.out 2>&1; then
    echo "expected missing check to fail" >&2
    exit 1
fi
grep -q "missing runtime=claude skill=sf-alpha" /tmp/shipflow-sync-check.out
grep -q "missing runtime=codex skill=sf-alpha" /tmp/shipflow-sync-check.out
test ! -e "$TARGET_HOME_TEST/.claude/skills/sf-alpha"

run_helper --repair --skill sf-alpha >/tmp/shipflow-sync-repair.out
assert_link "$TARGET_HOME_TEST/.claude/skills/sf-alpha" "$SHIPFLOW_ROOT_TEST/skills/sf-alpha"
assert_link "$TARGET_HOME_TEST/.codex/skills/sf-alpha" "$SHIPFLOW_ROOT_TEST/skills/sf-alpha"
grep -q "summary mode=repair" /tmp/shipflow-sync-repair.out

run_helper --check --skill sf-alpha >/tmp/shipflow-sync-ok.out
grep -q "ok runtime=claude skill=sf-alpha" /tmp/shipflow-sync-ok.out
grep -q "ok runtime=codex skill=sf-alpha" /tmp/shipflow-sync-ok.out

ln -sfn "$SHIPFLOW_ROOT_TEST/skills/sf-alpha" "$TARGET_HOME_TEST/.codex/skills/sf-beta"
if run_helper --check --skill sf-beta --runtime codex >/tmp/shipflow-sync-stale.out 2>&1; then
    echo "expected stale symlink check to fail" >&2
    exit 1
fi
grep -q "stale-or-broken-symlink" /tmp/shipflow-sync-stale.out
run_helper --repair --skill sf-beta --runtime codex >/tmp/shipflow-sync-stale-repair.out
assert_link "$TARGET_HOME_TEST/.codex/skills/sf-beta" "$SHIPFLOW_ROOT_TEST/skills/sf-beta"
test ! -e "$TARGET_HOME_TEST/.claude/skills/sf-beta"

mkdir -p "$TARGET_HOME_TEST/.claude/skills/sf-gamma"
if run_helper --repair --skill sf-gamma --runtime claude >/tmp/shipflow-sync-collision.out 2>&1; then
    echo "expected non-symlink collision to fail" >&2
    exit 1
fi
grep -q "non-symlink-existing" /tmp/shipflow-sync-collision.out
test -d "$TARGET_HOME_TEST/.claude/skills/sf-gamma"
test ! -L "$TARGET_HOME_TEST/.claude/skills/sf-gamma"

run_helper --repair --skill sf-gamma --runtime claude --backup-existing >/tmp/shipflow-sync-backup.out
assert_link "$TARGET_HOME_TEST/.claude/skills/sf-gamma" "$SHIPFLOW_ROOT_TEST/skills/sf-gamma"
grep -q "backed-up-existing" /tmp/shipflow-sync-backup.out

if run_helper --check --skill ../bad >/tmp/shipflow-sync-invalid.out 2>&1; then
    echo "expected invalid skill name to fail" >&2
    exit 1
fi
grep -q "invalid skill name" /tmp/shipflow-sync-invalid.out

if run_helper --check --skill sf--bad >/tmp/shipflow-sync-invalid2.out 2>&1; then
    echo "expected invalid double hyphen skill name to fail" >&2
    exit 1
fi
grep -q "invalid skill name" /tmp/shipflow-sync-invalid2.out

run_helper --repair --all --runtime codex >/tmp/shipflow-sync-all-codex.out
assert_link "$TARGET_HOME_TEST/.codex/skills/sf-alpha" "$SHIPFLOW_ROOT_TEST/skills/sf-alpha"
assert_link "$TARGET_HOME_TEST/.codex/skills/sf-beta" "$SHIPFLOW_ROOT_TEST/skills/sf-beta"
assert_link "$TARGET_HOME_TEST/.codex/skills/sf-gamma" "$SHIPFLOW_ROOT_TEST/skills/sf-gamma"

if find "$HOME/.codex/skills" -maxdepth 0 >/dev/null 2>&1; then
    test ! -e "$HOME/.codex/skills/sf-alpha-test-should-not-exist"
fi

echo "test_skill_runtime_sync: passed"
