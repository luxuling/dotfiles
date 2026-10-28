import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Item {
	id: root

	property string alt: "none"

	implicitWidth: 32
	implicitHeight: Theme.wingHeight

	// NOTE: swaync-client -swb stays open and prints one JSON object per state change.
	Process {
		id: stream

		command: ["swaync-client", "-swb"]
		running: true
		stdout: SplitParser {
			splitMarker: "\n"
			onRead: data => root.applyState(data)
		}
		onExited: restart.start()
	}

	Timer {
		id: restart

		interval: 1000
		onTriggered: stream.running = true
	}

	function applyState(line) {
		const trimmed = line.trim()
		if (trimmed === "")
			return

		let payload
		try {
			payload = JSON.parse(trimmed)
		} catch (error) {
			return
		}

		if (typeof payload.alt !== "string")
			return

		root.alt = payload.alt
	}

	function iconFor(state) {
		if (state === "notification")
			return "󱅫"

		if (state === "dnd-notification")
			return "󰂠"

		if (state === "dnd-none")
			return "󰪓"

		if (state === "inhibited-notification" || state === "dnd-inhibited-notification")
			return "󰂛"

		if (state === "inhibited-none" || state === "dnd-inhibited-none")
			return "󰪑"

		return "󰂜"
	}

	HoverFill {
		anchors.fill: parent
		anchors.topMargin: 10
		anchors.bottomMargin: 10
		shown: mouse.containsMouse
	}

	BarText {
		anchors.centerIn: parent
		text: root.iconFor(root.alt)
		color: Theme.ink
	}

	MouseArea {
		id: mouse

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: event => {
			if (event.button === Qt.RightButton) {
				Quickshell.execDetached(["swaync-client", "-d", "-sw"])
				return
			}

			Quickshell.execDetached(["swaync-client", "-t", "-sw"])
		}
	}
}
