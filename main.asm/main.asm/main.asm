.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode: DWORD
INCLUDE Irvine32.inc

.data

ground BYTE "------------------------------------------------------------------------------------------------------------------------",0

strScore BYTE "Your score is: ",0
score BYTE 0

xPos BYTE 20
yPos BYTE 20

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

	call DrawPlayer

	call CreateRandomCoin
	call DrawCoin

	call Randomize

	gameLoop:

		; getting points:
		mov bl,xPos
		cmp bl,xCoinPos
		jne notCollecting
		mov bl,yPos
		cmp bl,yCoinPos
		jne notCollecting
		; player is intersecting coin:
		inc score
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

		checkBottom:	;snake cant go under the bottom line
		cmp yPos,28
		jne moveDown
		jmp gameLoop

		checkLeft:	;snake cant go too far over to the left

		jne moveLeft
		jmp gameLoop

		checkRight:	;snake cant go too far over to the right
		mov cl, 118
		sub cl, score

		jne moveRight
		jmp gameLoop

		checkTop:	;snake cant go too far over to the top
		cmp yPos,1
		jne moveUp
		jmp gameLoop

		moveUp:
		call UpdatePlayer
		dec yPos
		call DrawPlayer
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

	jmp gameLoop

	exitGame:
	exit
INVOKE ExitProcess,0
main ENDP

DrawPlayer PROC
	; draw player at (xPos,yPos):
	mov dl,xPos
	mov dh,yPos
	call Gotoxy
	mov al, "X"
	call WriteChar
	ret
DrawPlayer ENDP

UpdatePlayer PROC
	mov dl,xPos
	mov dh,yPos
	call Gotoxy
	mov al, " "
	call WriteChar
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