import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

/**
 * Loop guard: detects when the agent repeats the same tool call (same tool +
 * same arguments) too many times in a row and interrupts with a forced
 * "ask the user" instruction instead of letting it burn tokens looping.
 *
 * ponytail: naive exact-match repeat counter (no semantic similarity), reset
 * per session. Upgrade to fuzzy/semantic loop detection if agents start
 * looping via near-identical-but-not-exact calls.
 */

const REPEAT_THRESHOLD = 3;

function keyFor(toolName: string, input: unknown): string {
  try {
    return `${toolName}:${JSON.stringify(input)}`;
  } catch {
    return `${toolName}:${String(input)}`;
  }
}

export default function (pi: ExtensionAPI) {
  let lastKey: string | null = null;
  let repeatCount = 0;
  let warned = false;

  pi.on("session_start", () => {
    lastKey = null;
    repeatCount = 0;
    warned = false;
  });

  pi.on("turn_start", () => {
    // A fresh turn starting normally means the model is making progress;
    // only the tool_call handler tracks exact repeats across turns.
  });

  pi.on("tool_call", async (event, ctx) => {
    const key = keyFor(event.toolName, event.input);

    if (key === lastKey) {
      repeatCount += 1;
    } else {
      lastKey = key;
      repeatCount = 1;
      warned = false;
    }

    if (repeatCount >= REPEAT_THRESHOLD && !warned) {
      warned = true;
      if (ctx.hasUI) {
        ctx.ui.notify(
          `Detected ${repeatCount}x repeated ${event.toolName} call — asking the model to stop and check with you instead of looping.`,
          "warning",
        );
      }
      return {
        block: true,
        reason:
          "STOP: you have repeated this exact tool call multiple times in a row without new information. " +
          "Do not retry it again. Instead, call the ask_user (or ask_user_choice) tool to ask the user what to do next, " +
          "rather than writing the question as plain text. Wait for their answer before taking any further action.",
      };
    }
  });
}
