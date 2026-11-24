import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import ".."

// NOTE: the settings drawer opens on a tile menu, a tile either runs a tool or opens its own page.
Item {
	id: root

	readonly property string base: Quickshell.env("HOME") + "/.local/share/wallpapers"
	readonly property string link: Quickshell.env("HOME") + "/.config/hypr/wallpaper.jpg"
	property string current: ""
	// NOTE: "" is the tile menu.
	property string page: ""
	// NOTE: set while ALT+W holds the keyboard, then the strip takes the keys.
	property bool keyboard: false

	signal close

	function reset() {
		root.page = ""
	}

	// NOTE: hyprpaper and hyprlock read ~/.config/hypr/wallpaper.jpg, so a pick repoints that link and tells hyprpaper.
	// hyprpaper only switches a monitor named in the call, an empty one is a silent no-op.
	function apply(name) {
		Quickshell.execDetached([
			"sh", "-c",
			"wall=$1; link=$2; shift 2; ln -sfn \"$wall\" \"$link\"; for mon; do hyprctl hyprpaper wallpaper \"$mon,$wall,cover\"; done",
			"sh", `${root.base}/${name}`, root.link,
			...Quickshell.screens.map(screen => screen.name)
		])
		root.current = name
	}

	onVisibleChanged: {
		if (visible)
			root.reset()
	}

	// NOTE: every screen has its own drawer, so the link is read again on each open in case another one changed it.
	onPageChanged: {
		if (page === "wallpaper")
			readCurrent.running = true
	}

	onKeyboardChanged: {
		if (keyboard)
			strip.forceActiveFocus()
	}

	Process {
		id: readCurrent

		command: ["readlink", root.link]
		stdout: StdioCollector {
			onStreamFinished: {
				root.current = text.trim().split("/").pop()
				for (let index = 0; index < walls.count; index++) {
					if (walls.get(index, "fileName") === root.current)
						strip.currentIndex = index
				}
			}
		}
	}

	FolderListModel {
		id: walls

		folder: "file://" + root.base
		nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
		showDirs: false
		sortCaseSensitive: false
	}

	component Tile: Card {
		id: tile

		required property string icon
		required property string label

		signal clicked

		width: 112
		height: 76
		lit: tileArea.containsMouse

		Column {
			anchors.centerIn: parent
			spacing: 8

			Icon {
				anchors.horizontalCenter: parent.horizontalCenter
				name: tile.icon
				size: 20
			}

			BarText {
				anchors.horizontalCenter: parent.horizontalCenter
				text: tile.label
				font.pixelSize: 12
				color: Theme.soft
			}
		}

		MouseArea {
			id: tileArea

			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor
			onClicked: tile.clicked()
		}
	}

	ColumnLayout {
		anchors.fill: parent
		visible: root.page === ""
		spacing: Theme.innerGap

		BarText {
			leftPadding: 4
			text: "settings"
			font.pixelSize: 13
			color: Theme.muted
		}

		Row {
			Layout.fillHeight: true
			spacing: 8

			Tile {
				icon: "image-01"
				label: "Wallpaper"
				onClicked: root.page = "wallpaper"
			}

			Tile {
				icon: "dropper"
				label: "Color picker"
				onClicked: Quickshell.execDetached(["hyprpicker", "--a"])
			}
		}
	}

	ColumnLayout {
		anchors.fill: parent
		visible: root.page === "wallpaper"
		spacing: Theme.innerGap

		RowLayout {
			Layout.fillWidth: true
			spacing: 4

			NavButton {
				icon: "chevron-left"
				onClicked: root.reset()
			}

			BarText {
				Layout.fillWidth: true
				text: "wallpaper"
				font.pixelSize: 13
				color: Theme.muted
			}

			BarText {
				visible: root.keyboard
				text: "←/→ move  ·  enter set  ·  esc close"
				font.pixelSize: 11
				color: Theme.muted
			}
		}

		ListView {
			id: strip

			Layout.fillWidth: true
			Layout.fillHeight: true
			visible: walls.count > 0
			orientation: ListView.Horizontal
			spacing: 8
			clip: true
			boundsBehavior: Flickable.StopAtBounds
			highlightFollowsCurrentItem: false
			model: walls

			onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

			Keys.onPressed: event => {
				if (event.key === Qt.Key_Left || event.key === Qt.Key_H)
					strip.currentIndex = Math.max(0, strip.currentIndex - 1)
				else if (event.key === Qt.Key_Right || event.key === Qt.Key_L)
					strip.currentIndex = Math.min(strip.count - 1, strip.currentIndex + 1)
				else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
					root.apply(walls.get(strip.currentIndex, "fileName"))
					root.close()
				} else if (event.key === Qt.Key_Escape)
					root.close()
				else
					return

				event.accepted = true
			}

			delegate: Item {
				id: thumb

				required property string fileName
				required property url fileUrl
				required property int index
				readonly property bool active: fileName === root.current
				// NOTE: with the keyboard the border is the cursor, with the mouse it marks the current wallpaper.
				readonly property bool marked: root.keyboard ? ListView.isCurrentItem : active

				width: height * 16 / 9
				height: ListView.view.height

				Image {
					id: picture

					anchors.fill: parent
					anchors.margins: 3
					visible: false
					source: thumb.fileUrl
					sourceSize.width: 360
					fillMode: Image.PreserveAspectCrop
					asynchronous: true
				}

				Rectangle {
					id: mask

					anchors.fill: picture
					visible: false
					radius: 8
					layer.enabled: true
				}

				MultiEffect {
					anchors.fill: picture
					source: picture
					maskEnabled: true
					maskSource: mask
					maskThresholdMin: 0.5
					maskSpreadAtMin: 1
					opacity: thumb.active || thumb.marked || area.containsMouse ? 1 : 0.6
				}

				Rectangle {
					anchors.fill: parent
					radius: 10
					color: "transparent"
					border.width: 1
					border.color: thumb.marked ? Theme.ink : "transparent"
				}

				MouseArea {
					id: area

					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: {
						strip.currentIndex = thumb.index
						root.apply(thumb.fileName)
					}
				}
			}
		}

		BarText {
			Layout.fillWidth: true
			Layout.fillHeight: true
			visible: walls.count === 0
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			text: "no wallpapers in ~/.local/share/wallpapers"
			font.pixelSize: 12
			color: Theme.muted
		}
	}
}
