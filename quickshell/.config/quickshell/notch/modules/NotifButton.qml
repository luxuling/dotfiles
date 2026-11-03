import QtQuick
import ".."

Item {
	id: root

	readonly property bool hovered: mouse.containsMouse

	implicitWidth: 32
	implicitHeight: Theme.wingHeight

	HoverFill {
		shown: mouse.containsMouse
	}

	Icon {
		anchors.centerIn: parent
		name: Notifs.dnd ? "bell-off-01" : Notifs.count > 0 ? "bell-ringing-01" : "bell-01"
	}

	// NOTE: hovering opens the notification drawer, clicking toggles do not disturb.
	MouseArea {
		id: mouse

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: Notifs.dnd = !Notifs.dnd
	}
}
