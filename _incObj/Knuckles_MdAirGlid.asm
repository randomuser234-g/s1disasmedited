Obj01_MdAir_Gliding:
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
	;bra.s	Knuckles_NormalGlide
	cmpi.b	#3,d0
	beq.w	Knuckles_Sliding
	cmpi.b	#4,d0
	beq.w	Knuckles_Climbing_Wall
	cmpi.b	#5,d0
	beq.w	Knuckles_Climbing_Onto_Ledge

Knuckles_NormalGlide:
	; These two lines are not here in S3K.
	move.b	#10,obHeight(a0)
	move.b	#10,obWidth(a0)

	; This function updates 'Gliding_collision_flags'.
	bsr.w	Knuckles_Floor2

	btst	#5,(v_glidecolflags).w	;(Gliding_collision_flags).w
	bne.w	Knuckles_BeginClimb

	; These two lines are not here in S3K.
	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)

	btst	#1,(v_glidecolflags).w	;(Gliding_collision_flags).w
	beq.s	Knuckles_BeginSlide

	move.b	(v_jpadhold2).w,d0
	andi.b	#btnA|btnB|btnC,d0
	bne.s	.continueGliding

	; The player has let go of the jump button, so exit the gliding state
	; and enter the falling state.
	move.b	#2,(f_doublejump).w
	move.b	#id_FallFromGlide,obAnim(a0)
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
	bra.w	Knuckles_DoGlidingAnimation
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

	jmp	Knuckles_ResetOnFloor	;Sonic_ResetOnFloor_Part2
; ---------------------------------------------------------------------------

loc_315780:
	move.b	#3,(f_doublejump).w
	move.b	#$CC,obFrame(a0)
	move.b	#$7F,obTimeFrame(a0)
	move.b	#0,obAniFrame(a0)

	; The drowning countdown uses the dust clouds' VRAM, so don't create
	; dust if Knuckles is drowning.
	;cmpi.b	#12,(v_air).w
	;blo.s	+
	; Create dust clouds.
	;move.b	#6,(Sonic_Dust+routine).w
	;move.b	#$15,(Sonic_Dust+mapping_frame).w
+
	rts
; ---------------------------------------------------------------------------

Knuckles_BeginClimb:
	;tst.b	(Disable_wall_grab).w
	;bmi.w	.fail

	move.b	obSolid(a0),d5		;lrb_solid_bit
	move.b	(v_doublejumpprop).w,d0
	addi.b	#$40,d0
	bpl.s	.right

;.left:
	bset	#0,obStatus(a0)

	jsr	loc_14FD6		;CheckLeftCeilingDist
	or.w	d0,d1
	bne.s	.checkFloorLeft

	;addq.w	#1,obX(a0)		;no idea why this is here, removing it seems to make left facing walls work more reliably
	bra.s	.success

.right:
	bclr	#0,obStatus(a0)

	jsr	sub_14E50		;CheckRightCeilingDist
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
	move.b	#3,(v_doublejumpprop).w
	; 'x_sub' holds the X coordinate that Knuckles was at when he first
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
	jsr	ObjFloorDist3

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
	move.b	#id_FallFromGlide,obAnim(a0)
	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)
	bset	#1,(v_glidecolflags).w	;(Gliding_collision_flags).w
	rts
; ---------------------------------------------------------------------------

Knuckles_FallingFromGlide:
	bsr.w	Knuckles_JumpDirection

	; Apply gravity.
	addi.w	#$38,obVelY(a0)

	; Fall slower when underwater.
	btst	#6,obStatus(a0)
	beq.s	+
	subi.w	#$28,obVelY(a0)
+
	; This function updates 'Gliding_collision_flags'.
	bsr.w	Knuckles_Floor2

	btst	#1,(v_glidecolflags).w	;(Gliding_collision_flags).w
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
	jmp	Knuckles_ResetOnFloor	;Sonic_ResetOnFloor_Part2
+
	jsr	Knuckles_ResetOnFloor	;Sonic_ResetOnFloor_Part2
	move.w	#$F,locktime(a0)
	move.b	#id_LandFromGlide,obAnim(a0)		;#AniIDKnuxAni_LandAfterGlide
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

	jsr	Knuckles_ResetOnFloor	;Sonic_ResetOnFloor_Part2

	move.w	#$F,locktime(a0)
	move.b	#id_Float4,obAnim(a0)	;#AniIDKnuxAni_ClimbLedge,obAnim(a0)

	rts
