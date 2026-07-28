; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------
Ani_Sonic:

ptr_Walk:	dc.w SonAni_Walk-Ani_Sonic
ptr_Run:	dc.w SonAni_Run-Ani_Sonic
ptr_Roll:	dc.w SonAni_Roll-Ani_Sonic
ptr_Roll2:	dc.w SonAni_Roll2-Ani_Sonic
ptr_Push:	dc.w SonAni_Push-Ani_Sonic
ptr_Wait:	dc.w SonAni_Wait-Ani_Sonic
ptr_Balance:	dc.w SonAni_Balance-Ani_Sonic
ptr_LookUp:	dc.w SonAni_LookUp-Ani_Sonic
ptr_Duck:	dc.w SonAni_Duck-Ani_Sonic
ptr_Warp1:	dc.w SonAni_Warp1-Ani_Sonic
ptr_Warp2:	dc.w SonAni_Warp2-Ani_Sonic
ptr_Warp3:	dc.w SonAni_Warp3-Ani_Sonic
ptr_Warp4:	dc.w SonAni_Warp4-Ani_Sonic
ptr_Stop:	dc.w SonAni_Stop-Ani_Sonic
ptr_Float1:	dc.w SonAni_Float1-Ani_Sonic
ptr_Float2:	dc.w SonAni_Float2-Ani_Sonic
ptr_Spring:	dc.w SonAni_Spring-Ani_Sonic
ptr_Hang:	dc.w SonAni_Hang-Ani_Sonic
ptr_Leap1:	dc.w SonAni_Leap1-Ani_Sonic
ptr_Leap2:	dc.w SonAni_Leap2-Ani_Sonic
ptr_Surf:	dc.w SonAni_Surf-Ani_Sonic
ptr_GetAir:	dc.w SonAni_GetAir-Ani_Sonic
ptr_Burnt:	dc.w SonAni_Burnt-Ani_Sonic
ptr_Drown:	dc.w SonAni_Drown-Ani_Sonic
ptr_Death:	dc.w SonAni_Death-Ani_Sonic
ptr_Shrink:	dc.w SonAni_Shrink-Ani_Sonic
ptr_Hurt:	dc.w SonAni_Hurt-Ani_Sonic
ptr_WaterSlide:	dc.w SonAni_WaterSlide-Ani_Sonic
ptr_Null:	dc.w SonAni_Null-Ani_Sonic
ptr_Float3:	dc.w SonAni_Float3-Ani_Sonic
ptr_Float4:	dc.w SonAni_Float4-Ani_Sonic
ptr_SpinDash:	dc.w SonAni_SpinDash-Ani_Sonic
ptr_RunFast:	dc.w SonAni_RunFast-Ani_Sonic
ptr_Fly:	dc.w SonAni_Fly-Ani_Sonic
ptr_Transform:	dc.w SonAni_Transform-Ani_Sonic
ptr_Glide:	dc.w SonAni_Glide-Ani_Sonic
ptr_FallFromGlide:	dc.w SonAni_FallFromGlide-Ani_Sonic
ptr_HangFromTails:	dc.w SonAni_HangFromTails-Ani_Sonic
ptr_LandFromGlide:	dc.w SonAni_LandFromGlide-Ani_Sonic
ptr_Carry:	dc.w SonAni_Carry-Ani_Sonic
ptr_CarryUp:	dc.w SonAni_CarryUp-Ani_Sonic	
ptr_FlyTired:	dc.w SonAni_FlyTired-Ani_Sonic
ptr_CarryTired:	dc.w SonAni_CarryTired-Ani_Sonic
ptr_Swim:	dc.w SonAni_Swim-Ani_Sonic
ptr_SwimUp:	dc.w SonAni_SwimUp-Ani_Sonic
ptr_SwimCarry:	dc.w SonAni_SwimCarry-Ani_Sonic
ptr_SwimTired:	dc.w SonAni_SwimTired-Ani_Sonic

SonAni_Walk:	dc.b $FF, fr_Walk13, fr_Walk14,	fr_Walk15, fr_Walk16, fr_Walk11, fr_Walk12, afEnd
		even
