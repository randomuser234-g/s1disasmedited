KnucklesGlideCustom:
		cmpi.b	#id_Glide,obAnim(a0)	;is Knuckles already gliding
		beq.s	KnucklesGlideCustom_StartGliding	;if yes, continue
		cmpi.b	#id_FallFromGlide,obAnim(a0)	;already started?
		beq.s	rts_KnucklesGlideCustom	;if yes, don't do more
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
		;btst	#5,obStatus(a0)	; is Knuckles pushing something? this check doesn't actually work, no wall climb yet
		;bne.w	KnucklesGlideCustom_ClimbWall		; if yes, branch
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
		move.b	#id_FallFromGlide,obAnim(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
	; Divide Knuckles' X velocity by 4.
		asr.w	obVelX(a0)
		asr.w	obVelX(a0)
		rts

KnucklesGlideCustom_ClimbWall:
		move.b	#id_FallFromGlide,obAnim(a0)
		rts
		