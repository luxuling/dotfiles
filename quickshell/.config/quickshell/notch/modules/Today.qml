import QtQuick
import Quickshell.Io
import ".."
import "../time.js" as Time

Card {
	id: root

	property date now: new Date()
	property int uptimeSeconds: 0

	radius: 12

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
			onStreamFinished: root.uptimeSeconds = Math.floor(parseFloat(text))
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
			color: Theme.ink
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

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 4

			Icon {
				anchors.verticalCenter: parent.verticalCenter
				name: "hourglass-01"
				color: Theme.muted
			}

			BarText {
				text: `up ${Time.span(Math.floor(root.uptimeSeconds / 60))}`
				font.pixelSize: 11
				color: Theme.muted
			}
		}
	}
}
