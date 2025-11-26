; i have used https://csc.csudh.edu/mmccullough/asm/help/index.html?page=source%2Fabout.htm as reference for irvine32 library functions and syntax it has helped me alot but there are still some functuions not even mentioned there it is not a complete reference but it helped me alot

; functions which are not mentioned in the above reference will be commented with explanation where used and at the end of the code 


.386
.MODEL        flat, stdcall
.STACK        4096

; =============================================
; Irvine32 Library Includes
; =============================================
INCLUDE       Irvine32.inc
INCLUDELIB    Irvine32.lib
INCLUDELIB    kernel32.lib
INCLUDELIB    user32.lib

; =============================================
; .data
; =============================================
.data

boxPositions  BYTE 14 DUP(0) ; 7 boxes × 2 bytes (X,Y)
treePositions BYTE 14 DUP(0) ; 7 trees × 2 bytes (X,Y)
boxCount      BYTE 0
treeCount     BYTE 0

boxChar       BYTE 'B'       ; Simple character for box
treeChar      BYTE 157       ; Simple character for tree


; =============================================
; NPC Data - 3 NPC Cars with fixed movement patterns (15 steps back and forth)
; =============================================
; NPC Car 1 - Horizontal movement (left-right)
npc1X                   BYTE 30                                                  ; NPC1 current X position
npc1Y                   BYTE 10                                                  ; NPC1 current Y position  
npc1StartX              BYTE 30                                                  ; NPC1 starting X (reference point)
npc1StartY              BYTE 10                                                  ; NPC1 starting Y (reference point)
npc1Direction           BYTE 1                                                   ; NPC1 direction: 1=moving away, 0=moving back
npc1StepCount           BYTE 0                                                   ; NPC1 step counter (0-15)
npc1MoveMode            BYTE 1                                                   ; NPC1 move mode: 1=horizontal, 2=vertical
npc1MoveCounter         BYTE 0                                                   ; NPC1 speed counter (moves every 4 cycles)

; NPC Car 2 - Vertical movement (up-down)
npc2X                   BYTE 60                                                  ; NPC2 current X position
npc2Y                   BYTE 12                                                  ; NPC2 current Y position  
npc2StartX              BYTE 60                                                  ; NPC2 starting X (reference point)
npc2StartY              BYTE 12                                                  ; NPC2 starting Y (reference point)
npc2Direction           BYTE 1                                                   ; NPC2 direction: 1=moving away, 0=moving back
npc2StepCount           BYTE 0                                                   ; NPC2 step counter (0-15)
npc2MoveMode            BYTE 2                                                   ; NPC2 move mode: 1=horizontal, 2=vertical
npc2MoveCounter         BYTE 0                                                   ; NPC2 speed counter (moves every 5 cycles)

; NPC Car 3 - Horizontal movement (right-left)
npc3X                   BYTE 90                                                  ; NPC3 current X position
npc3Y                   BYTE 18                                                  ; NPC3 current Y position  
npc3StartX              BYTE 90                                                  ; NPC3 starting X (reference point)
npc3StartY              BYTE 18                                                  ; NPC3 starting Y (reference point)
npc3Direction           BYTE 1                                                   ; NPC3 direction: 1=moving away, 0=moving back
npc3StepCount           BYTE 0                                                   ; NPC3 step counter (0-15)
npc3MoveMode            BYTE 1                                                   ; NPC3 move mode: 1=horizontal, 2=vertical
npc3MoveCounter         BYTE 0                                                   ; NPC3 speed counter (moves every 4 cycles)

npcChar                 BYTE 'C'                                                 ; NPC character


; Building position storage - tracks all placed buildings
buildingPositions       BYTE 200 DUP(0)                                          ; Stores X,Y pairs for each building block
buildingCountPlaced     BYTE 0                                                   ; Number of buildings actually placed

strScore                BYTE "Your score is: ",                       0
score                   BYTE 0

strTryAgain             BYTE "Try Again?  1=yes, 0=no",               0
invalidInput            BYTE "invalid input",                         0
strYouDied              BYTE "you died ",                             0
strPoints               BYTE " point(s)",                             0
strLevelComplete        BYTE "*** LEVEL COMPLETE! ***",               0
str4PassengersDelivered BYTE "4 Passengers Successfully Delivered!",  0
strYourScore            BYTE "Your Score: ",                          0
blank                   BYTE "                                     ", 0

; Represent the car (player vehicle) using 'T' characters (single char per segment)
car                     BYTE 'T'


; Keep only head position (single 'T' car)
xPos                    BYTE 11,                                      5 DUP(?) ; Head X (start near left boundary)
yPos                    BYTE 6,                                       5 DUP(?) ; Head Y

; Widened wall coordinates: increased right side X from 85 -> 96
xPosWall BYTE 10,10,110,110			;position of upperLeft, lowerLeft, upperRight, lowerRignt wall 
yPosWall BYTE 5,27,5,27


; xPosWall[0] = 10 → Upper-Left corner X
; xPosWall[1] = 10 → Lower-Left corner X
; xPosWall[2] = 110 → Upper-Right corner X
; xPosWall[3] = 110 → Lower-Right corner X

; yPosWall[0] = 5 → Upper-Left corner Y
; yPosWall[1] = 27 → Lower-Left corner Y
; yPosWall[2] = 5 → Upper-Right corner Y
; yPosWall[3] = 27 → Lower-Right corner Y

; (10,5)     (110,5)
;     ╔══════════╗
;     ║          ║
;     ║          ║
;     ║          ║
;     ╚══════════╝
; (10,27)    (110,27)


xCoinPos                BYTE ?
yCoinPos                BYTE ?

; Passenger storage (5 passengers × 2 bytes: X,Y)
passengerPositions      BYTE 10 DUP(0)
passengerCount          BYTE 0
passengerChar           BYTE 'P'

; Passenger state tracking
passengerStates         BYTE 5 DUP(0)                                            ; 0=waiting, 1=picked up, 2=delivered
currentPassenger        BYTE 255                                                 ; Index of currently carried passenger (255=none)
pickedUpPassenger       BYTE 0                                                   ; Flag: 0=no passenger, 1=carrying passenger
destinationColor        BYTE 2                                                   ; Green color for destination

inputChar               BYTE "+"                                                 ; + denotes the start of the game
speed                   DWORD 0
      
    title_line1  BYTE "                  _____________  ______________  _______  _____________  _________",  0
    title_line2  BYTE "      _           ___  __ \_  / / /_  ___/__  / / /__  / / /_  __ \_  / / /__  __ \", 0
    title_line3  BYTE "   0=[_]=0        __  /_/ /  / / /_____ \__  /_/ /__  /_/ /_  / / /  / / /__  /_/ /", 0
    title_line4  BYTE "     /T\          _  _, _// /_/ / ____/ /_  __  / _  __  / / /_/ // /_/ / _  _, _/",  0
    title_line5  BYTE "    |(o)|         /_/ |_| \____/  /____/ /_/ /_/  /_/ /_/  \____/ \____/  /_/ |_|",   0
    title_line6  BYTE "  []=\_/=[]       _____________________  ____________",                               0
    title_line7  BYTE "    __V__         __  ____/__    |__   |/  /__  ____/",                               0
    title_line8  BYTE "   '-----'        _  / __ __  /| |_  /|_/ /__  __/",                                  0
    title_line9  BYTE "                  / /_/ / _  ___ |  /  / / _  /___",                                  0
    title_line10 BYTE "                  \____/  /_/  |_/_/  /_/  /_____/",                                  0

    menu1   BYTE "                    1. Start New Game",        0
    menu2   BYTE "                    2. Continue Game",         0
    menu3   BYTE "                    3. Difficulty Level",      0
    menu4   BYTE "                    4. Leaderboard",           0
    menu5   BYTE "                    5. Instructions",          0
    menu6   BYTE "                    6. Exit",                  0
    prompt1 BYTE "                   Enter your choice (1-6): ", 0

    RedTaxi    BYTE "                     1.Red Taxi",    0
    YellowTaxi BYTE "                     2.Yellow Taxi", 0
    Randomcol  BYTE "                     3.Random Taxi", 0

    prompt2 BYTE "                     Please choose any car you like (1-3): ",                0
    prompt3 BYTE "                     Please enter player Name (show be with in 20 words): ", 0


; Add these to your .data section:
instructions_title BYTE "              RUSH HOUR TAXI - INSTRUCTIONS",           0
controls_title     BYTE "CONTROLS:",                                             0
control_arrows     BYTE "  Arrow Keys - Move taxi (Up, Down, Left, Right)",      0
control_space      BYTE "  Spacebar   - Pick up/Drop off passengers",            0
control_pause      BYTE "  P          - Pause game",                             0

gameplay_title     BYTE "HOW TO PLAY:",                                          0
gameplay1          BYTE "  1. Find passengers (P) and press SPACE to pick up",   0
gameplay2          BYTE "  2. Drive to green destination and SPACE to drop off", 0
gameplay3          BYTE "  3. Avoid NPC cars and collect bonus items (X)",       0

scoring_title      BYTE "SCORING:",                                              0
score_passenger    BYTE "  +10 points - Deliver passenger to destination",       0
score_bonus        BYTE "  +10 points - Collect bonus items (X)",                0
score_penalty      BYTE "  -5 points  - Hit a pedestrian",                       0

taxi_title         BYTE "TAXI DIFFERENCES:",                                     0
red_taxi           BYTE "  Red Taxi    : -2 pts (obstacles), -3 pts (cars)",     0
yellow_taxi        BYTE "  Yellow Taxi : -4 pts (obstacles), -2 pts (cars)",     0

pressAnyKey        BYTE "Press any key to return to main menu...",               0


    PlayerName BYTE 20 DUP(0)

    highscoresFile    BYTE "highscores.txt", 0
    LeaderBoardNames  BYTE 10 DUP(20 DUP(0))   ; 10 names, each 20 chars
    LeaderBoardScores DWORD 10 DUP(0)
    LeaderBoardCount  DWORD 0

    SelectTaxi_Line1 BYTE "            _____      _           _     _______         _",  0
    SelectTaxi_Line2 BYTE "           / ____|    | |         | |   |__   __|       (_)", 0
    SelectTaxi_Line3 BYTE "          | (___   ___| | ___  ___| |_     | | __ ___  ___ ", 0
    SelectTaxi_Line4 BYTE "           \___ \ / _ \ |/ _ \/ __| __|    | |/ _` \ \/ / |", 0
    SelectTaxi_Line5 BYTE "           ____) |  __/ |  __/ (__| |_     | | (_| |>  <| |", 0
    SelectTaxi_Line6 BYTE "          |_____/ \___|_|\___|\___|\__|    |_|\__,_/_/\_\_|", 0


    LEADERBOARD_Line1 BYTE " _     _____    _    ____  _____ ____  ____   ___    _    ____  ____",   0
    LEADERBOARD_Line2 BYTE "| |   | ____|  / \  |  _ \| ____|  _ \| __ ) / _ \  / \  |  _ \|  _ \",  0
    LEADERBOARD_Line3 BYTE "| |   |  _|   / _ \ | | | |  _| | |_) |  _ \| | | |/ _ \ | |_) | | | |", 0
    LEADERBOARD_Line4 BYTE "| |___| |___ / ___ \| |_| | |___|  _ <| |_) | |_| / ___ \|  _ <| |_| |", 0
    LEADERBOARD_Line5 BYTE "|_____|_____/_/   \_\____/|_____|_| \_\____/ \___/_/   \_\_| \_\____/",  0

    Car_line1 BYTE "                      _   ",  0
    Car_line2 BYTE "                   0=[_]=0",  0
    Car_line3 BYTE "                     /T\ ",   0
    Car_line4 BYTE "                    |(o)|",   0
    Car_line5 BYTE "                  []=\_/=[]", 0
    Car_line6 BYTE "                     _V_",    0
    Car_line7 BYTE "                   '-----'",  0


    ; Error messages
    invalidChoice   BYTE "Invalid choice!",                         0
    invalidNameSize BYTE "The name cannot be longer than 19 words", 0

    nameAcceptedMsg BYTE "Name accepted successfully!", 0
    tryAgainMsg     BYTE "Please try again.",           0
    
    ; Current selection
    userChoice       BYTE ?
    fileHandle       HANDLE ?
    UserColourChoice BYTE ?   ; 1 = Red, 2 = Yellow, 3 = Random
    PlayerNameLength BYTE ?
    
    ; Missing newGameMsg definition - adding it
    newGameMsg BYTE "*** START NEW GAME ***",0Dh,0Ah
               BYTE "This will start a new game...", 0
               
    continueMsg BYTE "*** CONTINUE GAME ***",0Dh,0Ah
                BYTE "Loading saved game...", 0
                
    difficultyMsg BYTE "*** DIFFICULTY LEVEL ***",0Dh,0Ah
                  BYTE "Easy, Medium, Hard options...", 0

    ; Game Mode Selection Screen
    gameModeTitle BYTE "            ____                      __  __           _     ",  0
    gameModeLine2 BYTE "           / ___| __ _ _ __ ___   ___|  \/  | ___   __| | ___",  0
    gameModeLine3 BYTE "          | |  _ / _` | '_ ` _ \ / _ \ |\/| |/ _ \ / _` |/ _ \", 0
    gameModeLine4 BYTE "          | |_| | (_| | | | | | |  __/ |  | | (_) | (_| |  __/", 0
    gameModeLine5 BYTE "           \____|\__,_|_| |_| |_|\___|_|  |_|\___/ \__,_|\___|", 0

    nameTitle BYTE "           _   _                     ",  0
    nameLine2 BYTE "          | \ | | __ _ _ __ ___   ___",  0
    nameLine3 BYTE "          |  \| |/ _` | '_ ` _ \ / _ \", 0
    nameLine4 BYTE "          | |\  | (_| | | | | | |  __/", 0
    nameLine5 BYTE "          |_| \_|\__,_|_| |_| |_|\___|", 0

    gameModePrompt BYTE "Select your game mode:", 0Dh, 0Ah, 0
    careerModeOpt  BYTE "  1. Career Mode   - Complete progressively difficult levels", 0Dh, 0Ah, 0
    timeModeOpt    BYTE "  2. Time Mode     - Pick up and deliver passengers within time limits", 0Dh, 0Ah, 0
    endlessModeOpt BYTE "  3. Endless Mode  - Play until you crash, endless passengers", 0Dh, 0Ah, 0Dh, 0Ah, 0
    gameModePrompt2  BYTE "Enter your choice (1-3): ",                0
    gameModeInvalid  BYTE "Invalid choice! Please enter 1, 2, or 3.", 0
    gameModeSelected BYTE "Mode selected: ",                          0

    ; Game Mode Storage
    currentGameMode BYTE 0                 ; 1=Career, 2=Time, 3=Endless
    careerModeName  BYTE "Career Mode",  0
    timeModeName    BYTE "Time Mode",    0
    endlessModeName BYTE "Endless Mode", 0
    
    ; Time Mode Variables
    timeStartMs        DWORD 0                        ; Starting time in milliseconds
    timeElapsedMs      DWORD 0                        ; Elapsed time in milliseconds
    timeLimitMs        DWORD 120000                   ; Time limit in milliseconds (120 seconds = 2 minutes)
    displaySeconds     BYTE 120                       ; Display value (seconds remaining)
    strTimeLeft        BYTE "Time: ",               0
    strTimeUp          BYTE "Time's Up! You died!", 0
    deliveredCount     BYTE 0                         ; Number of passengers delivered in time mode
    requiredDeliveries BYTE 4                         ; Must deliver 4 passengers in time mode
    timeModeActive     BYTE 0                         ; Flag: 1 if in time mode, 0 otherwise
                  
    leaderboardMsg BYTE "***No LEADERBOARD Record Yet***",0Dh,0Ah
                   BYTE "NO Leaderboard record be the first one to register :)", 0
                   
    instructionsMsg BYTE "*** INSTRUCTIONS ***",0Dh,0Ah
                    BYTE "Game rules and controls...", 0
                    
    exitMsg BYTE "*** EXIT GAME ***",0Dh,0Ah
            BYTE "Thank you for playing Rush Hour!",0Dh,0Ah
            BYTE "Goodbye!", 0


    
    pauseMsg         BYTE "Game Paused", 0
    resumeMsg     BYTE "[Any Key] Resume  [Q] Quit  [S] Save", 0
    quitToMenuMsg BYTE "Returning to main menu...",                               0
    savingMsg     BYTE "Saving score to leaderboard...",                          0
    
    ; Pause state
    isPaused         BYTE 0          ; 0 = not paused, 1 = paused

