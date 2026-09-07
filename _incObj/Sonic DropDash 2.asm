Sonic_DropDash:
		cmpi.b	#1,(v_dropdashtoggle).w	; check if dropdash toggle is 1 (indicating no dropdash)
		beq.w	rts_SonicDropDash	;if yes, must be turned off
		btst	#bitUp,(v_jpadhold2).w	;is holding up?
		bne.w	rts_SonicDropDash	;if yes, branch (work with calling tails to fly)
		tst.b	(f_tailscarrysonic).w	;is tails carrying sonic?
		bne.w	rts_SonicDropDash	;if yes, don't perform a dropdash
		cmpi.b	#id_Transform,obAnim(a0)			; is Sonic transforming?
		beq.w	rts_SonicDropDash						;if yes, don't dropdash
		btst	#2,obStatus(a0)		; Sonic is rolling?
		beq.w	rts_SonicDropDash		;if not, don't dropdash
		cmpi.b	#1,(f_doublejump).w	;already started a dropdash?
		beq.s	Sonic_ChkStopDropDash	;if yes, check to cancel dropdash
		cmpi.b	#2,(f_doublejump).w	;already ended a dropdash?
		beq.w	rts_SonicDropDash	;if yes, don't dropdash
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		beq.w	rts_SonicDropDash		;if not, check to cancel dropdash
		move.b	#1,(f_doublejump).w		;set doublejump flag	(some of dropdash code is sonic's object under Sonic_Floor, Sonic_ResetOnFloor and Sonic_SpinDash)
		move.w	#sfx_PeelCharge,d0
		jmp	(QueueSound2).l

Sonic_ChkStopDropDash:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		bne.w	rts_SonicDropDash		;if yes, don't cancel
		move.b	#2,(f_doublejump).w	;stop a dropdash
		move.w	#sfx_PeelStop,d0
		jmp	(QueueSound2).l
Sonic_DropDashZoom:
		; unleash the charged spindash and start rolling quickly:
		clr.b	spindash_flag(a0)		; clear Spin Dash flag
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		bset	#2,obStatus(a0)
		btst	#0,obStatus(a0)
		beq.s	.chkright
		cmpi.w	#-$800,obInertia(a0)
		blt.s	.addspeedleft
		bra.s	.dontchk
.chkright:
		cmpi.w	#$800,obInertia(a0)
		bgt.s	.addspeed
.dontchk:
		move.w	#$800,obInertia(a0)
		tst.b	(v_super).w
		bne.s	.superspeed
		tst.b	(v_shoes).w
		beq.s	.afteraddspeed
.superspeed:
		addi.w	#$300,obInertia(a0)
		bra.s	.afteraddspeed
.addspeed:
		addi.w	#$300,obInertia(a0)
		bra.s	+
.addspeedleft:
		subi.w	#$300,obInertia(a0)
		bra.s	+
.afteraddspeed:
		btst	#0,obStatus(a0)
		beq.s	+
		neg.w	obInertia(a0)
+
		move.b	#id_Roll,obAnim(a0)
		move.w	#sfx_PeelRelease,d0	; spindash zoom sound
		jmp	(QueueSound2).l 
rts_SonicDropDash:
		rts