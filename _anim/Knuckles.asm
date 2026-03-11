; ---------------------------------------------------------------------------
; Animation script - Knuckles
; ---------------------------------------------------------------------------
Ani_Knuckles:

ptr_WalkKnuckles:	dc.w KnucklesAni_Walk-Ani_Knuckles
ptr_RunKnuckles:	dc.w KnucklesAni_Run-Ani_Knuckles
ptr_RollKnuckles:	dc.w KnucklesAni_Roll-Ani_Knuckles
ptr_Roll2Knuckles:	dc.w KnucklesAni_Roll2-Ani_Knuckles
ptr_PushKnuckles:	dc.w KnucklesAni_Push-Ani_Knuckles
ptr_WaitKnuckles:	dc.w KnucklesAni_Wait-Ani_Knuckles
ptr_BalanceKnuckles:	dc.w KnucklesAni_Balance-Ani_Knuckles
ptr_LookUpKnuckles:	dc.w KnucklesAni_LookUp-Ani_Knuckles
ptr_DuckKnuckles:	dc.w KnucklesAni_Duck-Ani_Knuckles
ptr_Warp1Knuckles:	dc.w KnucklesAni_Warp1-Ani_Knuckles
ptr_Warp2Knuckles:	dc.w KnucklesAni_Warp2-Ani_Knuckles
ptr_Warp3Knuckles:	dc.w KnucklesAni_Warp3-Ani_Knuckles
ptr_Warp4Knuckles:	dc.w KnucklesAni_Warp4-Ani_Knuckles
ptr_StopKnuckles:	dc.w KnucklesAni_Stop-Ani_Knuckles
ptr_Float1Knuckles:	dc.w KnucklesAni_Float1-Ani_Knuckles
ptr_Float2Knuckles:	dc.w KnucklesAni_Float2-Ani_Knuckles
ptr_SpringKnuckles:	dc.w KnucklesAni_Spring-Ani_Knuckles
ptr_HangKnuckles:	dc.w KnucklesAni_Hang-Ani_Knuckles
ptr_Leap1Knuckles:	dc.w KnucklesAni_Leap1-Ani_Knuckles
ptr_Leap2Knuckles:	dc.w KnucklesAni_Leap2-Ani_Knuckles
ptr_SurfKnuckles:	dc.w KnucklesAni_Surf-Ani_Knuckles
ptr_GetAirKnuckles:	dc.w KnucklesAni_GetAir-Ani_Knuckles
ptr_BurntKnuckles:	dc.w KnucklesAni_Burnt-Ani_Knuckles
ptr_DrownKnuckles:	dc.w KnucklesAni_Drown-Ani_Knuckles
ptr_DeathKnuckles:	dc.w KnucklesAni_Death-Ani_Knuckles
ptr_ShrinkKnuckles:	dc.w KnucklesAni_Shrink-Ani_Knuckles
ptr_HurtKnuckles:	dc.w KnucklesAni_Hurt-Ani_Knuckles
ptr_WaterSlideKnuckles:	dc.w KnucklesAni_WaterSlide-Ani_Knuckles
ptr_NullKnuckles:	dc.w KnucklesAni_Null-Ani_Knuckles
ptr_Float3Knuckles:	dc.w KnucklesAni_Float3-Ani_Knuckles
ptr_Float4Knuckles:	dc.w KnucklesAni_Float4-Ani_Knuckles
ptr_SpinDashKnuckles:	dc.w KnucklesAni_SpinDash-Ani_Knuckles
ptr_RunFastKnuckles:	dc.w KnucklesAni_RunFast-Ani_Knuckles
ptr_FlyKnuckles:	dc.w KnucklesAni_Fly-Ani_Knuckles
ptr_TransformKnuckles:	dc.w KnucklesAni_Transform-Ani_Knuckles

KnucklesAni_Walk:	dc.b $FF,  7,	8,  1,	2,  3,	4,  5,	6, afEnd
		even
KnucklesAni_Run:	dc.b $FF,  $21,  $22,  $23,  $24, afEnd, afEnd, afEnd, afEnd, afEnd
		even
KnucklesAni_Roll:	dc.b $FE,  $96,  $97,  $98,  $99,  $9A,     afEnd, afEnd
		even
KnucklesAni_Roll2:	dc.b $FE,  $96,  $97,  $9A,  $98,  $99,  $9A, afEnd
		even
KnucklesAni_Push:	dc.b  $FD,$CE,$CF,$D0,$D1, afEnd,afEnd,afEnd,afEnd,afEnd
		even
