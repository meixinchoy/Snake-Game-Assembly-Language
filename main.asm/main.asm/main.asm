.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode: DWORD
INCLUDE Irvine32.inc

.data

xWall BYTE 60 DUP("#"),0

strScore BYTE "Your score is: ",0
score BYTE 0

str1 BYTE "Try Again?  1=yes, 0=no",0
invalidInput BYTE "invalid input",0
str3 BYTE "you died ",0
str4 BYTE " (Press any key to continue)",0
blank BYTE "                                     ",0

snake BYTE "X", 100 DUP("x")

xPos BYTE 40,39,99 DUP(?)
yPos BYTE 20,20,99 DUP(?)

xPosWall BYTE 29,29,89,89			;position of upperLeft, lowerLeft, upperRight, lowerRignt wall 
yPosWall BYTE 4,25,4,25

xCoinPos BYTE ?
yCoinPos BYTE ?

inputChar BYTE ?
lastInputChar BYTE ?

strSpeed BYTE "Speed (1-fast, 2-medium, 3-slow): ",0
speed	DWORD 0

.code
main PROC
	call DrawWall			;draw walls
	call DrawScoreboard		;draw scoreboard
	call ChooseSpeed		;let player to choose Speed

	mov ebx,1			
	call DrawPlayer			;draw snake(start with 2 units)
	dec ebx
	call DrawPlayer

	call CreateRandomCoin
	call DrawCoin
	call Randomize			;set up finish

	gameLoop::

		mov dl,106						;move cursor to coordinates
		mov dh,1
		call Gotoxy

		; get user key input
		call ReadKey
            jz noKey					;jump if no key is entered
		mov bl, inputChar
		mov lastInputChar, bl
		mov inputChar,al				;assign variables

		noKey:
		cmp inputChar,"x"				;exit game if user input x
		je exitgame

		cmp inputChar,"w"				
		je checkTop

		cmp inputChar,"s"				
		je checkBottom

		cmp inputChar,"a"
		je checkLeft

		cmp inputChar,"d"
		je checkRight
		jne gameLoop					; reloop if user didnt enter any meaningful key


		; check whether can continue moving
		checkBottom:	
		cmp lastInputChar, "w"
		je dontChgDirection				;cant go down immediately after going up
		mov cl, yPosWall[1]
		dec cl							;one unit ubove the y-coordinate of lowerbound
		cmp yPos[0],cl					
		jl moveDown
		je died							;die if crash into the wall

		checkLeft:						
		cmp lastInputChar, "d"
		je dontChgDirection				
		mov cl, xPosWall[0]
		inc cl
		cmp xPos[0],cl
		jg moveLeft
		je died							; check for left	

		checkRight:		
		cmp lastInputChar, "a"
		je dontChgDirection
		mov cl, xPosWall[2]
		dec cl
		cmp xPos[0],cl
		jl moveRight
		je died							; check for right

		checkTop:		
		cmp lastInputChar, "s"
		je dontChgDirection
		mov cl, yPosWall[0]
		inc cl
		cmp yPos,cl
		jg moveUp
		je died							; check for up
		
		; move up
		moveUp:		
		mov eax, speed					;slow down the moving
		add eax, speed
		call delay
		mov ecx, 1
		add cl, score					;number of iterations to print the snake body n tail
		mov ebx, 0						;index 0(snake head)
		call UpdatePlayer	
		mov ah, yPos[ebx]	
		mov al, xPos[ebx]				;alah stores the pos of the snake's next unit 
		dec yPos[ebx]					;move the head up
		call DrawPlayer					
		call DrawBody					
		call CheckSnake
		
		moveDown:						; move down
		mov eax, speed
		add eax, speed
		call delay
		mov ecx, 1
		add cl, score
		mov ebx, 0
		call UpdatePlayer
		mov ah, yPos[ebx]
		mov al, xPos[ebx]
		inc yPos[ebx]
		call DrawPlayer					
		call DrawBody					
		call CheckSnake


		moveLeft:						; move left
		mov eax, speed
		call delay
		mov ecx, 1
		add cl, score
		mov ebx, 0
		call UpdatePlayer
		mov ah, yPos[ebx]
		mov al, xPos[ebx]
		dec xPos[ebx]
		call DrawPlayer					
		call DrawBody					
		call CheckSnake


		moveRight:						; move right
		mov eax, speed
		call delay
		mov ecx, 1
		add cl, score
		mov ebx, 0
		call UpdatePlayer
		mov ah, yPos[ebx]
		mov al, xPos[ebx]
		inc xPos[ebx]
		call DrawPlayer					
		call DrawBody					
		call CheckSnake

	; getting points
		checkcoin::
		mov ebx,0
		mov bl,xPos[0]
		cmp bl,xCoinPos
		jne gameloop
		mov bl,yPos[0]
		cmp bl,yCoinPos
		jne gameloop

		; snake is eating coin
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

		; write score
		mov dl,17
		mov dh,1
		call Gotoxy
		mov al,score
		call WriteInt		

