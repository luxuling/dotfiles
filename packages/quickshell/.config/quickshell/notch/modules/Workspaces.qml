import QtQuick
import Quickshell.Hyprland
import ".."

Row {
	id: root

	required property string screenName

	// NOTE: the pills sit tight and spread apart while the cursor is over them, so the right one is easier to hit.
	spacing: hover.hovered ? 5 : 1

	Behavior on spacing {
		NumberAnimation {
			duration: 140
			easing.type: Easing.OutQuad
		}
	}

	HoverHandler {
		id: hover
	}

	Repeater {
		model: Hyprland.workspaces

		delegate: Item {
			id: dot

			required property var modelData

			readonly property bool onScreen: modelData.id > 0
				&& modelData.monitor !== null
				&& modelData.monitor.name === root.screenName

			visible: onScreen
			implicitWidth: onScreen ? 7 : 0
			implicitHeight: Theme.wingHeight

			// NOTE: dots sit close together, so the pill keeps the slot width to not cover neighbours.
			HoverFill {
				width: parent.width
				shown: mouse.containsMouse
			}

			Rectangle {
				anchors.centerIn: parent
				width: dot.modelData.active ? 5 : 3
				height: dot.modelData.active ? 20 : 12
				radius: width / 2
				color: dot.modelData.urgent ? Theme.bright : dot.modelData.active ? Theme.ink : Theme.gutter
			}

			MouseArea {
				id: mouse

				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				// NOTE: a Lua config evaluates dispatch as hl.dispatch(...), so the argument is a dispatcher call.
				onClicked: {
					const id = dot.modelData.id
					if (Hyprland.usingLua)
						Hyprland.dispatch("hl.dsp.focus({ workspace = " + id + " })")
					else
						Hyprland.dispatch("workspace " + id)
				}
			}
		}
	}
}
