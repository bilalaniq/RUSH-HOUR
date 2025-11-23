.386
.model       flat,                                         stdcall
.stack       4096

; =============================================
; Irvine32 Library Includes
; =============================================
INCLUDE      Irvine32.inc
INCLUDELIB   Irvine32.lib
INCLUDELIB   kernel32.lib
INCLUDELIB   user32.lib

; =============================================
; .data
; =============================================
.data


xWall        BYTE 52 DUP("#"),                             0

strScore     BYTE "Your score is: ",                       0
score        BYTE 0

strTryAgain  BYTE "Try Again?  1=yes, 0=no",               0
invalidInput BYTE "invalid input",                         0
strYouDied   BYTE "you died ",                             0
strPoints    BYTE " point(s)",                             0
blank        BYTE "                                     ", 0

; Represent the car (player vehicle) using 'T' characters (single char per segment)
car          BYTE 'T'


; Keep only head position (single 'T' car)
xPos         BYTE 15,                                      100 DUP(?) ; Head X (start near left boundary)
yPos         BYTE 15,                                      100 DUP(?) ; Head Y

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


xCoinPos     BYTE ?
yCoinPos     BYTE ?

inputChar    BYTE "+"                                                 ; + denotes the start of the game
; lastInputChar removed (unused)
speed        DWORD 0

            
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


    ROAD_CHAR      BYTE ' ', 0 ; Empty road
    BUILDING_CHAR  BYTE 178, 0 ; ASCII 219 for buildings 
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
    call SelectTaxiScreen
    ; call EnterPlayer_Name
    ;call start_game
    call Clrscr
    call DrawWall         ;draw walls
    call DrawScoreboard   ;draw scoreboard
    call DrawBuildings

    ; Fixed movement speed (milliseconds) — no user prompt
    mov eax,   5   ; faster: 15 ms delay per move
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








































; =============================================
; FlushKeys - consume any pending keypresses (handles extended keys)
; Ensures only a single key is processed per move (prevents diagonal input)
; Uses Irvine32 ReadKey: when no key available ZF is set.
; =============================================

FlushKeys:
Flush_loop:
    call ReadKey
    jz   Flush_done        ; no key available → done
    cmp  al, 0
    je   Flush_consume_ext ; extended key prefix — consume scan code
    jmp  Flush_loop
Flush_consume_ext:
    call ReadKey
    jz   Flush_done
    jmp  Flush_loop
Flush_done:
    ret


; =============================================
; drawCar - Main Game Loop
; ============================================
drawCar:
    mov esi, 0
    mov ecx, 1 ; draw only the head (car)
drawCar_loop:
    call DrawPlayer   ; draw car (taxi) head only
    inc  esi          ; it is passed in the drawplayer proc to know which part to draw
    loop drawCar_loop

    call Randomize
    call CreateRandomCoin
    call DrawCoin         ; set up finish

    gameLoop::
    mov  dl, 106 ;move cursor to coordinates where it is safe so no overlap occurs
    mov  dh, 1
    call Gotoxy

    ; get user key input
    call ReadKey  ; No Key Pressed → ZF = 1 (Zero Flag SET) on Key Pressed call ReadKey → ZF = 0 (Zero Flag CLEAR)
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
    jne gameLoop

    ; process 'p' (or other future normal keys) via storing and FlushKeys
    mov  inputChar, al  ;assign variables (single-step movement)
    call FlushKeys
    cmp  inputChar, "p"
    je   exitgame
    jmp  gameLoop       ; reloop if no meaningful key was entered

checkBottom: 	
    mov al, yPos[0]    ; Get current Y position
    inc al             ; Calculate: current Y + 1 (moving down)
    mov cl, yPosWall[3]; Get bottom wall position (27)
    cmp al, cl         ; Compare next position with wall
    jb  moveDown       ; If next Y < 27 → safe to move down
    je  died           ; If next Y = 27 → hit wall, game over

checkLeft: 	
    mov al, xPos[0]    ; Get current X position
    dec al             ; Calculate: current X - 1 (moving left)
    mov cl, xPosWall[0]; Get left wall position (10)
    cmp al, cl         ; Compare next position with wall
    ja  moveLeft       ; If next X > 10 → safe to move left
    je  died           ; If next X = 10 → hit wall, game over

checkRight: 	
    mov al, xPos[0]    ; Get current X position
    inc al             ; Calculate: current X + 1 (moving right)
    mov cl, xPosWall[2]; Get right wall position (110)
    cmp al, cl         ; Compare next position with wall
    jb  moveRight      ; If next X < 110 → safe to move right
    je  died           ; If next X = 110 → hit wall, game over

checkTop: 	
    mov al, yPos[0]    ; Get current Y position
    dec al             ; Calculate: current Y - 1 (moving up)
    mov cl, yPosWall[0]; Get top wall position (5)
    cmp al, cl         ; Compare next position with wall
    ja  moveUp         ; If next Y > 5 → safe to move up
    je  died           ; If next Y = 5 → hit wall, game over
		
		moveUp:		
		mov  eax, speed     
		call delay          ; Pauses the game for the calculated time Without this delay, the car would move too fast to control 
        mov  esi, 0         ;index 0 (car)
		call UpdatePlayer
		dec  yPos[esi]       ; Move up (Y = Y - 1) 
        call DrawPlayer
        jmp  checkcoin

		
		moveDown:                ;move down
		mov       eax, speed
		call      delay
		mov       esi, 0
		call      UpdatePlayer
		inc       yPos[esi]
        call      DrawPlayer
        jmp       checkcoin


		moveLeft:                ;move left
		mov       eax, speed
		call      delay
		mov       esi, 0
		call      UpdatePlayer
		dec       xPos[esi]
        call      DrawPlayer
        jmp       checkcoin


		moveRight:                ;move right
		mov        eax, speed
		call       delay
		mov        esi, 0
		call       UpdatePlayer
		inc        xPos[esi]
        call       DrawPlayer
        jmp        checkcoin

    ; Post-move handling (coin check only for single-head car)
    checkcoin:
        mov  al, xPos[0]
        cmp  al, xCoinPos
        jne  no_eat
        mov  al, yPos[0]
        cmp  al, yCoinPos
        jne  no_eat
        call EatingCoin
        jmp  gameLoop

    no_eat:
        jmp gameLoop



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
DrawWall       ENDP


