# ClaudeCodeTools-behavior

Наставницький конфіг для Claude Code: правила, скіли, агенти, трекінг витрат.

## Що всередині

```
├── CLAUDE.md              ← головний файл правил
├── skills/
│   ├── preflight/          ← аналіз плану перед стартом
│   ├── mentor-review/      ← рев'ю після завершення
│   ├── reflect/            ← ретроспектива сесії
│   ├── compare/            ← порівняння підходів
│   └── explain/            ← пояснення з перших принципів
├── agents/
│   └── rubber-duck.md      ← сократівський дебагер
├── statusline.py           ← трекінг витрат DeepSeek
├── sync.sh                 ← синхронізація з ~/.claude/
└── README.md
```

## Синхронізація

Це репо — джерело правди. Синхронізація між ним і `~/.claude/`:

```bash
# Перед комітом: ~/.claude/ → репо
./sync.sh

# Після клону/оновлення: репо → ~/.claude/
./sync.sh --pull
```

**Не синхронізується:** `settings.json` (бо містить локальні налаштування, theme тощо). Для `statusLine` треба вручну додати в `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.claude/statusline.py"
  }
}
```

## Робочий цикл

1. Працюєш із Claude Code — змінюєш поведінку в `~/.claude/`
2. `./sync.sh` — копіює зміни в репо
3. `git diff` — перевіряєш
4. `git commit && git push` — фіксуєш
5. На іншій машині: `git pull && ./sync.sh --pull`
