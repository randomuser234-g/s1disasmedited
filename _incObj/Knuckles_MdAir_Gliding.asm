Knuckles_MdAir_Gliding:
	bsr.w	Knuckles_GlideSpeedControl
	bsr.w	Knuckles_LevelBound
	jsr	(SpeedToPos).l
	bsr.w	Knuckles_GlideControl

return_3156B8:
	rts


; =============== S U B	R O U T	I N E =======================================


Knuckles_GlideControl:
	move.b	(f_doublejump).w,d0
	beq.s	return_3156B8
	cmpi.b	#2,d0
	beq.w	Knuckles_FallingFromGlide
	cmpi.b	#3,d0
	beq.w	Knuckles_Sliding
	cmpi.b	#4,d0
	beq.w	Knuckles_Climbing_Wall
	cmpi.b	#5,d0
	beq.w	Knuckles_Climbing_Onto_Ledge

;Knuckles_NormalGlide:
	; These two lines are not here in S3K.
	move.b	#10,obHeight(a0)
	move.b	#10,obWidth(a0)

	; This function updates 'Gliding_collision_flags'.
	bsr.w	Knuckles_DoLevelCollision2

	btst	#5,(Gliding_collision_flags).w
	bne.w	Knuckles_BeginClimb

	; These two lines are not here in S3K.
	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)

	btst	#1,(Gliding_collision_flags).w
	beq.s	Knuckles_BeginSlide

	move.b	(v_jpadhold2).w,d0
	andi.b	#btnA|btnB|btnC,d0
	bne.s	.continueGliding

	; The player has let go of the jump button, so exit the gliding state
	; and enter the falling state.
	move.b	#2,(f_doublejump).w
	move.b	#id_Glide,obAnim(a0)
	bclr	#0,obStatus(a0)
	tst.w	obVelX(a0)
	bpl.s	+
	bset	#0,obStatus(a0)
+
	; Divide Knuckles' X velocity by 4.
	asr.w	obVelX(a0)
	asr.w	obVelX(a0)

	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)

	rts
; ---------------------------------------------------------------------------

.continueGliding:
	bra.w	Knuckles_DoGlidingobAnimation
; ---------------------------------------------------------------------------

Knuckles_BeginSlide:
	bclr	#0,obStatus(a0)
	tst.w	obVelX(a0)
	bpl.s	+
	bset	#0,obStatus(a0)
+
	move.b	obAngle(a0),d0
	addi.b	#$20,d0
	andi.b	#$C0,d0
	beq.s	loc_315780

	move.w	obInertia(a0),obVelX(a0)
	move.w	#0,obVelY(a0)

	bra.w	Sonic_ResetOnFloor_Part2
; ---------------------------------------------------------------------------

loc_315780:
	move.b	#3,(f_doublejump).w
	move.b	#$CC,obFrame(a0)
	move.b	#$7F,obTimeFrame(a0)
	move.b	#0,obAniFrame(a0)

	; The drowning countdown uses the dust clouds' VRAM, so don't create
	; dust if Knuckles is drowning.
	cmpi.b	#12,(v_air).w
	blo.s	+
	; Create dust clouds.
	;move.b	#6,(Sonic_Dust+obRoutine).w
	;move.b	#$15,(Sonic_Dust+obFrame).w
	nop
+
	rts
; ---------------------------------------------------------------------------

Knuckles_BeginClimb:
	tst.b	(Disable_wall_grab).w
	bmi.w	.fail

	move.b	lrb_solid_bit(a0),d5
	move.b	double_jump_property(a0),d0
	addi.b	#$40,d0
	bpl.s	.right

;.left:
	bset	#0,obStatus(a0)

	bsr.w	CheckLeftCeilingDist
	or.w	d0,d1
	bne.s	.checkFloorLeft

	addq.w	#1,obX(a0)
	bra.s	.success

.right:
	bclr	#0,obStatus(a0)

	bsr.w	CheckRightCeilingDist
	or.w	d0,d1
	bne.w	.checkFloorRight
