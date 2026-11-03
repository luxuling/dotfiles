import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import "modules"

Item {
	id: root

	required property int screenWidth
	required property string screenName

	property bool open: false
	property bool drawerOpen: false
	// NOTE: the kind outlives drawerOpen so the content stays visible while the drawer folds.
	property string drawerKind: "clock"

	readonly property int screenBudget: Math.max(0, screenWidth - 48)
	readonly property int barHeight: Theme.foldedHeight
	readonly property int groupGap: open ? 36 : Theme.gap
	readonly property bool drawerHovered: clockHover.hovered || spectrumHover.hovered || bell.hovered || agentButton.hovered || memory.hovered || volume.hovered || agentSlotHover.hovered || countdownHover.hovered || drawerHover.hovered || reminderPanel.typing
	readonly property bool wantsKeyboard: drawerOpen && drawerKind === "reminder"
	readonly property var spotify: Mpris.players.values.find(player => player.identity === "Spotify") ?? null
	// NOTE: the popup kept for the fold animation, Notifs.popup is already null by then.
	property var lastPopup: null

	implicitWidth: Math.min(screenBudget, Theme.melt * 2 + Theme.sidePad * 2 + workWrap.width + clockItem.width + meters.width + countdownSlot.width + agentSlot.width + extraSlot.width)
	// NOTE: innerGap is the space between the bar and the drawer content, added on top of the content height.
	readonly property int drawerSize: Theme.innerGap + (drawerKind === "popup" ? Math.min(Theme.drawerHeight, popupCard.implicitHeight + Theme.gap) : drawerKind === "agent" ? Math.min(Theme.drawerHeight, agentCard.implicitHeight + Theme.gap) : drawerKind === "alert" ? alertCard.height + Theme.gap : Theme.drawerHeight)

	implicitHeight: barHeight + (drawerOpen ? drawerSize : 0)

	// NOTE: the fold is delayed so the cursor can cross from the clock or spectrum into the drawer. A hovered popup pauses its timer instead.
	onDrawerHoveredChanged: {
		if (drawerHovered) {
			drawerFold.stop()
			drawerOpen = true
			if (drawerKind === "popup")
				Notifs.hold()
			return
		}

		if (drawerKind === "popup") {
			Notifs.release()
			return
		}

		// NOTE: a waiting agent request takes the drawer back once the cursor leaves, it only closes on an answer.
		if (Agents.current !== null) {
			drawerKind = "agent"
			return
		}

		drawerFold.start()
	}

	// NOTE: hovering the cat shows the unseen alert first, otherwise the session list.
	function agentsDrawer() {
		return Agents.alert !== null ? "alert" : "agents"
	}

	// NOTE: only a request that needs an answer opens the notch, alerts stay in the folded bar next to the cat.
	function syncAgent() {
		if (Agents.current === null) {
			if (drawerKind === "agent")
				drawerOpen = false
			if (!hover.hovered)
				open = false
			return
		}

		drawerKind = "agent"
		drawerFold.stop()
		drawerOpen = true
		open = true
	}

	Connections {
		target: Agents

		function onCurrentChanged() {
			root.syncAgent()
		}

		// NOTE: a jump folds the notch, unless another request still waits, which then takes the drawer.
		function onJumped() {
			if (Agents.current !== null) {
				root.syncAgent()
				return
			}

			root.drawerOpen = false
			root.open = false
		}
	}

	onDrawerKindChanged: {
		if (drawerKind !== "popup")
			Notifs.popup = null
	}

	Connections {
		target: Notifs

		function onPopupChanged() {
			if (Notifs.popup === null) {
				if (root.drawerKind === "popup")
					root.drawerOpen = false
				return
			}

			// NOTE: an open hover drawer wins, the notification still lands in the center.
			if (root.drawerOpen && root.drawerKind !== "popup")
				return

			root.lastPopup = Notifs.popup
			root.drawerKind = "popup"
			drawerFold.stop()
			root.drawerOpen = true
		}
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
		// NOTE: the notch stays wide while an agent card shows, the folded width is too narrow for it.
		onTriggered: root.open = Agents.current !== null
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

			HoverFill {
				width: clock.implicitWidth + 20
				shown: clockHover.hovered
			}

			Clock {
				id: clock

				anchors.centerIn: parent
			}

			HoverHandler {
				id: clockHover

				cursorShape: Qt.PointingHandCursor

				onHoveredChanged: {
					if (hovered)
						root.drawerKind = "clock"
				}
			}
		}

		// NOTE: the reminder entry always sits right of the clock. A pending reminder drains a ring here, the exact countdown lives in the drawer.
		Item {
			id: countdownSlot

			readonly property var next: Reminders.next
			readonly property bool pending: next !== null
			readonly property real remaining: next === null ? 0 : Reminders.remaining(next)
			readonly property bool urgent: next !== null && Reminders.urgent(next)

			// NOTE: folded, the slot only shows while a reminder is pending.
			width: root.open || pending ? Theme.hoverSize : 0
			height: root.barHeight
			clip: true

			Behavior on width {
				NumberAnimation {
					duration: 140
					easing.type: Easing.OutQuad
				}
			}

			Item {
				width: Theme.hoverSize
				height: parent.height

				HoverFill {
					shown: countdownHover.hovered
				}

				Icon {
					anchors.centerIn: parent
					visible: !countdownSlot.pending
					name: "hourglass-03"
				}

				CircleMeter {
					anchors.centerIn: parent
					visible: countdownSlot.pending
					fraction: countdownSlot.remaining
					icon: "hourglass-03"

					Behavior on fraction {
						NumberAnimation { duration: 1000 }
					}

					SequentialAnimation on opacity {
						running: countdownSlot.pending && !countdownSlot.urgent
						loops: Animation.Infinite
						alwaysRunToEnd: true

						NumberAnimation { to: 0.5; duration: 1200; easing.type: Easing.InOutSine }
						NumberAnimation { to: 1; duration: 1200; easing.type: Easing.InOutSine }
					}

					Shake on rotation {
						running: countdownSlot.urgent
						angle: 14
					}
				}

				HoverHandler {
					id: countdownHover

					cursorShape: Qt.PointingHandCursor

					onHoveredChanged: {
						if (hovered)
							root.drawerKind = "reminder"
					}
				}
			}
		}

		// NOTE: folded, a busy agent or an unseen alert shows as a cat here. Unfolded, the cat button covers it.
		Item {
			id: agentSlot

			readonly property var busy: Agents.sessions.filter(session => session.status === "running" || session.status === "waiting")

			width: !root.open && (busy.length > 0 || Agents.alert !== null) ? agentRow.implicitWidth + 12 : 0
			height: root.barHeight
			clip: true

			Behavior on width {
				NumberAnimation {
					duration: 140
					easing.type: Easing.OutQuad
				}
			}

			Row {
				id: agentRow

				anchors.centerIn: parent
				spacing: 4

				AgentCat {
					anchors.verticalCenter: parent.verticalCenter
				}

				BarText {
					anchors.verticalCenter: parent.verticalCenter
					visible: agentSlot.busy.length > 1
					text: agentSlot.busy.length
					font.pixelSize: 11
					color: Theme.muted
				}

			}

			HoverHandler {
				id: agentSlotHover

				cursorShape: Qt.PointingHandCursor

				onHoveredChanged: {
					if (hovered)
						root.drawerKind = root.agentsDrawer()
				}
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

				Spectrum {
					active: root.spotify !== null && root.spotify.isPlaying
				}
			}

			HoverHandler {
				id: spectrumHover

				onHoveredChanged: {
					if (hovered)
						root.drawerKind = "player"
				}
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
					anchors.verticalCenter: parent.verticalCenter
					spacing: 10

					Memory {
						id: memory

						onHoveredChanged: {
							if (hovered)
								root.drawerKind = "system"
						}
					}

					Volume {
						id: volume

						onHoveredChanged: {
							if (hovered)
								root.drawerKind = "sound"
						}
					}
				}

				Row {
					spacing: 4

					LaunchButton {
						icon: "dropper"
						command: ["hyprpicker", "--a"]
					}

					NotifButton {
						id: bell

						onHoveredChanged: {
							if (hovered)
								root.drawerKind = "center"
						}
					}

					AgentButton {
						id: agentButton

						onHoveredChanged: {
							if (hovered)
								root.drawerKind = root.agentsDrawer()
						}
					}
				}

				Tray {}
			}
		}
	}

	Item {
		y: root.barHeight
		width: root.width
		height: root.height - root.barHeight
		clip: true

		HoverHandler { id: drawerHover }

		Item {
			anchors.left: parent.left
			anchors.right: parent.right
			anchors.top: parent.top
			anchors.topMargin: Theme.innerGap
			anchors.leftMargin: Theme.melt + Theme.gap
			anchors.rightMargin: Theme.melt + Theme.gap
			height: Theme.drawerHeight - Theme.gap
			opacity: root.drawerOpen ? 1 : 0

			Behavior on opacity {
				NumberAnimation { duration: 160 }
			}

			RowLayout {
				anchors.fill: parent
				spacing: Theme.innerGap
				visible: root.drawerKind === "clock"

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

			Player {
				anchors.fill: parent
				visible: root.drawerKind === "player"
				player: root.spotify
			}

			NotifCard {
				id: popupCard

				width: parent.width
				visible: root.drawerKind === "popup"
				notification: root.lastPopup
				showActions: true
				// NOTE: the folded notch only peeks at the popup, hovering widens it into the full card.
				compact: !root.open
			}

			NotifCenter {
				anchors.fill: parent
				visible: root.drawerKind === "center"
			}

			AgentCard {
				id: agentCard

				width: parent.width
				visible: root.drawerKind === "agent"
				request: Agents.current
			}

			AgentList {
				anchors.fill: parent
				visible: root.drawerKind === "agents"
			}

			Loader {
				id: alertCard

				width: parent.width
				active: root.drawerKind === "alert" && Agents.alert !== null

				sourceComponent: SessionCard {
					session: Agents.session(Agents.alert.session)
				}
			}

			System {
				anchors.fill: parent
				visible: root.drawerKind === "system"
			}

			Sound {
				anchors.fill: parent
				visible: root.drawerKind === "sound"
			}

			ReminderPanel {
				id: reminderPanel

				anchors.fill: parent
				visible: root.drawerKind === "reminder"
			}
		}
	}
}
