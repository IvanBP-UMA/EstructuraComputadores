.set    GPBASE,   0x3F200000
.set    GPFSEL0,  0x00
.set    GPSET0, 0x1c
.set    GPCLR0, 0x28
.set    STBASE,   0x3F003000
.set    STCLO,          0x04

.text
	mov 	r0, #0b11010011
	msr	cpsr_c, r0
	mov 	sp, #0x8000000	@ Inicializ. pila en modo SVC
	
	ldr r0, = GPBASE
/* guia bits   xx999888777666555444333222111000*/
    ldr r1, =0b00000000000000000001000000000000
    str r1, [r0, #GPFSEL0]

ldr r0, =STBASE
ldr r1, =956
ldr r4, =GPBASE
mov r5, #0b10000

loop: bl timer
    str r5, [r4, #GPSET0]
    bl timer
    str r5, [r4, #GPCLR0]
    b loop

timer: push {r4, r5}
	ldr r4, [r0, #STCLO]
	add r4, r4, r1
	wait: ldr r5, [r0, #STCLO]
			cmp r5, r4
			blt wait
	pop {r4, r5}
	bx lr