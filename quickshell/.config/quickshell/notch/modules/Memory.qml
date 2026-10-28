import QtQuick
import Quickshell.Io
import ".."

Item {
	id: root

	property real usedFraction: 0

	implicitWidth: 22
	implicitHeight: Theme.wingHeight

	HoverFill {
		anchors.fill: parent
		anchors.topMargin: 8
		anchors.bottomMargin: 8
		shown: mouse.containsMouse
	}

	CircleMeter {
		anchors.centerIn: parent
		fraction: root.usedFraction
		glyph: ""
	}

	MouseArea {
		id: mouse

		anchors.fill: parent
		hoverEnabled: true
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
		const total = /MemTotal:\s+(\d+)/.exec(meminfo)
		const available = /MemAvailable:\s+(\d+)/.exec(meminfo)
		if (total === null || available === null)
			return

		const totalKb = Number(total[1])
		const usedKb = totalKb - Number(available[1])
		root.usedFraction = totalKb === 0 ? 0 : Math.max(0, Math.min(1, usedKb / totalKb))
	}
}
