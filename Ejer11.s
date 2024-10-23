.include "inter.inc"
.data
	ledsArr: .word 0b00000000000000000000001000000000, 0b00000000000000000000010000000000, 0b00000000000000000000100000000000, 0b00000000000000100000000000000000, 0b00000000010000000000000000000000, 0b00001000000000000000000000000000
	size: .word 6
	counter: .word 0
	previous_action: .word 0 	/*0 if turn off, 1 if turn on*/

.set LEDS, 0b00001000010000100000111000000000

.text
/* Agrego vector interrupcion */
	mov r0, #0
	ADDEXC  0x18, irq_handler
	mov r0, #0
	ADDEXC 0x1C, fiq_handler

/* Inicializo la pila en modos IRQ y SVC */
        mov     r0, #0b11010010   @ Modo IRQ, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000
	mov r0, #0b11010001
	msr cpsr_c, r0
	mov sp, #0x4000
        mov     r0, #0b11010011   @ Modo SVC, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000000

/* Configuro GPIO LEDS como salida */
        ldr     r0, =GPBASE
/* guia bits       xx999888777666555444333222111000*/
	ldr r1, =0b00001000000000000001000000000000
	str r1, [r0, #GPFSEL0]
/* guia bits 2     xx999888777666555444333222111000*/
	ldr r1, =0b00000000001000000000000000001001
	str r1, [r0, #GPFSEL1]
/* guia bits 3     xx999888777666555444333222111000*/
	ldr r1, =0b00000000001000000000000001000000
	str r1, [r0, #GPFSEL2]
	
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	ldr r2, =200000
	add r1, r2
	str r1, [r0, #STC3]
	
	ldr r1, [r0, #STCLO]
	ldr r2, =1136
	add r1, r2
	str r1, [r0, #STC1]
	
	ldr r0,=INTBASE
	mov r1, #0b1000
	str r1,[r0,#INTENIRQ1]
	
	mov r1, #0b10000001
	str r1, [r0, #INTFIQCON]
	
	mov r1, #0b00010011
	msr cpsr_c, r1
	
bucle: b bucle

irq_handler: push {r0, r1, r2, r3}
	ldr r0, =ledsArr
	ldr r1, =size
	ldr r1, [r1]
	ldr r2, =counter
	ldr r2, [r2]
	cmp r2, r1
	moveq r2, #0
	
	ldr r3, [r0, r2, LSL#2]
	ldr r0, =GPBASE
	ldr r1, =LEDS
	str r1, [r0, #GPCLR0]
	str r3, [r0, #GPSET0]
	
	ldr r1, =counter
	add r2, #1
	str r2, [r1]
	
	ldr r0, =STBASE
	mov r1, #0b01000
	str r1, [r0, #STCS]
	
	ldr r1, [r0, #STCLO]
	ldr r2, =200000
	add r1, r2
	str r1, [r0, #STC3]

	pop {r0, r1, r2, r3}
	subs    pc, lr, #4 
	
fiq_handler: push {r0, r1, r2, r3}
	
	ldr r0, =GPBASE
	ldr r3, =previous_action
	ldr r3, [r3]
	
	cmp r3, #0
	moveq r2, #0b010000
	streq r2, [r0, #GPSET0]
	
	movne r2, #0b010000
	strne r2, [r0, #GPCLR0]
	
	eor r3, #1
	ldr r2, =previous_action
	str r3, [r2]
	
	ldr r0, =STBASE
	mov r1, #0b00010
	str r1, [r0, #STCS]
	
	ldr r1, [r0, #STCLO]
	ldr r2, =1136
	add r1, r2
	str r1, [r0, #STC1]

	pop {r0, r1, r2, r3}
	subs    pc, lr, #4 
