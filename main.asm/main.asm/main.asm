.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode: DWORD
INCLUDE Irvine32.inc

.data

xdivider BYTE 60 DUP("#"),0

strScore BYTE "Your score is: ",0
score BYTE 0

snake BYTE "X","x",?,?,?,?,?,?,?,?,?,?

xPos BYTE 40,39,?,?,?,?,?,?,?,?,?,?
yPos BYTE 20,20,?,?,?,?,?,?,?,?,?,?

xPosWall BYTE 29,29,89,89			;upperLeft, lowerLeft, upperRight, lowerRignt 
yPosWall BYTE 4,25,4,25

xCoinPos BYTE ?
yCoinPos BYTE ?

inputChar BYTE ?
lastInputChar BYTE ?

strSpeed BYTE "Speed: ",0
speed	WORD 0

StartFlag BYTE 1			;1 means that the program has just started, 0 means otherwise

.code
main PROC

	; draw walls
	mov dl,xPosWall[0]
	mov dh,yPosWall[0]
	call Gotoxy	
	mov edx,OFFSET xdivider
	call WriteString			;upper wall

	mov dl,xPosWall[1]
	mov dh,yPosWall[1]
	call Gotoxy	
	mov edx,OFFSET xdivider		
	call WriteString			;lower wall

	mov dl, xPosWall[2]
	mov dh, yPosWall[2]
	mov eax,"#"	
	inc yPosWall[3]
	L11: 
	call Gotoxy	
	call WriteChar	
	inc dh
	cmp dh, yPosWall[3]			;right wall	
	jl L11

	mov dl, xPosWall[0]
	mov dh, yPosWall[0]
	mov eax,"#"	
	L12: 
	call Gotoxy	
	call WriteChar	
	inc dh
	cmp dh, yPosWall[3]			;left wall
	jl L12



	; draw score
	mov dl,2
	mov dh,1
	call Gotoxy
	mov edx,OFFSET strScore
	call WriteString
	mov eax,0
	call WriteInt	

	mov dl,100				;player choose speed
	mov dh,1
	call Gotoxy	
	mov edx,OFFSET strSpeed
	call WriteString
	mov eax,0
	call readInt			; enter integers (1,2,3) 1-quickest
	mov bx, 150
	mul bx
	mov speed, ax
	add speed, 1000

	mov ecx, 2				;draw snake
	mov ebx,1
L1: 
	call DrawPlayer
	dec ebx
loop L1

	call CreateRandomCoin
	call DrawCoin

	call Randomize				;set up finish

	gameLoop::

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

		; write score
		mov dl,17
		mov dh,1
		call Gotoxy
		mov al,score
		call WriteInt		

		; get user key input
		cmp StartFlag, 1
		je Initialinput
		call ReadKey
            jz noKey		;jump if no key is entered
		processInput:
		mov bl, inputChar
		mov lastInputChar, bl
		mov inputChar,al		;assign var

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

		checkBottom:	
		cmp lastInputChar, "w"
		je dontChgDirection		;cant go down immediately after going up
		mov cl, yPosWall[1]
		dec cl
		cmp yPos[0],cl
		jl moveDown
		je exitGame		;die if go too far down

		checkLeft:		
		cmp lastInputChar, "d"
		je dontChgDirection
		mov cl, xPosWall[0]
		inc cl
		cmp xPos[0],cl
		jg moveLeft
		je exitGame		

		checkRight:		
		cmp lastInputChar, "a"
		je dontChgDirection
		mov cl, xPosWall[2]
		dec cl
		cmp xPos[0],cl
		jl moveRight
		je exitGame		

		checkTop:		
		cmp lastInputChar, "s"
		je dontChgDirection
		mov cl, yPosWall[0]
		inc cl
		cmp yPos,cl
		jg moveUp
		je exitGame		
		
		moveUp:		
		call delayfunc
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
		call CheckSnake

		
		moveDown:
		call delayfunc
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
		call CheckSnake


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
		call CheckSnake


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
		call CheckSnake

jmp gameLoop

dontChgDirection:
	mov inputChar, bl
	jmp noKey

Initialinput:			
	call readChar		;bc program will glitch if use readKey for the first input
	mov StartFlag, 0
	jmp processInput

	exitGame::
	mov speed, 10000
	call delayfunc
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
	mov eax,58
	call RandomRange	;0-59
	add eax, 30			;30-88
	mov xCoinPos,al
	mov eax,19
	call RandomRange	;0-19
	add eax, 5			;5-24
	mov yCoinPos,al
	ret
CreateRandomCoin ENDP


delayfunc PROC			;loops to slow down the prog
	mov bx, 3000
	mov cx, speed
	delay2:
	dec bx
	cmp bx,0 
	jne delay2
	dec cx
	cmp cx,0   
	jne delay2
	ret
delayfunc ENDP

CheckSnake PROC			;check whether the snake head collides w its body 
	cmp score, 3
	jl gameLoop
	mov al, xPos[0] 
	mov ah, yPos[0] 
	mov ebx,4				;start checking from index 4(5th unit)
	mov cl,score
	sub cl,2
L13:
	cmp xPos[ebx], al		;check if xpos same ornot
	je XposSame
	contloop:
	inc ebx
loop L13
	jmp gameLoop
	XposSame:				; if xpos same, check for ypos
	cmp yPos[ebx], al
	je exitGame				;if collides, snake dies
	jmp contloop

CheckSnake ENDP
END main