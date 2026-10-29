----------------------------------------------------------------
-- MONITOR
----------------------------------------------------------------

hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1080@144",
	position = "0x0",
	scale = 1,
})

----------------------------------------------------------------
-- VARIABLES
----------------------------------------------------------------

local mainMod = "ALT"

local terminal = "ghostty"
local fileManager = "thunar"
local menu = "walker"
local screenshot = "hyprshot -m region -o /home/lixuling/Pictures/Screenshots/"
local lockscreen = "hyprlock"
local screenRecord = "$HOME/.config/scripts/mf-recording.sh"
local walkerRepos = "$HOME/.config/scripts/walker-repos.sh"

----------------------------------------------------------------
-- AUTOSTART
----------------------------------------------------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("swaync")
	hl.exec_cmd("qs -p /home/lixuling/dotfiles/quickshell/.config/quickshell/notch --no-duplicate")
	hl.exec_cmd("elephant")
	hl.exec_cmd("walker --gapplication-service")
end)

----------------------------------------------------------------
-- ENVIRONMENT VARIABLES
----------------------------------------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

----------------------------------------------------------------
-- LOOK AND FEEL
----------------------------------------------------------------

hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 20,

		border_size = 1,

		col = {
			-- GrokNight FG on the focused window, prompt_border on the rest
			active_border = "rgb(e1e1e1)",
			inactive_border = "rgb(323237)",
		},

		resize_on_border = false,
		allow_tearing = false,

		layout = "dwindle",
	},

	decoration = {
		rounding = 18,
		rounding_power = 2,

		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(0a0a0aee)",
		},

		-- BLUR
		-- Blur hanya terlihat kalau permukaan di atasnya transparan.
		-- Untuk window: atur transparansi di aplikasinya (mis. ghostty background-opacity).
		-- Untuk layer (waybar, walker, swaync): lihat layer_rule di bagian bawah.
		blur = {
			enabled = true,
			size = 8,
			passes = 3, -- 2 -> 3: blur lebih halus, tidak "kotak-kotak"
			vibrancy = 0.1696,
			new_optimizations = true,
			popups = true, -- blur menu klik-kanan / popup yang transparan
		},

		-- Baru di 0.56 (opsional): motion blur saat window digerakkan / di-resize
		-- motion_blur = {
		--     enabled = true,
		-- },
	},

	misc = {
		force_default_wallpaper = -1, -- 0 atau 1 untuk mematikan wallpaper maskot anime
		disable_hyprland_logo = false, -- true untuk mematikan logo / background Hyprland
	},
})

----------------------------------------------------------------
-- ANIMATIONS
----------------------------------------------------------------

hl.config({
	animations = {
		enabled = true,
	},
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "easeInOutCubic", style = "fade" })

----------------------------------------------------------------
-- LAYOUTS
----------------------------------------------------------------

hl.config({
	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},
})

----------------------------------------------------------------
-- INPUT
----------------------------------------------------------------

hl.config({
	input = {
		kb_layout = "us",

		follow_mouse = 1,
		sensitivity = 0, -- -1.0 - 1.0, 0 = tanpa modifikasi

		touchpad = {
			natural_scroll = false,
		},
	},
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

----------------------------------------------------------------
-- KEYBINDINGS
----------------------------------------------------------------

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("togglesplit")) -- dwindle (dulu ALT+J, bentrok dengan focus down)
hl.bind("Print", hl.dsp.exec_cmd(screenshot))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd(lockscreen))
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd(screenRecord))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(walkerRepos))

-- Restart utils
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("pkill -x qs; pkill hyprpaper; qs -p /home/lixuling/dotfiles/quickshell/.config/quickshell/notch & hyprpaper &"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("qs -p /home/lixuling/dotfiles/quickshell/.config/quickshell/notch --no-duplicate"))

-- Pindah fokus: mainMod + h,j,k,l
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Workspace 1-10: mainMod + [0-9], pindahkan window dengan mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll antar workspace
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Geser / resize window dengan mainMod + LMB / RMB
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume dan brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Media (butuh playerctl)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

----------------------------------------------------------------
-- WINDOW RULES
----------------------------------------------------------------

hl.window_rule({
	name = "ignore-maximize",
	match = { class = ".*" },
	suppress_event = "maximize",
})

-- Perbaikan fokus aneh pada popup XWayland (class dan title kosong)
hl.window_rule({
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "helium",
	match = { class = "helium" },
	workspace = "3 silent",
})

hl.window_rule({
	name = "easyeffects",
	match = { class = "com.github.wwmm.easyeffects" },
	workspace = "8 silent",
})

hl.window_rule({
	name = "spotify",
	match = { class = "Spotify" },
	workspace = "9 silent",
})

hl.window_rule({
	name = "discord",
	match = { class = "discord" },
	workspace = "10 silent",
})

hl.window_rule({
	name = "discord-popout",
	match = { class = "discord", initial_title = "Discord Popout" },
	float = true,
	pin = true,
	size = "576 324",
	move = { "monitor_w - 576 - 22", "22" },
})

hl.window_rule({
	name = "helium-pip",
	match = { initial_title = "Picture in picture" },
	float = true,
	pin = true,
	size = "576 324",
	move = { "monitor_w - 576 - 22", "monitor_h - 324 - 62" },
})

hl.window_rule({
	name = "firefox-meet-presentation",
	match = { class = "firefox", title = ".*Presentation Window.*" },
	float = true,
	pin = true,
})

hl.window_rule({
	name = "thunar-dialog",
	match = { class = "^thunar$" },
	float = true,
})

hl.window_rule({
	name = "thunar",
	match = { class = "^thunar$", title = ".* - Thunar$" },
	float = true,
	size = { "800", "monitor_h - 84" },
	move = { "monitor_w - 800 - 22", "22" },
})

-- Opsi B untuk blur ghostty (kalau tidak mau pakai background-opacity di ghostty):
-- ini membuat SEMUA isi window (termasuk teks) ikut transparan.
-- hl.window_rule({
--     name    = "ghostty-opacity",
--     match   = { class = "com.mitchellh.ghostty" },
--     opacity = "0.9 0.8",   -- aktif / tidak aktif
-- })

----------------------------------------------------------------
-- LAYER RULES (blur untuk bar, launcher, notifikasi)
-- Cek namespace dengan: hyprctl layers
-- Catatan: namespace adalah RegEx, gunakan "a|b" untuk beberapa namespace.
-- ignore_alpha: piksel dengan alpha <= nilai ini TIDAK di-blur.
-- Pastikan alpha background di CSS (walker/swaync) LEBIH TINGGI dari ini.
----------------------------------------------------------------

hl.layer_rule({
	name = "walker",
	match = { namespace = "walker" },
	blur = true,
	ignore_alpha = 0.3,
})

hl.layer_rule({
	name = "swaync",
	match = { namespace = "swaync-control-center|swaync-notification-window" },
	blur = true,
	ignore_alpha = 0.3,
})
