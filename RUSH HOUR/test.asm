.386
.model     flat, stdcall
.stack     4096

; =============================================
; Irvine32 Library Includes
; =============================================
INCLUDE    Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib

; =============================================
; .data
; =============================================
.data

             
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
    prompt3 BYTE "                     Please enter player Name (show be with in 19 words): ", 0

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
    pressAnyKey     BYTE "Press any key to continue...",            0
    invalidNameSize BYTE "The name cannot be longer than 19 words", 0
    
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
    call CreateTestLeaderboard
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
    ret
    
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
; Enter Player Name
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
    mov  edx, OFFSET prompt3
    call WriteString
    
    ; Read the player name
    mov  edx,              OFFSET PlayerName
    mov  ecx,              SIZEOF PlayerName
    call ReadString
    mov  PlayerNameLength, al
    
    ; Validate name length
    cmp PlayerNameLength, 0
    je  invalid_input
    cmp PlayerNameLength, 19
    ja  invalid_input
    
    ret

invalid_input:
    mov  edx, OFFSET invalidNameSize
    call WriteString
    call Crlf
    
    mov  edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar
    
    call EnterPlayer_Name
    ret

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
DisplayLeaderboard PROC
    call Clrscr

    ; Load leaderboard data first
    mov edx, OFFSET highscoresFile
    call OpenInputFile
    mov fileHandle, eax

    cmp fileHandle, INVALID_HANDLE_VALUE
    je no_file

    ; Read the count
    mov edx, OFFSET LeaderBoardCount
    mov ecx, SIZEOF LeaderBoardCount
    call ReadFromFile

    ; Read the actual data
    mov ecx, LeaderBoardCount
    cmp ecx, 0
    je close_display_file

    mov esi, 0
read_display_loop:
    ; Read name
    mov eax, esi
    mov ebx, 20
    mul ebx
    mov edx, OFFSET LeaderBoardNames
    add edx, eax
    mov eax, fileHandle
    mov ecx, 20
    call ReadFromFile

    ; Read score
    mov eax, esi
    mov ebx, 4
    mul ebx
    mov edx, OFFSET LeaderBoardScores
    add edx, eax
    mov eax, fileHandle
    mov ecx, 4
    call ReadFromFile

    inc esi
    cmp esi, LeaderBoardCount
    jb read_display_loop

close_display_file:
    mov eax, fileHandle
    call CloseFile

no_file:
    ; Now display the data
    mov eax, cyan + (black * 16)
    call SetTextColor

    mov edx, OFFSET LEADERBOARD_Line1
    call WriteString
    call Crlf
    mov edx, OFFSET LEADERBOARD_Line2
    call WriteString
    call Crlf
    mov edx, OFFSET LEADERBOARD_Line3
    call WriteString
    call Crlf
    mov edx, OFFSET LEADERBOARD_Line4
    call WriteString
    call Crlf
    mov edx, OFFSET LEADERBOARD_Line5
    call WriteString
    call Crlf
    call Crlf

    ; Check if leaderboard is empty
    cmp LeaderBoardCount, 0
    je no_scores

    mov eax, white + (black * 16)
    call SetTextColor

    ; Display only actual entries
    mov ecx, LeaderBoardCount
    mov esi, 0
score_loop:
    ; Display rank number
    mov eax, esi
    inc eax
    call WriteDec
    mov al, '.'
    call WriteChar
    mov al, ' '
    call WriteChar

    ; Display name
    mov eax, esi
    mov ebx, 20
    mul ebx
    mov edx, OFFSET LeaderBoardNames
    add edx, eax
    call WriteString

    ; Add spacing
    mov al, ' '
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar

    ; Display score
    mov eax, esi
    mov ebx, 4
    mul ebx
    mov edx, OFFSET LeaderBoardScores
    add edx, eax
    mov eax, [edx]
    call WriteDec
    call Crlf

    inc esi
    loop score_loop
    jmp done_display

no_scores:
    mov eax, Red + (black * 16)
    call SetTextColor
    call Crlf
    call Crlf
    mov edx, OFFSET leaderboardMsg
    call WriteString

