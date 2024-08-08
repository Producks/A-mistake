;- Initilization of the title screen and rendering -;

; Draw the title screen (ScreenUpdateIndex is using TitleScreenPPUDataPointers)
	LDA #DrawTitleLayout ; TitleLayout
	STA ScreenUpdateIndex
	JSR WaitForNMI_TitleScreen ; Check later if this create a conflict

; Draw level select digits
    LDA HighestLevel
    STA CurrentLevel
    JSR AdjustWorldLevelSelect

	JSR WaitForNMI_TitleScreen_TurnOnPPU ; Display title screen after everything is done
	LDA #DrawCursorOne
	STA CursorLocation ; Setup the cursor to the default position

;- End of initilization of the title screen and rendering -;


;- Title screen related functions, loop, input reading, sound effect, exiting -;
TitleScreenInputReading:
	LDA Player1JoypadPress
	BEQ WaitForNmiTitleScreen ; If nothing is being press, go wait right away
	JSR SendInputCheatCode ; Send input to the cheat code routine, don't worry nothing is hidden here :)

	AND #ControllerInput_Select | ControllerInput_Start ; The LDA Player1JoypadPress wasn't affected in the previous sub routine
	BNE CheckStartSelectInputTitleScreen

	LDA Player1JoypadPress
	AND #ControllerInput_Left | ControllerInput_Right
	BNE HandleHorizontalInputTitleScreen

WaitForNmiTitleScreen: ; No input matched or we are waiting for NMI!
	JSR WaitForNMI_TitleScreen
	JMP TitleScreenInputReading

; Handle input for left and right
HandleHorizontalInputTitleScreen:
	AND #ControllerInput_Left
	TAY 
	LDA CursorLocation
	CMP #DrawCursorTwo
	BNE WaitForNmiTitleScreen ; Go back to reading inputs if the cursor isn't on the level select position
	CPY #ControllerInput_Left ; Will make it that right take prio if someone is doing left + right
	BEQ DecreaseLevelSelect

IncrementLevelSelect:
	LDA CurrentLevel
	CMP #HighestLevel ; Check what is the furthest level we've been, and block you from going further.
	BCS PlayWrongsongTitleScreenLevelSelect
	INC CurrentLevel
	JMP PlaySoundEffectLevelSelect ; optimize later

DecreaseLevelSelect:
	LDA CurrentLevel
	BEQ PlayWrongsongTitleScreenLevelSelect
	DEC CurrentLevel

PlaySoundEffectLevelSelect:
	LDA #SoundEffect2_CoinGet
	STA SoundEffectQueue2

WorkAroundTitleScreen:
	JSR AdjustWorldLevelSelect
	JMP WaitForNmiTitleScreen

PlayWrongsongTitleScreenLevelSelect: ; Does a sound effect if we have reached the furthest we can go in the level select
    LDA #DPCM_PlayerHurt
    STA DPCMQueue
    JMP WaitForNmiTitleScreen


; Handle input for start and select on the main menu
CheckStartSelectInputTitleScreen:
	CMP #ControllerInput_Start ; Will make it that if select+start is press, that select take prio
	BEQ HandleStartInputTitleScreen

; Move the cursor
HandleSelectInputSelect:
	INC CursorLocation
	LDA CursorLocation
	CMP #$04
	BNE UpdateCursorFirstScreen
	LDA #$01
	STA CursorLocation

UpdateCursorFirstScreen:
	JSR UpdateCursorAndIndex
	JMP WaitForNmiTitleScreen ; optimize later

; Check 2 & 3, if not fall through to leaving the title screen
HandleStartInputTitleScreen:
	LDA CursorLocation
	CMP #DrawCursorTwo
	BEQ LevelSelectTitleScreen
	CMP #DrawCursorThree
	BEQ ConfirmationRendering

QuitTitleScreen:
	LDA #SoundEffect1_1UP
	STA SoundEffectQueue1
    LDA #Music2_StopMusic
	STA MusicQueue2
	LDA #$D0
	JSR WaitTitleScreenTimer

	LDA #$00
	TAY

ZeroMemoryAfterTitleScreen: ; CREATED MASSIVE BUG IF AUDIO WAS GOING, MADE ME LOSE 2 HOURS
	STA byte_RAM_0, Y
	INY
	CPY #$F0
	BCC ZeroMemoryAfterTitleScreen

	JMP HideAllSprites
;- End of title screen -;

LevelSelectTitleScreen:
	JMP WaitForNmiTitleScreen ; LOL, i'm an idiot. Bad code design GG

;- Confirmation related functions, sound effect, rendering, input reading, save wiping -;
ConfirmationRendering:
SetSoundEffectConfirmationRendering:
	LDA #SoundEffect1_ThrowItem
	STA SoundEffectQueue1

InitializeCursorForConfirmation: ; Could probably just INC, but scared to do so incase of a bug.
	LDA #DrawCursorFour
	STA CursorLocation

DrawConfirmationTextForDeletefile:
	LDA #DrawConfirmationText
	STA ScreenUpdateIndex
	JSR WaitForNMI_TitleScreen

