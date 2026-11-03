import QtQuick
import ".."

// NOTE: shared by the seek and volume bars. A live slider reports every drag step, otherwise it only reports on release.
Item {
	id: root

	property real value: 0
	property bool live: false
	readonly property bool active: area.containsMouse || area.pressed
	readonly property real shown: area.pressed ? area.fraction : Math.max(0, Math.min(1, value))

	signal moved(real fraction)

	implicitHeight: 12

	Rectangle {
		anchors.verticalCenter: parent.verticalCenter
		width: parent.width
		height: root.active ? 6 : 4
		radius: height / 2
		color: Theme.idle

		Behavior on height {
			NumberAnimation { duration: 100 }
		}

		Rectangle {
			width: parent.width * area.fraction
			height: parent.height
			radius: parent.radius
			color: Qt.alpha(Theme.ink, 0.15)
			visible: root.active
		}

		Rectangle {
			width: parent.width * root.shown
			height: parent.height
			radius: parent.radius
			color: Theme.ink
		}
	}

	Rectangle {
		anchors.verticalCenter: parent.verticalCenter
		x: root.width * root.shown - width / 2
		width: 12
		height: 12
		radius: 6
		color: Theme.ink
		scale: root.active ? 1 : 0

		Behavior on scale {
			NumberAnimation {
				duration: 120
				easing.type: Easing.OutBack
			}
		}
	}

	MouseArea {
		id: area

		readonly property real fraction: Math.max(0, Math.min(1, mouseX / width))

		anchors.fill: parent
		anchors.topMargin: -4
		anchors.bottomMargin: -4
		enabled: root.enabled
		hoverEnabled: true
		preventStealing: true
		cursorShape: Qt.PointingHandCursor
		onPressed: {
			if (root.live)
				root.moved(fraction)
		}
		onPositionChanged: {
			if (pressed && root.live)
				root.moved(fraction)
		}
		onReleased: root.moved(fraction)
		onWheel: event => {
			if (root.live)
				root.moved(Math.max(0, Math.min(1, root.value + (event.angleDelta.y > 0 ? 0.05 : -0.05))))
		}
	}
}
