local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local spotify_widget = require("awesome-wm-widgets.spotify-widget.spotify")
local dpi = require("beautiful.xresources").apply_dpi

local os = os
local my_table = awful.util.table or gears.table

local theme = {}
theme.dir = os.getenv("HOME") .. "/.config/awesome/themes/zen-tastic"
theme.black = "#000000"
theme.wallpaper = theme.dir .. "/wall.jpg"
theme.font = "DejaVu Sans Mono 15"
theme.fg_normal = "#DDDDFF"
theme.fg_focus = "#4CAF50"
theme.fg_urgent = "#CC9393"
theme.bg_normal = "#000000"
theme.bg_focus = "#37474F"
theme.bg_urgent = "#1A1A1A"
theme.border_width = dpi(1)
theme.border_normal = "#3F3F3F"
theme.border_focus = "#FF7043"
theme.border_marked = "#CC9393"
theme.tasklist_bg_focus = "#000000"
theme.titlebar_bg_focus = "#009922"
theme.titlebar_bg_normal = "#000000"
theme.titlebar_fg_focus = "#00FF00"
theme.menu_height = dpi(0)
theme.menu_width = dpi(0)
theme.cpu_svg = theme.dir .. "/icons/cpu.svg"
theme.nepal_flag = theme.dir .. "/icons/nepal.svg"
theme.ram_svg = theme.dir .. "/icons/ram.svg"
theme.japan_flag = theme.dir .. "/icons/japan.svg"
theme.temp_svg = theme.dir .. "/icons/temp.svg"
theme.taglist_squares_sel = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel = theme.dir .. "/icons/square_unsel.png"
theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon = false
theme.useless_gap = dpi(0)
theme.high = "#e33a6e"
theme.medium = "#e0da37"
theme.low = "#4CAF50"
theme.download = "#66BB6A"
theme.upload = "#4FC3F7"
theme.clock = "#607D8B"
theme.japan = "#507D8B"
local markup = lain.util.markup

local npt = wibox.widget.imagebox(theme.nepal_flag)
local cpu_svg = wibox.widget.imagebox(theme.cpu_svg)
local jst = wibox.widget.imagebox(theme.japan_flag)
local temp_icon = wibox.widget.imagebox(theme.temp_svg)
local ram_icon = wibox.widget.imagebox(theme.ram_svg)
local mytextclock = wibox.widget.textclock(markup(theme.clock, "%I:%M %p ", 60, "Asia/Kathmandu"))
mytextclock.font = theme.font

local japan = wibox.widget.textclock(markup(theme.japan, " %I:%M %p "), 60, "Asia/Tokyo")
japan.font = theme.font

local netdowninfo = wibox.widget.textbox()
local netupinfo = lain.widget.net({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.upload, "&#8593; " .. net_now.sent .. " "))
        netdowninfo:set_markup(markup.fontfg(theme.font, theme.download, "&#8595; " .. net_now.received .. " "))
    end,
})

-- local governor = lain.widget.temp({
--  settings = function()
--      local command = "cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | uniq"
--      local handle = io.popen(command)
--      if handle then
--          local result = handle:read("*a")
--          if result then
--              handle:close()
--              result = string.gsub(result, "%s+", "")
--              if result == "performance" or result == "ondemand" then
--                  widget:set_markup(markup.fontfg(theme.font, theme.low, " 🔥 " .. result .. " "))
--              else
--                  widget:set_markup(markup.fontfg(theme.font, theme.high, " ⚠️ " .. result .. " "))
--              end
--          end
--      end
--  end,
-- })

function getNotification()
    local command = "dunstctl count waiting"
    local handle = io.popen(command)
    if handle then
        local result = handle:read("*a")
        if result then
            handle:close()
            return " " .. result
        else
            return "0 "
        end
    end
end

local notify = lain.widget.temp({
    timeout = 1,
    settings = function()
        local command = "dunstctl is-paused"
        local handle = io.popen(command)
        if handle then
            local result = handle:read("*a")
            if result then
                handle:close()
                result = string.gsub(result, "%s+", "")
                if result == "false" then
                    widget:set_markup(markup.fontfg(theme.font, theme.low, ""))
                else
                    widget:set_markup(markup.fontfg(theme.font, theme.high, "" .. getNotification()))
                end
            end
        end
    end,
})

local temp = lain.widget.temp({
    timeout = 5,
    settings = function()
        if tonumber(coretemp_now) >= 80 then
            widget:set_markup(markup.fontfg(theme.font, theme.high, " " .. coretemp_now .. " °C"))
        elseif tonumber(coretemp_now) >= 50 and tonumber(coretemp_now) < 80 then
            widget:set_markup(markup.fontfg(theme.font, theme.medium, " " .. coretemp_now .. " °C"))
        else
            widget:set_markup(markup.fontfg(theme.font, theme.low, " " .. coretemp_now .. " °C"))
        end
    end,
})