SonAni_Run:	dc.b $FF,  fr_Run11,  fr_Run12,  fr_Run13,  fr_Run14,     afEnd,     afEnd, afEnd
		even
SonAni_Roll:	dc.b $FE,  fr_Roll1,  fr_Roll2,  fr_Roll3,  fr_Roll4,  fr_Roll5,     afEnd, afEnd
		even
SonAni_Roll2:	dc.b $FE,  fr_Roll1,  fr_Roll2,  fr_Roll5,  fr_Roll3,  fr_Roll4,  fr_Roll5, afEnd
		even
SonAni_Push:	dc.b $FD,  fr_Push1,  fr_Push2,  fr_Push3,  fr_Push4,     afEnd,     afEnd, afEnd
		even
SonAni_Wait:	dc.b $17, fr_Stand, fr_Stand, fr_Stand, fr_Stand, fr_Stand, fr_Stand, fr_Stand, fr_Stand, fr_Stand
		dc.b fr_Stand, fr_Stand, fr_Stand, fr_Wait2, fr_Wait1, fr_Wait1, fr_Wait1, fr_Wait2, fr_Wait3, afBack, 2
		even
SonAni_Balance:	dc.b $1F, fr_Balance1, fr_Balance2, afEnd
		even
SonAni_LookUp:	dc.b $3F, fr_LookUp, afEnd
		even
SonAni_Duck:	dc.b $3F, fr_Duck, afEnd
		even
SonAni_Warp1:	dc.b $3F, fr_Warp1, afEnd
		even
SonAni_Warp2:	dc.b $3F, fr_Warp2, afEnd
		even
SonAni_Warp3:	dc.b $3F, fr_Warp3, afEnd
		even
SonAni_Warp4:	dc.b $3F, fr_Warp4, afEnd
		even
SonAni_Stop:	dc.b 7,	fr_Stop1, fr_Stop2, afEnd
		even
SonAni_Float1:	dc.b 7,	fr_Float1, fr_Float4, afEnd
		even
SonAni_Float2:	dc.b 7,	fr_Float1, fr_Float2, fr_Float5, fr_Float3, fr_Float6, afEnd
		even
SonAni_Spring:	dc.b $2F, fr_Spring, afChange, id_Walk
		even
SonAni_Hang:	dc.b 4,	fr_Hang1, fr_Hang2, afEnd
		even
SonAni_Leap1:	dc.b $F, fr_Leap1, fr_Leap1, fr_Leap1,	afBack, 1
		even
SonAni_Leap2:	dc.b $F, fr_Leap1, fr_Leap2, afBack, 1
		even
SonAni_Surf:	dc.b $3F, fr_Surf, afEnd
		even
SonAni_GetAir:	dc.b $B, fr_GetAir, fr_GetAir, fr_Walk15, fr_Walk16, afChange, id_Walk
		even
SonAni_Burnt:	dc.b $20, fr_Burnt, afEnd
		even
SonAni_Drown:	dc.b $2F, fr_Drown, afEnd
		even
SonAni_Death:	dc.b 3,	fr_Death, afEnd
		even
SonAni_Shrink:	dc.b 3,	fr_Shrink1, fr_Shrink2, fr_Shrink3, fr_Shrink4, fr_Shrink5, fr_Null, afBack, 1
		even
SonAni_Hurt:	dc.b 3,	fr_Injury, afEnd
		even
SonAni_WaterSlide:
		dc.b 7, fr_Injury, fr_WaterSlide, afEnd
		even
SonAni_Null:	dc.b $77, fr_Null, afChange, id_Walk
		even
SonAni_Float3:	dc.b 3,	fr_Float1, fr_Float2, fr_Float5, fr_Float3, fr_Float6, afEnd
		even
SonAni_Float4:	dc.b 3,	fr_Float1, afChange, id_Walk
		even
SonAni_SpinDash: dc.b 0, $34, $34, $34, $34, $34, $34
		 dc.b $34, $34, $34, $34, afEnd
		 even
