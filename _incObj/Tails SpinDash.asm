; ---------------------------------------------------------------------------
; Subroutine to check for starting to charge a spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_SpinDash:
		cmpa.w	#v_player,a0	;is Tails player 1?
		bne.w	.skiptoggle	;if not, skip spindash toggle
		cmpi.b	#1,(v_spindashtoggle).w	; check if spindash toggle is 1 (indicating no spindash)
		beq.w	Tails_SpinDashDoNothing	;if yes, do nothing
	.skiptoggle:
		cmpi.b	#1,spindash_flag(a0)
		beq.s	Tails_UpdateSpindash
		cmpi.b	#id_Duck,obAnim(a0)
		bne.s	Tails_SpinDashDoNothing
		move.b	(v_jpadpress2p2).w,d0
		andi.b	#btnB|btnC|btnA,d0
		beq.w	Tails_SpinDashDoNothing
		move.b	#id_SpinDash,obAnim(a0)
		move.w	#sfx_SpinDash,d0
		jsr	(QueueSound2).l
		addq.l	#4,sp
		move.b	#1,spindash_flag(a0)
		move.w	#0,spindash_counter(a0)
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
Tails_SpinDashDoNothing:
		rts
; End of function Tails_SpinDash


; ---------------------------------------------------------------------------
; Subroutine to update an already-charging spindash
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_UpdateSpindash:
		move.b	#id_SpinDash,obAnim(a0)
		move.b	(v_jpadhold2p2).w,d0 
		btst	#bitDn,d0
		bne.w	Tails_ChargingSpindash

		; unleash the charged spindash and start rolling quickly:
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#id_Roll,obAnim(a0)
		addq.w	#5,obY(a0)	; add the difference between Sonic's rolling and standing heights
		jsr	TailsRollHeight
		bclr	#0,spindash_flag(a0)		; clear Spin Dash flag
		moveq	#0,d0
		move.b	spindash_counter(a0),d0
		add.w	d0,d0
		move.w	TailsSpindashSpeeds(pc,d0.w),obInertia(a0)
	tst.b	v_super			; Do we have super sonic?
	bne.s	.TailsSuperSpeed			; If yes, branch
.CheckSpeedShoes:
	tst.b	v_shoes			; Do we have speed shoes?
	beq.s	.skipTailsSuperSpeed			; If not, branch
.TailsSuperSpeed:
	addi.w	#$300,obInertia(a0)	;extra speed when super
.skipTailsSuperSpeed:

		; Determine how long to lag the camera for.
		; Notably, the faster Sonic goes, the less the camera lags.
		; This is seemingly to prevent Sonic from going off-screen.
		;removed

		btst	#0,obStatus(a0)
		beq.s	+
		neg.w	obInertia(a0)
+
		bset	#2,obStatus(a0)
		move.w	#sfx_Teleport,d0	; spindash zoom sound
		jsr	(QueueSound2).l 
		move.w	#0,spindash_counter(a0)
		bra.s	Tails_Spindash_ResetScr
; ===========================================================================
TailsSpindashSpeeds:
		dc.w  $800	; 0
		dc.w  $880	; 1
		dc.w  $900	; 2
		dc.w  $980	; 3
		dc.w  $A00	; 4
		dc.w  $A80	; 5
		dc.w  $B00	; 6
		dc.w  $B80	; 7
		dc.w  $C00	; 8
; ===========================================================================

Tails_ChargingSpindash:			; If still charging the dash...
		tst.w	spindash_counter(a0)
		beq.s	+
		move.w	spindash_counter(a0),d0
		lsr.w	#5,d0
		sub.w	d0,spindash_counter(a0)
		bcc.s	+
		move.w	#0,spindash_counter(a0)
+
		move.b	(v_jpadpress2p2).w,d0
		andi.b	#btnB|btnC|btnA,d0
		beq.w	Tails_Spindash_ResetScr
		move.w	#(id_SpinDash<<8)|(id_Walk<<0),obAnim(a0)
		move.w	#sfx_SpinDash,d0
		jsr	(QueueSound2).l
		beq.w	Tails_Spindash_ResetScr
		addi.w	#$200,spindash_counter(a0)
		cmpi.w	#$800,spindash_counter(a0)
		blo.s	Tails_Spindash_ResetScr
		move.w	#$800,spindash_counter(a0)

Tails_Spindash_ResetScr:
		addq.l	#4,sp
		cmpi.w	#(224/2)-16,($FFFFEED8).w
		beq.s	Tails_SpinDashAngle
		bhs.s	+
		addq.w	#4,($FFFFEED8).w
+		subq.w	#2,($FFFFEED8).w

Tails_SpinDashAngle:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
		move.w	#$60,(v_lookshift).w
		rts
; End of function Tails_UpdateSpindash