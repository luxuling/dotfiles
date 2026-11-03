import QtQuick
import ".."

// NOTE: one agent session: status, prompt, the last few steps and the last reply. Clicking jumps to its pane.
Card {
	id: card

	required property var session

	readonly property bool live: session.status === "running" || session.status === "waiting"
	readonly property var spinner: ["·", "✻", "✽", "✶", "✳", "✶", "✽", "✻"]
	property int tick: 0

	function glyph(status) {
		if (status === "running")
			return card.spinner[card.tick % card.spinner.length]
		if (status === "waiting")
			return "✽"
		if (status === "cancelled")
			return "·"

		return status === "done" ? "✻" : "✳"
	}

	function verb(session) {
		if (session.status === "waiting")
			return "Waiting for you"
		if (session.status === "cancelled")
			return "Cancelled"
		if (session.status !== "running")
			return session.status === "done" ? "Done" : "Idle"

		const verbs = { run: "Running", edit: "Editing", explore: "Reading" }
		return verbs[Agents.stepKind(session.tool)] ?? "Thinking"
	}

	function safe(text) {
		return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
	}

	function plural(count, noun) {
		return `${count} ${noun}${count === 1 ? "" : "s"}`
	}

	function stepLabel(step) {
		const many = step.files.length > 1
		if (step.kind === "run")
			return step.count > 1 ? ["Ran", card.plural(step.count, "command")] : ["Ran", step.description.charAt(0).toLowerCase() + step.description.slice(1)]
		if (step.kind === "edit")
			return ["Edited", many ? card.plural(step.files.length, "file") : step.files[0] ?? "a file"]
		if (step.kind === "explore")
			return ["Explored", many ? card.plural(step.files.length, "file") : step.files[0] ?? "the code"]

		return ["Called", card.plural(step.count, "tool")]
	}

	function stepText(step) {
		const [verb, what] = card.stepLabel(step)
		const added = step.add > 0 ? ` <font color="${Theme.soft}">+${step.add}</font>` : ""
		const removed = step.del > 0 ? ` <font color="${Theme.muted}">-${step.del}</font>` : ""
		const diff = step.kind === "edit" ? added + removed : ""

		return `<font color="${Theme.muted}">◈</font> ${verb} ${card.safe(what)}${diff}`
	}

	height: details.implicitHeight + 18
	lit: area.containsMouse

	AgentLogo {
		id: dot

		anchors.left: parent.left
		anchors.leftMargin: 12
		anchors.verticalCenter: parent.verticalCenter
		agent: card.session.agent
		size: 18
	}

	// NOTE: the status glyph sits on the logo's corner, so the title and the lines below share one left edge.
	Rectangle {
		anchors.horizontalCenter: dot.right
		anchors.verticalCenter: dot.bottom
		width: 13
		height: 13
		radius: 7
		color: Theme.crust

		BarText {
			anchors.centerIn: parent
			text: card.glyph(card.session.status)
			font.pixelSize: 11
			color: card.live || card.session.status === "done" ? Theme.bright : Theme.muted
		}
	}

	Column {
		id: details

		anchors.left: dot.right
		anchors.right: parent.right
		anchors.leftMargin: 14
		anchors.rightMargin: 12
		anchors.verticalCenter: parent.verticalCenter
		spacing: 3

		Item {
			width: parent.width
			height: 18

			Row {
				anchors.left: parent.left
				anchors.right: corner.left
				anchors.rightMargin: 8
				height: parent.height
				spacing: 6
				clip: true

				// NOTE: a live status shimmers letter by letter, a settled one sits still.
				Row {
					anchors.verticalCenter: parent.verticalCenter

					Repeater {
						model: `${card.verb(card.session)}${card.session.status === "running" ? "…" : ""}`.split("")

						BarText {
							required property string modelData
							required property int index

							text: modelData
							font.pixelSize: 12
							color: card.live ? Qt.alpha(Theme.ink, 0.4 + 0.6 * Math.max(0, 1 - Math.abs(index - card.tick % (parent.children.length + 6)) / 3)) : Theme.ink
						}
					}
				}

				BarText {
					anchors.verticalCenter: parent.verticalCenter
					visible: card.session.tools > 0
					text: `·  ${card.plural(card.session.tools, "tool")}`
					font.pixelSize: 11
					font.weight: Font.Normal
					color: Theme.muted
				}
			}

			BarText {
				id: corner

				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
				text: `${card.session.project}  ·  ${Agents.elapsed(card.session.since)}`
				font.pixelSize: 11
				color: Theme.muted
			}
		}

		BarText {
			width: parent.width
			visible: text !== ""
			text: card.session.prompt !== "" ? `› ${card.session.prompt}` : ""
			font.pixelSize: 11
			font.weight: Font.Normal
			color: Theme.muted
		}

		Repeater {
			model: card.session.steps.slice(-4)

			BarText {
				required property var modelData

				width: parent.width
				text: card.stepText(modelData)
				textFormat: Text.StyledText
				font.pixelSize: 11
				font.weight: Font.Normal
				color: Qt.alpha(Theme.ink, 0.6)
			}
		}

		BarText {
			width: parent.width
			visible: text !== ""
			text: card.session.status !== "running" ? card.session.last : ""
			font.pixelSize: 11
			font.weight: Font.Normal
			color: Theme.muted
		}
	}

	MouseArea {
		id: area

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: Agents.jump(card.session.pane)
	}

	Timer {
		running: card.visible && card.live
		interval: 120
		repeat: true
		onTriggered: card.tick += 1
	}
}
