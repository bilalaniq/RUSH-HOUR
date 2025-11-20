.386
.model        flat,                                         stdcall
.stack        4096

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


xWall         BYTE 52 DUP("#"),                             0

strScore      BYTE "Your score is: ",                       0
score         BYTE 0

strTryAgain   BYTE "Try Again?  1=yes, 0=no",               0
invalidInput  BYTE "invalid input",                         0
strYouDied    BYTE "you died ",                             0
strPoints     BYTE " point(s)",                             0
blank         BYTE "                                     ", 0

; Represent the snake using only 'x' characters (single char per segment)
snake         BYTE 200 DUP('x')


;xPos BYTE 45,44,43,42,41, 100 DUP(?)
;yPos BYTE 15,15,15,15,15, 100 DUP(?)

xPos BYTE 15,14,13,12,11, 100 DUP(?)  ; Start at left boundary (X=11)
yPos BYTE 15,15,15,15,15, 100 DUP(?)

; Widened wall coordinates: increased right side X from 85 -> 96
xPosWall BYTE 10,10,110,110			;position of upperLeft, lowerLeft, upperRight, lowerRignt wall 
yPosWall BYTE 5,27,5,27

xCoinPos      BYTE ?
yCoinPos      BYTE ?

inputChar     BYTE "+"                                                   ; + denotes the start of the game
lastInputChar BYTE ?

strSpeed      BYTE "Speed (1-fast, 2-medium, 3-slow): ",    0
speed         DWORD 0










    legendMsg BYTE "Legend: P=Passenger  T=Taxi  C=Car  ▓=Building", 0
            
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


    ; Board dimensions
    BOARD_WIDTH  = 20
    BOARD_HEIGHT = 20


    ROAD_CHAR      BYTE ' ', 0 ; Empty road
    BUILDING_CHAR  BYTE 178, 0 ; ASCII 178 for buildings 
    TAXI_CHAR      BYTE 'T', 0 ; taxi
    PASSENGER_CHAR BYTE 'P', 0 ; Passenger
    CAR_CHAR       BYTE 'C', 0 ; Other cars
    OBSTACLE_CHAR  BYTE '#', 0 ; Obstacles


    
    
    
    

    ; Board display messages
    boardTitle BYTE "=== RUSH HOUR GAME BOARD ===",                                     0
    testMsg    BYTE "Board displayed successfully! Press any key to return to menu...", 0



    
    ; Error messages
    invalidChoice   BYTE "Invalid choice!",                         0
    pressAnyKey     BYTE "Press any key to continue...",            0
    invalidNameSize BYTE "The name cannot be longer than 19 words", 0

    nameAcceptedMsg BYTE "Name accepted successfully!", 0
    tryAgainMsg     BYTE "Please try again.",           0
    
    ; Current selection
    userChoice       BYTE ?
    fileHandle       HANDLE ?
    UserColourChoice BYTE ?
    PlayerNameLength BYTE ?
    
    ; Missing newGameMsg definition - adding it
    newGameMsg BYTE "*** START NEW GAME ***",0Dh,0Ah
               BYTE "This will start a new game...", 0
               
    continueMsg BYTE "*** CONTINUE GAME ***",0Dh,0Ah
                BYTE "Loading saved game...", 0
                
    difficultyMsg BYTE "*** DIFFICULTY LEVEL ***",0Dh,0Ah
                  BYTE "Easy, Medium, Hard options...", 0
                  
    leaderboardMsg BYTE "***No LEADERBOARD Record Yet***",0Dh,0Ah
                   BYTE "NO Leaderboard record be the first one to register :)", 0
                   
    instructionsMsg BYTE "*** INSTRUCTIONS ***",0Dh,0Ah
                    BYTE "Game rules and controls...", 0
                    
    exitMsg BYTE "*** EXIT GAME ***",0Dh,0Ah
            BYTE "Thank you for playing Rush Hour!",0Dh,0Ah
            BYTE "Goodbye!", 0

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
    ;call SelectTaxiScreen
    ;call start_game
    call Clrscr
    call DrawWall			;draw walls
	call DrawScoreboard		;draw scoreboard
	call ChooseSpeed		;let player to choose Speed

    jmp drawSnake		;start the game flow (draw snake and enter game loop)
    
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
    jmp  name_screen

