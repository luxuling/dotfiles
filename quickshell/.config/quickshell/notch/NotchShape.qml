import QtQuick
import QtQuick.Shapes

Shape {
	id: root

	// NOTE: the shoulders flare out to y=0. The cubics are quarter-circles tangent to the screen edge and the side wall.
	readonly property real curve: 0.5522847498

	anchors.fill: parent
	preferredRendererType: Shape.GeometryRenderer

	ShapePath {
		fillColor: Theme.crust
		strokeColor: "transparent"
		strokeWidth: 0
		fillRule: ShapePath.WindingFill
		joinStyle: ShapePath.RoundJoin

		startX: 0
		startY: 0

		PathLine { x: root.width; y: 0 }

		PathCubic {
			control1X: root.width - Theme.melt * root.curve
			control1Y: 0
			control2X: root.width - Theme.melt
			control2Y: Theme.melt * root.curve
			x: root.width - Theme.melt
			y: Theme.melt
		}

		PathLine { x: root.width - Theme.melt; y: root.height - Theme.bottomRadius }

		PathArc {
			x: root.width - Theme.melt - Theme.bottomRadius
			y: root.height
			radiusX: Theme.bottomRadius
			radiusY: Theme.bottomRadius
			direction: PathArc.Clockwise
		}

		PathLine { x: Theme.melt + Theme.bottomRadius; y: root.height }

		PathArc {
			x: Theme.melt
			y: root.height - Theme.bottomRadius
			radiusX: Theme.bottomRadius
			radiusY: Theme.bottomRadius
			direction: PathArc.Clockwise
		}

		PathLine { x: Theme.melt; y: Theme.melt }

		PathCubic {
			control1X: Theme.melt
			control1Y: Theme.melt * (1 - root.curve)
			control2X: Theme.melt * root.curve
			control2Y: 0
			x: 0
			y: 0
		}
	}
}