done_display:
    mov eax, White + (black * 16)
    call SetTextColor
    call Crlf
    call Crlf
    mov edx, OFFSET pressAnyKey
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
; Test Program to Create Leaderboard File - FIXED VERSION (10 entries)
; =============================================
CreateTestLeaderboard PROC
    ; First, initialize the arrays in memory
    call InitializeLeaderboardArrays
    
    ; Then set up test data in memory
    mov LeaderBoardCount, 10
    
    ; Entry 1: "Player1" + score 9500
    mov esi, OFFSET testName1
    mov edi, OFFSET LeaderBoardNames
    mov ecx, LENGTHOF testName1
    call CopyString
    mov dword ptr [LeaderBoardScores + 0], 9500
    
    ; Entry 2: "ProGamer" + score 8200
    mov esi, OFFSET testName2
    mov edi, OFFSET LeaderBoardNames + 20
    mov ecx, LENGTHOF testName2
    call CopyString
    mov dword ptr [LeaderBoardScores + 4], 8200
    
    ; Entry 3: "TaxiDriver" + score 7500
    mov esi, OFFSET testName3
    mov edi, OFFSET LeaderBoardNames + 40
    mov ecx, LENGTHOF testName3
    call CopyString
    mov dword ptr [LeaderBoardScores + 8], 7500
    
    ; Entry 4: "SpeedRacer" + score 6800
    mov esi, OFFSET testName4
    mov edi, OFFSET LeaderBoardNames + 60
    mov ecx, LENGTHOF testName4
    call CopyString
    mov dword ptr [LeaderBoardScores + 12], 6800
    
    ; Entry 5: "NewPlayer" + score 5500
    mov esi, OFFSET testName5
    mov edi, OFFSET LeaderBoardNames + 80
    mov ecx, LENGTHOF testName5
    call CopyString
    mov dword ptr [LeaderBoardScores + 16], 5500
    
    ; Entry 6: "RushMaster" + score 4800
    mov esi, OFFSET testName6
    mov edi, OFFSET LeaderBoardNames + 100
    mov ecx, LENGTHOF testName6
    call CopyString
    mov dword ptr [LeaderBoardScores + 20], 4800
    
    ; Entry 7: "CityRacer" + score 4200
    mov esi, OFFSET testName7
    mov edi, OFFSET LeaderBoardNames + 120
    mov ecx, LENGTHOF testName7
    call CopyString
    mov dword ptr [LeaderBoardScores + 24], 4200
    
    ; Entry 8: "FastTaxi" + score 3800
    mov esi, OFFSET testName8
    mov edi, OFFSET LeaderBoardNames + 140
    mov ecx, LENGTHOF testName8
    call CopyString
    mov dword ptr [LeaderBoardScores + 28], 3800
    
    ; Entry 9: "RoadKing" + score 3200
    mov esi, OFFSET testName9
    mov edi, OFFSET LeaderBoardNames + 160
    mov ecx, LENGTHOF testName9
    call CopyString
    mov dword ptr [LeaderBoardScores + 32], 3200
    
    ; Entry 10: "Beginner" + score 2500
    mov esi, OFFSET testName10
    mov edi, OFFSET LeaderBoardNames + 180
    mov ecx, LENGTHOF testName10
    call CopyString
    mov dword ptr [LeaderBoardScores + 36], 2500
    
    ; Now save to file
    call saveLeaderBoard
    
    ret

; Helper procedure to initialize arrays with zeros
InitializeLeaderboardArrays PROC
    ; Initialize names array with zeros
    mov edi, OFFSET LeaderBoardNames
    mov ecx, 200  ; 10 entries × 20 bytes
    mov al, 0
    rep stosb
    
    ; Initialize scores array with zeros
    mov edi, OFFSET LeaderBoardScores
    mov ecx, 10   ; 10 entries
    mov eax, 0
    rep stosd
    
    ret
InitializeLeaderboardArrays ENDP

; Test data - 10 entries
testName1  BYTE "Player1",0
testName2  BYTE "ProGamer",0  
testName3  BYTE "TaxiDriver",0
testName4  BYTE "SpeedRacer",0
testName5  BYTE "NewPlayer",0
testName6  BYTE "RushMaster",0
testName7  BYTE "CityRacer",0
testName8  BYTE "FastTaxi",0
testName9  BYTE "RoadKing",0
testName10 BYTE "Beginner",0

CreateTestLeaderboard ENDP







END        main