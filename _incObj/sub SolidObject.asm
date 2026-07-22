; ---------------------------------------------------------------------------
; Solid object subroutine (includes spikes, blocks, rocks etc)
;
; input:
;	d1 = width
;	d2 = height / 2 (when jumping)
;	d3 = height / 2 (when walking)
;	d4 = x-axis position
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


SolidObject:
	; Collide player 1.
	lea	(v_player).w,a1
	moveq	#p1_standing_bit,d6
	movem.l	d1-d4,-(sp)	; Backup input registers.
	bsr.s	SolidObject_SingleCharacter
	movem.l	(sp)+,d1-d4	; Restore input registers.

	; Collide player 2.
	lea	(v_player2).w,a1
	btst	#7,obRender(a1)
	beq.w	SolidObject_End	; Don't bother if Tails is not on-screen.
	addq.b	#p2_standing_bit-p1_standing_bit,d6
SolidObject_SingleCharacter:
		btst	d6,obStatus(a0)	; is Sonic standing on the object?
		beq.w	Solid_ChkEnter	; if not, branch
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)	; is Sonic in the air?
		bne.s	.leave		; if yes, branch
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	.leave		; if Sonic moves off the left, branch
		cmp.w	d2,d0		; has Sonic moved off the right?
		blo.s	.stand		; if not, branch

.leave:
		bclr	#3,obStatus(a1)	; clear Sonic's standing flag
		bset	#1,obStatus(a1)	; set "in air" flag
		bclr	d6,obStatus(a0)	; clear object's standing flag
		;clr.b	obSolid(a0)
		moveq	#0,d4
		rts

.stand:
		move.w	d4,d2
		jsr	MvSonicOnPtfm
		moveq	#0,d4
		rts
SolidObject_End:
		rts
; ===========================================================================

SolidObject71:
	lea	(v_player).w,a1 ; a1=character
	moveq	#p1_standing_bit,d6
	movem.l	d1-d4,-(sp)
	bsr.s	SolidObject_Always_SingleCharacter
	movem.l	(sp)+,d1-d4
	lea	(v_player2).w,a1 ; a1=character
	addq.b	#1,d6
SolidObject_Always_SingleCharacter:
		btst	d6,obStatus(a0)	; is Sonic standing on the object?
		beq.w	loc_FAD0
		move.w	d1,d2
		add.w	d2,d2
		btst	#1,obStatus(a1)
		bne.s	.leave
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.s	.leave
		cmp.w	d2,d0
		blo.s	.stand

.leave:
		bclr	#3,obStatus(a1)	; clear Sonic's standing flag
		bset	#1,obStatus(a1)	; set "in air" flag
		bclr	d6,obStatus(a0)	; clear object's standing flag
		;clr.b	obSolid(a0)
		moveq	#0,d4
		rts

.stand:
		move.w	d4,d2
		jsr	MvSonicOnPtfm
		moveq	#0,d4
		rts
; ===========================================================================

SolidObject2F:
	lea	(v_player).w,a1
	moveq	#p1_standing_bit,d6
	movem.l	d1-d4,-(sp)	; Backup input registers.
	bsr.s	SolidObject2F_SingleCharacter
	movem.l	(sp)+,d1-d4	; Restore input registers.

	; Collide player 2.
	lea	(v_player2).w,a1
	addq.b	#p2_standing_bit-p1_standing_bit,d6
; loc_F4FA:
SolidObject2F_SingleCharacter:
		tst.b	obRender(a0)	; is the object visible?
		bpl.w	Solid_Ignore		;if not, branch
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Solid_Ignore
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0
		bhi.w	Solid_Ignore
		move.w	d0,d5
		btst	#0,obRender(a0)	; is object horizontally flipped?
		beq.s	.notflipped	; if not, branch
		not.w	d5
		add.w	d3,d5

.notflipped:
		lsr.w	#1,d5
		moveq	#0,d3
		move.b	(a2,d5.w),d3
		sub.b	(a2),d3
		move.w	obY(a0),d5
		sub.w	d3,d5
		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3
		sub.w	d5,d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	Solid_Ignore
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3
		bhs.w	Solid_Ignore
		bra.w	loc_FB0E
; ===========================================================================

Solid_ChkEnter:
		tst.b	obRender(a0)
		bpl.w	Solid_Ignore

loc_FAD0:
		move.w	obX(a1),d0
		sub.w	obX(a0),d0
		add.w	d1,d0
		bmi.w	Solid_Ignore	; if Sonic moves off the left, branch
		move.w	d1,d3
		add.w	d3,d3
		cmp.w	d3,d0		; has Sonic moved off the right?
		bhi.w	Solid_Ignore	; if yes, branch
		move.b	obHeight(a1),d3
		ext.w	d3
		add.w	d3,d2
		move.w	obY(a1),d3
		sub.w	obY(a0),d3
		addq.w	#4,d3
		add.w	d2,d3
		bmi.w	Solid_Ignore	; if Sonic moves above, branch
		move.w	d2,d4
		add.w	d4,d4
		cmp.w	d4,d3		; has Sonic moved below?
		bhs.w	Solid_Ignore	; if yes, branch

