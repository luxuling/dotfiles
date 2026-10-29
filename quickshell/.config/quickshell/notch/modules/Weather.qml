import QtQuick
import Quickshell.Io
import ".."

Rectangle {
	id: root

	property bool ready: false
	property string icon: ""
	property string temp: ""
	property string feels: ""
	property string condition: ""
	property string humidity: ""
	property string wind: ""
	property string place: ""

	radius: 12
	color: Qt.alpha(Theme.white, 0.04)

	// NOTE: location is pinned to Yogyakarta. Fields are pipe separated to keep parsing trivial.
	Process {
		id: probe

		command: ["curl", "-sf", "--max-time", "10", "wttr.in/Yogyakarta?format=%c|%t|%f|%C|%h|%w|%l"]
		stdout: StdioCollector {
			waitForEnd: true
			onStreamFinished: root.apply(text)
		}
	}

	Timer {
		interval: 15 * 60 * 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: probe.running = true
	}

	function apply(line) {
		const fields = line.trim().split("|").map(field => field.trim())
		if (fields.length !== 7)
			return

		root.icon = fields[0]
		root.temp = fields[1].replace("+", "")
		root.feels = fields[2].replace("+", "")
		root.condition = fields[3]
		root.humidity = fields[4]
		root.wind = fields[5]
		root.place = fields[6].split(",")[0]
		root.ready = true
	}

	BarText {
		anchors.centerIn: parent
		width: parent.width - 16
		horizontalAlignment: Text.AlignHCenter
		visible: !root.ready
		text: "weather unavailable"
		font.pixelSize: 12
		color: Theme.muted
	}

	Column {
		anchors.centerIn: parent
		width: parent.width - 16
		spacing: 4
		visible: root.ready

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 10

			Text {
				anchors.verticalCenter: parent.verticalCenter
				text: root.icon
				font.pixelSize: 20
			}

			BarText {
				anchors.verticalCenter: parent.verticalCenter
				text: root.temp
				font.pixelSize: 26
				color: Theme.ink
			}
		}

		BarText {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			text: root.condition
			font.pixelSize: 13
			color: Theme.accent
		}

		BarText {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			text: `feels ${root.feels}`
			font.pixelSize: 12
		}

		Item {
			width: 1
			height: 4
		}

		BarText {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			text: `\u{f058e} ${root.humidity}   \u{f059d} ${root.wind}`
			font.pixelSize: 11
			color: Theme.muted
		}

		BarText {
			width: parent.width
			horizontalAlignment: Text.AlignHCenter
			text: `\u{f034e} ${root.place}`
			font.pixelSize: 11
			color: Theme.muted
		}
	}
}
