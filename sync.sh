#!/usr/bin/env bash
# Синхронізація між ~/.claude/ та git-репо ClaudeCodeTools-behavior.
#
# Без аргументів: push — копіює з ~/.claude/ → репо    (перед комітом).
# --pull:        pull — копіює з репо → ~/.claude/    (після клону/оновлення).

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

FILES=(
    CLAUDE.md
    statusline.py
)

DIRS=(
    agents
    skills
)

die() { echo "[sync] ПОМИЛКА: $1" >&2; exit 1; }

push_changes() {
    echo "[sync] push: ~/.claude/ → $REPO_DIR"
    for f in "${FILES[@]}"; do
        [ -f "$CLAUDE_DIR/$f" ] && cp "$CLAUDE_DIR/$f" "$REPO_DIR/$f" && echo "  ✓ $f"
    done
    for d in "${DIRS[@]}"; do
        [ -d "$CLAUDE_DIR/$d" ] && rm -rf "$REPO_DIR/$d" && cp -r "$CLAUDE_DIR/$d" "$REPO_DIR/$d" && echo "  ✓ $d/"
    done
    echo "[sync] готово. Тепер: cd $REPO_DIR && git diff"
}

pull_changes() {
    echo "[sync] pull: $REPO_DIR → ~/.claude/"
    [ -d "$CLAUDE_DIR" ] || mkdir -p "$CLAUDE_DIR"
    for f in "${FILES[@]}"; do
        [ -f "$REPO_DIR/$f" ] && cp "$REPO_DIR/$f" "$CLAUDE_DIR/$f" && echo "  ✓ $f"
    done
    [ -f "$REPO_DIR/statusline.py" ] && chmod +x "$CLAUDE_DIR/statusline.py"
    for d in "${DIRS[@]}"; do
        [ -d "$REPO_DIR/$d" ] && rm -rf "$CLAUDE_DIR/$d" && cp -r "$REPO_DIR/$d" "$CLAUDE_DIR/$d" && echo "  ✓ $d/"
    done
    echo "[sync] готово. Файли в ~/.claude/ оновлено."
}

case "${1:-}" in
    --pull) pull_changes ;;
    "")     push_changes ;;
    *)      die "невідомий аргумент: $1. Використовуй: --pull або без аргументів для push." ;;
esac