; ---------------------------------------------------------------------------
; loc_315958:
.continueSliding:
	; These two lines aren't here in S3K.
	move.b	#10,obHeight(a0)
	move.b	#10,obWidth(a0)

	bsr.w	Knuckles_Floor2

	; Get distance from floor in 'd1', and angle of floor in 'd3'.
	jsr	Sonic_HitFloor

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
	move.b	#id_FallFromGlide,obAnim(a0)

	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)

	bset	#1,(v_glidecolflags).w	;(Gliding_collision_flags).w
	rts
; ---------------------------------------------------------------------------

Knuckles_Climbing_Wall:
	;tst.b	(Disable_wall_grab).w
	;bmi.w	Knuckles_LetGoOfWall

	; If Knuckles' X coordinate is no longer the same as when he first
	; latched onto the wall, then detach him from the wall. This is
	; probably intended to detach Knuckles from the wall if something
	; physically pushes him away from it.
	move.w	obX(a0),d0
	cmp.w	obScreenY(a0),d0
	bne.w	Knuckles_LetGoOfWall

	; If an object is now carrying Knuckles, then detach him from the
	; wall.
	btst	#3,obStatus(a0)
	bne.w	Knuckles_LetGoOfWall

	move.w	#0,obInertia(a0)
	move.w	#0,obVelX(a0)
	move.w	#0,obVelY(a0)

	;move.l	#Primary_Collision,(v_collindex).w
	;cmpi.b	#$D,obSolid(a0)		;lrb_solid_bit
	;beq.s	+
	;move.l	#Secondary_Collision,(v_collindex).w
+
	move.b	obSolid(a0),d5	;lrb_solid_bit

	; These two lines aren't in S3K.
	move.b	#10,obHeight(a0)
	move.b	#10,obWidth(a0)

	moveq	#0,d1	; Climbing animation delta: make the animation pause.

	btst	#bitUp,(v_jpadhold2).w
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
	move.b	obSolid(a0),d5		;lrb_solid_bit
	move.w	obY(a0),d2
	subq.w	#8,d2
	move.w	obX(a0),d3
	bsr.w	CheckCeilingDist_WithRadius

	; Check if Knuckles has room above him.
	tst.w	d1
	bpl.s	.moveUp

	; Knuckles is bumping into the ceiling, so push him out.
	sub.w	d1,obY(a0)

	moveq	#1,d1	; Climbing animation delta: make the animation play forwards.
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
	moveq	#1,d1	; Climbing animation delta: make the animation play forwards.

	; Don't let Knuckles climb through the level's upper boundary.
	move.w	(v_limittop2).w,d0

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
	btst	#bitDn,(v_jpadhold2).w
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
	move.b	#$D,d5		;top_solid_bit
	move.w	obY(a0),d2
	addi.w	#9,d2
	move.w	obX(a0),d3
	bsr.w	CheckFloorDist_WithRadius

	; Check if Knuckles has room below him.
	tst.w	d1
	bpl.s	.moveDown

	; Knuckles has reached the floor.
	add.w	d1,obY(a0)
	move.b	(v_anglebuffer).w,obAngle(a0)

	move.w	#0,obInertia(a0)
	move.w	#0,obVelX(a0)
	move.w	#0,obVelY(a0)

	jsr	Knuckles_ResetOnFloor	;Sonic_ResetOnFloor_Part2

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
	moveq	#-1,d1	; Climbing animation delta: make the animation play backwards.

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
	andi.b	#btnUp_mask|btnDn_mask,d0
	bne.s	.isMovingUpOrDown

	; Get Knuckles' distance from the floor in 'd1'.
	move.b	#$D,d5		;top_solid_bit
	move.w	obY(a0),d2
	addi.w	#9,d2
	move.w	obX(a0),d3
	bsr.w	CheckFloorDist_WithRadius

	; Check if Knuckles has room below him.
	tst.w	d1
	bmi.w	.reachedFloor

	; Bug! 'd1' has been overwritten by 'CheckFloorDist_WithRadius', but
	; the code after this needs it for updating Knuckles' animation. This
	; bug is the reason why Knuckles resets to his first climbing frame
	; when the player is not holding up or down.
    endif

