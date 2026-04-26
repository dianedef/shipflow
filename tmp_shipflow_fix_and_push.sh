#!/usr/bin/env bash
set -euo pipefail

cd /home/claude/shipflow

sudo chown -R claude:claude .git/objects/8d .git/objects/a2

git commit -F - <<'EOF'
Update skill routing and documentation references

- make documentation freshness gate references absolute
- extend model routing guidance for Codex/OpenAI and Claude Code
- add OpenAI Docs MCP to init guidance

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
EOF

git push || git push -u origin main
