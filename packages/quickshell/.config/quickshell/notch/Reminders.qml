pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "time.js" as Time

Singleton {
	id: root

	property var items: []
	property real now: Date.now()
	readonly property var next: items.length > 0 ? items[0] : null

	function remaining(item) {
		return Math.max(0, Math.min(1, (item.at - root.now) / Math.max(1, item.at - item.from)))
	}

	function urgent(item) {
		return item.at - root.now <= 60000
	}

	function preview(input, presetMs) {
		return Time.parseReminder(input, root.now, presetMs)
	}

	function add(input, presetMs) {
		const reminder = Time.parseReminder(input, Date.now(), presetMs)
		if (reminder === null)
			return false

		root.save([...root.items, reminder].sort((a, b) => a.at - b.at))
		return true
	}

	function remove(index) {
		root.save(root.items.filter((_, position) => position !== index))
	}

	function save(items) {
		root.items = items
		store.setText(JSON.stringify(items))
	}

	function fireDue() {
		const now = root.now
		const due = root.items.filter(item => item.at <= now)
		if (due.length === 0)
			return

		for (const item of due)
			Quickshell.execDetached(["notify-send", "-a", "Reminder", "-i", Quickshell.shellPath("icons/hourglass-03.svg"), item.text])

		root.save(root.items.filter(item => item.at > now))
	}

	function load(text) {
		try {
			const parsed = JSON.parse(text)
			const valid = Array.isArray(parsed) ? parsed.filter(item => typeof item.at === "number" && typeof item.text === "string") : []
			root.items = valid.map(item => ({ from: typeof item.from === "number" ? item.from : item.at, at: item.at, text: item.text }))
		} catch (error) {
			console.warn("reminders.json is not valid json, starting empty:", error)
			root.items = []
		}
	}

	// NOTE: the file is the only record across restarts, a missing one just means nothing is pending.
	FileView {
		id: store

		path: Quickshell.statePath("reminders.json")
		onLoaded: root.load(text())
		onLoadFailed: root.items = []
	}

	// NOTE: one clock drives every countdown, reminders that came due while the shell was down fire on the first tick.
	Timer {
		interval: 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			root.now = Date.now()
			root.fireDue()
		}
	}
}
