import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { spawn } from "node:child_process";
import { basename, join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

/**
 * Desktop notifications (the quickshell notch, or any libnotify daemon):
 *  - when pi blocks on a prompt (confirm / select / input / editor / custom)
 *  - when a turn settles, with the project name as title and a short
 *    summary of what finished as the body.
 *
 * ponytail: notify-send only (no dbus lib), last assistant text as the
 * "what finished" summary. Upgrade to a real summary if one line isn't enough.
 */

const ICON = join(dirname(fileURLToPath(import.meta.url)), "..", "assets", "notify-icon.jpg");

function notify(title: string, body: string, urgency: "low" | "normal" | "critical") {
  spawn("notify-send", ["-a", "pi", "-i", ICON, "-u", urgency, title, body], {
    stdio: "ignore",
    detached: true,
  }).unref();
}

function firstLines(text: string, max = 200): string {
  const t = text.replace(/\s+/g, " ").trim();
  return t.length > max ? `${t.slice(0, max - 1)}…` : t;
}

export default function (pi: ExtensionAPI) {
  let lastAssistantText = "";

  pi.on("message_end", (event) => {
    if (event.message.role !== "assistant") return;
    const text = event.message.content
      .filter((c): c is { type: "text"; text: string } => c.type === "text")
      .map((c) => c.text)
      .join("\n");
    if (text.trim()) lastAssistantText = text;
  });

  pi.on("ui_prompt_start", (event, ctx) => {
    notify(
      `pi: ${basename(ctx.cwd)} needs you`,
      event.title ?? `waiting for ${event.kind}`,
      "critical",
    );
  });

  pi.on("agent_settled", (_event, ctx) => {
    notify(
      `pi: ${basename(ctx.cwd)} done`,
      lastAssistantText ? firstLines(lastAssistantText) : "turn finished",
      "normal",
    );
    lastAssistantText = "";
  });
}
