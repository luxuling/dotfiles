import QtQuick
import QtQuick.Layouts
import Quickshell
import "modules"

Item {
	id: root

	required property int screenWidth
	required property string screenName

	property bool open: false
	property bool drawerOpen: false

	readonly property int screenBudget: Math.max(0, screenWidth - 48)
	readonly property int barHeight: Theme.foldedHeight
	readonly property int groupGap: open ? 36 : Theme.gap
	readonly property bool drawerHovered: clockHover.hovered || drawerHover.hovered

	implicitWidth: Math.min(screenBudget, Theme.melt * 2 + Theme.sidePad * 2 + workWrap.width + clockItem.width + meters.width + extraSlot.width)
	implicitHeight: barHeight + (drawerOpen ? Theme.drawerHeight : 0)

	// NOTE: the fold is delayed so the cursor can cross from the clock into the drawer.
	onDrawerHoveredChanged: {
		if (drawerHovered) {
			drawerFold.stop()
			drawerOpen = true
			return
		}

		drawerFold.start()
	}

	onDrawerOpenChanged: {
		if (drawerOpen)
			calendar.reset()
	}

	Behavior on implicitHeight {
		NumberAnimation {
			duration: 160
			easing.type: Easing.OutQuad
		}
	}

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

	Timer {
		id: drawerFold

		interval: 220
		onTriggered: root.drawerOpen = false
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

			HoverHandler { id: clockHover }
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

	Item {
		y: root.barHeight
		width: root.width
		height: root.height - root.barHeight
		clip: true

		HoverHandler { id: drawerHover }

		RowLayout {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.leftMargin: Theme.melt + Theme.gap
			anchors.rightMargin: Theme.melt + Theme.gap
			height: Theme.drawerHeight - Theme.gap
			spacing: Theme.innerGap
			opacity: root.drawerOpen ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: 160 }
			}

			// NOTE: preferredWidth 0 with fillWidth splits the space left by the calendar evenly.
			Today {
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.preferredWidth: 0
			}

			Calendar {
				id: calendar

				Layout.alignment: Qt.AlignTop
			}

			Weather {
				Layout.fillWidth: true
				Layout.fillHeight: true
				Layout.preferredWidth: 0
			}
		}
	}
}
