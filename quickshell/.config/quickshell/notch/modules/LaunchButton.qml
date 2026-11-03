import QtQuick
import Quickshell
import ".."

Item {
	id: root

	required property string icon
	required property var command

	implicitWidth: 28
	implicitHeight: Theme.wingHeight

	HoverFill {
		shown: mouse.containsMouse
	}

	Icon {
		anchors.centerIn: parent
		name: root.icon
		color: Theme.ink
	}

	MouseArea {
		id: mouse

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: Quickshell.execDetached(root.command)
	}
}
