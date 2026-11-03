import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import ".."

// NOTE: master output on top, then one row per app playing audio.
ColumnLayout {
	id: root

	readonly property var sink: Pipewire.defaultAudioSink
	// NOTE: playback streams are the ones feeding a sink. properties stay empty until a node is tracked, so they can't filter.
	readonly property var streams: Pipewire.nodes.values.filter(node => node.isStream && node.isSink && node.audio !== null)

	spacing: Theme.innerGap

	// NOTE: Pipewire leaves channel volumes at 0 until a node is tracked.
	PwObjectTracker {
		objects: [root.sink, ...root.streams]
	}

	component VolumeRow: Card {
		id: row

		required property var node
		required property string label
		readonly property var audio: node?.audio ?? null
		readonly property bool muted: audio !== null && audio.muted
		readonly property real level: audio === null ? 0 : audio.volume

		Layout.fillWidth: true
		implicitHeight: 36

		RowLayout {
			anchors.fill: parent
			anchors.leftMargin: 6
			anchors.rightMargin: 12
			spacing: 10

			Item {
				implicitWidth: 24
				implicitHeight: 24

				HoverFill {
					shown: muteArea.containsMouse
				}

				Icon {
					anchors.centerIn: parent
					name: row.muted || row.level === 0 ? "volume-x" : row.level < 0.5 ? "volume-min" : "volume-max"
					color: row.muted ? Theme.muted : Theme.ink
				}

				MouseArea {
					id: muteArea

					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: {
						if (row.audio !== null)
							row.audio.muted = !row.audio.muted
					}
				}
			}

			BarText {
				Layout.preferredWidth: 140
				text: row.label
				font.pixelSize: 13
				color: row.muted ? Theme.muted : Theme.ink
			}

			BarSlider {
				Layout.fillWidth: true
				live: true
				value: row.level
				onMoved: fraction => {
					if (row.audio !== null)
						row.audio.volume = fraction
				}
			}

			BarText {
				Layout.preferredWidth: 36
				horizontalAlignment: Text.AlignRight
				text: `${Math.round(row.level * 100)}%`
				font.pixelSize: 12
				color: Theme.muted
			}
		}
	}

	RowLayout {
		Layout.fillWidth: true
		spacing: 4

		VolumeRow {
			node: root.sink
			label: root.sink?.description ?? "no output"
		}

		LaunchButton {
			icon: "settings-01"
			command: ["pavucontrol"]
		}
	}

	Flickable {
		Layout.fillWidth: true
		Layout.fillHeight: true
		contentHeight: apps.implicitHeight
		clip: true

		ColumnLayout {
			id: apps

			width: parent.width
			spacing: 6

			Repeater {
				model: root.streams

				VolumeRow {
					required property var modelData

					node: modelData
					label: modelData.properties["application.name"] ?? modelData.name
				}
			}

			BarText {
				Layout.fillWidth: true
				visible: root.streams.length === 0
				horizontalAlignment: Text.AlignHCenter
				topPadding: 24
				text: "no apps playing"
				font.pixelSize: 12
				color: Theme.muted
			}
		}
	}
}
