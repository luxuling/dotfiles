import QtQuick
import ".."

Text {
	font.family: Theme.fontFamily
	font.pixelSize: Theme.fontSize
	font.weight: Font.Medium
	color: Theme.ink
	elide: Text.ElideRight
	wrapMode: Text.NoWrap
	maximumLineCount: 1
	renderType: Text.QtRendering
}
