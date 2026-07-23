; ===========================================================================
; ----------------------------------------------------------------------------
; Object 26 - Monitor
;
; The power-ups themselves are handled by the next object. This just does the
; monitor collision and graphics.
; ----------------------------------------------------------------------------
; Obj_Monitor:
Monitor:
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	Mon_Index(pc,d0.w),d1
	jmp	Mon_Index(pc,d1.w)
; ===========================================================================
; obj_26_subtbl:
;Obj26_Index:
Mon_Index:
		dc.w Obj26_Init-Mon_Index			; 0
		dc.w Mon_Solid-Mon_Index			; 2
		dc.w Mon_BreakOpen-Mon_Index			; 4
		dc.w Mon_Animate-Mon_Index			; 6
		dc.w BranchTo2_MarkObjGone-Mon_Index		; 8
; ===========================================================================
; obj_26_sub_0: Obj_26_Init:
Obj26_Init:
		addq.b	#2,obRoutine(a0)
		move.b	#$E,obHeight(a0)
		move.b	#$E,obWidth(a0)
		move.l	#Map_Monitor,obMap(a0)
		move.w	#make_art_tile(ArtTile_Monitor,0,0),obGfx(a0)
		move.b	#4,obRender(a0)
		move.b	#3,obPriority(a0)
		move.b	#$F,obActWid(a0)
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.s	.notbroken	; if not, branch
		bclr	#7,2(a2,d0.w)
		btst	#0,2(a2,d0.w)	; has monitor been broken?
		beq.s	.notbroken	; if not, branch
		move.b	#8,obRoutine(a0) ; run "Mon_Display" routine
		move.b	#$B,obFrame(a0)	; use broken monitor frame
		rts
; ---------------------------------------------------------------------------
.notbroken:
		move.b	#$46,obColType(a0)
		move.b	obSubtype(a0),obAnim(a0)
		cmpi.b	#3,(v_bonusfeat).w	; check if bonus feature flag to 3 (indicating eggman's traps)
		beq.w	.eggmanstraps		;if yes, branch
		cmpi.b	#$A,obAnim(a0)		; does monitor contain something above Tails?
		bhi.s	.invalidmonitor		;branch to prevent invalid monitors
		cmpi.b	#$A,obSubtype(a0)		; does monitor contain something above Tails?
		bhi.s	.invalidmonitor		;branch to prevent invalid monitors
		jsr	Mon_Solid
		rts
	.eggmanstraps:
		move.b	#$1,obAnim(a0)		; apply eggman monitor over everything, this hurts the player and takes their air
		move.b	#$1,obSubtype(a0)
		jsr	Mon_Solid
		rts
.invalidmonitor:
		move.b	#$A,obAnim(a0)		; apply tails monitor
		move.b	#$A,obSubtype(a0)

;obj_26_sub_2:
;Obj26_Main:
Mon_Solid:
	move.b	ob2ndRout(a0),d0
	beq.s	SolidObject_Monitor
	; only when secondary routine isn't 0
	; make monitor fall
	bsr.w	ObjectFall
	jsr	(ObjFloorDist).l
	tst.w	d1			; is monitor in the ground?
	bpl.w	SolidObject_Monitor	; if not, branch
	add.w	d1,obY(a0)		; move monitor out of the ground
	clr.w	obVelY(a0)
	clr.b	ob2ndRout(a0)	; stop monitor from falling
; loc_1271C:
SolidObject_Monitor:
	move.w	#$1A,d1	; monitor's width
	move.w	#$F,d2
	move.w	d2,d3
	addq.w	#1,d3
	move.w	obX(a0),d4
	lea	(v_player).w,a1 ; a1=character
	moveq	#p1_standing_bit,d6
	movem.l	d1-d4,-(sp)
	bsr.w	SolidObject_Monitor_Sonic
	movem.l	(sp)+,d1-d4
	lea	(v_player2).w,a1 ; a1=character
	moveq	#p2_standing_bit,d6
	bsr.w	SolidObject_Monitor_Tails

;Obj26_Animate
Mon_Animate:	; Routine 6
		cmpi.b	#1,(v_character).w	; is the multiple character flag set to 1 (Tails)?
		beq.s	.checksonicmonitor	; if yes, check the type of monitor
		cmpi.b	#3,(v_character).w	; is the multiple character flag set to 3 (Knuckles)?
		beq.s	.checksonicmonitor	; yes, check the type of monitor
		bra.s	.loadmap		;skip this code if neither character is there
	.checksonicmonitor:
		cmpi.b	#2,obAnim(a0)		; does monitor contain Sonic?
		bne.s	.loadmap
		cmpi.b	#1,(v_character).w	; is the multiple character flag set to 1 (Tails)?
		bne.s	.knucklesmonitor	; if not, you must be Knuckles, load his monitor

	.tailsmonitor:
		move.b	#$A,obAnim(a0)		; use 'Tails' icon
		bra.s	.loadmap
	.knucklesmonitor:
		move.b	#$B,obAnim(a0)		; use 'Knuckles' icon

	.loadmap:
		lea	(Ani_Monitor).l,a1
		bsr.w	AnimateSprite

