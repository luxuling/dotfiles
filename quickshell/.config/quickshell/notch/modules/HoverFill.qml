import QtQuick
import ".."

// NOTE: a circle by default so icon buttons match everywhere, wide slots like the clock override width into a pill.
Rectangle {
	required property bool shown

	width: Theme.hoverSize
	height: Theme.hoverSize
	x: (parent.width - width) / 2
	y: (parent.height - height) / 2
	radius: height / 2
	color: Theme.ink
	opacity: shown ? 0.08 : 0
}
