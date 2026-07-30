; ===========================================================================
; ----------------------------------------------------------------------------
; Object 05 - Tails' tails
; ----------------------------------------------------------------------------
; Sprite_1D200:
Obj05:
	moveq	#0,d0
	move.b	obRoutine(a0),d0
	move.w	Obj05_Index(pc,d0.w),d1
	jmp	Obj05_Index(pc,d1.w)
; ===========================================================================
; off_1D20E: Obj05_States:
Obj05_Index:
		dc.w Obj05_Init-Obj05_Index	; 0
		dc.w Obj05_Main-Obj05_Index	; 2
; ===========================================================================
TailsTails_LastLoadedDPLC = v_tlstlsframenum
Obj05_parent_prev_anim = objoff_30

; loc_1D212
Obj05_Init:
	addq.b	#2,obRoutine(a0) ; => Obj05_Main
	move.l	#Map_Miles,obMap(a0)
	move.w	#make_art_tile(ArtTile_TailsTails,0,0),obGfx(a0)
	move.b	#2,obPriority(a0)
	move.b	#$18,obActWid(a0)
	move.b	#4,obRender(a0)

; loc_1D23A:
Obj05_Main:
	movea.w	objoff_3E(a0),a2 ; a2=character
	move.b	obAngle(a2),obAngle(a0)
	move.b	obStatus(a2),obStatus(a0)
	move.w	obX(a2),obX(a0)
	move.w	obY(a2),obY(a0)			;chunk setting obGfx was missing earlier, existed in S2 but i forgot
	andi.w	#$7FFF,obGfx(a0)		;#drawing_mask,art_tile
	tst.w	obGfx(a2)
	bpl.s	.skiparttile
	ori.w	#(1<<15),obGfx(a0)		;#high_priority,art_tile
.skiparttile:
	moveq	#0,d0
	move.b	obAnim(a2),d0
	btst	#5,obStatus(a2)	; is Tails pushing something?
	beq.s	.pushing	;if yes, branch
    
	moveq	#4,d0
.pushing:
	cmp.b	Obj05_parent_prev_anim(a0),d0
	beq.s	.display
	move.b	d0,Obj05_parent_prev_anim(a0)
	move.b	Obj05AniSelection(pc,d0.w),obAnim(a0)
; loc_1D288:
.display:
	lea	(Obj05AniData).l,a1
	bsr.w	Tails_Animate2
	bsr.w	LoadTailsTailsDynPLC
	jsr	(DisplaySprite).l
	rts
; ===========================================================================
; animation master script table for the tails
; chooses which animation script to run depending on what Tails is doing
; byte_1D29E:
Obj05AniSelection:
	dc.b	0,0	; TlsAni_Walk,Run			->
	dc.b	3	; TlsAni_Roll				-> Directional
	dc.b	3	; TlsAni_Roll2				-> Directional
	dc.b	9	; TlsAni_Push				-> Pushing
	dc.b	1	; TlsAni_Wait				-> Swish
	dc.b	0	; TlsAni_Balance			-> Blank
	dc.b	2	; TlsAni_LookUp				-> Flick
	dc.b	1	; TlsAni_Duck				-> Swish
	dc.b	0,0,0,0	; TlsAni_Warp1,2,3,4			->
	dc.b	8	; TlsAni_Stop				-> Skidding
	dc.b	0,0	; TlsAni_Float1,2			->
	dc.b	0	; TlsAni_Spring				->
	dc.b	0	; TlsAni_Hang				->
	dc.b	0,0	; TlsAni_Leap1,2			->
	dc.b	$A	; TlsAni_Surf				-> Hanging
	dc.b	0	; TlsAni_GetAir				->
	dc.b	0,0,0,0	; TlsAni_Burnt,Drown,Death,Shrink	->
	dc.b	0,0	; TlsAni_Hurt,WaterSlide		->
	dc.b	0	; TlsAni_Null				->
	dc.b	0,0	; TlsAni_Float3,4			->
	dc.b	7	; TlsAni_SpinDash			-> Spindash
	dc.b	0	; TlsAni_RunFast			->
	dc.b	$B	; TlsAni_Fly				->
	dc.b	0	; TlsAni_Transform			->
	dc.b	0	; TlsAni_Glide				->
	dc.b	0	; TlsAni_FallFromGlide			->
	dc.b	$A	; TlsAni_HangFromTails			->
	dc.b	1	; TlsAni_LandFromGlide				-> Swish
	dc.b	$B	; TlsAni_Carry				->
	dc.b	$B	; TlsAni_CarryUp				->
	dc.b	$B	; TlsAni_FlyTired				->
	dc.b	$B	; TlsAni_CarryTired				->
	dc.b	0	; TlsAni_Swim			->
	dc.b	0	; TlsAni_SwimUp			->
	dc.b	0	; TlsAni_SwimCarry				->
	dc.b	0	; TlsAni_SwimTired			->
	even