.code
main PROC
    call MainMenu
    exit
main     ENDP

; =============================================
; Main Menu Procedure
; =============================================
MainMenu PROC
menu_start:
    call DisplayMainMenu
    call GetUserChoice
    call ProcessMenuChoice
    
    ; If user didn't choose exit (6), show menu again
    cmp userChoice, 6
    jne menu_start
    
    ret
MainMenu        ENDP

; =============================================
; Display Main Menu Interface
; =============================================
DisplayMainMenu PROC
    call Clrscr ; Clear screen
    
    ; Display title with yellow color
    mov  eax, yellow + (black * 16)
    call SetTextColor
    
    ; Display ASCII art title
    mov  edx, OFFSET title_line1  ; FIXED: was "OFSET" should be "OFFSET"
    call WriteString
    call Crlf
    mov  edx, OFFSET title_line2
    call WriteString
    call Crlf
    mov  edx, OFFSET title_line3
    call WriteString
    call Crlf
    mov  edx, OFFSET title_line4
    call WriteString
    call Crlf
    mov  edx, OFFSET title_line5
    call WriteString
    call Crlf
    mov  edx, OFFSET title_line6
    call WriteString
    call Crlf
    mov  edx, OFFSET title_line7
    call WriteString
    call Crlf
    mov  edx, OFFSET title_line8
    call WriteString
    call Crlf
    mov  edx, OFFSET title_line9
    call WriteString
    call Crlf
    mov  edx, OFFSET title_line10
    call WriteString
    call Crlf
    call Crlf

    ; Reset to white color for menu items
    mov  eax, white + (black * 16)
    call SetTextColor
    
    ; Display menu options

    mov  eax, Green + (black * 16)
    call SetTextColor

    mov  edx, OFFSET menu1
    call WriteString
    call Crlf

    mov  eax, white + (black * 16)
    call SetTextColor
    
    mov  edx, OFFSET menu2
    call WriteString
    call Crlf
    
    mov  edx, OFFSET menu3
    call WriteString
    call Crlf
    
    mov  edx, OFFSET menu4
    call WriteString
    call Crlf
    
    mov  edx, OFFSET menu5
    call WriteString
    call Crlf

    mov  eax, Red + (black * 16)
    call SetTextColor
    
    mov  edx, OFFSET menu6
    call WriteString
    call Crlf
    call Crlf

    mov  eax, white + (black * 16)
    call SetTextColor
    
    ret
DisplayMainMenu ENDP

; =============================================
; Get User Choice (1-6)
; =============================================
GetUserChoice   PROC
input_loop:
    
    mov  edx, OFFSET prompt1
    call WriteString
    
    ; Read single character
    call ReadChar  ; The character is not echoed on the screen.
    call WriteChar ; Echo the character
    call Crlf
    call Crlf
    
    ; Validate input
    cmp al, '1'       ; it sets CF flag if al < value
    jb  invalid_input ; jb means jump if unsigned less than. it checks if CF = 1 then jumps
    cmp al, '6'
    ja  invalid_input ; ja means jump if unsigned greater than. it jumps if both CF = 0 (not less) and ZF = 0 (not equal) 
    
    ; Valid input - store it
    sub al,         '0' ; Convert ASCII to number
    mov userChoice, al
    ret

    ; lets say you want to enter 5 so the ascii value of 5 would be 53 in decimal and 0 would be 48 so 53 - 48 = 5
    ; it is valid for all values used here
    
invalid_input:
    mov  edx, OFFSET invalidChoice
    call WriteString
    call Crlf
    
    mov  edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar                ; Wait for any key
    
    call DisplayMainMenu ; Redisplay menu
    jmp  input_loop
    
GetUserChoice     ENDP

; =============================================
; Process Menu Choice
; =============================================
ProcessMenuChoice PROC
    cmp userChoice, 1
    je  start_new_game
    cmp userChoice, 2
    je  continue_game
    cmp userChoice, 3
    je  difficulty_menu
    cmp userChoice, 4
    je  show_leaderboard
    cmp userChoice, 5
    je  show_instructions
    cmp userChoice, 6
    je  exit_program
    ret

start_new_game:
    call SelectTaxiScreen
    call EnterPlayer_Name
    call GameModeSelectionScreen
    ; call start_game
    call Clrscr
    
    ; Initialize score to 0 for new game
    mov score,            0
    ; Reset leaderboard count so we load from file fresh
    mov LeaderBoardCount, 0
    
    ; Reset timeModeActive to 0 (will be set by GameModeSelectionScreen if needed)
    ; Note: GameModeSelectionScreen already sets timeModeActive = 1 if time mode selected
    
    call DrawWall       ;draw walls
    call DrawScoreboard ;draw scoreboard
    call DrawBuildings
    call DrawNPCs       ;draw NPC cars

    ; Set speed based on taxi color
    ; 1 = Red Taxi (slow: 15ms), 2 = Yellow Taxi (fast: 5ms)
    cmp UserColourChoice, 1
    je  set_red_speed
    
    ; Default to yellow (fast speed)
    mov eax, 5    ; Yellow taxi: 5ms per move (faster)
    jmp speed_set

set_red_speed:
    mov eax, 15 ; Red taxi: 15ms per move (slower)

speed_set:
    mov speed, eax


    jmp drawCar ;start the game flow (draw car and enter game loop)
    
continue_game:
    call ContinueGameScreen
    ret
    
difficulty_menu:
    call DifficultyScreen
    ret
    
show_leaderboard:
    call LeaderboardScreen
    ret
    
show_instructions:
    call InstructionsScreen
    ret
    
exit_program:
    call ExitScreen
    ret
    
ProcessMenuChoice   ENDP



; =============================================
; DynamicColor white - yellow - Red
; =============================================
SetDynamicColor_WRY PROC
    ; This will ALWAYS default to white if UserColourChoice isn't 1 or 2
    cmp UserColourChoice, 1
    je  set_red
    cmp UserColourChoice, 2
    je  set_yellow
    
    ; Default to white for any other value
    mov eax, white + (black * 16)
    jmp color_set

set_red:
    mov eax, red + (black * 16)
    jmp color_set

set_yellow:
    mov eax, yellow + (black * 16)

color_set:
    call SetTextColor
    ret
SetDynamicColor_WRY ENDP





; =============================================
; SelectTaxiScreen
; =============================================
SelectTaxiScreen    PROC
    call Clrscr
    
    mov  eax, cyan + (black * 16)
    call SetTextColor

    mov  edx, OFFSET SelectTaxi_Line1
    call WriteString
    call Crlf
    mov  edx, OFFSET SelectTaxi_Line2
    call WriteString
    call Crlf
    mov  edx, OFFSET SelectTaxi_Line3
    call WriteString
    call Crlf
    mov  edx, OFFSET SelectTaxi_Line4
    call WriteString
    call Crlf
    mov  edx, OFFSET SelectTaxi_Line5
    call WriteString
    call Crlf
    mov  edx, OFFSET SelectTaxi_Line6
    call WriteString
    call Crlf
    call Crlf
    call Crlf

    mov  eax, white + (black * 16)
    call SetTextColor
    mov  edx, OFFSET Car_line1
    call WriteString
    call Crlf
    mov  edx, OFFSET Car_line2
    call WriteString
    call Crlf
    mov  edx, OFFSET Car_line3
    call WriteString
    call Crlf
    mov  edx, OFFSET Car_line4
    call WriteString
    call Crlf
    mov  edx, OFFSET Car_line5
    call WriteString
    call Crlf
    mov  edx, OFFSET Car_line6
    call WriteString
    call Crlf
    mov  edx, OFFSET Car_line7
    call WriteString
    call Crlf
    call Crlf

    mov  eax, Red + (black * 16)
    call SetTextColor
    mov  edx, OFFSET RedTaxi
    call WriteString
    call Crlf
    call Crlf

    mov  eax, Yellow + (black * 16)
    call SetTextColor
    mov  edx, OFFSET YellowTaxi
    call WriteString
    call Crlf
    call Crlf

    mov  eax, White + (black * 16)
    call SetTextColor

    mov  edx, OFFSET Randomcol
    call WriteString
    call Crlf
    call Crlf



colourinput_loop:
    mov  edx, OFFSET prompt2
    call WriteString
    
    call ReadChar
    call WriteChar
    call Crlf
    call Crlf
    
    ; Validate input (1, 2, or 3)
    cmp al, '1'
    jb  invalid_input
    cmp al, '3'
    ja  invalid_input
    
    sub al, '0'

    cmp al, 3
    jne not_three

    call Randomize
    mov  eax,              2
    call RandomRange
    add  eax,              1
    mov  UserColourChoice, al
    jmp  return_back

not_three:
    mov UserColourChoice, al

return_back:
    ret

invalid_input:
    mov  edx, OFFSET invalidChoice
    call WriteString
    call Crlf
    
    mov  edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar
    
    call SelectTaxiScreen
    ret
    
SelectTaxiScreen ENDP

; =============================================
; Enter Player Name - FIXED VERSION
; =============================================
EnterPlayer_Name PROC
    call Clrscr
    call SetDynamicColor_WRY


    
   call Clrscr
    mov  dh,  1
    mov  dl,  10
    call Gotoxy
    mov  edx, OFFSET nameTitle
    call WriteString
    mov  dh,  2
    mov  dl,  10
    call Gotoxy
    mov  edx, OFFSET nameLine2
    call WriteString
    mov  dh,  3
    mov  dl,  10
    call Gotoxy
    mov  edx, OFFSET nameLine3
    call WriteString
    mov  dh,  4
    mov  dl,  10
    call Gotoxy
    mov  edx, OFFSET nameLine4
    call WriteString
    mov  dh,  5
    mov  dl,  10
    call Gotoxy
    mov  edx, OFFSET nameLine5
    call WriteString


    call Crlf
    call Crlf
    mov  edx, OFFSET Car_line1
    call WriteString
    call Crlf
    mov  edx, OFFSET Car_line2
    call WriteString
    call Crlf
    mov  edx, OFFSET Car_line3
    call WriteString
    call Crlf
    mov  edx, OFFSET Car_line4
    call WriteString
    call Crlf
    mov  edx, OFFSET Car_line5
    call WriteString
    call Crlf
    mov  edx, OFFSET Car_line6
    call WriteString
    call Crlf
    mov  edx, OFFSET Car_line7
    call WriteString
    call Crlf
    call Crlf

    mov  eax, white + (black * 16)
    call SetTextColor
    
Nameinput_loop:
    ; Clear the previous input
    mov edi, OFFSET PlayerName
    mov ecx, SIZEOF PlayerName
    mov al,  0
    rep stosb
    
    mov  edx, OFFSET prompt3
    call WriteString
    
    ; Read the player name with length limit
    mov  edx,              OFFSET PlayerName
    mov  ecx,              SIZEOF PlayerName
    call ReadString
    mov  PlayerNameLength, al
    
    ; Validate name length - STRICT 19 char limit
    cmp PlayerNameLength, 0
    je  invalid_input
    cmp PlayerNameLength, 19
    ja  name_too_long
    
    ; Ensure null termination
    movzx ebx,                         PlayerNameLength
    mov   byte ptr [PlayerName + ebx], 0
    
    ; Display success message
    call Crlf
    call Crlf
    mov  edx, OFFSET nameAcceptedMsg
    call WriteString
    call Crlf
    mov  edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar
    
    ret

name_too_long:
    call Crlf
    mov  edx, OFFSET invalidNameSize
    call WriteString
    call Crlf
    mov  edx, OFFSET tryAgainMsg
    call WriteString
    call Crlf
    jmp  Nameinput_loop

invalid_input:
    call Crlf
    mov  edx, OFFSET invalidNameSize
    call WriteString
    call Crlf
    mov  edx, OFFSET tryAgainMsg
    call WriteString
    call Crlf
    jmp  Nameinput_loop
EnterPlayer_Name        ENDP

; =============================================
; GameModeSelectionScreen - Displays game mode options
; =============================================
GameModeSelectionScreen PROC
    call Clrscr
    mov  dh,  1
    mov  dl,  10
    call Gotoxy
    mov  edx, OFFSET gameModeTitle
    call WriteString
    mov  dh,  2
    mov  dl,  10
    call Gotoxy
    mov  edx, OFFSET gameModeLine2
    call WriteString
    mov  dh,  3
    mov  dl,  10
    call Gotoxy
    mov  edx, OFFSET gameModeLine3
    call WriteString
    mov  dh,  4
    mov  dl,  10
    call Gotoxy
    mov  edx, OFFSET gameModeLine4
    call WriteString
    mov  dh,  5
    mov  dl,  10
    call Gotoxy
    mov  edx, OFFSET gameModeLine5
    call WriteString
    
    
    mov  dh,  9
    mov  dl,  5
    call Gotoxy
    mov  edx, OFFSET gameModePrompt
    call WriteString
    mov  dh,  11
    mov  dl,  5
    call Gotoxy
    mov  edx, OFFSET careerModeOpt
    call WriteString
    mov  dh,  12
    mov  dl,  5
    call Gotoxy
    mov  edx, OFFSET timeModeOpt
    call WriteString
    mov  dh,  13
    mov  dl,  5
    call Gotoxy
    mov  edx, OFFSET endlessModeOpt
    call WriteString
gameModeInputLoop:
    mov  dh,  16
    mov  dl,  5
    call Gotoxy
    mov  edx, OFFSET gameModePrompt2
    call WriteString
    call ReadChar
    call WriteChar
    call Crlf
    cmp  al,  '1'
    je   setCareerMode
    cmp  al,  '2'
    je   setTimeMode
    cmp  al,  '3'
    je   setEndlessMode
    mov  dh,  18
    mov  dl,  5
    call Gotoxy
    mov  edx, OFFSET gameModeInvalid
    call WriteString
    call Crlf
    jmp  gameModeInputLoop
setCareerMode:
    mov  currentGameMode, 1
    mov  timeModeActive,  0                       ; Deactivate time mode for career
    mov  dh,              18
    mov  dl,              5
    call Gotoxy
    mov  edx,             OFFSET gameModeSelected
    call WriteString
    mov  edx,             OFFSET careerModeName
    call WriteString
    call Crlf
    call ReadChar
    ret
setTimeMode:
    mov  currentGameMode, 2
    mov  timeModeActive,  1                       ; Activate time mode
    mov  displaySeconds,  120                     ; Display 120 seconds (2 minutes)
    call GetMseconds                              ; Get current system time in milliseconds
    mov  timeStartMs,     eax                     ; Store start time
    mov  timeElapsedMs,   0                       ; Reset elapsed time
    mov  deliveredCount,  0                       ; Reset delivered passenger count
    mov  dh,              18
    mov  dl,              5
    call Gotoxy
    mov  edx,             OFFSET gameModeSelected
    call WriteString
    mov  edx,             OFFSET timeModeName
    call WriteString
    call Crlf
    call ReadChar
    ret
