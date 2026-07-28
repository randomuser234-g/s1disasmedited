; ---------------------------------------------------------------------------
; Animation script - Tails
; ---------------------------------------------------------------------------
Ani_Tails:

ptr2_Walk:	dc.w TlsAni_Walk-Ani_Tails
ptr2_Run:	dc.w TlsAni_Run-Ani_Tails
ptr2_Roll:	dc.w TlsAni_Roll-Ani_Tails
ptr2_Roll2:	dc.w TlsAni_Roll2-Ani_Tails
ptr2_Push:	dc.w TlsAni_Push-Ani_Tails
ptr2_Wait:	dc.w TlsAni_Wait-Ani_Tails
ptr2_Balance:	dc.w TlsAni_Balance-Ani_Tails
ptr2_LookUp:	dc.w TlsAni_LookUp-Ani_Tails
ptr2_Duck:	dc.w TlsAni_Duck-Ani_Tails
ptr2_Warp1:	dc.w TlsAni_Warp1-Ani_Tails
ptr2_Warp2:	dc.w TlsAni_Warp2-Ani_Tails
ptr2_Warp3:	dc.w TlsAni_Warp3-Ani_Tails
ptr2_Warp4:	dc.w TlsAni_Warp4-Ani_Tails
ptr2_Stop:	dc.w TlsAni_Stop-Ani_Tails
ptr2_Float1:	dc.w TlsAni_Float1-Ani_Tails
ptr2_Float2:	dc.w TlsAni_Float2-Ani_Tails
ptr2_Spring:	dc.w TlsAni_Spring-Ani_Tails
ptr2_Hang:	dc.w TlsAni_Hang-Ani_Tails
ptr2_Leap1:	dc.w TlsAni_Leap1-Ani_Tails
ptr2_Leap2:	dc.w TlsAni_Leap2-Ani_Tails
ptr2_Surf:	dc.w TlsAni_Surf-Ani_Tails
ptr2_GetAir:	dc.w TlsAni_GetAir-Ani_Tails
ptr2_Burnt:	dc.w TlsAni_Burnt-Ani_Tails
ptr2_Drown:	dc.w TlsAni_Drown-Ani_Tails
ptr2_Death:	dc.w TlsAni_Death-Ani_Tails
ptr2_Shrink:	dc.w TlsAni_Shrink-Ani_Tails
ptr2_Hurt:	dc.w TlsAni_Hurt-Ani_Tails
ptr2_WaterSlide:	dc.w TlsAni_WaterSlide-Ani_Tails
ptr2_Null:	dc.w TlsAni_Null-Ani_Tails
ptr2_Float3:	dc.w TlsAni_Float3-Ani_Tails
ptr2_Float4:	dc.w TlsAni_Float4-Ani_Tails
ptr2_SpinDash:	dc.w TlsAni_SpinDash-Ani_Tails
ptr2_RunFast:	dc.w TlsAni_RunFast-Ani_Tails
ptr2_Fly:	dc.w TlsAni_Fly-Ani_Tails
ptr2_Transform:	dc.w TlsAni_Transform-Ani_Tails
ptr2_Glide:	dc.w TlsAni_Glide-Ani_Tails
ptr2_FallFromGlide:	dc.w TlsAni_FallFromGlide-Ani_Tails
ptr2_HangFromTails:	dc.w TlsAni_HangFromTails-Ani_Tails
ptr2_LandFromGlide:	dc.w TlsAni_LandFromGlide-Ani_Tails
ptr2_Carry:	dc.w TlsAni_Carry-Ani_Tails
ptr2_CarryUp:	dc.w TlsAni_CarryUp-Ani_Tails	
ptr2_FlyTired:	dc.w TlsAni_FlyTired-Ani_Tails
ptr2_CarryTired:	dc.w TlsAni_CarryTired-Ani_Tails
ptr2_Swim:	dc.w TlsAni_Swim-Ani_Tails
ptr2_SwimUp:	dc.w TlsAni_SwimUp-Ani_Tails
ptr2_SwimCarry:	dc.w TlsAni_SwimCarry-Ani_Tails
ptr2_SwimTired:	dc.w TlsAni_SwimTired-Ani_Tails

TlsAni_Walk:	dc.b $FF, $10, $11,	$12, $13, $14, 15, $F, $E, afEnd
		even
TlsAni_Run:	dc.b $FF,  $2E,  $2F,  $30,  $31, afEnd,  afEnd, afEnd,     afEnd, afEnd
		even
TlsAni_Roll:	dc.b $FE,  $48,  $47,  $46,     afEnd, afEnd
		even
