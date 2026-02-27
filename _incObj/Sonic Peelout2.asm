spindash_counter = v_unused3

Sonic_Peelout:
		cmpi.b	#1,(v_peelouttoggle).w	; check if peelout flag to 1 (indicating disable it)
		beq.w	rts_SonicPeelout	;if yes, don't perform it
		cmpi.b	#1,(v_s1peelout).w	; check if s1 peelout flag to 1
		beq.w	Sonic_ContPeelout	;do s1 style peelout, based on continue
		cmpi.b	#1,(v_character).w	; check if multiple character flag is set 1 (indicating Tails)
		beq.w	rts_SonicPeelout
		cmpi.b	#id_Roll,obAnim(a0)
		beq.s	rts_SonicPeelout
		cmpi.b	#2,spindash_flag(a0)
		beq.s	Sonic_UpdatePeelout
		cmpi.b	#id_LookUp,obAnim(a0)
		bne.s	rts_SonicPeelout
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnB|btnC|btnA,d0
		beq.w	rts_SonicPeelout
		move.b	#id_Walk,obAnim(a0)
		move.w	#sfx_PeelCharge,d0
		jsr	(QueueSound2).l
		addq.l	#4,sp
		move.b	#2,spindash_flag(a0)
		move.w	#0,spindash_counter(a0)
		bclr	#5,obStatus(a0)	; clear pushing flag.
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos

rts_SonicPeelout:
		rts
Peelout_DoNothing:
		move.w	#sfx_PeelStop,d0	; spindash zoom sound
		jsr	(QueueSound2).l 
		clr.b	spindash_flag(a0)	; clear Spin Dash flag 
		clr.w	spindash_counter(a0)	; clear Spin Dash counter
		clr.w	obInertia(a0)		; kill whatever little speed we've built up
		rts


; End of function Sonic_Peelout


; ---------------------------------------------------------------------------
; Subroutine to update an already-charging peelout
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Sonic_UpdatePeelout:
		bclr	#5,obStatus(a0)	; clear pushing flag.
		move.b	#id_Walk,obAnim(a0)
		move.b	(v_jpadhold2).w,d0 
		btst	#bitUp,d0
		bne.w	Sonic_ChargingPeelout

		; unleash the charged spindash and start rolling quickly:
		cmpi.w	#30,spindash_counter(a0)
		blo.s	Peelout_DoNothing	; if not, branch
		move.b	#id_Walk,obAnim(a0)
		clr.b	spindash_flag(a0)		; clear Spin Dash flag
		clr.w	spindash_counter(a0)
		move.w	#sfx_PeelRelease,d0	; spindash zoom sound
		jsr	(QueueSound2).l 
		bra.s	.donothingloop
		nop
	.donothingloop:
		rts


; ===========================================================================

Sonic_ChargingPeelout:			; If still charging the dash...
		jsr	.buildspeed
		btst	#bitUp,(v_jpadhold2).w ; is up being pressed?
		beq.w	Sonic_Peelout_ResetScr
		addi.w	#1,spindash_counter(a0)
		cmpi.w	#30,spindash_counter(a0)
		blo.s	Sonic_Peelout_ResetScr
		move.w	#30,spindash_counter(a0)
		addq.l	#4,sp
		rts

		.buildspeed:
	moveq	#100,d0				; Get charge speed increment value
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
	beq.s	.IncPeeloutCharge		; If not, branch
	neg.w	d0				; Negate the charge speed increment value
	neg.w	d1				; Negate the max charge speed

.IncPeeloutCharge:
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

Sonic_Peelout_ResetScr:
		addq.l	#4,sp
		cmpi.w	#(224/2)-16,($FFFFEED8).w
		beq.s	Sonic_PeeloutAngle
		bhs.s	+
		addq.w	#4,($FFFFEED8).w
+		subq.w	#2,($FFFFEED8).w

Sonic_PeeloutAngle:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
		move.w	#$60,(v_lookshift).w
		rts

; End of function Sonic_UpdatePeelout