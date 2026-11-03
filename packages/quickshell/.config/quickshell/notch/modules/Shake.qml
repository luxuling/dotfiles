import QtQuick

// NOTE: a quick wiggle that repeats with a pause, used as `Shake on rotation` to ask for attention.
SequentialAnimation {
	property real angle: 10

	loops: Animation.Infinite
	alwaysRunToEnd: true

	NumberAnimation { to: -angle; duration: 60 }
	NumberAnimation { to: angle; duration: 120 }
	NumberAnimation { to: -angle * 0.6; duration: 120 }
	NumberAnimation { to: 0; duration: 60 }
	PauseAnimation { duration: 700 }
}
