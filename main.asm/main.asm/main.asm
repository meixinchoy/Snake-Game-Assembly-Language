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

	call Randomize

	gameLoop:

		; getting points:
		mov ebx,0
		mov bl,xPos[0]
		cmp bl,xCoinPos
		jne notCollecting
		mov bl,yPos[0]
		cmp bl,yCoinPos
		jne notCollecting
		; player is intersecting coin:
		inc score
		mov ebx, 1
		add bl, score
		mov snake[ebx], "x"
		mov ah, yPos[ebx-1]
		mov al, xPos[ebx-1]
		mov xPos[ebx], al
		mov yPos[ebx], ah

		cmp xPos[ebx-2], al
		jne checky

		cmp yPos[ebx-2], ah
		jl incy
		jg decy
		incy:
		inc yPos[ebx]
		jmp continue
		decy:
		dec yPos[ebx]
		jmp continue

		checky:
		cmp yPos[ebx-2], ah
		jl incx
		jg decx
		incx:
		inc xPos[ebx]
		jmp continue
		decx:
		dec xPos[ebx]
		jmp continue

		continue:
		call UpdatePlayer
		call DrawPlayer
		call CreateRandomCoin
		call DrawCoin
		notCollecting:

		mov eax,white (black * 16)
		call SetTextColor

		; draw score:
		mov dl,0
		mov dh,0
		call Gotoxy
		mov edx,OFFSET strScore
		call WriteString
		mov al,score
		call WriteInt		

		; get user key input:
		call ReadChar
		mov inputChar,al

		; exit game if user types 'x':
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
		cmp yPos,28
		jne moveDown
		jmp gameLoop

		checkLeft:	;snake cant go too far over to the left
		cmp xPos[0],1
		jne moveLeft
		jmp gameLoop

		checkRight:	;snake cant go too far over to the right
		mov cl, 118
		sub cl, score
		cmp xPos[0],cl
		jne moveRight
		jmp gameLoop

		checkTop:	;snake cant go too far over to the top
		cmp yPos,1
		jne moveUp
		jmp gameLoop


		moveUp:
		mov ecx, 1
		add cl, score
		mov ebx, 0
		call UpdatePlayer
		mov ah, yPos[ebx]
		mov al, xPos[ebx]
		dec yPos[ebx]
		call DrawPlayer
	L5:	
		inc ebx
		call UpdatePlayer
		mov dl, xPos[ebx]
		mov dh, yPos[ebx]
		mov yPos[ebx], ah
		mov xPos[ebx], al
		mov al, dl
		mov ah,dh
		call DrawPlayer
	loop L5
		jmp gameLoop



		moveDown:
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

	exitGame:
	exit
INVOKE ExitProcess,0
main ENDP

DrawPlayer PROC
	; draw player at (xPos,yPos):
	mov dl,xPos[ebx]
	mov dh,yPos[ebx]
	call Gotoxy
	mov dl, al
	mov al, snake[ebx]
	call WriteChar
	mov al, dl
	ret
DrawPlayer ENDP

UpdatePlayer PROC
	mov dl, xPos[ebx]
	mov dh,yPos[ebx]
	call Gotoxy
	mov dl, al
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
	call RandomRange
	inc eax
	mov xCoinPos,al
	mov eax,28
	call RandomRange
	inc eax
	mov yCoinPos,al
	ret
CreateRandomCoin ENDP

leftloop PROC
	L3:	
		call UpdatePlayer
		dec xPos[ebx]
		call DrawPlayer
		inc ebx
	loop L3
leftloop ENDP

END main


; gravity logic:
;		gravity:
;		cmp yPos,27
;		jg onGround
; make player fall:
;		call UpdatePlayer
;		inc yPos
;		call DrawPlayer
;		mov eax,80
;		call Delay
;		jmp gravity
;		onGround:

;allow player to jump
;		moveUp:
;		; allow player to jump:
;		mov ecx,1
;		jumpLoop:
;			call UpdatePlayer
;			dec yPos
;			call DrawPlayer
;			mov eax,70
;			call Delay
;		loop jumpLoop
;		jmp gameLoop




;	checkMovement:
;		mov xPosEql,1
;		mov yPosEql,1
;		mov cx, 2
;		add cl, score
;	L6:
;		mov ebx,0
;		mov bl, cl
;		dec bl
;		mov al, xPos[ebx] 
;		dec bl
;		cmp xPos[ebx], al 
;		jne breakx
;	loop L6
;		mov cx, 2
;		add cl, score
;	L7:
;		mov ebx,0
;		mov bl, cl
;		dec bl
;		mov al, yPos[ebx] 
;		dec bl
;		cmp yPos[ebx], al 
;		jne breaky
;	loop L7
;		jmp snakeLineCmp
;
;		snakeLineCmp:
;		cmp xPosEql, 1
;		je bodysamedir
;		mov yPosEql,1
;		je bodysamedir
;		jne bodydiffdir
;
;		breakx:
;		mov xPosEql,0
;		jmp L7
;		
;		breaky:
;		mov yPosEql,0
;		jmp snakeLineCmp
;

