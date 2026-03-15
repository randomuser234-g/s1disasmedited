KnucklesGlideCustom:
		btst	#0,(f_doublejump).w ; are controls locked?
		bne.w	Knuckles_AlreadyClimbing	; if yes, branch
		cmpi.b	#id_Glide,obAnim(a0)	;is Knuckles already gliding
		beq.s	KnucklesGlideCustom_StartGliding	;if yes, continue
		cmpi.b	#id_Roll,obAnim(a0)	;is Knuckles rolling?
		bne.s	rts_KnucklesGlideCustom	;if not, don't attempt to glide
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnB|btnC|btnA,d0
		beq.s	rts_KnucklesGlideCustom
		move.b	#id_Glide,obAnim(a0)
		rts

rts_KnucklesGlideCustom:
		rts
KnucklesGlideCustom_StartGliding:
		move.b	#10,obHeight(a0)
		move.b	#10,obWidth(a0)
		btst	#0,(f_doublejump).w ; are controls locked?
		bne.s	KnucklesGlideCustom_ClimbWall	; if yes, branch
		.continue:
		cmpi.b	#id_FallFromGlide,obAnim(a0)	;already started?
		beq.s	rts_KnucklesGlideCustom	;if yes, don't do more
		move.b	(v_jpadhold2).w,d0	;are you holding the button?
		andi.b	#btnB|btnC|btnA,d0	;if not, cancel glide
		beq.s	KnucklesGlideCustom_CancelGlide
		subi.w	#$A,obVelY(a0)	
		btst	#0,obStatus(a0)
		beq.s	.right
		subi.w	#5,obVelX(a0)
		bra.s	.slowfall
	.right:
		addi.w	#5,obVelX(a0)

	.slowfall:
		cmpi.w	#$50,obVelY(a0)	; apply to Y speed.
		ble.s	rts_KnucklesGlideCustom	;if falling too slow, do nothing
		move.w	#$50,obVelY(a0)	; ;if falling too fast, cap y speed
		rts
		



KnucklesGlideCustom_CancelGlide:
		move.b	#0,(f_doublejump).w ;clear thing for go on wall
		move.b	#id_FallFromGlide,obAnim(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
	; Divide Knuckles' X velocity by 4.
		asr.w	obVelX(a0)
		asr.w	obVelX(a0)
		rts
;-----------------------------------------------------------------------------------
KnucklesGlideCustom_ClimbWall:
	move.b	#$B7,(v_player+obFrame).w	
	move.b	#$7F,obTimeFrame(a0)
	move.b	#0,obAniFrame(a0)
Knuckles_AlreadyClimbing:
	; Get Knuckles' distance from the wall in 'd1'.
	.onwall:
	;is knuckles away from the wall?
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		clr.w	obVelX(a0)	;freeze knuckles on the wall
		clr.w	obVelY(a0)
		move.b	(v_jpadpress2).w,d0
		jsr	.jump
		cmpi.b	#id_Roll,obAnim(a0)	;is Knuckles rolling?
		beq.w	rts_KnucklesGlideCustom	;if yes, he must be jumping off, don't run any further code here
		jsr	.dn
		rts
;-----------------------------------------------------------------------------------
		.jump:
		andi.b	#btnABC,d0	; is A, B or C pressed?
		beq.w	rts_KnucklesGlideCustom	; if not, do nothing
		;more KIS2 code
	move.w	#-$380,obVelY(a0)
	move.w	#$400,obVelX(a0)

	bchg	#0,obStatus(a0)
	bne.s	+
	neg.w	obVelX(a0)
+
	bset	#1,obStatus(a0)
	move.b	#1,jumping(a0)	;unsure what this is

	move.b	#$E,obHeight(a0)
	move.b	#7,obWidth(a0)

	move.b	#id_Roll,obAnim(a0)
	bset	#2,obStatus(a0)
	move.b	#0,(f_doublejump).w
		rts
;-----------------------------------------------------------------------------------
		.dn:
		btst	#bitDn,(v_jpadhold2).w ; is down being pressed?
		beq.w	.up	; if not, branch
		addq.w	#1,obY(a0)	;go down on the wall
		;wall check
	move.w	obY(a0),d2
	addi.w	#11,d2
	bsr.w	GetDistanceFromWall

	; If Knuckles is no longer against the wall (he has climbed off the
	; bottom of it) then make him let go.
	tst.w	d1
	bne.w	Knuckles_StopClimbing
		cmpi.b	#$B7,(v_player+obFrame).w	
		ble.s	.loopdown
		subi.b	#$1,(v_player+obFrame).w	
		rts
;-----------------------------------------------------------------------------------
		.up:
		btst	#bitUp,(v_jpadhold2).w ; is up being pressed?
		beq.w	Knuckles_StoppedClimbing	; if not, branch
	move.w	obY(a0),d2
	subi.w	#11,d2
	jsr	GetDistanceFromWall

	; If the wall is far away from Knuckles, then we must have reached a
	; ledge, so make Knuckles climb up onto it.
	cmpi.w	#4,d1
	bge.w	Knuckles_Ledge
	tst.w	d1
	bpl.s	.moveup

	; Knuckles is bumping into the ceiling, so push him out.
	sub.w	d1,obY(a0)
	bra.s	.animup
		.moveup:
		subq.w	#1,obY(a0)	;go up on the wall
		.animup:
		cmpi.b	#$BC,(v_player+obFrame).w	
		bge.s	.loopup
		addi.b	#1,(v_player+obFrame).w	
		rts
;-----------------------------------------------------------------------------------
		.loopup:
		move.b	#$B7,(v_player+obFrame).w	
		move.b	#$7F,obTimeFrame(a0)
		move.b	#0,obAniFrame(a0)	
		rts
		.loopdown:
		move.b	#$BC,(v_player+obFrame).w	
		move.b	#$7F,obTimeFrame(a0)
		move.b	#0,obAniFrame(a0)	
		rts
;-----------------------------------------------------------------------------------
Knuckles_StoppedClimbing:
	; check similar to going up, but to stop climbing if you go left or right
	move.w	obY(a0),d2
	addi.w	#11,d2
	bsr.w	GetDistanceFromWall
	tst.w	d1
	bne.w	Knuckles_StopClimbing
	clr.w	d1

		move.b	#$B7,(v_player+obFrame).w	
		move.b	#$7F,obTimeFrame(a0)
		move.b	#0,obAniFrame(a0)
		rts
Knuckles_StopClimbing:
		move.b	#id_FallFromGlide,obAnim(a0)
		move.b	#0,(f_doublejump).w ;clear thing for go on wall
		rts
Knuckles_Ledge:
		move.b	#0,(f_doublejump).w ;clear thing for go on wall
		btst	#0,obStatus(a0)
		bne.s	.facingLeft
		addi.w	#5,obX(a0)
		bra.s	.skipleft
	.facingLeft:
		subi.w	#5,obX(a0)
	.skipleft:
		subi.w	#$10,obY
		rts
;============================================================================
; sub_315C22:
GetDistanceFromWall:
	move.b	obSolid(a0),d5
	btst	#0,obStatus(a0)
	bne.s	.facingLeft

;.facingRight:
	move.w	obX(a0),d3
	jmp	sub_14EB4
; ---------------------------------------------------------------------------
; loc_315C36:
.facingLeft:
	move.w	obX(a0),d3
	subq.w	#1,d3
	jmp	Sonic_HitWall
; End of function GetDistanceFromWall