; Loop here until the player confirm what choice they make
WaitForConfirmationInput:
	LDA Player1JoypadPress
	AND #ControllerInput_Start | ControllerInput_Select
	BNE CheckConfirmationSelect

WaitForNMIConfirmationText:
	JSR WaitForNMI_TitleScreen
	JMP WaitForConfirmationInput

CheckConfirmationSelect:
	CMP #ControllerInput_Select
	BEQ MoveCursorConfirmation 

HandleStartConfirmation:
	LDA CursorLocation
	CMP #DrawCursorFour
	BEQ PlaySoundEffectDecline ; Branch if cursor is on decline 3, delete if cursor at 4

; 0 out the save file
DeleteSaveFile:
	LDA #$00
	LDY #$0F
OverWriteSaveFile:
	STA $7FF0, Y
	DEY
	BPL OverWriteSaveFile

PlayDeleteSaveFileSoundEffect:
	LDA #SoundEffect2_Shrinking
	STA SoundEffectQueue2

CleanupConfirmation:
	LDA #DrawDeleteSaveFileText
	STA ScreenUpdateIndex
	LDA #DrawCursorOne
	STA CursorLocation
    JSR SetWorldNumberTitleScreen
	JMP WaitForNmiTitleScreen ; optimize later

MoveCursorConfirmation:
	LDA CursorLocation
	EOR #$01 ; Xor 07 to flip the last 3 bits
	JSR UpdateCursorAndIndex
	JMP WaitForNMIConfirmationText

PlaySoundEffectDecline:
	LDA #SoundEffect2_Climbing
	STA SoundEffectQueue2
	BNE CleanupConfirmation

;- End of functions confirmation -;


;- Random utilities subroutine for the title screen -;
;- Save 3-5 instructions at the cost of JSR + RTS, but not much is happening in here anyway... -;
UpdateCursorAndIndex:
	STA CursorLocation
	STA ScreenUpdateIndex
	LDA #SoundEffect1_CherryGet
	STA SoundEffectQueue1
	RTS

; Utulity timer for the title screen, wait an amount of frame until it overflow
WaitTitleScreenTimer:
	STA TimerTitleScreen
LoopTitleScreenTimer:
	JSR WaitForNMI
	INC TimerTitleScreen
	BNE LoopTitleScreenTimer
	RTS

;- This will fetch the CurrentLevel and set the current world that goes with this level, and also print it on the screen  -;
AdjustWorldLevelSelect:
	LDA CurrentLevel
	LDY #$00
LoopFindCurrentNewWorld: ; With the CurrentLevel value, find which world it belong to and set it.
	INY
	CMP WorldStartingLevel, Y
	BCS LoopFindCurrentNewWorld ; If CurrrentLevel >= WorldStartingIndex branch
	DEY
	STY CurrentWorld

; Display numbarssss
; Set the world number
SetWorldNumberTitleScreen:
	LDA CurrentWorld
	TAY
	CLC
	ADC #$D1
	STA CurrentLevelWorldScreenDisplay

; Set the level number
SetCurrentLevelTitleScreen:
	LDA CurrentLevel
	SEC
	SBC WorldStartingLevel, Y
	CLC
	ADC #$D1
	STA CurrentLevelTitleScreenDisplay

; Write to the PPU to update the color palette at location $3F11-$3f13
; Changed to e-f so it can be used everywhere, take 45 bytes of the permanent bank
UpdateLevelSelectNumbers:
	LDX byte_RAM_300
	LDA #$22
	STA PPUBuffer_301, X
	LDA #$F5
	STA PPUBuffer_301 + 1, X
	LDA #$03
	STA PPUBuffer_301 + 2, X
	LDA CurrentLevelWorldScreenDisplay
	STA PPUBuffer_301 + 3, X
	LDA #$F4
	STA PPUBuffer_301 + 4, X
	LDA CurrentLevelTitleScreenDisplay
	STA PPUBuffer_301 + 5, X
	LDA #$00
	STA PPUBuffer_301 + 6, X
	TXA
	CLC
	ADC #$06
	STA byte_RAM_300
	RTS

;- Fin  -;

CheatCodeTable:
	.db ControllerInput_Right, ControllerInput_Right, ControllerInput_Down, ControllerInput_Down, ControllerInput_Up

SendInputCheatCode:
	LDY CheatCodeCounter
	CMP #CheatCodeTable, Y
	BNE ResetCheatCodeCounter
	INY
	STY CheatCodeCounter
	CPY #$05
	BNE LeaveCheatcode
	LDY #SoundEffect2_Growing
	STY SoundEffectQueue2
    LDA #$13 ; :)
    STA HighestLevel
    STA CurrentLevel
    LDA #$06
    STA CurrentWorld
    JSR SetWorldNumberTitleScreen
    LDA Player1JoypadPress
ResetCheatCodeCounter:
	LDY #$00
	STY CheatCodeCounter
LeaveCheatcode:
	RTS

;- End of subroutine for the TitleScreen -;