BranchTo2_MarkObjGone ; BranchTo
	bra.w	RememberState

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; sub_12756:
SolidObject_Monitor_Sonic:
	btst	d6,obStatus(a0)			; is Sonic standing on the monitor?
	bne.s	Obj26_ChkOverEdge		; if yes, branch
	cmpi.b	#1,spindash_flag(a1)	;is this a spindash?
	beq.s	.nocol		;if yes, no colision
	cmpi.b	#2,spindash_flag(a1)	;is this a peelout?
	beq.s	.nocol		;if yes, no collision
	cmpi.b	#id_Glide,obAnim(a1) ; is Knuckles gliding?
	beq.s	.nocol	; if yes, branch
	cmpi.b	#id_Roll,obAnim(a1)		; is Sonic spinning?
	beq.s	.nocol	; if yes, branch
	bra.w	Solid_ChkEnter		; if not, branch
.nocol:
	rts
; End of function SolidObject_Monitor_Sonic


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||
; sub_12768:
SolidObject_Monitor_Tails:
	btst	d6,obStatus(a0)			; is Tails standing on the monitor?
	bne.s	Obj26_ChkOverEdge		; if yes, branch
	bra.w	Solid_ChkEnter		;no 2p checks here
	;tst.w	(Two_player_mode).w		; is it two player mode?
	;beq.w	Solid_ChkEnter		; if not, branch
	; in one player mode monitors always behave as solid for Tails
	;cmpi.b	#id_Roll,obAnim(a1)	; is Tails spinning?
	;bne.w	Solid_ChkEnter		; if not, branch
	;rts
; End of function SolidObject_Monitor_Tails

; ---------------------------------------------------------------------------
; Checks if the player has walked over the edge of the monitor.
; ---------------------------------------------------------------------------
;loc_12782:
Obj26_ChkOverEdge:
	move.w	d1,d2
	add.w	d2,d2
	btst	#1,obStatus(a1)	; is the character in the air?
	bne.s	+		; if yes, branch
	; check, if character is standing on
	move.w	obX(a1),d0
	sub.w	obX(a0),d0
	add.w	d1,d0
	bmi.s	+	; branch, if character is behind the left edge of the monitor
	cmp.w	d2,d0
	blo.s	Obj26_CharStandOn	; branch, if character is not beyond the right edge of the monitor
+
	; if the character isn't standing on the monitor
	bclr	#3,obStatus(a1)	; clear 'on object' bit
	bset	#1,obStatus(a1)	; set 'in air' bit
	bclr	d6,obStatus(a0)	; clear 'standing on' bit for the current character
	moveq	#0,d4
	rts
; ---------------------------------------------------------------------------
;loc_127B2:
Obj26_CharStandOn:
	move.w	d4,d2
	bsr.w	MvSonicOnPtfm
	moveq	#0,d4
	rts
; ===========================================================================
Mon_BreakOpen:	; Routine 4
		move.b	obStatus(a0),d0
		andi.b	#standing_mask|pushing_mask,d0	; is someone touching the monitor?
		beq.s	.spawnicon	; if not, branch
		move.b	d0,d1
		andi.b	#p1_standing|p1_pushing,d1	; is it the main character?
		beq.s	.tailsbroke		; if not, branch
	andi.b	#~(1<<3|1<<5),(v_player+obStatus).w
	ori.b	#1<<1,(v_player+obStatus).w	; prevent Sonic from walking in the air
.tailsbroke:
	andi.b	#p2_standing|p2_pushing,d0	; is it the sidekick?
	beq.s	.spawnicon	; if not, branch
	andi.b	#~(1<<3|1<<5),(v_player2+obStatus).w
	ori.b	#1<<1,(v_player2+obStatus).w	; prevent Tails from walking in the air
.spawnicon:
		addq.b	#2,obRoutine(a0)
		move.b	#0,obColType(a0)
		bsr.w	FindFreeObj
		bne.s	Mon_Explode
		_move.b	#id_PowerUp,obID(a1) ; load monitor contents object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obAnim(a0),obAnim(a1)

Mon_Explode:
		bsr.w	FindFreeObj
		bne.s	.fail
		_move.b	#id_ExplosionItem,obID(a1) ; load explosion object
		addq.b	#2,obRoutine(a1) ; don't create an animal
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

.fail:
		lea	(v_objstate).w,a2
		moveq	#0,d0
		move.b	obRespawnNo(a0),d0
		beq.w	.dontpermbreak	; if not, branch
		bset	#0,2(a2,d0.w)
	.dontpermbreak:
		move.b	#9,obAnim(a0)	; set monitor type to broken
		bra.w	DisplaySprite