.isMovingUpOrDown:
	; If Knuckles has not moved, skip this.
	tst.w	d1
	beq.s	.notMoving

	; Only animate every 4 frames.
	subq.b	#1,(v_doublejumpprop).w
	bpl.s	.notMoving
	move.b	#3,(v_doublejumpprop).w

	; Add delta to animation frame.
	add.b	obFrame(a0),d1

	; Make the animation loop.
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

	move.b	#id_Roll,obAnim(a0)
	bset	#2,obStatus(a0)
	move.b	#0,(f_doublejump).w
; return_315B94:
.hasNotJumped:
	rts
; ---------------------------------------------------------------------------

Knuckles_ClimbUp:
	move.b	#5,(f_doublejump).w		  ; Climb up to	the floor above	you

	cmpi.b	#$BD,obFrame(a0)
	beq.s	+

	move.b	#0,(v_doublejumpprop).w
	bsr.s	Knuckles_DoLedgeClimbingAnimation
+
	rts
; ---------------------------------------------------------------------------
; loc_315BAE:
Knuckles_LetGoOfWall:
	move.b	#2,(f_doublejump).w

	move.w	#(id_FallFromGlide<<8)|id_FallFromGlide,obAnim(a0)
	move.b	#$CB,obFrame(a0)
	move.b	#7,obTimeFrame(a0)
	move.b	#1,obAniFrame(a0)

	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)

	rts
; End of function Knuckles_GlideControl


; =============== S U B	R O U T	I N E =======================================

; sub_315BDA:
Knuckles_DoLedgeClimbingAnimation:
	moveq	#0,d0
	move.b	(v_doublejumpprop).w,d0
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

	addq.b	#4,(v_doublejumpprop).w
	move.b	#0,obAniFrame(a0)
	rts
; End of function Knuckles_DoLedgeClimbingAnimation

; ---------------------------------------------------------------------------
; Strangely, the last frame uses frame $D2. It will never be seen, however,
; because it is immediately overwritten by Knuckles' waiting animation.

; word_315C12:
.frames:
	; mapping_frame, x_pos, y_pos, anim_frame_timer
	dc.b $BD,   3,  -3,   6
	dc.b $BE,   8, -10,   6
	dc.b $BF,  -8, -12,   6
	dc.b $D2,   8,  -5,   6
.framesEnd:

; =============== S U B	R O U T	I N E =======================================
;============================================================================
; sub_315C22:	;more sonic 2 code
GetDistanceFromWall:
	move.b	obSolid(a0),d5
	btst	#0,obStatus(a0)
	bne.s	.facingLeft

;.facingRight:
	move.w	obX(a0),d3
	jmp	sub_14EB4
; ---------------------------------------------------------------------------
; loc_315C36:
.facingLeft:
	move.w	obX(a0),d3
	subq.w	#1,d3
	jmp	Sonic_HitWall
; End of function GetDistanceFromWall

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Knuckles_GlideControl
; Knuckles_Climbing_Up:
Knuckles_Climbing_Onto_Ledge:
	tst.b	obTimeFrame(a0)
	bne.s	return_315C7A

	bsr.w	Knuckles_DoLedgeClimbingAnimation

	; Have we reached the end of the ledge-climbing animation?
	cmpi.b	#Knuckles_DoLedgeClimbingAnimation.framesEnd-Knuckles_DoLedgeClimbingAnimation.frames,(v_doublejumpprop).w
	bne.s	return_315C7A

	; Yes.
	move.w	#0,obInertia(a0)
	move.w	#0,obVelX(a0)
	move.w	#0,obVelY(a0)

	btst	#0,obStatus(a0)
	beq.s	+
	subq.w	#1,obX(a0)
+
	jsr	Knuckles_ResetOnFloor	;Sonic_ResetOnFloor_Part2
	move.b	#id_Wait,obAnim(a0)

return_315C7A:
	rts
; END OF FUNCTION CHUNK	FOR Knuckles_GlideControl

; =============== S U B	R O U T	I N E =======================================

