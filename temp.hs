--------------------------------------
-- IMPORT PACKAGES
--------------------------------------

import qualified Data.Map as Map
import qualified Graphics.X11.Types
import XMonad (
	Default (def)
    , Dimension
	, Full (Full)
	, Mirror (Mirror)
	, MonadReader (ask)
	, ScreenId (S)
	, Tall (Tall)
	, X
	, XConfig ( XConfig,
        borderWidth,
        clickJustFocuses,
        focusFollowsMouse,
        focusedBorderColor,
        keys,
        layoutHook,
        logHook,
        manageHook,
        modMask,
        normalBorderColor,
        startupHook,
        terminal,
        workspaces
      ),
    XState (windowset),
    modify,
    sendMessage,
    shiftMask,
    spawn,
    windows,
    withFocused,
    xC_left_ptr,
    xK_1,
    xK_9,
    xK_Super_L,
    xK_s,
    xK_w,
    xmonad,
    (.|.),
    (|||),
  )
import XMonad.Actions.CopyWindow (copyToAll, killAllOtherCopies)
import XMonad.Actions.CycleWS (toggleWS)
import XMonad.Actions.CycleWindows (cycleRecentWindows, rotFocusedUp, rotUnfocusedDown, rotUnfocusedUp)
import XMonad.Actions.GroupNavigation (Direction (History), nextMatch)
import XMonad.Actions.Navigation2D
  ( Direction2D (L, R),
    screenGo,
    screenSwap,
    windowToScreen,
    withNavigation2DConfig,
  )
import XMonad.Actions.OnScreen (onlyOnScreen)
import XMonad.Actions.WithAll (killAll, sinkAll)
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageDocks (ToggleStruts (..))
import XMonad.Hooks.RefocusLast (refocusLastLogHook)
import XMonad.Hooks.StatusBar (StatusBarConfig, dynamicEasySBs, statusBarPropTo)
import XMonad.Hooks.StatusBar.PP
  ( PP (ppCurrent, ppExtras, ppHidden, ppHiddenNoWindows, ppLayout, ppSep, ppTitle, ppUrgent, ppVisible),
    filterOutWsPP,
    wrap,
    xmobarColor,
  )
import XMonad.Layout.GridVariants (Grid (Grid))
import XMonad.Layout.IndependentScreens
  ( VirtualWorkspace,
    countScreens,
    marshallPP,
    onCurrentScreen,
    withScreens,
    workspaces',
  )
import XMonad.Layout.LimitWindows (limitWindows)
import XMonad.Layout.MultiToggle
  ( EOT (EOT),
    Toggle (Toggle),
    mkToggle,
    single,
    (??),
  )
import XMonad.Layout.MultiToggle.Instances
  ( StdTransformers (MIRROR, NBFULL, NOBORDERS),
  )
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.OneBig (OneBig (OneBig))
import XMonad.Layout.Reflect (REFLECTX (REFLECTX), REFLECTY (REFLECTY))
import XMonad.Layout.Renamed (Rename (Replace), renamed)
import XMonad.Layout.SimplestFloat (simplestFloat)
import XMonad.Layout.Spacing (spacing)
import qualified XMonad.Layout.ToggleLayouts as T
  ( ToggleLayout (Toggle),
    toggleLayouts,
  )
import XMonad.ManageHook
  ( className,
    composeAll,
    doF,
    doFloat,
    title,
    (-->),
    (<&&>),
    (<+>),
    (=?),
  )
import qualified XMonad.StackSet as W
import XMonad.Util.Cursor (setDefaultCursor)
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.Loggers
  ( logLayoutOnScreen,
    logTitleOnScreen,
    padL,
    shortenL,
    xmobarColorL,
  )
import XMonad.Util.NamedScratchpad
  ( NamedScratchpad (NS),
    customFloating,
    namedScratchpadAction,
    namedScratchpadManageHook,
    nsHideOnFocusLoss,
  )
import XMonad.Util.SpawnOnce (spawnOnce)

--------------------------------------
-- Scratchpads
--------------------------------------
myScratchpads :: [NamedScratchpad]
myScratchpads =
  [ NS "postman" spawnPostman findPostman manageFloating,
    NS "slack" spawnSlack findSlack manageFloating,
    NS "signal" spawnSignal findSignal manageFloating,
    NS "ym" spawnYM findYM manageFloating
  ]
  where
    spawnPostman = "postman"
    findPostman = className =? "Postman"
    spawnSlack = "slack"
    findSlack = className =? "Slack"
    spawnSignal = "signal-desktop"
    findSignal = className =? "Signal"
    spawnYM = "youtube-music"
    findYM = className =? "YouTube Music"
    manageFloating = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w

