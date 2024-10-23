.include "inter.inc"
.data
GLOBAL: .word 0x0
	      /*10987654321098765432109876543210*/
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
		   /*xx999888777666555444333222111000*/
	ldr r1, =0b00001000000000000000000000000000
	str r1, [r0, #GPFSEL0]
	ldr r1, =0b00000000001000000000000000001001
	str r1, [r0, #GPFSEL1]
	ldr r1, =0b00000000001000000000000001000000
	str r1, [r0, #GPFSEL2]

	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	ldr r2, =6000000
	add r1, r2
	str r1, [r0, #STC3]


	ldr r0, =INTBASE
	mov r1, #0b01000
	str r1, [r0, #INTENIRQ1]
	mov r0, #0b01010011
	msr cpsr_c, r0
	ldr r2, =LEDS1
	ldr r3, =LEDS2
bucle: 
	ldr r0, =GLOBAL
	ldr r0, [r0]
	ands r0, #0x1
	beq bucle
	ldr r0, =STBASE
	ldr r1, =1000000
	ldr r4, =GPBASE
main:
	str r2, [r4, #GPSET0]
	str r3, [r4, #GPCLR0]
	bl wait
	str r3, [r4, #GPSET0]
	str r2, [r4, #GPCLR0]
	bl wait
	b main

wait:
	push {r4, r5}
	ldr r4, [r0, #STCLO]
	add r4, r1
	bc:
		ldr r5, [r0, #STCLO]
		cmp r5, r4
		blt bc
		pop {r4, r5}
		bx lr

irq_handler:
	push {r0, r1}

	ldr r0, =GLOBAL
	ldr r1, =0x1
	str r1, [r0]
	
	ldr r0, =STBASE
	mov r1, #0b01000
	str r1, [r0, #STCS]
	
	pop {r0, r1}
	subs pc, lr, #4	