; loc_3157E8:
.success:
	; These two lines aren't here in S3K.
	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)

	; This sound does not exist in Sonic 2, so the code to play it was
	; removed.
	;moveq	#signextendB(sfx_Grab),d0

	; If Hyper Knuckles glides into a wall at a high-enough
	; speed, then make the screen shake and harm all enemies
	; on-screen.
	; This code is leftover and useless in KiS2.
	tst.b	(v_super).w
	beq.s	.noQuake

	cmpi.w	#$480,obInertia(a0)
	blo.s	.noQuake

	nop
	; This is the code that replaced the above 'nop' in S3K.
	;move.w	#$14,(Glide_screen_shake).w
	;bsr.w	HyperAttackTouchResponse
	;moveq	#signextendB(sfx_Thump),d0

.noQuake:
	;jsr	(PlaySound).l
	move.w	#0,obInertia(a0)
	move.w	#0,obVelX(a0)
	move.w	#0,obVelY(a0)
	move.b	#4,(f_doublejump).w
	move.b	#$B7,obFrame(a0)
	move.b	#$7F,obTimeFrame(a0)
	move.b	#0,obAniFrame(a0)
	move.b	#3,double_jump_property(a0)
	; 'obScreenY' holds the X coordinate that Knuckles was at when he first
	; latched onto the wall.
	move.w	obX(a0),obScreenY(a0)
	rts
; ---------------------------------------------------------------------------

.checkFloorLeft:
	; This adds the Y radius to the X coordinate...
	; This appears to be a bug, but, luckily, the X and Y radius are both
	; 10, so this is harmless.
	move.w	obX(a0),d3
	move.b	obHeight(a0),d0
	ext.w	d0
	sub.w	d0,d3
	subq.w	#1,d3
; loc_31584A:
.checkFloorCommon:
	move.w	obY(a0),d2
	subi.w	#11,d2
	jsr	ChkFloorEdge_Part3

	tst.w	d1
	bmi.s	.fail
	cmpi.w	#12,d1
	bhs.s	.fail
	add.w	d1,obY(a0)
	bra.w	.success
; ---------------------------------------------------------------------------
; loc_31586A:
.checkFloorRight:
	; This adds the Y radius to the X coordinate...
	; This appears to be a bug, but, luckily, the X and Y radius are both
	; 10, so this is harmless.
	move.w	obX(a0),d3
	move.b	obHeight(a0),d0
	ext.w	d0
	add.w	d0,d3
	addq.w	#1,d3
	bra.s	.checkFloorCommon
; ---------------------------------------------------------------------------
; loc_31587A:
.fail:
	move.b	#2,(f_doublejump).w
	move.b	#AniIDKnuxAni_FallAfterGlide,obAnim(a0)
	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)
	bset	#1,(Gliding_collision_flags).w
	rts
; ---------------------------------------------------------------------------

Knuckles_FallingFromGlide:
	bsr.w	Knuckles_JumpDirection

	; Apply gravity.
	addi.w	#$38,obVelY(a0)

	; Fall slower when underwater.
	btst	#obStatus.player.underwater,obStatus(a0)
	beq.s	+
	subi.w	#$28,obVelY(a0)
+
	; This function updates 'Gliding_collision_flags'.
	bsr.w	Knuckles_DoLevelCollision2

	btst	#1,(Gliding_collision_flags).w
	bne.s	.return

	; Knuckles has touched the ground.
	move.w	#0,obInertia(a0)
	move.w	#0,obVelX(a0)
	move.w	#0,obVelY(a0)

	move.b	obHeight(a0),d0
	subi.b	#19,d0
	ext.w	d0
	add.w	d0,obY(a0)

	; This sound does not exist in Sonic 2, so the code to play it was
	; removed.
	;moveq	#signextendB(sfx_GlideLand),d0
	;jsr	(PlaySound).l

	move.b	obAngle(a0),d0
	addi.b	#$20,d0
	andi.b	#$C0,d0
	beq.s	+
	bra.w	Sonic_ResetOnFloor_Part2
