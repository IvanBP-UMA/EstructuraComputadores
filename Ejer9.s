.include "inter.inc"
.data
ledsarr: .word 0b00000000000000000000001000000000, 0b00000000000000000000010000000000, 0b00000000000000000000100000000000, 0b00000000000000100000000000000000, 0b00000000010000000000000000000000, 0b00001000000000000000000000000000
size: .word 6
global: .word 1
.set ALL_LEDS , 0b00001000010000100000111000000000
.set TIME, 200000
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
		   //xx999888777666555444333222111000	
	ldr r1, =0b00001000000000000000000000000000
	str r1, [r0, #GPFSEL0]
	ldr r1, =0b00000000001000000000000000001001
	str r1, [r0, #GPFSEL1]
	ldr r1, =0b00000000001000000000000001000000
	str r1, [r0, #GPFSEL2]

	mov r1, #0b00000000000000000000000000001100
	str r1, [r0, #GPFEN0]

	ldr r0, =INTBASE
	mov r1, #0b00000000000100000000000000000000
	str r1, [r0, #INTENIRQ2]
	mov r0, #0b01010011
	msr cpsr_c, r0
main:
	
	ldr r2, =ledsarr
	mov r4, #0
	bucle: 
		ldr r0, =GPBASE
		ldr r1, =size
		ldr r1, [r1]
		cmp r4, r1
		moveq r4, #0
		ldr r3, [r2, r4, LSL#2]
		
		ldr r5, =ALL_LEDS

		//el eor es para borrar todas menos la actual
		eor r5, r3
		str r5, [r0, #GPCLR0]
		str r3, [r0, #GPSET0]


		 // sumar la variable global para seguir o parar
		ldr r5, =global
		ldr r5, [r5]		
		add r4, r4, r5
		
		//falta solo el bl wait
		ldr r0, =STBASE
		ldr r1, =200000
		bl timer
		b bucle


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
	ldr r0, =GPBASE
	ldr r2, =global
	ldr r1, [r0, #GPEDS0]
	
	ands r1, #0b00100
	movne r3, #1
	strne r3, [r2]
	movne r1, #0b00100
	strne r1, [r0, #GPEDS0]

	ldr r1, [r0, #GPEDS0]
	ands r1, #0b01000
	movne r3, #0
	strne r3, [r2]
	movne r1, #0b01000
	strne r1, [r0, #GPEDS0]

	
	pop {r0, r1, r2, r3}
	subs pc, lr, #4	
