.set    GPBASE,   0x3F200000
.set    GPFSEL0,  0x00
.set    GPFSEL1, 0x04
.set    GPFSEL2, 0x08
.set    GPSET0, 0x1c
.set    GPCLR0, 0x28
.set    STBASE,   0x3F003000
.set    STCLO,          0x04

/* guia bits 2 10987654321098765432109876543210*/
.set  LEDS1, 0b00000000010000000000101000000000
.set  LEDS2, 0b00001000000000100000010000000000

.text
	mov 	r0, #0b11010011
	msr	cpsr_c, r0
	mov 	sp, #0x8000000	@ Inicializ. pila en modo SVC
	
	ldr r0, = GPBASE
/* guia bits   xx999888777666555444333222111000*/
	ldr r1, =0b00001000000000000000000000000000
	str r1, [r0, #GPFSEL0]
/* guia bits 2 xx999888777666555444333222111000*/
	ldr r1, =0b00000000001000000000000000001001
	str r1, [r0, #GPFSEL1]
/* guia bits 3 xx999888777666555444333222111000*/
	ldr r1, =0b00000000001000000000000001000000
	str r1, [r0, #GPFSEL2]
/* guia bits 2 10987654321098765432109876543210*/
	ldr r1, =LEDS1
	str r1, [r0, #GPSET0]

ldr r0, =STBASE
ldr r1, =1000000
ldr r4, =GPBASE

loop: bl timer
		ldr r5, =LEDS1
		str r5, [r4, #GPCLR0]
		ldr r5, =LEDS2
		str r5, [r4, #GPSET0]
		bl timer
		ldr r5, =LEDS2
		str r5, [r4, #GPCLR0]
		ldr r5, = LEDS1
		str r5, [r4, #GPSET0]
		b loop

timer: push {r4, r5}
	ldr r4, [r0, #STCLO]
	add r4, r4, r1
	wait: ldr r5, [r0, #STCLO]
			cmp r5, r4
			blt wait
	pop {r4, r5}
	bx lr