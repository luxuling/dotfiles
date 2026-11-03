import QtQuick
import ".."

BarText {
	id: root

	property date now: new Date()

	font.pixelSize: Theme.clockSize
	color: Theme.ink
	text: Qt.formatDateTime(now, "HH:mm")

	Timer {
		interval: 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: root.now = new Date()
	}
}