jmp gameLoop

	dontChgDirection:		;dont allow user to change direction
	mov inputChar, bl		;set current inputChar as previous
	jmp noKey				;jump back to continue moving the same direction 

	died::
	mov eax, 1000
	call delay
	Call ClrScr			
	mov dl,	35
	mov dh, 20
	call Gotoxy
	mov edx, OFFSET str3	;"you died"
	call WriteString
	mov edx, OFFSET str4	;"enter any key to cont"
	call WriteString
	call ReadChar
	Call ClrScr
	mov dl,	50
	mov dh, 20
	call Gotoxy
	mov edx, OFFSET str1
	call WriteString		;"try again?"
	invalidnum:
	mov dl,	56
	mov dh, 21
	call Gotoxy
	mov edx, OFFSET blank
	call WriteString
	mov dh, 21
	mov dl,	56
	call Gotoxy
	call ReadInt
	cmp al, 1
	je playagn				;playagn
	cmp al, 0
	je exitgame				;exitgame
	mov dh,	19
	call Gotoxy
	mov edx, OFFSET invalidInput	
	call WriteString		;invalid num
	jmp invalidnum


	;reinitialise everything
	playagn:			
	mov xPos[0], 40
	mov xPos[1], 39
	mov yPos[0], 20
	mov yPos[1], 20
	mov score,0
	mov lastInputChar, 0
	mov inputChar,0
	dec yPosWall[3]
	Call ClrScr
	jmp main
	
	exitgame:
	exit
INVOKE ExitProcess,0
main ENDP


DrawWall PROC					;procedure to draw wall
	mov dl,xPosWall[0]
	mov dh,yPosWall[0]
	call Gotoxy	
	mov edx,OFFSET xWall
	call WriteString			;draw upper wall

	mov dl,xPosWall[1]
	mov dh,yPosWall[1]
	call Gotoxy	
	mov edx,OFFSET xWall		
	call WriteString			;draw lower wall

	mov dl, xPosWall[2]
	mov dh, yPosWall[2]
	mov eax,"#"	
	inc yPosWall[3]
	L11: 
	call Gotoxy	
	call WriteChar	
	inc dh
	cmp dh, yPosWall[3]			;draw right wall	
	jl L11

	mov dl, xPosWall[0]
	mov dh, yPosWall[0]
	mov eax,"#"	
	L12: 
	call Gotoxy	
	call WriteChar	
	inc dh
	cmp dh, yPosWall[3]			;draw left wall
	jl L12
	ret
DrawWall ENDP


DrawScoreboard PROC				;procedure to draw scoreboard
	mov dl,2
	mov dh,1
	call Gotoxy
	mov edx,OFFSET strScore		;print string that indicates score
	call WriteString
	mov eax,"0"
	call WriteChar				;scoreboard starts with 0
	ret
DrawScoreboard ENDP


ChooseSpeed PROC			;procedure for player to choose speed
	mov edx,0
	mov dl,71				
	mov dh,1
	call Gotoxy	
	mov edx,OFFSET strSpeed	; prompt to enter integers (1,2,3)
	call WriteString
	mov ebx, 36				;36milisecond difference per speed level
	mov eax,0
	call readInt			
	cmp ax,1				;input validation
	jl invalidspeed			
	cmp ax, 3
	jg invalidspeed			
	mul ebx
	mov speed, eax			;assign speed variable in mililiseconds
	ret						;return if speed has been chosen

	invalidspeed:			;jump here if user entered invalid input
	mov dl,105				
	mov dh,1
	call Gotoxy	
	mov edx, OFFSET invalidInput		;print error message
	call WriteString		
	mov ax, 1500
	call delay				
	mov dl,105				
	mov dh,1
	call Gotoxy	
	mov edx, OFFSET blank	;erase error message after 1.5 secs of delay
	call writeString		
	call ChooseSpeed		;call procedure again for user to choose speed
	ret
ChooseSpeed ENDP


DrawPlayer PROC
	mov dl,xPos[ebx]	; draw player at (xPos,yPos)
	mov dh,yPos[ebx]
	call Gotoxy
	mov dl, al			;temporarily save al in dl
	mov al, snake[ebx]		
	call WriteChar
	mov al, dl			
	ret
DrawPlayer ENDP


UpdatePlayer PROC
	mov dl, xPos[ebx]	; erase player at (dl,dh)
	mov dh,yPos[ebx]
	call Gotoxy
	mov dl, al			;temporarily save al in dl
	mov al, " "
	call WriteChar
	mov al, dl
	ret
UpdatePlayer ENDP


DrawCoin PROC						;procedure to draw coin
	mov eax,yellow (yellow * 16)
	call SetTextColor				;set color to yellow for coin
	mov dl,xCoinPos
	mov dh,yCoinPos
	call Gotoxy						;go to position of coin
	mov al,"X"		
	call WriteChar					;draw coin
	mov eax,white (black * 16)
	call SetTextColor				;reset color to black and white
	ret
DrawCoin ENDP


CreateRandomCoin PROC		;procedure to create a random coin
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


DrawBody PROC				;procedure to print body of the snake
	printbodyloop:	
		inc ebx				;loop to print remaining units of snake
		call UpdatePlayer
		mov dl, xPos[ebx]
		mov dh, yPos[ebx]	;dldh temporarily stores the current pos of the unit 
		mov yPos[ebx], ah
		mov xPos[ebx], al	;assign new position to the unit
		mov al, dl
		mov ah,dh			;move the current position back into alah
		call DrawPlayer
	loop printbodyloop
	ret
DrawBody ENDP


CheckSnake PROC			;check whether the snake head collides w its body 
	cmp score, 3
	jl checkcoin			; snake with less than 5 units cant collide with itself
	mov al, xPos[0] 
	mov ah, yPos[0] 
	mov ebx,4				;start checking from index 4(5th unit)
	mov cl,score
	sub cl,2				;loop score-2 times from the 5th to the last unit of snake
L13:
	cmp xPos[ebx], al		;check if xpos same ornot
	je XposSame
	contloop:
	inc ebx
loop L13
	jmp checkcoin			; jump to return if no collision
	XposSame:				; if xpos same, check for ypos
	cmp yPos[ebx], ah
	je died					;if collides, snake dies
	jmp contloop			;continue loop to check whether the other snake units collide with the head
	jmp checkcoin
CheckSnake ENDP
END main