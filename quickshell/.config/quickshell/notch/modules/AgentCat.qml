import QtQuick
import ".."

// NOTE: the cat rests while no agent works, plays at random while one does, and shakes wide-eyed while one waits or has an unseen alert.
Icon {
	id: root

	readonly property bool playing: Agents.sessions.some(session => session.status === "running") && !root.attention
	readonly property var moves: ["cat", "cat-eyes", "cat-tail", "cat-ear", "cat-tail"]
	property string pose: "cat"

	readonly property bool attention: Agents.waiting || Agents.alert !== null

	name: root.attention ? "cat-eyes" : root.playing ? root.pose : "cat"
	size: 16
	color: Theme.ink

	transform: Translate {
		id: shift

		Behavior on x {
			NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
		}

		Behavior on y {
			NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
		}
	}

	onPlayingChanged: {
		shift.x = 0
		shift.y = 0
		root.pose = "cat"
	}

	Timer {
		running: root.playing
		interval: 500
		repeat: true
		onTriggered: {
			root.pose = root.moves[Math.floor(Math.random() * root.moves.length)]
			shift.x = Math.round(Math.random() * 4) - 2
			shift.y = Math.random() < 0.25 ? -2 : 0
			interval = 300 + Math.random() * 700
		}
	}

	Shake on rotation {
		running: root.attention
	}
}