TlsAni_Roll2:	dc.b $FE,  $48,  $47,  $46, afEnd
		even
TlsAni_Push:	dc.b $FD,  $63,  $64,  $65,  $66,     afEnd,     afEnd, afEnd
		even
TlsAni_Wait:	dc.b   7,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  3,  2,  1,  1,  1
		dc.b   1,  1,  1,  1,  1,  3,  2,  1,  1,  1,  1,  1,  1,  1,  1,  1
		dc.b   5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5
		dc.b   6,  7,  8,  7,  8,  7,  8,  7,  8,  7,  8,  6,afBack,$1C
		even
TlsAni_Balance:	dc.b   9,$69,$69,$6A,$6A,$69,$69,$6A,$6A,$69,$69,$6A,$6A,$69,$69,$6A
		dc.b $6A,$69,$69,$6A,$6A,$69,$6A,afEnd
		even
TlsAni_LookUp:	dc.b $3F, $4, afEnd
		even
TlsAni_Duck:	dc.b $3F, $5B, afEnd
		even
TlsAni_Warp1:	dc.b $3F, $00, afEnd
		even
TlsAni_Warp2:	dc.b $3F, $00, afEnd
		even
TlsAni_Warp3:	dc.b $3F, $00, afEnd
		even
TlsAni_Warp4:	dc.b $3F, $00, afEnd
		even
TlsAni_Stop:	dc.b 7,	$67, $68, afEnd
		even
TlsAni_Float1:	dc.b 7,	$6E, $73, afEnd
		even
TlsAni_Float2:	dc.b 7,	$6E, $6F, $70, $71, $72, afEnd
		even
TlsAni_Spring:	dc.b 3,$59,$5A,$59,$5A,$59,$5A,$59,$5A,$59,$5A,$59,$5A, afChange, id_Walk
		even
TlsAni_Hang:	dc.b 4,	$6C, $6D, afEnd
		even
TlsAni_Leap1:	dc.b $F, $00, $00,	afBack, 1
		even
TlsAni_Leap2:	dc.b $F, $00, $00, afBack, 1
		even
TlsAni_Surf:	dc.b $3F, $00, afEnd
		even
TlsAni_GetAir:	dc.b $B, $74, $74, $12, $13, afChange, id_Walk
		even
TlsAni_Burnt:	dc.b $20, $5D, afEnd
		even
TlsAni_Drown:	dc.b $2F, $5D, afEnd
		even
TlsAni_Death:	dc.b 3,	$5D, afEnd
		even
TlsAni_Shrink:	dc.b 3,	$00, fr_Null, afBack, 1
		even
TlsAni_Hurt:	dc.b 3,	$5C, afEnd
		even
TlsAni_WaterSlide:
		dc.b 7, $5C, $6B, afEnd
		even
TlsAni_Null:	dc.b $77, fr_Null, afChange, id_Walk
		even
TlsAni_Float3:	dc.b 3,	$6E, $6F, $70, $71, $72, $73, afEnd
		even
TlsAni_Float4:	dc.b 3,	$6E, afChange, id_Walk
		even
TlsAni_SpinDash: dc.b 0, $60, $61, $62, afEnd
		 even
TlsAni_RunFast	dc.b $FF,$3E,$3F,afEnd
		dc.b afEnd,afEnd,afEnd,afEnd,afEnd,afEnd
TlsAni_Fly: dc.b 1, $5E, $5F, afEnd,afEnd,afEnd, afEnd
		 even
TlsAni_Transform:	dc.b    2, $8B, $8B, $8C, $8D, $8C, $8D, $8C, $8D, $8C, $8D, $8C, $8D, afChange,   id_Walk
		even
TlsAni_Glide: dc.b 0, $5E, $5F, afEnd
		 even
TlsAni_FallFromGlide: dc.b 0, $59, $59, afBack,1
		 even
TlsAni_HangFromTails:
		dc.b $13,$85,$86,$FF
		even
TlsAni_LandFromGlide:dc.b  $F,$5B,afChange,  id_Walk
	even
TlsAni_Carry: dc.b 1, $90, afEnd, afEnd, afEnd,afEnd, afEnd
		 even
TlsAni_CarryUp: dc.b 1, $91, afEnd, afEnd,afEnd,afEnd,afEnd, afEnd
		 even
TlsAni_FlyTired: dc.b $B, $92, $93, afEnd, afEnd, afEnd, afEnd
		 even
TlsAni_CarryTired: dc.b $B, $94, $95, afEnd, afEnd, afEnd, afEnd
		 even
TlsAni_Swim: dc.b 7, $96, $97, $98, $99, $9A, afEnd
		 even
