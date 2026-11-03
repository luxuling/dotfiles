import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

// NOTE: ALT+T calls the "projects" ipc target, the picker walks ~/MINE/codes/<category>/<project>.
Picker {
	id: root

	readonly property string base: Quickshell.env("HOME") + "/MINE/codes"
	// NOTE: an empty category means the category list is shown.
	property string category: ""

	function reload() {
		root.items = Array.from({ length: folders.count }, (_, index) => ({
			label: folders.get(index, "fileName"),
			icon: "folder",
			chevron: root.category === ""
		}))
	}

	title: category === "" ? "codes" : `codes  ›  ${category}`
	hint: "j/k move  ·  l open  ·  h back  ·  / filter  ·  q close"
	namespace: "quickshell-projects"

	onOpenChanged: {
		if (!open)
			return

		root.category = ""
	}

	// NOTE: one ghostty at a time, running the tmux coding session for the picked project.
	onPicked: item => {
		if (root.category === "") {
			root.restore = ""
			root.query = ""
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

	IpcHandler {
		target: "projects"

		function toggle(): void {
			root.open = !root.open
		}
	}
}
