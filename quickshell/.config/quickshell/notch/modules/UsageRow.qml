import QtQuick
import ".."

// NOTE: one line per agent, each limit is a thin bar plus its percent, the soonest reset closes the line.
Row {
	id: usage

	required property string agent
	required property var limits

	height: 16
	spacing: 10

	AgentLogo {
		anchors.verticalCenter: parent.verticalCenter
		agent: usage.agent
		size: 14
	}

	Repeater {
		model: usage.limits

		Row {
			required property var modelData

			anchors.verticalCenter: parent.verticalCenter
			spacing: 6

			BarText {
				anchors.verticalCenter: parent.verticalCenter
				width: 16
				text: modelData.label
				font.pixelSize: 11
				font.weight: Font.Normal
				color: Theme.muted
			}

			Rectangle {
				anchors.verticalCenter: parent.verticalCenter
				width: 56
				height: 4
				radius: 2
				color: Qt.alpha(Theme.ink, 0.1)

				Rectangle {
					width: parent.width * Math.min(100, modelData.used) / 100
					height: parent.height
					radius: 2
					color: Theme.ink
				}
			}

			BarText {
				anchors.verticalCenter: parent.verticalCenter
				width: 32
				text: `${modelData.used}%`
				font.pixelSize: 11
				color: Theme.ink
			}
		}
	}

	BarText {
		anchors.verticalCenter: parent.verticalCenter
		visible: usage.limits.length > 0
		text: usage.limits.length > 0 ? `resets ${Usage.resetIn(usage.limits[0].reset)}` : ""
		font.pixelSize: 11
		font.weight: Font.Normal
		color: Theme.muted
	}
}
