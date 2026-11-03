import QtQuick
import ".."

// NOTE: the faint panel every notch card sits on, lit a step brighter on hover or focus.
Rectangle {
	property bool lit: false

	radius: 10
	color: Qt.alpha(Theme.ink, lit ? 0.08 : 0.04)
}
