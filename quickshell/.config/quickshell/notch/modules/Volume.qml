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
	implicitWidth: 22
	implicitHeight: Theme.wingHeight

	HoverFill {
		anchors.fill: parent
		anchors.topMargin: 8
		anchors.bottomMargin: 8
		shown: mouse.containsMouse
	}

	CircleMeter {
		anchors.centerIn: parent
		fraction: root.level
		glyph: root.muted ? "" : root.level < 0.3 ? "" : root.level < 0.7 ? "" : ""
		mark: root.muted ? Theme.muted : Theme.ink
	}

	MouseArea {
		id: mouse

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: Quickshell.execDetached(["pavucontrol"])
		onWheel: event => {
			if (root.audio === null)
				return

			const direction = event.angleDelta.y > 0 ? 1 : -1
			const next = root.audio.volume + direction * 0.05
			root.audio.volume = Math.min(1.5, Math.max(0, next))
		}
	}
}
