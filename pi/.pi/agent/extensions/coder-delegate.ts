import type {
  ExtensionAPI,
  ExtensionContext,
  ExtensionCommandContext,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

interface CoderPaneState {
  paneId: string;
  cwd: string;
  createdAt: number;
}

function statePath(cwd: string) {
  return join(cwd, ".pi", "coder-pane.json");
}

function loadState(cwd: string): CoderPaneState | null {
  try {
    const raw = readFileSync(statePath(cwd), "utf8");
    return JSON.parse(raw) as CoderPaneState;
  } catch {
    return null;
  }
}

function saveState(cwd: string, state: CoderPaneState) {
  const dir = join(cwd, ".pi");
  if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
  writeFileSync(statePath(cwd), JSON.stringify(state, null, 2));
}

function paneAlive(paneId: string): boolean {
  const res = spawnSync("tmux", ["list-panes", "-a", "-F", "#{pane_id}"], { encoding: "utf8" });
  if (res.status !== 0) return false;
  return res.stdout
    .split("\n")
    .map((s) => s.trim())
    .includes(paneId);
}

/** Lists panes of the CURRENT window only (no -a). */
function paneInCurrentWindow(paneId: string): boolean {
  const res = spawnSync("tmux", ["list-panes", "-F", "#{pane_id}"], { encoding: "utf8" });
  return (
    res.status === 0 && res.stdout.split("\n").map((s) => s.trim()).includes(paneId)
  );
}

// A zoomed pane (resize-pane -Z) covers the whole window and hides every
// other pane — the split exists and receives keys, but is invisible. Unzoom it.
function unzoomWindow() {
  const res = spawnSync("tmux", ["display-message", "-p", "#{window_zoomed_flag}"], {
    encoding: "utf8",
  });
  if (res.status === 0 && res.stdout.trim() === "1") {
    spawnSync("tmux", ["resize-pane", "-Z"]);
  }
}

/**
 * Extract readable text from an AgentMessage for the handoff transcript.
 * Skips raw tool call/result payloads (noisy) but keeps text and
 * compaction/branch summaries (they carry forward earlier context).
 */
function messageText(message: any): string | null {
  if (!message) return null;
  const role = message.role;
  if (role === "user" || role === "assistant") {
    const content = message.content;
    if (typeof content === "string") return content.trim() || null;
    if (Array.isArray(content)) {
      const text = content
        .filter((c: any) => c?.type === "text")
        .map((c: any) => c.text)
        .join("\n")
        .trim();
      return text || null;
    }
    return null;
  }
  if (role === "compactionSummary" || role === "branchSummary") {
    return message.summary?.trim() || null;
  }
  return null;
}

/**
 * Build a markdown transcript of the plan agent's conversation so the coder
 * agent (a brand new pi session with no shared memory) can read the actual
 * plan instead of only whatever short task string was typed at spawn time.
 *
 * ponytail: dumps user+assistant text and summaries verbatim, no LLM
 * re-summarization step. Upgrade to a compacted/summarized handoff if
 * transcripts get too large for the coder's context window.
 */
function buildPlanHandoff(ctx: ExtensionContext): string {
  const entries = ctx.sessionManager.buildContextEntries();
  const lines: string[] = ["# Plan handoff", ""];
  for (const entry of entries) {
    if (entry.type !== "message") continue;
    const text = messageText((entry as any).message);
    if (!text) continue;
    const role = (entry as any).message.role;
    const heading = role === "user" ? "## User" : role === "assistant" ? "## Plan Agent" : "## Summary";
    lines.push(heading, "", text, "");
  }
  return lines.join("\n");
}

function writePlanHandoff(cwd: string, transcript: string): string {
  const dir = join(cwd, ".pi", "handoff");
  if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
  const path = join(dir, `plan-${Date.now()}.md`);
  writeFileSync(path, transcript);
  return path;
}

type EnsureResult = { paneId: string; spawned: boolean } | { error: string };

function ensureCoderPane(cwd: string): EnsureResult {
  if (!process.env.TMUX) {
    return {
      error:
        "Not running inside tmux. Start a tmux session first (`tmux new -s work`), then run `pi` inside it to use the split coder pane.",
    };
  }

  const existing = loadState(cwd);
  if (existing && existing.cwd === cwd && paneAlive(existing.paneId)) {
    // A reused pane may live in another window (user switched/moved) — pull
    // it back next to the active pane so the split is actually visible.
    if (!paneInCurrentWindow(existing.paneId)) {
      spawnSync("tmux", ["join-pane", "-h", "-s", existing.paneId]);
      spawnSync("tmux", ["select-layout", "even-horizontal"]);
    }
    unzoomWindow();
    return { paneId: existing.paneId, spawned: false };
  }

  const split = spawnSync(
    "tmux",
    ["split-window", "-h", "-P", "-F", "#{pane_id}", "-c", cwd, "pi"],
    { encoding: "utf8" },
  );
  if (split.status !== 0 || !split.stdout.trim()) {
    return {
      error: `Failed to spawn coder pane: ${split.stderr?.trim() || split.error?.message || "unknown tmux error"}`,
    };
  }

  const paneId = split.stdout.trim();
  saveState(cwd, { paneId, cwd, createdAt: Date.now() });
  spawnSync("tmux", ["select-layout", "even-horizontal"]);
  // If the pane we split from was zoomed, the new split stays hidden behind it.
  unzoomWindow();
  return { paneId, spawned: true };
}

function sendToPane(paneId: string, text: string) {
  // Flatten to a single line: tmux send-keys -l sends literal bytes, but
  // embedded newlines would submit the message prematurely inside pi's editor.
  const flat = text.replace(/\r?\n/g, " ").trim();
  spawnSync("tmux", ["send-keys", "-t", paneId, "-l", flat]);
  spawnSync("tmux", ["send-keys", "-t", paneId, "Enter"]);
}

function coderMessage(handoffPath: string, task: string): string {
  return (
    `Read ${handoffPath} first for the full planning context. ` +
    "Read the code-standards skill (/home/lixuling/.agents/skills/code-standards/SKILL.md) before writing anything and follow it for every file you write or edit, even small edits. " +
    `Then: ${task}`
  );
}

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "delegate_to_coder",
    label: "Delegate to Coder",
    description:
      "Spawn (if not already running) a Coder agent in a split tmux pane, running its own interactive pi session, and send it a task to implement. " +
      "Automatically writes the full planning conversation (this session's context) to a handoff file under .pi/handoff/ and tells the coder to read it first, so the coder has the same context as the plan agent instead of only the short task string. " +
      "Use this to hand off implementation work identified while planning (e.g. after writing a spec/TODO with the spec-writer skill). The user can watch the coder pane work and can also type directly into it themselves; this tool just injects an initial or follow-up instruction.",
    parameters: Type.Object({
      task: Type.String({
        description:
          "Self-contained task/prompt to send to the coder agent. Reference concrete file paths (e.g. docs/specs/<slug>.todo.md) instead of vague instructions.",
      }),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx: ExtensionContext) {
      const result = ensureCoderPane(ctx.cwd);
      if ("error" in result) {
        return { content: [{ type: "text", text: result.error }], details: {}, isError: true };
      }
      if (result.spawned) {
        // give the freshly spawned pi instance a moment to boot before sending keys
        spawnSync("sleep", ["2"]);
      }
      const transcript = buildPlanHandoff(ctx);
      const handoffPath = writePlanHandoff(ctx.cwd, transcript);
      const message = coderMessage(handoffPath, params.task);
      sendToPane(result.paneId, message);
      return {
        content: [
          {
            type: "text",
            text: `${result.spawned ? "Spawned new coder pane" : "Reused existing coder pane"} (${result.paneId}).\nSaved plan handoff to ${handoffPath}\nSent task:\n\n${params.task}`,
          },
        ],
        details: { paneId: result.paneId, spawned: result.spawned, handoffPath },
      };
    },
  });

  pi.registerCommand("coder", {
    description: "Spawn/reuse the split coder pane and send it a task (manual delegation)",
    handler: async (args: string, ctx: ExtensionCommandContext) => {
      const task = args?.trim();
      if (!task) {
        ctx.ui.notify("Usage: /coder <task to delegate>", "warning");
        return;
      }
      const result = ensureCoderPane(ctx.cwd);
      if ("error" in result) {
        ctx.ui.notify(result.error, "error");
        return;
      }
      if (result.spawned) {
        spawnSync("sleep", ["2"]);
      }
      const transcript = buildPlanHandoff(ctx);
      const handoffPath = writePlanHandoff(ctx.cwd, transcript);
      const message = coderMessage(handoffPath, task);
      sendToPane(result.paneId, message);
      ctx.ui.notify(
        `${result.spawned ? "Spawned" : "Reused"} coder pane (${result.paneId}), saved handoff to ${handoffPath}, and delegated task.`,
        "info",
      );
    },
  });

  pi.registerCommand("coder-status", {
    description: "Show whether the coder pane is active",
    handler: async (_args: string, ctx: ExtensionCommandContext) => {
      const state = loadState(ctx.cwd);
      if (!state) {
        ctx.ui.notify("No coder pane has been spawned yet.", "info");
        return;
      }
      const alive = paneAlive(state.paneId);
      ctx.ui.notify(
        `Coder pane ${state.paneId}: ${alive ? "alive" : "not found (will respawn on next delegate)"}`,
        alive ? "info" : "warning",
      );
    },
  });
}