setEndlessMode:
    mov  currentGameMode, 3
    mov  timeModeActive,  0                       ; Deactivate time mode for endless
    mov  dh,              18
    mov  dl,              5
    call Gotoxy
    mov  edx,             OFFSET gameModeSelected
    call WriteString
    mov  edx,             OFFSET endlessModeName
    call WriteString
    call Crlf
    call ReadChar
    ret
GameModeSelectionScreen ENDP

; =============================================
; LeaderboardScreen
; =============================================
LeaderboardScreen       PROC
    mov  edx,        OFFSET highscoresFile
    call OpenInputFile
    mov  fileHandle, eax

    cmp fileHandle, INVALID_HANDLE_VALUE
    je  Createnewfile

    mov  edx, OFFSET LeaderBoardCount
    mov  ecx, SIZEOF LeaderBoardCount
    call ReadFromFile

    mov ecx, LeaderBoardCount
    cmp ecx, 0
    je  close_file

    mov esi, 0
read_loop:
    ; Calculate name offset manually
    mov  eax, esi
    mov  ebx, 20
    mul  ebx                          ; EAX = ESI × 20 (offset from start of array)
    mov  edx, OFFSET LeaderBoardNames
    add  edx, eax
    mov  eax, fileHandle
    mov  ecx, 20
    call ReadFromFile

    ; Calculate score offset manually  
    mov  eax, esi
    mov  ebx, 4
    mul  ebx
    mov  edx, OFFSET LeaderBoardScores
    add  edx, eax
    mov  eax, fileHandle
    mov  ecx, 4
    call ReadFromFile

    inc esi
    mov ecx, LeaderBoardCount
    sub ecx, esi
    jnz read_loop

close_file:
    mov  eax, fileHandle
    call CloseFile
    call DisplayLeaderboard
    ret

Createnewfile:
    mov  edx,              OFFSET highscoresFile
    call CreateOutputFile
    mov  fileHandle,       eax
    call CloseFile
    mov  LeaderBoardCount, 0
    call DisplayLeaderboard
    ret
LeaderboardScreen ENDP

; =============================================
; Save Leaderboard to File
; =============================================
saveLeaderBoard   PROC
    mov  edx,        OFFSET highscoresFile
    call CreateOutputFile
    mov  fileHandle, eax

    mov  edx, OFFSET LeaderBoardCount
    mov  ecx, SIZEOF LeaderBoardCount
    call WriteToFile

    mov ecx, LeaderBoardCount
    cmp ecx, 0
    je  close_file_save

    mov esi, 0
write_loop:
    ; Calculate name offset manually
    mov  eax, esi
    mov  ebx, 20
    mul  ebx
    mov  edx, OFFSET LeaderBoardNames
    add  edx, eax
    mov  eax, fileHandle
    mov  ecx, 20
    call WriteToFile

    ; Calculate score offset manually
    mov  eax, esi
    mov  ebx, 4
    mul  ebx
    mov  edx, OFFSET LeaderBoardScores
    add  edx, eax
    mov  eax, fileHandle
    mov  ecx, 4
    call WriteToFile

    inc esi
    mov ecx, LeaderBoardCount
    sub ecx, esi
    jnz write_loop

close_file_save:
    mov  eax, fileHandle
    call CloseFile
    ret
saveLeaderBoard ENDP


; =============================================
; Swap Names
; Input: EDI = first name address, ESI = second name address
; =============================================
SwapNames       PROC
    pushad         ; Save ALL general-purpose registers to stack
    mov    ecx, 20 ; Set counter to 20 (names are 20 bytes each)
swap_loop:
    mov   al,    [edi] ; Load byte from first name into AL
    mov   bl,    [esi] ; Load byte from second name into BL
    mov   [edi], bl    ; Store byte from BL into first name
    mov   [esi], al    ; Store byte from AL into second name
    inc   edi          ; Move to next byte in first name
    inc   esi          ; Move to next byte in second name
    loop  swap_loop    ; Decrement ECX and loop until ECX = 0
    popad              ; Restore ALL general-purpose registers from stack
    ret
SwapNames  ENDP

; =============================================
; Copy String
; Input: ESI = source, EDI = destination, ECX = count
; =============================================
CopyString PROC
    push esi ; Save original ESI value to stack
    push edi ; Save original EDI value to stack  
    push ecx ; Save original ECX value to stack
    cld      ; Clear Direction Flag (DF=0) - move forward in memory

    rep movsb ; Repeat MOVe String Byte: copy ECX bytes from [ESI] to [EDI]
    ; movsb = "Move String Byte" - Copies 1 byte from [ESI] to [EDI], then increments both ESI and EDI
    ; rep = "Repeat" - Repeats movsb ECX times (decrementing ECX each time until ECX=0)

    pop ecx ; Restore original ECX from stack
    pop edi ; Restore original EDI from stack
    pop esi ; Restore original ESI from stack
    ret     ; Return to caller
CopyString            ENDP

; =============================================
; Add Score to Leaderboard
; Input: EAX = score, EDX = player name address
; =============================================
AddScoreToLeaderboard PROC
    ; Save the input parameters in registers that won't be clobbered
    mov ebx, eax ; Save score in EBX
    mov esi, edx ; Save player name address in ESI
    
    ; Initialize LeaderBoardCount to 0 first
    mov LeaderBoardCount, 0
    
    ; Try to load existing leaderboard data from file
    mov  edx,        OFFSET highscoresFile
    call OpenInputFile
    mov  fileHandle, eax

    cmp fileHandle, INVALID_HANDLE_VALUE
    je  check_board_full                 ; File doesn't exist, start fresh

    ; Try to read the count
    mov  edx, OFFSET LeaderBoardCount
    mov  ecx, SIZEOF LeaderBoardCount
    call ReadFromFile

    ; Check if we successfully read a valid count
    mov ecx, LeaderBoardCount
    cmp ecx, 0
    je  file_empty            ; No entries in file

    cmp ecx, 10
    jbe load_existing_data ; Count is valid (1-10), load the data

file_empty:
    ; File exists but is empty
    mov  eax,              fileHandle
    call CloseFile
    mov  LeaderBoardCount, 0
    jmp  check_board_full

load_existing_data:
    ; Load existing scores and names
    mov edi, 0 ; Use EDI as loop counter
load_existing_loop:
    ; Read name
    mov  eax, edi
    mov  ecx, 20
    mul  ecx
    mov  edx, OFFSET LeaderBoardNames
    add  edx, eax
    mov  eax, fileHandle              ; Load file handle
    mov  ecx, 20
    call ReadFromFile

    ; Read score
    mov  eax, edi
    mov  ecx, 4
    mul  ecx
    mov  edx, OFFSET LeaderBoardScores
    add  edx, eax
    mov  eax, fileHandle               ; Load file handle again
    mov  ecx, 4
    call ReadFromFile

    inc edi
    cmp edi, LeaderBoardCount
    jb  load_existing_loop

    mov  eax, fileHandle
    call CloseFile

check_board_full:
    cmp LeaderBoardCount, 10
    jb  add_new_score

    ; Check if new score is higher than lowest score
    mov eax, 9
    mov ecx, 4
    mul ecx
    mov edx, OFFSET LeaderBoardScores
    add edx, eax                      ; EDX = address of score[9]
    mov ecx, [edx]                    ; ECX = lowest score value
    
    cmp ebx, ecx ; Compare new score with lowest (ebx contains score)
    jbe no_add

    ; Replace lowest score
    mov eax, 9
    mov ecx, 20
    mul ecx                          ; EAX = 9 × 20 = 180
    mov edi, OFFSET LeaderBoardNames
    add edi, eax
    mov edx, esi                     ; Source name (ESI contains name address)
    mov ecx, 20
    
    ; Call CopyString: ESI = source, EDI = destination, ECX = count
    push esi
    mov  esi, edx
    call CopyString
    pop  esi
    
    ; Store score
    mov eax,   9
    mov ecx,   4
    mul ecx
    mov edi,   OFFSET LeaderBoardScores
    add edi,   eax                      ; EDI = address of score[9]
    mov eax,   ebx                      ; EAX = score (stored in ebx)
    mov [edi], eax                      ; Store new score
    jmp sort_scores

add_new_score:
    ; Add to end
    mov eax, LeaderBoardCount
    mov ecx, 20
    mul ecx
    mov edi, OFFSET LeaderBoardNames
    add edi, eax
    mov edx, esi                     ; Source name (ESI contains name address)
    mov ecx, 20
    
    ; Call CopyString: ESI = source, EDI = destination, ECX = count
    push esi
    mov  esi, edx
    call CopyString
    pop  esi
    
    ; Store score
    mov eax,   LeaderBoardCount
    mov ecx,   4
    mul ecx
    mov edi,   OFFSET LeaderBoardScores
    add edi,   eax
    mov eax,   ebx                      ; EAX = score (stored in ebx)
    mov [edi], eax
    
    inc LeaderBoardCount

sort_scores:
    ; Simple bubble sort for leaderboard (highest first)
    mov ecx, LeaderBoardCount
    dec ecx
    jz  save_leaderboard      ; If only 1 entry, no sort needed

outer_loop:
    push ecx
    mov  esi, 0 ; ESI = inner loop index (i)
inner_loop:
    ; Get current score (scores[i])
    mov eax, esi                      ; EAX = current index
    mov ebx, 4
    mul ebx
    mov edi, OFFSET LeaderBoardScores
    add edi, eax                      ; EDI = address of scores[i]
    mov eax, [edi]                    ; EAX = scores[i]
    
    ; Get next score (scores[i+1])
    mov  ebx, esi
    inc  ebx                           ; EBX = next index (i+1)
    push eax                           ; Save scores[i]
    mov  eax, ebx                      ; EAX = next index
    mov  ebx, 4
    mul  ebx                           ; EAX = (i+1) × 4
    mov  edi, OFFSET LeaderBoardScores
    add  edi, eax
    mov  ebx, [edi]                    ; EBX = value of scores[i+1]
    pop  eax                           ; Restore scores[i]
    
    cmp eax, ebx ; Compare scores[i] with scores[i+1]
    jae no_swap  ; If scores[i] >= scores[i+1], no swap needed
                       ; This means we want DESCENDING order

    ; Swap scores
    push eax                             ; Save scores[i]
    push ebx                             ; Save scores[i+1]
    mov  eax,   esi                      ; Current index
    mov  ebx,   4
    mul  ebx
    mov  edi,   OFFSET LeaderBoardScores
    add  edi,   eax                      ; EDI = address of scores[i]
    pop  ebx                             ; Restore scores[i+1]
    mov  [edi], ebx                      ; Store scores[i+1] in scores[i]
    
    mov eax,   esi
    inc eax
    mov ebx,   4
    mul ebx
    mov edi,   OFFSET LeaderBoardScores
    add edi,   eax
    pop eax                             ; Restore scores[i]
    mov [edi], eax                      ; Store scores[i] in scores[i+1]

    ; Swap names - FIXED: Save and restore ESI properly
    push esi                          ; Save current index
    mov  eax, esi
    mov  ebx, 20
    mul  ebx
    mov  edi, OFFSET LeaderBoardNames
    add  edi, eax
    
    mov eax, esi
    inc eax
    mov ebx, 20
    mul ebx
    mov esi, OFFSET LeaderBoardNames
    add esi, eax
    
    call SwapNames
    pop  esi       ; Restore current index

no_swap:
    inc esi
    cmp esi, ecx
    jb  inner_loop
    
    pop ecx
    dec ecx
    jnz outer_loop

save_leaderboard:
    call saveLeaderBoard

no_add:
    ret
AddScoreToLeaderboard ENDP

; =============================================
; Display Leaderboard
; =============================================
DisplayLeaderboard    PROC
    call Clrscr

    ; Load leaderboard data first
    mov  edx,        OFFSET highscoresFile
    call OpenInputFile
    mov  fileHandle, eax

    cmp fileHandle, INVALID_HANDLE_VALUE
    je  no_file

    ; Read the count
    mov  edx, OFFSET LeaderBoardCount
    mov  ecx, SIZEOF LeaderBoardCount
    call ReadFromFile

    ; Read the actual data
    mov ecx, LeaderBoardCount
    cmp ecx, 0
    je  close_display_file

    mov esi, 0
read_display_loop:
    ; Read name
    mov  eax, esi
    mov  ebx, 20
    mul  ebx
    mov  edx, OFFSET LeaderBoardNames
    add  edx, eax
    mov  eax, fileHandle
    mov  ecx, 20
    call ReadFromFile

    ; Read score
    mov  eax, esi
    mov  ebx, 4
    mul  ebx
    mov  edx, OFFSET LeaderBoardScores
    add  edx, eax
    mov  eax, fileHandle
    mov  ecx, 4
    call ReadFromFile

    inc esi
    cmp esi, LeaderBoardCount
    jb  read_display_loop

close_display_file:
    mov  eax, fileHandle
    call CloseFile

no_file:
    ; Now display the data
    mov  eax, cyan + (black * 16)
    call SetTextColor

    mov  edx, OFFSET LEADERBOARD_Line1
    call WriteString
    call Crlf
    mov  edx, OFFSET LEADERBOARD_Line2
    call WriteString
    call Crlf
    mov  edx, OFFSET LEADERBOARD_Line3
    call WriteString
    call Crlf
    mov  edx, OFFSET LEADERBOARD_Line4
    call WriteString
    call Crlf
    mov  edx, OFFSET LEADERBOARD_Line5
    call WriteString
    call Crlf
    call Crlf

    ; Check if leaderboard is empty
    cmp LeaderBoardCount, 0
    je  no_scores

    mov  eax, white + (black * 16)
    call SetTextColor

    ; Display only actual entries
    mov ecx, LeaderBoardCount
    mov esi, 0
score_loop:
    ; Display rank number
    mov  eax, esi
    inc  eax
    call WriteDec
    mov  al,  '.'
    call WriteChar
    mov  al,  ' '
    call WriteChar

    ; Display name
    mov  eax, esi
    mov  ebx, 20
    mul  ebx
    mov  edx, OFFSET LeaderBoardNames
    add  edx, eax
    call WriteString

    ; Add spacing
    mov  al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar

    ; Display score
    mov  eax, esi
    mov  ebx, 4
    mul  ebx
    mov  edx, OFFSET LeaderBoardScores
    add  edx, eax
    mov  eax, [edx]
    call WriteDec
    call Crlf

    inc  esi
    loop score_loop
    jmp  done_display

no_scores:
    mov  eax, Red + (black * 16)
    call SetTextColor
    call Crlf
    call Crlf
    mov  edx, OFFSET leaderboardMsg
    call WriteString

done_display:
    mov  eax, White + (black * 16)
    call SetTextColor
    call Crlf
    call Crlf
    mov  edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar
    ret
DisplayLeaderboard ENDP



; =============================================
; Placeholder Screens for other Menu Option
; =============================================
NewGameScreen      PROC
    call Clrscr
    mov  edx, OFFSET newGameMsg
    call WriteString
    call Crlf
    call WaitForKey
    ret
NewGameScreen      ENDP

ContinueGameScreen PROC
    call Clrscr
    mov  edx, OFFSET continueMsg
    call WriteString
    call Crlf
    call WaitForKey
    ret
ContinueGameScreen ENDP

DifficultyScreen   PROC
    call Clrscr
    mov  edx, OFFSET difficultyMsg
    call WriteString
    call Crlf
    call WaitForKey
    ret
DifficultyScreen   ENDP

