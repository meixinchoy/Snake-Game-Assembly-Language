.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode: DWORD
INCLUDE Irvine32.inc

.data
	;define variables here

.code
main PROC
	;write assembly code here

INVOKE ExitProcess,0
main ENDP
END main