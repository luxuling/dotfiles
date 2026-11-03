import QtQuick
import ".."

Item {
	id: root

	required property string icon
	readonly property bool hovered: area.containsMouse

	signal clicked

	width: Math.max(24, Theme.iconSize + 8)
	height: 24

	HoverFill {
		shown: area.containsMouse
	}

	Icon {
		anchors.centerIn: parent
		name: root.icon
	}

	MouseArea {
		id: area

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: root.clicked()
	}
}
