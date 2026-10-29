// NOTE: tray menus are Qt Widgets, so this shell has to run as QApplication.
//@ pragma UseQApplication

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

ShellRoot {
	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: panel

			required property var modelData

			screen: modelData
			color: "transparent"
			aboveWindows: true
			anchors.top: true
			anchors.left: true
			anchors.right: true

			// NOTE: the window is tall enough for the drawer, but the zone stays at bar height so windows never move. The mask keeps the empty part click-through.
			implicitHeight: notch.barHeight + Theme.drawerHeight
			exclusiveZone: notch.barHeight

			WlrLayershell.namespace: "quickshell-notch"

			// NOTE: the shoulder curve is the outside of a circle, so those disks are cut out of the mask.
			mask: Region {
				item: notch
				bottomLeftRadius: Theme.bottomRadius
				bottomRightRadius: Theme.bottomRadius

				Region {
					x: -Theme.melt
					y: 0
					width: Theme.melt * 2
					height: Theme.melt * 2
					shape: RegionShape.Ellipse
					intersection: Intersection.Subtract
				}

				Region {
					x: notch.width - Theme.melt
					y: 0
					width: Theme.melt * 2
					height: Theme.melt * 2
					shape: RegionShape.Ellipse
					intersection: Intersection.Subtract
				}
			}

			NotchBar {
				id: notch

				anchors.top: parent.top
				anchors.horizontalCenter: parent.horizontalCenter
				width: implicitWidth
				height: implicitHeight
				screenWidth: panel.screen.width
				screenName: panel.screen.name
			}
		}
	}
}
