import QtQuick
import Quickshell
import Quickshell.Io

// NOTE: ALT+SPACE calls the "apps" ipc target, the same picker as the projects one over the desktop apps.
Picker {
	id: root

	// NOTE: desktop entry ids in pin order, pinned apps sit above the rest.
	property var pinned: []
	readonly property var apps: DesktopEntries.applications.values
		.filter(entry => !entry.noDisplay)
		.sort((a, b) => a.name.localeCompare(b.name))

	function togglePin(item) {
		if (item === undefined)
			return

		const id = item.entry.id
		root.restore = item.label
		root.pinned = root.pinned.includes(id) ? root.pinned.filter(pin => pin !== id) : [...root.pinned, id]
		store.setText(JSON.stringify(root.pinned))
	}

	title: "apps"
	hint: "j/k move  ·  l open  ·  p pin  ·  / filter  ·  q close"
	namespace: "quickshell-apps"
	items: [
		...root.pinned.map(id => root.apps.find(entry => entry.id === id)).filter(entry => entry !== undefined),
		...root.apps.filter(entry => !root.pinned.includes(entry.id))
	].map(entry => ({
		label: entry.name,
		iconPath: Quickshell.iconPath(entry.icon, true),
		search: [entry.name, entry.genericName, entry.keywords.join(" ")].join(" "),
		badge: root.pinned.includes(entry.id) ? "pinned" : "",
		entry
	}))

	onPicked: item => {
		item.entry.execute()
		root.open = false
	}

	onKey: (text, item) => {
		if (text === "p")
			root.togglePin(item)
	}

	// NOTE: the file is the only record across restarts, a missing one just means nothing is pinned.
	FileView {
		id: store

		path: Quickshell.statePath("pinned-apps.json")
		onLoaded: {
			try {
				const parsed = JSON.parse(text())
				root.pinned = Array.isArray(parsed) ? parsed.filter(id => typeof id === "string") : []
			} catch (error) {
				console.warn("pinned-apps.json is not valid json, starting empty:", error)
				root.pinned = []
			}
		}
		onLoadFailed: root.pinned = []
	}

	IpcHandler {
		target: "apps"

		function toggle(): void {
			root.open = !root.open
		}
	}
}
