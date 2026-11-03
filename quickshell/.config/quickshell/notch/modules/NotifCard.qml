import QtQuick
import Quickshell.Widgets
import ".."

Card {
	id: root

	required property var notification
	property bool showActions: false
	// NOTE: compact is the folded popup, one glance of icon, summary and the first body line.
	property bool compact: false
	property string hint: ""

	readonly property var defaultAction: notification?.actions.find(action => action.identifier === "default") ?? null
	readonly property var buttons: notification?.actions.filter(action => action.identifier !== "default") ?? []
	readonly property string icon: notification === null ? "" : Notifs.iconFor(notification)
	readonly property string shot: notification === null ? "" : Notifs.screenshotOf(notification)
	// NOTE: browsers prepend the site origin as the first body line, it is noise next to the app icon.
	readonly property string body: shot !== "" ? `Copied to clipboard · ${shot.split("/").pop()}` : (notification?.body ?? "").replace(/^(<a [^>]*>)?(https?:\/\/)?[\w-]+(\.[\w-]+)*\.[a-z]{2,}(:\d+)?\/?(<\/a>)?(\n+|$)/i, "").replace(/\n+/g, " ")

	// NOTE: apps only send action labels, so the label is matched to an icon. Order matters, "show in folder" must hit folder before show.
	function iconFor(label) {
		const rules = [
			[/folder|directory/i, "folder"],
			[/reply|respond/i, "flip-backward"],
			[/setting|preference|config/i, "settings-01"],
			[/copy/i, "copy-01"],
			[/delete|remove|trash/i, "trash-01"],
			[/archive/i, "archive"],
			[/snooze|later|remind/i, "clock"],
			[/call|answer/i, "phone"],
			[/download|save/i, "download-01"],
			[/like/i, "thumbs-up"],
			[/pause/i, "pause-circle"],
			[/play|resume/i, "play"],
			[/next|skip/i, "skip-forward"],
			[/prev|back/i, "skip-back"],
			[/open|view|show|launch|go to/i, "link-external-01"],
			[/read|done|ok|accept|confirm|yes|allow/i, "check"],
			[/dismiss|close|cancel|decline|deny|ignore|^no$/i, "x-close"]
		]
		return rules.find(rule => rule[0].test(label))?.[1] ?? "dots-horizontal"
	}

	implicitHeight: content.implicitHeight + 12
	lit: card.containsMouse

	// NOTE: clicking the card reveals a screenshot in thunar, runs the app's default action, or just dismisses when there is none.
	MouseArea {
		id: card

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: {
			if (root.shot !== "")
				Notifs.showInFolder(root.shot)

			if (root.defaultAction !== null)
				root.defaultAction.invoke()
			else
				root.notification.dismiss()
		}
	}

	Row {
		id: content

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.margins: 6
		anchors.leftMargin: 8
		spacing: 8

		ClippingRectangle {
			id: image

			anchors.verticalCenter: parent.verticalCenter
			width: root.compact ? 24 : 32
			height: width
			radius: 6
			color: Theme.idle

			Image {
				anchors.fill: parent
				visible: root.icon !== ""
				source: root.icon
				sourceSize.width: 64
				sourceSize.height: 64
				fillMode: Image.PreserveAspectCrop
				asynchronous: true
			}

			Icon {
				anchors.centerIn: parent
				visible: root.icon === ""
				name: "bell-01"
				color: Theme.muted
			}
		}

		Column {
			width: parent.width - image.width - parent.spacing - (side.visible ? side.width + parent.spacing : 0)
			spacing: 1

			// NOTE: hovering an action swaps the app name for the action label, so an unmatched icon is never a guess.
			BarText {
				width: parent.width
				visible: !root.compact
				text: root.hint !== "" ? root.hint : root.notification?.appName ?? ""
				font.pixelSize: 10
				color: Theme.muted
			}

			BarText {
				width: parent.width
				text: root.notification?.summary ?? ""
				font.pixelSize: 12
				color: Theme.ink
			}

			// NOTE: bodies carry freedesktop markup (b, i, u, a, img), StyledText renders that subset and ignores the rest.
			BarText {
				width: parent.width
				visible: text !== ""
				text: root.body
				textFormat: Text.StyledText
				font.pixelSize: 11
				font.weight: Font.Normal
				color: root.compact ? Theme.muted : Theme.ink
				linkColor: Theme.bright
				onLinkActivated: link => Qt.openUrlExternally(link)
			}
		}

		Row {
			id: side

			visible: !root.compact

			Repeater {
				model: root.showActions ? root.buttons : []

				NavButton {
					required property var modelData

					icon: root.iconFor(modelData.text)
					onClicked: modelData.invoke()
					onHoveredChanged: root.hint = hovered ? modelData.text : ""
				}
			}

			NavButton {
				icon: "x-close"
				onClicked: root.notification.dismiss()
			}
		}
	}
}
