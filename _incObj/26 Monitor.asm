; ---------------------------------------------------------------------------
; Object 26 - monitors
; ---------------------------------------------------------------------------

Monitor:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Mon_Index(pc,d0.w),d1
		jmp	Mon_Index(pc,d1.w)
; ===========================================================================
Mon_Index:	dc.w Mon_Main-Mon_Index
		dc.w Mon_Solid-Mon_Index
		dc.w Mon_BreakOpen-Mon_Index
		dc.w Mon_Animate-Mon_Index
		dc.w Mon_Display-Mon_Index
; ===========================================================================

Mon_Main:	; Routine 0
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
; ===========================================================================

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

Mon_Solid:	; Routine 2
		move.b	ob2ndRout(a0),d0 ; is monitor set to fall?
		beq.s	.normal		; if not, branch
		subq.b	#2,d0
		bne.s	.fall

		; 2nd Routine 2
		moveq	#0,d1
		move.b	obActWid(a0),d1
		addi.w	#$B,d1
		bsr.w	ExitPlatform
		btst	#3,obStatus(a1) ; is Sonic on top of the monitor?
		bne.w	.ontop		; if yes, branch
		clr.b	ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

.ontop:
		move.w	#$10,d3
		move.w	obX(a0),d2
		bsr.w	MvSonicOnPtfm
		bra.w	Mon_Animate
; ===========================================================================

.fall:		; 2nd Routine 4
		bsr.w	ObjectFall
		jsr	(ObjFloorDist).l
		tst.w	d1
		bpl.w	Mon_Animate
		add.w	d1,obY(a0)
		clr.w	obVelY(a0)
		clr.b	ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

.normal:	; 2nd Routine 0
		move.w	#$1A,d1
		move.w	#$F,d2
		bsr.w	Mon_SolidSides
		beq.w	loc_A25C
		tst.w	obVelY(a1)
		bmi.s	loc_A20A
		cmpi.b	#1,spindash_flag(a1)	;is this a spindash?
		beq.s	loc_A25C		;if yes, no colision
		cmpi.b	#2,spindash_flag(a1)	;is this a peelout?
		beq.s	loc_A25C		;if yes, no collision
		cmpi.b	#id_Roll,obAnim(a1) ; is Sonic rolling?
		beq.s	loc_A25C	; if yes, branch

loc_A20A:
		tst.w	d1
		bpl.s	loc_A220
		sub.w	d3,obY(a1)
		bsr.w	loc_74AE
		move.b	#2,ob2ndRout(a0)
		bra.w	Mon_Animate
; ===========================================================================

loc_A220:
		tst.w	d0
		beq.w	loc_A246
		bmi.s	loc_A230
		tst.w	obVelX(a1)
		bmi.s	loc_A246
		bra.s	loc_A236
; ===========================================================================

loc_A230:
		tst.w	obVelX(a1)
		bpl.s	loc_A246

loc_A236:
		sub.w	d0,obX(a1)
		move.w	#0,obInertia(a1)
		move.w	#0,obVelX(a1)

loc_A246:
		btst	#1,obStatus(a1)
		bne.s	loc_A26A
		bset	#5,obStatus(a1)
		bset	#5,obStatus(a0)
		bra.s	Mon_Animate
; ===========================================================================

loc_A25C:
		btst	#5,obStatus(a0)
		beq.s	Mon_Animate
		move.w	#1,obAnim(a1)	; clear obAnim and set obNextAni to 1

loc_A26A:
		bclr	#5,obStatus(a0)
		bclr	#5,obStatus(a1)

Mon_Animate:	; Routine 6
		cmpi.b	#1,(v_character).w	; is the multiple character flag set to 1 (Tails)?
		bne.s	.loadmap		; if not, load Sonic's mappings
		cmpi.b	#2,obAnim(a0)		; does monitor contain Sonic?
		bne.s	.loadmap

	.tailsmap:
		move.b	#$A,obAnim(a0)		; use 'Tails' icon

	.loadmap:
		lea	(Ani_Monitor).l,a1
		bsr.w	AnimateSprite

Mon_Display:	; Routine 8
		bsr.w	DisplaySprite
		out_of_range.w	DeleteObject
		rts
; ===========================================================================

Mon_BreakOpen:	; Routine 4
		move.b	obStatus(a0),d0
		andi.b	#$78,d0					; is someone touching the monitor?
		beq.s	.spawnicon			; if not, branch
		andi.b	#5,(v_player+obStatus).w	;player on object -> player pushing
		ori.b	#1,(v_player+obStatus).w	; in air flag, prevent Sonic from walking in the air
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
