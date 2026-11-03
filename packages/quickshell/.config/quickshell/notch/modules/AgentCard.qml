import QtQuick
import ".."

// NOTE: one compact card for a blocking agent request: a permission, a question or a plan to approve.
Card {
	id: root

	property var request: null

	readonly property var message: request === null ? null : request.message
	readonly property string kind: message === null ? "" : message.event === "PermissionRequest" ? "permission" : message.tool === "ExitPlanMode" ? "plan" : "question"
	readonly property var question: kind === "question" ? message.input.questions[step] : null

	// NOTE: AskUserQuestion can carry several questions, they are answered one after another before the single reply.
	property int step: 0
	property var answers: ({})
	property var picked: []

	onRequestChanged: {
		root.step = 0
		root.answers = {}
		root.picked = []
	}

	function answer(label) {
		if (root.question.multiSelect) {
			root.picked = root.picked.includes(label) ? root.picked.filter(other => other !== label) : [...root.picked, label]
			return
		}

		root.commit(label)
	}

	function commit(label) {
		root.answers = Object.assign({}, root.answers, { [root.question.question]: label })
		root.picked = []

		if (root.step + 1 < root.message.input.questions.length) {
			root.step += 1
			return
		}

		Agents.reply(root.request, { decision: "allow", answers: root.answers })
	}

	function title() {
		const what = root.kind === "permission" ? root.message.tool : root.kind === "plan" ? "plan" : root.question.header
		return `${root.message.project}  ·  ${what}`
	}

	// NOTE: a plan shows only its first heading or line, the full plan stays in the terminal.
	function planTitle() {
		const line = root.message.input.plan.split("\n").find(text => text.trim() !== "")
		return Agents.plain(line)
	}

	function headline() {
		if (root.kind === "question")
			return root.question.question
		if (root.kind === "plan")
			return root.planTitle()

		return Agents.describe(root.message)
	}

	implicitHeight: content.implicitHeight + 16

	Rectangle {
		id: logo

		anchors.left: parent.left
		anchors.top: parent.top
		anchors.margins: 8
		width: 26
		height: 26
		radius: 7
		color: Theme.idle

		AgentLogo {
			anchors.centerIn: parent
			agent: root.message === null ? "claude" : root.message.agent
			size: 16
		}
	}

	Column {
		id: content

		anchors.left: logo.right
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.margins: 8
		anchors.leftMargin: 10
		anchors.rightMargin: 10
		spacing: 6

		BarText {
			width: parent.width
			text: root.message === null ? "" : root.title()
			font.pixelSize: 10
			color: Theme.muted
		}

		BarText {
			width: parent.width
			text: root.message === null ? "" : root.headline()
			font.pixelSize: 12
			color: Theme.ink
		}

		Flow {
			width: parent.width
			spacing: 6

			Repeater {
				model: root.question !== null ? root.question.options : []

				Pill {
					required property var modelData

					label: modelData.label
					active: root.picked.includes(modelData.label)
					onClicked: root.answer(modelData.label)
				}
			}

			Pill {
				visible: root.question !== null && root.question.multiSelect === true
				label: "Send"
				onClicked: root.commit(root.picked.join(", "))
			}

			Pill {
				visible: root.kind === "permission" || root.kind === "plan"
				label: root.kind === "plan" ? "Approve" : "Allow"
				active: true
				onClicked: Agents.reply(root.request, { decision: "allow" })
			}

			Pill {
				visible: root.kind === "permission" || root.kind === "plan"
				label: root.kind === "plan" ? "Reject" : "Deny"
				onClicked: Agents.reply(root.request, { decision: "deny" })
			}

			Pill {
				label: "Terminal"
				onClicked: {
					Agents.jump(root.message.pane)
					Agents.reply(root.request, { decision: "terminal" })
				}
			}
		}
	}
}
