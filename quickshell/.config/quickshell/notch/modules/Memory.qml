import QtQuick
import Quickshell.Io
import ".."

Item {
	id: root

	property real usedFraction: 0
	readonly property bool hovered: mouse.containsMouse

	implicitWidth: 22
	implicitHeight: Theme.wingHeight

	HoverFill {
		shown: mouse.containsMouse
	}

	CircleMeter {
		anchors.centerIn: parent
		fraction: root.usedFraction
		icon: "cpu-chip-01"
	}

	MouseArea {
		id: mouse

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
	}

	Process {
		id: probe

		command: ["cat", "/proc/meminfo"]
		stdout: StdioCollector {
			waitForEnd: true
			onStreamFinished: root.readUsed(text)
		}
	}

	Timer {
		interval: 2000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: probe.running = true
	}

	function readUsed(meminfo) {
		const totalKb = Number(/MemTotal:\s+(\d+)/.exec(meminfo)[1])
		const availableKb = Number(/MemAvailable:\s+(\d+)/.exec(meminfo)[1])

		root.usedFraction = (totalKb - availableKb) / totalKb
	}
}
