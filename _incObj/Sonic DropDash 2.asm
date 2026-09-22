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
		move.b	#1,(f_doublejump).w		;set doublejump flag	(some of dropdash code is sonic's object under Sonic_ResetOnFloor and Sonic_SpinDash)
		move.w	#sfx_PeelCharge,d0
		jmp	(QueueSound2).l

Sonic_ChkStopDropDash:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0	; is A, B or C held?
		bne.w	rts_SonicDropDash		;if yes, don't cancel
		move.b	#2,(f_doublejump).w	;stop a dropdash
		move.w	#sfx_PeelStop,d0
		jmp	(QueueSound2).l
Sonic_DropDashZoom:	;mania ver
		; unleash the charged spindash and start rolling quickly:
		clr.b	spindash_flag(a0)		; clear Spin Dash flag
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		bset	#2,obStatus(a0)
	tst.b	(v_super).w		;is super sonic?
	bne.s	.super			;if yes, go faster
	tst.b	(v_shoes).w		;have speedshoes?
	bne.s	.shoes			;if yes, go faster
	move.w	#$800,d0				; Get dashspeed value
	move.w	#$C00,d1		; Get max charge speed
	bra.s	.notsuper
.shoes:	;added buff for speedshoes
	move.w	#$A00,d0				; Get dashspeed value
	move.w	#$D00,d1		; Get max charge speed
	bra.s	.notsuper
.super:
	move.w	#$C00,d0				; Get dash speed value
	move.w	#$D00,d1		; Get max charge speed
.notsuper:
		btst	#bitR,(v_jpadhold2).w	;pressing right?
		beq.s	.chkleft		;if not check for left
		bclr	#0,obStatus(a0)		;face right
		bra.s	.nodpad
.chkleft
		btst	#bitL,(v_jpadhold2).w	;pressing left?
		beq.s	.nodpad			;if not, assume there is no dpad inputs
		bset	#0,obStatus(a0)		;face left
.nodpad:
	btst	#0,obStatus(a0)	;is facing left?
	beq.s	.dontnegated1		;if not, don't negate dashspeed
	neg.w	d0
	neg.w	d1
	tst.w	obVelX(a0)		;is sonic's speed less than or equal to 0
	ble.s	.divspeed		;if yes, branch
	bra.s	.chkangle
.dontnegated1:
	tst.w	obVelX(a0)		;is sonic's speed greater or equal to 0
	bge.s	.divspeed		;if yes, branch
.chkangle:
	tst.b	obAngle(a0)		;angle of 0?
	beq.s	.groundspeedisdash	;if yes, branch
	asr.w	#1,obInertia(a0)	;cut Sonic's speed in half
	add.w	obInertia(a0),d0	;then add his speed to the dash speed
	bra.s	.skipcap
.divspeed:
	asr.w	obInertia(a0)	;cut Sonic's speed in 4ths
	add.w	obInertia(a0),d0
	btst	#0,obStatus(a0)	;is facing left?
	beq.s	.facerightchkcap		;if not, use other calc
	cmp.w	d0,d1			;is the dashspeed higher than max speed?
	ble.s	.skipcap		;if not, branch
	bra.s	.capspeed
.facerightchkcap:
	cmp.w	d1,d0			;is the dashspeed higher than max speed?
	ble.s	.skipcap		;if not, branch
.capspeed:
	move.w	d1,d0			;cap dashspeed
.skipcap:
.groundspeedisdash:
	move.w	d0,obInertia(a0)
		move.b	#id_Roll,obAnim(a0)
		move.w	#sfx_PeelRelease,d0	; spindash zoom sound
		jmp	(QueueSound2).l 
rts_SonicDropDash:
		rts