import QtQuick
import Quickshell
import Quickshell.Bluetooth
import ".."

Item {
	id: root

	property int revision: 0

	readonly property var adapter: Bluetooth.defaultAdapter
	readonly property bool powered: adapter !== null && adapter.enabled
	readonly property int shownWidth: 28
	readonly property string statusText: {
		revision
		return statusLabel()
	}
	readonly property string statusIcon: {
		if (statusText === "Off")
			return "󰂲"

		if (statusText === "On")
			return ""

		if (statusText.indexOf("%") !== -1)
			return ""

		return "󰂱"
	}
	implicitWidth: shownWidth
	implicitHeight: Theme.wingHeight

	function retouch() {
		revision++
	}

	function statusLabel() {
		if (adapter === null || !powered)
			return "Off"

		for (let i = 0; i < devices.count; i++) {
			const device = devices.objectAt(i)
			if (device.connected)
				return device.label
		}

		return "On"
	}

	Instantiator {
		id: devices

		model: Bluetooth.devices

		delegate: QtObject {
			required property var modelData

			readonly property bool connected: modelData.connected
			readonly property bool hasBattery: modelData.batteryAvailable
			readonly property string label: {
				const name = modelData.name !== "" ? modelData.name : modelData.deviceName
				if (!modelData.batteryAvailable)
					return name

				return name + " " + Math.round(modelData.battery) + "%"
			}

			onConnectedChanged: root.retouch()
			onLabelChanged: root.retouch()
		}

		onObjectAdded: root.retouch()
		onObjectRemoved: root.retouch()
	}

	HoverFill {
		anchors.fill: parent
		anchors.topMargin: 8
		anchors.bottomMargin: 8
		shown: mouse.containsMouse
	}

	BarText {
		anchors.centerIn: parent
		text: root.statusIcon
		color: root.statusText === "Off" ? Theme.muted : Theme.ink
	}

	MouseArea {
		id: mouse

		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: Quickshell.execDetached(["blueman-manager"])
	}
}
