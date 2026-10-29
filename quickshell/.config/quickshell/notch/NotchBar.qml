import QtQuick
import Quickshell
import "modules"

Item {
	id: root

	required property int screenWidth
	required property string screenName

	property bool open: false

	readonly property int screenBudget: Math.max(0, screenWidth - 48)
	readonly property int barHeight: Theme.foldedHeight
	readonly property int groupGap: open ? 36 : Theme.gap

	implicitWidth: Math.min(screenBudget, Theme.melt * 2 + Theme.sidePad * 2 + workWrap.width + clockItem.width + meters.width + extraSlot.width)
	implicitHeight: barHeight

	HoverHandler {
		id: hover

		onHoveredChanged: {
			if (hover.hovered) {
				collapse.stop()
				root.open = true
				return
			}

			collapse.start()
		}
	}

	Timer {
		id: collapse

		interval: 220
		onTriggered: root.open = false
	}

	NotchShape {
		anchors.fill: parent
	}

	Row {
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.leftMargin: Theme.melt + Theme.sidePad
		anchors.rightMargin: Theme.melt + Theme.sidePad
		height: root.barHeight
		spacing: 0

		Item {
			id: workWrap

			width: workspaces.implicitWidth + root.groupGap
			height: root.barHeight

			Workspaces {
				id: workspaces

				anchors.left: parent.left
				anchors.verticalCenter: parent.verticalCenter
				screenName: root.screenName
			}
		}

		Item {
			id: clockItem

			width: clock.implicitWidth + 28
			height: root.barHeight

			Clock {
				id: clock

				anchors.centerIn: parent
			}
		}

		Item {
			id: meters

			width: meterRow.implicitWidth + root.groupGap
			height: root.barHeight

			Row {
				id: meterRow

				anchors.left: parent.left
				anchors.leftMargin: root.groupGap
				anchors.verticalCenter: parent.verticalCenter
				spacing: 10

				Memory { id: memory }

				Volume { id: volume }
			}
		}

		Item {
			id: extraSlot

			height: root.barHeight
			clip: true
			width: root.open ? extras.implicitWidth + root.groupGap : 0

			Behavior on width {
				NumberAnimation {
					duration: 140
					easing.type: Easing.OutQuad
				}
			}

			Row {
				id: extras

				anchors.left: parent.left
				anchors.leftMargin: root.groupGap
				anchors.verticalCenter: parent.verticalCenter
				spacing: root.groupGap

				Row {
					spacing: 4

					BluetoothStatus { id: bluetooth }

					LaunchButton {
						id: picker

						glyph: ""
						command: ["hyprpicker", "--a"]
					}

					LaunchButton {
						id: bongocat

						glyph: ""
						command: ["bongocat", "-c", Quickshell.env("HOME") + "/.config/bongocat.conf", "-t"]
					}

					SwayncButton { id: swaync }
				}

				Tray { id: tray }
			}
		}
	}
}
