------------------------------------------------
--- __  __                                _  ---
--- \ \/ /_ __ ___   ___  _ __   __ _  __| | ---
---  \  /| '_ ` _ \ / _ \| '_ \ / _` |/ _` | ---
---  /  \| | | | | | (_) | | | | (_| | (_| | ---
--- /_/\_\_| |_| |_|\___/|_| |_|\__,_|\__,_| ---
------------------------------------------------
-- TODO
-- [x] improve dmenu!!
-- [x] add sink all functionality
-- [x] notifications rounded borders
-- [x] add no borders for inactive windows
-- [x] add tabbed layout
-- [x] add centered master layout
-- [x] fix fullscreen toggle borders
-- [x] add scroll wheel volume control
-- [x] add treeselect for power options and stuff
-- [x] fix xmobar rounded corners
-- [x] make xmobar clickable and execute scripts
-- [x] check imports and declare only the actually imported functions
---------------
--- IMPORTS ---
---------------
-- Base --
import System.Directory
import System.Exit
import System.IO
import XMonad
import Data.Monoid
import qualified Data.Map as M
import qualified XMonad.StackSet as W
-- Actions --
import XMonad.Actions.CycleWS
import XMonad.Actions.DwmPromote
import XMonad.Actions.NoBorders
import XMonad.Actions.RotSlaves
import qualified XMonad.Actions.FlexibleResize as Flex
  -- import XMonad.Actions.MouseResize
-- Hooks --
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeWindows
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.RefocusLast
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.WindowSwallowing
import qualified XMonad.Hooks.ManageHelpers as MH
-- Layouts --
import XMonad.Layout.Dwindle
import XMonad.Layout.Tabbed
import XMonad.Layout.ResizableTile
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ThreeColumns
-- Layout modifiers --
import XMonad.Layout.DwmStyle
import XMonad.Layout.Decoration
import XMonad.Layout.DecorationMadness
import XMonad.Layout.LayoutModifier
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.MouseResizableTile
import XMonad.Layout.NoBorders
import XMonad.Layout.Reflect
import XMonad.Layout.Spacing
import qualified XMonad.Layout.MultiToggle as MT
import qualified XMonad.Layout.Fullscreen as FS
  -- import qualified XMonad.Layout.ToggleLayouts as T
-- Utilities --
import XMonad.Util.ClickableWorkspaces
import XMonad.Util.EZConfig
import XMonad.Util.Font
import XMonad.Util.Loggers
import XMonad.Util.NamedScratchpad
import XMonad.Util.Ungrab
import XMonad.Util.Themes
  -- import XMonad.Util.NamedActions

-----------------
--- VARIABLES ---
-----------------
myFont :: String
myFont = "xft:mononokiNerdFontMono:regular:size=10:antialias=true:hinting=true"
myMod :: KeyMask
myMod = mod4Mask
myTerm :: String
myTerm = "alacritty"
myBrowser :: String
myBrowser = "qutebrowser"
myBorderWidth :: Dimension
myBorderWidth = 3
myNormCol :: String
myNormCol = "#2f383e"
myFocusCol :: String
myFocusCol = "#a6c080"
myEditor :: String
myEditor = myTerm ++ " -e nvim"

---------------------
--- MAIN & CONFIG ---
---------------------
main :: IO ()
main = xmonad 
     . ewmhFullscreen 
     . ewmh 
     . withEasySB (myStatusBar0 <> myStatusBar1) defToggleStrutsKey 
     $ myConfig

myConfig = def
  { modMask             = mod4Mask
  , layoutHook          = myLayout
  -- , layoutHook          = dwmStyle shrinkText myDWConfig (myLayout)
  -- , layoutHook          = tallDefaultResizable shrinkText (theme myTheme)
  , handleEventHook     = myHandleEventHook
  , manageHook          = myManageHook
  , borderWidth         = myBorderWidth
  , startupHook         = myStartupHook
  , mouseBindings       = myMouseBindings
  , normalBorderColor   = myNormCol
  , focusedBorderColor  = myFocusCol
  , logHook             = myLogHook
  }
  `additionalKeysP` myKeys

-- myTheme = 
--   newTheme { themeName      = "myTheme"
--            , themeAuthor     = "lucas"
--            , themeDescription = "test"
--            , theme          = def { inactiveBorderWidth = 0
--                                   , activeBorderWidth = 8
--                                   }
--            }
-- myDWConfig = def
--   { inactiveBorderWidth = 0
--   , activeBorderWidth = 8
--   }

--------------------
--- FISHING HOOKS ---
--------------------
myHandleEventHook = fadeWindowsEventHook <> swallowEventHook (className =? "Alacritty") (return True)

myLogHook = fadeWindowsLogHook myFadeHook <> refocusLastLogHook >> nsHideOnFocusLoss scratchpads

myFadeHook = composeAll 
  [ {- default                  --> -} opacity 0.85
  , isUnfocused                 --> opacity 0.7
  , className =? "qutebrowser"  --> opacity 0.9
  , className =? "guvcview"     --> opacity 1.0
  , className =? "Steam"        --> opacity 0.9
  , title =? "Buffer"       --> opacity 0.0
  , className =? "Zathura"      --> opacity 1.0
  , MH.isFullscreen             --> opacity 1.0
  ]

myManageHook = composeAll
  [ manageDocks
  , className =? "Gimp"             --> doFloat
  , className =? "Guvcview"         --> doFloat
  , className =? "DroidCam Client"  --> doFloat
  -- , className =? "steam_app_261550" --> MH.doFullFloat
  -- , className =? "qutebrowser"      --> hasBorder False
  , MH.isDialog                     --> doFloat
  , MH.isFullscreen                 --> MH.doFullFloat
  ] <+> namedScratchpadManageHook scratchpads

---------------
--- LAYOUTS ---
---------------
-- TODO: fake fullscreen, 3col, tabs
myLayout = MT.mkToggle (MT.single REFLECTY)
          $ MT.mkToggle (MT.single REFLECTX)
          $ MT.mkToggle (MT.single MIRROR)
          $ MT.mkToggle (MT.single NBFULL)
          $ spacingWithEdge 5 
          $ smartBorders
          $ mouseResizableTile
            { masterFrac = 0.5
            , fracIncrement = 0.10
            , draggerType = FixedDragger 0 10
            }
          -- $ avoidStruts
          -- $ ResizableTall 1 (10/100) (1/2) [] -- nmaster ratio delta [fraction]

---------------
--- STARTUP ---
---------------
myStartupHook :: X ()
myStartupHook = do
  spawn ("killall trayer; sleep 1 && trayer --edge top --margin 289 --distance 3 --align left --widthtype request --padding 3 --SetDockType true --SetPartialStrut true --expand true --tint 0xa6c080 --transparent true --alpha 0 --monitor 0 --height 19")
  spawn ("unclutter --timeout 3")
  spawn ("clipmenud")
  spawn ("mbsync -a")

------------------
--- STATUS BAR ---
------------------
myStatusBar0 = statusBarPropTo "_XMONAD_LOG_0" "xmobar -x 0 ~/.config/xmonad/xmobar/xmobarrc0" (clickablePP myXmobarPP)
myStatusBar1 = statusBarPropTo "_XMONAD_LOG_1" "xmobar -x 1 ~/.config/xmonad/xmobar/xmobarrc1" (clickablePP myXmobarPP')

myXmobarPP :: PP
myXmobarPP = def
  { ppSep             = " "                                           -- Seperator between tags/layout/title
  , ppWsSep           = " "                                           -- Seperator between WS tags
  , ppCurrent         = xmobarColor "#2f383e" "#a6c080" . pad         -- Current focused workspace
  , ppVisible         = xmobarColor "#2f383e" "#83c092" . pad         -- Visible but not focused (other screen)
  , ppHidden          = showHidden                                    -- Hidden WS with content
  , ppHiddenNoWindows = showHiddenNoWindows                           -- Hidden WS withouth content
  -- , ppTitle           = xmobarColor "#2f383e" "#a6c080" . wrap " " "      "
  , ppOrder           = \(ws:_:_:xs) -> [ws] ++ xs                         -- What fields to print and in what order (layout exluded in this case)
  , ppExtras          = [lTitle]
  }
  where
    showHidden wsId = 
      if any (`elem` wsId) ['A' .. 'Z'] then "" else (xmobarBorder "Bottom" "#a6c080" 2 . pad) wsId   -- exclude WS's that contain A-Z (like scratchpad WS)
    showHiddenNoWindows wsId = 
      if any (`elem` wsId) ['A' .. 'Z'] then "" else (xmobarColor "#d3c6aa" "#2f383e" . pad) wsId
    lTitle = logWhenActive' 0                                                                         -- when screen 0 is active do:
      (xmobarColorL "#2f383e" "#a6c080" . fixedWidthL AlignLeft " " 135 . wrapL " [" "]" $ logTitle)  -- green title 
      (xmobarColorL "#2f383e" "#83c092" . fixedWidthL AlignLeft " " 135 . wrapL " [" "]" $ logTitle)  -- blue title 

-- secondary SB with space for trayer
myXmobarPP' :: PP
myXmobarPP' = myXmobarPP
  { ppExtras = [logCmd "~/.config/xmonad/xmobar/trayer-padding-icon.sh", lTitle] } 
  where
    lTitle = logWhenActive' 1 
      (xmobarColorL "#2f383e" "#a6c080" . fixedWidthL AlignLeft " " 135 . wrapL " [" "]" $ logTitle) 
      (xmobarColorL "#2f383e" "#83c092" . fixedWidthL AlignLeft " " 135 . wrapL " [" "]" $ logTitle)

-- helper function to format the title differently based on the screen that is active
logWhenActive' :: ScreenId -> Logger -> Logger -> Logger
logWhenActive' n l t = do
  c <- withWindowSet $ return . W.screen . W.current
  if n == c then l else t
-------------------
--- SCRATCHPADS ---
-------------------
scratchpads  =
  [ NS "Terminal" spawnTerm findTerm manageTerm
  , NS "Calculator" spawnCalc findCalc manageCalc
  , NS "TaskManager" spawnTask findTask manageTask
  , NS "Calendar" spawnCal findCal manageCal
  , NS "Mail" spawnMail findMail manageMail
  -- Add one for notetaking
  ]
  where
    spawnTerm = myTerm ++ " -t scratchpad"
    findTerm = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)

    spawnCalc = myTerm ++ " -t Calc -e insect"
    findCalc = title =? "Calc"
    manageCalc = customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)

    spawnTask = myTerm ++ " -t btop -e btop"
    findTask = title =? "btop"
    manageTask = customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)

    spawnCal = myTerm ++ " -t agenda -e calcurse"
    findCal = title =? "agenda"
    manageCal = customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)

    spawnMail = myTerm ++ " -t mail -e neomutt"
    findMail = title =? "mail"
    manageMail = customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3)

