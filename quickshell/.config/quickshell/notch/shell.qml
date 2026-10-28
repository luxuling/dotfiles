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

			// NOTE: the zone matches the bar height so windows start under the notch.
			implicitHeight: notch.barHeight
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
				height: barHeight
				screenWidth: panel.screen.width
				screenName: panel.screen.name
			}
		}
	}
}