TlsAni_SwimUp: dc.b 3, $96, $97, $98, $99, $9A, afEnd
		 even
TlsAni_SwimCarry: dc.b 4, $9B, $9C, afEnd, afEnd, afEnd, afEnd
		 even
TlsAni_SwimTired: dc.b $B, $9D, $9E, $9F, afEnd, afEnd, afEnd
		 even

id2_Walk:	equ (ptr_Walk-Ani_Tails)/2	; 0
id2_Run:	equ (ptr_Run-Ani_Tails)/2	; 1
id2_Roll:	equ (ptr_Roll-Ani_Tails)/2	; 2
id2_Roll2:	equ (ptr_Roll2-Ani_Tails)/2	; 3
id2_Push:	equ (ptr_Push-Ani_Tails)/2	; 4
id2_Wait:	equ (ptr_Wait-Ani_Tails)/2	; 5
id2_Balance:	equ (ptr_Balance-Ani_Tails)/2	; 6
id2_LookUp:	equ (ptr_LookUp-Ani_Tails)/2	; 7
id2_Duck:	equ (ptr_Duck-Ani_Tails)/2	; 8
id2_Warp1:	equ (ptr_Warp1-Ani_Tails)/2	; 9
id2_Warp2:	equ (ptr_Warp2-Ani_Tails)/2	; $A
id2_Warp3:	equ (ptr_Warp3-Ani_Tails)/2	; $B
id2_Warp4:	equ (ptr_Warp4-Ani_Tails)/2	; $C
id2_Stop:	equ (ptr_Stop-Ani_Tails)/2	; $D
id2_Float1:	equ (ptr_Float1-Ani_Tails)/2	; $E
id2_Float2:	equ (ptr_Float2-Ani_Tails)/2	; $F
id2_Spring:	equ (ptr_Spring-Ani_Tails)/2	; $10
id2_Hang:	equ (ptr_Hang-Ani_Tails)/2	; $11
id2_Leap1:	equ (ptr_Leap1-Ani_Tails)/2	; $12
id2_Leap2:	equ (ptr_Leap2-Ani_Tails)/2	; $13
id2_Surf:	equ (ptr_Surf-Ani_Tails)/2	; $14
id2_GetAir:	equ (ptr_GetAir-Ani_Tails)/2	; $15
id2_Burnt:	equ (ptr_Burnt-Ani_Tails)/2	; $16
id2_Drown:	equ (ptr_Drown-Ani_Tails)/2	; $17
id2_Death:	equ (ptr_Death-Ani_Tails)/2	; $18
id2_Shrink:	equ (ptr_Shrink-Ani_Tails)/2	; $19
id2_Hurt:	equ (ptr_Hurt-Ani_Tails)/2	; $1A
id2_WaterSlide:	equ (ptr_WaterSlide-Ani_Tails)/2 ; $1B
id2_Null:	equ (ptr_Null-Ani_Tails)/2	; $1C
id2_Float3:	equ (ptr_Float3-Ani_Tails)/2	; $1D
id2_Float4:	equ (ptr_Float4-Ani_Tails)/2	; $1E
id2_SpinDash:	equ (ptr_SpinDash-Ani_Tails)/2	; $1F
id2_RunFast:	equ (ptr_Fly-Ani_Tails)/2	; $20
id2_Fly:	equ (ptr_Fly-Ani_Tails)/2	; $21
id2_Transform:	equ (ptr_Transform-Ani_Tails)/2	; $22
id2_Glide:	equ (ptr_Glide-Ani_Tails)/2	; $23
id2_FallFromGlide:	equ (ptr_FallFromGlide-Ani_Tails)/2	; $24
id2_HangFromTails:	equ (ptr_HangFromTails-Ani_Tails)/2	; $25
id2_LandFromGlide:	equ (ptr_LandFromGlide-Ani_Tails)/2	; $26
id2_Carry:	equ (ptr_Carry-Ani_Tails)/2	; $27
id2_CarryUp:	equ (ptr_CarryUp-Ani_Tails)/2	; $28
id2_FlyTired:	equ (ptr_FlyTired-Ani_Tails)/2	; $29
id2_CarryTired:	equ (ptr_CarryTired-Ani_Tails)/2	; $2A
id2_Swim:	equ (ptr_Swim-Ani_Tails)/2	; $2B
id2_SwimUp:	equ (ptr_SwimUp-Ani_Tails)/2	; $2B
id2_SwimCarry:	equ (ptr_SwimCarry-Ani_Tails)/2	; $2C
id2_SwimTired:	equ (ptr_SwimTired-Ani_Tails)/2	; $2D