+
	bsr.w	Sonic_ResetOnFloor_Part2
	move.w	#$F,locktime(a0)
	move.b	#AniIDKnuxAni_LandAfterGlide,obAnim(a0)
; return_315900:
.return:
	rts
; ---------------------------------------------------------------------------

Knuckles_Sliding:
	move.b	(v_jpadhold2).w,d0
	andi.b	#btnA|btnB|btnC,d0
	beq.s	.getUp

	tst.w	obVelX(a0)
	bpl.s	.goingRight

;.goingLeft:
	addi.w	#$20,obVelX(a0)
	bmi.s	.continueSliding2

	bra.s	.getUp
; ---------------------------------------------------------------------------
; loc_31591C:
.continueSliding2:
	bra.s	.continueSliding
; ---------------------------------------------------------------------------
; loc_31591E:
.goingRight:
	subi.w	#$20,obVelX(a0)
	bpl.s	.continueSliding
; loc_315926:
.getUp:
	move.w	#0,obInertia(a0)
	move.w	#0,obVelX(a0)
	move.w	#0,obVelY(a0)

	move.b	obHeight(a0),d0
	subi.b	#19,d0
	ext.w	d0
	add.w	d0,obY(a0)

	bsr.w	Sonic_ResetOnFloor_Part2

	move.w	#$F,locktime(a0)
	move.b	#AniIDKnuxAni_ClimbLedge,obAnim(a0)

	rts
; ---------------------------------------------------------------------------
; loc_315958:
.continueSliding:
	; These two lines aren't here in S3K.
	move.b	#10,obHeight(a0)
	move.b	#10,obWidth(a0)

	bsr.w	Knuckles_DoLevelCollision2

	; Get distance from floor in 'd1', and obAngle of floor in 'd3'.
	bsr.w	Sonic_CheckFloor

	; If the distance from the floor is suddenly really high, then
	; Knuckles must have slid off a ledge, so make him enter his falling
	; state.
	cmpi.w	#14,d1
	bge.s	.fall

	add.w	d1,obY(a0)
	move.b	d3,obAngle(a0)

	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)

	; This sound does not exist in Sonic 2, so the code to play it was
	; removed.
	; Play the sliding sound every 8 frames.
;	move.b	(Vint_runcount+3).w,d0
;	andi.b	#7,d0
;	bne.s	+

;	moveq	#signextendB(sfx_GroundSlide),d0
;	jsr	(PlaySound).l
;+
	rts
; ---------------------------------------------------------------------------
; loc_315988:
.fall:
	move.b	#2,(f_doublejump).w
	move.b	#AniIDKnuxAni_FallAfterGlide,obAnim(a0)

	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)

	bset	#1,(Gliding_collision_flags).w
	rts
; ---------------------------------------------------------------------------

Knuckles_Climbing_Wall:
	tst.b	(Disable_wall_grab).w
	bmi.w	Knuckles_LetGoOfWall

	; If Knuckles' X coordinate is no longer the same as when he first
	; latched onto the wall, then detach him from the wall. This is
	; probably intended to detach Knuckles from the wall if something
	; physically pushes him away from it.
	move.w	obX(a0),d0
	cmp.w	obScreenY(a0),d0
	bne.w	Knuckles_LetGoOfWall

	; If an object is now carrying Knuckles, then detach him from the
	; wall.
	btst	#obStatus.player.on_object,obStatus(a0)
	bne.w	Knuckles_LetGoOfWall

	move.w	#0,obInertia(a0)
	move.w	#0,obVelX(a0)
	move.w	#0,obVelY(a0)

	move.l	#Primary_Collision,(Collision_addr).w
	cmpi.b	#$D,lrb_solid_bit(a0)
	beq.s	+
	move.l	#Secondary_Collision,(Collision_addr).w
+
	move.b	lrb_solid_bit(a0),d5

	; These two lines aren't in S3K.
	move.b	#10,obHeight(a0)
	move.b	#10,obWidth(a0)

	moveq	#0,d1	; Climbing obAnimation delta: make the obAnimation pause.

	btst	#button_up,(v_jpadhold2).w
	beq.w	.notClimbingUp

