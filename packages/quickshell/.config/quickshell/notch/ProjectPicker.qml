import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

// NOTE: ALT+T calls the "projects" ipc target, the picker walks ~/MINE/codes/<category>/<project>.
Picker {
	id: root

	readonly property string base: Quickshell.env("HOME") + "/MINE/codes"
	readonly property string parentDir: base + (category === "" ? "" : "/" + category)
	readonly property string keyHint: "ctrl+j/k move · enter open · ctrl+n new · backspace · esc close"
	// NOTE: an empty category means the category list is shown.
	property string category: ""
	property string notice: ""
	property string pending: ""

	function reload() {
		root.items = Array.from({ length: folders.count }, (_, index) => ({
			label: folders.get(index, "fileName"),
			icon: "folder",
			chevron: root.category === ""
		}))
	}

	// NOTE: the list hides dotfolders, so a leading dot would create a folder the picker cannot show.
	function folderName(text) {
		const name = text.trim()
		if (name === "" || name === "." || name === ".." || name.startsWith(".") || name.includes("/"))
			return ""

		return name
	}

	function folderExists(name) {
		for (let index = 0; index < folders.count; index++) {
			if (folders.get(index, "fileName") === name)
				return true
		}

		return false
	}

	function createFolder() {
		const name = root.folderName(root.query)
		if (name === "") {
			root.notice = root.query.trim() === "" ? "type a folder name" : "invalid folder name"
			return
		}

		if (root.folderExists(name)) {
			root.notice = "already exists"
			return
		}

		if (mkdir.running)
			return

		root.pending = name
		root.notice = ""
		mkdir.exec(["mkdir", "--", root.parentDir + "/" + name])
	}

	function finishCreate(exitCode) {
		if (exitCode !== 0) {
			root.notice = "could not create folder"
			return
		}

		root.restore = root.pending
		root.query = ""
		root.reload()
	}

	title: category === "" ? "codes" : `codes  ›  ${category}`
	hint: notice === "" ? keyHint : notice
	namespace: "quickshell-projects"

	onQueryChanged: root.notice = ""

	onOpenChanged: {
		if (!open)
			return

		root.category = ""
		root.notice = ""
	}

	onKey: text => {
		if (text === "C-n")
			root.createFolder()
	}

	// NOTE: one ghostty at a time, running the tmux coding session for the picked project.
	onPicked: item => {
		if (root.category === "") {
			root.restore = ""
			root.query = ""
			root.notice = ""
			root.category = item.label
			return
		}

		Quickshell.execDetached(["sh", "-c", "pkill -x ghostty; sleep 0.2; exec ghostty -e \"$HOME/.config/scripts/coding\" \"$1\"", "sh", `${root.base}/${root.category}/${item.label}`])
		root.open = false
	}

	onBack: {
		if (root.category === "")
			return

		root.restore = root.category
		root.query = ""
		root.notice = ""
		root.category = ""
	}

	FolderListModel {
		id: folders

		folder: "file://" + root.base + (root.category === "" ? "" : "/" + root.category)
		showFiles: false
		showDotAndDotDot: false
		showHidden: false
		sortCaseSensitive: false
		onStatusChanged: {
			if (status === FolderListModel.Ready)
				root.reload()
		}
		onCountChanged: root.reload()
	}

	Process {
		id: mkdir

		onExited: (exitCode) => root.finishCreate(exitCode)
	}

	IpcHandler {
		target: "projects"

		function toggle(): void {
			root.open = !root.open
		}
	}
}
