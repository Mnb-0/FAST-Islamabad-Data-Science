;Muneeb Lone | 23i-2623 | DS-B

INCLUDE Irvine32.inc

.data

snakeMenuLabel BYTE 13,10,"6. Play Snake Game",13,10,0
ground BYTE "------------------------------------------------------------------------------------------------------------------------",0
strScore BYTE "Your score is: ",0
score BYTE 0

xPos BYTE 20
yPos BYTE 20

xCoinPos BYTE ?
yCoinPos BYTE ?

inputChar BYTE ?

menuText BYTE 13,10,"--- MAIN MENU ---",13,10,
         "1. Display Star",13,10,
         "2. Display Colored Star",13,10,
         "3. Write Colored Text at Coordinates",13,10,
         "4. Draw Filled Rectangle",13,10,
         "5. Exit",13,10,
         "6. Play Snake Game",13,10,
         "Select an option (1–6): ",0

xCoord DWORD ?
yCoord DWORD ?
foregroundColor BYTE ?
backgroundColor BYTE ?
borderColor BYTE ?
fillColor BYTE ?
rectWidth DWORD ?
rectHeight DWORD ?
userText BYTE 100 DUP(0)

promptX BYTE "Enter X coordinate: ", 0
promptY BYTE "Enter Y coordinate: ", 0
promptWidth BYTE "Enter rectangle width: ", 0
promptHeight BYTE "Enter rectangle height: ", 0
promptFG BYTE "Enter Foreground Color (0–15): ", 0
promptBG BYTE "Enter Background Color (0–15): ", 0
promptBorder BYTE "Enter border color (0–15): ", 0
promptFill BYTE "Enter fill color (0–15): ", 0
promptText BYTE "Enter the text to display: ", 0

colorPaletteLabel BYTE 13,10,"Color Palette:",13,10,0
paletteStr1 BYTE "0-Black  1-Blue   2-Green  3-Cyan   4-Red    5-Magenta",13,10,0
paletteStr2 BYTE "6-Brown  7-L.Gray 8-D.Gray 9-L.Blue 10-L.Green 11-L.Cyan",13,10,0
paletteStr3 BYTE "12-L.Red 13-L.Mag 14-Yellow 15-White",13,10,0

.code
main PROC
    jmp StartMainLoop

StartMainLoop:
    call ClrScr
    call DisplayMenu
    call ReadInt
    cmp eax, 1
    je Task1
    cmp eax, 2
    je Task2
    cmp eax, 3
    je Task3
    cmp eax, 4
    je Task4
    cmp eax, 5
    je ExitProgram
    cmp eax, 6
    je PlaySnakeGame
    jmp StartMainLoop

Task1:
    call ClrScr
    call GetCoordinates
    call DisplaySimpleStar
    call WaitMsg
    jmp StartMainLoop

Task2:
    call ClrScr
    call GetCoordinates
    call ShowColorPalette
    call GetColors
    call DisplayColoredStar
    call WaitMsg
    jmp StartMainLoop

Task3:
    call ClrScr
    call GetCoordinates
    call ShowColorPalette
    call GetColors
    call GetTextInput
    call WriteTextAtCoordinates
    call WaitMsg
    jmp StartMainLoop

Task4:
    call ClrScr
    call GetRectangleSpecs
    call ShowColorPalette
    call GetRectangleColors
    call DrawFilledRectangle
    call WaitMsg
    jmp StartMainLoop

ExitProgram:
    exit
main ENDP

;Display Menu

DisplayMenu PROC
    mov edx, OFFSET menuText
    call WriteString
    ret
DisplayMenu ENDP

;Task 1: Display Star
DisplaySimpleStar PROC
    mov eax, xCoord
    mov ebx, yCoord
    call Gotoxy
    mov al, '*'
    call WriteChar
    ret
DisplaySimpleStar ENDP

;Task 2: Colored Star
DisplayColoredStar PROC
    xor eax, eax
    mov al, backgroundColor
    shl al, 4
    or al, foregroundColor
    call SetTextColor

    mov eax, xCoord
    mov ebx, yCoord
    call Gotoxy

    mov al, '*'
    call WriteChar
    ret
DisplayColoredStar ENDP

;Task 3: Colored Text
WriteTextAtCoordinates PROC
    xor eax, eax
    mov al, backgroundColor
    shl al, 4
    or al, foregroundColor
    call SetTextColor

    mov eax, xCoord
    mov ebx, yCoord
    call Gotoxy

    mov edx, OFFSET userText
    call WriteString
    ret
WriteTextAtCoordinates ENDP

;Task 4: Filled Rectangle
DrawFilledRectangle PROC
    pushad

    mov al, borderColor
    call SetTextColor

    mov eax, yCoord
    and eax, 0FFh
    mov dh, al
    mov dl, byte ptr xCoord
    mov ecx, rectWidth

TopBorder:
    call Gotoxy
    mov al, '#'
    call WriteChar
    inc dl
    loop TopBorder

    mov eax, rectHeight
    sub eax, 2
    jle DrawBottomBorder

    mov esi, eax
    mov edi, yCoord
    inc edi

MiddleRows:
    mov al, borderColor
    call SetTextColor

    mov eax, edi
    and eax, 0FFh
    mov dh, al
    mov dl, byte ptr xCoord
    call Gotoxy
    mov al, '#'
    call WriteChar

    mov eax, rectWidth
    sub eax, 2
    jle SkipFill
    mov ecx, eax
    mov ebx, xCoord
    inc ebx

    mov al, fillColor
    call SetTextColor

