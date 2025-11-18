.386
.model flat, stdcall
.stack 4096

; =============================================
; Irvine32 Library Includes
; =============================================
INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib
INCLUDELIB kernel32.lib
INCLUDELIB user32.lib

; =============================================
; .data
; =============================================
.data
    ; Main menu display
    menuTitle BYTE "=== RUSH HOUR GAME ===",0
    menuLine BYTE "==========================",0
             
    title_line1 BYTE "                  _____________  ______________  _______  _____________  _________",0 
    title_line2 BYTE "      _           ___  __ \_  / / /_  ___/__  / / /__  / / /_  __ \_  / / /__  __ \",0
    title_line3 BYTE "   0=[_]=0        __  /_/ /  / / /_____ \__  /_/ /__  /_/ /_  / / /  / / /__  /_/ /",0
    title_line4 BYTE "     /T\          _  _, _// /_/ / ____/ /_  __  / _  __  / / /_/ // /_/ / _  _, _/",0 
    title_line5 BYTE "    |(o)|         /_/ |_| \____/  /____/ /_/ /_/  /_/ /_/  \____/ \____/  /_/ |_|",0  
    title_line6 BYTE "  []=\_/=[]       _____________________  ____________",0                              
    title_line7 BYTE "    __V__         __  ____/__    |__   |/  /__  ____/",0                              
    title_line8 BYTE "   '-----'        _  / __ __  /| |_  /|_/ /__  __/",0                                 
    title_line9 BYTE "                  / /_/ / _  ___ |  /  / / _  /___",0                                 
    title_line10 BYTE "                  \____/  /_/  |_/_/  /_/  /_____/",0                                                                                                                  

    menu1 BYTE "                    1. Start New Game",0
    menu2 BYTE "                    2. Continue Game",0
    menu3 BYTE "                    3. Difficulty Level",0
    menu4 BYTE "                    4. Leaderboard",0
    menu5 BYTE "                    5. Instructions",0
    menu6 BYTE "                    6. Exit",0
    prompt BYTE "                   Enter your choice (1-6): ",0


    
    ; Error messages
    invalidChoice BYTE "Invalid choice! Please enter 1-6.",0
    pressAnyKey BYTE "Press any key to continue...",0
    
    ; Current selection
    userChoice BYTE ?

    ; Screen messages
    newGameMsg BYTE "*** START NEW GAME ***",0Dh,0Ah
               BYTE "This will start a new game...",0
               
    continueMsg BYTE "*** CONTINUE GAME ***",0Dh,0Ah
                BYTE "Loading saved game...",0
                
    difficultyMsg BYTE "*** DIFFICULTY LEVEL ***",0Dh,0Ah
                  BYTE "Easy, Medium, Hard options...",0
                  
    leaderboardMsg BYTE "*** LEADERBOARD ***",0Dh,0Ah
                   BYTE "Top 10 scores will be displayed here...",0
                   
    instructionsMsg BYTE "*** INSTRUCTIONS ***",0Dh,0Ah
                    BYTE "Game rules and controls...",0
                    
    exitMsg BYTE "*** EXIT GAME ***",0Dh,0Ah
            BYTE "Thank you for playing Rush Hour!",0Dh,0Ah
            BYTE "Goodbye!",0

.code
main PROC
    call MainMenu
    exit
main ENDP





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
MainMenu ENDP



