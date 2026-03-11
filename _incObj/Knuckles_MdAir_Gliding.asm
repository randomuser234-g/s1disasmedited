Knuckles_MdAir_Gliding:				  ; ...
		bsr.w	Knuckles_GlideSpeedControl
		bsr.w	Knuckles_LevelBoundaries
		jsr	SpeedToPos		  ; AKA	SpeedToPos in Sonic 1
		bsr.w	Knuckles_GlideControl

return_3156B8:					  ; ...
		rts
; End of function Obj01_MdAir
;====================================================================
undefined stuff below
Knuckles_GlideControl:				  ; ...

; FUNCTION CHUNK AT 00315C40 SIZE 0000003C BYTES

		move.b	obColProp(a0),d0
		beq.s	return_3156B8
		cmp.b	#2,d0
		beq.w	Knuckles_FallingFromGlide
		cmp.b	#3,d0
		beq.w	Knuckles_Sliding
		cmp.b	#4,d0
		beq.w	Knuckles_Climbing_Wall
		cmp.b	#5,d0
		beq.w	Knuckles_Climbing_Up

Knuckles_NormalGlide:
		move.b	#$A,$16(a0)	;y radius
		move.b	#$A,$17(a0)
		bsr.w	Knuckles_DoLevelCollision2
		btst	#5,($FFFFF7AC).w
		bne.w	Knuckles_BeginClimb
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		btst	#1,($FFFFF7AC).w
		beq.s	Knuckles_BeginSlide
		move.b	($FFFFF602).w,d0	;controller stuff?
		and.b	#$70,d0			;abc button
		bne.s	loc_31574C		;
		move.b	#2,obColProp(a0)
		move.b	#$21,$1C(a0)
		bclr	#0,$22(a0)
		tst.w	$10(a0)
		bpl.s	loc_315736
		bset	#0,$22(a0)

loc_315736:					  ; ...
		asr	$10(a0)
		asr	$10(a0)
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		rts
; ---------------------------------------------------------------------------

loc_31574C:					  ; ...
		bra.w	sub_315C7C
; ---------------------------------------------------------------------------

Knuckles_BeginSlide:				  ; ...
		bclr	#0,$22(a0)
		tst.w	$10(a0)
		bpl.s	loc_315762
		bset	#0,$22(a0)

loc_315762:					  ; ...
		move.b	$26(a0),d0
		add.b	#$20,d0
		and.b	#$C0,d0
		beq.s	loc_315780
		move.w	$14(a0),$10(a0)
		move.w	#0,$12(a0)
		bra.w	Knuckles_ResetOnFloor_Part2
; ---------------------------------------------------------------------------

loc_315780:					  ; ...
		move.b	#3,obColProp(a0)
		move.b	#$CC,$1A(a0)
		move.b	#$7F,$1E(a0)
		move.b	#0,$1B(a0)
		cmp.b	#$C,$28(a0)
		bcs.s	return_3157AC
		move.b	#6,($FFFFD124).w
		move.b	#$15,($FFFFD11A).w

return_3157AC:					  ; ...
		rts
; ---------------------------------------------------------------------------

Knuckles_BeginClimb:				  ; ...
		tst.b	($FFFFF7AD).w
		bmi.w	loc_31587A
		move.b	$3F(a0),d5
		move.b	$1F(a0),d0
		add.b	#$40,d0
		bpl.s	loc_3157D8
		bset	#0,$22(a0)
		bsr.w	CheckLeftCeilingDist
		or.w	d0,d1
		bne.s	Knuckles_FallFromGlide
		addq.w	#1,8(a0)
		bra.s	loc_3157E8
; ---------------------------------------------------------------------------

loc_3157D8:					  ; ...
		bclr	#0,$22(a0)
		bsr.w	CheckRightCeilingDist
		or.w	d0,d1
		bne.w	loc_31586A

loc_3157E8:					  ; ...
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		tst.b	($FFFFFE19).w
		beq.s	loc_315804
		cmp.w	#$480,$14(a0)
		bcs.s	loc_315804
		nop