SonAni_RunFast	dc.b	$FF, $58, $59, $5A, $5B, afEnd, afEnd, afEnd
SonAni_Fly:
		dc.b 7, $3C, $3F, afEnd
		even
SonAni_Transform:
		dc.b   2,$68,$68,$69,$69,$6A,$6B,$6C,$6B,$6C,$6B,$6C,$6B,$6C,afChange, id_Walk
		even
SonAni_Glide:
		dc.b 7, $3C, $3F, afEnd
		even
SonAni_FallFromGlide:
		dc.b 7, fr_Spring, fr_Spring, afBack, 1
		even
SonAni_HangFromTails:
		dc.b $A, $A5, $A6, $A7, $A6, $A5, $A4, $A3, $A4, afEnd
		even
SonAni_LandFromGlide:dc.b  $F,$3F,afChange,  id_Walk
	even
SonAni_Carry:	dc.b $77, fr_Null, afEnd,afEnd,afEnd,afEnd,afEnd
		even
SonAni_CarryUp:	dc.b $77, fr_Null, afEnd,afEnd,afEnd,afEnd,afEnd
		even
SonAni_FlyTired:	dc.b $77, fr_Null, afEnd,afEnd,afEnd,afEnd,afEnd
		even
SonAni_CarryTired:	dc.b $77, fr_Null, afEnd,afEnd,afEnd,afEnd,afEnd
		even
SonAni_Swim:	dc.b $77, fr_Null, afEnd,afEnd,afEnd,afEnd,afEnd
		even
SonAni_SwimUp:	dc.b $77, fr_Null, afEnd,afEnd,afEnd,afEnd,afEnd
		even
SonAni_SwimCarry:	dc.b $77, fr_Null, afEnd,afEnd,afEnd,afEnd,afEnd
		even
SonAni_SwimTired:	dc.b $77, fr_Null, afEnd,afEnd,afEnd,afEnd,afEnd
		even

