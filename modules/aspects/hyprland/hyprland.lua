-- Hyprland 0.57 config (Lua). Linked to ~/.config/hypr/hyprland.lua by hyprland.nix.
-- Behaviour mirrors the mango config (modules/aspects/wayland/mango/mangowc.nix):
-- gaps, master layout (centered on the LG ultrawide), layout cycling, lazy
-- scratchpads, and the window stash. Animations are Hyprland's defaults.
-- Cursor theme/size come from HM session vars (stylix) via ~/.config/uwsm/env.

local LG = 'LG Electronics LG HDR WQHD' -- EDID make + model of the ultrawide

------------------------------------------------------------------------------
-- Options
------------------------------------------------------------------------------
hl.config({
  general = {
    layout = 'master',
    gaps_in = 5,
    gaps_out = 5,
    border_size = 4,
    -- colours from Hyprland's example config (example/hyprland.lua)
    col = {
      active_border = { colors = { 'rgba(33ccffee)', 'rgba(00ff99ee)' }, angle = 45 },
      inactive_border = 'rgba(595959aa)',
    },
    resize_on_border = true,
  },
  input = {
    kb_options = 'grp:alt_caps_toggle,caps:super',
    numlock_by_default = false,
    repeat_delay = 300,
    repeat_rate = 25,
    follow_mouse = 2,
    float_switch_override_focus = 0,
    sensitivity = 0,
    touchpad = {
      natural_scroll = false,
      disable_while_typing = true,
      scroll_factor = 0.8,
    },
  },
  -- mango's view_current_to_back: SUPER+<current> jumps back to the previous workspace
  binds = { workspace_back_and_forth = 1 },
  master = {
    mfact = 0.55,
    new_status = 'master',
    orientation = 'left',
    -- centered (mango center_tile): master centred once there is 1 stack window,
    -- the first stack window goes right; a lone window spans the full width
    slave_count_for_center_master = 1,
    center_master_fallback = 'right',
  },
  layers = { layers_hog_keyboard_focus = true },
  misc = {
    initial_workspace_tracking = 1,
    mouse_move_enables_dpms = true,
    key_press_enables_dpms = false,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    enable_swallow = true,
    vrr = 2,
    enable_anr_dialog = true,
    on_focus_under_fullscreen = 1, -- monocle: focused window takes over the maximize
    anr_missed_pings = 15,
  },
  decoration = { rounding = 5 },
  ecosystem = {
    no_donation_nag = true,
    no_update_news = true,
  },
  cursor = {
    sync_gsettings_theme = true,
    no_hardware_cursors = 2,
    enable_hyprcursor = true,
    warp_on_change_workspace = 0,
    no_warps = true,
  },
  render = { direct_scanout = 0 },
})

------------------------------------------------------------------------------
-- Monitors (mango monitor_rule): LG at its max mode, anything else preferred
------------------------------------------------------------------------------
-- Workspace switch + windows: default is speed 8 (800 ms) on the "default" curve, whose long
-- tail crawls at the end. easeOutCubic over 300 ms settles without the crawl.
hl.curve('easeOutCubic', { type = 'bezier', points = { { 0.33, 1 }, { 0.68, 1 } } })
hl.animation({ leaf = 'workspaces', enabled = true, speed = 3, bezier = 'easeOutCubic' })
hl.animation({ leaf = 'windows', enabled = true, speed = 3, bezier = 'easeOutCubic' }) -- open/close/move, same reason

hl.monitor({ output = 'desc:' .. LG, mode = '3440x1440@75.05', position = '0x0', scale = 1, supports_wide_color = -1 })
hl.monitor({ output = '', mode = 'preferred', position = 'auto', scale = 1 })

------------------------------------------------------------------------------
-- Workspaces
------------------------------------------------------------------------------
for i = 1, 5 do
  hl.workspace_rule({ workspace = tostring(i), persistent = true })
end
hl.workspace_rule({ workspace = 'special:minimized', gaps_out = 100 })

-- Centered master on the LG (mango tag_rule); elsewhere master.orientation = "left".
-- Filter expressions can't hold spaces (wiki selectors.md); desc: matches by prefix.
hl.workspace_rule({ workspace = 'm[desc:LG]', layout = 'master', layout_opts = { orientation = 'center' } })

-- SUPER+o cycles the active workspace: master left -> master center -> monocle.
-- Built-ins only, no rules: the master layout's orientation messages are per
-- workspace and clear a maximized window themselves (MasterAlgorithm.cpp).
-- "monocle" = focused window maximized; misc.on_focus_under_fullscreen = 1 makes
-- the next focused window take over, like mango's monocle.
local NEXT = { left = 'center', center = 'monocle', monocle = 'left' }
-- ponytail: Lua-side state; desyncs if you unmaximize by other means (one extra SUPER+o)
local layout_of = {} -- workspace name -> "left" | "center" | "monocle"

local function on_lg(ws)
  local mon = ws.monitor
  return mon ~= nil and mon.description ~= nil and mon.description:find(LG, 1, true) ~= nil
