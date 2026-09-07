Sonic_DropDash:
		cmpi.b	#1,(v_dropdashtoggle).w	; check if dropdash toggle is 1 (indicating no dropdash)
		beq.w	rts_SonicDropDash
		btst	#bitUp,(v_jpadhold2).w	;is holding up?
		bne.w	rts_SonicDropDash	;if yes, branch (work with calling tails to fly)
		cmpi.b	#id_Transform,obAnim(a0)			; is Sonic transforming?
		beq.w	rts_SonicDropDash						;if yes, don't dropdash
		btst	#2,obStatus(a0)		; Sonic is rolling?
		beq.w	rts_SonicDropDash		;if not, don't dropdash
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		beq.s	Sonic_StopDropDash		;if not, check to cancel dropdash
		tst.b	(f_doublejump).w	;already started a dropdash?
		bne.w	rts_SonicDropDash	;if yes, skip this code
		move.b	#1,(f_doublejump).w		;set doublejump flag	(rest of dropdash code is sonic's object under Sonic_ResetOnFloor)
		move.w	#sfx_PeelCharge,d0
		jmp	(QueueSound2).l

Sonic_StopDropDash:
		tst.b	(f_doublejump).w	;already started a dropdash?
		beq.w	rts_SonicDropDash	;if yes, skip this code
		clr.b	(f_doublejump).w	;stop a dropdash
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
.chkright:
		cmpi.w	#$800,obInertia(a0)
		bgt.s	.addspeed
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
		clr.w	obVelY(a0)
		btst	#0,obStatus(a0)
		beq.s	+
		neg.w	obInertia(a0)
+
		move.b	#id_Roll,obAnim(a0)
		move.b	#id_Roll,obPrevAni(a0)
		move.w	#sfx_PeelRelease,d0	; spindash zoom sound
		jsr	(QueueSound2).l 
		move.w	#0,spindash_counter(a0)
		rts
rts_SonicDropDash:
		rts