not_three:
    mov UserColourChoice, al

name_screen:
    call EnterPlayer_Name
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
EnterPlayer_Name  ENDP





; =============================================
; LeaderboardScreen
; =============================================
LeaderboardScreen PROC
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
    push eax
    push edx
    
    cmp LeaderBoardCount, 10
    jb  add_new_score

    ; Check if new score is higher than lowest score
    mov esi, 9
    mov eax, esi
    mov ecx, 4
    mul ecx
    mov ebx, OFFSET LeaderBoardScores
    add ebx, eax                      ; EBX = address of score[9]
    mov ecx, [ebx]                    ; ECX = lowest score value
    
    ; Restore and compare
    pop  edx
    pop  eax
    push eax
    push edx
    
    cmp eax, ecx ; Compare new score with lowest
    jbe no_add

    ; Replace lowest score
    mov  esi, 9
    ; Copy name
    mov  eax, esi
    mov  ebx, 20
    mul  ebx                          ; EAX = 9 × 20 = 180
    mov  edi, OFFSET LeaderBoardNames
    add  edi, eax
    mov  esi, edx                     ; Source name
    mov  ecx, 20
    call CopyString                   ; Copy new name
    
    ; Store score
    mov  esi,   9
    mov  eax,   esi
    mov  ebx,   4
    mul  ebx
    mov  edi,   OFFSET LeaderBoardScores
    add  edi,   eax                      ; EDI = address of score[9]
    pop  eax
    push eax
    mov  [edi], eax                      ; Store new score
    jmp  sort_scores

add_new_score:
    ; Add to end
    mov  esi, LeaderBoardCount
    ; Copy name
    mov  eax, esi
    mov  ebx, 20
    mul  ebx
    mov  edi, OFFSET LeaderBoardNames
    add  edi, eax
    mov  esi, edx                     ; Source name
    mov  ecx, 20
    call CopyString
    
    ; Store score
    mov  esi,   LeaderBoardCount
    mov  eax,   esi
    mov  ebx,   4
    mul  ebx
    mov  edi,   OFFSET LeaderBoardScores
    add  edi,   eax
    pop  eax
    push eax
    mov  [edi], eax
    
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
    pop edx
    pop eax
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
    mov  edx, OFFSET instructionsMsg
    call WriteString
    call Crlf
    call WaitForKey
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
WaitForKey ENDP








































drawSnake:
    mov  esi, 0
    mov  ecx, 1       ; draw only the head initially
drawSnake_loop:
    call DrawPlayer ; draw snake head only
    inc  esi
    loop drawSnake_loop

    call Randomize
    call CreateRandomCoin
    call DrawCoin         ; set up finish

    ; Start with default movement to the right so snake moves without initial keypress
    mov  inputChar, 'd'
    mov  lastInputChar, 'd'

    gameLoop::
		mov  dl, 106 ;move cursor to coordinates
		mov  dh, 1
		call Gotoxy

		; get user key input
        call ReadKey
            jz   noKey                    ;jump if no key is entered
        ; Handle extended (arrow) keys: first read returns 0, next returns scan code
        cmp  al, 0
        jne  processInput_normal
        ; extended key - read second code
        call ReadKey
        ; map scan codes to WASD
        cmp  al, 72    ; up arrow scan code
        je   set_w
        cmp  al, 80    ; down
        je   set_s
        cmp  al, 75    ; left
        je   set_a
        cmp  al, 77    ; right
        je   set_d
        jmp  processInput_normal

set_w:
        mov  al, 'w'
        jmp  processInput_store

set_s:
        mov  al, 's'
        jmp  processInput_store

set_a:
        mov  al, 'a'
        jmp  processInput_store

set_d:
        mov  al, 'd'
        jmp  processInput_store

processInput_normal:
        ; AL already contains normal key (ASCII)

processInput_store:
        mov  bl,            inputChar
        mov  lastInputChar, bl
        mov  inputChar,     al        ;assign variables

		noKey:
		cmp inputChar, "x"
		je  exitgame       ;exit game if user input x

		cmp inputChar, "w"
		je  checkTop

		cmp inputChar, "s"
		je  checkBottom

		cmp inputChar, "a"
		je  checkLeft

		cmp inputChar, "d"
		je  checkRight
		jne gameLoop       ; reloop if no meaningful key was entered


		checkBottom:	
    cmp lastInputChar, "w"
    je  dontChgDirection
    mov al, yPos[0]
    inc al
    cmp al, 26        ; Explicit bottom boundary (Y=26)
    jl  moveDown
    jge died