; =============================================
; Display Main Menu Interface
; =============================================
DisplayMainMenu PROC
    call Clrscr          ; Clear screen
    
    ; Display title with yellow color
    mov eax, yellow + (black * 16)
    call SetTextColor
    
    ; Display ASCII art title
    mov edx, OFFSET title_line1  ; FIXED: was "OFSET" should be "OFFSET"
    call WriteString
    call Crlf
    mov edx, OFFSET title_line2
    call WriteString
    call Crlf
    mov edx, OFFSET title_line3
    call WriteString
    call Crlf
    mov edx, OFFSET title_line4
    call WriteString
    call Crlf
    mov edx, OFFSET title_line5
    call WriteString
    call Crlf
    mov edx, OFFSET title_line6
    call WriteString
    call Crlf
    mov edx, OFFSET title_line7
    call WriteString
    call Crlf
    mov edx, OFFSET title_line8
    call WriteString
    call Crlf
    mov edx, OFFSET title_line9
    call WriteString
    call Crlf
    mov edx, OFFSET title_line10
    call WriteString
    call Crlf
    call Crlf

    ; Reset to white color for menu items
    mov eax, white + (black * 16)
    call SetTextColor
    
    ; Display menu options

    mov eax, Green + (black * 16)
    call SetTextColor

    mov edx, OFFSET menu1
    call WriteString
    call Crlf

    mov eax, white + (black * 16)
    call SetTextColor
    
    mov edx, OFFSET menu2
    call WriteString
    call Crlf
    
    mov edx, OFFSET menu3
    call WriteString
    call Crlf
    
    mov edx, OFFSET menu4
    call WriteString
    call Crlf
    
    mov edx, OFFSET menu5
    call WriteString
    call Crlf

    mov eax, Red + (black * 16)
    call SetTextColor
    
    mov edx, OFFSET menu6
    call WriteString
    call Crlf
    call Crlf

    mov eax, white + (black * 16)
    call SetTextColor
    
    ret
DisplayMainMenu ENDP

; =============================================
; Get User Choice (1-6)
; =============================================
GetUserChoice PROC
input_loop:
    ; Display prompt
    mov edx, OFFSET prompt
    call WriteString
    
    ; Read single character
    call ReadChar       ; The character is not echoed on the screen.
    call WriteChar      ; Echo the character
    call Crlf
    call Crlf
    
    ; Validate input
    cmp al, '1'          ; it sets CF flag if al < value
    jb invalid_input     ; jb means jump if unsigned less than. it checks if CF = 1 then jumps
    cmp al, '6'
    ja invalid_input     ; ja means jump if unsigned greater than. it jumps if both CF = 0 (not less) and ZF = 0 (not equal) 
    
    ; Valid input - store it
    sub al, '0'         ; Convert ASCII to number
    mov userChoice, al
    ret


    ; lets say you want to enter 5 so the ascii value of 5 would be 53 in decimal and 0 would be 48 so 53 - 48 = 5
    ; it is valid for all values used here


    
invalid_input:
    mov edx, OFFSET invalidChoice
    call WriteString
    call Crlf
    
    mov edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar       ; Wait for any key
    
    call DisplayMainMenu ; Redisplay menu
    jmp input_loop
    
GetUserChoice ENDP

; =============================================
; Process Menu Choice
; =============================================
ProcessMenuChoice PROC
    cmp userChoice, 1
    je start_new_game
    cmp userChoice, 2
    je continue_game
    cmp userChoice, 3
    je difficulty_menu
    cmp userChoice, 4
    je show_leaderboard
    cmp userChoice, 5
    je show_instructions
    cmp userChoice, 6
    je exit_program
    ret

start_new_game:
    call NewGameScreen
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
    
ProcessMenuChoice ENDP

; =============================================
; Placeholder Screens for Each Menu Option
; =============================================

NewGameScreen PROC
    call Clrscr
    mov edx, OFFSET newGameMsg
    call WriteString
    call Crlf
    call WaitForKey
    ret
NewGameScreen ENDP

ContinueGameScreen PROC
    call Clrscr
    mov edx, OFFSET continueMsg
    call WriteString
    call Crlf
    call WaitForKey
    ret
ContinueGameScreen ENDP

DifficultyScreen PROC
    call Clrscr
    mov edx, OFFSET difficultyMsg
    call WriteString
    call Crlf
    call WaitForKey
    ret
DifficultyScreen ENDP

LeaderboardScreen PROC
    call Clrscr
    mov edx, OFFSET leaderboardMsg
    call WriteString
    call Crlf
    call WaitForKey
    ret
LeaderboardScreen ENDP

InstructionsScreen PROC
    call Clrscr
    mov edx, OFFSET instructionsMsg
    call WriteString
    call Crlf
    call WaitForKey
    ret
InstructionsScreen ENDP

ExitScreen PROC
    call Clrscr
    mov edx, OFFSET exitMsg
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
    mov edx, OFFSET pressAnyKey
    call WriteString
    call ReadChar
    ret
WaitForKey ENDP

END main