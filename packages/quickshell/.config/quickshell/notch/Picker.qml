import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "modules"

// NOTE: the centered search picker behind the app launcher and project picker, items are { label, icon | iconPath, search?, chevron?, badge? }.
Scope {
	id: root

	property bool open: false
	property string title: ""
	property string hint: ""
	required property string namespace
	property var items: []
	// NOTE: after the items change, the row with this label is selected instead of the first one.
	property string restore: ""
	property string query: ""
	readonly property var shown: items.filter(item => (item.search ?? item.label).toLowerCase().includes(query.toLowerCase()))

	signal picked(var item)
	signal back
	// NOTE: search-field chords the picker does not use itself, such as "C-p" to pin.
	signal key(string text, var item)

	onOpenChanged: {
		root.query = ""
		root.restore = ""
	}

	// NOTE: the window is rebuilt on every open, so the selection and query start fresh.
	LazyLoader {
		active: root.open

		PanelWindow {
			screen: Quickshell.screens.find(screen => screen.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
			anchors.top: true
			anchors.bottom: true
			anchors.left: true
			anchors.right: true
			exclusionMode: ExclusionMode.Ignore
			color: "transparent"

			WlrLayershell.namespace: root.namespace
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

			Rectangle {
				id: box

				function move(delta) {
					list.currentIndex = Math.max(0, Math.min(list.count - 1, list.currentIndex + delta))
				}

				function forward() {
					const item = root.shown[list.currentIndex]
					if (item !== undefined)
						root.picked(item)
				}

				anchors.centerIn: parent
				width: 520
				height: 360
				radius: 18
				color: Theme.crust

				Connections {
					target: root

					function onQueryChanged() {
						if (filterInput.text !== root.query)
							filterInput.text = root.query
					}

					function onItemsChanged() {
						Qt.callLater(() => list.currentIndex = Math.max(0, root.shown.findIndex(item => item.label === root.restore)))
					}
				}

				Item {
					id: header

					anchors.top: parent.top
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.margins: 16
					height: 20

					BarText {
						anchors.left: parent.left
						anchors.verticalCenter: parent.verticalCenter
						text: root.title
						font.pixelSize: 13
						color: Theme.muted
					}

					BarText {
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						text: list.count
						font.pixelSize: 12
						color: Theme.muted
					}
				}

				Item {
					id: filterRow

					anchors.top: header.bottom
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.leftMargin: 16
					anchors.rightMargin: 16
					anchors.topMargin: 8
					height: 24

					BarText {
						id: slash

						anchors.left: parent.left
						anchors.verticalCenter: parent.verticalCenter
						text: "/"
						font.pixelSize: 13
						color: Theme.muted
					}

					TextInput {
						id: filterInput

						anchors.left: slash.right
						anchors.right: parent.right
						anchors.leftMargin: 6
						anchors.verticalCenter: parent.verticalCenter
						clip: true
						font.family: Theme.fontFamily
						font.pixelSize: 13
						color: Theme.ink
						selectionColor: Qt.alpha(Theme.ink, 0.2)
						onTextChanged: root.query = text
						onAccepted: box.forward()
						Component.onCompleted: forceActiveFocus()
						Keys.priority: Keys.BeforeItem
						Keys.onEscapePressed: root.open = false
						Keys.onDownPressed: event => {
							box.move(1)
							event.accepted = true
						}
						Keys.onUpPressed: event => {
							box.move(-1)
							event.accepted = true
						}
						// NOTE: backspace on an empty query walks back to the category list.
						Keys.onPressed: event => {
							if (event.modifiers & Qt.ControlModifier) {
								if (event.key === Qt.Key_J)
									box.move(1)
								else if (event.key === Qt.Key_K)
									box.move(-1)
								else if (event.key === Qt.Key_P)
									root.key("C-p", root.shown[list.currentIndex])
								else
									return

								event.accepted = true
								return
							}

							if (event.key === Qt.Key_Backspace && text === "") {
								root.back()
								event.accepted = true
							}
						}
					}
				}

				ListView {
					id: list

					anchors.top: filterRow.bottom
					anchors.bottom: footer.top
					anchors.left: parent.left
					anchors.right: parent.right
					anchors.margins: 8
					anchors.topMargin: 8
					clip: true
					interactive: false
					model: root.shown
					spacing: 4
					boundsBehavior: Flickable.StopAtBounds
					highlightFollowsCurrentItem: false

					// NOTE: rows are drawer cards like the reminder list, so the current one keeps in view by hand.
					onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

					// NOTE: same cards as the notch drawers, the current row is the brighter one.
					delegate: Card {
						id: row

						required property var modelData
						required property int index
						readonly property bool selected: ListView.isCurrentItem

						width: ListView.view.width
						height: 30
						radius: 8
						lit: row.selected

						Item {
							id: iconSlot

							anchors.left: parent.left
							anchors.leftMargin: 10
							anchors.verticalCenter: parent.verticalCenter
							width: 18
							height: 18

							Icon {
								anchors.centerIn: parent
								visible: !!row.modelData.icon
								name: row.modelData.icon ?? "folder"
								size: 14
								color: Theme.muted
							}

							Image {
								anchors.fill: parent
								visible: !!row.modelData.iconPath
								source: row.modelData.iconPath ?? ""
								sourceSize.width: 18
								sourceSize.height: 18
								asynchronous: true
							}
						}

						BarText {
							anchors.left: iconSlot.right
							anchors.right: chevron.left
							anchors.leftMargin: 10
							anchors.rightMargin: row.modelData.badge ? 60 : 8
							anchors.verticalCenter: parent.verticalCenter
							text: row.modelData.label
							font.pixelSize: 13
							color: Theme.ink
						}

						BarText {
							anchors.right: chevron.left
							anchors.rightMargin: 8
							anchors.verticalCenter: parent.verticalCenter
							visible: !!row.modelData.badge
							text: row.modelData.badge ?? ""
							font.pixelSize: 11
							color: Theme.muted
						}

						Icon {
							id: chevron

							anchors.right: parent.right
							anchors.rightMargin: 10
							anchors.verticalCenter: parent.verticalCenter
							visible: !!row.modelData.chevron && row.selected
							name: "chevron-right"
							size: 14
							color: Theme.muted
						}
					}
				}

				BarText {
					anchors.centerIn: list
					visible: list.count === 0
					text: root.items.length === 0 ? "Nothing here" : "No matches"
					font.pixelSize: 12
					color: Theme.muted
				}

				BarText {
					id: footer

					anchors.bottom: parent.bottom
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.bottomMargin: 12
					text: root.hint
					font.pixelSize: 11
					color: Theme.muted
				}
			}

			// NOTE: keyboard only. This stays on top so the pointer cannot move the selection, open a row, or fall through and steal the grab.
			MouseArea {
				anchors.fill: parent
				hoverEnabled: true
				acceptedButtons: Qt.AllButtons

				WheelHandler {
					onWheel: event => event.accepted = true
				}
			}
		}
	}
}
