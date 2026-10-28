import QtQuick
import Quickshell
import ".."

Item {
	id: root

	required property string glyph
	required property var command
	property color mark: Theme.ink

	implicitWidth: glyphText.implicitWidth + 12
	implicitHeight: Theme.wingHeight

	HoverFill {
		anchors.fill: parent
		anchors.topMargin: 10
		anchors.bottomMargin: 10
		shown: mouse.containsMouse
	}

	BarText {
		id: glyphText

		anchors.centerIn: parent
		text: root.glyph
		color: root.mark
	}

	MouseArea {
		id: mouse

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: Quickshell.execDetached(root.command)
	}
}
