import QtQuick
import QtQuick.Controls
import ".."

Column {
	id: root

	readonly property int cell: 24

	property int month: new Date().getMonth()
	property int year: new Date().getFullYear()
	property date selected: new Date()

	topPadding: 4
	spacing: 4

	function shift(step) {
		const next = new Date(root.year, root.month + step, 1)
		root.month = next.getMonth()
		root.year = next.getFullYear()
	}

	function reset() {
		const today = new Date()
		root.month = today.getMonth()
		root.year = today.getFullYear()
		root.selected = today
	}

	function sameDay(a, b) {
		return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate()
	}

	component NavButton: Item {
		id: button

		required property string glyph
		signal clicked

		width: 24
		height: 24

		HoverFill {
			anchors.fill: parent
			shown: area.containsMouse
		}

		BarText {
			anchors.centerIn: parent
			text: button.glyph
			font.pixelSize: 13
		}

		MouseArea {
			id: area

			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor
			onClicked: button.clicked()
		}
	}

	WheelHandler {
		onWheel: event => root.shift(event.angleDelta.y > 0 ? -1 : 1)
	}

	Item {
		width: grid.width
		height: 24

		NavButton {
			anchors.left: parent.left
			glyph: "‹"
			onClicked: root.shift(-1)
		}

		BarText {
			anchors.centerIn: parent
			text: Qt.formatDate(new Date(root.year, root.month, 1), "MMM yyyy")
			font.pixelSize: 12

			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: root.reset()
			}
		}

		NavButton {
			anchors.right: parent.right
			glyph: "›"
			onClicked: root.shift(1)
		}
	}

	DayOfWeekRow {
		width: grid.width
		height: 16
		padding: 0
		spacing: 0

		delegate: BarText {
			required property string shortName

			text: shortName.slice(0, 2)
			color: Theme.muted
			font.pixelSize: 10
			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
		}
	}

	MonthGrid {
		id: grid

		month: root.month
		year: root.year
		width: root.cell * 7
		height: (root.cell - 2) * 6
		padding: 0
		spacing: 0

		onClicked: date => root.selected = date

		delegate: Item {
			id: day

			required property var model

			readonly property bool inMonth: model.month === root.month
			readonly property bool isSelected: root.sameDay(model.date, root.selected)

			Rectangle {
				anchors.centerIn: parent
				width: 20
				height: 20
				radius: 10
				color: day.model.today ? Theme.accent : (dayArea.containsMouse ? Theme.idle : "transparent")
				border.width: day.isSelected && !day.model.today ? 1 : 0
				border.color: Theme.accent
			}

			BarText {
				anchors.centerIn: parent
				text: day.model.day
				font.pixelSize: 11
				color: day.model.today ? Theme.crust : (day.inMonth ? Theme.text : Theme.muted)
			}

			// NOTE: MonthGrid emits clicked itself; this area only drives the hover tint.
			MouseArea {
				id: dayArea

				anchors.fill: parent
				hoverEnabled: true
				acceptedButtons: Qt.NoButton
				cursorShape: Qt.PointingHandCursor
			}
		}
	}
}