loc_315804:					  ; ...
		move.w	#0,$14(a0)
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		move.b	#4,obColProp(a0)
		move.b	#$B7,$1A(a0)
		move.b	#$7F,$1E(a0)
		move.b	#0,$1B(a0)
		move.b	#3,$1F(a0)
		move.w	8(a0),$A(a0)
		rts
; ---------------------------------------------------------------------------

Knuckles_FallFromGlide:				  ; ...
		move.w	8(a0),d3
		move.b	$16(a0),d0
		ext.w	d0
		sub.w	d0,d3
		subq.w	#1,d3

loc_31584A:					  ; ...
		move.w	$C(a0),d2
		sub.w	#$B,d2
		jsr	ChkFloorEdge_Part2
		tst.w	d1
		bmi.s	loc_31587A
		cmp.w	#$C,d1
		bcc.s	loc_31587A
		add.w	d1,$C(a0)
		bra.w	loc_3157E8
; ---------------------------------------------------------------------------

loc_31586A:					  ; ...
		move.w	8(a0),d3
		move.b	$16(a0),d0
		ext.w	d0
		add.w	d0,d3
		addq.w	#1,d3
		bra.s	loc_31584A
; ---------------------------------------------------------------------------

loc_31587A:					  ; ...
		move.b	#2,obColProp(a0)
		move.b	#$21,$1C(a0)
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		bset	#1,($FFFFF7AC).w
		rts
; ---------------------------------------------------------------------------

Knuckles_FallingFromGlide:			  ; ...
		bsr.w	Knuckles_ChgJumpDir
		add.w	#$38,$12(a0)
		btst	#6,$22(a0)
		beq.s	loc_3158B2
		sub.w	#$28,$12(a0)

loc_3158B2:					  ; ...
		bsr.w	Knuckles_DoLevelCollision2
		btst	#1,($FFFFF7AC).w
		bne.s	return_315900
		move.w	#0,$14(a0)
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		move.b	$16(a0),d0
		sub.b	#$13,d0
		ext.w	d0
		add.w	d0,$C(a0)
		move.b	$26(a0),d0
		add.b	#$20,d0
		and.b	#$C0,d0
		beq.s	loc_3158F0
		bra.w	Knuckles_ResetOnFloor_Part2
; ---------------------------------------------------------------------------

loc_3158F0:					  ; ...
		bsr.w	Knuckles_ResetOnFloor_Part2
		move.w	#$F,$2E(a0)
		move.b	#$23,$1C(a0)

return_315900:					  ; ...
		rts
; ---------------------------------------------------------------------------

Knuckles_Sliding:				  ; ...
		move.b	($FFFFF602).w,d0
		and.b	#$70,d0
		beq.s	loc_315926
		tst.w	$10(a0)
		bpl.s	loc_31591E
		add.w	#$20,$10(a0)
		bmi.s	loc_31591C
		bra.s	loc_315926
; ---------------------------------------------------------------------------

loc_31591C:					  ; ...
		bra.s	loc_315958
; ---------------------------------------------------------------------------

loc_31591E:					  ; ...
		sub.w	#$20,$10(a0)
		bpl.s	loc_315958

loc_315926:					  ; ...
		move.w	#0,$14(a0)
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		move.b	$16(a0),d0
		sub.b	#$13,d0
		ext.w	d0
		add.w	d0,$C(a0)
		bsr.w	Knuckles_ResetOnFloor_Part2
		move.w	#$F,$2E(a0)
		move.b	#$22,$1C(a0)
		rts
; ---------------------------------------------------------------------------

loc_315958:					  ; ...
		move.b	#$A,$16(a0)
		move.b	#$A,$17(a0)
		bsr.w	Knuckles_DoLevelCollision2
		bsr.w	Player_CheckFloor
		cmp.w	#$E,d1
		bge.s	loc_315988
		add.w	d1,$C(a0)
		move.b	d3,$26(a0)
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		rts
; ---------------------------------------------------------------------------

