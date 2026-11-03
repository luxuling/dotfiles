import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "modules"

// NOTE: the centered vim picker behind the app launcher and project picker, items are { label, icon | iconPath, search?, chevron?, badge? }.
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
	// NOTE: any other plain key in normal mode, so a user can add its own bindings like "p" to pin.
	signal key(string text, var item)

	onOpenChanged: {
		root.query = ""
		root.restore = ""
	}

	// NOTE: the window is rebuilt on every open, so the selection and modes always start fresh.
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

			MouseArea {
				anchors.fill: parent
				onClicked: root.open = false
			}

			Rectangle {
				id: box

				// NOTE: opens in search mode, esc drops to the vim keys.
				property bool filtering: true
				property bool pendingG: false

				function move(delta) {
					list.currentIndex = Math.max(0, Math.min(list.count - 1, list.currentIndex + delta))
				}

				function forward() {
					const item = root.shown[list.currentIndex]
					if (item !== undefined)
						root.picked(item)
				}

				function dismiss() {
					if (root.query !== "") {
						root.query = ""
						return
					}

					root.open = false
				}

				function stopFiltering() {
					box.filtering = false
					list.forceActiveFocus()
				}

				anchors.centerIn: parent
				width: 520
				height: 360
				radius: 18
				color: Theme.crust

				// NOTE: swallows clicks so only the backdrop closes the picker.
				MouseArea {
					anchors.fill: parent
				}

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
					anchors.topMargin: visible ? 8 : 0
					height: visible ? 24 : 0
					visible: box.filtering || root.query !== ""

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
						Keys.onEscapePressed: {
							root.query = ""
							box.stopFiltering()
						}
						Keys.onDownPressed: box.move(1)
						Keys.onUpPressed: box.move(-1)
						// NOTE: backspace on an empty query walks back up, like h in normal mode.
						Keys.onPressed: event => {
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
					focus: true
					model: root.shown
					spacing: 4
					boundsBehavior: Flickable.StopAtBounds
					highlightFollowsCurrentItem: false

					// NOTE: rows are drawer cards like the reminder list, so the current one keeps in view by hand.
					onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

					// NOTE: letters are read from event.text so "G" and "g" differ, Ctrl chords use the key code.
					Keys.onPressed: event => {
						const pendingG = box.pendingG
						box.pendingG = false
						const half = Math.max(1, Math.floor(list.height / 34 / 2))

						if (event.modifiers & Qt.ControlModifier) {
							if (event.key === Qt.Key_D)
								box.move(half)
							else if (event.key === Qt.Key_U)
								box.move(-half)
							else
								return
						} else if (event.text === "j" || event.key === Qt.Key_Down) {
							box.move(1)
						} else if (event.text === "k" || event.key === Qt.Key_Up) {
							box.move(-1)
						} else if (event.text === "G") {
							list.currentIndex = list.count - 1
						} else if (event.text === "g") {
							if (pendingG)
								list.currentIndex = 0
							else
								box.pendingG = true
						} else if (event.text === "l" || event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Right) {
							box.forward()
						} else if (event.text === "h" || event.key === Qt.Key_Left || event.key === Qt.Key_Backspace) {
							root.back()
						} else if (event.text === "/") {
							box.filtering = true
							filterInput.forceActiveFocus()
						} else if (event.text === "q" || event.key === Qt.Key_Escape) {
							box.dismiss()
						} else if (event.text !== "") {
							root.key(event.text, root.shown[list.currentIndex])
						} else {
							return
						}

						event.accepted = true
					}

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

						MouseArea {
							anchors.fill: parent
							hoverEnabled: true
							cursorShape: Qt.PointingHandCursor
							onEntered: list.currentIndex = row.index
							onClicked: {
								list.currentIndex = row.index
								box.forward()
							}
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
					text: box.filtering ? "enter open  ·  esc normal mode" : root.hint
					font.pixelSize: 11
					color: Theme.muted
				}
			}
		}
	}
}
