import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

/**
 * Gives the agent a real interactive prompt instead of writing "open questions"
 * as plain inline text that the user has to scroll back and answer manually.
 *
 * Two tools:
 * - ask_user: free-form question, opens an input/editor dialog
 * - ask_user_choice: multiple-choice + always a "Type something…" option for custom input
 *
 * Falls back to plain text (returns immediately without blocking) when there's
 * no interactive UI available (print/JSON mode), since ctx.hasUI is false there.
 */

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "ask_user",
    label: "Ask User",
    description:
      "Ask the user a single open-ended question via an interactive prompt dialog, and wait for their typed answer. " +
      "Use this instead of writing 'open questions' as inline text when you are blocked, unsure, or need a decision " +
      "before continuing — especially during planning. Ask ONE question per call; call this tool multiple times in " +
      "sequence for multiple questions so the user answers them one at a time instead of a wall of text.",
    parameters: Type.Object({
      question: Type.String({ description: "The question to ask, phrased clearly and concretely." }),
      context: Type.Optional(
        Type.String({ description: "Optional short context/why this question matters, shown above the input." }),
      ),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx: ExtensionContext) {
      if (!ctx.hasUI) {
        return {
          content: [
            {
              type: "text",
              text: `[No interactive UI available — question was not shown to the user]\nQ: ${params.question}`,
            },
          ],
          details: {},
        };
      }
      const answer = await ctx.ui.input(
        params.context ? `${params.context}\n\n${params.question}` : params.question,
        "Type your answer...",
      );
      if (answer === undefined || answer === "") {
        return {
          content: [{ type: "text", text: "The user dismissed the prompt without answering." }],
          details: {},
        };
      }
      return {
        content: [{ type: "text", text: `User answered: ${answer}` }],
        details: { answer },
      };
    },
  });

  pi.registerTool({
    name: "ask_user_choice",
    label: "Ask User (choice)",
    description:
      "Ask the user to pick one option from a short list via an interactive select dialog. " +
      "The dialog always includes a final 'Type something…' option so the user can type a custom answer " +
      "instead of picking a listed option. Use this for multiple-choice decisions instead of listing options " +
      "as inline text.",
    parameters: Type.Object({
      question: Type.String({ description: "The question/decision being made." }),
      options: Type.Array(Type.String(), { description: "2-6 short option labels the user can pick from." }),
    }),
    async execute(_toolCallId, params, _signal, _onUpdate, ctx: ExtensionContext) {
      if (!ctx.hasUI) {
        return {
          content: [
            {
              type: "text",
              text: `[No interactive UI available]\nQ: ${params.question}\nOptions: ${params.options.join(", ")}`,
            },
          ],
          details: {},
        };
      }
      const OTHER = "Type something\u2026";
      const choice = await ctx.ui.select(params.question, [...params.options, OTHER]);
      if (choice === undefined) {
        return {
          content: [{ type: "text", text: "The user dismissed the prompt without choosing." }],
          details: {},
        };
      }
      if (choice === OTHER) {
        const answer = await ctx.ui.input(params.question, "Type your answer...");
        if (answer === undefined || answer === "") {
          return {
            content: [{ type: "text", text: "The user dismissed the prompt without answering." }],
            details: {},
          };
        }
        return {
          content: [{ type: "text", text: `User wrote: ${answer}` }],
          details: { choice: answer, wasCustom: true },
        };
      }
      return {
        content: [{ type: "text", text: `User chose: ${choice}` }],
        details: { choice, wasCustom: false },
      };
    },
  });
}