--------------------------------------
-- Variables Initialization
--------------------------------------
myTerminal :: String
myTerminal = "kitty"

myBrowser :: String
myBrowser = "brave"

myFileManager :: String
myFileManager = "thunar"

myEditor :: String
myEditor = myTerminal ++ "-e nvim"

myNormalBorderColor :: String
myNormalBorderColor = "#f6f4f3"

myFocusedBorderColor :: String
myFocusedBorderColor = "#890620"

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myClickJustFocuses :: Bool
myClickJustFocuses = False

myBorderWidth :: Dimension
myBorderWidth = 4

--------------------------------------
-- Autostart
--------------------------------------
myStartupHook :: X ()
myStartupHook = do
  modify $ \xstate -> xstate {windowset = onlyOnScreen 1 "1_1 " (windowset xstate)}
  spawnOnce "picom --experimental-backends &"
  spawnOnce "feh --bg-fill --randomize ~/.wallpapers/* &" -- feh set random wallpaper
  spawn
    "trayer --iconspacing 5 --edge top --align right --widthtype request --heighttype pixel --padding 5 --SetDockType true --SetPartialStrut false --expand true --monitor primary --transparent true --alpha 0 --tint 0x282c34  --height 22"
  setDefaultCursor xC_left_ptr -- Set cursor theme

--------------------------------------
-- Generating Layouts and Naming Them
--------------------------------------
tall =
  renamed [Replace "tall"] $
    smartBorders $
      limitWindows 12 $
        spacing 4 $
          Tall 1 (3 / 100) (2 / 3)

grid =
  renamed [Replace "grid"] $
    limitWindows 12 $
      spacing 4 $
        mkToggle (single MIRROR) $
          Grid (16 / 10)

oneBig =
  renamed [Replace "oneBig"] $
    limitWindows 6 $
      spacing 4 $
        Mirror $
          mkToggle (single MIRROR) $
            mkToggle (single REFLECTX) $
              mkToggle (single REFLECTY) $
                OneBig (5 / 9) (8 / 12)

monocle = renamed [Replace "monocle"] $ limitWindows 20 Full

floats = renamed [Replace "floats"] $ limitWindows 20 simplestFloat

myLayoutHook =
  smartBorders $
    T.toggleLayouts floats $
      mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout = oneBig ||| noBorders monocle ||| tall ||| grid ||| floats

workspaceKeys ::
  XConfig l ->
  Map.Map (Graphics.X11.Types.KeyMask, Graphics.X11.Types.KeySym) (X ())
