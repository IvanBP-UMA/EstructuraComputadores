.include "inter.inc"
.data
GLOBAL: .word 0x0
.set LEDS1, 0b00000000010000000000101000000000
.set LEDS2, 0b00001000000000100000010000000000
.text 
	mov r0, #0
	ADDEXC 0x18, irq_handler

	mov r0, #0b11010010
	msr cpsr_c, r0
	mov sp, #0x8000

	mov r0, #0b11010011
	msr cpsr_c, r0
	mov sp, #0x8000000

	ldr r0, =GPBASE
		   /*xx999888777666555444333222111000	*/
	ldr r1, =0b00001000000000000000000000000000
	str r1, [r0, #GPFSEL0]
	ldr r1, =0b00000000001000000000000000001001
	str r1, [r0, #GPFSEL1]
	ldr r1, =0b00000000001000000000000001000000
	str r1, [r0, #GPFSEL2]

	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	ldr r2, =500000
	add r1, r2
	str r1, [r0, #STC3]


	ldr r0, =INTBASE
	mov r1, #0b01000
	str r1, [r0, #INTENIRQ1]
	mov r0, #0b01010011
	msr cpsr_c, r0
bucle: b bucle

irq_handler:
	push {r0, r1, r2, r3}
	ldr r0, =GLOBAL
	ldr r1, [r0]
	eors r1, #0x1
	str r1, [r0]
	ldr r0, =GPBASE
	ldr r2, =LEDS1
	ldr r3, =LEDS2
	streq r2, [r0, #GPSET0]
	streq r3, [r0, #GPCLR0]
	strne r3, [r0, #GPSET0]
	strne r2, [r0, #GPCLR0]	

	ldr r0, =STBASE

	mov r1, #0b01000
	str r1, [r0, #STCS]

	ldr r1, [r0, #STCLO]
	ldr r2, =500000
	add r1, r2
	str r1, [r0, #STC3]

	pop {r0, r1, r2, r3}
	subs pc, lr, #4	
