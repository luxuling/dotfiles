import QtQuick
import QtQuick.Effects
import ".."

// NOTE: the vendored Untitled UI svgs are stroked white so colorization can tint them to any theme colour.
Image {
	id: root

	required property string name
	property color color: Theme.ink
	property int size: Theme.iconSize

	width: size
	height: size
	source: Qt.resolvedUrl(`../icons/${name}.svg`)
	sourceSize.width: size
	sourceSize.height: size
	layer.enabled: true
	layer.effect: MultiEffect {
		colorization: 1
		colorizationColor: root.color
	}
}
