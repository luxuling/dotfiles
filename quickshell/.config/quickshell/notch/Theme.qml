pragma Singleton
import QtQuick

QtObject {
	// NOTE: GrokNight grays only, the notch stays monochrome. The one hue is Claude's logo.
	readonly property color crust: "#141414"
	readonly property color idle: "#363636"
	readonly property color gutter: "#414141"
	readonly property color muted: "#6c6c6c"
	readonly property color soft: "#bdbdbd"
	readonly property color ink: "#e1e1e1"
	readonly property color bright: "#ffffff"
	readonly property color claude: "#d97757"

	readonly property string fontFamily: "Maple Mono NF CN"
	readonly property int fontSize: 15
	readonly property int clockSize: 16

	// NOTE: 34 is the 26px hover fill plus 4px each side, going lower clips the hover fills.
	readonly property int foldedHeight: 34
	readonly property int wingHeight: 34
	readonly property int sidePad: 16
	readonly property int melt: 14
	readonly property int bottomRadius: 14
	readonly property int gap: 14
	readonly property int innerGap: 8
	readonly property int hoverSize: 26
	readonly property int iconSize: 16
	readonly property int drawerHeight: 200
}
