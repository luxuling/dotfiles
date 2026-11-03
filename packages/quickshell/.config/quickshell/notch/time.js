const UNIT_MS = { h: 3600000, m: 60000, s: 1000 }

function parseDuration(spec) {
	// NOTE: QML's JS engine has no String.matchAll, so the whole spec is validated first and split with a global match.
	if (!/^(\d+[hms])+$/.test(spec))
		return 0

	return spec.match(/\d+[hms]/g).reduce((total, part) => total + Number(part.slice(0, -1)) * UNIT_MS[part.slice(-1)], 0)
}

function nextClock(hours, minutes, now) {
	const at = new Date(now)
	at.setHours(hours, minutes, 0, 0)
	if (at.getTime() <= now)
		at.setDate(at.getDate() + 1)

	return at.getTime()
}

function parseAt(spec, now) {
	const clock = /^(\d{1,2}):(\d{2})$/.exec(spec)
	if (clock === null)
		return now + parseDuration(spec)

	const hours = Number(clock[1])
	const minutes = Number(clock[2])
	if (hours > 23 || minutes > 59)
		return now

	return nextClock(hours, minutes, now)
}

// NOTE: a leading "25m", "1h30m", "45s" or "14:30" sets the time, otherwise the picked preset does.
function parseReminder(input, now, presetMs) {
	const text = input.trim()
	if (text === "")
		return null

	const match = /^(\S+)\s+(.+)$/.exec(text)
	const at = match === null ? now : parseAt(match[1], now)
	if (at > now)
		return { from: now, at, text: match[2] }

	return { from: now, at: now + presetMs, text }
}

function formatCountdown(at, now) {
	const total = Math.max(0, Math.ceil((at - now) / 1000))
	const hours = Math.floor(total / 3600)
	const minutes = Math.floor(total / 60) % 60
	const seconds = String(total % 60).padStart(2, "0")

	return hours > 0 ? `${hours}:${String(minutes).padStart(2, "0")}:${seconds}` : `${minutes}:${seconds}`
}

function formatClock(at) {
	const date = new Date(at)

	return `${String(date.getHours()).padStart(2, "0")}:${String(date.getMinutes()).padStart(2, "0")}`
}

function span(minutes) {
	const days = Math.floor(minutes / 1440)
	const hours = Math.floor(minutes / 60) % 24
	const rest = minutes % 60
	if (days > 0)
		return `${days}d ${hours}h`
	if (hours > 0)
		return rest === 0 ? `${hours}h` : `${hours}h ${rest}m`

	return `${rest}m`
}
