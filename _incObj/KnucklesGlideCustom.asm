KnucklesGlideCustom:
		btst	#0,(f_doublejump).w ; is knuckles climbing?
		bne.w	Knuckles_AlreadyClimbing	; if yes, continue climbing
		cmpi.b	#id_Glide,obAnim(a0)	;is Knuckles already gliding?
		beq.s	KnucklesGlideCustom_StartGliding	;if yes, continue
		cmpi.b	#id_Roll,obAnim(a0)	;is Knuckles rolling?
		bne.s	rts_KnucklesGlideCustom	;if not, don't attempt to glide
		move.b	(v_jpadpress2).w,d0	;press A B C button?
		andi.b	#btnB|btnC|btnA,d0	
		beq.s	rts_KnucklesGlideCustom	;if not, don't glide
		move.b	#id_Glide,obAnim(a0)	; start glide
		rts

rts_KnucklesGlideCustom:
		rts
KnucklesGlideCustom_StartGliding:
		move.b	#10,obHeight(a0)	;gliding height and width
		move.b	#10,obWidth(a0)
		btst	#0,(f_doublejump).w ; is knuckles against a wall?
		bne.s	KnucklesGlideCustom_ClimbWall	; if yes, start climbing
		.continue:
		cmpi.b	#id_FallFromGlide,obAnim(a0)	;already started?
		beq.s	rts_KnucklesGlideCustom	;if yes, don't glide
		move.b	(v_jpadhold2).w,d0	;are you holding the button?
		andi.b	#btnB|btnC|btnA,d0	;if not, cancel glide
		beq.s	KnucklesGlideCustom_CancelGlide
		subi.w	#$A,obVelY(a0)	;slow fall
		btst	#0,obStatus(a0)	;Knuckles facing left?
		beq.s	.right		;if not, go right
		subi.w	#5,obVelX(a0)	;go left
		bra.s	.slowfall
	.right:
		addi.w	#5,obVelX(a0)	;go right

	.slowfall:
		cmpi.w	#$50,obVelY(a0)	; apply to Y speed.
		ble.s	rts_KnucklesGlideCustom	;if falling too slow, do nothing
		move.w	#$50,obVelY(a0)	; ;if falling too fast, cap y speed
		rts
		



KnucklesGlideCustom_CancelGlide:
		move.b	#0,(f_doublejump).w ;clear thing for go on wall
		move.b	#id_FallFromGlide,obAnim(a0)	;falling anim
		move.b	#$13,obHeight(a0)	;standing heights and width
		move.b	#9,obWidth(a0)
	; Divide Knuckles' X velocity by 4.
		asr.w	obVelX(a0)
		asr.w	obVelX(a0)
		rts
;-----------------------------------------------------------------------------------
KnucklesGlideCustom_ClimbWall:
	move.b	#$B7,(v_player+obFrame).w	;climbing frame, this part's run once only starting to climb
	move.b	#$7F,obTimeFrame(a0)
	move.b	#0,obAniFrame(a0)
Knuckles_AlreadyClimbing:
		move.b	#$13,obHeight(a0)	;standing height
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
	move.w	#-$380,obVelY(a0)	;jump opposite from wall
	move.w	#$400,obVelX(a0)	;a little height

	bchg	#0,obStatus(a0)	;are you left?
	bne.s	+
	neg.w	obVelX(a0)	;reverse direction
+
	bset	#1,obStatus(a0)	;in air flag
	move.b	#1,jumping(a0)	;unsure what this is

	move.b	#$E,obHeight(a0)	;rolling height
	move.b	#7,obWidth(a0)

	move.b	#id_Roll,obAnim(a0)	;rolling animation
	bset	#2,obStatus(a0)		;rolling state
	move.b	#0,(f_doublejump).w	;remove climbing state
		rts
	;the ported thing here was just jumping from wall
;-----------------------------------------------------------------------------------
		.dn:
		btst	#bitDn,(v_jpadhold2).w ; is down being pressed?
		beq.w	.up	; if not, check if pressing up
		addq.w	#1,obY(a0)	;go down on the wall
		tst.b	(v_super).w	; Are we in non-super state?
		beq.w	.animup		; If so, do nothing
		addq.w	#1,obY(a0)	;go down faster
		;wall check
	move.w	obY(a0),d2
	addi.w	#11,d2
	bsr.w	GetDistanceFromWall

	; If Knuckles is no longer against the wall (he has climbed off the
	; bottom of it) then make him let go.
	tst.w	d1
	bne.w	Knuckles_StopClimbing
		cmpi.b	#$B7,(v_player+obFrame).w	;on this frame or lower?
		ble.s	.loopdown			;if yes, set it to highest climbing frame to loop animation
		subi.b	#$1,(v_player+obFrame).w	;cycle through climbing anim
		rts
;-----------------------------------------------------------------------------------
		.up:
		btst	#bitUp,(v_jpadhold2).w ; is up being pressed?
		beq.w	Knuckles_StoppedClimbing	; if not, stop moving and stay still on wall
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
		tst.b	(v_super).w	; Are we in non-super state?
		beq.w	.animup		; If so, do nothing
		subq.w	#1,obY(a0)	;go up faster
		.animup:
		cmpi.b	#$BC,(v_player+obFrame).w	;on this frame or higher?
		bge.s	.loopup				;if yes, loop to lowest frame
		addi.b	#1,(v_player+obFrame).w		;increase frames to move in animation
		rts
;-----------------------------------------------------------------------------------
		.loopup:
		move.b	#$B7,(v_player+obFrame).w	;lowest frame
		move.b	#$7F,obTimeFrame(a0)
		move.b	#0,obAniFrame(a0)	
		rts
		.loopdown:
		move.b	#$BC,(v_player+obFrame).w	;highest frame
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
		move.b	#id_FallFromGlide,obAnim(a0)	;falling anim
		move.b	#0,(f_doublejump).w ;clear thing for go on wall
		rts
Knuckles_Ledge:
		move.b	#0,(f_doublejump).w ;clear thing for go on wall
		btst	#0,obStatus(a0)	;Knuckles facing left?
		bne.s	.facingLeft	;if yes, go left
		addi.w	#$B,obX(a0)	;go right a certain distance
		bra.s	.skipleft
	.facingLeft:
		subi.w	#$B,obX(a0)
	.skipleft:
		subi.w	#$10,obY	;go a little above the wall
		rts
;============================================================================
; sub_315C22:	;more sonic 2 code
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