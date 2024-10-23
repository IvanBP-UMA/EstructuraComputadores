.include "inter.inc"
.data
ledsarr: .word 0b00000000000000000000001000000000, 0b00000000000000000000010000000000, 0b00000000000000000000100000000000, 0b00000000000000100000000000000000, 0b00000000010000000000000000000000, 0b00001000000000000000000000000000
soundarr: .word 1706, 1706, 1515, 1706, 1276, 1351, 1706, 1706, 1515, 1706, 1136, 1276, 1706, 1706, 851, 1012, 1276, 1351, 1515, 956, 956, 1012, 1276, 1136, 1276
currentLed: .word 0
currentSound: .word 0
currentSoundTimer: .word 1136
global: .word 1
stop: .word 1
.set ALL_LEDS , 0b00001000010000100000111000000000
.set TIME, 200000
.text 
	mov r0, #0
	ADDEXC 0x18, irq_handler
	ADDEXC 0x1c, fiq_handler
	//FIQ SETUP	
	mov r0, #0b11010001	
	msr cpsr_c, r0
	mov sp, #0x4000

	//IRQ SETUP
	mov r0, #0b11010010
	msr cpsr_c, r0
	mov sp, #0x8000

	//SVC SETUP
	mov r0, #0b11010011
	msr cpsr_c, r0
	mov sp, #0x8000000

	ldr r0, =GPBASE
		   //  xx999888777666555444333222111000	
	ldr r1, =0b00001000000000000001000000000000
	str r1, [r0, #GPFSEL0]
	ldr r1, =0b00000000001000000000000000001001
	str r1, [r0, #GPFSEL1]
	ldr r1, =0b00000000001000000000000001000000
	str r1, [r0, #GPFSEL2]
	
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	ldr r2, =1136
	add r1, r2
	str r1, [r0, #STC1]
	ldr r1, [r0, #STCLO]
	ldr r2, =400000
	add r1, r2
	str r1, [r0, #STC3]

	
	ldr r0, =INTBASE
	mov r1, #0b01000
	str r1, [r0, #INTENIRQ1]
	mov r1, #0b10000001
	str r1, [r0, #INTFIQCON]
	mov r0, #0b00010011
	msr cpsr_c, r0
	
	ldr r0, =GPBASE
	ldr r2, =stop
	ldr r3, [r2]
loop:	
	ldr r1, [r0, #GPLEV0]
	tst r1, #0b00100
	moveq r3, #1
	tst r1, #0b01000
	moveq r3, #0

	str r3, [r2]
	b loop
	
	

timer: push {r4, r5}
	ldr r4, [r0, #STCLO]
	add r4, r4, r1
	wait: ldr r5, [r0, #STCLO]
			cmp r5, r4
			blt wait
	pop {r4, r5}
	bx lr
	
	
irq_handler:
	push {r0, r1, r2, r3}
	ldr r0, =ledsarr
	ldr r1, =currentLed
	ldr r2, [r1]
	ldr r3, [r0, r2, LSL#2]
	ldr r0, =GPBASE

	//apagar el ultimo estado
	str r3, [r0, #GPCLR0]

	//Actualizar y salvar current al siguiente estado
	ldr r3, =stop
	ldr r3, [r3]
	cmp r3, #1
	addeq r2, #1
	cmp r2, #6
	moveq r2, #0
	str r2, [r1]
	
	ldr r0, =ledsarr
	ldr r3, [r0, r2, LSL#2]
	ldr r0, =GPBASE
	str r3, [r0, #GPSET0]
	
	//actualizo el sonido nuevo 
	
	ldr r0, =soundarr
	ldr r1, =currentSound
	ldr r2, [r1]
	ldr r3, =stop
	ldr r3, [r3]
	cmp r3, #1
	addeq r2, #1
	cmp r2, #25
	moveq r2, #0
	str r2, [r1]
	ldr r3, [r0, r2, LSL#2]
	ldr r0, =currentSoundTimer
	str r3, [r0]

	ldr r0, =STBASE
	mov r1, #0b01000
	str r1, [r0, #STCS]
	
	ldr r1, [r0, #STCLO]
	ldr r2, =400000
	add r1, r2
	str r1, [r0, #STC3]
	pop {r0, r1, r2, r3}
	subs pc, lr, #4


fiq_handler:
	push {r0, r1, r2}
	ldr r0, =global
	ldr r1, [r0]
	eors r1, #0x1
	str r1, [r0]
	mov r2, #0b010000
	ldr r0, =GPBASE
	streq r2, [r0, #GPSET0]
	strne r2, [r0, #GPCLR0]
	
	ldr r0, =STBASE
	mov r1, #0b010
	str r1, [r0, #STCS]

	ldr r1, [r0, #STCLO]
	ldr r2, =currentSoundTimer
	ldr r2, [r2]
	add r1, r2
	str r1, [r0, #STC1]
	pop {r0, r1, r2}
	subs pc, lr, #4