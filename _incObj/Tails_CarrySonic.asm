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

	tst.b	(f_tailscarrysonic).w	;is tails already carrying sonic?
	bne.w	.leftorright		;if yes, skip coordinate checks


	move.w	obX(a1),d0		;distance between players
	sub.w	obX(a0),d0
	addi.w	#$C,d0			;more to the right
	cmpi.w	#$18,d0			;is sonic a certain distance toward tails?
	bhs.w	.stopcarrysonic		;if not, stop carrying sonic
	move.w	obY(a1),d1		
	sub.w	obY(a0),d1		;distance between players
	subi.w	#$20,d1		;32	;more down
	cmpi.w	#$10,d1		;16	;is sonic a certain distance toward tails?
	bhs.w	.stopcarrysonic		;if not, stop carrying sonic

	;face left or right
.leftorright:
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
	move.b	#1,(f_tailscarrysonic).w	;set carrying sonic flag
	move.b	#0,(v_tailscpujump).w
	btst	#bitDn,(v_jpadhold2).w ; is down being pressed?
	beq.s	.end	; if not, branch
	move.b	#id_Roll,obAnim(a0) ; use "jumping" animation
	move.b	#id_Roll,obAnim(a1) ; use "jumping" animation, flight cancel
.stopcarrysonic:
	move.b	#0,(f_tailscarrysonic).w
		rts
.end:
	rts