;.climbingUp:
	; Get Knuckles' distance from the wall in 'd1'.
	move.w	obY(a0),d2
	subi.w	#11,d2
	bsr.w	GetDistanceFromWall

	; If the wall is far away from Knuckles, then we must have reached a
	; ledge, so make Knuckles climb up onto it.
	cmpi.w	#4,d1
	bge.w	Knuckles_ClimbUp

	; If Knuckles has encountered a small dip in the wall, then make him
	; stop.
	tst.w	d1
	bne.w	.notMoving

	; Get Knuckles' distance from the ceiling in 'd1'.
	move.b	lrb_solid_bit(a0),d5
	move.w	obY(a0),d2
	subq.w	#8,d2
	move.w	obX(a0),d3
	bsr.w	CheckCeilingDist_WithRadius

	; Check if Knuckles has room above him.
	tst.w	d1
	bpl.s	.moveUp

	; Knuckles is bumping into the ceiling, so push him out.
	sub.w	d1,obY(a0)

	moveq	#1,d1	; Climbing obAnimation delta: make the obAnimation play forwards.
	bra.w	.finishMoving
; ---------------------------------------------------------------------------
; loc_315A46:
.moveUp:
	subq.w	#1,obY(a0)

	; Super Knuckles and Hyper Knuckles climb walls faster.
	tst.b	(v_super).w
	beq.s	+
	subq.w	#1,obY(a0)
+
	moveq	#1,d1	; Climbing obAnimation delta: make the obAnimation play forwards.

	; Don't let Knuckles climb through the level's upper boundary.
	move.w	(Camera_Min_obY).w,d0

	; If the level wraps vertically, then don't bother with any of this.
	cmpi.w	#-$100,d0
	beq.w	.finishMoving

	; Check if Knuckles is over the level's top boundary.
	addi.w	#16,d0
	cmp.w	obY(a0),d0
	ble.w	.finishMoving

	; Knuckles is climbing over the level's top boundary: push him back
	; down.
	move.w	d0,obY(a0)
	bra.w	.finishMoving
; ---------------------------------------------------------------------------
; loc_315A76:
.notClimbingUp:
	btst	#button_down,(v_jpadhold2).w
	beq.w	.finishMoving

;.climbingDown:
	; ...I'm not sure what this code is for.
	cmpi.b	#$BD,obFrame(a0)
	bne.s	+
	move.b	#$B7,obFrame(a0)
	addq.w	#3,obY(a0)
	subq.w	#3,obX(a0)
	btst	#0,obStatus(a0)
	beq.s	+
	addq.w	#3*2,obX(a0)
+
	; Get Knuckles' distance from the wall in 'd1'.
	move.w	obY(a0),d2
	addi.w	#11,d2
	bsr.w	GetDistanceFromWall

	; If Knuckles is no longer against the wall (he has climbed off the
	; bottom of it) then make him let go.
	tst.w	d1
	bne.w	Knuckles_LetGoOfWall

	; Get Knuckles' distance from the floor in 'd1'.
	move.b	top_solid_bit(a0),d5
	move.w	obY(a0),d2
	addi.w	#9,d2
	move.w	obX(a0),d3
	bsr.w	CheckFloorDist_WithRadius

	; Check if Knuckles has room below him.
	tst.w	d1
	bpl.s	.moveDown

	; Knuckles has reached the floor.
	add.w	d1,obY(a0)
	move.b	(Primary_obAngle).w,obAngle(a0)

	move.w	#0,obInertia(a0)
	move.w	#0,obVelX(a0)
	move.w	#0,obVelY(a0)

	bsr.w	Sonic_ResetOnFloor_Part2

	move.b	#id_Wait,obAnim(a0)

	rts
; ---------------------------------------------------------------------------
; loc_315AF4:
.moveDown:
	addq.w	#1,obY(a0)

	; Super Knuckles and Hyper Knuckles climb walls faster.
	tst.b	(v_super).w
	beq.s	+
	addq.w	#1,obY(a0)