checkLeft:		
    cmp lastInputChar, "+"
    je  dontGoLeft
    cmp lastInputChar, "d"
    je  dontChgDirection
    mov al, xPos[0]
    dec al
    mov cl, xPosWall[0]
    cmp al, cl
    ja  moveLeft
    je  died

checkRight:		
    cmp lastInputChar, "a"
    je  dontChgDirection
    mov al, xPos[0]
    inc al
    mov cl, xPosWall[2]
    cmp al, cl
    jb  moveRight
    je  died

checkTop:		
    cmp lastInputChar, "s"
    je  dontChgDirection
    mov al, yPos[0]
    dec al
    mov cl, yPosWall[0]
    cmp al, cl
    ja  moveUp
    je  died
		
		moveUp:		
		mov  eax, speed     ;slow down the moving
		add  eax, speed
		call delay
		mov  esi, 0         ;index 0(snake head)
		call UpdatePlayer
		mov  ah,  yPos[esi]
		mov  al,  xPos[esi] ;alah stores the pos of the snake's next unit 
		dec  yPos[esi]      ;move the head up
		call DrawPlayer
		call DrawBody
		call CheckSnake

		
		moveDown:                ;move down
		mov       eax, speed
		add       eax, speed
		call      delay
		mov       esi, 0
		call      UpdatePlayer
		mov       ah,  yPos[esi]
		mov       al,  xPos[esi]
		inc       yPos[esi]
		call      DrawPlayer
		call      DrawBody
		call      CheckSnake


		moveLeft:                ;move left
		mov       eax, speed
		call      delay
		mov       esi, 0
		call      UpdatePlayer
		mov       ah,  yPos[esi]
		mov       al,  xPos[esi]
		dec       xPos[esi]
		call      DrawPlayer
		call      DrawBody
		call      CheckSnake


		moveRight:                ;move right
		mov        eax, speed
		call       delay
		mov        esi, 0
		call       UpdatePlayer
		mov        ah,  yPos[esi]
		mov        al,  xPos[esi]
		inc        xPos[esi]
		call       DrawPlayer
		call       DrawBody
		call       CheckSnake

	; getting points
		checkcoin::
		mov esi, 0
		mov bl,  xPos[0]
		cmp bl,  xCoinPos
		jne gameloop      ;reloop if snake is not intersecting with coin
		mov bl,  yPos[0]
		cmp bl,  yCoinPos
		jne gameloop      ;reloop if snake is not intersecting with coin

		call EatingCoin ;call to update score, append snake and generate new coin	

jmp gameLoop ;reiterate the gameloop


	dontChgDirection:               ;dont allow user to change direction
	mov               inputChar, bl ;set current inputChar as previous
	jmp               noKey         ;jump back to continue moving the same direction 

	dontGoLeft:                ;forbids the snake to go left at the begining of the game
	mov         inputChar, "+" ;set current inputChar as "+"
	jmp         gameLoop       ;restart the game loop

	died::
	call YouDied
	 
	playagn::			
	call ReinitializeGame ;reinitialise everything
	
	exitgame::
	exit
ret


DrawWall PROC           ;procedure to draw wall
    ; Draw a box using box-drawing characters around the wall coordinates
    ; Top-left corner
    mov  dl, xPosWall[0]
    mov  dh, yPosWall[0]
    call Gotoxy
    mov  al, 201  ; ╔
    call WriteChar

    ; Draw top horizontal line between left and right corners
    movzx eax, xPosWall[2]
    movzx ebx, xPosWall[0]
    sub  eax, ebx
    sub  eax, 1          ; number of horizontal chars between corners
    mov  ecx, eax
    mov  dl, xPosWall[0]
    inc  dl
draw_top:
    call Gotoxy
    mov  al, 205  ; ═
    call WriteChar
    inc  dl
    loop draw_top

    ; Top-right corner
    mov  dl, xPosWall[2]
    mov  dh, yPosWall[0]
    call Gotoxy
    mov  al, 187  ; ╗
    call WriteChar

    ; Draw vertical sides (rows) using BL as current row
    movzx eax, yPosWall[0]
    inc  al
    mov  bl, al           ; current row
    movzx eax, yPosWall[3]
    dec  al
    mov  bh, al           ; last row