end

local function cycle_layout()
  local ws = hl.get_active_workspace()
  if not ws or not hl.get_active_window() then
    return
  end
  local nxt = NEXT[layout_of[ws.name] or (on_lg(ws) and 'center' or 'left')]
  layout_of[ws.name] = nxt
  if nxt == 'monocle' then
    hl.dispatch(hl.dsp.window.fullscreen({ mode = 'maximized', action = 'set' }))
  else
    hl.dispatch(hl.dsp.layout('orientation' .. nxt))
  end
end

------------------------------------------------------------------------------
-- Scratchpads: special workspaces, app spawned on first toggle, 70% x 70% centred.
-- Only one is visible at a time; the same key hides it again.
------------------------------------------------------------------------------
local SCRATCHPADS = {
  term = { class = 'kitty-term', cmd = 'kitty --class kitty-term' },
  filemanager = { class = 'org.gnome.Nautilus', cmd = 'nautilus' },
  pw = { class = 'bitwarden', cmd = 'bitwarden' },
  slack = { class = 'Slack', cmd = 'slack' },
  ente = { class = 'io.ente.auth', cmd = 'enteauth' },
}

for name, sp in pairs(SCRATCHPADS) do
  hl.window_rule({
    match = { class = sp.class },
    workspace = 'special:' .. name .. ' silent',
    float = true,
    size = { 'monitor_w * 0.7', 'monitor_h * 0.7' },
    center = true,
  })
end

-- Replaces the removed on_created_empty rule (wiki code snippet).
hl.on('workspace.created', function(ws)
  if not ws.is_empty or not ws.special then
    return
  end
  local sp = SCRATCHPADS[(ws.name:gsub('^special:', ''))]
  if sp then
    hl.exec_cmd(sp.cmd)
  end
end)

local function toggle_special(name)
  local cur = hl.get_active_special_workspace()
  if cur and cur.name ~= 'special:' .. name then
    hl.dispatch(hl.dsp.workspace.toggle_special((cur.name:gsub('^special:', ''))))
  end
  hl.dispatch(hl.dsp.workspace.toggle_special(name))
end

-- Apps launched from the filemanager scratchpad would inherit its special workspace;
-- r+0 = the current regular workspace, applied silently so the scratchpad stays up.
hl.window_rule({ match = { class = 'vlc' }, workspace = 'r+0' })

------------------------------------------------------------------------------
-- Window stash (mango tag 6, here special:minimized).
-- SUPER+n: stash the focused window (origin kept as a tag) / on the stash, bring the
-- focused window back to the workspace underneath. SUPER+SHIFT+u: back to origin.
-- Scratchpad windows are never stashed.
------------------------------------------------------------------------------
local STASH = 'minimized'

local function origin_of(w)
  for _, t in ipairs(w.tags or {}) do
    local id = t:match('^stash_from_(%d+)%*?$')
    if id then
      return id
    end
  end
end

local function unstash(w, ws)
  local origin = origin_of(w)
  if origin then
    hl.dispatch(hl.dsp.window.tag({ window = w, tag = '-stash_from_' .. origin }))
  end
  hl.dispatch(hl.dsp.window.move({ window = w, workspace = ws }))
  local cur = hl.get_active_special_workspace()
  if cur and cur.name == 'special:' .. STASH then
    hl.dispatch(hl.dsp.workspace.toggle_special(STASH))
  end
end

local function stash_toggle()
  local w = hl.get_active_window()
  if not w or not w.workspace then
    return
  end
  if w.workspace.name == 'special:' .. STASH then
    unstash(w, tostring(hl.get_active_workspace().id))
  elseif not w.workspace.special then
    hl.dispatch(hl.dsp.window.tag({ window = w, tag = '+stash_from_' .. w.workspace.id }))
    hl.dispatch(hl.dsp.window.move({ window = w, workspace = 'special:' .. STASH, follow = false }))
  end
end

local function restore_to_origin()
  local w = hl.get_active_window()
  if not w or not w.workspace or w.workspace.name ~= 'special:' .. STASH then
    return
  end
  local origin = origin_of(w)
  if origin then
    unstash(w, origin)
  else
    stash_toggle()
  end
end

------------------------------------------------------------------------------
-- Binds
------------------------------------------------------------------------------
local exec = hl.dsp.exec_cmd

-- DMS (same binds as wayland/_dms-binds.nix, which mango and sway use — keep in sync)
hl.bind('SUPER + space', exec('dms ipc launcher toggle'))
hl.bind('F1', exec('dms ipc audio mute'))
hl.bind('F2', exec('dms ipc audio decrement 5'))
hl.bind('F3', exec('dms ipc audio increment 5'))
hl.bind('F4', exec('dms ipc audio micmute'))
hl.bind('F5', exec('dms ipc brightness decrement 10 backlight:amdgpu_bl1'))
hl.bind('F6', exec('dms ipc brightness increment 10 backlight:amdgpu_bl1'))
hl.bind('SUPER + SHIFT + P', exec('dms ipc powermenu toggle'))
hl.bind('SUPER + SHIFT + D', exec('dms ipc notifications toggleDoNotDisturb'))
hl.bind('SUPER + SHIFT + I', exec('dms ipc notepad toggle'))
hl.bind('SUPER + SHIFT + V', exec('dms ipc clipboard toggle'))
hl.bind('SUPER + SHIFT + B', exec('dms ipc notifications toggle'))
hl.bind('SUPER + SHIFT + G', exec('dms ipc control-center toggle'))
-- laptop only (dms.nix dms-home.laptop puts it on PATH); a no-op elsewhere
hl.bind('SUPER + B', exec('battery-charge-toggle'))