id_Walk:	equ (ptr_Walk-Ani_Sonic)/2	; 0
id_Run:		equ (ptr_Run-Ani_Sonic)/2	; 1
id_Roll:	equ (ptr_Roll-Ani_Sonic)/2	; 2
id_Roll2:	equ (ptr_Roll2-Ani_Sonic)/2	; 3
id_Push:	equ (ptr_Push-Ani_Sonic)/2	; 4
id_Wait:	equ (ptr_Wait-Ani_Sonic)/2	; 5
id_Balance:	equ (ptr_Balance-Ani_Sonic)/2	; 6
id_LookUp:	equ (ptr_LookUp-Ani_Sonic)/2	; 7
id_Duck:	equ (ptr_Duck-Ani_Sonic)/2	; 8
id_Warp1:	equ (ptr_Warp1-Ani_Sonic)/2	; 9
id_Warp2:	equ (ptr_Warp2-Ani_Sonic)/2	; $A
id_Warp3:	equ (ptr_Warp3-Ani_Sonic)/2	; $B
id_Warp4:	equ (ptr_Warp4-Ani_Sonic)/2	; $C
id_Stop:	equ (ptr_Stop-Ani_Sonic)/2	; $D
id_Float1:	equ (ptr_Float1-Ani_Sonic)/2	; $E
id_Float2:	equ (ptr_Float2-Ani_Sonic)/2	; $F
id_Spring:	equ (ptr_Spring-Ani_Sonic)/2	; $10
id_Hang:	equ (ptr_Hang-Ani_Sonic)/2	; $11
id_Leap1:	equ (ptr_Leap1-Ani_Sonic)/2	; $12
id_Leap2:	equ (ptr_Leap2-Ani_Sonic)/2	; $13
id_Surf:	equ (ptr_Surf-Ani_Sonic)/2	; $14
id_GetAir:	equ (ptr_GetAir-Ani_Sonic)/2	; $15
id_Burnt:	equ (ptr_Burnt-Ani_Sonic)/2	; $16
id_Drown:	equ (ptr_Drown-Ani_Sonic)/2	; $17
id_Death:	equ (ptr_Death-Ani_Sonic)/2	; $18
id_Shrink:	equ (ptr_Shrink-Ani_Sonic)/2	; $19
id_Hurt:	equ (ptr_Hurt-Ani_Sonic)/2	; $1A
id_WaterSlide:	equ (ptr_WaterSlide-Ani_Sonic)/2 ; $1B
id_Null:	equ (ptr_Null-Ani_Sonic)/2	; $1C
id_Float3:	equ (ptr_Float3-Ani_Sonic)/2	; $1D
id_Float4:	equ (ptr_Float4-Ani_Sonic)/2	; $1E
id_SpinDash:	equ (ptr_SpinDash-Ani_Sonic)/2	; $1F
id_RunFast:	equ (ptr_RunFast-Ani_Sonic)/2	; $20
id_Fly:		equ (ptr_Fly-Ani_Sonic)/2	; $21
id_Transform:		equ (ptr_Transform-Ani_Sonic)/2	; $22
id_Glide:		equ (ptr_Glide-Ani_Sonic)/2	; $23
id_FallFromGlide:		equ (ptr_FallFromGlide-Ani_Sonic)/2	; $24
id_HangFromTails:		equ (ptr_HangFromTails-Ani_Sonic)/2	; $25
id_LandFromGlide:		equ (ptr_LandFromGlide-Ani_Sonic)/2	; $26
id_Carry:	equ (ptr_Carry-Ani_Sonic)/2	; $27
id_CarryUp:	equ (ptr_CarryUp-Ani_Sonic)/2	; $28
id_FlyTired:	equ (ptr_FlyTired-Ani_Sonic)/2	; $29
id_CarryTired:	equ (ptr_CarryTired-Ani_Sonic)/2	; $2A
id_Swim:	equ (ptr_Swim-Ani_Sonic)/2	; $2B
id_SwimUp:	equ (ptr_SwimUp-Ani_Sonic)/2	; $2C
id_SwimCarry:	equ (ptr_SwimCarry-Ani_Sonic)/2	; $2D
id_SwimTired:	equ (ptr_SwimTired-Ani_Sonic)/2	; $2E
;---------------------------------------------------------------------------------------------------------
Ani_SuperSonic:

