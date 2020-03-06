;
; FinalProject.asm
;
; Created: 12-02-2020 18:27:18
; Author : SANKET
;

.include "M32DEF.INC"
.EQU H0 = 0x02 ;filter cofficient from matlab fda tool
.EQU H1 = 0x07 ; original cofficients multiplied by 255
.EQU H2 = 0x0A
.EQU H3 = 0x07
.EQU H4 = 0x02
rjmp main
.org $016
	rjmp timint ; called when the timer overflows

.org $020
	rjmp adcint ;called when the adc completes conversion

.org 40
main:
	ldi r16,high(ramend)
	out sph,r16
	ldi r16,low(ramend)
	out spl,r16

	ldi r16,$FF
	out ddrb,r16
	ldi r16,0
	out ddra,r16
	
	sei
	
	ldi r16,1
	out timsk,r16
	ldi r16,0
	out tcnt0,r16
	ldi r16,$E1 ;11100001 ADC 1 IS THE INPUT
	out admux,r16     ;
	ldi r16,$87
	out adcsra,r16    ; DIVISION FACTOR 128, ENABLED, INTERRUPT ENABLED
	ldi r22, 0x00 ;Convolution bits
	ldi r23, 0x00
	ldi r24, 0x00
	ldi r25, 0x00
	ldi r26, 0x00
	ldi r27, 0x00
	ldi r29, 0x00
	ldi r16,1
	out tccr0,r16 ; no prescaling
	sbi adcsra,adsc ; start conversion
	loop:
		rjmp loop
adcint:
	ldi r16,$87
	out adcsra, r16
	reti
timint:
	
	in r20, adcl
	in r21, adch
	sbi adcsra,adsc
	ldi r28, H0 ;Load filter coefficient H0
	mov r22, r21
	mul r28, r22 ; 2 Clock cycle multiplication r1:r0 = r28*r22
	add r29, r0
	adc r30, r1


	ldi r28, H1 ;Load filter coefficient H1
	mul r28, r23 ; 2 Clock cycle multiplication r1:r0 = r28*r23
	add r29, r0
	adc r30, r1

	ldi r28, H2 ;Load filter coefficient H2
	mul r28, r24 ; 2 Clock cycle multiplication r1:r0 = r28*r24
	add r29, r0
	adc r30, r1

	ldi r28, H3 ;Load filter coefficient H3
	mul r28, r25 ; 2 Clock cycle multiplication r1:r0 = r28*r25
	add r29, r0
	adc r30, r1

	ldi r28, H4 ;Load filter coefficient H4
	mul r28, r26 ; 2 Clock cycle multiplication r1:r0 = r28*r26
	add r29, r0
	adc r30, r1
	/*
	ldi r28, H5 ;Load filter coefficient H5
	mul r28, r27 ; 2 Clock cycle multiplication r1:r0 = r28*r27
	add r29, r0
	adc r30, r1
	*/

	out portb, r30 ;Put result at DAC inpput port which is connected to portb IN this case
	/* The whole result is in R30(Most significant byte) and R29(Least significant byte)
	Since initially we had multiplied in coeffieient by 256, so at last we will have to divide by 256.
	For this we can Right shift result 8 positions to divide the result by 256. If we Right shift result by  8 positions, the data in register R30 will come in R29.
	Here I have not shifted but left the R29 and taken only R30 containt as 8-bit result.
	*/

	;--------------------------------------------------------------------------------------------------------------
	; input sample shift

	mov r26, r25
	mov r25, r24
	mov r24, r23
	mov r23, r22
	;--------------------------------------------------------------------------------------------------------------

	ldi r29, 0
	ldi r30, 0

	ldi r16,0
	out tcnt0,r16
	reti