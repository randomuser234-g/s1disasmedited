; ---------------------------------------------------------------------------
; Subroutine called at the peak of a jump that transforms Sonic into Super Sonic
; if he has enough rings and emeralds
; Commented code is unchanged code from Sonic 2 that hasn't been changed to fit Sonic 1 yet
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1AB38: test_set_SS:
Sonic_CheckGoSuper:
	move.b	(v_jpadpress2).w,d0
	andi.b	#btnB|btnC|btnA,d0
	beq.w	return_1ABA4

	cmpi.b	#1,(v_bonusfeat).w	; check if bonus feature flag is set to 1 (indicating super forms)
	bne.w	return_1ABA4		; if not, branch
	tst.b	(v_super).w	; is Sonic already Super?
	bne.w	return_1ABA4		; if yes, branch
	cmpi.b	#6,(v_emeralds).w	; does Sonic have exactly 6 emeralds?
	bne.w	return_1ABA4		; if not, branch
	cmpi.w	#50,(v_rings).w	; does Sonic have at least 50 rings?
	blo.w	return_1ABA4		; if not, branch
	tst.b	(f_timecount).w	;is time stopped?
	beq.w	return_1ABA4		; if yes, branch
Sonic_GoSuper:
	andi.b	#~(1<<2|1<<4),obStatus(a0)	; Clear bits 2 and 4, clears rolljump
	move.b	#$13,obHeight(a0)
	jsr	TailsHeight
	move.b	#9,obWidth(a0)
	move.b	#1,(v_supersonpal).w
	move.b	#$F,(v_supersonpaltimer).w
	move.b	#1,(v_super).w
	move.b	#$81,(f_playerctrl).w ; lock controls and disable object interaction
	move.b	#id_Transform,obAnim(a0)			; use transformation animation
	move.b	#1,(v_starsobj1+obAnim).w
	move.b	#id_ShieldItem,(v_starsobj2).w ; load stars object ($3802)
	move.b	#2,(v_starsobj2+obAnim).w
	move.b	#id_ShieldItem,(v_starsobj3).w ; load stars object ($3803)
	move.b	#3,(v_starsobj3+obAnim).w
	move.b	#id_ShieldItem,(v_starsobj4).w ; load stars object ($3804)
	move.b	#4,(v_starsobj4+obAnim).w
	move.w	#$A00,(v_sonspeedmax).w ; change Sonic's top speed
	move.w	#$30,(v_sonspeedacc).w	; change Sonic's acceleration
	move.w	#$100,(v_sonspeeddec).w	; change Sonic's deceleration
	move.b	#1,(v_invinc).w	; make Sonic invincible
	move.w	#0,(v_player+invtime).w ; time limit for the power-up
	move.w	#sfx_Teleport,d0
	jsr	(QueueSound1).l	; Play transformation sound effect.
	cmpi.w	#12,(v_air).w	; more than 12 seconds of air left?
	blt.s	return_1ABA4	; if yes, branch
	move.w	#bgm_Super,d0
	jmp	(QueueSound2).l ; play Super sonic music

; ---------------------------------------------------------------------------
return_1ABA4:
	rts
; End of subroutine Sonic_CheckGoSuper

; ---------------------------------------------------------------------------
; Subroutine doing the extra logic for Super Sonic
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1ABA6:
Sonic_Super:
	tst.b	(v_super).w	; Ignore all this code if not Super Sonic
	beq.w	return_1AC3C
	tst.b	(f_timecount).w
	beq.s	Sonic_RevertToNormal ; ?
	subq.b	#$1,(v_superframecount).w
	bpl.w	return_1AC3C
	move.b	#$3C,(v_superframecount).w	; Reset frame counter to 60
	tst.w	(v_rings).w
	beq.s	Sonic_RevertToNormal
	ori.b	#1,(f_ringcount).w
	cmpi.w	#1,(v_rings).w
	beq.s	+
	cmpi.w	#10,(v_rings).w
	beq.s	+
	cmpi.w	#100,(v_rings).w
	bne.s	++
+
	ori.b	#$80,(f_ringcount).w
+
	subq.w	#1,(v_rings).w
	bne.s	return_1AC3C
; loc_1ABF2:
Sonic_RevertToNormal:
	move.b	#2,(v_supersonpal).w	; Remove rotating palette
	move.b	#$28,(v_supersonpalnum).w
	move.b	#0,(v_super).w
	move.b	#id_Run,obPrevAni(a0) ; restart Sonic's animation
	move.b	#0,(v_invinc).w	; remove Sonic invincible
	move.w	#$600,(v_sonspeedmax).w
	move.w	#$C,(v_sonspeedacc).w
	move.w	#$80,(v_sonspeeddec).w
	bsr.w	MusicSuper
	btst	#6,obStatus(a0)	; is Sonic underwater?
	beq.s	return_1AC3C	;if not, branch
	move.w	#$300,(v_sonspeedmax).w
	move.w	#6,(v_sonspeedacc).w
	move.w	#$40,(v_sonspeeddec).w

return_1AC3C:
	rts

MusicSuper:
		cmpi.w	#12,(v_air).w	; more than 12 seconds of air left?
		blt.s	return_1AC3C	; if yes, branch
		jsr	.resumezonemus
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w ; check if level is 0103 (SBZ3)
		bne.s	.notsbz
		move.w	#bgm_SBZ,d0	; play SBZ music
		jsr	.playselected
		rts
.notsbz:
		cmpi.w	#(id_SBZ<<8)+2,(v_zone).w ; is level FZ?
		bne.s	.notfz
		move.w	#bgm_FZ,d0	; play SBZ music
		jsr	.playselected
		rts

.notfz:
			tst.b	(f_lockscreen).w ; is Sonic at a boss?
			beq.s	.playselected ; if not, branch
			move.w	#bgm_Boss,d0
.playselected:
		jsr	(QueueSound1).l
		rts
.resumezonemus:
		moveq	#0,d0
		move.b	(v_zone).w,d0
		lea	(MusicList).l,a1 ; load music playlist
		move.b	(a1,d0.w),d0
		jsr	(QueueSound1).l
		rts
; End of subroutine Sonic_Super
