import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import ".."

Row {
	id: root

	spacing: 8

	Repeater {
		model: SystemTray.items

		delegate: Item {
			id: slot

			required property var modelData

			implicitWidth: 16
			implicitHeight: Theme.wingHeight

			Image {
				anchors.centerIn: parent
				width: 16
				height: 16
				fillMode: Image.PreserveAspectFit
				source: slot.modelData.icon
			}

			QsMenuAnchor {
				id: menu

				menu: slot.modelData.menu
				anchor.item: slot
				anchor.edges: Edges.Bottom
				anchor.gravity: Edges.Bottom
				anchor.adjustment: PopupAdjustment.All
			}

			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				acceptedButtons: Qt.LeftButton | Qt.RightButton
				onClicked: {
					if (slot.modelData.hasMenu)
						menu.open()
					else
						slot.modelData.activate()
				}
			}
		}
	}
}