for i = 1, 5 do
  local n = tostring(i)
  hl.bind('SUPER + ' .. n, hl.dsp.focus({ workspace = n }))
  hl.bind('SUPER + SHIFT + ' .. n, hl.dsp.window.move({ workspace = n }))
  hl.bind('SUPER + CTRL + ' .. n, hl.dsp.window.move({ workspace = n, follow = false }))
end

-- Apps
hl.bind('SUPER + SHIFT + Return', exec('ghostty'))
hl.bind('SUPER + W', exec('default-browser'))

-- Master layout
hl.bind('SUPER + M', hl.dsp.layout('focusmaster'))
hl.bind('SUPER + Return', hl.dsp.layout('swapwithmaster master'))
hl.bind('SUPER + SHIFT + R', hl.dsp.layout('rollnext'))
hl.bind('SUPER + ALT + R', hl.dsp.layout('rollprev'))
hl.bind('SUPER + ALT + I', hl.dsp.layout('addmaster'))
hl.bind('SUPER + ALT + D', hl.dsp.layout('removemaster'))
hl.bind('SUPER + CTRL + L', hl.dsp.layout('mfact +0.02'))
hl.bind('SUPER + CTRL + H', hl.dsp.layout('mfact -0.02'))
hl.bind('SUPER + O', cycle_layout)

-- Windows
hl.bind('SUPER + C', hl.dsp.window.close())
hl.bind('SUPER + F', hl.dsp.window.fullscreen())
hl.bind('SUPER + SHIFT + F', hl.dsp.window.float())
hl.bind('SUPER + X', hl.dsp.focus({ last = true }))
hl.bind('SUPER + U', hl.dsp.focus({ urgent_or_last = true }))
hl.bind('ALT + Tab', hl.dsp.window.cycle_next())

local dirs = { h = 'left', l = 'right', k = 'up', j = 'down' }
for key, dir in pairs(dirs) do
  hl.bind('SUPER + ' .. key, hl.dsp.focus({ direction = dir }))
  -- master layout: moving onto a neighbour swaps the two (like mango exchange_client)
  hl.bind('SUPER + SHIFT + ' .. key, hl.dsp.window.move({ direction = dir }))
  hl.bind('SUPER + ALT + ' .. key, hl.dsp.window.swap({ direction = dir }))
end
hl.bind('SUPER + CTRL + K', hl.dsp.window.resize({ x = 0, y = -10, relative = true }))
hl.bind('SUPER + CTRL + J', hl.dsp.window.resize({ x = 0, y = 10, relative = true }))

-- Workspaces
hl.bind('SUPER + Z', hl.dsp.focus({ workspace = 'previous' }))

-- Scratchpads + stash
hl.bind('SUPER + grave', function()
  toggle_special('term')
end)
hl.bind('SUPER + T', function()
  toggle_special('filemanager')
end)
hl.bind('SUPER + SHIFT + O', function()
  toggle_special('pw')
end)
hl.bind('SUPER + SHIFT + S', function()
  toggle_special('slack')
end)
hl.bind('SUPER + SHIFT + E', function()
  toggle_special('ente')
end)
hl.bind('SUPER + N', stash_toggle)
hl.bind('SUPER + SHIFT + N', function()
  toggle_special(STASH)
end)
hl.bind('SUPER + SHIFT + U', restore_to_origin)

-- Screenshots
hl.bind('SUPER + P', exec('grimblast --notify copysave screen'))
hl.bind('SUPER + CTRL + P', exec('grimblast --notify copysave area'))
hl.bind(
  'SUPER + ALT + P',
  exec(
    'mkdir -p "$HOME/Pictures/Screenshots"; FILE=$(mktemp /tmp/screenshot-XXXXXX.png); '
      .. 'grimblast --freeze save area "$FILE" && satty --filename "$FILE" '
      .. '--output-filename "$HOME/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"; rm -f "$FILE"'
  )
)

-- Session (uwsm docs: stop the session with `uwsm stop`, not the exit dispatcher)
hl.bind('SUPER + SHIFT + C', hl.dsp.reload_config())
hl.bind('SUPER + SHIFT + Q', exec('uwsm stop'))

-- Mouse
hl.bind('SUPER + mouse:272', hl.dsp.window.drag(), { mouse = true })
hl.bind('SUPER + mouse:273', hl.dsp.window.resize(), { mouse = true })
