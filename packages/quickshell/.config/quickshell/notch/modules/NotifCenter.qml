import QtQuick
import ".."

Item {
	id: root

	Item {
		id: header

		width: parent.width
		height: 24

		BarText {
			anchors.left: parent.left
			anchors.verticalCenter: parent.verticalCenter
			text: Notifs.count > 0 ? `Notifications  ${Notifs.count}` : "Notifications"
			font.pixelSize: 13
			color: Theme.ink
		}

		Row {
			anchors.right: parent.right
			spacing: 4

			NavButton {
				icon: Notifs.dnd ? "bell-off-01" : "bell-01"
				onClicked: Notifs.dnd = !Notifs.dnd
			}

			NavButton {
				icon: "trash-01"
				onClicked: Notifs.clearAll()
			}
		}
	}

	BarText {
		anchors.centerIn: list
		visible: Notifs.count === 0
		text: "No notifications"
		font.pixelSize: 12
		color: Theme.muted
	}

	ListView {
		id: list

		anchors.top: header.bottom
		anchors.topMargin: 8
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		clip: true
		spacing: 6
		model: Notifs.list

		delegate: NotifCard {
			required property var modelData

			width: ListView.view.width
			notification: modelData
		}
	}
}