local bat = lain.widget.bat({
    timeout = 10,
    settings = function()
        local perc = bat_now.perc ~= "N/A" and bat_now.perc .. "%" or bat_now.perc

        if bat_now.ac_status == 1 then
            perc = "&#x1F50C;"
            widget:set_markup(markup.fontfg(theme.font, theme.low, perc))
        else
            perc = "&#128267; " .. bat_now.perc .. "%"
        end

        if bat_now.perc == "N/A" then
            return
        end

        if bat_now.perc >= 70 and bat_now.perc ~= "N/A" then
            widget:set_markup(markup.fontfg(theme.font, theme.low, perc))
        elseif bat_now.perc >= 20 and bat_now.perc < 70 and bat_now.perc ~= "N/A" then
            widget:set_markup(markup.fontfg(theme.font, theme.medium, perc))
        elseif bat_now.perc ~= "N/A" then
            widget:set_markup(markup.fontfg(theme.font, theme.high, perc))
        end
    end,
})

theme.volume = lain.widget.alsa({
    settings = function()
        if volume_now.status == "off" then
            volume_now.level = volume_now.level .. "M"
            widget:set_markup(markup.fontfg(theme.font, theme.high, " " .. volume_now.level))
            return
        end

        if volume_now.level >= 80 then
            widget:set_markup(markup.fontfg(theme.font, theme.low, " V:" .. volume_now.level .. "% "))
        elseif volume_now.level >= 50 and volume_now.level < 80 then
            widget:set_markup(markup.fontfg(theme.font, theme.medium, " V:" .. volume_now.level .. "% "))
        else
            widget:set_markup(markup.fontfg(theme.font, theme.high, " V:" .. volume_now.level .. "% "))
        end
    end,
})

local cpu = lain.widget.cpu({
    settings = function()
        if cpu_now.usage >= 80 then
            widget:set_markup(markup.fontfg(theme.font, theme.high, " " .. cpu_now.usage .. "% "))
        elseif cpu_now.usage >= 50 then
            widget:set_markup(markup.fontfg(theme.font, theme.medium, " " .. cpu_now.usage .. "% "))
        else
            widget:set_markup(markup.fontfg(theme.font, theme.low, " " .. cpu_now.usage .. "% "))
        end
    end,
})

local memory = lain.widget.mem({
    settings = function()
        if mem_now.perc >= 80 then
            widget:set_markup(markup.fontfg(theme.font, theme.high, " " .. mem_now.used .. " M "))
        elseif mem_now.perc >= 50 and mem_now.perc < 80 then
            widget:set_markup(markup.fontfg(theme.font, theme.medium, " " .. mem_now.used .. " M "))
        else
            widget:set_markup(markup.fontfg(theme.font, theme.low, " " .. mem_now.used .. " M "))
        end
    end,
})

-- MPD
local mpdicon = wibox.widget.imagebox()
theme.mpd = lain.widget.mpd({
    settings = function()
        mpd_notification_preset = {
            text = string.format("%s [%s] - %s\n%s", mpd_now.artist, mpd_now.album, mpd_now.date, mpd_now.title),
        }

        if mpd_now.state == "play" then
            artist = mpd_now.artist .. " > "
            title = mpd_now.title .. " "
            mpdicon:set_image(theme.widget_note_on)
        elseif mpd_now.state == "pause" then
            artist = "mpd "
            title = "paused "
        else
            artist = ""
            title = ""
            --mpdicon:set_image() -- not working in 4.0
            mpdicon._private.image = nil
            mpdicon:emit_signal("widget::redraw_needed")
            mpdicon:emit_signal("widget::layout_changed")
        end
        widget:set_markup(markup.fontfg(theme.font, "#e54c62", artist) .. markup.fontfg(theme.font, "#b2b2b2", title))
    end,
})

local systray = wibox.widget.systray()

local spotify_widget = spotify_widget({
    font = "DejaVu Sans Mono 15",
    play_icon = "/home/hackerd/.local/share/icons/Papirus/24x24/categories/spotify.svg",
    pause_icon = "/home/hackerd/.local/share/icons/Papirus/24x24/panel/spotify-indicator.svg",
    show_tooltip = false,
})

function theme.at_screen_connect(s)
    -- Quake application
    s.quake = lain.util.quake({ app = awful.util.terminal })

    -- If wallpaper is a function, call it with the screen
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)

    -- Tags
    awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
        awful.button({}, 1, function()
            awful.layout.inc(1)
        end),
        awful.button({}, 2, function()
            awful.layout.set(awful.layout.layouts[1])
        end),
        awful.button({}, 3, function()
            awful.layout.inc(-1)
        end),
        awful.button({}, 4, function()
            awful.layout.inc(1)
        end),
        awful.button({}, 5, function()
            awful.layout.inc(-1)
        end)
    ))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

    -- Create the wibox
    s.mywibox =
    awful.wibar({ position = "top", screen = s, height = dpi(25), bg = theme.bg_normal, fg = theme.fg_normal })

    s.mytaskbar =
    awful.wibar({ position = "bottom", screen = s, height = dpi(20), bg = theme.black, fg = theme.fg_normal })

    s.mytaskbar:setup({
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.align.horizontal,
            s.mytasklist,
        },
        nil,
        nil,
    })

    s.mywibox:setup({
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        nil,
        {
            layout = wibox.layout.fixed.horizontal,
            spotify_widget,
            notify,
            -- governor,
            netdowninfo,
            netupinfo.widget,
            cpu,
            memory,
            -- temp_icon,
            temp,
            theme.volume.widget,
            npt,
            mytextclock,
            jst,
            japan,
            bat,
            systray,
        },
    })
end

return theme