+
	moveq	#-1,d1	; Climbing obAnimation delta: make the obAnimation play backwards.

; loc_315B04:
.finishMoving:
	; This block of code is in S3K, but not KiS2:
    if 0
	; This code detaches Knuckles from the wall if there is ground
	; directly below him. Note that this code specifically does not run
	; if the player is holding up or down: this is because similar code
	; already runs if either of those buttons are being held. Presumably,
	; this check was added so that Knuckles would properly detach from
	; the wall if a rising floor (think Marble Garden Zone Act 2) came up
	; from under him. With that said, KiS2 lacks this logic, and yet
	; Knuckles seems to detach from the wall in Hill Top Zone's rising
	; wall section just fine, so I'm not sure whether this code was ever
	; actually needed in the first place.
	move.b	(v_jpadhold2).w,d0
	andi.b	#button_up_mask|button_down_mask,d0
	bne.s	.isMovingUpOrDown

	; Get Knuckles' distance from the floor in 'd1'.
	move.b	top_solid_bit(a0),d5
	move.w	obY(a0),d2
	addi.w	#9,d2
	move.w	obX(a0),d3
	bsr.w	CheckFloorDist_WithRadius

	; Check if Knuckles has room below him.
	tst.w	d1
	bmi.w	.reachedFloor

	; Bug! 'd1' has been overwritten by 'CheckFloorDist_WithRadius', but
	; the code after this needs it for updating Knuckles' obAnimation. This
	; bug is the reason why Knuckles resets to his first climbing frame
	; when the player is not holding up or down.
    endif

.isMovingUpOrDown:
	; If Knuckles has not moved, skip this.
	tst.w	d1
	beq.s	.notMoving

	; Only obAnimate every 4 frames.
	subq.b	#1,double_jump_property(a0)
	bpl.s	.notMoving
	move.b	#3,double_jump_property(a0)

	; Add delta to obAnimation frame.
	add.b	obFrame(a0),d1

	; Make the obAnimation loop.
	cmpi.b	#$B7,d1
	bhs.s	+
	move.b	#$BC,d1
+
	cmpi.b	#$BC,d1
	bls.s	+
	move.b	#$B7,d1
+
	; Apply the frame.
	move.b	d1,obFrame(a0)
; loc_315B30:
.notMoving:
	move.b	#$20,obTimeFrame(a0)
	move.b	#0,obAniFrame(a0)

	; These two lines aren't in S3K.
	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)

	move.w	(v_jpadhold2).w,d0
	andi.w	#btnA|btnB|btnC,d0
	beq.s	.hasNotJumped

	; Knuckles has jumped off the wall.
	move.w	#-$380,obVelY(a0)
	move.w	#$400,obVelX(a0)

	bchg	#0,obStatus(a0)
	bne.s	+
	neg.w	obVelX(a0)
+
	bset	#1,obStatus(a0)
	move.b	#1,jumping(a0)

	move.b	#14,obHeight(a0)
	move.b	#7,obWidth(a0)

	move.b	#AniIDSonAni_Roll,obAnim(a0)
	bset	#obStatus.player.rolling,obStatus(a0)
	move.b	#0,(f_doublejump).w
; return_315B94:
.hasNotJumped:
	rts
; ---------------------------------------------------------------------------

Knuckles_ClimbUp:
	move.b	#5,(f_doublejump).w		  ; Climb up to	the floor above	you

	cmpi.b	#$BD,obFrame(a0)
	beq.s	+

	move.b	#0,double_jump_property(a0)
	bsr.s	Knuckles_DoLedgeClimbingobAnimation
+
	rts
; ---------------------------------------------------------------------------
; loc_315BAE:
Knuckles_LetGoOfWall:
	move.b	#2,(f_doublejump).w

	move.w	#(AniIDKnuxAni_FallAfterGlide<<8)|AniIDKnuxAni_FallAfterGlide,obAnim(a0)
	move.b	#$CB,obFrame(a0)
	move.b	#7,obTimeFrame(a0)
	move.b	#1,obAniFrame(a0)

	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)

	rts