FillLoop:
    mov eax, edi
    and eax, 0FFh
    mov dh, al
    mov dl, bl
    call Gotoxy
    mov al, ' '
    call WriteChar
    inc bl
    loop FillLoop

SkipFill:
    mov al, borderColor
    call SetTextColor

    mov eax, edi
    and eax, 0FFh
    mov dh, al
    mov eax, xCoord
    add eax, rectWidth
    dec eax
    mov dl, al
    call Gotoxy
    mov al, '#'
    call WriteChar

    inc edi
    dec esi
    jnz MiddleRows

DrawBottomBorder:
    mov al, borderColor
    call SetTextColor

    mov eax, yCoord
    add eax, rectHeight
    dec eax
    mov dh, al
    mov dl, byte ptr xCoord
    mov ecx, rectWidth

BottomBorderLoop:
    call Gotoxy
    mov al, '#'
    call WriteChar
    inc dl
    loop BottomBorderLoop

    popad
    ret
DrawFilledRectangle ENDP

;Input Helpers
GetCoordinates PROC
    mov edx, OFFSET promptX
    call WriteString
    call ReadInt
    mov xCoord, eax

    mov edx, OFFSET promptY
    call WriteString
    call ReadInt
    mov yCoord, eax
    ret
GetCoordinates ENDP

ShowColorPalette PROC
    mov edx, OFFSET colorPaletteLabel
    call WriteString

    mov edx, OFFSET paletteStr1
    call WriteString

    mov edx, OFFSET paletteStr2
    call WriteString

    mov edx, OFFSET paletteStr3
    call WriteString
    ret
ShowColorPalette ENDP

GetColors PROC
    mov edx, OFFSET promptFG
    call WriteString
    call ReadInt
    mov foregroundColor, al

    mov edx, OFFSET promptBG
    call WriteString
    call ReadInt
    mov backgroundColor, al
    ret
GetColors ENDP

GetTextInput PROC
    mov edx, OFFSET promptText
    call WriteString
    mov edx, OFFSET userText
    mov ecx, 100
    call ReadString
    ret
GetTextInput ENDP

GetRectangleSpecs PROC
    mov edx, OFFSET promptX
    call WriteString
    call ReadInt
    mov xCoord, eax

    mov edx, OFFSET promptY
    call WriteString
    call ReadInt
    mov yCoord, eax

    mov edx, OFFSET promptWidth
    call WriteString
    call ReadInt
    mov rectWidth, eax

    mov edx, OFFSET promptHeight
    call WriteString
    call ReadInt
    mov rectHeight, eax
    ret
GetRectangleSpecs ENDP

GetRectangleColors PROC
    mov edx, OFFSET promptBorder
    call WriteString
    call ReadInt
    mov borderColor, al

    mov edx, OFFSET promptFill
    call WriteString
    call ReadInt
    mov fillColor, al
    ret
GetRectangleColors ENDP

;Snake Game
PlaySnakeGame PROC
    call ClrScr
    call Randomize

    mov dl,0
    mov dh,29
    call Gotoxy
    mov edx,OFFSET ground
    call WriteString

    call DrawPlayer
    call CreateRandomCoin
    call DrawCoin

gameLoop:
    mov bl,xPos
    cmp bl,xCoinPos
    jne notCollecting
    mov bl,yPos
    cmp bl,yCoinPos
    jne notCollecting
    inc score
    call CreateRandomCoin
    call DrawCoin
notCollecting:

    mov eax, white + (black * 16)
    call SetTextColor

    mov dl,0
    mov dh,0
    call Gotoxy
    mov edx,OFFSET strScore
    call WriteString
    mov al,score
    call WriteInt

gravity:
    cmp yPos,27
    jg onGround
    call UpdatePlayer
    inc yPos
    call DrawPlayer
    mov eax,80
    call Delay
    jmp gravity
onGround:

    call ReadChar
    mov inputChar,al

    cmp inputChar,"x"
    je EndSnakeGame
    cmp inputChar,"w"
    je moveUp
    cmp inputChar,"s"
    je moveDown
    cmp inputChar,"a"
    je moveLeft
    cmp inputChar,"d"
    je moveRight

moveUp:
    mov ecx,1
jumpLoop:
    call UpdatePlayer
    dec yPos
    call DrawPlayer
    mov eax,70
    call Delay
    loop jumpLoop
    jmp gameLoop

moveDown:
    call UpdatePlayer
    inc yPos
    call DrawPlayer
    jmp gameLoop

moveLeft:
    call UpdatePlayer
    dec xPos
    call DrawPlayer
    jmp gameLoop

moveRight:
    call UpdatePlayer
    inc xPos
    call DrawPlayer
    jmp gameLoop

EndSnakeGame:
    call WaitMsg
    ret
PlaySnakeGame ENDP

DrawPlayer PROC
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
    mov al,"X"
    call WriteChar
    ret
DrawPlayer ENDP

UpdatePlayer PROC
    mov dl,xPos
    mov dh,yPos
    call Gotoxy
    mov al," "
    call WriteChar
    ret
UpdatePlayer ENDP

DrawCoin PROC
    mov eax, yellow + (yellow * 16)
    call SetTextColor
    mov dl,xCoinPos
    mov dh,yCoinPos
    call Gotoxy
    mov al,"O"
    call WriteChar
    ret
DrawCoin ENDP

CreateRandomCoin PROC
    mov eax,55
    inc eax
    call RandomRange
    mov xCoinPos,al
    mov yCoinPos,27
    ret
CreateRandomCoin ENDP

END main