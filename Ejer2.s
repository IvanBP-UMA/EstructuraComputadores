.set    GPBASE,   0x3F200000
.set    GPFSEL0,  0x00
.set    GPFSEL1,  0x04
.set    GPFSEL2,  0x08
.set    GPSET0,   0x1c
.set GPCLR0, 0x028
.set GPLEV0, 0x034


.set LEDSCONFG1, 0b00000000010000000000101000000000
.SET LEDSCONFG2, 0b00001000000000100000010000000000
.text 
	ldr r0, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r1, =0b00001000000000000000000000000000
        str	r1, [r0, #GPFSEL0] 
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000001000000000000000001001
        str	r1, [r0, #GPFSEL1]  
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000001000000000000001000000
        str	r1, [r0, #GPFSEL2]  
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00001000010000100000111000000000
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 9
		
loop:       
	ldr r1, [r0, #GPLEV0]
	tst r1, #0b00100
	beq encenderSetDeLed1
	tst r1, #0b01000
	beq encenderSetDeLed2
	
	b loop


encenderSetDeLed1:
	ldr r2, =LEDSCONFG1
	ldr r3, =LEDSCONFG2
	str r2, [r0, #GPSET0]
	str r3, [r0, #GPCLR0]
	b loop
	
encenderSetDeLed2:
	ldr r3, =LEDSCONFG1
	ldr r2, =LEDSCONFG2
	str r2, [r0, #GPSET0]
	str r3, [r0, #GPCLR0]
	b loop