InstructionsScreen PROC
    call Clrscr
    
    ; Display title
    mov  eax, cyan + (black * 16)
    call SetTextColor
    mov  edx, OFFSET instructions_title
    call WriteString
    call Crlf
    call Crlf
    
    ; Basic Controls
    mov  eax, yellow + (black * 16)
    call SetTextColor
    mov  edx, OFFSET controls_title
    call WriteString
    call Crlf
    
    mov  eax, white + (black * 16)
    call SetTextColor
    mov  edx, OFFSET control_arrows
    call WriteString
    call Crlf
    mov  edx, OFFSET control_space
    call WriteString
    call Crlf
    mov  edx, OFFSET control_pause
    call WriteString
    call Crlf
    call Crlf
    
    ; Gameplay Instructions
    mov  eax, green + (black * 16)
    call SetTextColor
    mov  edx, OFFSET gameplay_title
    call WriteString
    call Crlf
    
    mov  eax, white + (black * 16)
    call SetTextColor
    mov  edx, OFFSET gameplay1
    call WriteString
    call Crlf
    mov  edx, OFFSET gameplay2
    call WriteString
    call Crlf
    mov  edx, OFFSET gameplay3
    call WriteString
    call Crlf
    call Crlf
    
    ; Scoring System
    mov  eax, lightGreen + (black * 16)
    call SetTextColor
    mov  edx, OFFSET scoring_title
    call WriteString
    call Crlf
    
    mov  eax, white + (black * 16)
    call SetTextColor
    mov  edx, OFFSET score_passenger
    call WriteString
    call Crlf
    mov  edx, OFFSET score_bonus
    call WriteString
    call Crlf
    mov  edx, OFFSET score_penalty
    call WriteString
    call Crlf
    call Crlf
    
    ; Taxi Differences
    mov  eax, lightBlue + (black * 16)
    call SetTextColor
    mov  edx, OFFSET taxi_title
    call WriteString
    call Crlf
    
    mov  eax, white + (black * 16)
    call SetTextColor
    mov  edx, OFFSET red_taxi
    call WriteString
    call Crlf
    mov  edx, OFFSET yellow_taxi
    call WriteString
    call Crlf
    call Crlf
    
    mov  edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar
    ret



InstructionsScreen ENDP

ExitScreen         PROC
    call Clrscr
    mov  edx, OFFSET exitMsg
    call WriteString
    call Crlf
    call WaitForKey
    
    ; Actually exit the program
    invoke ExitProcess, 0
    ret
ExitScreen ENDP

; =============================================
; Utility Function - Wait for Key Press
; =============================================
WaitForKey PROC
    mov  edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar
    ret
WaitForKey   ENDP


; =============================================
; ApplyPenalty - applies penalty based on taxi color
; =============================================
ApplyPenalty PROC
    ; Check if score is already 0
    cmp score, 0
    je  no_penalty
    
    ; Apply penalty based on taxi color
    cmp UserColourChoice, 1
    je  red_penalty
    cmp UserColourChoice, 2
    je  yellow_penalty
    
    ; Default penalty: -1 point
    dec score
    jmp update_display

red_penalty:
    ; Red taxi: -2 points
    cmp score, 2
    jl  no_penalty
    sub score, 2
    jmp update_display

yellow_penalty:
    ; Yellow taxi: -4 points
    cmp score, 4
    jl  no_penalty
    sub score, 4

update_display:
    call DrawScoreboard

no_penalty:
    ret
ApplyPenalty ENDP

; =============================================
; drawCar - Main Game Loop
; ============================================
drawCar:
    ; Clear and regenerate boxes and trees each game
    mov boxCount,  0
    mov treeCount, 0
    
    ; Initialize timer display for time mode
    cmp   timeModeActive, 1
    jne   skip_timer_init
    mov   dl,             95                 ; Right side of screen (X position)
    mov   dh,             29                 ; Bottom of screen (Y position)
    call  Gotoxy
    mov   edx,            OFFSET strTimeLeft
    call  WriteString
    movzx eax,            displaySeconds
    call  WriteDec
    mov   al,             ' '
    call  WriteChar
    call  WriteChar
    
skip_timer_init:
    mov esi, 0
    mov ecx, 1 ; draw only the head (car)
drawCar_loop:
    call DrawPlayer   ; draw car (taxi) head only
    inc  esi          ; it is passed in the drawplayer proc to know which part to draw
    loop drawCar_loop

    call Randomize
    call CreateRandomCoin
    call DrawCoin              ; set up finish
    call GenerateBoxesAndTrees
    call DrawBoxesAndTrees
    call CreatePassengers
    call DrawPassengers

    gameLoop::
    mov  dl, 106 ;move cursor to coordinates where it is safe so no overlap occurs
    mov  dh, 1
    call Gotoxy

    ; Update time counter if in time mode
    cmp  timeModeActive, 1
    jne  skip_time_update
    call UpdateTimeCounter
    ; Check if time is up (displaySeconds = 0)
    cmp  displaySeconds, 0
    je   time_is_up
    
skip_time_update:

    ; Erase and move NPC cars
    call EraseNPCs
    call MoveNPCs
    call DrawNPCs
    
   

    ; get user key input
    call ReadKey  ; No Key Passed → ZF = 1 (Zero Flag SET) on Key Pressed call ReadKey → ZF = 0 (Zero Flag CLEAR)
    jz   gameLoop ;no key → wait for next key press
    
    ; Handle extended (arrow) keys: when AL==0 the scan code is in AH
    cmp al, 0      ; Extended keys (arrow keys, function keys) send two bytes: first byte is 0, second byte is scan code
    jne normal_key ; If AL != 0, it's a normal ASCII key and we jump to normal_key processing

    ; Extended key — check scan code in AH and jump to movement checks
    cmp ah, 72      ; Up arrow scan code
    je  checkTop
    cmp ah, 80      ; Down
    je  checkBottom
    cmp ah, 75      ; Left
    je  checkLeft
    cmp ah, 77      ; Right
    je  checkRight
    jmp gameLoop

normal_key:
    ; AL contains a normal ASCII key
    cmp al, 'p'
    je  pause_game
    cmp al, 'P'
    je  pause_game
    cmp al, ' '         ; Spacebar for pickup/drop
    je  handle_spacebar
    jmp gameLoop

handle_spacebar:
    call HandlePickupDrop
    jmp  gameLoop

pause_game:
    ; Pause menu at right side of screen
    mov  dh,  1
    mov  dl,  70
    call Gotoxy
    mov  al,  218  ; ┌
    call WriteChar
    mov  ecx, 40
    mov  al,  196  ; ─
    clear_top:
    call WriteChar
    loop clear_top
    mov  al,  191  ; ┐
    call WriteChar
    
    mov  dh,  2
    mov  dl,  70
    call Gotoxy
    mov  al,  179     ; │
    call WriteChar
    mov  al,  ' '
    mov  ecx, 40
    pause_space1:
    call WriteChar
    loop pause_space1
    mov  al,  179     ; │
    call WriteChar
    
    mov  dh,  2
    mov  dl,  73
    call Gotoxy
    mov  edx, OFFSET pauseMsg
    call WriteString
    
    mov  dh,  3
    mov  dl,  70
    call Gotoxy
    mov  al,  179     ; │
    call WriteChar
    mov  al,  ' '
    mov  ecx, 40
    pause_space2:
    call WriteChar
    loop pause_space2
    mov  al,  179     ; │
    call WriteChar
    
    mov  dh,  3
    mov  dl,  73
    call Gotoxy
    mov  edx, OFFSET resumeMsg
    call WriteString
    
    mov  dh,  4
    mov  dl,  70
    call Gotoxy
    mov  al,  192  ; └
    call WriteChar
    mov  ecx, 40
    mov  al,  196  ; ─
    clear_bot:
    call WriteChar
    loop clear_bot
    mov  al,  217  ; ┘
    call WriteChar
    
    ; Wait for input
    call ReadChar
    
    ; Check if save
    cmp al, 's'
    je  pause_save_score
    cmp al, 'S'
    je  pause_save_score
    
    ; Check if quit
    cmp al, 'q'
    je  pause_quit_to_menu
    cmp al, 'Q'
    je  pause_quit_to_menu
    
    ; Clear pause box lines - clear entire area
    mov  dh,  1
    mov  dl,  70
    call Gotoxy
    mov  ecx, 42           ; 70 to 111 = 42 chars
    mov  al,  ' '
    clear_pause_line1:
    call WriteChar
    loop clear_pause_line1
    
    mov  dh,  2
    mov  dl,  70
    call Gotoxy
    mov  ecx, 42
    mov  al,  ' '
    clear_pause_line2:
    call WriteChar
    loop clear_pause_line2
    
    mov  dh,  3
    mov  dl,  70
    call Gotoxy
    mov  ecx, 42
    mov  al,  ' '
    clear_pause_line3:
    call WriteChar
    loop clear_pause_line3
    
    mov  dh,  4
    mov  dl,  70
    call Gotoxy
    mov  ecx, 42
    mov  al,  ' '
    clear_pause_line4:
    call WriteChar
    loop clear_pause_line4
    
    ; Resume - continue game
    jmp gameLoop

pause_save_score:
    ; Clear pause box first (right side)
    mov  dh,  1
    mov  dl,  70
    call Gotoxy
    mov  ecx, 42
    mov  al,  ' '
    clear_save_line1:
    call WriteChar
    loop clear_save_line1
    
    mov  dh,  2
    mov  dl,  70
    call Gotoxy
    mov  ecx, 42
    mov  al,  ' '
    clear_save_line2:
    call WriteChar
    loop clear_save_line2
    
    mov  dh,  3
    mov  dl,  70
    call Gotoxy
    mov  ecx, 42
    mov  al,  ' '
    clear_save_line3:
    call WriteChar
    loop clear_save_line3
    
    mov  dh,  4
    mov  dl,  70
    call Gotoxy
    mov  ecx, 42
    mov  al,  ' '
    clear_save_line4:
    call WriteChar
    loop clear_save_line4
    
    ; Prepare to save score: EAX = score, EDX = player name
    movzx eax, score             ; Get current score into EAX
    mov   edx, OFFSET PlayerName ; Get player name address
    call  AddScoreToLeaderboard  ; Add score to leaderboard and save
    
    ; Display saving message
    mov  dh,  2
    mov  dl,  73
    call Gotoxy
    mov  eax, yellow + (black * 16)
    call SetTextColor
    mov  edx, OFFSET savingMsg
    call WriteString
    
    ; Wait a moment then return to menu
    mov  eax, 1000
    call delay
    
    jmp pause_quit_to_menu ; Return to menu after saving
    
pause_quit_to_menu:
    ret

pause_exit:
    ; process 'p' (or other future normal keys) via storing and FlushKeys
    mov inputChar, al  ;assign variables (single-step movement)
    cmp inputChar, "p"
    je  exitgame
    jmp gameLoop

checkBottom: 	
    mov al, yPos[0]     ; Get current Y position
    inc al              ; Calculate: current Y + 1 (moving down)
    mov cl, yPosWall[3] ; Get bottom wall position (27)
    cmp al, cl          ; Compare next position with wall
    jae noMoveDown      ; If next Y >= 27 → hit wall, stop
    
    ; Check collision with building, box, or tree
    mov  dl, xPos[0] ; Next X position
    mov  dh, al      ; Next Y position
    call IsBuilding
    cmp  al, 1
    je   noMoveDown  ; Hit building, don't move
    mov  dl, xPos[0]
    mov  dh, [yPos]
    inc  dh          ; Next Y position
    call IsBox
    cmp  al, 1
    je   noMoveDown  ; Hit box, don't move
    mov  dl, xPos[0]
    mov  dh, [yPos]
    inc  dh          ; Next Y position
    call IsTree
    cmp  al, 1
    je   noMoveDown  ; Hit tree, don't move
    
    jmp moveDown ; All checks passed, safe to move down
    
noMoveDown:
    call ApplyPenalty
    jmp  gameLoop

checkLeft: 	
    mov al, xPos[0]     ; Get current X position
    dec al              ; Calculate: current X - 1 (moving left)
    mov cl, xPosWall[0] ; Get left wall position (10)
    cmp al, cl          ; Compare next position with wall
    jle noMoveLeft      ; If next X <= 10 → hit wall, stop
    
    ; Check collision with building, box, or tree
    mov  dl, al      ; Next X position
    mov  dh, yPos[0] ; Current Y position
    call IsBuilding
    cmp  al, 1
    je   noMoveLeft  ; Hit building, don't move
    mov  dl, [xPos]
    dec  dl          ; Next X position
    mov  dh, yPos[0]
    call IsBox
    cmp  al, 1
    je   noMoveLeft  ; Hit box, don't move
    mov  dl, [xPos]
    dec  dl          ; Next X position
    mov  dh, yPos[0]
    call IsTree
    cmp  al, 1
    je   noMoveLeft  ; Hit tree, don't move
    
    jmp moveLeft ; All checks passed, safe to move left
    
noMoveLeft:
    call ApplyPenalty
    jmp  gameLoop


checkRight: 	
    mov al, xPos[0]     ; Get current X position
    inc al              ; Calculate: current X + 1 (moving right)
    mov cl, xPosWall[2] ; Get right wall position (110)
    cmp al, cl          ; Compare next position with wall
    jae noMoveRight     ; If next X >= 110 → hit wall, stop
    
    ; Check collision with building, box, or tree
    mov  dl, al      ; Next X position
    mov  dh, yPos[0] ; Current Y position
    call IsBuilding
    cmp  al, 1
    je   noMoveRight ; Hit building, don't move
    mov  dl, [xPos]
    inc  dl          ; Next X position
    mov  dh, yPos[0]
    call IsBox
    cmp  al, 1
    je   noMoveRight ; Hit box, don't move
    mov  dl, [xPos]
    inc  dl          ; Next X position
    mov  dh, yPos[0]
    call IsTree
    cmp  al, 1
    je   noMoveRight ; Hit tree, don't move
    
    jmp moveRight ; All checks passed, safe to move right
    
noMoveRight:
    call ApplyPenalty
    jmp  gameLoop

checkTop: 	
    mov al, yPos[0]     ; Get current Y position
    dec al              ; Calculate: current Y - 1 (moving up)
    mov cl, yPosWall[0] ; Get top wall position (5)
    cmp al, cl          ; Compare next position with wall
    jle noMoveUp        ; If next Y <= 5 → hit wall, stop
    
    ; Check collision with building, box, or tree
    mov  dl, xPos[0] ; Current X position
    mov  dh, al      ; Next Y position
    call IsBuilding
    cmp  al, 1
    je   noMoveUp    ; Hit building, don't move
    mov  dl, xPos[0]
    mov  dh, [yPos]
    dec  dh          ; Next Y position
    call IsBox
    cmp  al, 1
    je   noMoveUp    ; Hit box, don't move
    mov  dl, xPos[0]
    mov  dh, [yPos]
    dec  dh          ; Next Y position
    call IsTree
    cmp  al, 1
    je   noMoveUp    ; Hit tree, don't move
    
    jmp moveUp ; All checks passed, safe to move up
    
