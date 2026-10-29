import QtQuick
import ".."

Rectangle {
	required property bool shown

	radius: height / 2
	color: Theme.white
	opacity: shown ? 0.08 : 0
}
