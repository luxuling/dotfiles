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

	AgentCat {
		anchors.centerIn: parent
	}

	MouseArea {
		id: mouse

		anchors.fill: parent
		hoverEnabled: true
	}
}