KnucklesAni_Wait:	dc.b    5, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56
		dc.b  $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56
		dc.b  $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $56, $D2, $D2, $D2, $D3, $D3, $D3, $D2, $D2, $D2
		dc.b  $D3, $D3, $D3, $D2, $D2, $D2, $D3, $D3, $D3, $D2, $D2, $D2, $D3, $D3, $D3, $D2, $D2, $D2, $D3, $D3
		dc.b  $D3, $D2, $D2, $D2, $D3, $D3, $D3, $D2, $D2, $D2, $D3, $D3, $D3, $D2, $D2, $D2, $D3, $D3, $D3, $D2
		dc.b  $D2, $D2, $D3, $D3, $D3, $D4, $D4, $D4, $D4, $D4, $D7, $D8, $D9, $DA, $DB, $D8, $D9, $DA, $DB, $D8
		dc.b  $D9, $DA, $DB, $D8, $D9, $DA, $DB, $D8, $D9, $DA, $DB, $D8, $D9, $DA, $DB, $D8, $D9, $DA, $DB, $D8
		dc.b  $D9, $DA, $DB, $DC, $DD, $DC, $DD, $DE, $DE, $D8, $D7, $FF
		even
KnucklesAni_Balance:	dc.b   3,$9F,$9F,$A0,$A0,$A1,$A1,$A2,$A2,$A3,$A3,$A4,$A4; 0	; ...
		dc.b $A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5; 13
		dc.b $A5,$A5,$A6,$A6,$A6,$A7,$A7,$A7,$A8,$A8,$A9,$A9,$AA; 26
		dc.b $AA,$FE,  6		  ; 39
		even
KnucklesAni_LookUp:	dc.b    5, $D5, $D6, afBack,   1
		even
KnucklesAni_Duck:	dc.b    5, $9B, $9C, afBack,   1
		even
KnucklesAni_Warp1:	dc.b $3F, 0, afEnd
		even
KnucklesAni_Warp2:	dc.b $3F, 0, afEnd
		even
KnucklesAni_Warp3:	dc.b $3F, 0, afEnd
		even
KnucklesAni_Warp4:	dc.b $3F, 0, afEnd
		even
KnucklesAni_Stop:	dc.b 3,$9D,$9E,$9F,$A0, afChange, id_Walk
		even
KnucklesAni_Float1:dc.b	 7,$C0,$FF		    ; 0	; ...
		even
KnucklesAni_Float2:dc.b	  5,$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,afEnd
		even
KnucklesAni_Spring:	dc.b $2F, $8E, afChange, id_Walk
		even
KnucklesAni_Hang:	dc.b 4,	$AE, $AF, afEnd
		even
KnucklesAni_Leap1:	dc.b $F, fr_Leap1, fr_Leap1, fr_Leap1,	afBack, 1
		even
KnucklesAni_Leap2:	dc.b 	5,$B1,$B2,$B2,$B2,$B3,$B4,$FE,	1,  7,$B1,$B3,$B3; 0 ; ...
		even
KnucklesAni_Surf:	dc.b $3F, fr_Surf, afEnd
		even
KnucklesAni_GetAir:	dc.b  $B,$B0,$B0,  3,  4, afChange, id_Walk
		even
KnucklesAni_Burnt:	dc.b $20, $AC, afEnd
		even
KnucklesAni_Drown:	dc.b $2F, $AD, afEnd
		even
KnucklesAni_Death:	dc.b 3,	$AB, afEnd
		even
KnucklesAni_Shrink:	dc.b 3,	0,0, 0, 0, 0, fr_Null, afBack, 1
		even
KnucklesAni_Hurt:	dc.b 3,	$8D, afEnd
		even
KnucklesAni_WaterSlide:
		dc.b 7, $8C, $8D, afEnd
		even
KnucklesAni_Null:	dc.b $77, fr_Null, afChange, id_Walk
		even
KnucklesAni_Float3:	dc.b	5,$C0,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,afEnd
		even
KnucklesAni_Float4:dc.b   3,$CF,$C8,$C9,$CA,$CB,afChange, id_Walk	  ; 0 ; ...
		even
KnucklesAni_SpinDash: dc.b 0, $86, $87, $86, $88, $86, $89
		 dc.b $86, $8A, $86, $8B, afEnd
		 even
KnucklesAni_RunFast	dc.b $FF,  $21,  $22,  $23,  $24, afEnd, afEnd, afEnd, afEnd, afEnd
KnucklesAni_Fly:
		dc.b 7, $C0, $C0, afEnd
		even
