Sonic_SpinDash:
		cmpi.b	#1,(v_spindashtoggle).w	; check if spindash toggle is 1 (indicating no spindash)
		beq.w	rts_SonicSpinDash	;if yes, do nothing
		cmpi.b	#1,(v_character).w	; check if multiple character flag is set 1 (indicating Tails)
		beq.w	Tails_SpinDash
		cmpi.b	#id_Walk,obAnim(a0)
		beq.s	rts_SonicSpinDash
		cmpi.b	#1,spindash_flag(a0)
		beq.w	Sonic_UpdateSpinDash
		cmpi.b	#id_Duck,obAnim(a0)
		bne.s	rts_SonicSpinDash
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnB|btnC|btnA,d0
		beq.w	rts_SonicSpinDash
		move.b	#id_Roll,obAnim(a0)
		move.w	#sfx_PeelCharge,d0
		jsr	(QueueSound2).l
		addq.l	#4,sp
		move.b	#1,spindash_flag(a0)
		move.w	#0,spindash_counter(a0)
		bclr	#5,obStatus(a0)	; clear pushing flag.
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		addq.w	#5,obY(a0)	; add the difference between Sonic's rolling and standing heights
		jsr	TailsRollHeight
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos

rts_SonicSpinDash:
		rts
SpinDash_DoNothing:
		move.w	#sfx_PeelStop,d0	; spindash zoom sound
		jsr	(QueueSound2).l 
		move.b	#$13,obHeight(a0)	; set Sonic's hitbox to standing.
		jsr	TailsHeight
		move.b	#9,obWidth(a0)
		clr.b	spindash_flag(a0)	; clear Spin Dash flag 
		clr.w	spindash_counter(a0)	; clear Spin Dash counter
		clr.w	obInertia(a0)		; kill whatever little speed we've built up
		rts

; End of function Sonic_SpinDash


; ---------------------------------------------------------------------------
; Subroutine to update an already-charging spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_UpdateSpinDash:
		bclr	#5,obStatus(a0)	; clear pushing flag.
		move.b	#id_Roll,obAnim(a0)
		move.b	(v_jpadhold2).w,d0 
		btst	#bitDn,d0
		bne.w	Sonic_ChargingSpinDash

		; unleash the charged spindash and start rolling quickly:
		cmpi.w	#45,spindash_counter(a0)
		bne.s	SpinDash_DoNothing	; if not, branch
		move.b	#id_Roll,obAnim(a0)
		clr.b	spindash_flag(a0)	; clear Spin Dash flag 
		clr.w	spindash_counter(a0)	; clear Spin Dash counter
		bset	#2,obStatus(a0)
		move.w	#sfx_PeelRelease,d0	; spindash zoom sound
		jsr	(QueueSound2).l 
		bra.s	.donothingloop
		nop
	.donothingloop:
		rts

; ===========================================================================

Sonic_ChargingSpinDash:			; If still charging the dash...
		jsr	.buildspeed
		btst	#bitDn,(v_jpadhold2).w ; is up being pressed?
		beq.w	Sonic_SpinDash_ResetScr
		addi.w	#1,spindash_counter(a0)
		cmpi.w	#45,spindash_counter(a0)
		blo.s	Sonic_SpinDash_ResetScr
		move.w	#45,spindash_counter(a0)
		addq.l	#4,sp
		rts
		
	.buildspeed:
		tst.w	obInertia(a0)	;already building speed?
		bne.s	.ismoving	;if yes branch
		move.w	#$200,obInertia(a0) ; set inertia if 0

.ismoving:
	move.w	#75,d0				; Get charge speed increment value
	move.w	v_sonspeedmax.w,d1		; Get max charge speed (top speed * 2)
	move.w	d1,d2
	asl.w	#1,d1
	tst.b	v_super			; Do we have super sonic?
	bne.s	.SpeedShoes			; If yes, branch
.CheckSpeedShoes:
	tst.b	v_shoes			; Do we have speed shoes?
	beq.s	.NoSpeedShoes			; If not, branch
.SpeedShoes:
	asr.w	#1,d2				; Get max charge speed for speed shoes ((top speed * 2) - (top speed / 2))
	sub.w	d2,d1

.NoSpeedShoes:
	btst	#0,obStatus(a0)			; Are we facing left?
	beq.s	.IncSpinDashCharge		; If not, branch
	neg.w	d0				; Negate the charge speed increment value
	neg.w	d1				; Negate the max charge speed

.IncSpinDashCharge:
	add.w	d0,obInertia(a0)		; Increment charge speed

	move.w	obInertia(a0),d0		; Get current charge speed
	btst	#0,obStatus(a0)			; Are we facing left?
	beq.s	.CheckMaxRight			; If not, branch
	cmp.w	d0,d1				; Have we reached the max charge speed?
	ble.s	.SetChargeSpeed			; If not, branch
	bra.s	.CapCharge			; If so, cap it

.CheckMaxRight:
	cmp.w	d1,d0				; Have we reached the max charge speed?
	ble.s	.SetChargeSpeed			; If not, branch

.CapCharge:
	move.w	d1,d0				; Cap the charge speed

.SetChargeSpeed:
	move.w	d0,obInertia(a0)		; Update the charge speed
	rts

Sonic_SpinDash_ResetScr:
		addq.l	#4,sp
		cmpi.w	#(224/2)-16,($FFFFEED8).w
		beq.s	Sonic_SpinDashAngle
		bhs.s	+
		addq.w	#4,($FFFFEED8).w
+		subq.w	#2,($FFFFEED8).w

Sonic_SpinDashAngle:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
		move.w	#$60,(v_lookshift).w
		rts

; End of function Sonic_UpdateSpinDash