workspaceKeys conf@(XConfig {modMask = modm}) =
  Map.fromList $
    [ ((m .|. modm, k), windows $ onCurrentScreen f i)
      | (i, k) <- zip (workspaces' conf) [xK_1 .. xK_9],
        (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
    ]

myKeys :: [(String, X ())]
myKeys =
  [ ("M-S-a", killAll), -- Kill all windows on current workspace
  -- Windows navigation
    ("M-S-s", windows copyToAll), -- Copy the winow to ALL workspaces
    ("M-C-c", killAllOtherCopies), -- Kill all the copies apart from the focused
    -- Move between current and the last open windows
    -- TODO: current and last open windows of the same screen
    ("M-x", nextMatch History (return True)),
    ("M-z", toggleWS),
    -- Cycle windows
    ("M4-s", cycleRecentWindows [xK_Super_L] xK_s xK_w),
    ("M-i", rotUnfocusedUp),
    ("M-o", rotUnfocusedDown),
    ("M-c-i", rotFocusedUp),
    -- Directional navigation of screens
    ("M-r", screenGo L False),
    ("M-u", screenGo R False),
    -- Swap workspaces on adjacent screens
    ("M-C-r", screenSwap L False),
    ("M-C-u", screenSwap R False),
    -- Send window to adjacent screen
    ("M-S-r", windowToScreen L False),
    ("M-S-u", windowToScreen R False),
    -- Layouts
    ("M-S-n", sendMessage (Toggle NOBORDERS)),
    ("M-S-=", sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts),
    -- Floating Windows
    ("M-S-f", sendMessage (T.Toggle "floats")), -- Toggles my 'floats' layout
    ("M-t", withFocused $ windows . W.sink), -- Push floating window back to tile
    ("M-S-t", sinkAll), -- Push ALL floating windows to tile
    -- Application Spawn
    ("M-b", spawn myBrowser), -- (Alt + b)
    ("M-n", spawn myEditor), -- (Alt + n)
    ("M-f", spawn myFileManager), -- (Alt + f)
    ("M-p", spawn "rofi -show drun"), -- (Alt + p)
    ("M-S-p", spawn "rofi -show window"), -- (Alt + x)
    -- Scratchpad Spawn
    ("M-C-p", namedScratchpadAction myScratchpads "postman"),
    ("M-C-s", namedScratchpadAction myScratchpads "slack"),
    ("M-C-g", namedScratchpadAction myScratchpads "signal"),
    ("M-C-y", namedScratchpadAction myScratchpads "ym"),
    ("M-q", spawn "xmonad --recompile; xmonad --restart")
  ]

--------------------------------------
-- Workspace Names that go on XMobar
--------------------------------------
myWorkspaces :: [VirtualWorkspace]
myWorkspaces =
  [ "\x0031 ",
    "\x0032 ",
    "\x0033 ",
    "\x0034 ",
    "\x0035 ",
    "\x0036 ",
    "\x0037 ",
    "\x0038 ",
    "\x0039 "
  ]

myXmobarPP :: ScreenId -> PP
myXmobarPP s =
  filterOutWsPP ["NSP"] . marshallPP s $
    def
      { ppCurrent = xmobarColor "#cba6f7" "" . wrap "<fn=1>" "</fn>", -- Workspace that I am viewing now
        ppVisible = xmobarColor "#6c7086" "" . wrap "<fn=1>" "</fn>", -- Workspace that is open on any monitor other than this one
        ppHidden = xmobarColor "#6c7086" "" . wrap "<fn=1>" "</fn>", -- Hidden workspaces that have any open software in it but not open on any monitors
        ppHiddenNoWindows = xmobarColor "#313244" "" . wrap "<fn=1>" "</fn>", -- Workspaces with no open softwares and not open on any monitors
        ppSep = "<fc=#444b6a> | </fc>", -- Separator character
        ppUrgent = xmobarColor "#EBCB8B" "" . wrap "!<fn=1>" "</fn>!", -- Urgent workspace
        ppTitle = const "",
        ppLayout = const "",
        ppExtras = [logLayoutOnScreen s, xmobarColorL "#EBCB8B" "" . padL . shortenL 15 $ logTitleOnScreen s]
      }

myStatusBarSpawner :: Applicative f => ScreenId -> f StatusBarConfig
myStatusBarSpawner (S s) = do
  pure $
    statusBarPropTo
      ("_XMONAD_LOG_" ++ show s)
      ("xmobar -x " ++ show s ++ " ~/.config/xmobar/xmobarrc" ++ show s ++ ".hs")
      (pure $ myXmobarPP (S s))

manageZoomHook =
  composeAll
    [ (className =? zoomClassName) <&&> shouldFloat <$> title --> doFloat,
      (className =? zoomClassName) <&&> shouldSink <$> title --> doSink
    ]
  where
    zoomClassName = "zoom"
    tileTitles =
      [ "Zoom - Free Account", -- main window
        "Zoom - Licensed Account", -- main window
        "Zoom Cloud Meetings",
        "Zoom", -- meeting window on creation
        "Zoom Meeting" -- meeting window shortly after creation
      ]
    shouldFloat title = title `notElem` tileTitles
    shouldSink title = title `elem` tileTitles
    doSink = (ask >>= doF . W.sink) <+> doF W.swapDown

main :: IO ()
main = do
  nScreens <- countScreens
  xmonad $
    ewmhFullscreen $
      ewmh $
        dynamicEasySBs myStatusBarSpawner $
          withNavigation2DConfig def $
            def
              { layoutHook = myLayoutHook,
                terminal = myTerminal,
                focusFollowsMouse = myFocusFollowsMouse,
                clickJustFocuses = myClickJustFocuses,
                borderWidth = myBorderWidth,
                normalBorderColor = myNormalBorderColor,
                focusedBorderColor = myFocusedBorderColor,
                startupHook = myStartupHook,
                workspaces = withScreens nScreens myWorkspaces,
                manageHook = manageZoomHook <+> namedScratchpadManageHook myScratchpads,
                logHook = refocusLastLogHook >> nsHideOnFocusLoss myScratchpads,
                keys = \c -> workspaceKeys c `Map.union` keys def c
              }
              `additionalKeysP` myKeys