; sub_315C7C:
Knuckles_DoGlidingAnimation:
	move.b	#$20,obTimeFrame(a0)
	move.b	#0,obAniFrame(a0)
	move.w	#(id_Glide<<8)|id_Glide,obAnim(a0)
	bclr	#5,obStatus(a0)
	bclr	#0,obStatus(a0)

	; Update Knuckles' frame, depending on where he's facing.
	moveq	#0,d0
	move.b	(v_doublejumpprop).w,d0
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
; End of function Knuckles_DoGlidingAnimation

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
	move.b	(v_doublejumpprop).w,d1
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

	move.b	(v_doublejumpprop).w,d0
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
	move.b	d0,(v_doublejumpprop).w

	move.b	(v_doublejumpprop).w,d0
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
	move.w	(v_limittop2).w,d0
	move.w	(v_limittop2).w,d0
	cmpi.w	#-$100,d0
	beq.w	.doNotKillspeed

	addi.w	#$10,d0
	cmp.w	obY(a0),d0
	ble.w	.doNotKillspeed

	asr.w	obVelX(a0)
	asr.w	obInertia(a0)
; loc_315D88:
.doNotKillspeed:
	cmpi.w	#$60,(v_lookshift).w
	beq.s	.doNotModifyBias
	bhs.s	+
	addq.w	#2*2,(v_lookshift).w
+
	subq.w	#2,(v_lookshift).w
; return_315D9A:
.doNotModifyBias:
	rts
; End of function Knuckles_GlideSpeedControl


CheckCeilingDist_WithRadius:
	move.b	obWidth(a0),d0
	ext.w	d0
	sub.w	d0,d2
	eori.w	#$F,d2
	lea	(v_anglebuffer).w,a4
	move.w	#-16,a3
	move.w	#$800,d6
	jsr	FindFloor
	move.b	#$80,d2
	jmp	loc_14E0A

; End of function CheckCeilingDist_WithRadius

CheckFloorDist_WithRadius:
	move.b	obWidth(a0),d0
	ext.w	d0
	add.w	d0,d2
	lea	(v_anglebuffer).w,a4
	move.w	#16,a3
	move.w	#0,d6
	jsr	FindFloor
	move.b	#0,d2
	jmp	loc_14E0A
; End of function CheckFloorDist_WithRadius


Knuckles_BeginGlide:
	cmpi.b	#id_Transform,obAnim(a0)			; is Knuckles transforming?
	beq.w	return_3165D2						;if yes, don't glide
	cmpi.b	#0,(f_tailscarrysonic).w		;Is Knuckles holding onto Tails
	bne.w	return_3165D2				;if yes, don't glide
	tst.b	(f_doublejump).w
	bne.w	return_3165D2
	move.b	(v_jpadpress2).w,d0
	andi.b	#btnB|btnC|btnA,d0
	beq.w	return_3165D2

	bclr	#2,obStatus(a0)
	move.b	#10,obHeight(a0)
	move.b	#10,obWidth(a0)
	bclr	#4,obStatus(a0)
	move.b	#1,(f_doublejump).w
	addi.w	#$200,obVelY(a0)
	bpl.s	loc_31659E
	move.w	#0,obVelY(a0)

loc_31659E:
	moveq	#0,d1
	move.w	#$400,d0
	move.w	d0,obInertia(a0)
	btst	#0,obStatus(a0)
	beq.s	loc_3165B4
	neg.w	d0
	moveq	#-$80,d1

loc_3165B4:
	move.w	d0,obVelX(a0)
	move.b	d1,(v_doublejumpprop).w
	move.w	#0,obAngle(a0)
	move.b	#0,(v_glidecolflags).w
	bset	#1,(v_glidecolflags).w
	bsr.w	Knuckles_DoGlidingAnimation

return_3165D2:
	rts





Knuckles_Floor2:
		move.w	obVelX(a0),d1
		move.w	obVelY(a0),d2
		jsr	(CalcAngle).l
		subi.b	#$20,d0
		andi.b	#$C0,d0
		cmpi.b	#$40,d0
		beq.w	loc_13680KnucklesGlide		;Sonic_HitLeftWall_2
		cmpi.b	#$80,d0
		beq.w	loc_136E2KnucklesGlide		;Sonic_HitCeilingAndWalls_2
		cmpi.b	#$C0,d0
		beq.w	loc_1373EKnucklesGlide		;Sonic_HitRightWall_2
		jsr	Sonic_HitWall	;originally bsr.w
		tst.w	d1
		bpl.s	loc_135F0KnucklesGlide
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		;gliding code
		bset	#5,(v_glidecolflags).w ;set thing for go on wall
		