KnucklesAni_Transform:
		dc.b   2,$EB,$EB,$EC,$ED,$EC,$ED,$EC,$ED,$EC,$ED,$EC,$ED;	0 ; ...
		dc.b 	afChange,  id_Walk		  ; 13
		even

id_WalkKnuckles:	equ (ptr_WalkKnuckles-Ani_Knuckles)/2	; 0
id_RunKnuckles:		equ (ptr_RunKnuckles-Ani_Knuckles)/2	; 1
id_RollKnuckles:	equ (ptr_RollKnuckles-Ani_Knuckles)/2	; 2
id_Roll2Knuckles:	equ (ptr_Roll2Knuckles-Ani_Knuckles)/2	; 3
id_PushKnuckles:	equ (ptr_PushKnuckles-Ani_Knuckles)/2	; 4
id_WaitKnuckles:	equ (ptr_WaitKnuckles-Ani_Knuckles)/2	; 5
id_BalanceKnuckles:	equ (ptr_BalanceKnuckles-Ani_Knuckles)/2	; 6
id_LookUpKnuckles:	equ (ptr_LookUpKnuckles-Ani_Knuckles)/2	; 7
id_DuckKnuckles:	equ (ptr_DuckKnuckles-Ani_Knuckles)/2	; 8
id_Warp1Knuckles:	equ (ptr_Warp1Knuckles-Ani_Knuckles)/2	; 9
id_Warp2Knuckles:	equ (ptr_Warp2Knuckles-Ani_Knuckles)/2	; $A
id_Warp3Knuckles:	equ (ptr_Warp3Knuckles-Ani_Knuckles)/2	; $B
id_Warp4Knuckles:	equ (ptr_Warp4Knuckles-Ani_Knuckles)/2	; $C
id_StopKnuckles:	equ (ptr_StopKnuckles-Ani_Knuckles)/2	; $D
id_Float1Knuckles:	equ (ptr_Float1Knuckles-Ani_Knuckles)/2	; $E
id_Float2Knuckles:	equ (ptr_Float2Knuckles-Ani_Knuckles)/2	; $F
id_SpringKnuckles:	equ (ptr_SpringKnuckles-Ani_Knuckles)/2	; $10
id_HangKnuckles:	equ (ptr_HangKnuckles-Ani_Knuckles)/2	; $11
id_Leap1Knuckles:	equ (ptr_Leap1Knuckles-Ani_Knuckles)/2	; $12
id_Leap2Knuckles:	equ (ptr_Leap2Knuckles-Ani_Knuckles)/2	; $13
id_SurfKnuckles:	equ (ptr_SurfKnuckles-Ani_Knuckles)/2	; $14
id_GetAirKnuckles:	equ (ptr_GetAirKnuckles-Ani_Knuckles)/2	; $15
id_BurntKnuckles:	equ (ptr_BurntKnuckles-Ani_Knuckles)/2	; $16
id_DrownKnuckles:	equ (ptr_DrownKnuckles-Ani_Knuckles)/2	; $17
id_DeathKnuckles:	equ (ptr_DeathKnuckles-Ani_Knuckles)/2	; $18
id_ShrinkKnuckles:	equ (ptr_ShrinkKnuckles-Ani_Knuckles)/2	; $19
id_HurtKnuckles:	equ (ptr_HurtKnuckles-Ani_Knuckles)/2	; $1A
id_WaterSlideKnuckles:	equ (ptr_WaterSlideKnuckles-Ani_Knuckles)/2 ; $1B
id_NullKnuckles:	equ (ptr_NullKnuckles-Ani_Knuckles)/2	; $1C
id_Float3Knuckles:	equ (ptr_Float3Knuckles-Ani_Knuckles)/2	; $1D
id_Float4Knuckles:	equ (ptr_Float4Knuckles-Ani_Knuckles)/2	; $1E
id_SpinDashKnuckles:	equ (ptr_SpinDashKnuckles-Ani_Knuckles)/2	; $1F
id_RunFastKnuckles:	equ (ptr_RunFastKnuckles-Ani_Knuckles)/2	; $1F
id_FlyKnuckles:		equ (ptr_FlyKnuckles-Ani_Knuckles)/2	; $1F
id_TransformKnuckles:		equ (ptr_TransformKnuckles-Ani_Knuckles)/2	; $1F
;---------------------------------------------------------------------------------------------------------