draw_rows_loop:
    ; Left border at (xPosWall[0], bl)
    mov  dl, xPosWall[0]
    mov  dh, bl
    call Gotoxy
    mov  al, 186  ; ║
    call WriteChar

    ; Right border at (xPosWall[2], bl)
    mov  dl, xPosWall[2]
    mov  dh, bl
    call Gotoxy
    mov  al, 186  ; ║
    call WriteChar

    inc  bl
    cmp  bl, bh
    jle  draw_rows_loop

    ; Bottom-left corner
    mov  dl, xPosWall[0]
    mov  dh, yPosWall[3]
    call Gotoxy
    mov  al, 200  ; ╚
    call WriteChar

    ; Bottom horizontal
    movzx eax, xPosWall[2]
    movzx ebx, xPosWall[0]
    sub  eax, ebx
    sub  eax, 1
    mov  ecx, eax
    mov  dl, xPosWall[0]
    inc  dl
draw_bottom:
    call Gotoxy
    mov  al, 205  ; ═
    call WriteChar
    inc  dl
    loop draw_bottom

    ; Bottom-right corner
    mov  dl, xPosWall[2]
    mov  dh, yPosWall[3]
    call Gotoxy
    mov  al, 188  ; ╝
    call WriteChar

    ret
DrawWall       ENDP


DrawScoreboard PROC ;procedure to draw scoreboard
	mov  dl,  2
	mov  dh,  1
	call Gotoxy
	mov  edx, OFFSET strScore ;print string that indicates score
	call WriteString
	mov  eax, "0"
	call WriteChar            ;scoreboard starts with 0
	ret
DrawScoreboard ENDP


ChooseSpeed    PROC ;procedure for player to choose speed
	mov  edx,   0
	mov  dl,    71
	mov  dh,    1
	call Gotoxy
	mov  edx,   OFFSET strSpeed ; prompt to enter integers (1,2,3)
	call WriteString
	mov  esi,   40              ; milisecond difference per speed level
	mov  eax,   0
	call readInt
	cmp  ax,    1               ;input validation
	jl   invalidspeed
	cmp  ax,    3
	jg   invalidspeed
	mul  esi
	mov  speed, eax             ;assign speed variable in mililiseconds
	ret

	invalidspeed:                          ;jump here if user entered an invalid number
	mov           dl,  105
	mov           dh,  1
	call          Gotoxy
	mov           edx, OFFSET invalidInput ;print error message		
	call          WriteString
	mov           ax,  1500
	call          delay
	mov           dl,  105
	mov           dh,  1
	call          Gotoxy
	mov           edx, OFFSET blank        ;erase error message after 1.5 secs of delay
	call          writeString
	call          ChooseSpeed              ;call procedure for user to choose again
	ret
ChooseSpeed ENDP

DrawPlayer  PROC ; draw player at (xPos,yPos)
    mov  dl, xPos[esi]
    mov  dh, yPos[esi]
    call Gotoxy
    mov  al, snake[esi]
    call WriteChar
    ret
DrawPlayer   ENDP

UpdatePlayer PROC ; erase player at (xPos,yPos)
    mov  dl, xPos[esi]
    mov  dh, yPos[esi]
    call Gotoxy
    mov  al, " "
    call WriteChar
    ret
UpdatePlayer ENDP

DrawCoin     PROC ;procedure to draw coin
	mov  eax, yellow (yellow * 16)
	call SetTextColor              ;set color to yellow for coin
	mov  dl,  xCoinPos
	mov  dh,  yCoinPos
	call Gotoxy
	mov  al,  "X"
	call WriteChar
	mov  eax, white (black * 16)   ;reset color to black and white
	call SetTextColor
	ret
DrawCoin         ENDP

