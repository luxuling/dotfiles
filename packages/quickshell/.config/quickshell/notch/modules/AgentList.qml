import QtQuick
import ".."

Item {
	id: root

	Column {
		id: header

		width: parent.width
		spacing: 6

		UsageRow {
			visible: Usage.claude !== null
			agent: "claude"
			limits: Usage.claude === null ? [] : [
				{ label: "5h", used: Usage.claude.session, reset: Usage.claude.sessionReset },
				{ label: "7d", used: Usage.claude.week, reset: Usage.claude.weekReset }
			].filter(limit => limit.used !== null)
		}

		UsageRow {
			visible: Usage.grok !== null
			agent: "grok"
			limits: Usage.grok === null ? [] : [{ label: "7d", used: Usage.grok.week, reset: Usage.grok.weekReset }]
		}
	}

	BarText {
		anchors.centerIn: parent
		visible: Agents.sessions.length === 0
		text: "No agents running"
		font.pixelSize: 12
		color: Theme.muted
	}

	ListView {
		anchors.top: header.bottom
		anchors.topMargin: 10
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		clip: true
		spacing: 6
		model: Agents.sessions

		delegate: SessionCard {
			required property var modelData

			width: ListView.view.width
			session: modelData
		}
	}
}