noMoveUp:
    call ApplyPenalty
    jmp  gameLoop
		
		moveUp:		
		mov  eax, speed
		call delay          ; Pauses the game for the calculated time Without this delay, the car would move too fast to control 
        mov  esi, 0         ;index 0 (car)
		call UpdatePlayer
		dec  yPos[esi]      ; Move up (Y = Y - 1) 
        call DrawPlayer
        call DrawPassengers
        call DrawCoin
        jmp  checkcoin

		
		moveDown:                ;move down
		mov       eax, speed
		call      delay
		mov       esi, 0
		call      UpdatePlayer
		inc       yPos[esi]
        call      DrawPlayer
        call      DrawPassengers
        call      DrawCoin
        jmp       checkcoin


		moveLeft:                ;move left
		mov       eax, speed
		call      delay
		mov       esi, 0
		call      UpdatePlayer
		dec       xPos[esi]
        call      DrawPlayer
        call      DrawPassengers
        call      DrawCoin
        jmp       checkcoin


		moveRight:                ;move right
		mov        eax, speed
		call       delay
		mov        esi, 0
		call       UpdatePlayer
		inc        xPos[esi]
        call       DrawPlayer
        call       DrawPassengers
        call       DrawCoin
        jmp        checkcoin

    ; Post-move handling (coin check only for single-head car)
    checkcoin:
    
    cmp al, 1
    je  died
    
    
    cmp al, 1
    je  died
    
    ; Check NPC collision
    mov  dl, xPos[0]
    mov  dh, yPos[0]
    call CheckPlayerNPCCollision
    cmp  al, 1
    je   npc_collision
    
    ; Check if player reached coin position
    mov al, xPos[0]
    cmp al, xCoinPos
    jne no_eat
    mov al, yPos[0]
    cmp al, yCoinPos
    jne no_eat
    
    ; Only auto-eat coin if NOT carrying a passenger
    ; (If carrying, HandlePickupDrop will handle the delivery)
    cmp pickedUpPassenger, 1
    je  no_eat
    
    call EatingCoin
    jmp  gameLoop

    no_eat:
        jmp gameLoop
        
    npc_collision:
        call PenaltyHitCar
        jmp  gameLoop

time_is_up:
    mov  timeModeActive, 0 ; Deactivate time mode
    call YouDied           ; Time ran out - player dies
    jmp  playagn           ; Return to play again/menu

	died:
	call YouDied
	 
	playagn::			
	call ReinitializeGame ;reinitialise everything
	
	exitgame::
	exit
ret



; =============================================
; DrawWall - draws wall using box-drawing characters
; =============================================
DrawWall PROC
    ; Draw a box using box-drawing characters around the wall coordinates
    ; Top-left corner
    mov  dl, xPosWall[0]
    mov  dh, yPosWall[0]
    call Gotoxy
    mov  al, 201         ; ╔
    call WriteChar

    movzx eax, xPosWall[2] ; Right X coordinate
    movzx ebx, xPosWall[0] ; Left X coordinate
    sub   eax, ebx         ; Calculate width between walls
    sub   eax, 1           ; Account for corners
    mov   ecx, eax         ; Set loop counter
    mov   dl,  xPosWall[0] ; Start from left edge
    inc   dl               ; Move right one position (past corner)
draw_top:
    call Gotoxy
    mov  al, 205   ; ═
    call WriteChar
    inc  dl
    loop draw_top

    ; Top-right corner
    mov  dl, xPosWall[2]
    mov  dh, yPosWall[0]
    call Gotoxy
    mov  al, 187         ; ╗
    call WriteChar

    ; Draw vertical sides (rows) using BL as current row
    movzx eax, yPosWall[0]
    inc   al               ; The top horizontal line is already drawn at Y=5
    mov   bl,  al          ; BL becomes our current row counter
    movzx eax, yPosWall[3] ; movzx: Converts byte value 27 to 32-bit: EAX = 27
    dec   al               ; The bottom horizontal line will be drawn at Y=27
    mov   bh,  al          ; last row BH becomes our loop limit
draw_rows_loop:
    ; Left border at (xPosWall[0], bl)
    mov  dl, xPosWall[0]
    mov  dh, bl
    call Gotoxy
    mov  al, 186         ; ║
    call WriteChar

    ; Right border at (xPosWall[2], bl)
    mov  dl, xPosWall[2]
    mov  dh, bl
    call Gotoxy
    mov  al, 186         ; ║
    call WriteChar

    inc bl
    cmp bl, bh         ; cmp bl, bh: Compare BL (current row) with BH (last row = 26)
    jle draw_rows_loop ; jle: "Jump if Less or Equal"

    ; Bottom-left corner
    mov  dl, xPosWall[0]
    mov  dh, yPosWall[3]
    call Gotoxy
    mov  al, 200         ; ╚
    call WriteChar

    ; Bottom horizontal
    movzx eax, xPosWall[2]
    movzx ebx, xPosWall[0]
    sub   eax, ebx
    sub   eax, 1
    mov   ecx, eax
    mov   dl,  xPosWall[0]
    inc   dl
draw_bottom:
    call Gotoxy
    mov  al, 205     ; ═
    call WriteChar
    inc  dl
    loop draw_bottom

    ; Bottom-right corner
    mov  dl, xPosWall[2]
    mov  dh, yPosWall[3]
    call Gotoxy
    mov  al, 188         ; ╝
    call WriteChar

    ret
DrawWall      ENDP


    
; =============================================
; DrawBuildings - draws random building obstacles inside the game area
; =============================================
DrawBuildings PROC
    LOCAL buildingCount:BYTE  ; Number of buildings to generate
    LOCAL buildingX:BYTE      ; Top-left X position of building
    LOCAL buildingY:BYTE      ; Top-left Y position of building  
    LOCAL buildingWidth:BYTE  ; Width of building in blocks
    LOCAL buildingHeight:BYTE ; Height of building in blocks
    LOCAL i:BYTE              ; Loop counter for height
    LOCAL j:BYTE              ; Loop counter for width
    
    mov  eax, gray + (black * 16)
    call SetTextColor
    
    ; Initialize random seed
    call Randomize
    
    ; Generate random buildings
    mov  eax,           20
    call RandomRange
    add  al,            20
    mov  buildingCount, al
    
    ; Reset building counter
    mov buildingCountPlaced, 0
    
    movzx ecx, buildingCount ; Zero-extend byte to dword for loop counter
buildingLoop:
    push ecx ; Save loop counter since we'll use ECX for other purposes
    
    ; Generate random building position and size
    ; X position: between 11 and 100 (within walls 10-110)
    mov  eax,       80 ; 100-20 = 80 possible positions
    call RandomRange
    add  al,        20 ; 20 + (0-79) = 20-99
    mov  buildingX, al
    
    ; Y position: between 6 and 22 (within walls 5-27)
    mov  eax,       16 ; 22-6 = 16 possible positions
    call RandomRange
    add  al,        6  ; 6 + (0-15) = 6-21
    mov  buildingY, al
    
    ; Building width: 3-6 blocks
    mov  eax,           4  ; 0-3
    call RandomRange
    add  al,            3  ; 3-6 blocks wide
    mov  buildingWidth, al
    
    ; Building height: 2-4 blocks
    mov  eax,            3  ; 0-2
    call RandomRange
    add  al,             2  ; 2-4 blocks high
    mov  buildingHeight, al
    
    ; Check if total blocks > 5
    mov al, buildingWidth
    mul buildingHeight
    cmp ax, 5
    jg  drawBuilding      ; If > 5 blocks, draw it
    
    ; If too small, adjust to ensure > 5 blocks
    mov al, buildingWidth
    cmp al, 3
    jbe increaseWidth
    jmp checkHeight
    
increaseWidth:
    mov buildingWidth, 4
    
checkHeight:
    mov al, buildingHeight
    cmp al, 2
    jbe increaseHeight
    jmp drawBuilding
    
increaseHeight:
    mov buildingHeight, 3
    
