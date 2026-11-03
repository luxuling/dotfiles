import QtQuick
import Quickshell.Widgets
import ".."

Item {
	id: root

	required property var player

	function formatTime(seconds) {
		const total = Math.max(0, Math.floor(seconds))
		const minutes = Math.floor(total / 60)
		const rest = total % 60
		return `${minutes}:${rest < 10 ? "0" : ""}${rest}`
	}

	// NOTE: Mpris only reports position on demand, so it is re-read every second while playing.
	Timer {
		interval: 1000
		running: root.player !== null && root.player.isPlaying
		repeat: true
		onTriggered: root.player.positionChanged()
	}

	BarText {
		anchors.centerIn: parent
		visible: root.player === null
		text: "Spotify not running"
		font.pixelSize: 12
		color: Theme.muted
	}

	Row {
		anchors.fill: parent
		spacing: Theme.gap
		visible: root.player !== null

		ClippingRectangle {
			id: cover

			width: parent.height
			height: parent.height
			radius: 12
			color: Theme.idle

			Image {
				anchors.fill: parent
				source: root.player?.trackArtUrl ?? ""
				fillMode: Image.PreserveAspectCrop
				asynchronous: true
			}
		}

		Column {
			anchors.verticalCenter: parent.verticalCenter
			width: parent.width - cover.width - parent.spacing
			spacing: 4

			BarText {
				width: parent.width
				text: root.player?.trackTitle ?? ""
				font.pixelSize: 16
				color: Theme.ink
			}

			// NOTE: artist and album share a line so the volume row fits under the controls.
			BarText {
				width: parent.width
				text: [root.player?.trackArtist ?? "", root.player?.trackAlbum ?? ""].filter(part => part !== "").join("  ·  ")
				font.pixelSize: 12
				color: Theme.muted
			}

			Item {
				width: 1
				height: 6
			}

			// NOTE: while dragging the fill follows the cursor, the seek itself happens on release.
			BarSlider {
				width: parent.width
				value: root.player !== null && root.player.length > 0 ? root.player.position / root.player.length : 0
				enabled: root.player !== null && root.player.canSeek
				onMoved: fraction => root.player.position = fraction * root.player.length
			}

			Item {
				width: parent.width
				height: 16

				BarText {
					anchors.left: parent.left
					text: root.formatTime(root.player?.position ?? 0)
					font.pixelSize: 11
					color: Theme.muted
				}

				BarText {
					anchors.right: parent.right
					text: root.formatTime(root.player?.length ?? 0)
					font.pixelSize: 11
					color: Theme.muted
				}
			}

			Item {
				width: parent.width
				height: 32

				Row {
					id: controls

					anchors.left: parent.left
					// NOTE: skip-back is centered in the button and its stroke starts 4 units into a 24-wide viewBox, so the row shifts left until the glyph meets the title and the seek bar.
					anchors.leftMargin: -((previous.width - Theme.iconSize) / 2 + Theme.iconSize * 4 / 24)
					anchors.verticalCenter: parent.verticalCenter
					spacing: 12

					NavButton {
						id: previous

						width: 32
						height: 32
						icon: "skip-back"
						onClicked: root.player.previous()
					}

					NavButton {
						width: 32
						height: 32
						icon: root.player?.isPlaying ? "pause-circle" : "play-circle"
						onClicked: root.player.togglePlaying()
					}

					NavButton {
						width: 32
						height: 32
						icon: "skip-forward"
						onClicked: root.player.next()
					}
				}

				// NOTE: this is Spotify's own volume over Mpris, the system volume stays on the bar meter. It sits right of the controls, as wide as them.
				Item {
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					width: controls.width
					height: 16
					visible: root.player?.volumeSupported ?? false

					Icon {
						id: volumeLow

						anchors.left: parent.left
						anchors.verticalCenter: parent.verticalCenter
						name: (root.player?.volume ?? 0) === 0 ? "volume-x" : (root.player?.volume ?? 0) < 0.5 ? "volume-min" : "volume-max"
						size: 14
						color: Theme.muted
					}

					BarSlider {
						anchors.left: volumeLow.right
						anchors.right: parent.right
						anchors.leftMargin: 8
						anchors.verticalCenter: parent.verticalCenter
						live: true
						value: root.player?.volume ?? 0
						onMoved: fraction => root.player.volume = fraction
					}
				}
			}
		}
	}
}
