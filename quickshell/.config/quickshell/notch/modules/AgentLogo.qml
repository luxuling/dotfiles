import QtQuick
import ".."

Icon {
	required property string agent

	name: agent
	color: agent === "claude" ? Theme.claude : Theme.ink
}
