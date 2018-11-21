	ORG 00H
	LJMP START
	ORG 0003H       ; INT0
	RETI
	ORG 000BH       ; T0_INT
	LJMP T0IN
	ORG 0013H       ; INT1
	RETI
	ORG 001BH       ; T1_INT
	RETI
	ORG 0023H       ; UART_INT
	RETI

START:  MOV A, IP       ; Move IP to ACC, 3 MSBs are undefined on startup
	MOV R2, #5      ; Shift right 5 times to make them 3 LSBs
RRLOOP: RR A
	DJNZ R2, RRLOOP
	MOV R1, #0      ; Number of T0 overflows
	MOV R3, A       ; Seed
	MOV R0, #23      ; Destination array pointer

	MOV TMOD, #00000001B    ; Configure T0 for 16-bit internal clock counter
	MOV TL0, #0B0H      ; 65536 - 3CB0H = 50000
	MOV TH0, #3CH
	MOV IE, #10000010B
	SETB TR0        ; Start timer 0

INF:    LJMP INF

T0IN:
	MOV A, R1
	INC A
	CJNE A, #20, SKIP
	CALL PRNG
	MOV A, #0
SKIP:   MOV R1, A
	MOV TL0, #0B0H
	MOV TH0, #3CH
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