ptrSS_Walk:	dc.w SupSonAni_Walk-Ani_SuperSonic
ptrSS_Run:	dc.w SupSonAni_Run-Ani_SuperSonic
ptrSS_Roll:	dc.w SupSonAni_Roll-Ani_SuperSonic
ptrSS_Roll2:	dc.w SupSonAni_Roll2-Ani_SuperSonic
ptrSS_Push:	dc.w SupSonAni_Push-Ani_SuperSonic
ptrSS_Wait:	dc.w SupSonAni_Wait-Ani_SuperSonic
ptrSS_Balance:	dc.w SupSonAni_Balance-Ani_SuperSonic
ptrSS_LookUp:	dc.w SupSonAni_LookUp-Ani_SuperSonic
ptrSS_Duck:	dc.w SupSonAni_Duck-Ani_SuperSonic
ptrSS_Warp1:	dc.w SupSonAni_Warp1-Ani_SuperSonic
ptrSS_Warp2:	dc.w SupSonAni_Warp2-Ani_SuperSonic
ptrSS_Warp3:	dc.w SupSonAni_Warp3-Ani_SuperSonic
ptrSS_Warp4:	dc.w SupSonAni_Warp4-Ani_SuperSonic
ptrSS_Stop:	dc.w SupSonAni_Stop-Ani_SuperSonic
ptrSS_Float1:	dc.w SupSonAni_Float1-Ani_SuperSonic
ptrSS_Float2:	dc.w SupSonAni_Float2-Ani_SuperSonic
ptrSS_Spring:	dc.w SupSonAni_Spring-Ani_SuperSonic
ptrSS_Hang:	dc.w SupSonAni_Hang-Ani_SuperSonic
ptrSS_Leap1:	dc.w SupSonAni_Leap1-Ani_SuperSonic
ptrSS_Leap2:	dc.w SupSonAni_Leap2-Ani_SuperSonic
ptrSS_Surf:	dc.w SupSonAni_Surf-Ani_SuperSonic
ptrSS_GetAir:	dc.w SupSonAni_GetAir-Ani_SuperSonic
ptrSS_Burnt:	dc.w SupSonAni_Burnt-Ani_SuperSonic
ptrSS_Drown:	dc.w SupSonAni_Drown-Ani_SuperSonic
ptrSS_Death:	dc.w SupSonAni_Death-Ani_SuperSonic
ptrSS_Shrink:	dc.w SupSonAni_Shrink-Ani_SuperSonic
ptrSS_Hurt:	dc.w SupSonAni_Hurt-Ani_SuperSonic
ptrSS_WaterSlide:	dc.w SupSonAni_WaterSlide-Ani_SuperSonic
ptrSS_Null:	dc.w SupSonAni_Null-Ani_SuperSonic
ptrSS_Float3:	dc.w SupSonAni_Float3-Ani_SuperSonic
ptrSS_Float4:	dc.w SupSonAni_Float4-Ani_SuperSonic
ptrSS_SpinDash:	dc.w SupSonAni_SpinDash-Ani_SuperSonic
ptrSS_RunFast:	dc.w SupSonAni_RunFast-Ani_SuperSonic
ptrSS_Fly:	dc.w SupSonAni_Fly-Ani_SuperSonic
ptrSS_Transform:	dc.w SupSonAni_Transform-Ani_SuperSonic
ptrSS_Glide:	dc.w SupSonAni_Glide-Ani_SuperSonic
ptrSS_FallFromGlide:	dc.w SupSonAni_FallFromGlide-Ani_SuperSonic
ptrSS_HangFromTails:	dc.w SupSonAni_HangFromTails-Ani_SuperSonic
ptrSS_LandFromGlide:	dc.w SonAni_LandFromGlide-Ani_SuperSonic
ptrSS_Carry:	dc.w SonAni_Carry-Ani_SuperSonic
ptrSS_CarryUp:	dc.w SonAni_CarryUp-Ani_SuperSonic	
ptrSS_FlyTired:	dc.w SonAni_FlyTired-Ani_SuperSonic
ptrSS_CarryTired:	dc.w SonAni_CarryTired-Ani_SuperSonic
ptrSS_Swim:	dc.w SonAni_Swim-Ani_SuperSonic
ptrSS_SwimUp:	dc.w SonAni_SwimUp-Ani_SuperSonic
ptrSS_SwimCarry:	dc.w SonAni_SwimCarry-Ani_SuperSonic
ptrSS_SwimTired:	dc.w SonAni_SwimTired-Ani_SuperSonic

SupSonAni_Walk:	dc.b $FF,$70,$71,$72,$73,$74,$75,$FF,$FF,$FF
		even
SupSonAni_Run:	dc.b $FF,$88,$89,$88,$89,$FF,$FF,$FF,$FF,$FF
		even
SupSonAni_Roll:	dc.b $FE,  fr_Roll1,  fr_Roll2,  fr_Roll3,  fr_Roll4,  fr_Roll5,     afEnd, afEnd
		even
SupSonAni_Roll2:	dc.b $FE,  fr_Roll1,  fr_Roll2,  fr_Roll5,  fr_Roll3,  fr_Roll4,  fr_Roll5, afEnd
		even
SupSonAni_Push:	dc.b $FD,$98,$99,$9A,$9B,afEnd,afEnd,afEnd,afEnd,afEnd
		even
SupSonAni_Wait:	dc.b   7,$6D,$6E,$6F,$6E,$FF
		even
SupSonAni_Balance:	dc.b   9,$9D,$9E,$9F,$9E,$A0,$A1,$A2,$A1,$FF
	even
SupSonAni_LookUp:	dc.b $3F, fr_LookUp, afEnd
		even
SupSonAni_Duck:	dc.b $3F, $9C, afEnd
		even
SupSonAni_Warp1:	dc.b $3F, fr_Warp1, afEnd
		even
