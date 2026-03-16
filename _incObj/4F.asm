;Pos_table = v_trackpos
;Pos_table_index = v_tracksonic
;Stat_table = v_trackstatsonic
; ---------------------------------------------------------------------------
; Object 4F - port of s3k object which gives Sonic his trailing effect
; ---------------------------------------------------------------------------

SuperAfterImg:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	AfterImg_Index(pc,d0.w),d1
		jmp	AfterImg_Index(pc,d1.w)
; ===========================================================================
AfterImg_Index:	dc.w SuperAfterImg_Init-AfterImg_Index
		dc.w Obj_HyperSonicKnux_Trail_Main-AfterImg_Index
; ===========================================================================
		; init
SuperAfterImg_Init:
		tst.w	(v_debuguse).w	; is debug mode being used?
		bne.s	.end	; if yes, don't do things, avoid using debug mode object as mappings
		addq.b	#2,obRoutine(a0)
		move.l	(v_player+obMap),obMap(a0)	; load player mappings
		cmpi.b	#1,(v_character).w	; is the multiple character flag set to 1 (Tails)?
		bne.s	.sonicmap		; if not, load Sonic's tiles
		move.w	#make_art_tile(ArtTile_Tails,0,0),obGfx(a0)
		bra.s	.playingastails		; branch to rest of code

	.sonicmap:
		move.w	#make_art_tile(ArtTile_Sonic,0,0),obGfx(a0)

	.playingastails:
		move.w	#$100,obPriority(a0)
		move.b	#$18,obWidth(a0)
		move.b	#$18,obHeight(a0)
		move.b	#4,obRender(a0)
	.end:
		rts
; ============================================================================
Obj_HyperSonicKnux_Trail_Main:
		tst.b	(v_super).w	; Are we in non-super state?
		beq.w	DeleteObject		; If so, branch and delete
		moveq	#$C,d1				; This will be subtracted from Pos_table_index, giving the object an older entry
		btst	#0,(v_framecount+1).w	; Even frame? (Think of it as 'every other number' logic)
		beq.s	.evenframe			; If so, branch
		moveq	#$14,d1				; On every other frame, use a different number to subtract, giving the object an even older entry

	.evenframe:
		move.w	(v_trackpos).w,d0
		lea	(v_tracksonic).w,a1
		sub.b	d1,d0
		lea	(a1,d0.w),a1
		move.w	(a1)+,obX(a0)			; Use previous player x_pos
		move.w	(a1)+,obY(a0)			; Use previous player y_pos
		;lea	(v_trackstatsonic).w,a1
		;move.b	3(a1,d0.w),obGfx(a0)	;may not be needed
		move.b	(v_player+obFrame).w,obFrame(a0)	; Use player's current mapping_frame
		move.b	(v_player+obRender).w,obRender(a0)	; Use player's current render_flags
		move.w	(v_player+obPriority).w,obPriority(a0)		; Use player's current priority
		bra.w	DisplaySprite
