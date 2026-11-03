import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../time.js" as Time

// NOTE: the stats tmux2k used to show (cpu, cpu-temp, ram, bandwidth, uptime), read in one probe while the drawer is up.
RowLayout {
	id: root

	readonly property int interval: 2000

	property real cpu: 0
	property int temp: 0
	property real ramUsedKb: 0
	property real ramTotalKb: 1
	property real downBps: 0
	property real upBps: 0
	property int uptimeSeconds: 0

	property var last: null

	spacing: Theme.innerGap

	Process {
		id: probe

		// ponytail: temp reads AMD k10temp only, swap the name (coretemp on Intel) for other CPUs.
		command: ["sh", "-c", "head -1 /proc/stat; cat /proc/meminfo /proc/net/dev /proc/uptime; for h in /sys/class/hwmon/*; do [ \"$(cat $h/name)\" = k10temp ] && echo temp $(cat $h/temp1_input); done"]
		stdout: StdioCollector {
			waitForEnd: true
			onStreamFinished: root.read(text)
		}
	}

	Timer {
		interval: root.interval
		running: root.visible
		repeat: true
		triggeredOnStart: true
		onTriggered: probe.running = true
	}

	function read(text) {
		const lines = text.split("\n")
		const cpuTimes = lines[0].trim().split(/\s+/).slice(1).map(Number)
		const idle = cpuTimes[3] + cpuTimes[4]
		const total = cpuTimes.reduce((sum, value) => sum + value, 0)

		let rx = 0
		let tx = 0
		for (const line of lines) {
			const net = /^\s*([^\s:]+):\s*(\d+)(?:\s+\d+){7}\s+(\d+)/.exec(line)
			if (net !== null && net[1] !== "lo") {
				rx += Number(net[2])
				tx += Number(net[3])
			}
		}

		const now = Date.now()
		// NOTE: rates need two samples, the first tick after opening only seeds them.
		if (last !== null) {
			const seconds = (now - last.at) / 1000
			cpu = 1 - (idle - last.idle) / Math.max(1, total - last.total)
			downBps = (rx - last.rx) / seconds
			upBps = (tx - last.tx) / seconds
		}
		last = { at: now, idle, total, rx, tx }

		ramTotalKb = Number(/MemTotal:\s+(\d+)/.exec(text)[1])
		ramUsedKb = ramTotalKb - Number(/MemAvailable:\s+(\d+)/.exec(text)[1])

		const tempMatch = /^temp (\d+)/m.exec(text)
		temp = tempMatch === null ? 0 : Math.round(Number(tempMatch[1]) / 1000)

		const uptimeLine = lines.find(line => /^\d+\.\d+ \d+\.\d+$/.test(line.trim()))
		uptimeSeconds = uptimeLine === undefined ? 0 : Math.floor(parseFloat(uptimeLine))
	}

	function rate(bytesPerSecond) {
		if (bytesPerSecond >= 1048576)
			return `${(bytesPerSecond / 1048576).toFixed(1)} MB/s`

		return `${Math.round(bytesPerSecond / 1024)} KB/s`
	}

	component Tile: Card {
		id: tile

		property string label
		property string value
		property string detail
		property string icon
		// NOTE: a fraction draws a meter ring, -1 shows the bare icon.
		property real fraction: -1

		Layout.fillWidth: true
		Layout.fillHeight: true
		Layout.preferredWidth: 0
		radius: 12

		Column {
			anchors.centerIn: parent
			width: parent.width - 16
			spacing: 6

			CircleMeter {
				anchors.horizontalCenter: parent.horizontalCenter
				visible: tile.fraction >= 0
				fraction: Math.max(0, tile.fraction)
				icon: tile.icon
			}

			Icon {
				anchors.horizontalCenter: parent.horizontalCenter
				visible: tile.fraction < 0
				name: tile.icon
			}

			BarText {
				width: parent.width
				horizontalAlignment: Text.AlignHCenter
				text: tile.value
				font.pixelSize: 15
				color: Theme.ink
			}

			BarText {
				width: parent.width
				horizontalAlignment: Text.AlignHCenter
				visible: tile.detail !== ""
				text: tile.detail
				font.pixelSize: 11
				color: Theme.muted
			}

			BarText {
				width: parent.width
				horizontalAlignment: Text.AlignHCenter
				text: tile.label
				font.pixelSize: 11
				color: Theme.muted
			}
		}
	}

	Tile {
		label: "cpu"
		value: `${Math.round(root.cpu * 100)}%`
		detail: root.temp > 0 ? `${root.temp}°C` : ""
		icon: "cpu-chip-01"
		fraction: root.cpu
	}

	Tile {
		label: "ram"
		value: `${(root.ramUsedKb / 1048576).toFixed(1)} GiB`
		detail: `of ${(root.ramTotalKb / 1048576).toFixed(1)} GiB`
		icon: "cpu-chip-01"
		fraction: root.ramUsedKb / root.ramTotalKb
	}

	Tile {
		label: "network"
		value: `↓ ${root.rate(root.downBps)}`
		detail: `↑ ${root.rate(root.upBps)}`
		icon: "download-01"
	}

	Tile {
		label: "uptime"
		value: Time.span(Math.floor(root.uptimeSeconds / 60))
		icon: "hourglass-01"
	}
}
