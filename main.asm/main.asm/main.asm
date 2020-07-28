.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode: DWORD
INCLUDE Irvine32.inc

.data

ground BYTE "------------------------------------------------------------------------------------------------------------------------",0

strScore BYTE "Your score is: ",0
score BYTE 0

snake BYTE "X","x",?,?,? ,0

xPos BYTE 20,19,?,?,?, 0
yPos BYTE 20,20,?,?,? ,0

xCoinPos BYTE ?
yCoinPos BYTE ?

inputChar BYTE ?

speed	WORD 0

StartFlag BYTE 1			;1 means that the program has just started, 0 means otherwise

.code
main PROC
	; draw ground at (0,29):
	mov dl,0
	mov dh,29
	call Gotoxy	
	mov edx,OFFSET ground
	call WriteString

	mov ecx, 2
	mov ebx,1
L1: 
	call DrawPlayer
	dec ebx
loop L1

	call CreateRandomCoin
	call DrawCoin

	call Randomize				;set up finish

	gameLoop:

		; getting points:
		mov ebx,0
		mov bl,xPos[0]
		cmp bl,xCoinPos
		jne notCollecting
		mov bl,yPos[0]
		cmp bl,yCoinPos
		jne notCollecting

		; snake is eating coin:
		inc score
		mov ebx, 1
		add bl, score
		mov snake[ebx], "x"		;add one unit to the snake
		mov ah, yPos[ebx-1]
		mov al, xPos[ebx-1]	
		mov xPos[ebx], al
		mov yPos[ebx], ah		;pos of new tail = pos of old tail

		cmp xPos[ebx-2], al		;check if the old tail and the unit before is on the yAxis
		jne checky				;jump if not on the yAxis

		cmp yPos[ebx-2], ah		;check if the new tail should be above or below of the old tail 
		jl incy			
		jg decy
		incy:					;inc if below
		inc yPos[ebx]
		jmp continue
		decy:					;dec if above
		dec yPos[ebx]
		jmp continue

		checky:					;old tail and the unit before is on the xAxis
		cmp yPos[ebx-2], ah		;check if the new tail should be right or left of the old tail
		jl incx
		jg decx
		incx:					;inc if right
		inc xPos[ebx]			
		jmp continue
		decx:					;dec if left
		dec xPos[ebx]
		jmp continue

		;update game
		continue:
		call DrawPlayer
		call CreateRandomCoin
		call DrawCoin			

		notCollecting:

		mov eax,white (black * 16)
		call SetTextColor

		; draw score
		mov dl,0
		mov dh,0
		call Gotoxy
		mov edx,OFFSET strScore
		call WriteString
		mov al,score
		call WriteInt		

		; get user key input
		cmp StartFlag, 1
		je Initialinput
		call ReadKey
            jz noKey		;jump if no key is entered
		processInput:
		mov inputChar,al

		noKey:
		cmp inputChar,"x"	
		je exitGame

		cmp inputChar,"w"
		je checkTop

		cmp inputChar,"s"
		je checkBottom

		cmp inputChar,"a"
		je checkLeft

		cmp inputChar,"d"
		je checkRight
		jne gameLoop

		checkBottom:	;snake cant go under the bottom line
		cmp yPos[0],28
		jne moveDown
		jmp gameLoop

		checkLeft:		;snake cant go too far over to the left
		cmp xPos[0],1
		jne moveLeft
		jmp gameLoop

		checkRight:		;snake cant go too far over to the right
		cmp xPos[0],118
		jne moveRight
		jmp gameLoop

		checkTop:		;snake cant go too far over to the top
		cmp yPos,1
		jne moveUp
		jmp gameLoop

		
		moveUp:			
		call delayfunc		;slow down the moving
		mov ecx, 1
		add cl, score		;number of iterations to print the snake body n tail
		mov ebx, 0			;index 0(snake head)
		call UpdatePlayer	
		mov ah, yPos[ebx]	
		mov al, xPos[ebx]	;alah stores the pos of the snake's next unit 
		dec yPos[ebx]		;move the head up
		call DrawPlayer		
	L5:	
		inc ebx				;loop to print remaining units of snake
		call UpdatePlayer
		mov dl, xPos[ebx]
		mov dh, yPos[ebx]	;dldh temporarily stores the current pos of the unit 
		mov yPos[ebx], ah
		mov xPos[ebx], al	;assign new position to the unit
		mov al, dl
		mov ah,dh			;move the current position back into alah
		call DrawPlayer
	loop L5
		jne gameLoop

		
		moveDown:
		call delayfunc
		mov ecx, 1
		add cl, score
		mov ebx, 0
		call UpdatePlayer
		mov ah, yPos[ebx]
		mov al, xPos[ebx]
		inc yPos[ebx]
		call DrawPlayer
	L4:	
		inc ebx
		call UpdatePlayer
		mov dl, xPos[ebx]
		mov dh, yPos[ebx]
		mov yPos[ebx], ah
		mov xPos[ebx], al
		mov al, dl
		mov ah,dh
		call DrawPlayer
	loop L4
		jmp gameLoop


		moveLeft:
		call delayfunc
		mov ecx, 1
		add cl, score
		mov ebx, 0
		call UpdatePlayer
		mov ah, yPos[ebx]
		mov al, xPos[ebx]
		dec xPos[ebx]
		call DrawPlayer
	L3:	
		inc ebx
		call UpdatePlayer
		mov dl, xPos[ebx]
		mov dh, yPos[ebx]
		mov yPos[ebx], ah
		mov xPos[ebx], al
		mov al, dl
		mov ah,dh
		call DrawPlayer
	loop L3
		jmp gameLoop


		moveRight:
		call delayfunc
		mov ecx, 1
		add cl, score
		mov ebx, 0
		call UpdatePlayer
		mov ah, yPos[ebx]
		mov al, xPos[ebx]
		inc xPos[ebx]
		call DrawPlayer
	L2:	
		inc ebx
		call UpdatePlayer
		mov dl, xPos[ebx]
		mov dh, yPos[ebx]
		mov yPos[ebx], ah
		mov xPos[ebx], al
		mov al, dl
		mov ah,dh
		call DrawPlayer
	loop L2
		jmp gameLoop