SupSonAni_Warp2:	dc.b $3F, fr_Warp2, afEnd
		even
SupSonAni_Warp3:	dc.b $3F, fr_Warp3, afEnd
		even
SupSonAni_Warp4:	dc.b $3F, fr_Warp4, afEnd
		even
SupSonAni_Stop:	dc.b 7,	fr_Stop1, fr_Stop2, afEnd
		even
SupSonAni_Float1:	dc.b 7,	fr_Float1, fr_Float4, afEnd
		even
SupSonAni_Float2:	dc.b 7,	fr_Float1, fr_Float2, fr_Float5, fr_Float3, fr_Float6, afEnd
		even
SupSonAni_Spring:	dc.b $2F, fr_Spring, afChange, id_Walk
		even
SupSonAni_Hang:	dc.b 4,	fr_Hang1, fr_Hang2, afEnd
		even
SupSonAni_Leap1:	dc.b $F, fr_Leap1, fr_Leap1, fr_Leap1,	afBack, 1
		even
SupSonAni_Leap2:	dc.b $F, fr_Leap1, fr_Leap2, afBack, 1
		even
SupSonAni_Surf:	dc.b $3F, fr_Surf, afEnd
		even
SupSonAni_GetAir:	dc.b $B, fr_GetAir, fr_GetAir, fr_Walk15, fr_Walk16, afChange, id_Walk
		even
SupSonAni_Burnt:	dc.b $20, fr_Burnt, afEnd
		even
SupSonAni_Drown:	dc.b $2F, fr_Drown, afEnd
		even
SupSonAni_Death:	dc.b 3,	fr_Death, afEnd
		even
SupSonAni_Shrink:	dc.b 3,	fr_Shrink1, fr_Shrink2, fr_Shrink3, fr_Shrink4, fr_Shrink5, fr_Null, afBack, 1
		even
SupSonAni_Hurt:	dc.b 3,	fr_Injury, afEnd
		even
SupSonAni_WaterSlide:
		dc.b 7, fr_Injury, fr_WaterSlide, afEnd
		even
SupSonAni_Null:	dc.b $77, fr_Null, afChange, id_Walk
		even
SupSonAni_Float3:	dc.b 3,	fr_Float1, fr_Float2, fr_Float5, fr_Float3, fr_Float6, afEnd
		even
SupSonAni_Float4:	dc.b 3,	fr_Float1, afChange, id_Walk
		even
SupSonAni_SpinDash: dc.b 0, $34, $34, $34, $34, $34, $34
		 dc.b $34, $34, $34, $34, afEnd
		 even
SupSonAni_RunFast	dc.b $FF,$88,$89,$8A,$8B,$FF,$FF,$FF,$FF,$FF
		even
SupSonAni_Fly:
		dc.b 7, $88, $89, afEnd
		even
SupSonAni_Transform:
		dc.b   2,$68,$68,$69,$69,$6A,$6B,$6C,$6B,$6C,$6B,$6C,$6B,$6C,afChange, id_Walk
		even
SupSonAni_Glide:
		dc.b 7, $88, $89, afEnd
		even
SupSonAni_FallFromGlide:
		dc.b 7, fr_Spring, fr_Spring, afBack, 1
		even

SupSonAni_HangFromTails:
		dc.b $A, $A5, $A6, $A7, $A6, $A5, $A4, $A3, $A4, afEnd
		even

