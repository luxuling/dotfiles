// NOTE: tray menus are Qt Widgets, so this shell has to run as QApplication.
//@ pragma UseQApplication
// NOTE: app and tray icons follow the GTK icon theme.
//@ pragma IconTheme WhiteSur-dark

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

ShellRoot {
	ProjectPicker {}
	AppLauncher {}

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: panel

			required property var modelData

			screen: modelData
			color: "transparent"
			anchors.top: true
			anchors.left: true
			anchors.right: true

			// NOTE: the window is tall enough for the drawer, but the zone stays at bar height so windows start right under the notch. The mask keeps the empty part click-through.
			implicitHeight: notch.barHeight + Theme.innerGap + Theme.drawerHeight
			exclusiveZone: notch.barHeight

			WlrLayershell.namespace: "quickshell-notch"
			// NOTE: a covered surface gets no frames, so the panel stays on Overlay and unmaps over fullscreen, a popup maps it back.
			readonly property bool fullscreen: Hyprland.monitorFor(modelData)?.activeWorkspace?.hasFullscreen ?? false

			visible: !fullscreen || (notch.drawerOpen && (notch.drawerKind === "popup" || notch.drawerKind === "agent"))
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: notch.wantsKeyboard ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

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