loc_315988:					  ; ...
		move.b	#2,obColProp(a0)
		move.b	#$21,$1C(a0)
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		bset	#1,($FFFFF7AC).w
		rts
; ---------------------------------------------------------------------------

Knuckles_Climbing_Wall:				  ; ...
		tst.b	($FFFFF7AD).w
		bmi.w	loc_315BAE
		move.w	8(a0),d0
		cmp.w	$A(a0),d0
		bne.w	loc_315BAE
		btst	#3,$22(a0)
		bne.w	loc_315BAE
		move.w	#0,$14(a0)
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		move.l	#$FFFFD600,($FFFFF796).w
		cmp.b	#$D,$3F(a0)
		beq.s	loc_3159F0
		move.l	#$FFFFD900,($FFFFF796).w

loc_3159F0:					  ; ...
		move.b	$3F(a0),d5
		move.b	#$A,$16(a0)
		move.b	#$A,$17(a0)
		moveq	#0,d1
		btst	#0,($FFFFF602).w
		beq.w	loc_315A76
		move.w	$C(a0),d2
		sub.w	#$B,d2
		bsr.w	sub_315C22
		cmp.w	#4,d1
		bge.w	Knuckles_ClimbUp	  ; Climb onto the floor above you
		tst.w	d1
		bne.w	loc_315B30
		move.b	$3F(a0),d5
		move.w	$C(a0),d2
		subq.w	#8,d2
		move.w	8(a0),d3
		bsr.w	sub_3192E6		  ; Doesn't exist in S2
		tst.w	d1
		bpl.s	loc_315A46
		sub.w	d1,$C(a0)
		moveq	#1,d1
		bra.w	loc_315B04
; ---------------------------------------------------------------------------

loc_315A46:					  ; ...
		subq.w	#1,$C(a0)
		tst.b	($FFFFFE19).w
		beq.s	loc_315A54
		subq.w	#1,$C(a0)

loc_315A54:					  ; ...
		moveq	#1,d1
		move.w	($FFFFEECC).w,d0
		cmp.w	#-$100,d0
		beq.w	loc_315B04
		add.w	#$10,d0
		cmp.w	$C(a0),d0
		ble.w	loc_315B04
		move.w	d0,$C(a0)
		bra.w	loc_315B04
; ---------------------------------------------------------------------------

loc_315A76:					  ; ...
		btst	#1,($FFFFF602).w
		beq.w	loc_315B04
		cmp.b	#$BD,$1A(a0)
		bne.s	loc_315AA2
		move.b	#$B7,$1A(a0)
		addq.w	#3,$C(a0)
		subq.w	#3,8(a0)
		btst	#0,$22(a0)
		beq.s	loc_315AA2
		addq.w	#6,8(a0)

loc_315AA2:					  ; ...
		move.w	$C(a0),d2
		add.w	#$B,d2
		bsr.w	sub_315C22
		tst.w	d1
		bne.w	loc_315BAE
		move.b	$3E(a0),d5
		move.w	$C(a0),d2
		add.w	#9,d2
		move.w	8(a0),d3
		bsr.w	sub_318FF6
		tst.w	d1
		bpl.s	loc_315AF4
		add.w	d1,$C(a0)
		move.b	($FFFFF768).w,$26(a0)
		move.w	#0,$14(a0)
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		bsr.w	Knuckles_ResetOnFloor_Part2
		move.b	#5,$1C(a0)
		rts
; ---------------------------------------------------------------------------

loc_315AF4:					  ; ...
		addq.w	#1,$C(a0)
		tst.b	($FFFFFE19).w
		beq.s	loc_315B02
		addq.w	#1,$C(a0)

loc_315B02:					  ; ...
		moveq	#-1,d1

loc_315B04:					  ; ...
		tst.w	d1
		beq.s	loc_315B30
		subq.b	#1,$1F(a0)
		bpl.s	loc_315B30
		move.b	#3,$1F(a0)
		add.b	$1A(a0),d1
		cmp.b	#$B7,d1
		bcc.s	loc_315B22
		move.b	#$BC,d1

