import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Item {
	id: root

	required property bool active

	readonly property int bars: 6
	property var values: Array(bars).fill(0)

	implicitWidth: row.implicitWidth
	implicitHeight: Theme.wingHeight

	onActiveChanged: {
		if (!active)
			values = Array(bars).fill(0)
	}

	// NOTE: cava only runs while Spotify plays, each stdout line is one frame of 0..100 values separated by ';'.
	Process {
		command: ["cava", "-p", Quickshell.shellPath("cava.conf")]
		running: root.active
		stdout: SplitParser {
			splitMarker: "\n"
			onRead: data => {
				const frame = data.split(";").filter(value => value !== "").map(Number)
				if (frame.length === root.bars)
					root.values = frame
			}
		}
	}

	HoverHandler {
		id: hover

		cursorShape: Qt.PointingHandCursor
	}

	HoverFill {
		width: parent.width + 16
		shown: hover.hovered
	}

	Row {
		id: row

		anchors.verticalCenter: parent.verticalCenter
		spacing: 2

		Repeater {
			model: root.bars

			Rectangle {
				required property int index

				anchors.verticalCenter: parent.verticalCenter
				width: 3
				height: 3 + root.values[index] / 100 * 15
				radius: 1.5
				color: root.active ? Theme.ink : Theme.muted

				Behavior on height {
					NumberAnimation { duration: 60 }
				}
			}
		}
	}
}