-------------------
--- KEYBINDINGS --- 
-------------------
myKeys =
  -- Window --
  [ ("M-q",           kill)
  , ("M-j",           windows W.focusDown)
  , ("M-k",           windows W.focusUp)
  , ("M-m",           windows W.focusMaster)
  , ("M-u",           sendMessage $ Shrink)
  , ("M-o",           sendMessage $ Expand)
  -- , ("M1-u",          sendMessage $ MirrorShrink)
  -- , ("M1-o",          sendMessage $ MirrorExpand)
  , ("M1-u",          sendMessage $ ShrinkSlave)
  , ("M1-o",          sendMessage $ ExpandSlave)
  , ("M-<Space>",     dwmpromote)
  , ("M-b",           sendMessage $ ToggleStruts)
  , ("M1-j",          rotSlavesDown)
  , ("M1-k",          rotSlavesUp)
  -- Spawn --
  , ("M-<Return>",    spawn $ myTerm)
  , ("M-w"  ,         spawn $ myBrowser)
  , ("M-d"  ,         spawn "dmenu_run_history -i")
  , ("M-p c",         spawn "clipmenu")
  , ("M-p p",         spawn "passmenu")
  , ("M-="  ,         spawn "~/.local/bin/volup.sh")
  , ("M--"  ,         spawn "~/.local/bin/voldown.sh")
  , ("M-0"  ,         spawn "~/.local/bin/voltoggle.sh")
  , ("M-s t",         namedScratchpadAction scratchpads "Terminal")
  , ("M-s c",         namedScratchpadAction scratchpads "Calculator")
  , ("M-s h",         namedScratchpadAction scratchpads "TaskManager")
  , ("M-s a",         namedScratchpadAction scratchpads "Calendar")
  , ("M-s m",         namedScratchpadAction scratchpads "Mail")
  , ("M-v",           spawn $ myEditor)
  , ("M1-s",          spawn $ "flameshot gui")
  -- System --
  , ("M-C-r",         spawn $ "xmonad --recompile")
  , ("M-S-r",         spawn $ "xmonad --restart")
  -- Layout --
  -- , ("M-<Tab>",       sendMessage NextLayout)
  , ("M-<Tab>",       sendMessage $  MT.Toggle MIRROR)
  , ("M-i",           sendMessage $  MT.Toggle REFLECTX)
  , ("M1-i",          sendMessage $ MT.Toggle REFLECTY)
  , ("M-f",           toggleFull )
  , ("M-c",           sendMessage $ NextLayout )
  -- Workspaces --
  , ("M-l",           moveTo Next $ hiddenWS :&: ignoringWSs [scratchpadWorkspaceTag])
  , ("M-h",           moveTo Prev $ hiddenWS :&: ignoringWSs [scratchpadWorkspaceTag])
  , ("M1-l",          shiftTo Next $ hiddenWS :&: ignoringWSs [scratchpadWorkspaceTag])
  , ("M1-h",          shiftTo Prev $ hiddenWS :&: ignoringWSs [scratchpadWorkspaceTag]) 
  , ("M-M1-l",        shiftTo Next (hiddenWS :&: ignoringWSs [scratchpadWorkspaceTag]) >> moveTo Next (hiddenWS :&: ignoringWSs [scratchpadWorkspaceTag]) )
  , ("M-M1-h",        shiftTo Prev (hiddenWS :&: ignoringWSs [scratchpadWorkspaceTag]) >> moveTo Prev (hiddenWS :&: ignoringWSs [scratchpadWorkspaceTag]) )
  , ("M-,",           nextScreen)
  , ("M-.",           prevScreen)
  , ("M1-,",          shiftNextScreen)
  , ("M1-.",          shiftPrevScreen)
  , ("M-M1-,",        shiftNextScreen >> nextScreen)
  , ("M-M1-.",        shiftPrevScreen >> prevScreen)
  , ("M-M1-<Space>",  swapNextScreen)
  -- , ("M1-<button4>",  spawn $ myTerm)
  -- , ("M-S-z", spawn "xscreensaver-command -lock")
  -- , ("M-C-s", unGrab *> spawn "scrot -s") -- "unGrab" means release keyboard before scrot tries to grab the keyboard ("*>" means first do this than that)
  -- , ("C-y",           spawn "xclip")
  -- , ("C-p",           spawn "xclip -o")
  ]
-- Helper function to toggle fullscreen
toggleFull = withFocused (\windowId -> do
  { floats <- gets (W.floating . windowset);
    if windowId `M.member` floats
      then withFocused $ windows . W.sink
      else withFocused $ windows . (flip W.float $  W.RationalRect 0 0 1 1) })
---------------------
--- MOUSEBINDINGS --- 
---------------------
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $
  [ ((modm, button1),     (\w -> focus w >> mouseMoveWindow w >> windows W.shiftMaster))
  , ((modm, button2),     (\w -> spawn "~/.local/bin/voltoggle.sh"))
  , ((modm, button3),     (\w -> focus w >> Flex.mouseResizeWindow w >> windows W.shiftMaster))
  , ((modm, button4),     (\w -> spawn  "~/.local/bin/volup.sh"))
  , ((modm, button5),     (\w -> spawn  "~/.local/bin/voldown.sh"))
  ]
