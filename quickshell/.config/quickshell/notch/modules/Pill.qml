import QtQuick
import ".."

// NOTE: a small rounded button, brighter when active or hovered.
Rectangle {
	id: pill

	required property string label
	property bool active: false

	signal clicked

	width: pillText.implicitWidth + 20
	height: 24
	radius: 12
	color: Qt.alpha(Theme.ink, area.containsMouse ? 0.14 : pill.active ? 0.1 : 0.05)

	BarText {
		id: pillText

		anchors.centerIn: parent
		text: pill.label
		font.pixelSize: 11
		color: pill.active || area.containsMouse ? Theme.ink : Theme.soft
	}

	MouseArea {
		id: area

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: pill.clicked()
	}
}
