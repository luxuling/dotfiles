import QtQuick
import Quickshell.Hyprland
import ".."

Row {
	id: root

	required property string screenName

	spacing: 3

	Repeater {
		model: Hyprland.workspaces

		delegate: Item {
			id: dot

			required property var modelData

			readonly property bool onScreen: modelData.id > 0
				&& modelData.monitor !== null
				&& modelData.monitor.name === root.screenName

			visible: onScreen
			implicitWidth: onScreen ? 10 : 0
			implicitHeight: Theme.wingHeight

			HoverFill {
				anchors.fill: parent
				anchors.topMargin: 10
				anchors.bottomMargin: 10
				shown: mouse.containsMouse
			}

			Rectangle {
				anchors.centerIn: parent
				width: dot.modelData.active ? 8 : 5
				height: dot.modelData.active ? 22 : 12
				radius: 3
				color: dot.modelData.urgent ? Theme.red : dot.modelData.active ? Theme.ink : Theme.gutter
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
