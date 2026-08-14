Tails_CarrySonic:
	tst.b	(v_player+spindash_flag).w	;already started peelout?
	bne.w	.stopcarrysonic	;if yes, don't carry sonic

	tst.b	(f_doublejump).w	;already started glide/climbing?
	bne.w	.stopcarrysonic	;if yes, don't carry knuckles

	tst.b	(f_wtunnelmode).w	;wind tunnel active?
	bne.w	.stopcarrysonic		;if yes, stop carrying sonic

	tst.b	(f_playerctrl).w	;controlled by objects?
	bmi.w	.stopcarrysonic		;if yes, stop carrying sonic

	cmpi.b	#4,obRoutine(a1)	;is sonic alive?
	bhs.w	.stopcarrysonic		;if not, stop carrying sonic

	tst.w	(v_debuguse).w		;debug used?
	bne.w	.stopcarrysonic		;if yes, stop carrying sonic

	tst.b	(f_tailscarrysonic).w	;carrying sonic?
	bne.s	.chkdistance		;if yes, check distance between the two with old parameters

	move.w	obX(a1),d0
	sub.w	obX(a0),d0
	addi.w	#$C,d0
	cmpi.w	#$18,d0
	bhs.w	.stopcarrysonic
	move.w	obY(a1),d1
	sub.w	obY(a0),d1
	subi.w	#$1E,d1		;30
	cmpi.w	#$10,d1		;16
	bhs.w	.stopcarrysonic
	bra.s	.leftorright
.chkdistance:
	btst	#1,obStatus(a1)	;is sonic airborne?
	beq.w	.stopcarrysonic	;if he isn't make sure to cancel

	btst	#3,obStatus(a1)	;is sonic on an object?
	bne.w	.stopcarrysonic	;if he is make sure to cancel

	move.w	obX(a1),d0	;get distance between tails and sonic by subtracting difference
	sub.w	obX(a0),d0		
	addi.w	#$C,d0		;enable a little range by adding $C
	cmpi.w	#$18,d0		;is he #$18 units away from this spot
	bhs.w	.bumpandstopcarrysonic	;if higher, then don't carry sonic
	move.w	obY(a1),d1
	sub.w	obY(a0),d1
	subi.w	#$19,d1		;25
	cmpi.w	#$D,d1		;13
	bhs.w	.stopcarrysonic
.leftorright:
	;face left or right
	btst	#0,obStatus(a0)		;tails facing left?
	bne.s	.notleft		;if not, don't face left
	bclr	#0,obStatus(a1)		;try to copy facing left/right
	bra.s	.afterdirections
.notleft:
	bset	#0,obStatus(a1)		;try to copy facing left/right
.afterdirections:
	;be airborne
	btst	#1,obStatus(a0)		;tails in the air?
	bne.s	.notairborne		;if not, don't be airborne
	bclr	#1,obStatus(a1)		;try to copy being in the air
	bra.s	.afteraircheck
.notairborne:
	bset	#1,obStatus(a1)		;try to copy being in the air
.afteraircheck:
	clr.w	obVelX(a1)
	clr.w	obVelY(a1)
	clr.w	obInertia(a1)
	move.w	obX(a0),obX(a1)
	move.w	obY(a0),obY(a1)
	move.w	obVelX(a0),obVelX(a1)	;velocity
	move.w	obVelY(a0),obVelY(a1)
	addi.w	#$1D,obY(a1)	;30		; the 3 numbers edited here may be where on y axis tails should hold sonic
	move.b	#id_HangFromTails,obAnim(a1)
	move.b	#1,(f_tailscarrysonic).w
	move.b	#0,(v_tailscpujump).w
	btst	#bitDn,(v_jpadhold2).w ; is down being pressed?
	beq.s	.end	; if not, branch
	move.b	#id_Roll,(a0) ; use "jumping" animation, flight cancel
	move.b	#id_Roll,(a1) ; use "jumping" animation
	bra.s	.stopcarrysonic
.bumpandstopcarrysonic:
	move.w	#-$100,obVelY(a1)
.stopcarrysonic:
	move.b	#0,(f_tailscarrysonic).w
		rts
.end:
	rts