loc_315B22:					  ; ...
		cmp.b	#$BC,d1
		bls.s	loc_315B2C
		move.b	#$B7,d1

loc_315B2C:					  ; ...
		move.b	d1,$1A(a0)

loc_315B30:					  ; ...
		move.b	#$20,$1E(a0)
		move.b	#0,$1B(a0)
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		move.w	($FFFFF602).w,d0
		and.w	#$70,d0
		beq.s	return_315B94
		move.w	#$FC80,$12(a0)
		move.w	#$400,$10(a0)
		bchg	#0,$22(a0)
		bne.s	loc_315B6A
		neg.w	$10(a0)

loc_315B6A:					  ; ...
		bset	#1,$22(a0)
		move.b	#1,$3C(a0)
		move.b	#$E,$16(a0)
		move.b	#7,$17(a0)
		move.b	#2,$1C(a0)
		bset	#2,$22(a0)
		move.b	#0,obColProp(a0)

return_315B94:					  ; ...
		rts
; ---------------------------------------------------------------------------

Knuckles_ClimbUp:				  ; ...
		move.b	#5,obColProp(a0)		  ; Climb up to	the floor above	you
		cmp.b	#$BD,$1A(a0)
		beq.s	return_315BAC
		move.b	#0,$1F(a0)
		bsr.s	sub_315BDA

return_315BAC:					  ; ...
		rts
; ---------------------------------------------------------------------------

loc_315BAE:					  ; ...
		move.b	#2,obColProp(a0)
		move.w	#$2121,$1C(a0)
		move.b	#$CB,$1A(a0)
		move.b	#7,$1E(a0)
		move.b	#1,$1B(a0)
		move.b	#$13,$16(a0)
		move.b	#9,$17(a0)
		rts
; End of function Knuckles_GlideControl


; =============== S U B	R O U T	I N E =======================================


sub_315BDA:					  ; ...
		moveq	#0,d0
		move.b	$1F(a0),d0
		lea	word_315C12(pc,d0.w),a1
		move.b	(a1)+,$1A(a0)
		move.b	(a1)+,d0
		ext.w	d0
		btst	#0,$22(a0)
		beq.s	loc_315BF6
		neg.w	d0

loc_315BF6:					  ; ...
		add.w	d0,8(a0)
		move.b	(a1)+,d1
		ext.w	d1
		add.w	d1,$C(a0)
		move.b	(a1)+,$1E(a0)
		addq.b	#4,$1F(a0)
		move.b	#0,$1B(a0)
		rts
; End of function sub_315BDA

; ---------------------------------------------------------------------------
word_315C12:	dc.w $BD03,$FD06,$BE08,$F606,$BFF8,$F406,$D208,$FB06; 0	; ...

; =============== S U B	R O U T	I N E =======================================


sub_315C22:					  ; ...

; FUNCTION CHUNK AT 00319208 SIZE 00000020 BYTES
; FUNCTION CHUNK AT 003193D2 SIZE 00000024 BYTES

		move.b	$3F(a0),d5
		btst	#0,$22(a0)
		bne.s	loc_315C36
		move.w	8(a0),d3
		bra.w	loc_319208
; ---------------------------------------------------------------------------

loc_315C36:					  ; ...
		move.w	8(a0),d3
		subq.w	#1,d3
		bra.w	loc_3193D2
; End of function sub_315C22

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Knuckles_GlideControl

Knuckles_Climbing_Up:				  ; ...
		tst.b	$1E(a0)
		bne.s	return_315C7A
		bsr.w	sub_315BDA
		cmp.b	#$10,$1F(a0)
		bne.s	return_315C7A
		move.w	#0,$14(a0)
		move.w	#0,$10(a0)
		move.w	#0,$12(a0)
		btst	#0,$22(a0)
		beq.s	loc_315C70
		subq.w	#1,8(a0)

loc_315C70:					  ; ...
		bsr.w	Knuckles_ResetOnFloor_Part2
		move.b	#5,$1C(a0)

return_315C7A:					  ; ...
		rts