idSS_Walk:	equ (ptr_Walk-Ani_SuperSonic)/2	; 0
idSS_Run:		equ (ptr_Run-Ani_SuperSonic)/2	; 1
idSS_Roll:	equ (ptr_Roll-Ani_SuperSonic)/2	; 2
idSS_Roll2:	equ (ptr_Roll2-Ani_SuperSonic)/2	; 3
idSS_Push:	equ (ptr_Push-Ani_SuperSonic)/2	; 4
idSS_Wait:	equ (ptr_Wait-Ani_SuperSonic)/2	; 5
idSS_Balance:	equ (ptr_Balance-Ani_SuperSonic)/2	; 6
idSS_LookUp:	equ (ptr_LookUp-Ani_SuperSonic)/2	; 7
idSS_Duck:	equ (ptr_Duck-Ani_SuperSonic)/2	; 8
idSS_Warp1:	equ (ptr_Warp1-Ani_SuperSonic)/2	; 9
idSS_Warp2:	equ (ptr_Warp2-Ani_SuperSonic)/2	; $A
idSS_Warp3:	equ (ptr_Warp3-Ani_SuperSonic)/2	; $B
idSS_Warp4:	equ (ptr_Warp4-Ani_SuperSonic)/2	; $C
idSS_Stop:	equ (ptr_Stop-Ani_SuperSonic)/2	; $D
idSS_Float1:	equ (ptr_Float1-Ani_SuperSonic)/2	; $E
idSS_Float2:	equ (ptr_Float2-Ani_SuperSonic)/2	; $F
idSS_Spring:	equ (ptr_Spring-Ani_SuperSonic)/2	; $10
idSS_Hang:	equ (ptr_Hang-Ani_SuperSonic)/2	; $11
idSS_Leap1:	equ (ptr_Leap1-Ani_SuperSonic)/2	; $12
idSS_Leap2:	equ (ptr_Leap2-Ani_SuperSonic)/2	; $13
idSS_Surf:	equ (ptr_Surf-Ani_SuperSonic)/2	; $14
idSS_GetAir:	equ (ptr_GetAir-Ani_SuperSonic)/2	; $15
idSS_Burnt:	equ (ptr_Burnt-Ani_SuperSonic)/2	; $16
idSS_Drown:	equ (ptr_Drown-Ani_SuperSonic)/2	; $17
idSS_Death:	equ (ptr_Death-Ani_SuperSonic)/2	; $18
idSS_Shrink:	equ (ptr_Shrink-Ani_SuperSonic)/2	; $19
idSS_Hurt:	equ (ptr_Hurt-Ani_SuperSonic)/2	; $1A
idSS_WaterSlide:	equ (ptr_WaterSlide-Ani_SuperSonic)/2 ; $1B
idSS_Null:	equ (ptr_Null-Ani_SuperSonic)/2	; $1C
idSS_Float3:	equ (ptr_Float3-Ani_SuperSonic)/2	; $1D
idSS_Float4:	equ (ptr_Float4-Ani_SuperSonic)/2	; $1E
idSS_SpinDash:	equ (ptr_SpinDash-Ani_SuperSonic)/2	; $1F
idSS_RunFast:	equ (ptr_RunFast-Ani_SuperSonic)/2	; $20
idSS_Fly:		equ (ptr_Fly-Ani_SuperSonic)/2	; $21
idSS_Transform:		equ (ptr_Transform-Ani_SuperSonic)/2	; $22
idSS_Glide:		equ (ptr_Glide-Ani_SuperSonic)/2	; $23
idSS_FallFromGlide:		equ (ptr_FallFromGlide-Ani_SuperSonic)/2	; $24
idSS_HangFromTails:		equ (ptr_HangFromTails-Ani_SuperSonic)/2	; $25
idSS_LandFromGlide:		equ (ptr_LandFromGlide-Ani_Sonic)/2	; $26
idSS_Carry:	equ (ptr_Carry-Ani_Sonic)/2	; $27
idSS_CarryUp:	equ (ptr_CarryUp-Ani_Sonic)/2	; $28
idSS_FlyTired:	equ (ptr_FlyTired-Ani_Sonic)/2	; $29
idSS_CarryTired:	equ (ptr_CarryTired-Ani_Sonic)/2	; $2A
idSS_Swim:	equ (ptr_Swim-Ani_Sonic)/2	; $2B
idSS_SwimUp:	equ (ptr_SwimUp-Ani_Sonic)/2	; $2C
idSS_SwimCarry:	equ (ptr_SwimCarry-Ani_Sonic)/2	; $2D
idSS_SwimTired:	equ (ptr_SwimTired-Ani_Sonic)/2	; $2E