; =============================================
; DrawBuildings - draws random building obstacles inside the game area
; =============================================
DrawBuildings PROC
    LOCAL buildingCount:BYTE      ; Number of buildings to generate
    LOCAL buildingX:BYTE          ; Top-left X position of building
    LOCAL buildingY:BYTE          ; Top-left Y position of building  
    LOCAL buildingWidth:BYTE      ; Width of building in blocks
    LOCAL buildingHeight:BYTE     ; Height of building in blocks
    LOCAL i:BYTE                  ; Loop counter for height
    LOCAL j:BYTE                  ; Loop counter for width
    
    mov eax, gray + (black * 16)
    call SetTextColor
    
    ; Initialize random seed
    call Randomize
    
    ; Generate random buildings
    mov eax, 20  
    call RandomRange
    add al, 20
    mov buildingCount, al
    
    movzx ecx, buildingCount        ; Zero-extend byte to dword for loop counter
buildingLoop:
    push ecx  ; Save loop counter since we'll use ECX for other purposes
    
    ; Generate random building position and size
    ; X position: between 11 and 100 (within walls 10-110)
    mov eax, 80  ; 100-20 = 80 possible positions
    call RandomRange
    add al, 20   ; 20 + (0-79) = 20-99
    mov buildingX, al
    
    ; Y position: between 6 and 22 (within walls 5-27)
    mov eax, 16  ; 22-6 = 16 possible positions
    call RandomRange
    add al, 6    ; 6 + (0-15) = 6-21
    mov buildingY, al
    
    ; Building width: 3-6 blocks
    mov eax, 4   ; 0-3
    call RandomRange
    add al, 3    ; 3-6 blocks wide
    mov buildingWidth, al
    
    ; Building height: 2-4 blocks
    mov eax, 3   ; 0-2
    call RandomRange
    add al, 2    ; 2-4 blocks high
    mov buildingHeight, al
    
    ; Check if total blocks > 5
    mov al, buildingWidth
    mul buildingHeight
    cmp ax, 5
    jg drawBuilding  ; If > 5 blocks, draw it
    
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
    ; Draw the building
    movzx ecx, buildingHeight
    mov i, 0
heightLoop:
    push ecx
    movzx ecx, buildingWidth
    mov j, 0
widthLoop:
        push ecx
        
        ; Calculate position
        mov dl, buildingX
        add dl, j
        mov dh, buildingY
        add dh, i
        
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
        mov al, 219
        call WriteChar
        
    skipBlock:
        pop ecx
        inc j
        loop widthLoop
    
    pop ecx
    inc i
    loop heightLoop
    
    pop ecx
    dec ecx
    jnz buildingLoop
    
    ; Reset to default color
    mov eax, white + (black * 16)
    call SetTextColor
    
    ret
DrawBuildings ENDP




; =============================================
; DrawScoreboard - draws the scoreboard
; =============================================
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


; =============================================
; DrawPlayer    esi = index of player to draw
; =============================================
DrawPlayer     PROC ; draw player (taxi) at (xPos,yPos) in yellow
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
; DrawCoin - draws coin at (xCoinPos,yCoinPos)
; =============================================
DrawCoin     PROC ;procedure to draw coin
	mov  eax, blue (blue * 16)
	call SetTextColor            ;set color to yellow for coin
	mov  dl,  xCoinPos
	mov  dh,  yCoinPos
	call Gotoxy
	mov  al,  "X"
	call WriteChar
	mov  eax, white (black * 16) ;reset color to black and white
	call SetTextColor
	ret
DrawCoin         ENDP



; =============================================
; CreateRandomCoin - creates random coin position
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
; EatingCoin - handles when car eats coin
; =============================================
EatingCoin       PROC
    ; car is eating coin - single 'T' car: just increase score and respawn coin
    inc  score
    call CreateRandomCoin
    call DrawCoin

    mov  dl, 17    ; write updated score
    mov  dh, 1
    call Gotoxy
    mov  al, score
    call WriteInt
    ret
EatingCoin ENDP




; =============================================
; YouDied - handles when player dies
; =============================================
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



; =============================================
; ReinitializeGame - resets game state for a new game
; =============================================
ReinitializeGame PROC ;procedure to reinitialize everything
    mov  xPos[0],   15
    mov  yPos[0],   15
    mov  score,     0   ;reinitialize score
    mov  inputChar, "+" ;reinitialize inputChar
    ; (Do not modify wall coordinates here) - keep wall size stable
    Call ClrScr
    jmp  main           ;start over the game
ReinitializeGame ENDP






















END              main




















; irvine32 functions that are not in the https://csc.csudh.edu/mmccullough/asm/help/index.html?page=source%2Fabout.htm

; Gotoxy is a procedure from the Irvine32 library that positions the cursor at specific coordinates on the console screen.
; mov  dl, column   ; X coordinate (0-based, left to right)
; mov  dh, row      ; Y coordinate (0-based, top to bottom)  
; call Gotoxy       ; Position cursor