jmp gameLoop

Initialinput:			
	call readChar		;bc program will glitch if use readKey for the first input
	mov StartFlag, 0
	jmp processInput

	exitGame:
	exit
INVOKE ExitProcess,0
main ENDP

DrawPlayer PROC
	; draw player at (xPos,yPos)
	mov dl,xPos[ebx]
	mov dh,yPos[ebx]
	call Gotoxy
	mov dl, al			;temporarily save al in dl
	mov al, snake[ebx]		
	call WriteChar
	mov al, dl			
	ret
DrawPlayer ENDP

UpdatePlayer PROC
	mov dl, xPos[ebx]
	mov dh,yPos[ebx]
	call Gotoxy
	mov dl, al			;temporarily save al in dl
	mov al, " "
	call WriteChar
	mov al, dl
	ret
UpdatePlayer ENDP

DrawCoin PROC
	mov eax,yellow (yellow * 16)
	call SetTextColor
	mov dl,xCoinPos
	mov dh,yCoinPos
	call Gotoxy
	mov al,"X"
	call WriteChar
	ret
DrawCoin ENDP

CreateRandomCoin PROC
	mov eax,118
	call RandomRange	;0-117
	inc eax				;1-118
	mov xCoinPos,al
	mov eax,28
	call RandomRange	;0-27
	inc eax				;1-28
	mov yCoinPos,al
	ret
CreateRandomCoin ENDP


delayfunc PROC			;loops to slow down the prog
	mov bx, 3500
	mov cx, 3500
	delay2:
	dec bx
	cmp bx,0 
	jne delay2
	dec cx
	cmp cx,0   
	jne delay2
	ret
delayfunc ENDP

END main