loc_FB0E:
		cmpa.w	#v_player2,a1
		beq.s	.player2ctrl
		tst.b	(f_playerctrl).w ; are object interactions disabled?	;sonic only
		bmi.w	Solid_Ignore	; if yes, branch
		bra.s	.after
.player2ctrl:
		tst.b	(f_playerctrl2).w ; are object interactions disabled?	;tails only
		bmi.w	Solid_Ignore	; if yes, branch
.after:
		cmpi.b	#6,obRoutine(a1) ; is Sonic dying?		;sonic only
	if Revision=0
		bcc.w	Solid_Ignore	; if yes, branch
	else
		bcc.w	Solid_Debug
	endif
		tst.w	(v_debuguse).w	; is debug mode being used?
		bne.w	Solid_Debug	; if yes, branch
		move.w	d0,d5
		cmp.w	d0,d1		; is Sonic right of centre of object?
		bhs.s	.isright	; if yes, branch
		add.w	d1,d1
		sub.w	d1,d0
		move.w	d0,d5
		neg.w	d5

.isright:
		move.w	d3,d1
		cmp.w	d3,d2		; is Sonic below centre of object?
		bhs.s	.isbelow	; if yes, branch

		subq.w	#4,d3
		sub.w	d4,d3
		move.w	d3,d1
		neg.w	d1

.isbelow:
		cmp.w	d1,d5
		bhi.w	Solid_TopBottom	; if Sonic hits top or bottom, branch
		cmpi.w	#4,d1
		bls.s	Solid_SideAir
		tst.w	d0		; where is Sonic?
		beq.s	Solid_Centre	; if inside the object, branch
		bmi.s	Solid_Right	; if right of the object, branch
		tst.w	obVelX(a1)	; is Sonic moving left?
		bmi.s	Solid_Centre	; if yes, branch
		bra.s	Solid_Left
; ===========================================================================

Solid_Right:
		tst.w	obVelX(a1)	; is Sonic moving right?
		bpl.s	Solid_Centre	; if yes, branch

Solid_Left:
		move.w	#0,obInertia(a1)
		move.w	#0,obVelX(a1)	; stop Sonic moving

Solid_Centre:
		sub.w	d0,obX(a1)	; correct Sonic's position
		btst	#1,obStatus(a1)	; is Sonic in the air?
		bne.s	Solid_SideAir	; if yes, branch
	move.l	d6,d4
	addq.b	#pushing_bit_delta,d4	; Character is pushing, not standing
	bset	d4,obStatus(a0)		; make object be pushed
	bset	#5,obStatus(a1)	; make Sonic push object
	move.w	d6,d4
	addi.b	#($10-p1_standing_bit+p1_touch_side_bit),d4
	bset	d4,d6	; This sets bits 0 (Sonic) or 1 (Tails) of high word of d6		
		moveq	#1,d4		; return side collision
		rts
; ===========================================================================

Solid_SideAir:
		bsr.s	Solid_NotPushing
	move.w	d6,d4
	addi.b	#($10-p1_standing_bit+p1_touch_side_bit),d4
	bset	d4,d6	; This sets bits 0 (Sonic) or 1 (Tails) of high word of d6
		moveq	#1,d4		; return side collision
		rts
; ===========================================================================

Solid_Ignore:
	move.l	d6,d4
	addq.b	#pushing_bit_delta,d4
	btst	d4,obStatus(a0)		; is Sonic pushing?
		beq.s	Solid_Debug	; if not, branch
	if FixBugs
		; Fix the Walk-Jump bug
		; https://info.sonicretro.org/SCHG_How-to:Fix_the_Walk-Jump_Bug_in_Sonic_1
		move.b	obAnim(a1),d4		; get Sonic's current animation
		cmpi.b	#id_Roll,d4		; is Sonic in his jumping/rolling animation?
		beq.s	Solid_NotPushing	; if so, branch
		cmpi.b	#id_Drown,d4		; is Sonic in his drowning animation?
		beq.s	Solid_NotPushing	; if so, branch
		cmpi.b	#id_Hurt,d4		; is Sonic in his hurt animation?
		beq.s	Solid_NotPushing	; if so, branch
	endif
		move.w	#id_Run,obAnim(a1) ; use running animation

Solid_NotPushing:
		move.l	d6,d4
		addq.b	#pushing_bit_delta,d4
		bclr	d4,obStatus(a0)	; clear pushing flag
		bclr	#5,obStatus(a1)	; clear Sonic's pushing flag

