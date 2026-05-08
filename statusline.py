#!/usr/bin/env python3
"""Claude Code status line with per-model cost tracking.

Tracks cumulative token usage per model across /model switches so that
cost is always calculated at the correct per-model pricing. When you
switch from Pro to Flash mid-session, Pro tokens are priced at Pro rates
and Flash tokens at Flash rates — no averaging, no approximation.

State is persisted in TMPDIR so it survives across status line invocations
but auto-cleans on reboot.
"""

import json
import os
import sys

STATE_FILE = os.path.join(os.environ.get("TMPDIR", "/tmp"), "claude-cost-state.json")

DEEPSEEK_PRICE = {
    "deepseek-v4-pro": {"input": 0.435, "output": 0.87},
    "deepseek-v4-flash": {"input": 0.14, "output": 0.28},
}


def detect_provider():
    base_url = os.environ.get("ANTHROPIC_BASE_URL", "")
    return "deepseek" if "deepseek" in base_url else "anthropic"


def extract_model(raw_name):
    return raw_name.split("[")[0].strip() if raw_name else None


def load_state():
    try:
        with open(STATE_FILE) as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {"models": {}, "last_input": 0, "last_output": 0}


def save_state(state):
    try:
        with open(STATE_FILE, "w") as f:
            json.dump(state, f)
    except OSError:
        pass


def compute_model_cost(model, tokens):
    prices = DEEPSEEK_PRICE.get(model)
    if not prices:
        return None
    inp, out = tokens
    return (inp * prices["input"] + out * prices["output"]) / 1_000_000


def format_cost(cost):
    if cost < 0.001:
        return f"${cost:.6f}"
    if cost < 0.01:
        return f"${cost:.4f}"
    if cost < 1.0:
        return f"${cost:.3f}"
    return f"${cost:.2f}"


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, TypeError):
        print("")
        return

    provider = detect_provider()
    if provider == "anthropic":
        cost = data.get("cost", {}).get("total_cost_usd")
        raw = data.get("model", {}).get("display_name", "?")
        print(f"[AN:{raw}] ${cost:.4f}" if cost is not None else f"[AN:{raw}]")
        return

    raw_model = data.get("model", {}).get("display_name", "?")
    model = extract_model(raw_model) or raw_model

    total_inp = data.get("context_window", {}).get("total_input_tokens", 0) or 0
    total_out = data.get("context_window", {}).get("total_output_tokens", 0) or 0

    if total_inp == 0 and total_out == 0:
        print(f"[DS:{model}] —")
        return

    # Attribute the delta tokens to the currently active model
    state = load_state()
    delta_inp = max(0, total_inp - state.get("last_input", 0))
    delta_out = max(0, total_out - state.get("last_output", 0))

    if delta_inp > 0 or delta_out > 0:
        m = state.setdefault("models", {}).setdefault(model, {"input_tokens": 0, "output_tokens": 0})
        m["input_tokens"] += delta_inp
        m["output_tokens"] += delta_out

    state["last_input"] = total_inp
    state["last_output"] = total_out
    save_state(state)

    # Sum cost across all models ever used in this session
    total_cost = 0.0
    for m, tokens in state.get("models", {}).items():
        c = compute_model_cost(m, (tokens["input_tokens"], tokens["output_tokens"]))
        if c is not None:
            total_cost += c

    print(f"[DS:{model}] {format_cost(total_cost)} | {total_inp + total_out:,}tk")


if __name__ == "__main__":
    main()
