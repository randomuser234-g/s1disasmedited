Sonic_ContPeelout:
		cmpi.b	#1,(v_character).w	; check if multiple character flag is set 1 (indicating Tails)
		beq.w	rts_SonicContPeelout
		cmpi.b	#2,spindash_flag(a0)
		beq.s	Sonic_UpdateContPeelout
		cmpi.b	#id_LookUp,obAnim(a0)	;looking up?
		bne.s	rts_SonicContPeelout	;if not, do nothing
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnB|btnC|btnA,d0	;A/B/C pressed?
		beq.w	rts_SonicContPeelout	;if not, do nothing
		move.b	#id_Walk,obAnim(a0)	;walking animation
		move.w	#sfx_Roll,d0		;roll sound
		jsr	(QueueSound2).l
		addq.l	#4,sp
		move.b	#2,spindash_flag(a0)	;set spindash flag
		bclr	#5,obStatus(a0)	; clear pushing flag.
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos

rts_SonicContPeelout:
		rts
ContPeelout_DoNothing:
		clr.b	spindash_flag(a0)	; clear Spin Dash flag 
		clr.w	obInertia(a0)		; kill whatever little speed we've built up
		rts

Sonic_UpdateContPeelout:
		bclr	#5,obStatus(a0)	; clear pushing flag.
		move.b	#id_Walk,obAnim(a0)
		move.b	(v_jpadhold2).w,d0 
		btst	#bitUp,d0		;holding up?
		bne.w	Sonic_ChargingContPeelout	;if yes, continue to charge

		; unleash the charged spindash and start rolling quickly:
	cmpi.w	#$800,obInertia(a0) ; check Sonic's inertia
	blo.s	ContPeelout_DoNothing	; if too low, branch
	asl.w	#1,obInertia(a0)	;$800 * 2 gets $1000, original value when continue, just VelX to Inertia
	tst.b	v_super			; Do we have super sonic?
	bne.s	.SuperSpeed			; If yes, branch
.CheckSpeedShoes:
	tst.b	v_shoes			; Do we have speed shoes?
	beq.s	.Water			; If not, branch
.SuperSpeed:
	addi.w	#$300,obInertia(a0)	;extra speed when super
	bra.s	.skipSuperSpeed
.Water:
	btst	#6,obStatus(a0)	;is Sonic underwater?
	beq.s	.skipSuperSpeed	;if not, don't slow him down
	lsr.w	#1,obInertia(a0)	;cut Sonic's speed in half, undoing multiplication from earlier so $800 max
.skipSuperSpeed:
		btst	#0,obStatus(a0)			; Are we facing left?
		beq.s	.skipleft		; If not, branch
		neg.w	obInertia(a0)		;negate the inertia, it goes the other way
	.skipleft:
		move.b	#id_Walk,obAnim(a0)
		clr.b	spindash_flag(a0)		; clear Spin Dash flag
		move.w	#sfx_Teleport,d0	; spindash zoom sound
		jsr	(QueueSound2).l 
		bra.s	.donothingloop
		nop
	.donothingloop:
		rts

Sonic_ChargingContPeelout:
		jsr	.buildspeedContinue
		bra.s	Sonic_ContPeelout_ResetScr
		rts

.buildspeedContinue:						;this chunk copied from continue screen sonic
		cmpi.w	#$800,obInertia(a0) ; check Sonic's inertia
		blo.s	.addspeedContinue	; if too low, branch. If high enough, don't add more speed
		rts

.addspeedContinue:
		addi.w	#$20,obInertia(a0) ; increase inertia
		rts

Sonic_ContPeelout_ResetScr:
		addq.l	#4,sp
		cmpi.w	#(224/2)-16,(v_lookshift).w
		beq.s	Sonic_ContPeeloutAngle
		bhs.s	+
		addq.w	#4,(v_lookshift).w
+		subq.w	#2,(v_lookshift).w

Sonic_ContPeeloutAngle:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
		move.w	#$60,(v_lookshift).w
		rts

; End of function Sonic_UpdatePeelout
