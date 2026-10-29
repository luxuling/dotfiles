import QtQuick
import Quickshell.Io
import ".."

Rectangle {
	id: root

	property date now: new Date()
	property int uptimeSeconds: 0

	radius: 12
	color: Qt.alpha(Theme.white, 0.04)

	function formatUptime(seconds) {
		const days = Math.floor(seconds / 86400)
		const hours = Math.floor(seconds % 86400 / 3600)
		const minutes = Math.floor(seconds % 3600 / 60)
		if (days > 0)
			return `${days}d ${hours}h ${minutes}m`

		return `${hours}h ${minutes}m`
	}

	Timer {
		interval: 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: root.now = new Date()
	}

	Process {
		id: probe

		command: ["cat", "/proc/uptime"]
		stdout: StdioCollector {
			waitForEnd: true
			onStreamFinished: root.uptimeSeconds = Math.floor(parseFloat(text)) || 0
		}
	}

	Timer {
		interval: 60000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: probe.running = true
	}

	Column {
		anchors.centerIn: parent
		width: parent.width - 16
		spacing: 4

		Row {
			anchors.horizontalCenter: parent.horizontalCenter

			BarText {
				id: bigTime

				text: Qt.formatTime(root.now, "HH:mm")
				font.pixelSize: 26
				color: Theme.ink
			}

			BarText {
				anchors.baseline: bigTime.baseline
				text: Qt.formatTime(root.now, ":ss")
				font.pixelSize: 13
				color: Theme.muted
			}
		}

		BarText {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			text: Qt.formatDate(root.now, "dddd")
			font.pixelSize: 13
			color: Theme.accent
		}

		BarText {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			text: Qt.formatDate(root.now, "d MMM yyyy")
			font.pixelSize: 12
		}

		Item {
			width: 1
			height: 4
		}

		BarText {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			text: `\u{f051f}  up ${root.formatUptime(root.uptimeSeconds)}`
			font.pixelSize: 11
			color: Theme.muted
		}
	}
}
