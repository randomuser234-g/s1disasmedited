Sonic_DropDash:
		cmpi.b	#1,spindash_flag(a0)	;have spindash flag set?
		beq.s	Sonic_ChargingDropDash	;if not, do nothing
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnB|btnC|btnA,d0
		beq.w	Sonic_DropDashDoNothing
		move.b	#1,spindash_flag(a0)
		move.w	#0,spindash_counter(a0)
		rts
Sonic_DropDashDoNothing:
		move.w	#0,spindash_counter(a0)
		rts

Sonic_ChargingDropDash:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnB|btnC|btnA,d0
		beq.w	Sonic_DropDashDoNothing
		addi.w	#$50,spindash_counter(a0)
		cmpi.w	#$800,spindash_counter(a0)
		blo.s	Sonic_DropDash_ResetScr
		move.w	#$800,spindash_counter(a0)
		rts

		

Sonic_StartDropDash:
		cmpi.b	#1,spindash_flag(a0)	;have spindash flag set?
		bne.s	Sonic_DropDashDoNothing	;if not, do nothing
		jmp	Tails_UpdateSpindash
		rts

; ===========================================================================

Sonic_DropDash_ResetScr:
		addq.l	#4,sp
		cmpi.w	#(224/2)-16,($FFFFEED8).w
		beq.s	Sonic_DropDashAngle
		bhs.s	+
		addq.w	#4,($FFFFEED8).w
+		subq.w	#2,($FFFFEED8).w

Sonic_DropDashAngle:
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_AnglePos
		move.w	#$60,(v_lookshift).w
		rts
		