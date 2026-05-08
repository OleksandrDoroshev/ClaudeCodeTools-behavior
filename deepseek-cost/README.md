# DeepSeek Cost Tracker

Status line для Claude Code, який коректно рахує вартість токенів
при використанні DeepSeek API (через `ANTHROPIC_BASE_URL`).

## Навіщо

Claude Code не знає ціни DeepSeek-моделей і не вміє рахувати вартість
при перемиканні Pro ↔ Flash. Цей скрипт вирішує обидві проблеми:
- Відстежує використання токенів per-model
- Рахує вартість за актуальними цінами DeepSeek
- Коректно обробляє `/model` перемикання all within one sesії

## Встановлення

1. Скопіюй скрипт:

```bash
cp statusline.py ~/.claude/statusline.py
chmod +x ~/.claude/statusline.py
```

2. Додай у `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "python3 ~/.claude/statusline.py"
  }
}
```

Або через команду: `/config statusLine`

3. Перезапусти Claude Code.

## Як виглядає

У статус-барі з'явиться рядок:
```
[DS:deepseek-v4-pro] $0.0423 | 48,251tk
```

При перемиканні на Flash через `/model`:
```
[DS:deepseek-v4-flash] $0.0441 | 52,100tk
```

Ціна росте повільніше на Flash, бо токени дешевші.

## Ціни

| Модель | Input ($/M tok) | Output ($/M tok) |
|--------|-----------------|-------------------|
| deepseek-v4-pro | 0.435 | 0.87 |
| deepseek-v4-flash | 0.14 | 0.28 |

Щоб оновити ціни — відредагуй `DEEPSEEK_PRICE` у скрипті.

## Вимкнення

Видали рядок `statusLine` із `settings.json` або видали скрипт.
При роботі з Anthropic API скрипт показує стандартну ціну, не заважає.

## Якщо переходиш на Opus/Anthropic

Цей скрипт не потрібен. Claude Code сам рахує вартість для Anthropic API.
Видали `statusLine` із `settings.json` — і все.