; ---------------------------------------------------------------------------
; Animation script - Tails' tails
; ---------------------------------------------------------------------------
; off_1D2C0:
Obj05AniData:
		dc.w Obj05Ani_Blank-Obj05AniData	;  0
		dc.w Obj05Ani_Swish-Obj05AniData	;  1
		dc.w Obj05Ani_Flick-Obj05AniData	;  2
		dc.w Obj05Ani_Directional-Obj05AniData	;  3
		dc.w Obj05Ani_DownLeft-Obj05AniData	;  4
		dc.w Obj05Ani_Down-Obj05AniData	;  5
		dc.w Obj05Ani_DownRight-Obj05AniData	;  6
		dc.w Obj05Ani_Spindash-Obj05AniData	;  7
		dc.w Obj05Ani_Skidding-Obj05AniData	;  8
		dc.w Obj05Ani_Pushing-Obj05AniData	;  9
		dc.w Obj05Ani_Hanging-Obj05AniData	; $A
		dc.w Obj05Ani_Flying-Obj05AniData	; $B

Obj05Ani_Blank:		dc.b $20,  0,$FF
	even
Obj05Ani_Swish:		dc.b   7,  9, $A, $B, $C, $D,$FF
	even
Obj05Ani_Flick:		dc.b   3,  9, $A, $B, $C, $D,$FD,  1
	even
Obj05Ani_Directional:	dc.b $FC,$49,$4A,$4B,$4C,$FF ; Tails is moving right
	even
Obj05Ani_DownLeft:	dc.b   3,$4D,$4E,$4F,$50,$FF ; Tails is moving up-right
	even
Obj05Ani_Down:		dc.b   3,$51,$52,$53,$54,$FF ; Tails is moving up
	even
Obj05Ani_DownRight:	dc.b   3,$55,$56,$57,$58,$FF ; Tails is moving up-left
	even
Obj05Ani_Spindash:	dc.b   2,$81,$82,$83,$84,$FF
	even
Obj05Ani_Skidding:	dc.b   2,$87,$88,$89,$8A,$FF
	even
Obj05Ani_Pushing:	dc.b   9,$87,$88,$89,$8A,$FF
	even
Obj05Ani_Hanging:	dc.b   9,$81,$82,$83,$84,$FF
	even
Obj05Ani_Flying:	dc.b   1,$8E,$8F,$FF
	even

; ===========================================================================
; ===========================================================================

; ---------------------------------------------------------------------------
; Tails' Tails pattern loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_1D184:
LoadTailsTailsDynPLC:
		cmpi.b	#$8F,obFrame(a0) ; higher than $8D?
		bhi.s	.nullanim		; if yes, branch to avoid invalid animations
		bra.s	.movefromanimtest		; branch to rest of code
.nullanim:
		move.b	#0,obFrame(a0)	; load sprite number
		rts
	.movefromanimtest:
		move.b	obFrame(a0),d0			; get Sonic's current frame
		cmp.b	(v_tlstlsframenum).w,d0		; has the frame changed?
		beq.s	.end				; if not, nothing to do
		move.b	d0,(v_tlstlsframenum).w		; update cached frame number
		lea	(MilesDynPLC).l,a2	; load Tails' DPLC
		move.w	#ArtTile_TailsTails*tile_size,d4	; starting VRAM tile
		move.l	#Art_Miles,d6
		jmp	(LoadDynPLC).l			; load DPLC


.end:
	rts