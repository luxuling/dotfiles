pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// NOTE: one server for every screen, the per-screen notches only read popup and list from here.
Singleton {
	id: root

	property bool dnd: false
	property var popup: null

	readonly property var list: server.trackedNotifications
	readonly property int count: server.trackedNotifications.values.length

	function show(notification) {
		root.popup = notification
		popupTimer.interval = notification.expireTimeout > 0 ? notification.expireTimeout * 1000 : 5000
		popupTimer.restart()
	}

	function hold() {
		popupTimer.stop()
	}

	function release() {
		if (root.popup !== null)
			popupTimer.restart()
	}

	function clearAll() {
		for (const notification of server.trackedNotifications.values.slice())
			notification.dismiss()
	}

	// NOTE: hyprshot sends the saved file as the image-path hint, the body only has it wrapped in markup.
	function screenshotOf(notification) {
		// NOTE: quickshell turns a bare image-path into image://icon/<path>, file:// paths pass through as is.
		const path = decodeURIComponent(notification.image.replace(/^(file:\/\/|image:\/\/icon\/)/, ""))
		if (notification.appName !== "Hyprshot" || !path.startsWith("/"))
			return ""

		return path.replace(/\/+/g, "/")
	}

	// NOTE: thunar owns FileManager1, so this opens the folder with the file selected.
	function showInFolder(path) {
		Quickshell.execDetached(["dbus-send", "--session", "--type=method_call", "--dest=org.freedesktop.FileManager1", "/org/freedesktop/FileManager1", "org.freedesktop.FileManager1.ShowItems", `array:string:file://${path}`, "string:"])
	}

	function iconFor(notification) {
		if (notification.image !== "")
			return notification.image

		const icon = notification.appIcon
		if (icon === "")
			return ""

		if (icon.startsWith("/") || icon.startsWith("file:"))
			return icon

		return Quickshell.iconPath(icon, true)
	}

	NotificationServer {
		id: server

		keepOnReload: true
		actionsSupported: true
		bodySupported: true
		bodyMarkupSupported: true
		bodyHyperlinksSupported: true
		imageSupported: true

		// NOTE: reminders ring, coding agents chime through Agents, everything else is silent.
		onNotification: notification => {
			notification.tracked = true
			if (/reminder/i.test(notification.appName))
				Quickshell.execDetached(["pw-play", "/usr/share/sounds/freedesktop/stereo/complete.oga"])

			if (!root.dnd || notification.urgency === NotificationUrgency.Critical)
				root.show(notification)
		}
	}

	Timer {
		id: popupTimer

		onTriggered: root.popup = null
	}

	Connections {
		target: root.popup

		function onClosed() {
			root.popup = null
		}
	}
}
