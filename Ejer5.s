.set    GPBASE,   0x3F200000
.set    GPFSEL0,  0x00
.set    GPFSEL1,  0x04
.set    GPFSEL2,  0x08
.set    GPSET0,   0x1c
.set GPCLR0, 0x028
.set GPLEV0, 0x034
.set STBASE, 0x3F003000
.set STCLO, 0x04

/* guia bits 2 10987654321098765432109876543210*/
.set  LEDS1, 0b00000000010000000000101000010000
.set  LEDS2, 0b00001000000000100000010000000000

.text
	mov r0, #0b11010011
	msr cpsr_c, r0
	mov sp, #0x8000000
	
	ldr r0, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r1, =0b00001000000000000001000000000000
        str	r1, [r0, #GPFSEL0] 
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000001000000000000000001001
        str	r1, [r0, #GPFSEL1]  
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000001000000000000001000000
        str	r1, [r0, #GPFSEL2]
	
	ldr r4, =LEDS1
	ldr r5, =LEDS2
	ldr r2, =GPBASE	
	
initialLoop: ldr r0, [r2, #GPLEV0]
	tst r0, #0b100
	moveq r0, #0
	beq setLEDS1
	tst r0, #0b1000
	moveq r0, #1
	beq setLEDS2
	b initialLoop

	
loop: bl timer
	
	eor r4, #0b010000
	eor r5, #0b010000
	ldr r2, =GPBASE	
	cmp r0, #1
	beq setLEDS2
	setLEDS1: str r5, [r2, #GPCLR0] 
		str r4, [r2, #GPSET0]
		ldr r1, =1908
		b loop
	
	setLEDS2: str r4, [r2, #GPCLR0]
		str r5, [r2, #GPSET0]
		ldr r1, =1279
		b loop



timer:  push {r4, r5}
	ldr r2, =STBASE
	ldr r3, [r2, #STCLO]
	add r3, r3, r1
	ldr r5, =GPBASE
	
	wait:   ldr r4, [r2, #STCLO]
		ldr r1, [r5, #GPLEV0]
		tst r1, #0b100
		moveq r0, #0
		tst r1, #0b1000
		moveq r0, #1
		
		cmp r4, r3
		blt wait
		
	pop {r4, r5}
	bx lr