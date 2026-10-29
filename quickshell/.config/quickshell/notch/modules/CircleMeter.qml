import QtQuick
import QtQuick.Shapes
import ".."

Item {
	id: root

	required property real fraction
	required property string glyph
	property color mark: Theme.ink

	implicitWidth: 20
	implicitHeight: 20

	Shape {
		anchors.fill: parent
		preferredRendererType: Shape.CurveRenderer

		ShapePath {
			strokeColor: Theme.idle
			strokeWidth: 1.5
			fillColor: "transparent"
			capStyle: ShapePath.RoundCap

			PathAngleArc {
				centerX: root.width / 2
				centerY: root.height / 2
				radiusX: 8
				radiusY: 8
				startAngle: -90
				sweepAngle: 359.9
			}
		}

		ShapePath {
			strokeColor: root.mark
			strokeWidth: 1.5
			fillColor: "transparent"
			capStyle: ShapePath.RoundCap

			PathAngleArc {
				centerX: root.width / 2
				centerY: root.height / 2
				radiusX: 8
				radiusY: 8
				startAngle: -90
				sweepAngle: Math.min(359.9, 360 * root.fraction)
			}
		}
	}

	BarText {
		anchors.centerIn: parent
		font.pixelSize: 9
		text: root.glyph
		color: root.mark
	}
}
