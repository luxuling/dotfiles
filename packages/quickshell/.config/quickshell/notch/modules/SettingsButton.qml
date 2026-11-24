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
		name: "settings-01"
	}

	// NOTE: hovering opens the settings drawer, there is nothing to click.
	MouseArea {
		id: mouse

		anchors.fill: parent
		hoverEnabled: true
	}
}
