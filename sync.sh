#!/bin/bash
# sync.sh — двостороння синхронізація між ~/.claude/ і git-репо
#
# sync.sh         — копіює ~/.claude/ → репо (зберегти зміни)
# sync.sh --pull  — копіює репо → ~/.claude/ (застосувати зміни)

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$HOME/.claude"
ITEMS=("CLAUDE.md" "skills" "agents")

pull() {
    for item in "${ITEMS[@]}"; do
        if [ -e "$REPO_DIR/.claude/$item" ]; then
            rm -rf "$SOURCE/$item" 2>/dev/null || true
            cp -R "$REPO_DIR/.claude/$item" "$SOURCE/$item"
            echo "✓ $item → ~/.claude/"
        else
            echo "✗ .claude/$item не знайдено в репо"
        fi
    done
    echo "Готово: репо → ~/.claude/"
}

push() {
    for item in "${ITEMS[@]}"; do
        if [ -e "$SOURCE/$item" ]; then
            rm -rf "$REPO_DIR/.claude/$item" 2>/dev/null || true
            cp -R "$SOURCE/$item" "$REPO_DIR/.claude/$item"
            echo "✓ $item → репо"
        else
            echo "✗ $item не знайдено в ~/.claude/"
        fi
    done
    echo "Готово: ~/.claude/ → репо"
}

case "${1:-}" in
    --pull) pull ;;
    --push) push ;;
    *)      push ;;
esac