; End of function Knuckles_GlideControl


; =============== S U B	R O U T	I N E =======================================

; sub_315BDA:
Knuckles_DoLedgeClimbingobAnimation:
	moveq	#0,d0
	move.b	double_jump_property(a0),d0
	lea	.frames(pc,d0.w),a1

	move.b	(a1)+,obFrame(a0)

	move.b	(a1)+,d0
	ext.w	d0
	btst	#0,obStatus(a0)
	beq.s	+
	neg.w	d0
+
	add.w	d0,obX(a0)

	move.b	(a1)+,d1
	ext.w	d1
	add.w	d1,obY(a0)

	move.b	(a1)+,obTimeFrame(a0)

	addq.b	#4,double_jump_property(a0)
	move.b	#0,obAniFrame(a0)
	rts
; End of function Knuckles_DoLedgeClimbingobAnimation

; ---------------------------------------------------------------------------
; Strangely, the last frame uses frame $D2. It will never be seen, however,
; because it is immediately overwritten by Knuckles' waiting obAnimation.

; word_315C12:
.frames:
	; obFrame, obX, obY, obAniFrame_timer
	dc.b $BD,   3,  -3,   6
	dc.b $BE,   8, -10,   6
	dc.b $BF,  -8, -12,   6
	dc.b $D2,   8,  -5,   6
.framesEnd:

; =============== S U B	R O U T	I N E =======================================

; sub_315C22:
GetDistanceFromWall:
	move.b	lrb_solid_bit(a0),d5
	btst	#0,obStatus(a0)
	bne.s	.facingLeft

;.facingRight:
	move.w	obX(a0),d3
	bra.w	CheckRightWallDist_WithRadius
; ---------------------------------------------------------------------------
; loc_315C36:
.facingLeft:
	move.w	obX(a0),d3
	subq.w	#1,d3
	bra.w	CheckLeftWallDist_WithRadius
; End of function GetDistanceFromWall

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Knuckles_GlideControl
; Knuckles_Climbing_Up:
Knuckles_Climbing_Onto_Ledge:
	tst.b	obTimeFrame(a0)
	bne.s	return_315C7A

	bsr.w	Knuckles_DoLedgeClimbingobAnimation

	; Have we reached the end of the ledge-climbing obAnimation?
	cmpi.b	#Knuckles_DoLedgeClimbingobAnimation.framesEnd-Knuckles_DoLedgeClimbingobAnimation.frames,double_jump_property(a0)
	bne.s	return_315C7A

	; Yes.
	move.w	#0,obInertia(a0)
	move.w	#0,obVelX(a0)
	move.w	#0,obVelY(a0)

	btst	#0,obStatus(a0)
	beq.s	+
	subq.w	#1,obX(a0)
+
	bsr.w	Sonic_ResetOnFloor_Part2
	move.b	#id_Wait,obAnim(a0)

return_315C7A:
	rts
; END OF FUNCTION CHUNK	FOR Knuckles_GlideControl

; =============== S U B	R O U T	I N E =======================================

; sub_315C7C:
Knuckles_DoGlidingobAnimation:
	move.b	#$20,obTimeFrame(a0)
	move.b	#0,obAniFrame(a0)
	move.w	#(AniIDKnuxAni_Glide<<8)|AniIDKnuxAni_Glide,obAnim(a0)
	bclr	#5,obStatus(a0)
	bclr	#0,obStatus(a0)

	; Update Knuckles' frame, depending on where he's facing.
	moveq	#0,d0
	move.b	double_jump_property(a0),d0
	addi.b	#$10,d0
	lsr.w	#5,d0
	move.b	.frames(pc,d0.w),d1
	move.b	d1,obFrame(a0)
	cmpi.b	#$C4,d1
	bne.s	+
	bset	#0,obStatus(a0)
	move.b	#$C0,obFrame(a0)
+
	rts
