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

xPosEql BYTE 1
yPosEql BYTE 1

xdir BYTE "R"
ydir BYTE "NA"

xdirflag BYTE 0

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
;		mov eax, 1
;		add al, score
;		mov snake[eax], "X"
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
		jne bodysameline
		jmp gameLoop

		checkRight:	;snake cant go too far over to the right
		mov cl, 118
		sub cl, score
		cmp xPos[0],cl
		jne bodysameline
		jmp gameLoop

		checkTop:	;snake cant go too far over to the top
		cmp yPos,1
		jne moveUp
		jmp gameLoop

		bodysameline:
		cmp inputChar, "a"
		je moveLeft
		cmp inputChar, "d"
		je moveRight
		cmp inputChar, "s"
		je moveDown
		cmp inputChar, "w"
		je moveUp

		bodydiffdir:

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
		mov ecx, 2
		add cl, score
		mov ebx, 0
		cmp xdir, "R"
		je leftnoupdate
		jne L3
	L3:	
		call UpdatePlayer
		dec xPos[ebx]
		call DrawPlayer
		inc ebx
	loop L3
		cmp xdirflag, 1
		je offxdirflag
		jmp gameLoop
		leftnoupdate:
		dec cl
		mov eax, 0
		add al, score
		mov dl, xPos[eax]
		inc al
		cmp dl, xPos[eax]
		je chgxdirtoL
		jmp L3


		moveRight:
		mov ecx, 2
		add cl, score
		mov ebx, 0
		cmp xdir, "L"
		je rightnoupdate
		jne L2
	L2:	
		call UpdatePlayer
		inc xPos[ebx]
		call DrawPlayer
		inc ebx
	loop L2
		cmp xdirflag, 1
		je offxdirflag
		jmp gameLoop
		rightnoupdate:
		dec cl
		mov eax, 0
		add al, score
		mov dl, xPos[eax]
		inc al
		cmp dl, xPos[eax]
		je chgxdirtoR
		jmp L2

jmp gameLoop

	chgxdirtoL:
	mov xdir,"L"
	mov xdirflag, 1
	jmp L3

	offxdirflag:
	call DrawPlayer
	mov xdirflag, 0
	jmp gameLoop

	chgxdirtoR:
	mov xdir,"R"
	mov xdirflag, 1
	jmp L2

	exitGame:
	exit
INVOKE ExitProcess,0
main ENDP

DrawPlayer PROC
	; draw player at (xPos,yPos):
	mov dl,xPos[ebx]
	mov dh,yPos[ebx]
	call Gotoxy
	mov al, snake[ebx]
	call WriteChar
	ret
DrawPlayer ENDP

UpdatePlayer PROC
	mov dl, xPos[ebx]
	mov dh,yPos[ebx]
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