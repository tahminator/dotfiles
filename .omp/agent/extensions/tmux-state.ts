// Publishes this agent's state on its tmux pane so `tmux-agents` can show who needs attention.
//
// Pane options written (on $TMUX_PANE):
//   @omp_state  input   - blocked on you: an `ask` question or a tool approval prompt
//               idle    - turn finished, waiting for your next prompt
//               working - agent turn in flight
//   @omp_since  epoch seconds of the last state change
// Both are unset when the session shuts down.

import { execFile } from "node:child_process";
import type { ExtensionAPI } from "@oh-my-pi/pi-coding-agent";

type State = "input" | "idle" | "working";

const pane = process.env.TMUX_PANE;

// tmux calls are spawned async; chain them so a fast working->input->working burst can't land out of order.
let queue: Promise<void> = Promise.resolve();

function tmux(args: string[]): void {
  queue = queue.then(
    () => new Promise<void>(resolve => execFile("tmux", args, () => resolve())),
  );
}

function publish(state: State | null): void {
  if (!pane) return;
  if (state === null) {
    tmux(["set-option", "-p", "-u", "-t", pane, "@omp_state", ";", "set-option", "-p", "-u", "-t", pane, "@omp_since"]);
    return;
  }
  const now = String(Math.floor(Date.now() / 1000));
  tmux(["set-option", "-p", "-t", pane, "@omp_state", state, ";", "set-option", "-p", "-t", pane, "@omp_since", now]);
}

export default function tmuxState(pi: ExtensionAPI) {
  if (!pane) return;

  // Factories are rebound for every subagent in the same process and pane; only the main agent's
  // lifecycle reflects the pane. Subagent questions/approvals still render in this pane, so those count.
  const isMain = (ctx: { agent?: { kind: string }; hasUI: boolean }) => ctx.hasUI && ctx.agent?.kind !== "sub";

  pi.on("session_start", (_event, ctx) => { if (isMain(ctx)) publish("idle"); });
  pi.on("agent_start", (_event, ctx) => { if (isMain(ctx)) publish("working"); });
  pi.on("agent_end", (_event, ctx) => { if (isMain(ctx)) publish("idle"); });
  pi.on("session_shutdown", (_event, ctx) => { if (isMain(ctx)) publish(null); });

  pi.on("tool_call", (event, ctx) => { if (ctx.hasUI && event.toolName === "ask") publish("input"); });
  pi.on("tool_result", (event, ctx) => { if (ctx.hasUI && event.toolName === "ask") publish("working"); });
  pi.on("tool_approval_requested", (_event, ctx) => { if (ctx.hasUI) publish("input"); });
  pi.on("tool_approval_resolved", (_event, ctx) => { if (ctx.hasUI) publish("working"); });
}