; End of function Knuckles_DoGlidingobAnimation

; ---------------------------------------------------------------------------
; byte_315CC2:
.frames:	dc.b $C0, $C1, $C2, $C3, $C4, $C3, $C2, $C1

; =============== S U B	R O U T	I N E =======================================


Knuckles_GlideSpeedControl:
	cmpi.b	#1,(f_doublejump).w
	bne.w	.doNotKillspeed

	move.w	obInertia(a0),d0
	cmpi.w	#$400,d0
	bhs.s	.mediumSpeed

;.lowSpeed:
	; Increase Knuckles' speed.
	addq.w	#8,d0
	bra.s	.applySpeed
; ---------------------------------------------------------------------------
; loc_315CE2:
.mediumSpeed:
	; If Knuckles is at his speed limit, then don't increase his speed.
	cmpi.w	#$1800,d0
	bhs.s	.applySpeed

	; If Knuckles is turning, then don't increase his speed either.
	move.b	double_jump_property(a0),d1
	andi.b	#$7F,d1
	bne.s	.applySpeed

	; Increase Knuckles' speed.
	addq.w	#4,d0

	; Super Knuckles and Hyper Knuckles glide faster.
	tst.b	(v_super).w
	beq.s	.applySpeed
	addq.w	#8,d0
; loc_315CFC:
.applySpeed:
	move.w	d0,obInertia(a0)

	move.b	double_jump_property(a0),d0
	btst	#bitL,(v_jpadhold2).w
	beq.s	.notHoldingLeft

;.holdingLeft:
	; Playing is holding left.
	cmpi.b	#$80,d0
	beq.s	.notHoldingLeft
	tst.b	d0
	bpl.s	+
	neg.b	d0
+
	addq.b	#2,d0
	bra.s	.setNewTurningValue
; ---------------------------------------------------------------------------
; loc_315D1C:
.notHoldingLeft:
	btst	#bitR,(v_jpadhold2).w
	beq.s	.notHoldingRight

;.holdingRight:
	; Playing is holding right.
	tst.b	d0
	beq.s	.notHoldingRight
	bmi.s	+
	neg.b	d0
+
	addq.b	#2,d0
	bra.s	.setNewTurningValue
; ---------------------------------------------------------------------------
; loc_315D30:
.notHoldingRight:
	move.b	d0,d1
	andi.b	#$7F,d1
	beq.s	.setNewTurningValue
	addq.b	#2,d0
; loc_315D3A:
.setNewTurningValue:
	move.b	d0,double_jump_property(a0)

	move.b	double_jump_property(a0),d0
	jsr	CalcSine
	muls.w	obInertia(a0),d1
	asr.l	#8,d1
	move.w	d1,obVelX(a0)

	; Is Knuckles is falling at a high speed, then create a parachute
	; effect, where gliding makes Knuckles fall slower.
	cmpi.w	#$80,obVelY(a0)
	blt.s	.fallingSlow
	subi.w	#$20,obVelY(a0)
	bra.s	.fallingFast
; ---------------------------------------------------------------------------
; loc_315D62:
.fallingSlow:
	; Apply gravity.
	addi.w	#$20,obVelY(a0)
; loc_315D68:
.fallingFast:
	; If Knuckles is above the level's top boundary, then kill his
	; horizontal speed.
	move.w	(Camera_Min_obY).w,d0
	cmpi.w	#-$100,d0
	beq.w	.doNotKillspeed

	addi.w	#$10,d0
	cmp.w	obY(a0),d0
	ble.w	.doNotKillspeed

	asr.w	obVelX(a0)
	asr.w	obInertia(a0)
; loc_315D88:
.doNotKillspeed:
	cmpi.w	#$60,(Camera_obY_bias).w
	beq.s	.doNotModifyBias
	bhs.s	+
	addq.w	#2*2,(Camera_obY_bias).w
+
	subq.w	#2,(Camera_obY_bias).w
; return_315D9A:
.doNotModifyBias:
	rts
; End of function Knuckles_GlideSpeedControl
