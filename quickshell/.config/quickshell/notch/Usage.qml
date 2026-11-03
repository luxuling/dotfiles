pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "time.js" as Time

// NOTE: claude-hud mirrors claude's statusline rate limits to a file, grok only logs its weekly credit fetches.
Singleton {
	id: root

	property var claude: null
	property var grok: null

	readonly property int hour: 3600000
	readonly property int day: 24 * hour

	// NOTE: both sources only update while the agent runs, so a reset that already passed means the limit is back to 0 until the next fetch.
	function roll(used, reset, period) {
		if (reset === null)
			return { used, reset }

		let end = new Date(reset).getTime()
		if (end > Date.now())
			return { used, reset }

		while (end <= Date.now())
			end += period

		return { used: 0, reset: new Date(end).toISOString() }
	}

	function percent(value) {
		return value === null ? null : Math.round(value)
	}

	function readClaude(text) {
		const usage = JSON.parse(text)
		const session = root.roll(root.percent(usage.five_hour.used_percentage), usage.five_hour.resets_at, 5 * hour)
		const week = root.roll(root.percent(usage.seven_day.used_percentage), usage.seven_day.resets_at, 7 * day)
		root.claude = {
			session: session.used,
			week: week.used,
			sessionReset: session.reset,
			weekReset: week.reset
		}
	}

	function readGrok(line) {
		const config = JSON.parse(line).ctx.config
		const week = root.roll(Math.round(config.creditUsagePercent), config.currentPeriod.end, 7 * day)
		root.grok = {
			week: week.used,
			weekReset: week.reset
		}
	}

	function resetIn(date) {
		return Time.span(Math.max(0, Math.round((new Date(date) - Date.now()) / 60000)))
	}

	// NOTE: claude-hud replaces the file by rename, which a file watcher loses, so it is re-read on a timer instead.
	FileView {
		id: claudeFile

		path: `${Quickshell.env("HOME")}/.cache/claude-usage.json`
		onLoaded: root.readClaude(text())
		onLoadFailed: root.claude = null
	}

	Process {
		id: grokLog

		command: ["sh", "-c", "tac \"$HOME/.grok/logs/unified.jsonl\" | grep -m1 'billing: fetched credits config'"]
		stdout: StdioCollector {
			onStreamFinished: {
				if (text !== "")
					root.readGrok(text)
			}
		}
	}

	Timer {
		running: true
		triggeredOnStart: true
		interval: 30000
		repeat: true
		onTriggered: {
			claudeFile.reload()
			grokLog.running = true
		}
	}
}
