pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "time.js" as Time

// NOTE: agent-hook sends one json line per claude/grok hook event here, a blocking event keeps its socket open for the answer.
Singleton {
	id: root

	property var sessions: []
	property var pending: []
	property var alert: null
	property double now: Date.now()

	readonly property var current: pending.length > 0 ? pending[0] : null
	readonly property bool waiting: sessions.some(session => session.status === "waiting")

	signal jumped

	function receive(socket, line) {
		const message = JSON.parse(line)
		message.project = message.cwd.split("/").pop()

		root.dropAnswered(message)
		root.track(message)
		if (message.event === "UserPromptSubmit" && root.alert !== null && root.alert.session === message.session)
			root.alert = null
		root.dropAlert()

		if (message.wait) {
			root.pending = [...root.pending, { message, socket }]
			root.chime()
			return
		}

		if (root.alertText(message) !== "")
			root.showAlert(message)
	}

	function track(message) {
		// NOTE: a pane runs one agent at a time, so a restarted agent replaces the row its killed session left behind.
		const others = root.sessions.filter(session => session.id !== message.session && (message.pane === "" || session.pane !== message.pane))
		if (message.event === "SessionEnd") {
			root.sessions = others
			return
		}

		const previous = root.sessions.find(session => session.id === message.session)
		const status = root.statusFor(message, previous)
		const newTurn = message.event === "UserPromptSubmit" || previous === undefined
		root.sessions = [...others, {
			id: message.session,
			agent: message.agent,
			project: message.project,
			pane: message.pane,
			transcript: message.transcript,
			status,
			tool: message.tool !== "" ? message.tool : newTurn ? "" : previous.tool,
			activity: message.tool !== "" ? root.activity(message) : newTurn ? "" : previous.activity,
			steps: root.isToolResult(message.event) ? root.addStep(newTurn ? [] : previous.steps, message) : newTurn ? [] : previous.steps,
			since: previous?.status === status ? previous.since : Date.now(),
			prompt: message.prompt !== "" ? message.prompt : newTurn ? "" : previous.prompt,
			last: message.last !== "" ? root.plain(message.last) : newTurn ? "" : previous.last,
			tools: (newTurn ? 0 : previous.tools) + (root.isToolResult(message.event) ? 1 : 0)
		}]
	}

	function prune(listing) {
		const running = new Set(listing.trim().split("\n"))
		root.sessions = root.sessions.filter(session => session.pane === "" || running.has(`${session.pane} ${session.agent}`))
		root.dropAlert()
	}

	// NOTE: an alert stays until it is clicked, or its session moves on or goes away.
	function dropAlert() {
		if (root.alert !== null && root.session(root.alert.session) === undefined)
			root.alert = null
	}

	function session(id) {
		return root.sessions.find(session => session.id === id)
	}

	function statusFor(message, previous) {
		if (message.wait || root.alertText(message) !== "" && message.event !== "Stop")
			return "waiting"
		if (message.event === "Stop")
			return "done"
		if (root.isCancel(message.event))
			return "cancelled"
		if (message.event === "SessionStart")
			return "idle"
		if (message.event === "Notification")
			return previous?.status ?? "idle"

		return "running"
	}

	// NOTE: a hook keeps running when the prompt is answered in the terminal, so later events of the session retire its cards.
	function dropAnswered(message) {
		const ends = ["UserPromptSubmit", "Stop", "SessionEnd"].includes(message.event) || root.isCancel(message.event) || message.type === "idle_prompt"
		const used = request => root.isToolResult(message.event) && request.message.event === "PermissionRequest" && request.message.tool === message.tool && JSON.stringify(request.message.input) === JSON.stringify(message.input)
		const stale = root.pending.filter(request => request.message.session === message.session && (ends || used(request)))

		for (const request of stale)
			root.reply(request, { decision: "terminal" })
	}

	function reply(request, answer) {
		if (request.socket !== null && request.socket.connected) {
			request.socket.write(JSON.stringify(answer) + "\n")
			request.socket.flush()
		}

		root.pending = root.pending.filter(other => other !== request)
		root.setStatus(request.message.session, answer.decision === "terminal" ? "waiting" : "running")
	}

	function setStatus(id, status) {
		root.sessions = root.sessions.map(session => session.id === id ? Object.assign({}, session, { status, since: Date.now() }) : session)
	}

	function forget(socket) {
		root.pending = root.pending.filter(request => request.socket !== socket)
	}

	// NOTE: claude's own permission prompt already has a card, idle_prompt just repeats Stop a minute later.
	function alertText(message) {
		const name = message.agent === "grok" ? "Grok" : "Claude"
		if (message.event === "Stop")
			return `${name} finished`
		if (message.event === "PreToolUse" && root.isQuestion(message.tool))
			return `${name} asks: ${message.input.questions[0].question}`
		if (message.event !== "Notification" || message.type === "idle_prompt" || message.agent === "claude" && message.type === "permission_prompt")
			return ""

		return message.message !== "" ? `${name}: ${message.message}` : `${name} needs you`
	}

	function showAlert(message) {
		root.alert = Object.assign({}, message, { text: root.alertText(message) })
		root.chime()
	}

	// NOTE: replies are markdown, the notch shows plain text, so the markup characters are dropped and lines joined.
	function plain(text) {
		return text.replace(/[*_`#>]+/g, "").replace(/\s*\n+\s*/g, " ").trim()
	}

	function stepKind(tool) {
		if (/^(Bash|run_terminal_cmd)$|shell|terminal/i.test(tool))
			return "run"
		if (/edit|write|replace|create/i.test(tool))
			return "edit"
		if (/read|grep|glob|search|list|find|fetch/i.test(tool))
			return "explore"

		return "call"
	}

	// NOTE: like the claude app's work log, a run of the same kind of tool folds into one step.
	function addStep(steps, message) {
		const kind = root.stepKind(message.tool)
		const input = message.input
		const file = (root.target(input) ?? "").split("/").pop()
		const description = input.description ?? input.command ?? ""
		const step = { kind, count: 1, files: file === "" ? [] : [file], add: message.diff[0], del: message.diff[1], description }

		const last = steps[steps.length - 1]
		if (last === undefined || last.kind !== kind)
			return [...steps, step].slice(-20)

		return [...steps.slice(0, -1), {
			kind,
			count: last.count + 1,
			files: last.files.includes(file) || file === "" ? last.files : [...last.files, file],
			add: last.add + step.add,
			del: last.del + step.del,
			description: last.description
		}]
	}

	function isCancel(event) {
		return event === "StopCancelled" || event === "StopFailure"
	}

	function cancelInterrupted(listing) {
		const ids = listing.trim().split("\n")
		root.sessions = root.sessions.map(session => ids.includes(session.id) ? Object.assign({}, session, { status: "cancelled", since: Date.now() }) : session)
	}

	function isToolResult(event) {
		return event === "PostToolUse" || event === "PostToolUseFailure"
	}

	function isQuestion(tool) {
		return tool === "AskUserQuestion" || tool === "ask_user_question"
	}

	function target(input) {
		return input.file_path ?? input.path ?? input.target_file ?? input.pattern
	}

	function describe(message) {
		const input = message.input
		const detail = input.command ?? root.target(input) ?? input.url ?? message.tool
		return detail.replace(Quickshell.env("HOME"), "~")
	}

	function activity(message) {
		const detail = root.describe(message)
		return detail === message.tool ? detail : `${message.tool}  ${detail}`
	}

	function chime() {
		Quickshell.execDetached(["mpg123", "-q", "-f", "1638", Quickshell.shellPath("sounds/yippee-tbh.mp3")])
	}

	function jump(pane) {
		root.alert = null
		root.jumped()
		// NOTE: hyprland 0.57 runs hyprctl dispatch as lua, focusing the window also switches to its workspace.
		Quickshell.execDetached(["sh", "-c", "hyprctl dispatch 'hl.dsp.focus({ window = \"class:com.mitchellh.ghostty\" })'; [ -n \"$1\" ] && tmux switch-client -t \"$1\" \\; select-window -t \"$1\" \\; select-pane -t \"$1\"", "sh", pane])
	}

	function elapsed(since) {
		const minutes = Math.floor((root.now - since) / 60000)
		return minutes < 1 ? "now" : Time.span(minutes)
	}

	SocketServer {
		active: true
		path: `${Quickshell.env("XDG_RUNTIME_DIR")}/quickshell-agents.sock`

		handler: Socket {
			id: connection

			onConnectedChanged: {
				if (!connection.connected)
					root.forget(connection)
			}

			parser: SplitParser {
				onRead: line => root.receive(connection, line)
			}
		}
	}

	Timer {
		interval: 30000
		running: root.sessions.length > 0
		repeat: true
		onTriggered: {
			root.now = Date.now()
			panes.running = true
		}
	}

	// NOTE: claude fires no hook when a turn is interrupted, it only writes the interrupt into its transcript.
	Timer {
		running: root.sessions.some(session => session.status === "running" && session.transcript !== "")
		interval: 3000
		repeat: true
		onTriggered: {
			const settled = root.sessions.filter(session => session.status === "running" && session.transcript !== "" && Date.now() - session.since > 3000)
			if (settled.length === 0)
				return

			interrupts.command = ["sh", "-c", "while [ $# -gt 0 ]; do tail -n 40 \"$2\" | grep -E '\"type\":\"(user|assistant)\"' | tail -n 1 | grep -q 'Request interrupted by user' && echo \"$1\"; shift 2; done", "sh", ...settled.reduce((args, session) => [...args, session.id, session.transcript], [])]
			interrupts.running = true
		}
	}

	Process {
		id: interrupts

		stdout: StdioCollector {
			onStreamFinished: {
				if (text !== "")
					root.cancelInterrupted(text)
			}
		}
	}

	// NOTE: an agent killed with its pane or terminal never sends SessionEnd, so rows whose pane no longer runs that agent are dropped.
	Process {
		id: panes

		command: ["tmux", "list-panes", "-a", "-F", "#{pane_id} #{pane_current_command}"]
		stdout: StdioCollector {
			onStreamFinished: {
				if (text !== "")
					root.prune(text)
			}
		}
	}
}