; END OF FUNCTION CHUNK	FOR Knuckles_GlideControl

; =============== S U B	R O U T	I N E =======================================


sub_315C7C:					  ; ...
		move.b	#$20,$1E(a0)
		move.b	#0,$1B(a0)
		move.w	#$2020,$1C(a0)
		bclr	#5,$22(a0)
		bclr	#0,$22(a0)
		moveq	#0,d0
		move.b	$1F(a0),d0
		add.b	#$10,d0
		lsr.w	#5,d0
		move.b	byte_315CC2(pc,d0.w),d1
		move.b	d1,$1A(a0)
		cmp.b	#$C4,d1
		bne.s	return_315CC0
		bset	#0,$22(a0)
		move.b	#$C0,$1A(a0)

return_315CC0:					  ; ...
		rts
; End of function sub_315C7C

; ---------------------------------------------------------------------------
byte_315CC2:	dc.b $C0,$C1,$C2,$C3,$C4,$C3,$C2,$C1; 0	; ...

; =============== S U B	R O U T	I N E =======================================


Knuckles_GlideSpeedControl:			  ; ...
		cmp.b	#1,obColProp(a0)
		bne.w	loc_315D88
		move.w	$14(a0),d0
		cmp.w	#$400,d0
		bcc.s	loc_315CE2
		addq.w	#8,d0
		bra.s	loc_315CFC
; ---------------------------------------------------------------------------

loc_315CE2:					  ; ...
		cmp.w	#$1800,d0
		bcc.s	loc_315CFC
		move.b	$1F(a0),d1
		and.b	#$7F,d1
		bne.s	loc_315CFC
		addq.w	#4,d0
		tst.b	($FFFFFE19).w
		beq.s	loc_315CFC
		addq.w	#8,d0

loc_315CFC:					  ; ...
		move.w	d0,$14(a0)
		move.b	$1F(a0),d0
		btst	#2,($FFFFF602).w
		beq.s	loc_315D1C
		cmp.b	#$80,d0
		beq.s	loc_315D1C
		tst.b	d0
		bpl.s	loc_315D18
		neg.b	d0

loc_315D18:					  ; ...
		addq.b	#2,d0
		bra.s	loc_315D3A
; ---------------------------------------------------------------------------

loc_315D1C:					  ; ...
		btst	#3,($FFFFF602).w
		beq.s	loc_315D30
		tst.b	d0
		beq.s	loc_315D30
		bmi.s	loc_315D2C
		neg.b	d0

loc_315D2C:					  ; ...
		addq.b	#2,d0
		bra.s	loc_315D3A
; ---------------------------------------------------------------------------

loc_315D30:					  ; ...
		move.b	d0,d1
		and.b	#$7F,d1
		beq.s	loc_315D3A
		addq.b	#2,d0

loc_315D3A:					  ; ...
		move.b	d0,$1F(a0)
		move.b	$1F(a0),d0
		jsr	CalcSine
		muls.w	$14(a0),d1
		asr.l	#8,d1
		move.w	d1,$10(a0)
		cmp.w	#$80,$12(a0)
		blt.s	loc_315D62
		sub.w	#$20,$12(a0)
		bra.s	loc_315D68
; ---------------------------------------------------------------------------

loc_315D62:					  ; ...
		add.w	#$20,$12(a0)

loc_315D68:					  ; ...
		move.w	($FFFFEECC).w,d0
		cmp.w	#$FF00,d0
		beq.w	loc_315D88
		add.w	#$10,d0
		cmp.w	$C(a0),d0
		ble.w	loc_315D88
		asr	$10(a0)
		asr	$14(a0)

loc_315D88:					  ; ...
		cmp.w	#$60,($FFFFEED8).w
		beq.s	return_315D9A
		bcc.s	loc_315D96
		addq.w	#4,($FFFFEED8).w

loc_315D96:					  ; ...
		subq.w	#2,($FFFFEED8).w

return_315D9A:					  ; ...
		rts
; End of function Knuckles_GlideSpeedControl

; ---------------------------------------------------------------------------
