
Bri_Platform:	; Routine 4
		bsr.s	Bri_WalkOff
		bsr.w	DisplaySprite
		bra.w	Bri_ChkDel

; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to walk off a bridge
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Bri_WalkOff:
	lea	(v_player2).w,a1 ; a1=character
	moveq	#p2_standing_bit,d6
	moveq	#objoff_3B,d5
	movem.l	d1-d4,-(sp)
	bsr.s	+
	movem.l	(sp)+,d1-d4
	lea	(v_player).w,a1 ; a1=character
	subq.b	#p2_standing_bit-p1_standing_bit,d6
	moveq	#objoff_3F,d5
+
	btst	d6,obStatus(a0)
	beq.s	loc_F8F0
	btst	#1,obStatus(a1)
	bne.s	+
	moveq	#0,d0
	move.w	obX(a1),d0
	sub.w	obX(a0),d0
	add.w	d1,d0
	bmi.s	+
	cmp.w	d2,d0
	blo.s	++
+
	bclr	#3,obStatus(a1)
	bclr	d6,obStatus(a0)
	moveq	#0,d4
	rts
; ===========================================================================
+
		bra.w	Bri_MoveSonic
loc_F8F0:
	move.w	d1,-(sp)
	jsr	PlatformObject11_cont
	;jsr	PlatformObject_cont
	move.w	(sp)+,d1
	btst	d6,obStatus(a0)
	beq.s	+	; rts
	moveq	#0,d0
	move.w	obX(a1),d0
	sub.w	obX(a0),d0
	add.w	d1,d0
	lsr.w	#4,d0
	move.b	d0,(a0,d5.w)
+
	rts
locret_75BE:
		rts
; End of function Bri_WalkOff
