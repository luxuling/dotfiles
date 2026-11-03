import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import ".."

Row {
	id: root

	spacing: 0

	Repeater {
		model: SystemTray.items

		delegate: Item {
			id: slot

			required property var modelData

			// NOTE: the slot is as wide as the hover circle, the notch clips anything past the last icon.
			implicitWidth: Theme.hoverSize
			implicitHeight: Theme.wingHeight

			HoverFill {
				shown: mouse.containsMouse
			}

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
				id: mouse

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