loc_135F0KnucklesGlide:
		jsr	sub_14EB4	;originally bsr.w
		tst.w	d1
		bpl.s	loc_13602KnucklesGlide
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		;gliding code
		bset	#5,(v_glidecolflags).w ;set thing for go on wall
		

loc_13602KnucklesGlide:
	jsr	Sonic_HitFloor	;originally bsr.w
	tst.w	d1
	bpl.s	return_1AF8A_2
	add.w	d1,obY(a0)
	move.b	d3,obAngle(a0)
	move.w	#0,obVelY(a0)
	bclr	#1,(v_glidecolflags).w	;airborne

return_1AF8A_2:
	rts
; ===========================================================================

loc_13680KnucklesGlide:			;Sonic_HitLeftWall_2
		jsr	Sonic_HitWall	;originally bsr.w
		tst.w	d1
		bpl.s	loc_1369AKnucklesGlide
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		bset	#5,(v_glidecolflags).w ;set thing for go on wall
; ===========================================================================

loc_1369AKnucklesGlide:	;Sonic_HitCeiling_2
		jsr	Sonic_DontRunOnWalls	;originally bsr.w
		tst.w	d1
		bpl.s	loc_136B4KnucklesGlide
		neg.w	d1
		cmpi.w	#20,d1
		bhs.s	loc_316A08
		add.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_136B2KnucklesGlide
		move.w	#0,obVelY(a0) ; stop Sonic in y since he hit a ceiling

locret_136B2KnucklesGlide:
		rts

loc_316A08:
	jsr	sub_14EB4
	tst.w	d1
	bpl.s	return_316A20
	add.w	d1,obX(a0)
	move.w	#0,obVelX(a0)
	bset	#5,(v_glidecolflags).w ;set thing for go on wall

return_316A20:
	rts
; ===========================================================================

loc_136B4KnucklesGlide:		;Sonic_HitFloor2_2
		tst.w	obVelY(a0)
		bmi.s	locret_136E0KnucklesGlide
		jsr	Sonic_HitFloor	;originally bsr.w
		tst.w	d1
		bpl.s	locret_136E0KnucklesGlide
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.w	#0,obVelY(a0)
		bclr	#1,(v_glidecolflags).w

locret_136E0KnucklesGlide:
		rts
; ===========================================================================

loc_136E2KnucklesGlide:			;Sonic_HitCeilingAndWalls_2
		jsr	Sonic_HitWall	;originally bsr.w
		tst.w	d1
		bpl.s	loc_136F4KnucklesGlide
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		bset	#5,(v_glidecolflags).w ;set thing for go on wall

loc_136F4KnucklesGlide:
		jsr	sub_14EB4	;originally bsr.w
		tst.w	d1
		bpl.s	loc_13706KnucklesGlide
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		bset	#5,(v_glidecolflags).w ;set thing for go on wall

loc_13706KnucklesGlide:
		jsr	Sonic_DontRunOnWalls	;originally bsr.w
		tst.w	d1
		bpl.s	.end
		sub.w	d1,obY(a0)
		move.w	#0,obVelY(a0)
.end:
		rts
; ===========================================================================
loc_1373EKnucklesGlide:			;Sonic_HitRightWall_2
		jsr	sub_14EB4	;originally bsr.w
		tst.w	d1
		bpl.s	loc_13758KnucklesGlide
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		bset	#5,(v_glidecolflags).w ;set thing for go on wall
; ===========================================================================

loc_13758KnucklesGlide:			;Sonic_HitCeiling2_2
		jsr	Sonic_DontRunOnWalls	;originally bsr.w
		tst.w	d1
		bpl.s	loc_13772KnucklesGlide
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_13770KnucklesGlide
		move.w	#0,obVelY(a0)

locret_13770KnucklesGlide:
		rts
; ===========================================================================

loc_13772KnucklesGlide:				;Sonic_HitFloor2_2
		tst.w	obVelY(a0)
		bmi.s	locret_1379EKnucklesGlide
		jsr	Sonic_HitFloor	;originally bsr.w
		tst.w	d1
		bpl.s	locret_1379EKnucklesGlide
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		move.w	#0,obVelY(a0)
		bclr	#1,(v_glidecolflags).w
locret_1379EKnucklesGlide:
		rts
; End of function Knuckles_Floor
