spindash_counter = v_spindashcount

Sonic_Peelout:
		cmpi.b	#1,(v_peelouttoggle).w	; check if peelout flag to 1 (indicating disable it)
		beq.w	rts_SonicPeelout	;if yes, don't perform it
		cmpi.b	#1,(v_s1peelout).w	; check if s1 peelout flag to 1
		beq.w	Sonic_ContPeelout	;do s1 style peelout, based on continue
		cmpi.b	#2,spindash_flag(a0)	;already started peelout?
		beq.s	Sonic_UpdatePeelout	;if yes, continue updating it
		cmpi.b	#id_LookUp,obAnim(a0)	;is sonic looking up?
		bne.s	rts_SonicPeelout	;if not, don't do it
		move.b	(v_jpadpress2).w,d0	;a/b/c pressed?
		andi.b	#btnB|btnC|btnA,d0	
		beq.w	rts_SonicPeelout	;if not, don't do it
		move.b	#id_Walk,obAnim(a0)	;set walking animation
		move.w	#sfx_PeelCharge,d0
		jsr	(QueueSound2).l		;play peelout sound
		addq.l	#4,sp	
		move.b	#2,spindash_flag(a0)	;set flags
		move.w	#0,spindash_counter(a0)	;clear spindash
		bclr	#5,obStatus(a0)	; clear pushing flag.
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos

rts_SonicPeelout:
		rts
Peelout_DoNothing:
		move.w	#sfx_PeelStop,d0	; stop sound
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
		move.b	#id_Walk,obAnim(a0)	;keep setting walk animation
		move.b	(v_jpadhold2).w,d0 	;holding up?
		btst	#bitUp,d0
		bne.w	Sonic_ChargingPeelout	;if yes, continue to charge

		; unleash the charged spindash and start rolling quickly:
		cmpi.w	#30,spindash_counter(a0)	;reached the minimum time?
		blo.s	Peelout_DoNothing	; if not, cancel the peelout
		move.b	#id_Walk,obAnim(a0)
		clr.b	spindash_flag(a0)		; clear Spin Dash flag
		clr.w	spindash_counter(a0)
		move.w	#sfx_PeelRelease,d0	; peelout zoom sound
		jmp	(QueueSound2).l 


; ===========================================================================

Sonic_ChargingPeelout:			; If still charging the dash...
		jsr	.buildspeed
		btst	#bitUp,(v_jpadhold2).w ; is up being pressed?
		beq.w	Sonic_Peelout_ResetScr	;if not, reset screen
		addi.w	#1,spindash_counter(a0)	;increment timer
		cmpi.w	#30,spindash_counter(a0)	;timer finished?
		blo.s	Sonic_Peelout_ResetScr		;if not, branch
		move.w	#30,spindash_counter(a0)	;cap the timer
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
		cmpi.w	#(224/2)-16,(v_lookshift).w
		beq.s	Sonic_PeeloutAngle
		bhs.s	+
		addq.w	#4,(v_lookshift).w
+		subq.w	#2,(v_lookshift).w

Sonic_PeeloutAngle:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
		move.w	#$60,(v_lookshift).w
		rts

; End of function Sonic_UpdatePeelout