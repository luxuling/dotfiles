pragma Singleton
import QtQuick

QtObject {
	// GrokNight from grok-build theme/groknight.rs. Gray base, TokyoNight accents.
	readonly property color crust: "#141414" // BG_STORM, bg_base
	readonly property color text: "#e1e1e1" // FG, text_primary
	readonly property color ink: "#e1e1e1" // FG
	readonly property color accent: "#7aa2f7" // BLUE
	readonly property color muted: "#6c6c6c" // COMMENT
	readonly property color idle: "#363636" // bg_visual
	readonly property color gutter: "#414141" // FG_GUTTER
	readonly property color red: "#f7768e" // RED, urgent only
	readonly property color white: "#e1e1e1"

	readonly property string fontFamily: "Maple Mono NF CN"
	readonly property int fontSize: 15
	readonly property int clockSize: 16

	readonly property int foldedHeight: 46
	readonly property int wingHeight: 46
	readonly property int sidePad: 28
	readonly property int melt: 14
	readonly property int bottomRadius: 18
	readonly property int gap: 14
	readonly property int innerGap: 8
}
