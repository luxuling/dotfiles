import QtQuick
import ".."
import "../time.js" as Time

Item {
	id: root

	readonly property bool typing: input.activeFocus
	readonly property var presets: [5, 15, 30, 60]
	property int minutes: 10
	// NOTE: clock mode rings at a picked time of day, clockMinutes counts from midnight.
	property bool atClock: false
	property int clockMinutes: 0
	property bool invalid: false
	readonly property var draft: Reminders.preview(input.text, presetMs(Reminders.now))

	onVisibleChanged: {
		if (!visible)
			input.focus = false
	}

	function presetMs(now) {
		if (!root.atClock)
			return root.minutes * 60000

		return Time.nextClock(Math.floor(root.clockMinutes / 60), root.clockMinutes % 60, now) - now
	}

	// NOTE: clock mode starts at the time the duration would have rung, so switching never jumps far.
	function toggleClock() {
		if (!root.atClock) {
			const at = new Date(Date.now() + root.minutes * 60000)
			root.clockMinutes = at.getHours() * 60 + at.getMinutes()
		}

		root.atClock = !root.atClock
	}

	function shiftClock(delta) {
		root.clockMinutes = (root.clockMinutes + delta + 1440) % 1440
	}

	function submit() {
		if (!Reminders.add(input.text, root.presetMs(Date.now()))) {
			root.invalid = true
			invalidReset.restart()
			input.forceActiveFocus()
			return
		}

		input.text = ""
	}

	// NOTE: one minute steps up to 5m, five minute steps after, so both "2m" and "45m" are a few clicks away.
	function step(direction) {
		if (root.atClock) {
			root.shiftClock(direction * 5)
			return
		}

		const size = root.minutes < 5 || (root.minutes === 5 && direction < 0) ? 1 : 5
		root.minutes = Math.max(1, Math.min(720, root.minutes + direction * size))
	}

	Timer {
		id: invalidReset

		interval: 700
		onTriggered: root.invalid = false
	}

	Card {
		id: field

		width: parent.width
		height: 32
		lit: input.activeFocus
		border.width: 1
		border.color: root.invalid ? Theme.bright : "transparent"

		Icon {
			id: fieldIcon

			anchors.left: parent.left
			anchors.leftMargin: 10
			anchors.verticalCenter: parent.verticalCenter
			name: "hourglass-03"
			color: Theme.muted
		}

		TextInput {
			id: input

			anchors.left: fieldIcon.right
			anchors.right: parent.right
			anchors.leftMargin: 8
			anchors.rightMargin: 10
			anchors.verticalCenter: parent.verticalCenter
			clip: true
			selectByMouse: true
			font.family: Theme.fontFamily
			font.pixelSize: 12
			color: Theme.ink
			selectionColor: Qt.alpha(Theme.bright, 0.4)
			onAccepted: root.submit()
			Keys.onUpPressed: root.step(1)
			Keys.onDownPressed: root.step(-1)
			Keys.onEscapePressed: {
				input.text = ""
				input.focus = false
			}

			BarText {
				anchors.verticalCenter: parent.verticalCenter
				visible: input.text === ""
				text: "What should I remind you about?  e.g. \"12:22 call mom\" or \"25m tea\""
				font.pixelSize: 12
				font.weight: Font.Normal
				color: Theme.muted
			}
		}
	}

	Item {
		id: when

		anchors.top: field.bottom
		anchors.topMargin: 8
		width: parent.width
		height: 28

		NavButton {
			id: modeButton

			anchors.verticalCenter: parent.verticalCenter
			icon: root.atClock ? "clock" : "hourglass-03"
			onClicked: root.toggleClock()
		}

		Card {
			id: stepper

			anchors.left: modeButton.right
			anchors.leftMargin: 4
			anchors.verticalCenter: parent.verticalCenter
			width: stepperRow.implicitWidth + 4
			height: 28
			radius: height / 2

			Row {
				id: stepperRow

				anchors.centerIn: parent

				NavButton {
					anchors.verticalCenter: parent.verticalCenter
					icon: "minus"
					onClicked: root.step(-1)
				}

				Item {
					anchors.verticalCenter: parent.verticalCenter
					width: 52
					height: 24

					BarText {
						anchors.centerIn: parent
						visible: !root.atClock
						text: Time.span(root.minutes)
						font.pixelSize: 12
						color: Theme.ink
					}

					// NOTE: the wheel over the hour moves hours, over the minute it moves single minutes.
					Row {
						anchors.centerIn: parent
						visible: root.atClock

						BarText {
							text: String(Math.floor(root.clockMinutes / 60)).padStart(2, "0")
							font.pixelSize: 12
							color: Theme.ink

							WheelHandler {
								onWheel: event => root.shiftClock(event.angleDelta.y > 0 ? 60 : -60)
							}
						}

						BarText {
							text: ":"
							font.pixelSize: 12
							color: Theme.muted
						}

						BarText {
							text: String(root.clockMinutes % 60).padStart(2, "0")
							font.pixelSize: 12
							color: Theme.ink

							WheelHandler {
								onWheel: event => root.shiftClock(event.angleDelta.y > 0 ? 1 : -1)
							}
						}
					}
				}

				NavButton {
					anchors.verticalCenter: parent.verticalCenter
					icon: "plus"
					onClicked: root.step(1)
				}
			}

			WheelHandler {
				enabled: !root.atClock
				onWheel: event => root.step(event.angleDelta.y > 0 ? 1 : -1)
			}
		}

		Row {
			anchors.left: stepper.right
			anchors.leftMargin: 8
			anchors.verticalCenter: parent.verticalCenter
			spacing: 4

			Repeater {
				model: root.presets

				Pill {
					required property int modelData

					label: Time.span(modelData)
					active: !root.atClock && root.minutes === modelData
					onClicked: {
						root.atClock = false
						root.minutes = modelData
					}
				}
			}
		}

		// NOTE: the button names the exact ring time, so a typed "25m" or "14:30" prefix is confirmed before adding.
		Rectangle {
			id: addButton

			readonly property bool ready: root.draft !== null

			anchors.right: parent.right
			anchors.verticalCenter: parent.verticalCenter
			width: addRow.implicitWidth + 20
			height: 28
			radius: height / 2
			color: ready ? Qt.alpha(Theme.ink, addArea.containsMouse ? 0.9 : 0.8) : Qt.alpha(Theme.ink, 0.04)

			Behavior on color {
				ColorAnimation { duration: 120 }
			}

			Row {
				id: addRow

				anchors.centerIn: parent
				spacing: 6

				Icon {
					anchors.verticalCenter: parent.verticalCenter
					name: "plus"
					size: 14
					color: addButton.ready ? Theme.crust : Theme.muted
				}

				BarText {
					anchors.verticalCenter: parent.verticalCenter
					text: addButton.ready ? `Remind at ${Time.formatClock(root.draft.at)}` : "Remind me"
					font.pixelSize: 12
					color: addButton.ready ? Theme.crust : Theme.muted
				}
			}

			MouseArea {
				id: addArea

				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: root.submit()
			}
		}
	}

	BarText {
		anchors.centerIn: list
		visible: Reminders.items.length === 0
		text: "No reminders yet"
		font.pixelSize: 12
		color: Theme.muted
	}

	ListView {
		id: list

		anchors.top: when.bottom
		anchors.topMargin: 8
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		clip: true
		spacing: 4
		model: Reminders.items

		delegate: Card {
			id: row

			required property var modelData
			required property int index
			readonly property real remaining: Reminders.remaining(modelData)
			readonly property bool urgent: Reminders.urgent(modelData)

			width: ListView.view.width
			height: 40
			radius: 8
			lit: rowHover.hovered

			HoverHandler {
				id: rowHover
			}

			CircleMeter {
				id: ring

				anchors.left: parent.left
				anchors.leftMargin: 10
				anchors.verticalCenter: parent.verticalCenter
				fraction: row.remaining
				icon: "hourglass-03"
				mark: row.urgent ? Theme.bright : Theme.ink

				Behavior on fraction {
					NumberAnimation { duration: 1000 }
				}
			}

			Column {
				anchors.left: ring.right
				anchors.leftMargin: 10
				anchors.right: countdown.left
				anchors.rightMargin: 8
				anchors.verticalCenter: parent.verticalCenter
				spacing: 1

				BarText {
					width: parent.width
					text: row.modelData.text
					font.pixelSize: 12
					color: Theme.ink
				}

				BarText {
					width: parent.width
					text: `rings ${Time.formatClock(row.modelData.at)}`
					font.pixelSize: 10
					font.weight: Font.Normal
					color: Theme.muted
				}
			}

			BarText {
				id: countdown

				anchors.right: cancel.left
				anchors.rightMargin: 2
				anchors.verticalCenter: parent.verticalCenter
				text: Time.formatCountdown(row.modelData.at, Reminders.now)
				font.pixelSize: 13
				color: row.urgent ? Theme.bright : Theme.ink
			}

			// NOTE: the cancel button only shows on hover, its slot stays reserved so the countdown never jumps.
			NavButton {
				id: cancel

				anchors.right: parent.right
				anchors.rightMargin: 6
				anchors.verticalCenter: parent.verticalCenter
				opacity: rowHover.hovered ? 1 : 0
				enabled: rowHover.hovered
				icon: "x-close"
				onClicked: Reminders.remove(row.index)

				Behavior on opacity {
					NumberAnimation { duration: 120 }
				}
			}
		}
	}
}
