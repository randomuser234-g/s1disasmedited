; ---------------------------------------------------------------------------
; Object 02 - Tails	(placeholder, this mostly just does Sonic's code)
; ---------------------------------------------------------------------------

; Obj02:
TailsPlayer:
		tst.w	(v_debuguse).w	; is debug mode being used?
		beq.s	Tails_Normal	; if not, branch
		jmp	(DebugMode).l
; ===========================================================================

; Obj02_Normal:
Tails_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0	
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Tails_Index(pc,d0.w),d1
		jmp	Tails_Index(pc,d1.w)
; ===========================================================================
; Obj02_Index:
Tails_Index:	dc.w Tails_Main-Tails_Index
		dc.w Tails_Control-Tails_Index
		dc.w Tails_Hurt-Tails_Index
		dc.w Tails_Death-Tails_Index
		dc.w Tails_ResetLevel-Tails_Index
	if FixBugs
		; Fix drowning bugs
		; https://info.sonicretro.org/SCHG_How-to:Correct_Drowning_Bugs_in_Sonic_1
		dc.w Tails_Drowned-Tails_Index
	endif
; ===========================================================================

; Obj02_Main:
Tails_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#$F,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.l	#Map_Miles,obMap(a0)	; load Tails' mappings
		move.w	#make_art_tile(ArtTile_Tails,0,0),obGfx(a0)
		move.b	#2,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		move.b	#0,(v_super).w	; turn off Super
		move.b	#0,(v_shoes).w	; turn off speed shoes
		move.w	#$600,(v_sonspeedmax).w ; Sonic's top speed
		move.w	#$C,(v_sonspeedacc).w ; Sonic's acceleration
		move.w	#$80,(v_sonspeeddec).w ; Sonic's deceleration

; Obj02_Control:
Tails_Control:	; Routine 2
		bsr.w	Sonic_Control
		rts

; ---------------------------------------------------------------------------
; Tails when he gets hurt (placeholder)
; ---------------------------------------------------------------------------

; Obj02_Hurt:
Tails_Hurt:	; Routine 4	
		jsr	(SpeedToPos).l
		addi.w	#$30,obVelY(a0)
		btst	#6,obStatus(a0)
		beq.s	.notunderwater
		subi.w	#$20,obVelY(a0)

.notunderwater:
		bsr.w	Sonic_HurtStop
		bsr.w	Sonic_LevelBound
		bsr.w	Sonic_RecordPosition
		bsr.w	Sonic_Animate
		bsr.w	Tails_LoadGfx
		jmp	(DisplaySprite).l
	rts

; ---------------------------------------------------------------------------
; Tails when he dies (placeholder)
; ---------------------------------------------------------------------------
; Obj02_Death
Tails_Death:	; Routine 6
		bsr.w	GameOver
		jsr	(ObjectFall).l
		bsr.w	Sonic_RecordPosition
		bsr.w	Sonic_Animate
		bsr.w	Tails_LoadGfx
		jmp	(DisplaySprite).l
		rts

; ---------------------------------------------------------------------------
; Tails when the level is restarted
; ---------------------------------------------------------------------------

; Obj02_ResetLevel:
Tails_ResetLevel:; Routine 8
		tst.w	restartime(a0)
		beq.s	.return
		subq.w	#1,restartime(a0)	; subtract 1 from time delay
		bne.s	.return
		move.w	#1,(f_restart).w ; restart the level

.return:
		rts
; End of function Tails_ResetLevel

	if FixBugs
		; Fix drowning bugs
		; https://info.sonicretro.org/SCHG_How-to:Correct_Drowning_Bugs_in_Sonic_1
; ---------------------------------------------------------------------------
; Tails when he's drowning
; ---------------------------------------------------------------------------
Tails_Drowned:
		bsr.w	SpeedToPos		; Make Sonic able to move
		addi.w	#$10,obVelY(a0)		; Apply gravity
		bsr.w	Sonic_RecordPosition	; Record position
		bsr.w	Sonic_Animate		; Animate Sonic
		bsr.w	Tails_LoadGfx		; Load Sonic's DPLCs
		bra.w	DisplaySprite		; And finally, display Sonic
; End of function Tails_Drowned
	endif
		rts
; ---------------------------------------------------------------------------
; Tails graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; LoadMilesDynPLC:

Tails_LoadGfx:
		jmp	Sonic_LoadGfx
; End of function Tails_LoadGfx
