; Based on original script by just.dont.do.it and Lewd Pink (http://steamcommunity.com/sharedfiles/filedetails/?id=886396996)

disabled := 0 ; script on/off, toggle with f1

keypressDelay := 50 ; delay between keydown/keyup
doubletapDelay := 50 ; delay between keypresses when doubletapping
sequenceDelay := 50 ; delay between different sequences
dodgeTime := 400 ; delay between each dodge, for holding down shift+WASD

fireToggle := 0
ctrlToggle := 0

; basic movement - must match the ingame controls
fwdButton := "w"
backButton := "s"
leftButton := "a"
rightButton := "d"

; fire & jump - must match in-game controls
fireButton := "Tab"
jumpButton := "Space"

; toggle pod (for scanning or charging)
podCtrlToggleKey := "x"

; items usage - must match to in-game controls
altButton := "LAlt"
useItems := "Down"
use := "e"

; Extra controls added by the script - these keys must NOT bound in the game
; dodge key
dodgeButton := "LShift"
; air slide (fire + jump normally)
airSlideButton := "f"
; use last item
useLastItemButton := "v"
; Cycle target
cycleButton := "r"

#UseHook
SendMode Input
global fwdButton, backButton, leftButton, rightButton, fireButton, jumpButton, dodgeButton, altButton, useItems, use, useLastItemButton, keypressDelay, doubletapDelay, sequenceDelay, dodgeTime, fireToggle, disabled, ctrlToggle

press(key) {
  Send {Blind}{%key% down}
  Sleep keypressDelay
  Send {Blind}{%key% up}
}

; function for handling holding down shift and moving, for continuous dodging
handleDodge(key) {
  Send {Blind}{%key% up} ; stop running first in case we were
  Sleep sequenceDelay
  press(key)
  Sleep doubletapDelay
  Send {Blind}{%key% down}
  Sleep dodgeTime
  if (GetKeyState(fwdButton) && !GetKeyState(fwdButton, "P")) {
   Send {Blind}{%fwdButton% up}
  }
  if (GetKeyState(backButton) && !GetKeyState(backButton, "P")) {
   Send {Blind}{%backButton% up}
  }
  if (GetKeyState(leftButton) && !GetKeyState(leftButton, "P")) {
   Send {Blind}{%leftButton% up}
  }
  if (GetKeyState(rightButton) && !GetKeyState(rightButton, "P")) {
   Send {Blind}{%rightButton% up}
  }
}

waitForDodge() {
  while (GetKeyState(dodgeButton, "P")) {
    if (GetKeyState(fwdButton, "P")) {
      handleDodge(fwdButton)
    } else if (GetKeyState(backButton, "P")) {
      handleDodge(backButton)
    } else if (GetKeyState(leftButton, "P")) {
      handleDodge(leftButton)
    } else if (GetKeyState(rightButton, "P")) {
      handleDodge(rightButton)
    }
    Sleep, 10
  }
}

toggleFire() {
  if (GetKeyState(fireButton)) {
    Send {%fireButton% up}
  } else {
    Send {%fireButton% down}
  }
  fireToggle := GetKeyState("Tab")

  if (ctrlToggle or fireToggle){
    Gui, 1: Show, NA Y40 x960
  } else {
    Gui, 1: Hide
  }
}

airSlide() {
  if (GetKeyState(jumpButton)) {
    Send {%jumpButton% up}
  }
  if (GetKeyState(fireButton)) {
    Send {%fireButton% up}
    toggleFireBack := 1
  }
  Sleep sequenceDelay
  Send {%jumpButton% down}
  Send {%fireButton% down}
  Sleep keypressDelay
  Send {%fireButton% up}
  Send {%jumpButton% up}
  Sleep sequenceDelay
  ; go back to pressing the fire button
  if (toggleFireBack) {
    Send {%fireButton% down}
  }
  if (GetKeyState(jumpButton, "P")) {
    Send {%jumpButton% down}
  }
}

cycleTarget() {
  Send {Q down}
  Send {Right down}
  Sleep keypressDelay
  Send {Q up}
  Send {Right up}
}

useLastItem() {
  Send {%altButton% down}
  Send {%useItems% down}
  Sleep keypressDelay
  Send {%altButton% up}
  Send {%useItems% up}
  press(use)
}

#IfWinActive, NieR:Automata

; key combinations to toggle fire
Hotkey $%fireButton%, toggleFire
Hotkey $^%fireButton%, toggleFire
Hotkey $+%fireButton%, toggleFire

; dodges, work when you press/hold LShift while already holding WSAD
Hotkey ~*%dodgeButton%, waitForDodge

; air slide, normally executed with pod fire + jump
Hotkey $*%airSlideButton%, airSlide

; use last item
Hotkey $*%useLastItemButton%, useLastItem

; Cycle target locks
Hotkey $*%cycleButton%, cycleTarget

; include script for showing pod while using pod toggle
; uses GDI+ library by tic: https://github.com/tariqporter/Gdip
;#Include %A_ScriptDir%\Gdip_All.ahk
#Include %A_ScriptDir%\ShowPodIcon.ahk
$*x::
  if (GetKeyState("Ctrl")) {
    Send {Ctrl up}
  } else {
    Send {Ctrl down}
  }
  ctrlToggle := GetKeyState("Ctrl") ; this variable is used in other places to track state

  if (ctrlToggle or fireToggle){
    Gui, 1: Show, NA y40 x960
  } else {
    Gui, 1: Hide
  }
Return

~Ctrl::
  ctrlToggle := 0

  if (!(ctrlToggle or fireToggle)){
    Gui, 1: Hide
  }

Return

; add bindings for number keys:
; change weapons
*1::
  Send {LAlt down}
  Send {Up down}
  Sleep keypressDelay
  Send {LAlt up}
  Send {Up up}
Return

; change pod
*2::
  Send {LAlt down}
  Send {Right down}
  Sleep keypressDelay
  Send {LAlt up}
  Send {Right up}
Return

; change pod
*3::
  Send {LAlt down}
  Send {Left down}
  Sleep keypressDelay
  Send {LAlt up}
  Send {Left up}
Return

*m::Escape

; flashlight
; *5::t

; *r::
;   Send {Q down}
;   Send {Right down}
;   Sleep keypressDelay
;   Send {Q up}
;   Send {Right up}
; Return

; toggle script on/off for using steam overlay
f1::
Suspend,Toggle

if (disabled == 1){
  SoundPlay, %A_WinDir%\Media\Speech On.wav, 1
  disabled = 0
} else {
  SoundPlay, %A_WinDir%\Media\Speech Off.wav, 1
  disabled = 1
}

Return