drawBuilding:
    ; Store this building's position data
    mov esi, OFFSET buildingPositions

    ; Memory: [25, 8, 4, 2, ...]
    ;      ↑   ↑  ↑  ↑
    ;      X   Y  W  H  (bytes 0-3 for building #3)

    movzx eax, buildingCountPlaced
    imul eax, eax, 4  ; Each building uses 4 bytes: X, Y, width, height Multiply building count by 4
    add   esi, eax
    
    mov al,      buildingX
    mov [esi],   al             ; Store X position
    mov al,      buildingY
    mov [esi+1], al             ; Store Y position
    mov al,      buildingWidth
    mov [esi+2], al             ; Store width
    mov al,      buildingHeight
    mov [esi+3], al             ; Store height
    
    inc buildingCountPlaced ; Increment building counter

    ; Draw the building
    movzx ecx, buildingHeight ; Set up height loop
    mov   i,   0              ; Row counter
heightLoop:
    push  ecx
    movzx ecx, buildingWidth ; Set up width loop  
    mov   j,   0             ; Column counter
widthLoop:
        push ecx ; Saves the current value of ECX (width counter) onto the stack
        
        ; Calculate position
        mov dl, buildingX ; DL = building's leftmost X coordinate
        add dl, j         ; DL = buildingX + current column offset
        mov dh, buildingY ; DH = building's topmost Y coordinate
        add dh, i         ;  DH = buildingY + current row offset
        
        ; Check if within wall boundaries
        cmp dl, 10
        jle skipBlock
        cmp dl, 110
        jge skipBlock
        cmp dh, 5
        jle skipBlock
        cmp dh, 27
        jge skipBlock
        
        ; Draw the block
        call Gotoxy
        mov  al, 178
        call WriteChar
        
    skipBlock:
        pop  ecx
        inc  j
        loop widthLoop
    
    pop  ecx
    inc  i
    loop heightLoop
    
    pop ecx
    dec ecx
    jnz buildingLoop
    
    ; Reset to default color
    mov  eax, white + (black * 16)
    call SetTextColor
    
    ret
DrawBuildings ENDP




; =============================================
; IsBuilding - checks if a position contains ANY PART of a building
; Input: DL = X position, DH = Y position
; Returns: AL = 1 if building, AL = 0 if not building
; =============================================
IsBuilding    PROC
    ; Check if any buildings exist
    mov al, buildingCountPlaced
    cmp al, 0
    je  noBuilding
    
    ; Check each building
    mov   esi, OFFSET buildingPositions
    movzx ecx, buildingCountPlaced
    
checkLoop:
    ; Load building data
    mov al, [esi]   ; Building X (top-left)
    mov ah, [esi+1] ; Building Y (top-left)  
    mov bl, [esi+2] ; Building width
    mov bh, [esi+3] ; Building height
    
    ; Calculate building boundaries
    ; Left boundary = buildingX
    ; Right boundary = buildingX + width - 1
    ; Top boundary = buildingY  
    ; Bottom boundary = buildingY + height - 1
    
    ; Check if position X is within building's X range
    ; if (posX >= buildingX) AND (posX <= buildingX + width - 1)
    cmp dl, al
    jl  nextBuilding ; posX < buildingX → not in building
    
    push bx           ; Save width and height
    mov  bl, al       ; Copy buildingX to BL
    add  bl, [esi+2]  ; BL = buildingX + width
    dec  bl           ; BL = buildingX + width - 1 (right boundary)
    cmp  dl, bl
    pop  bx           ; Restore width and height
    jg   nextBuilding ; posX > right boundary → not in building
    
    ; Check if position Y is within building's Y range
    ; if (posY >= buildingY) AND (posY <= buildingY + height - 1)
    cmp dh, ah
    jl  nextBuilding ; posY < buildingY → not in building
    
    push bx           ; Save width and height
    mov  bl, ah       ; Copy buildingY to BL
    add  bl, [esi+3]  ; BL = buildingY + height
    dec  bl           ; BL = buildingY + height - 1 (bottom boundary)
    cmp  dh, bl
    pop  bx           ; Restore width and height
    jg   nextBuilding ; posY > bottom boundary → not in building
    
    ; If we get here, position is inside the building!
    mov al, 1
    ret
    
nextBuilding:
    add  esi, 4    ; Move to next building (4 bytes each)
    loop checkLoop
    
noBuilding:
    mov al, 0
    ret
IsBuilding            ENDP




; =============================================
; GenerateBoxesAndTrees - Generate 7 boxes and 7 trees
; =============================================
GenerateBoxesAndTrees PROC
    ; Generate 7 boxes
    mov ecx, 7
generate_boxes:
    push ecx
    
    ; Generate random X position (11-109) - inside walls
    mov  eax, 98     ; 109-11 = 98 (11 to 109 inclusive)
    call RandomRange
    add  al,  11
    mov  bl,  al     ; BL = box X
    
    ; Generate random Y position (6-26) - inside walls  
    mov  eax, 20     ; 26-6 = 20 (6 to 26 inclusive)
    call RandomRange
    add  al,  6
    mov  bh,  al     ; BH = box Y
    
    ; Store box position
    mov   esi, OFFSET boxPositions
    movzx eax, boxCount
    add   esi, eax
    add   esi, eax                 ; ×2 for X,Y pairs
    
    mov [esi],   bl ; Store X
    mov [esi+1], bh ; Store Y
    
    inc  boxCount
    pop  ecx
    loop generate_boxes
    
    ; Generate 7 trees
    mov ecx, 7
generate_trees:
    push ecx
    
    ; Generate random X position (11-109) - inside walls
    mov  eax, 98     ; 109-11 = 98 (11 to 109 inclusive)
    call RandomRange
    add  al,  11
    mov  bl,  al     ; BL = tree X
    
    ; Generate random Y position (6-26) - inside walls
    mov  eax, 20     ; 26-6 = 20 (6 to 26 inclusive)
    call RandomRange
    add  al,  6
    mov  bh,  al     ; BH = tree Y
    
    ; Store tree position
    mov   esi, OFFSET treePositions
    movzx eax, treeCount
    add   esi, eax
    add   esi, eax                  ; ×2 for X,Y pairs
    
    mov [esi],   bl ; Store X
    mov [esi+1], bh ; Store Y
    
    inc  treeCount
    pop  ecx
    loop generate_trees
    
    ret
GenerateBoxesAndTrees ENDP

; =============================================
; Draw boxes and trees
; =============================================
DrawBoxesAndTrees     PROC
    ; Draw boxes in gray
    mov  eax, gray + (black * 16)
    call SetTextColor
    
    mov   esi, OFFSET boxPositions
    movzx ecx, boxCount
    cmp   ecx, 0
    je    draw_trees
    
draw_boxes:
    mov  dl,  [esi]   ; X position
    mov  dh,  [esi+1] ; Y position
    call Gotoxy
    mov  al,  boxChar
    call WriteChar
    add  esi, 2
    loop draw_boxes

draw_trees:
    ; Draw trees in green
    mov  eax, green + (black * 16)
    call SetTextColor
    
    mov   esi, OFFSET treePositions
    movzx ecx, treeCount
    cmp   ecx, 0
    je    done_drawing
    
draw_trees_loop:
    mov  dl,  [esi]      ; X position
    mov  dh,  [esi+1]    ; Y position
    call Gotoxy
    mov  al,  treeChar
    call WriteChar
    add  esi, 2
    loop draw_trees_loop

done_drawing:
    ; Reset to default color
    mov  eax, white + (black * 16)
    call SetTextColor
    ret
DrawBoxesAndTrees ENDP



; =============================================
; CreatePassengers - creates 5 passenger positions with retry logic
; =============================================
CreatePassengers  PROC
    mov passengerCount, 0
    mov ecx,            5 ; Create 5 passengers

create_passenger_loop:
    push ecx    ; Save outer loop counter
    mov  edi, 0 ; Retry counter

try_generate:
    inc edi
    cmp edi, 50        ; Max 50 attempts per passenger
    jg  force_position ; If too many failures, force a position

    ; Generate random position
    call GenerateValidPosition
    jc   try_generate          ; If carry set, position invalid - try again

    ; Position is valid - store it
    mov   esi, OFFSET passengerPositions
    movzx eax, passengerCount
    shl   eax, 1                         ; Multiply by 2 (X,Y pairs)
    add   esi, eax
    
    mov [esi],   bl    ; Store X
    mov [esi+1], bh    ; Store Y
    inc passengerCount
    
    pop ecx
    dec ecx
    jnz create_passenger_loop
    ret

force_position:
    ; Force a position after too many failed attempts
    call  GenerateForcedPosition
    mov   esi, OFFSET passengerPositions
    movzx eax, passengerCount
    shl   eax, 1
    add   esi, eax
    
    mov [esi],   bl
    mov [esi+1], bh
    inc passengerCount
    
    pop ecx
    dec ecx
    jnz create_passenger_loop
    ret

CreatePassengers      ENDP

; =============================================
; GenerateValidPosition - generates a valid position for passenger
; Returns: BL = X, BH = Y, CF = 0 if valid, CF = 1 if invalid
; =============================================
GenerateValidPosition PROC
    ; Generate X between 11-109
    mov  eax, 99     ; 109-11+1 = 99
    call RandomRange
    add  al,  11
    mov  bl,  al

    ; Generate Y between 6-26
    mov  eax, 21     ; 26-6+1 = 21
    call RandomRange
    add  al,  6
    mov  bh,  al

    ; Check building collision
    mov  dl, bl
    mov  dh, bh
    call IsBuilding
    cmp  al, 1
    je   invalid_position

    ; Check box collision
    mov  dl, bl
    mov  dh, bh
    call IsBox
    cmp  al, 1
    je   invalid_position

    ; Check tree collision
    mov  dl, bl
    mov  dh, bh
    call IsTree
    cmp  al, 1
    je   invalid_position

    ; Check coin collision
    mov al, bl
    cmp al, xCoinPos
    jne check_player_collision
    mov al, bh
    cmp al, yCoinPos
    je  invalid_position

check_player_collision:
    ; Check player collision
    mov al, bl
    cmp al, xPos[0]
    jne check_existing_passengers
    mov al, bh
    cmp al, yPos[0]
    je  invalid_position

check_existing_passengers:
    ; Check if position overlaps with existing passengers
    mov   esi, OFFSET passengerPositions
    movzx ecx, passengerCount
    cmp   ecx, 0
    je    valid_position
    
check_passenger_loop:
    mov al, [esi]
    cmp al, bl
    jne next_passenger_check
    mov al, [esi+1]
    cmp al, bh
    je  invalid_position
    
next_passenger_check:
    add  esi, 2
    loop check_passenger_loop

valid_position:
    clc ; Clear carry flag = valid
    ret

invalid_position:
    stc ; Set carry flag = invalid
    ret
GenerateValidPosition  ENDP


; =============================================
; GenerateForcedPosition - generates a forced position when random fails
; Returns: BL = X, BH = Y
; Uses safe positions with increased spacing to avoid obstacles
; =============================================
GenerateForcedPosition PROC
    ; Use predefined positions that are guaranteed to be accessible
    ; Walls: X=11-109, Y=6-26
    ; These positions are spread out across the playable area
    
    movzx ecx, passengerCount
    cmp   ecx, 0
    jne   passenger_1
    ; Position 0: top-left area (X=25, Y=10)
    mov   bl,  25
    mov   bh,  10
    ret
    
passenger_1:
    cmp ecx, 1
    jne passenger_2
    ; Position 1: top-right area (X=95, Y=10)
    mov bl,  95
    mov bh,  10
    ret
    
passenger_2:
    cmp ecx, 2
    jne passenger_3
    ; Position 2: center area (X=60, Y=16)
    mov bl,  60
    mov bh,  16
    ret
    
passenger_3:
    cmp ecx, 3
    jne passenger_4
    ; Position 3: bottom-left area (X=25, Y=22)
    mov bl,  25
    mov bh,  22
    ret
    
passenger_4:
    ; Position 4: bottom-right area (X=95, Y=22)
    mov bl, 95
    mov bh, 22
    ret
GenerateForcedPosition ENDP

; =============================================
; DrawPassengers - draws waiting passengers only (picked up and delivered ones are hidden)
; =============================================
DrawPassengers         PROC
    ; Check if any passengers exist
    mov al, passengerCount
    cmp al, 0
    je  done_drawing_passengers
    
    ; Set color for passengers (magenta)
    mov  eax, magenta + (black * 16)
    call SetTextColor
    
    ; Draw only waiting passengers (state 0)
    mov   esi, OFFSET passengerPositions
    mov   edi, OFFSET passengerStates
    movzx ecx, passengerCount
    
draw_passengers_loop:
    ; Check if passenger is waiting (state 0)
    mov al, [edi]
    cmp al, 0
    jne skip_passenger_draw
    
    ; Draw waiting passenger
    mov  dl, [esi]         ; X position
    mov  dh, [esi+1]       ; Y position
    call Gotoxy
    mov  al, passengerChar ; 'P'
    call WriteChar

skip_passenger_draw:
    add  esi, 2
    inc  edi
    loop draw_passengers_loop

done_drawing_passengers:
    ; Reset to default color
    mov  eax, white + (black * 16)
    call SetTextColor
    ret
DrawPassengers ENDP










; =============================================
; IsBox - checks if a position contains a box
; Input: DL = X position, DH = Y position
; Returns: AL = 1 if box, AL = 0 if not box
; =============================================
IsBox          PROC
    ; Check if any boxes exist
    mov al, boxCount
    cmp al, 0
    je  noBox
    
    ; Check each box
    mov   esi, OFFSET boxPositions
    movzx ecx, boxCount
    
checkBoxLoop:
    mov al, [esi]   ; Box X
    mov ah, [esi+1] ; Box Y
    
    cmp dl, al  ; Compare X position
    jne nextBox
    cmp dh, ah  ; Compare Y position
    jne nextBox
    
    ; Position matches box
    mov al, 1
    ret
    
nextBox:
    add  esi, 2
    loop checkBoxLoop
    
noBox:
    mov al, 0
    ret
IsBox  ENDP

; =============================================
; IsTree - checks if a position contains a tree
; Input: DL = X position, DH = Y position
; Returns: AL = 1 if tree, AL = 0 if not tree
; =============================================
IsTree PROC
    ; Check if any trees exist
    mov al, treeCount
    cmp al, 0
    je  noTree
    
    ; Check each tree
    mov   esi, OFFSET treePositions
    movzx ecx, treeCount
    
checkTreeLoop:
    mov al, [esi]   ; Tree X
    mov ah, [esi+1] ; Tree Y
    
    cmp dl, al   ; Compare X position
    jne nextTree
    cmp dh, ah   ; Compare Y position
    jne nextTree
    
    ; Position matches tree
    mov al, 1
    ret
    
nextTree:
    add  esi, 2
    loop checkTreeLoop
    
noTree:
    mov al, 0
    ret
IsTree      ENDP

; =============================================
; IsPassenger - Check if waiting passenger at position (DL, DH)
; Input: DL = X position, DH = Y position
; Output: AL = 1 if passenger found, AL = 0 if not
; =============================================
IsPassenger PROC
    ; Check if any passengers exist
    mov al, passengerCount
    cmp al, 0
    je  noPassenger
    
    ; Check each passenger
    mov   esi, OFFSET passengerPositions
    mov   edi, OFFSET passengerStates
    movzx ecx, passengerCount
    
checkPassengerLoop:
    ; Only check waiting passengers (state 0)
    mov al, [edi]
    cmp al, 0
    jne nextPassenger
    
    mov al, [esi]   ; Passenger X
    mov ah, [esi+1] ; Passenger Y
    
    cmp dl, al        ; Compare X position
    jne nextPassenger
    cmp dh, ah        ; Compare Y position
    jne nextPassenger
    
    ; Position matches passenger
    mov al, 1
    ret
    
nextPassenger:
    add  esi, 2
    inc  edi
    loop checkPassengerLoop
    
noPassenger:
    mov al, 0
    ret
IsPassenger             ENDP

; =============================================
; CheckPlayerNPCCollision - Check if player collides with any NPC
; Input: DL = player X, DH = player Y
; Output: AL = 1 if collision with NPC, AL = 0 if no collision
; =============================================
CheckPlayerNPCCollision PROC
    ; Check NPC1
    cmp dl, npc1X
    jne check_npc2_collision
    cmp dh, npc1Y
    je  npc_collision_found
    
check_npc2_collision:
    ; Check NPC2
    cmp dl, npc2X
    jne check_npc3_collision
    cmp dh, npc2Y
    je  npc_collision_found
    
check_npc3_collision:
    ; Check NPC3
    cmp dl, npc3X
    jne no_npc_collision
    cmp dh, npc3Y
    je  npc_collision_found
    
no_npc_collision:
    mov al, 0
    ret
    
npc_collision_found:
    mov al, 1
    ret
CheckPlayerNPCCollision ENDP




; Example 1: Check if player is on a box
; mov dl, xPos[0]
; mov dh, yPos[0]
; call IsBox
; cmp al, 1
; je handleBoxCollision


; Example 2: Check if player is on a tree
; mov dl, xPos[0]
; mov dh, yPos[0]
; call IsTree
; cmp al, 1
; je handleTreeCollision


    























































































; =============================================
; DrawScoreboard - draws the scoreboard
; =============================================
DrawScoreboard          PROC
	mov  dl,  2
	mov  dh,  1
	call Gotoxy
	mov  edx, OFFSET strScore
	call WriteString
	
	; Clear old score area (3 spaces for any previous value)
	mov  al, ' '
	call WriteChar
	call WriteChar
	call WriteChar
	
	; Reposition cursor to display score
	mov  dl, 17
	mov  dh, 1
	call Gotoxy
	
	; Display score value
	movzx eax, score ; Load current score (0-255)
	call  WriteInt   ; Display as integer
	
	; Display passenger status
	mov  dl, 2
	mov  dh, 2
	call Gotoxy
	
	; Show current passenger being carried
	mov al, pickedUpPassenger
	cmp al, 1
	jne not_carrying
	
not_carrying:
passenger_display_done:
	ret
DrawScoreboard    ENDP

; =============================================
; UpdateTimeCounter - Uses system time for accurate timer
; =============================================
UpdateTimeCounter PROC
    ; Get current time in milliseconds
    call GetMseconds ; Returns time in EAX
    
    ; Calculate elapsed time: current - start
    sub eax,           timeStartMs
    mov timeElapsedMs, eax
    
    ; Calculate remaining time: 120000ms - elapsed
    mov eax, 120000        ; 2 minutes in milliseconds
    sub eax, timeElapsedMs
    
    ; If time is up or negative, set to 0
    cmp eax, 0
    jge time_valid
    mov eax, 0
    
time_valid:
    ; Convert milliseconds to seconds (divide by 1000)
    mov ebx, 1000
    xor edx, edx
    div ebx       ; EAX = seconds, EDX = remainder
    
    ; Store the display seconds
    mov displaySeconds, al
    
    ; Display the updated timer on screen (right bottom corner)
    mov  dl,  95                 ; Right side of screen (X position)
    mov  dh,  29                 ; Bottom of screen (Y position)
    call Gotoxy
    mov  edx, OFFSET strTimeLeft
    call WriteString
    
    ; Display time value
    movzx eax, displaySeconds
    call  WriteDec
    
    ; Clear any leftover digits by writing spaces
    mov  al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    
    ret
UpdateTimeCounter ENDP

; =============================================
; DrawPlayer    esi = index of player to draw
; =============================================
DrawPlayer        PROC ; draw player (taxi) at (xPos,yPos) in yellow
    call SetDynamicColor_WRY

    mov  dl, xPos[esi]
    mov  dh, yPos[esi]
    call Gotoxy
    mov  al, car
    call WriteChar

    ; restore white color
    mov  eax, white + (black * 16)
    call SetTextColor
    ret
DrawPlayer   ENDP




; =============================================
; UpdatePlayer - erase player at (xPos,yPos)  esi = index of player to erase 
; =============================================
UpdatePlayer PROC ; erase player at (xPos,yPos)
    mov  dl, xPos[esi]
    mov  dh, yPos[esi]
    call Gotoxy
    mov  al, " "
    call WriteChar
    ret
UpdatePlayer ENDP

; =============================================
; DrawNPCs - Draw all 3 NPC cars
; =============================================
DrawNPCs     PROC
    ; Draw NPC1
    mov  eax, magenta + (black * 16)
    call SetTextColor
    mov  dl,  npc1X
    mov  dh,  npc1Y
    call Gotoxy
    mov  al,  npcChar
    call WriteChar
    
    ; Draw NPC2
    mov  eax, brown + (black * 16)
    call SetTextColor
    mov  dl,  npc2X
    mov  dh,  npc2Y
    call Gotoxy
    mov  al,  npcChar
    call WriteChar
    
    ; Draw NPC3
    mov  eax, cyan + (black * 16)
    call SetTextColor
    mov  dl,  npc3X
    mov  dh,  npc3Y
    call Gotoxy
    mov  al,  npcChar
    call WriteChar
    
    ; Restore white color
    mov  eax, white + (black * 16)
    call SetTextColor
    ret
DrawNPCs  ENDP

; =============================================
; EraseNPCs - Erase all 3 NPC cars
; =============================================
EraseNPCs PROC
    ; Erase NPC1
    mov  dl, npc1X
    mov  dh, npc1Y
    call Gotoxy
    mov  al, ' '
    call WriteChar
    
    ; Erase NPC2
    mov  dl, npc2X
    mov  dh, npc2Y
    call Gotoxy
    mov  al, ' '
    call WriteChar
    
    ; Erase NPC3
    mov  dl, npc3X
    mov  dh, npc3Y
    call Gotoxy
    mov  al, ' '
    call WriteChar
    ret
EraseNPCs ENDP

; =============================================
; MoveNPCs - Move all 3 NPC cars
; =============================================
MoveNPCs  PROC
    ; Move NPC1
    call MoveNPC1
    
    ; Move NPC2
    call MoveNPC2
    
    ; Move NPC3
    call MoveNPC3
    ret
MoveNPCs                    ENDP

; =============================================
; Helper Procedures - Check if passenger at position
; =============================================

; CheckNPC1PassengerAtNextPos - Check if passenger at NPC1's next right position
; Returns: AL = 1 if passenger found, AL = 0 if not
CheckNPC1PassengerAtNextPos PROC
    mov ecx, 5
    mov esi, OFFSET passengerPositions
    mov edi, OFFSET passengerStates
    
check_npc1_next_loop:
    mov al, [edi]      ; Check passenger state
    cmp al, 0          ; Only check waiting passengers
    jne skip_npc1_next
    
    mov al, [esi]      ; Passenger X
    mov bl, npc1X
    inc bl             ; NPC1's next X position
    cmp al, bl
    jne skip_npc1_next
    
    mov al, [esi+1]          ; Passenger Y
    cmp al, npc1Y
    je  passenger_found_npc1 ; Found collision!
    
skip_npc1_next:
    add  esi, 2
    inc  edi
    loop check_npc1_next_loop
    
    mov al, 0 ; No passenger found
    ret
    
passenger_found_npc1:
    mov al, 1 ; Passenger found
    ret
CheckNPC1PassengerAtNextPos ENDP

; CheckNPC1PassengerAtPrevPos - Check if passenger at NPC1's next left position
CheckNPC1PassengerAtPrevPos PROC
    mov ecx, 5
    mov esi, OFFSET passengerPositions
    mov edi, OFFSET passengerStates
    
check_npc1_prev_loop:
    mov al, [edi]
    cmp al, 0
    jne skip_npc1_prev
    
    mov al, [esi]
    mov bl, npc1X
    dec bl             ; NPC1's previous X position
    cmp al, bl
    jne skip_npc1_prev
    
    mov al, [esi+1]
    cmp al, npc1Y
    je  passenger_found_npc1_prev
    
skip_npc1_prev:
    add  esi, 2
    inc  edi
    loop check_npc1_prev_loop
    
    mov al, 0
    ret
    
passenger_found_npc1_prev:
    mov al, 1
    ret
CheckNPC1PassengerAtPrevPos ENDP

; CheckNPC2PassengerAtNextPos - Check if passenger at NPC2's next down position
CheckNPC2PassengerAtNextPos PROC
    mov ecx, 5
    mov esi, OFFSET passengerPositions
    mov edi, OFFSET passengerStates
    
check_npc2_next_loop:
    mov al, [edi]
    cmp al, 0
    jne skip_npc2_next
    
    mov al, [esi]
    cmp al, npc2X
    jne skip_npc2_next
    
    mov al, [esi+1]
    mov bl, npc2Y
    inc bl                   ; NPC2's next Y position
    cmp al, bl
    je  passenger_found_npc2
    
skip_npc2_next:
    add  esi, 2
    inc  edi
    loop check_npc2_next_loop
    
    mov al, 0
    ret
    
passenger_found_npc2:
    mov al, 1
    ret
CheckNPC2PassengerAtNextPos ENDP

; CheckNPC2PassengerAtPrevPos - Check if passenger at NPC2's previous up position
CheckNPC2PassengerAtPrevPos PROC
    mov ecx, 5
    mov esi, OFFSET passengerPositions
    mov edi, OFFSET passengerStates
    
check_npc2_prev_loop:
    mov al, [edi]
    cmp al, 0
    jne skip_npc2_prev
    
    mov al, [esi]
    cmp al, npc2X
    jne skip_npc2_prev
    
    mov al, [esi+1]
    mov bl, npc2Y
    dec bl                        ; NPC2's previous Y position
    cmp al, bl
    je  passenger_found_npc2_prev
    
skip_npc2_prev:
    add  esi, 2
    inc  edi
    loop check_npc2_prev_loop
    
    mov al, 0
    ret
    
passenger_found_npc2_prev:
    mov al, 1
    ret
CheckNPC2PassengerAtPrevPos ENDP

; CheckNPC3PassengerAtNextPos - Check if passenger at NPC3's next left position
CheckNPC3PassengerAtNextPos PROC
    mov ecx, 5
    mov esi, OFFSET passengerPositions
    mov edi, OFFSET passengerStates
    
check_npc3_next_loop:
    mov al, [edi]
    cmp al, 0
    jne skip_npc3_next
    
    mov al, [esi]
    mov bl, npc3X
    dec bl             ; NPC3's next X position (moving left)
    cmp al, bl
    jne skip_npc3_next
    
    mov al, [esi+1]
    cmp al, npc3Y
    je  passenger_found_npc3
    
skip_npc3_next:
    add  esi, 2
    inc  edi
    loop check_npc3_next_loop
    
    mov al, 0
    ret
    
passenger_found_npc3:
    mov al, 1
    ret
CheckNPC3PassengerAtNextPos ENDP

; CheckNPC3PassengerAtPrevPos - Check if passenger at NPC3's previous right position
CheckNPC3PassengerAtPrevPos PROC
    mov ecx, 5
    mov esi, OFFSET passengerPositions
    mov edi, OFFSET passengerStates
    
check_npc3_prev_loop:
    mov al, [edi]
    cmp al, 0
    jne skip_npc3_prev
    
    mov al, [esi]
    mov bl, npc3X
    inc bl             ; NPC3's previous X position (moving right)
    cmp al, bl
    jne skip_npc3_prev
    
    mov al, [esi+1]
    cmp al, npc3Y
    je  passenger_found_npc3_prev
    
skip_npc3_prev:
    add  esi, 2
    inc  edi
    loop check_npc3_prev_loop
    
    mov al, 0
    ret
    
passenger_found_npc3_prev:
    mov al, 1
    ret
CheckNPC3PassengerAtPrevPos ENDP

; =============================================
; MoveNPC1 - Move NPC1 in fixed 15-step horizontal pattern
; Moves right 15 steps, then left 15 steps, repeat
; Speed: moves every 4 game loop cycles
; =============================================
MoveNPC1                    PROC
    ; Increment speed counter
    inc npc1MoveCounter
    cmp npc1MoveCounter, 220
    jne npc1_skip_move       ; Only move every 4 cycles
    mov npc1MoveCounter, 0   ; Reset counter
    
    ; Check move mode - NPC1 moves horizontally
    cmp npc1Direction, 1
    je  npc1_move_away   ; Moving away from start (right)
    jmp npc1_move_back   ; Moving back to start (left)

npc1_move_away:
    ; Check if reached 15 steps away
    cmp npc1StepCount, 15
    jge npc1_turn_back
    
    ; Check if can move right (respect walls and obstacles)
    mov al, npc1X
    inc al
    cmp al, 105        ; Right boundary check (110 - 5 buffer)
    jge npc1_turn_back
    
    ; Check for obstacles (building, box, tree)
    mov  dl, al
    mov  dh, npc1Y
    call IsBuilding
    cmp  al, 1
    je   npc1_turn_back
    mov  dl, npc1X
    inc  dl
    mov  dh, npc1Y
    call IsBox
    cmp  al, 1
    je   npc1_turn_back
    mov  dl, npc1X
    inc  dl
    mov  dh, npc1Y
    call IsTree
    cmp  al, 1
    je   npc1_turn_back
    
    ; Check for passenger collision BEFORE moving
    mov  dl, npc1X
    inc  dl
    mov  dh, npc1Y
    call IsPassenger
    cmp  al, 1
    je   npc1_turn_back ; If passenger ahead, turn back
    
    ; Move right
    inc npc1X
    inc npc1StepCount
    ret

npc1_turn_back:
    mov npc1Direction, 0 ; Change to moving back
    mov npc1StepCount, 0 ; Reset step counter
    ret

npc1_move_back:
    ; Check if returned to start
    cmp npc1StepCount, 15
    jge npc1_turn_forward
    
    ; Check if can move left
    mov al, npc1X
    dec al
    cmp al, 15            ; Left boundary check (10 + 5 buffer)
    jle npc1_turn_forward
    
    ; Check for obstacles
    mov  dl, al
    mov  dh, npc1Y
    call IsBuilding
    cmp  al, 1
    je   npc1_turn_forward
    mov  dl, npc1X
    dec  dl
    mov  dh, npc1Y
    call IsBox
    cmp  al, 1
    je   npc1_turn_forward
    mov  dl, npc1X
    dec  dl
    mov  dh, npc1Y
    call IsTree
    cmp  al, 1
    je   npc1_turn_forward
    
    ; Check for passenger collision BEFORE moving
    mov  dl, npc1X
    dec  dl
    mov  dh, npc1Y
    call IsPassenger
    cmp  al, 1
    je   npc1_turn_forward ; If passenger ahead, turn forward
    
    ; Move left
    dec npc1X
    inc npc1StepCount
    ret

npc1_turn_forward:
    mov npc1Direction, 1 ; Change to moving away
    mov npc1StepCount, 0 ; Reset step counter
    ret

npc1_skip_move:
    ret
MoveNPC1 ENDP

; =============================================
; MoveNPC2 - Move NPC2 in fixed 15-step vertical pattern
; Moves down 15 steps, then up 15 steps, repeat
; Speed: moves every 5 game loop cycles
; =============================================
MoveNPC2 PROC
    ; Increment speed counter
    inc npc2MoveCounter
    cmp npc2MoveCounter, 220
    jne npc2_skip_move       ; Only move every 5 cycles
    mov npc2MoveCounter, 0   ; Reset counter
    
    ; Check move mode - NPC2 moves vertically
    cmp npc2Direction, 1
    je  npc2_move_away   ; Moving away from start (down)
    jmp npc2_move_back   ; Moving back to start (up)

npc2_move_away:
    ; Check if reached 15 steps away
    cmp npc2StepCount, 15
    jge npc2_turn_back
    
    ; Check if can move down (respect walls and obstacles)
    mov al, npc2Y
    inc al
    cmp al, 25         ; Bottom boundary check (27 - 2 buffer)
    jge npc2_turn_back
    
    ; Check for obstacles
    mov  dl, npc2X
    mov  dh, al
    call IsBuilding
    cmp  al, 1
    je   npc2_turn_back
    mov  dl, npc2X
    mov  dh, npc2Y
    inc  dh
    call IsBox
    cmp  al, 1
    je   npc2_turn_back
    mov  dl, npc2X
    mov  dh, npc2Y
    inc  dh
    call IsTree
    cmp  al, 1
    je   npc2_turn_back
    
    ; Check for passenger collision BEFORE moving
    mov  dl, npc2X
    mov  dh, npc2Y
    inc  dh
    call IsPassenger
    cmp  al, 1
    je   npc2_turn_back ; If passenger ahead, turn back
    
    ; Move down
    inc npc2Y
    inc npc2StepCount
    ret

npc2_turn_back:
    mov npc2Direction, 0 ; Change to moving back
    mov npc2StepCount, 0 ; Reset step counter
    ret

npc2_move_back:
    ; Check if returned to start
    cmp npc2StepCount, 15
    jge npc2_turn_forward
    
    ; Check if can move up
    mov al, npc2Y
    dec al
    cmp al, 8             ; Top boundary check (5 + 3 buffer)
    jle npc2_turn_forward
    
    ; Check for obstacles
    mov  dl, npc2X
    mov  dh, al
    call IsBuilding
    cmp  al, 1
    je   npc2_turn_forward
    mov  dl, npc2X
    mov  dh, npc2Y
    dec  dh
    call IsBox
    cmp  al, 1
    je   npc2_turn_forward
    mov  dl, npc2X
    mov  dh, npc2Y
    dec  dh
    call IsTree
    cmp  al, 1
    je   npc2_turn_forward
    
    ; Check for passenger collision BEFORE moving
    mov  dl, npc2X
    mov  dh, npc2Y
    dec  dh
    call IsPassenger
    cmp  al, 1
    je   npc2_turn_forward ; If passenger ahead, turn forward
    
    ; Move up
    dec npc2Y
    inc npc2StepCount
    ret

npc2_turn_forward:
    mov npc2Direction, 1 ; Change to moving away
    mov npc2StepCount, 0 ; Reset step counter
    ret

npc2_skip_move:
    ret
MoveNPC2 ENDP

; =============================================
; MoveNPC3 - Move NPC3 in fixed 15-step horizontal pattern
; Moves left 15 steps, then right 15 steps, repeat
; Speed: moves every 4 game loop cycles
; =============================================
MoveNPC3 PROC
    ; Increment speed counter
    inc npc3MoveCounter
    cmp npc3MoveCounter, 220
    jne npc3_skip_move       ; Only move every 4 cycles
    mov npc3MoveCounter, 0   ; Reset counter
    
    ; Check move mode - NPC3 moves horizontally
    cmp npc3Direction, 1
    je  npc3_move_away   ; Moving away from start (left)
    jmp npc3_move_back   ; Moving back to start (right)

npc3_move_away:
    ; Check if reached 15 steps away
    cmp npc3StepCount, 15
    jge npc3_turn_back
    
    ; Check if can move left (respect walls and obstacles)
    mov al, npc3X
    dec al
    cmp al, 15         ; Left boundary check
    jle npc3_turn_back
    
    ; Check for obstacles
    mov  dl, al
    mov  dh, npc3Y
    call IsBuilding
    cmp  al, 1
    je   npc3_turn_back
    mov  dl, npc3X
    dec  dl
    mov  dh, npc3Y
    call IsBox
    cmp  al, 1
    je   npc3_turn_back
    mov  dl, npc3X
    dec  dl
    mov  dh, npc3Y
    call IsTree
    cmp  al, 1
    je   npc3_turn_back
    
    ; Check for passenger collision BEFORE moving
    mov  dl, npc3X
    dec  dl
    mov  dh, npc3Y
    call IsPassenger
    cmp  al, 1
    je   npc3_turn_back ; If passenger ahead, turn back
    
    ; Move left
    dec npc3X
    inc npc3StepCount
    ret

npc3_turn_back:
    mov npc3Direction, 0 ; Change to moving back
    mov npc3StepCount, 0 ; Reset step counter
    ret

npc3_move_back:
    ; Check if returned to start
    cmp npc3StepCount, 15
    jge npc3_turn_forward
    
    ; Check if can move right
    mov al, npc3X
    inc al
    cmp al, 105           ; Right boundary check
    jge npc3_turn_forward
    
    ; Check for obstacles
    mov  dl, al
    mov  dh, npc3Y
    call IsBuilding
    cmp  al, 1
    je   npc3_turn_forward
    mov  dl, npc3X
    inc  dl
    mov  dh, npc3Y
    call IsBox
    cmp  al, 1
    je   npc3_turn_forward
    mov  dl, npc3X
    inc  dl
    mov  dh, npc3Y
    call IsTree
    cmp  al, 1
    je   npc3_turn_forward
    
    ; Check for passenger collision BEFORE moving
    mov  dl, npc3X
    inc  dl
    mov  dh, npc3Y
    call IsPassenger
    cmp  al, 1
    je   npc3_turn_forward ; If passenger ahead, turn forward
    
    ; Move right
    inc npc3X
    inc npc3StepCount
    ret

npc3_turn_forward:
    mov npc3Direction, 1 ; Change to moving away
    mov npc3StepCount, 0 ; Reset step counter
    ret

npc3_skip_move:
    ret
MoveNPC3        ENDP




; =============================================
; DrawDestination - draws destination at (xCoinPos,yCoinPos)
; GREEN color with "D" symbol
; =============================================
DrawDestination PROC
    mov  eax, green + (black * 16)
    call SetTextColor
    mov  dl,  xCoinPos
    mov  dh,  yCoinPos
    call Gotoxy
    mov  al,  "D"                  ; D for destination
    call WriteChar
    mov  eax, white + (black * 16)
    call SetTextColor
    ret
DrawDestination ENDP

; =============================================
; DrawBonusPoint - draws bonus point at (xCoinPos,yCoinPos)
; BLUE color with "*" symbol
; =============================================
DrawBonusPoint  PROC
    mov  eax, blue + (blue * 16)
    call SetTextColor
    mov  dl,  xCoinPos
    mov  dh,  yCoinPos
    call Gotoxy
    mov  al,  "*"                  ; * for bonus point
    call WriteChar
    mov  eax, white + (black * 16)
    call SetTextColor
    ret
DrawBonusPoint ENDP

; =============================================
; DrawCoin - draws destination or bonus point based on passenger status
; GREEN destination when passenger picked up, BLUE bonus point otherwise
; =============================================
DrawCoin       PROC
    ; Check if carrying a passenger - if so, draw destination in green
    cmp pickedUpPassenger, 1
    je  draw_destination_call
    
    ; No passenger - draw bonus point in blue
    call DrawBonusPoint
    ret

draw_destination_call:
    call DrawDestination
    ret
DrawCoin         ENDP



; =============================================
; ` - creates random coin position
; =============================================
CreateRandomCoin PROC ;procedure to create a random coin
    ; Generate X between (xPosWall[0]+1) .. (xPosWall[2]-1)
    movzx ecx,      xPosWall[2] ; Right wall X (e.g., 110)         
    movzx ebx,      xPosWall[0] ; Left wall X (e.g., 10)
    mov   eax,      ecx
    sub   eax,      ebx         ; 110 - 10 = 100 (total width)
    sub   eax,      1           ; 100 - 1 = 99 (account for corners)1
    dec   eax                   ; 99 - 1 = 98 (for RandomRange: 0..98)
    call  RandomRange           ; Returns 0-98 in EAX
    add   eax,      ebx         ; Add left wall: 10 + (0-98) = 10-108
    inc   eax                   ; 11-109 (ensure inside walls)
    mov   xCoinPos, al          ; Store final X position

    ; Generate Y between (yPosWall[0]+1) .. (yPosWall[3]-1)
    movzx ecx,      yPosWall[3] ; Bottom wall Y (e.g., 27)
    movzx ebx,      yPosWall[0] ; Top wall Y (e.g., 5)
    mov   eax,      ecx
    sub   eax,      ebx         ; 27 - 5 = 22 (total height)
    sub   eax,      1           ; 22 - 1 = 21 (account for corners)
    dec   eax                   ; 21 - 1 = 20 (for RandomRange: 0..20)
    call  RandomRange           ; Returns 0-20 in EAX
    add   eax,      ebx         ; Add top wall: 5 + (0-20) = 5-25
    inc   eax                   ; 6-26 (ensure inside walls)
    mov   yCoinPos, al          ; Store final Y position


; --- Ensure coin is not inside a building ---
    mov  dl, xCoinPos     ; DL = coin X
    mov  dh, yCoinPos     ; DH = coin Y
    call IsBuilding       ; AL = 1 if inside a building
    cmp  al, 1
    je   CreateRandomCoin ; regenerate if coin is inside a building


    mov ecx, 1 ; ECX = 1 (single-segment car)
    mov esi, 0
checkCoinXPos:
    movzx eax, xCoinPos
    cmp   al,  xPos[esi] ; Compare coin X with car segment X position
    je    checkCoinYPos  ;jump if xPos of car at esi = xPos of coin
continueloop:
    inc  esi           ; Move to next car segment (but there's only one!)
    loop checkCoinXPos ; Decrement ECX and loop (ECX becomes 0, loop exits)
    ret                ; Return when coin doesn't overlap with car
checkCoinYPos:
    movzx eax, yCoinPos    ; Load coin Y position
    cmp   al,  yPos[esi]   ; Compare coin Y with car segment Y position
    jne   continueloop     ; If Y doesn't match, continue to next segment (but there are no more!)
    call  CreateRandomCoin ; coin generated on car, calling function again to create another set of coordinates
CreateRandomCoin ENDP



; =============================================
; HandlePickupDrop - spacebar handler for pickup/drop passengers
; =============================================
HandlePickupDrop PROC
    cmp pickedUpPassenger, 1
    je  try_dropoff          ; If carrying, try to drop
    
try_pickup:
    ; Try to pick up a passenger at current position
    mov esi, OFFSET passengerPositions
    mov edi, OFFSET passengerStates
    mov ecx, 5
    mov ebx, 0                         ; Passenger index
    
check_pickup_loop:
    ; Check if passenger is waiting (state 0)
    mov al, [edi]
    cmp al, 0
    jne next_pickup_check
    
    ; Check if player is at passenger location
    mov al, xPos[0]
    cmp al, [esi]
    jne next_pickup_check
    
    mov al, yPos[0]
    cmp al, [esi+1]
    jne next_pickup_check
    
    ; Player is at passenger - PICKUP!
    mov [edi],             BYTE ptr 1 ; Mark passenger as picked up (state 1)
    mov currentPassenger,  bl         ; Store passenger index
    mov pickedUpPassenger, 1          ; Flag: carrying passenger
    
    ; Erase passenger from screen
    mov  dl, [esi]
    mov  dh, [esi+1]
    call Gotoxy
    mov  al, ' '
    call WriteChar
    
    ; Generate destination at coin position
    call CreateRandomCoin
    
    ; Redraw destination marker (green D)
    call DrawDestination
    ret
    
next_pickup_check:
    add  esi, 2
    inc  edi
    inc  ebx
    loop check_pickup_loop
    ret

try_dropoff:
    ; Check if player is at coin position (destination)
    mov al, xPos[0]
    cmp al, xCoinPos
    jne drop_not_at_dest
    
    mov al, yPos[0]
    cmp al, yCoinPos
    jne drop_not_at_dest
    
    ; Player is at destination - DROPOFF!
    mov al, currentPassenger
    cmp al, 255
    je  drop_not_at_dest
    
    ; Erase destination 'D' from screen
    mov  dl, xCoinPos
    mov  dh, yCoinPos
    call Gotoxy
    mov  al, ' '
    call WriteChar
    
    ; Mark passenger as delivered (state 2)
    movzx eax,   currentPassenger
    mov   edi,   OFFSET passengerStates
    add   edi,   eax
    mov   [edi], BYTE ptr 2
    
    ; Award points
    add score, 10
    
    ; Update display
    call DrawScoreboard
    
    ; Clear pickup state - ready for next passenger
    mov pickedUpPassenger, 0
    mov currentPassenger,  255
    
    ; If in time mode, increment delivery count
    cmp timeModeActive, 1
    jne check_all_passengers
    
    inc deliveredCount
    
    ; Check if we've delivered the required number in time mode
    cmp deliveredCount, 4
    jl  check_all_passengers
    
    ; Time mode: 4 passengers delivered - WIN!
    mov  timeModeActive, 0
    call DisplayTimeModeLevelComplete
    jmp  drop_not_at_dest
    
check_all_passengers:
    ; Check if ALL passengers are delivered (all have state 2) - for career/endless mode
    call CheckAllPassengersDelivered
    cmp  al, 1
    jne  next_passenger_ready
    
    ; All passengers delivered - reset for next round
    call ResetAllPassengers
    call CreatePassengers   ; Create new set of passengers
    call DrawPassengers     ; Draw all waiting passengers
    jmp  drop_not_at_dest
    
next_passenger_ready:
    ; Some passengers still waiting - redraw them
    call DrawPassengers
    
drop_not_at_dest:
    ret
HandlePickupDrop            ENDP

; =============================================
; CheckAllPassengersDelivered - checks if all passengers are delivered
; Returns: AL = 1 if all delivered, AL = 0 if not
; =============================================
CheckAllPassengersDelivered PROC
    mov esi, OFFSET passengerStates
    mov ecx, 5
    
check_all_loop:
    mov  al, [esi]
    cmp  al, 2             ; Check if passenger is delivered
    jne  not_all_delivered
    inc  esi
    loop check_all_loop
    
    ; All passengers are delivered
    mov al, 1
    ret
    
not_all_delivered:
    mov al, 0
    ret
CheckAllPassengersDelivered ENDP

; =============================================
; ResetAllPassengers - resets all passengers to waiting state
; =============================================
ResetAllPassengers          PROC
    mov esi, OFFSET passengerStates
    mov ecx, 5
    
reset_loop:
    mov  [esi], BYTE ptr 0 ; Set state to waiting (0)
    inc  esi
    loop reset_loop
    ret
ResetAllPassengers ENDP


; =============================================
; EatingCoin - handles when car eats bonus point (not carrying passenger)
; =============================================
EatingCoin         PROC
    ; car is eating bonus coin - increase score and respawn coin
    add  score, 10
    call CreateRandomCoin
    
    ; Redraw the new bonus point
    call DrawBonusPoint
    
    ; Update scoreboard display
    call DrawScoreboard
    ret
EatingCoin                   ENDP




; =============================================
; DisplayTimeModeLevelComplete - handles when player completes time mode
; =============================================
DisplayTimeModeLevelComplete PROC
	mov  eax, 1000
	call delay
	Call ClrScr
	
	mov  dl,  50
	mov  dh,  12
	call Gotoxy
	mov  edx, OFFSET strLevelComplete
	call WriteString

	mov  dl,  50
	mov  dh,  14
	call Gotoxy
	mov  edx, OFFSET str4PassengersDelivered
	call WriteString

	mov   dl,  56
	mov   dh,  16
	call  Gotoxy
	mov   edx, OFFSET strYourScore
	call  WriteString
	movzx eax, score
	call  WriteInt
	mov   edx, OFFSET strPoints
	call  WriteString

	mov  dl,  50
	mov  dh,  20
	call Gotoxy
	mov  edx, OFFSET strTryAgain
	call WriteString

	retry_time:
	mov  dh, 21
	mov  dl, 56
	call Gotoxy
	call ReadInt
	cmp  al, 1
	je   playagn
	cmp  al, 0
	je   exitgame

	mov  dh,  19
	call Gotoxy
	mov  edx, OFFSET invalidInput
	call WriteString
	mov  dl,  56
	mov  dh,  21
	call Gotoxy
	mov  edx, OFFSET blank
	call WriteString
	jmp  retry_time
DisplayTimeModeLevelComplete ENDP

; =============================================
; YouDied - handles when player dies
; =============================================
YouDied                      PROC
	mov  eax, 1000
	call delay
	Call ClrScr
	
	mov  dl,  57
	mov  dh,  12
	call Gotoxy
	mov  edx, OFFSET strYouDied ;"you died"
	call WriteString

	mov   dl,  56
	mov   dh,  14
	call  Gotoxy
	movzx eax, score
	call  WriteInt
	mov   edx, OFFSET strPoints ;display score
	call  WriteString

	mov  dl,  50
	mov  dh,  18
	call Gotoxy
	mov  edx, OFFSET strTryAgain
	call WriteString             ;"try again?"

	retry:
	mov  dh, 19
	mov  dl, 56
	call Gotoxy
	call ReadInt  ;get user input
	cmp  al, 1
	je   playagn  ;playagn
	cmp  al, 0
	je   exitgame ;exitgame

	mov  dh,  17
	call Gotoxy
	mov  edx, OFFSET invalidInput ;"Invalid input"
	call WriteString
	mov  dl,  56
	mov  dh,  19
	call Gotoxy
	mov  edx, OFFSET blank        ;erase previous input
	call WriteString
	jmp  retry                    ;let user input again
YouDied   ENDP



; =============================================
; ReinitializeGame - resets game state for a new game
; =============================================
; =============================================
; SCORING SYSTEM - COMPLETE REBUILD
; Uses UserColourChoice: 1=Red Taxi, 2=Yellow Taxi
; =============================================

; AddPoints - Award positive points for deliveries/bonuses
; Input: AL = points to add
; Ensures score doesn't exceed 255
AddPoints PROC
    movzx ecx,   score ; Load current score into ECX
    add   ecx,   eax   ; Add points
    cmp   ecx,   255   ; Check if exceeds max
    jle   add_ok
    mov   score, 255   ; Cap at 255
    jmp   add_done
add_ok:
    mov score, cl ; Store new score
add_done:
    call DrawScoreboard
    ret
AddPoints      ENDP

; SubtractPoints - Deduct negative points for collisions
; Input: AL = points to subtract
; Ensures score doesn't go below 0
SubtractPoints PROC
    movzx ecx,   score ; Load current score
    cmp   ecx,   eax   ; Compare score with penalty
    jl    sub_to_zero  ; If score < penalty, set to 0
    sub   ecx,   eax   ; Otherwise subtract
    mov   score, cl    ; Store result
    jmp   sub_done
sub_to_zero:
    mov score, 0 ; Set to 0
sub_done:
    call DrawScoreboard
    ret
SubtractPoints         ENDP

; AwardPassengerDelivery - Award +10 points for passenger delivery
AwardPassengerDelivery PROC
    mov  al, 10
    call AddPoints
    ret
AwardPassengerDelivery ENDP

; PenaltyHitObstacle - Red/Yellow taxi hits obstacle (tree/box/building)
; Checks UserColourChoice: 1=Red (-2), 2=Yellow (-4)
PenaltyHitObstacle     PROC
    cmp UserColourChoice, 1
    je  penalty_red_obstacle
    ; Default to yellow
    mov al,               4    ; Yellow taxi: -4 points
    jmp apply_obstacle_penalty
penalty_red_obstacle:
    mov al, 2 ; Red taxi: -2 points
apply_obstacle_penalty:
    call SubtractPoints
    ret
PenaltyHitObstacle ENDP

; PenaltyHitCar - Red/Yellow taxi hits another car
; Checks UserColourChoice: 1=Red (-3), 2=Yellow (-2)
PenaltyHitCar      PROC
    cmp UserColourChoice, 1
    je  penalty_red_car
    ; Default to yellow
    mov al,               2 ; Yellow taxi: -2 points
    jmp apply_car_penalty
penalty_red_car:
    mov al, 3 ; Red taxi: -3 points
apply_car_penalty:
    call SubtractPoints
    ret
PenaltyHitCar    ENDP

; PenaltyHitPerson - Any taxi hits pedestrian: -5 points
PenaltyHitPerson PROC
    mov  al, 5
    call SubtractPoints
    ret
PenaltyHitPerson     ENDP

; PenaltyWallCollision - Any taxi hits wall: -1 point
PenaltyWallCollision PROC
    cmp  score, 0
    je   no_wall_penalty ; Don't go below 0
    mov  al,    1
    call SubtractPoints
no_wall_penalty:
    ret
PenaltyWallCollision ENDP

ReinitializeGame     PROC
    ; ===== Player State =====
    mov xPos[0], 11
    mov yPos[0], 6
    
    ; ===== Game Variables =====
    mov score,     0
    mov inputChar, "+"
    mov speed,     0
    
    ; ===== Passenger System =====
    call ResetAllPassengers     ; Reset all passenger states to waiting
    mov  currentPassenger,  255 ; No passenger being carried
    mov  pickedUpPassenger, 0   ; Not carrying anyone
    mov  passengerCount,    0   ; No passengers counted yet
    
    ; ===== Coin/Bonus Position =====
    mov xCoinPos, 0
    mov yCoinPos, 0
    
    ; ===== Buildings & Obstacles =====
    mov boxCount,            0
    mov treeCount,           0
    mov buildingCountPlaced, 0
    
    ; Clear box positions array
    mov esi, OFFSET boxPositions
    mov ecx, 14
    xor al,  al
clear_boxes:
    mov  [esi], al
    inc  esi
    loop clear_boxes
    
    ; Clear tree positions array
    mov esi, OFFSET treePositions
    mov ecx, 14
    xor al,  al
clear_trees:
    mov  [esi], al
    inc  esi
    loop clear_trees
    
    ; Clear building positions array
    mov esi, OFFSET buildingPositions
    mov ecx, 200
    xor al,  al
clear_buildings:
    mov  [esi], al
    inc  esi
    loop clear_buildings
    
    ; ===== NPC Car 1 - Reset to start position and state =====
    mov npc1X,           30
    mov npc1Y,           10
    mov npc1StartX,      30
    mov npc1StartY,      10
    mov npc1Direction,   1
    mov npc1StepCount,   0
    mov npc1MoveCounter, 0
    mov npc1MoveMode,    1
    
    ; ===== NPC Car 2 - Reset to start position and state =====
    mov npc2X,           60
    mov npc2Y,           12
    mov npc2StartX,      60
    mov npc2StartY,      12
    mov npc2Direction,   1
    mov npc2StepCount,   0
    mov npc2MoveCounter, 0
    mov npc2MoveMode,    2
    
    ; ===== NPC Car 3 - Reset to start position and state =====
    mov npc3X,           90
    mov npc3Y,           18
    mov npc3StartX,      90
    mov npc3StartY,      18
    mov npc3Direction,   1
    mov npc3StepCount,   0
    mov npc3MoveCounter, 0
    mov npc3MoveMode,    1
    
    ; ===== Time Mode Variables =====
    mov displaySeconds, 120
    mov timeStartMs,    0
    mov timeElapsedMs,  0
    
    ; ===== Pause State =====
    mov isPaused, 0
    
    Call ClrScr
    jmp  main
ReinitializeGame ENDP


END              main


; irvine32 functions that are not in the https://csc.csudh.edu/mmccullough/asm/help/index.html?page=source%2Fabout.htm

; Gotoxy is a procedure from the Irvine32 library that positions the cursor at specific coordinates on the console screen.
; mov  dl, column   ; X coordinate (0-based, left to right)
; mov  dh, row      ; Y coordinate (0-based, top to bottom)  
; call Gotoxy       ; Position cursor