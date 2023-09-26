-- This is XMOBAR CONFIG for monitor 1
-- If you have more monitors, make separate configs, then call these from xmonad
-- Font used : Fira Code, CaskaydiaCove Nerd Font for icons
Config { font    = "xft:JetBrainsMono Nerd Font:weight=bold:pixelsize=12:antialias=true:hinting=true"
       , bgColor = "#11111b"
       , fgColor = "#cdd6f4"
       , alpha = 254
       , position = TopSize L 100 24 
       , lowerOnStart = True
       , hideOnStart = False
       , allDesktops = False
       , persistent = True
       , iconRoot = ".config/xmonad/xpm/"
       , overrideRedirect = True
       , commands = [ Run XPropertyLog "_XMONAD_LOG_0"
                      -- Time and date -- 30 seconds
                    , Run Date "<fc=#81A1C1><fc=#D8DEE9>%I:%M %p</fc> %a %_d %b %Y</fc>" "date" 300
                      -- Disk space free -- 30 minute 
                    , Run DiskU [("/", "<fc=#88C0D0><fn=1> </fn><free></fc> ")] [] 18000 -- Shows total free space on the root partition
                      -- Ram used number and percent -- 2 seconds
                    , Run Memory ["--template", "<fc=#A3BE8C><fn=1> </fn><usedratio></fc> " , "-S", "On" ] 20
                      -- Cpu usage in percent -- 5 seconds
                    , Run Cpu ["--template", "<fc=#EBCB8B><fn=1> </fn><total></fc> " , "-S", "On" ,"-H","50" ,"--high","red"] 50
                      -- Show CPU temperature -- 1 minute
                      -- This script uses pacman-contrib package to work
                    , Run Com ".local/bin/checkupdate" [] "checkupdate" 72000
                      -- Network up and down -- 2 seconds
                    , Run DynNetwork ["--template", " <fc=#98be65><rx> <fc=#39ff14><fn=1> </fn></fc><fc=#ff9f00><fn=1> </fn></fc> <tx> </fc> " , "-S", "True"] 20
                      -- Wireless Interface -- 2 minute 
                    , Run Wireless "wlp2s0" ["--template", "<fn=1><fc=#ecd534><qualitybar> </fc></fn>"
                                               , "-W", "0" , "-f", "睊直直直直直直直直" , "-L", "5", "-l", "#FF0000" ] 1200
                      -- Runs a standard shell command 'uname -r' to get kernel version -- 2 hour
                    , Run Com "uname" ["-s","-r"] "" 0
                      -- Shift all icons to the left to accomodate system tray -- 5 seconds
                    , Run Com ".local/bin/trayer-padding-icon.sh" ["panel"] "trayerpad" 50
		    , Run Battery ["--template", "<fc=#81A1C1><acstatus></fc>"
                                   , "-S", "On", "-d", "0", "-m", "2" --suffix false(default), --ddigits 0 decimal places to show, --minWidth 2 characters(can be padded with -c/--padchars string)
                                   , "-L", "20", "-H", "80", "-p", "3" --Low , --High, --ppad pads percentage values with 3 characters
                                   , "-W", "0" --bwidth total number of characters used to draw bars (default 10)
                                   , "-f", "" -- Choose icon for leftbar depending on battery remaining --bfore characters used to draw bars (cyclically)
                                   , "--" -- Monitor specific data below
                                   --, "-P" --shows the percentage symbol
                                   , "-a", "notify-send -u critical 'Battery running out!'"
                                   , "-A", "10"
                                   , "-i", "<left><fn=1> <leftbar>  <fc=#39ff14>ﮣ </fc></fn>" -- Charged (The two spaces are to render the battery icon fully, after which the plug icon comes, which takes 2 cells to render, so one empty space)
                                   , "-O", "<left><fn=1> <leftbar>  <fc=#ff9f00> </fc></fn>" -- Charging
                                   , "-o", "<left><fn=1> <leftbar>  <fc=#39ff14>ﮤ </fc></fn>" -- Discharging
                                   , "-H", "8", "-L", "5" 
                                   , "-l", "green", "-m", "grey", "-h", "red" -- Shows an approximation of rate of battery discharge
                                   ] 600
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "<fn=1>   </fn>%_XMONAD_LOG_0%}%date%{ %disku% %memory% %cpu% <fc=#D08770><fn=1> </fn>%checkupdate%</fc> %trayerpad%"
}