Solid_Debug:
		moveq	#0,d4		; return no collision
		rts
; ===========================================================================

Solid_TopBottom:
		tst.w	d3		; is Sonic below the object?
		bmi.s	Solid_Below	; if yes, branch
;SolidObject_InsideTop:
		cmpi.w	#$10,d3		; has Sonic landed on the object?
		blo.s	Solid_Landed	; if yes, branch
		cmpi.w	#$14,d3				; has Sonic landed on the object?
		blo.s	Solid_Landed		; if yes, branch
		bra.s	Solid_Ignore
; ===========================================================================

Solid_Below:
		tst.w	obVelY(a1)	; is Sonic moving vertically?
		beq.s	Solid_Squash	; if not, branch
		bpl.s	Solid_TopBtmAir	; if moving downwards, branch
		tst.w	d3		; is Sonic above the object?
		bpl.s	Solid_TopBtmAir	; if yes, branch
		move.w	#0,obVelY(a1)	; stop Sonic moving

Solid_TopBtmAir:
		sub.w	d3,obY(a1)	; correct Sonic's position
	move.w	d6,d4
	addi.b	#($10-p1_standing_bit+p1_touch_bottom_bit),d4
	bset	d4,d6	; This sets bits 2 (Sonic) or 3 (Tails) of high word of d6
	moveq	#-2,d4			; Return bottom collision.
		moveq	#-2,d4	;change from -1
		rts
; ===========================================================================

Solid_Squash:
		btst	#1,obStatus(a1)	; is Sonic in the air?
		bne.s	Solid_TopBtmAir	; if yes, branch
		move.l	a0,-(sp)
		movea.l	a0,a2	;added
		movea.l	a1,a0
		jsr	(KillSonic).l	; kill Sonic
		movea.l	(sp)+,a0
	move.w	d6,d4
	addi.b	#($10-p1_standing_bit+p1_touch_bottom_bit),d4
	bset	d4,d6	; This sets bits 2 (Sonic) or 3 (Tails) of high word of d6
		moveq	#-2,d4	;change from -1
		rts
; ===========================================================================

Solid_Landed:
		subq.w	#4,d3
		moveq	#0,d1
		move.b	obActWid(a0),d1
		move.w	d1,d2
		add.w	d2,d2
		add.w	obX(a1),d1
		sub.w	obX(a0),d1
		bmi.s	Solid_Miss	; if Sonic is right of object, branch
		cmp.w	d2,d1		; is Sonic left of object?
		bhs.s	Solid_Miss	; if yes, branch
		tst.w	obVelY(a1)	; is Sonic moving upwards?
		bmi.s	Solid_Miss	; if yes, branch
		sub.w	d3,obY(a1)	; correct Sonic's position
		subq.w	#1,obY(a1)
		bsr.s	Solid_ResetFloor
		move.w	d6,d4
		addi.b	#($10-p1_standing_bit+p1_touch_top_bit),d4
		bset	d4,d6	; This sets bits 4 (Sonic) or 5 (Tails) of high word of d6
		moveq	#-1,d4		; return top/bottom collision
		rts
; ===========================================================================

Solid_Miss:
		moveq	#0,d4
		rts
; End of function SolidObject


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Solid_ResetFloor:
		btst	#3,obStatus(a1)	; is Sonic standing on something?
		beq.s	.notonobj	; if not, branch

		moveq	#0,d0
		move.b	standonobject(a1),d0	; get object being stood on
		lsl.w	#object_size_bits,d0
		addi.l	#(v_objspace&$FFFFFF),d0
		movea.l	d0,a2
		bclr	#3,obStatus(a2)	; clear object's standing flags
		bclr	d6,obStatus(a3)

.notonobj:
		move.w	a0,d0
		subi.w	#v_objspace&$FFFF,d0
		lsr.w	#object_size_bits,d0
		andi.w	#$7F,d0
		move.b	d0,standonobject(a1)	; set object being stood on
		move.b	#0,obAngle(a1)	; clear Sonic's angle
		move.w	#0,obVelY(a1)	; stop Sonic
		move.w	obVelX(a1),obInertia(a1)
		btst	#1,obStatus(a1)	; is Sonic in the air?
		beq.s	.notinair	; if not, branch
		move.l	a0,-(sp)
		movea.l	a1,a0
		jsr	(Sonic_ResetOnFloor).l ; reset Sonic as if on floor
		movea.l	(sp)+,a0

.notinair:
		bset	#3,obStatus(a1)	; set object standing flag
		bclr	#1,obStatus(a1)
		bset	d6,obStatus(a0)	; set Sonic standing on object flag
		rts
; End of function Solid_ResetFloor