CreateRandomCoin PROC ;procedure to create a random coin
    ; Generate X between (xPosWall[0]+1) .. (xPosWall[2]-1)
    movzx ecx, xPosWall[2]
    movzx ebx, xPosWall[0]
    mov  eax, ecx
    sub  eax, ebx
    sub  eax, 1        ; W = right - left - 1
    dec  eax           ; pass W-1 to RandomRange to get 0..W-1
    call RandomRange
    add  eax, ebx
    inc  eax           ; now EAX in [left+1 .. right-1]
    mov  xCoinPos, al

    ; Generate Y between (yPosWall[0]+1) .. (yPosWall[3]-1)
    movzx ecx, yPosWall[3]
    movzx ebx, yPosWall[0]
    mov  eax, ecx
    sub  eax, ebx
    sub  eax, 1
    dec  eax
    call RandomRange
    add  eax, ebx
    inc  eax
    mov  yCoinPos, al

    mov ecx, 5
    add cl,  score ;loop number of snake unit
    mov esi, 0
checkCoinXPos:
    movzx eax, xCoinPos
    cmp   al,  xPos[esi]
    je    checkCoinYPos  ;jump if xPos of snake at esi = xPos of coin
continueloop:
    inc   esi
    loop checkCoinXPos
    ret                    ; return when coin is not on snake
checkCoinYPos:
    movzx eax, yCoinPos
    cmp   al,  yPos[esi]
    jne   continueloop     ; jump back to continue loop if yPos of snake at esi != yPos of coin
    call  CreateRandomCoin ; coin generated on snake, calling function again to create another set of coordinates
CreateRandomCoin ENDP

CheckSnake       PROC ;check whether the snake head collides w its body 
	mov al,  xPos[0]
	mov ah,  yPos[0]
	mov esi, 4       ;start checking from index 4(5th unit)
	mov ecx, 1
	add cl,  score
checkXposition:
	cmp xPos[esi], al ;check if xpos same ornot
	je  XposSame
	contloop:
	inc esi
loop checkXposition
	jmp       checkcoin
	XposSame:               ; if xpos same, check for ypos
	cmp       yPos[esi], ah
	je        died          ;if collides, snake dies
	jmp       contloop

CheckSnake ENDP

DrawBody   PROC ;procedure to print body of the snake
        ; No body rendering - snake is represented by a single 'x' (head only)
        ret
DrawBody   ENDP

EatingCoin PROC
	; snake is eating coin
	inc score
	mov ebx,       4
	add bl,        score
	mov esi,       ebx
	mov ah,        yPos[esi-1]
	mov al,        xPos[esi-1]
	mov xPos[esi], al          ;add one unit to the snake
	mov yPos[esi], ah          ;pos of new tail = pos of old tail

	cmp xPos[esi-2], al ;check if the old tail and the unit before is on the yAxis
	jne checky          ;jump if not on the yAxis

	cmp   yPos[esi-2], ah ;check if the new tail should be above or below of the old tail 
	jl    incy
	jg    decy
	incy:                 ;inc if below
	inc   yPos[esi]
	jmp   continue
	decy:                 ;dec if above
	dec   yPos[esi]
	jmp   continue

	checky:                 ;old tail and the unit before is on the xAxis
	cmp     yPos[esi-2], ah ;check if the new tail should be right or left of the old tail
	jl      incx
	jg      decx
	incx:                   ;inc if right
	inc     xPos[esi]
	jmp     continue
	decx:                   ;dec if left
	dec     xPos[esi]

	continue:                  ;add snake tail and update new coin
	call      DrawPlayer
	call      CreateRandomCoin
	call      DrawCoin

	mov  dl, 17    ; write updated score
	mov  dh, 1
	call Gotoxy
	mov  al, score
	call WriteInt
	ret
EatingCoin ENDP


YouDied    PROC
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
YouDied          ENDP

ReinitializeGame PROC ;procedure to reinitialize everything
	mov  xPos[0],       15
    mov  xPos[1],       14
    mov  xPos[2],       13
    mov  xPos[3],       12
    mov  xPos[4],       11  ; Start at left boundary (X=11)
    mov  yPos[0],       15
    mov  yPos[1],       15
    mov  yPos[2],       15
    mov  yPos[3],       15
    mov  yPos[4],       15
	mov  score,         0   ;reinitialize score
	mov  lastInputChar, 0
	mov  inputChar,     "+" ;reinitialize inputChar and lastInputChar
    ; (Do not modify wall coordinates here) - keep wall size stable
	Call ClrScr
	jmp  main               ;start over the game
ReinitializeGame ENDP






















END              main