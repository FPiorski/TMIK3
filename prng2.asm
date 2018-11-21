; TMIK LAB 3 - generate a random number between 0 and 9, output it in bcd and save it to memory

	ORG 00H
	LJMP START
	ORG 0003H       ; INT0
	RETI
	ORG 000BH       ; T0_INT
	LJMP T0IN
	ORG 0013H       ; INT1
	RETI
	ORG 001BH       ; T1_INT
	LJMP T1IN
	ORG 0023H       ; UART_INT
	RETI

START:  MOV A, IP       ; Move IP to ACC, 3 MSBs are undefined on startup
	MOV R2, #5      ; Shift right 5 times to make them 3 LSBs
RRLOOP: RR A
	DJNZ R2, RRLOOP
	; Or just swap ACC nibbles and RR A one time
	; (Didn't know about SWAP when I wrote this)

	MOV R3, A       ; Seed
	MOV R0, #23     ; Destination array pointer

	MOV TMOD, #00100001B
	; Configure T0 for 16-bit internal clock counter (timer) operation
	; Configure T1 to be an 8-bit timer with autoreloading on overflow
	MOV TL0, #0B0H        ; 65536 - 3CB0H = 50000
	MOV TH0, #3CH
	MOV TH1, #0ECH        ; Load TL1 with TH1 after every TL1 overflow
	MOV TL1, #0ECH
	MOV IE, #10001010B    ; Enable Timer 0 & 1 interrupts
	SETB TR0	      ; Start timer 0
	CLR TR1	              ; Make sure timer 1 is disabled

INF:    LJMP INF

T0IN:
	SETB TR1              ; Enable timer 1 for one clock cycle
	CLR TR1
	MOV TL0, #0B0H        ; Reload timer 0
	MOV TH0, #0FFH
	RETI

T1IN:
	CALL PRNG
	RETI

PRNG:   MOV A, R3
	JNZ NOCPL
	CPL A
	MOV R3, A
NOCPL:  ANL A, #10111000B
	MOV C, P
	MOV A, R3
	RLC A
	MOV R3, A       ; New seed
	DEC A
	ANL A, #0FH     ; Leave only the four lest significant bits
	CJNE A, #10, DUMMY  ; Carry is set when A < 10
DUMMY:  JC NOADJ
	SUBB A, #6
NOADJ:  MOV P1, A
	MOV @R0, A
	INC R0
	CJNE R0, #31, NOZERO
	MOV R0, #23
NOZERO: RET

END
