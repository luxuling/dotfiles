import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import ".."

Item {
	id: root

	readonly property var sink: Pipewire.defaultAudioSink
	readonly property var audio: sink === null ? null : sink.audio

	// NOTE: Pipewire leaves channel volumes at 0 until the sink is tracked.
	PwObjectTracker {
		objects: [Pipewire.defaultAudioSink]
	}
	readonly property bool muted: audio !== null && audio.muted
	readonly property real level: audio === null || muted ? 0 : Math.max(0, Math.min(1, audio.volume))
	readonly property bool hovered: mouse.containsMouse
	implicitWidth: 22
	implicitHeight: Theme.wingHeight

	HoverFill {
		shown: mouse.containsMouse
	}

	CircleMeter {
		anchors.centerIn: parent
		fraction: root.level
		icon: root.muted ? "volume-x" : root.level < 0.5 ? "volume-min" : "volume-max"
		mark: root.muted ? Theme.muted : Theme.ink
	}

	MouseArea {
		id: mouse

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: {
			if (root.audio !== null)
				root.audio.muted = !root.audio.muted
		}
		onWheel: event => {
			if (root.audio === null)
				return

			const direction = event.angleDelta.y > 0 ? 1 : -1
			const next = root.audio.volume + direction * 0.05
			root.audio.volume = Math.min(1.5, Math.max(0, next))
		}
	}
}
