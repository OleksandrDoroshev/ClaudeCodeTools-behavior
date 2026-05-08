# Налаштування на іншій машині

## Перший запуск

```bash
# 1. Клонуй репо
cd ~
git clone https://github.com/OleksandrDoroshev/ClaudeCodeTools-behavior.git

# 2. Синхронізуй у ~/.claude/
cd ~/ClaudeCodeTools-behavior
./sync.sh --pull

# 3. Додай statusLine у settings.json
```

### statusLine (вручну)

Додай у `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.claude/statusline.py"
  }
}
```

Перевір:

```bash
ls ~/.claude/CLAUDE.md          # головний файл
ls ~/.claude/skills/            # 5 скілів
ls ~/.claude/agents/            # 1 агент
ls ~/.claude/statusline.py      # трекер витрат
```

Перезапусти Claude Code. Готово.

## Після змін поведінки

Якщо змінив CLAUDE.md, skills/, agents/ у роботі з Claude Code:

```bash
cd ~/ClaudeCodeTools-behavior
./sync.sh          # ~/.claude/ → репо
git diff            # перевір що змінилось
git commit -am "опис змін"
git push
```

## Після оновлень з репо

```bash
cd ~/ClaudeCodeTools-behavior
git pull
./sync.sh --pull    # репо → ~/.claude/
```
