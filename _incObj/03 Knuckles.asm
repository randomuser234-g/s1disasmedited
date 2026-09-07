; ---------------------------------------------------------------------------
; Object 03 - Knuckles
; ---------------------------------------------------------------------------

; obj03:
KnucklesPlayer:
		tst.w	(v_debuguse).w	; is debug mode being used?
		beq.s	Knuckles_Normal	; if not, branch
		jmp	(DebugMode).l
; ===========================================================================

; obj03_Normal:
Knuckles_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Knuckles_Index(pc,d0.w),d1
		jmp	Knuckles_Index(pc,d1.w)
; ===========================================================================
; obj03_Index:
Knuckles_Index:	dc.w Knuckles_Main-Knuckles_Index
		dc.w Knuckles_Control-Knuckles_Index
		dc.w Knuckles_Hurt-Knuckles_Index
		dc.w Knuckles_Death-Knuckles_Index
		dc.w Knuckles_ResetLevel-Knuckles_Index
	if FixBugs
		; Fix drowning bugs	;note these links are wrong, there is no Knuckles 1, it's still Sonic 1
		; https://info.Knucklesretro.org/SCHG_How-to:Correct_Drowning_Bugs_in_Knuckles_1
		dc.w Knuckles_Drowned-Knuckles_Index
	endif
; ===========================================================================

; obj03_Main:
Knuckles_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#$13,obHeight(a0)
		move.b	#9,obWidth(a0)
		move.l	#Map_Knuckles,obMap(a0)
		move.w	#make_art_tile(ArtTile_Sonic,0,0),obGfx(a0)
		move.b	#2,obPriority(a0)
		move.b	#$18,obActWid(a0)
		move.b	#4,obRender(a0)
		move.b	#0,(v_super).w	; turn off Super
		move.b	#0,(v_shoes).w	; turn off speed shoes
		move.w	#$600,(v_sonspeedmax).w ; Knuckles's top speed
		move.w	#$C,(v_sonspeedacc).w ; Knuckles's acceleration
		move.w	#$80,(v_sonspeeddec).w ; Knuckles's deceleration

; obj03_Control:
Knuckles_Control:	; Routine 2
		jsr	Sonic_PanCamera		; Run extended camera panning calculations	,bsr.w originally
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	.nodebug	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	.nodebug	; if not, branch
		move.w	#1,(v_debuguse).w ; change Knuckles into a ring/item
		clr.b	(f_lockctrl).w
		rts
; ===========================================================================

.nodebug:
		tst.b	(f_lockctrl).w	; are controls locked?
		bne.s	.ignorecontrols	; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2).w ; enable joypad control

.ignorecontrols:
		btst	#0,(f_playerctrl).w ; are controls locked?
		beq.s	.controlsnotlocked	;if not, branch
		move.b	#0,(f_doublejump).w
		bra.s	.ignoremodes
.controlsnotlocked:
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Knuckles_Modes(pc,d0.w),d1
		jsr	Knuckles_Modes(pc,d1.w)

.ignoremodes:
		bsr.s	Knuckles_Display
		jsr	Sonic_Super		;originally bsr.w
		bsr.w	Knuckles_RecordPosition
		bsr.w	Knuckles_Water
		move.b	(v_anglebuffer).w,angleright(a0)
		move.b	(v_anglebuffer2).w,angleleft(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	.nowindtunnel
		tst.b	obAnim(a0)
		bne.s	.nowindtunnel
		move.b	obPrevAni(a0),obAnim(a0)

.nowindtunnel:
		bsr.w	Knuckles_Animate
		tst.b	(f_playerctrl).w
		bmi.s	.ignoreobjcoll
		jsr	(ReactToItem).l

.ignoreobjcoll:
		bsr.w	Knuckles_Loops
		bsr.w	Knuckles_LoadGfx
		rts
; ===========================================================================
; obj03_Modes:
Knuckles_Modes:	dc.w Knuckles_MdNormal-Knuckles_Modes
		dc.w Knuckles_MdJump-Knuckles_Modes
		dc.w Knuckles_MdRoll-Knuckles_Modes
		dc.w Knuckles_MdJump2-Knuckles_Modes
; ---------------------------------------------------------------------------
; Music to play after invincibility wears off
; ---------------------------------------------------------------------------
MusicList2Knuckles:
		dc.b bgm_GHZ
		dc.b bgm_LZ
		dc.b bgm_MZ
		dc.b bgm_SLZ
		dc.b bgm_SYZ
		dc.b bgm_SBZ
		zonewarning MusicList2Knuckles,1
		; The ending doesn't get an entry
		even

; ---------------------------------------------------------------------------
; Subroutine to display Knuckles and set music
; ---------------------------------------------------------------------------

Knuckles_Display:
		move.w	flashtime(a0),d0
		beq.s	.display
		subq.w	#1,flashtime(a0)
		lsr.w	#3,d0
		bcc.s	.chkinvincible

.display:
		jsr	(DisplaySprite).l

.chkinvincible:
		tst.b	(v_invinc).w	; does Knuckles have invincibility?
		beq.s	.chkshoes	; if not, branch
		tst.w	invtime(a0)	; check time remaining for invinciblity
		beq.s	.chkshoes	; if no time remains, branch
		subq.w	#1,invtime(a0)	; subtract 1 from time
		bne.s	.chkshoes
		tst.b	(f_lockscreen).w
		bne.s	.removeinvincible
		cmpi.w	#$C,(v_air).w
		blo.s	.removeinvincible
		moveq	#0,d0
		move.b	(v_zone).w,d0
		cmpi.w	#(id_LZ<<8)+3,(v_zone).w ; check if level is SBZ3
		bne.s	.music
		moveq	#5,d0		; play SBZ music

.music:
		lea	(MusicList2Knuckles).l,a1
		move.b	(a1,d0.w),d0
		jsr	(QueueSound1).l	; play normal music

.removeinvincible:
		move.b	#0,(v_invinc).w ; cancel invincibility

.chkshoes:
		tst.b	(v_shoes).w	; does Knuckles have speed shoes?
		beq.s	.exit		; if not, branch
		tst.w	shoetime(a0)	; check time remaining
		beq.s	.exit
		tst.b	(v_super).w	; is Knuckles already Super?
		bne.s	.chkshoescont		; if yes, branch
		subq.w	#1,shoetime(a0)	; subtract 1 from time
		bne.s	.exit
		btst	#6,obStatus(a0)	;is Knuckles underwater?
		beq.s	.normalshoes	;if not, then normal shoes speed restored
	.normalshoeswater:
		move.w	#$300,(v_sonspeedmax).w ; change Knuckles's top speed
		move.w	#6,(v_sonspeedacc).w ; change Knuckles's acceleration
		move.w	#$40,(v_sonspeeddec).w ; change Knuckles's deceleration
		bra.s	.chkshoescont
	.normalshoes:
		move.w	#$600,(v_sonspeedmax).w ; restore Knuckles's speed
		move.w	#$C,(v_sonspeedacc).w ; restore Knuckles's acceleration
		move.w	#$80,(v_sonspeeddec).w ; restore Knuckles's deceleration
	.chkshoescont:
		move.b	#0,(v_shoes).w	; cancel speed shoes
		move.w	#0,(v_player+shoetime).w	;remove time limit for the power-up
		move.w	#bgm_Slowdown,d0
		jmp	(QueueSound1).l	; run music at normal speed

.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to record Knuckles's previous positions for invincibility stars
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Knuckles_RecordPos:
Knuckles_RecordPosition:
		move.w	(v_trackpos).w,d0
		lea	(v_tracksonic).w,a1
		lea	(a1,d0.w),a1
		move.w	obX(a0),(a1)+
		move.w	obY(a0),(a1)+
		addq.b	#4,(v_trackbyte).w	;downwards is from Knuckles 2/3
		lea	(v_trackstatsonic).w,a1
		lea	(a1,d0.w),a1
		move.w	(v_jpadhold2).w,(a1)+
		move.w	obStatus(a0),(a1)+ ; Copies `status` AND the byte after it...
		move.b	obGfx(a0),(a1)+
		rts
; End of function Knuckles_RecordPosition

; ---------------------------------------------------------------------------
; Subroutine for Knuckles when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_Water:
		cmpi.b	#1,(f_water).w	; is there water?
		beq.s	.islabyrinth	; if yes, branch

.exit:
		rts
; ===========================================================================

; obj03_InWater:
.islabyrinth:
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0	; is Knuckles above the water?
		bge.s	.abovewater	; if yes, branch
		bset	#6,obStatus(a0)
		bne.s	.exit
		jsr	ResumeMusic	;bsr.w originally
		move.b	#id_DrownCount,(v_sonicbubbles).w ; load bubbles object from Knuckles's mouth
		move.b	#$81,(v_sonicbubbles+obSubtype).w
		tst.b	(v_super).w	; is Knuckles Super?
		bne.s	.skipspeedslow		; if yes, branch
		tst.b	(v_shoes).w	; does Knuckles have speed shoes?
		bne.s	.skipspeedslow		; if yes, branch
		move.w	#$300,(v_sonspeedmax).w ; change Knuckles's top speed
		move.w	#6,(v_sonspeedacc).w ; change Knuckles's acceleration
		move.w	#$40,(v_sonspeeddec).w ; change Knuckles's deceleration
	.skipspeedslow:
		asr	obVelX(a0)
		asr	obVelY(a0)
		asr	obVelY(a0)	; slow Knuckles
		beq.s	.exit		; branch if Knuckles stops moving
		move.b	#id_Splash,(v_splash).w ; load splash object
		move.w	#sfx_Splash,d0
		jmp	(QueueSound2).l	 ; play splash sound
; ===========================================================================

; obj03_OutWater:
.abovewater:
		bclr	#6,obStatus(a0)
		beq.s	.exit
		jsr	ResumeMusic	;bsr.w originally
		tst.b	(v_super).w	; is Knuckles Super?
		bne.s	.speedshoesexitwater		; if yes, branch
		tst.b	(v_shoes).w	; does Knuckles have speed shoes?
		bne.s	.speedshoesexitwater		; if yes, branch
		move.w	#$600,(v_sonspeedmax).w ; restore Knuckles's speed
		move.w	#$C,(v_sonspeedacc).w ; restore Knuckles's acceleration
		move.w	#$80,(v_sonspeeddec).w ; restore Knuckles's deceleration
		bra.s	.exitwatercont
	.speedshoesexitwater:
		nop
	.exitwatercont:
		asl	obVelY(a0)
		beq.w	.exit
		move.b	#id_Splash,(v_splash).w ; load splash object
		cmpi.w	#-$1000,obVelY(a0)
		bgt.s	.belowmaxspeed
		move.w	#-$1000,obVelY(a0) ; set maximum speed on leaving water

.belowmaxspeed:
		move.w	#sfx_Splash,d0
		jmp	(QueueSound2).l	 ; play splash sound
; End of function Knuckles_Water

; ===========================================================================
; ---------------------------------------------------------------------------
; Modes for controlling Knuckles
; ---------------------------------------------------------------------------

; obj03_MdNormal:
Knuckles_MdNormal:
		bsr.w	Knuckles_SpinDash	
		bsr.w	Knuckles_Jump
		bsr.w	Knuckles_SlopeResist
		bsr.w	Knuckles_Move
		bsr.w	Knuckles_Roll
		bsr.w	Knuckles_LevelBound
		jsr	(SpeedToPos).l
		jsr	Sonic_AnglePos	;originally bsr.w
		bsr.w	Knuckles_SlopeRepel
		rts
; ===========================================================================

; obj03_MdJump:
Knuckles_MdJump:
	tst.b	(f_doublejump).w	;doublejump flag is active?
	bne.w	Obj01_MdAir_Gliding	;if yes, run gliding code

		bsr.w	Knuckles_JumpHeight
		bsr.w	Knuckles_JumpDirection
		bsr.w	Knuckles_LevelBound
		jsr	(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	.notunderwater
		subi.w	#$28,obVelY(a0)

.notunderwater:
		bsr.w	Knuckles_JumpAngle
		bsr.w	Knuckles_Floor
		rts
; ===========================================================================

; obj03_MdRoll:
Knuckles_MdRoll:
		bsr.w	Knuckles_Jump
		bsr.w	Knuckles_RollRepel
		bsr.w	Knuckles_RollSpeed
		bsr.w	Knuckles_LevelBound
		jsr	(SpeedToPos).l
		jsr	Sonic_AnglePos	;originally bsr.w
		bsr.w	Knuckles_SlopeRepel
		rts
; ===========================================================================

; obj03_MdJump2:
Knuckles_MdJump2:
		bsr.w	Knuckles_JumpHeight
		bsr.w	Knuckles_JumpDirection
		bsr.w	Knuckles_LevelBound
		jsr	(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	.notunderwater
		subi.w	#$28,obVelY(a0)

.notunderwater:
		bsr.w	Knuckles_JumpAngle
		bsr.w	Knuckles_Floor
		rts

; ---------------------------------------------------------------------------
; Subroutine to make Knuckles walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Knuckles_Move:
		move.b	#0,(f_doublejump).w ;clear thing for go on wall
		move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		move.w	(v_sonspeeddec).w,d4
		tst.b	(f_slidemode).w
		bne.w	loc_12FEEKnuckles
		tst.w	locktime(a0)	; is Knuckles's D-Pad input temporarily locked?
		bne.w	Knuckles_ResetScr	; if yes, ignore D-Pad input
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		beq.s	.notleft	; if not, branch
		bsr.w	Knuckles_MoveLeft

.notleft:
		btst	#bitR,(v_jpadhold2).w ; is right being pressed?
		beq.s	.notright	; if not, branch
		bsr.w	Knuckles_MoveRight

.notright:
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0		; is Knuckles on a slope?
		bne.w	Knuckles_ResetScr	; if yes, branch
		tst.w	obInertia(a0)	; is Knuckles moving?
		bne.w	Knuckles_ResetScr	; if yes, branch
		bclr	#5,obStatus(a0)
		move.b	#id_Wait,obAnim(a0) ; use "standing" animation
		btst	#3,obStatus(a0)
		beq.s	Knuckles_Balance
		moveq	#0,d0
		move.b	standonobject(a0),d0
		lsl.w	#object_size_bits,d0
		lea	(v_objspace).w,a1
		lea	(a1,d0.w),a1
		tst.b	obStatus(a1)
		bmi.s	Knuckles_LookUp
		moveq	#0,d1
		move.b	obActWid(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2
		add.w	obX(a0),d1
		sub.w	obX(a1),d1
		cmpi.w	#4,d1
		blt.s	loc_12F6AKnuckles
		cmp.w	d2,d1
		bge.s	loc_12F5AKnuckles
		bra.s	Knuckles_LookUp
; ===========================================================================

Knuckles_Balance:
		jsr	(ObjFloorDist).l
		cmpi.w	#$C,d1
		blt.s	Knuckles_LookUp
		cmpi.b	#3,angleright(a0)
		bne.s	loc_12F62Knuckles

loc_12F5AKnuckles:
		bclr	#0,obStatus(a0)
		bra.s	loc_12F70Knuckles
; ===========================================================================

loc_12F62Knuckles:
		cmpi.b	#3,angleleft(a0)
		bne.s	Knuckles_LookUp

loc_12F6AKnuckles:
		bset	#0,obStatus(a0)

loc_12F70Knuckles:
		move.b	#id_Balance,obAnim(a0) ; use "balancing" animation
		bra.s	Knuckles_ResetScr
; ===========================================================================

Knuckles_LookUp:
		btst	#bitUp,(v_jpadhold2).w ; is up being pressed?
		beq.s	Knuckles_Duck	; if not, branch
		move.b	#id_LookUp,obAnim(a0) ; use "looking up" animation
		cmpi.w	#$C8,(v_lookshift).w
		beq.s	loc_12FC2Knuckles
		addq.w	#2,(v_lookshift).w
		bra.s	loc_12FC2Knuckles
; ===========================================================================

Knuckles_Duck:
		btst	#bitDn,(v_jpadhold2).w ; is down being pressed?
		beq.s	Knuckles_ResetScr	; if not, branch
		move.b	#id_Duck,obAnim(a0) ; use "ducking" animation
		cmpi.w	#8,(v_lookshift).w
		beq.s	loc_12FC2Knuckles
		subq.w	#2,(v_lookshift).w
		bra.s	loc_12FC2Knuckles
; ===========================================================================

; obj03_ResetScr
Knuckles_ResetScr:
		cmpi.w	#$60,(v_lookshift).w ; is screen in its default position?
		beq.s	loc_12FC2Knuckles	; if yes, branch
		bcc.s	loc_12FBEKnuckles
		addq.w	#4,(v_lookshift).w ; move screen back to default

loc_12FBEKnuckles:
		subq.w	#2,(v_lookshift).w ; move screen back to default

loc_12FC2Knuckles:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0	; is left/right pressed?
		bne.s	loc_12FEEKnuckles	; if yes, branch
		move.w	obInertia(a0),d0
		beq.s	loc_12FEEKnuckles
		bmi.s	loc_12FE2Knuckles
		sub.w	d5,d0
		bcc.s	loc_12FDCKnuckles
		move.w	#0,d0

loc_12FDCKnuckles:
		move.w	d0,obInertia(a0)
		bra.s	loc_12FEEKnuckles
; ===========================================================================

loc_12FE2Knuckles:
		add.w	d5,d0
		bcc.s	loc_12FEAKnuckles
		move.w	#0,d0

loc_12FEAKnuckles:
		move.w	d0,obInertia(a0)

loc_12FEEKnuckles:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)

loc_1300CKnuckles:
		move.b	obAngle(a0),d0
		addi.b	#$40,d0
		bmi.s	locret_1307CKnuckles
		move.b	#$40,d1
		tst.w	obInertia(a0)
		beq.s	locret_1307CKnuckles
		bmi.s	loc_13024Knuckles
		neg.w	d1

loc_13024Knuckles:
		move.b	obAngle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		jsr	Sonic_WalkSpeed	;originally bsr.w
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_1307CKnuckles
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_13078Knuckles
		cmpi.b	#$40,d0
		beq.s	loc_13066Knuckles
		cmpi.b	#$80,d0
		beq.s	loc_13060Knuckles
		add.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts
; ===========================================================================

loc_13060Knuckles:
		sub.w	d1,obVelY(a0)
		rts
; ===========================================================================

loc_13066Knuckles:
		sub.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts
; ===========================================================================

loc_13078Knuckles:
		add.w	d1,obVelY(a0)

locret_1307CKnuckles:
		rts
; End of function Knuckles_Move

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Knuckles_MoveLeft:
		btst	#2,obStatus(a0)	; is Knuckles already rolling?
		bne.s	locret_130E8Knuckles		; if yes, branch
		move.w	obInertia(a0),d0
		beq.s	loc_13086Knuckles
		bpl.s	loc_130B2Knuckles

loc_13086Knuckles:
		bset	#0,obStatus(a0)
		bne.s	loc_1309AKnuckles
		bclr	#5,obStatus(a0)
		move.b	#id_Run,obPrevAni(a0) ; restart Knuckles's animation

loc_1309AKnuckles:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_130A6Knuckles
		add.w	d5,d0	; remove this frame's acceleration change
		cmp.w	d1,d0	; compare speed with top speed
		ble.s	loc_130A6Knuckles; if speed was already greater than the maximum, branch
		move.w	d1,d0

loc_130A6Knuckles:
		move.w	d0,obInertia(a0)
		move.b	#id_Walk,obAnim(a0) ; use walking animation
		rts
; ===========================================================================

loc_130B2Knuckles:
		sub.w	d4,d0
		bcc.s	loc_130BAKnuckles
		move.w	#-$80,d0

loc_130BAKnuckles:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_130E8Knuckles
		cmpi.w	#$400,d0
		blt.s	locret_130E8Knuckles
		move.b	#id_Stop,obAnim(a0) ; use "stopping" animation
		bclr	#0,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr	(QueueSound2).l	; play stopping sound

locret_130E8Knuckles:
		rts
; End of function Knuckles_MoveLeft


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_MoveRight:
		btst	#2,obStatus(a0)	; is Knuckles already rolling?
		bne.s	locret_1314EKnuckles		; if yes, branch
		move.w	obInertia(a0),d0
		bmi.s	loc_13118Knuckles
		bclr	#0,obStatus(a0)
		beq.s	loc_13104Knuckles
		bclr	#5,obStatus(a0)
		move.b	#id_Run,obPrevAni(a0) ; restart Knuckles's animation

loc_13104Knuckles:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_1310CKnuckles
		sub.w	d5,d0	; remove this frame's acceleration change
		cmp.w	d1,d0	; compare speed with top speed
		bge.s	loc_1310CKnuckles; if speed was already greater than the maximum, branch
		move.w	d6,d0

loc_1310CKnuckles:
		move.w	d0,obInertia(a0)
		move.b	#id_Walk,obAnim(a0) ; use walking animation
		rts
; ===========================================================================

loc_13118Knuckles:
		add.w	d4,d0
		bcc.s	loc_13120Knuckles
		move.w	#$80,d0

loc_13120Knuckles:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_1314EKnuckles
		cmpi.w	#-$400,d0
		bgt.s	locret_1314EKnuckles
		move.b	#id_Stop,obAnim(a0) ; use "stopping" animation
		bset	#0,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr	(QueueSound2).l	; play stopping sound

locret_1314EKnuckles:
		rts
; End of function Knuckles_MoveRight

; ---------------------------------------------------------------------------
; Subroutine to change Knuckles's speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_RollSpeed:
		move.w	(v_sonspeedmax).w,d6
		asl.w	#1,d6
		moveq	#6,d5	; natural roll deceleration = 1/2 normal acceleration
		move.w	(v_sonspeeddec).w,d4
		asr.w	#2,d4
		tst.b	(f_slidemode).w
		bne.w	loc_131CCKnuckles
		tst.w	locktime(a0)	; is Knuckles's D-Pad input temporarily locked?
		bne.s	.notright	; if yes, ignore D-Pad input
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		beq.s	.notleft	; if not, branch
		bsr.w	Knuckles_RollLeft

.notleft:
		btst	#bitR,(v_jpadhold2).w ; is right being pressed?
		beq.s	.notright	; if not, branch
		bsr.w	Knuckles_RollRight

.notright:
		move.w	obInertia(a0),d0
		beq.s	loc_131AAKnuckles
		bmi.s	loc_1319EKnuckles
		sub.w	d5,d0
		bcc.s	loc_13198Knuckles
		move.w	#0,d0

loc_13198Knuckles:
		move.w	d0,obInertia(a0)
		bra.s	loc_131AAKnuckles
; ===========================================================================

loc_1319EKnuckles:
		add.w	d5,d0
		bcc.s	loc_131A6Knuckles
		move.w	#0,d0

loc_131A6Knuckles:
		move.w	d0,obInertia(a0)

loc_131AAKnuckles:
		tst.w	obInertia(a0)	; is Knuckles moving?
		bne.s	loc_131CCKnuckles	; if yes, branch
		bclr	#2,obStatus(a0)
		move.b	#$13,obHeight(a0)
		;jsr	TailsHeight
		move.b	#9,obWidth(a0)
		move.b	#id_Wait,obAnim(a0) ; use "standing" animation
		subq.w	#5,obY(a0)
		;jsr	Tails_HeightAfterLanding

loc_131CCKnuckles:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		cmpi.w	#$1000,d1
		ble.s	loc_131F0Knuckles
		move.w	#$1000,d1

loc_131F0Knuckles:
		cmpi.w	#-$1000,d1
		bge.s	loc_131FAKnuckles
		move.w	#-$1000,d1

loc_131FAKnuckles:
		move.w	d1,obVelX(a0)
		bra.w	loc_1300CKnuckles
; End of function Knuckles_RollSpeed


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_RollLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_1320AKnuckles
		bpl.s	loc_13218Knuckles

loc_1320AKnuckles:
		bset	#0,obStatus(a0)
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		rts
; ===========================================================================

loc_13218Knuckles:
		sub.w	d4,d0
		bcc.s	loc_13220Knuckles
		move.w	#-$80,d0

loc_13220Knuckles:
		move.w	d0,obInertia(a0)
		rts
; End of function Knuckles_RollLeft


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_RollRight:
		move.w	obInertia(a0),d0
		bmi.s	loc_1323AKnuckles
		bclr	#0,obStatus(a0)
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		rts
; ===========================================================================

loc_1323AKnuckles:
		add.w	d4,d0
		bcc.s	loc_13242Knuckles
		move.w	#$80,d0

loc_13242Knuckles:
		move.w	d0,obInertia(a0)
		rts
; End of function Knuckles_RollRight

; ---------------------------------------------------------------------------
; Subroutine to change Knuckles's direction while jumping
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Knuckles_ChgJumpDir
Knuckles_JumpDirection:
		move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		asl.w	#1,d5
		btst	#4,obStatus(a0)
		bne.s	obj03_ResetScr2
		move.w	obVelX(a0),d0
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		beq.s	loc_13278Knuckles	; if not, branch
		bset	#0,obStatus(a0)
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_13278Knuckles
		add.w	d5,d0	; remove this frame's acceleration change
		cmp.w	d1,d0	; compare speed with top speed
		ble.s	loc_13278Knuckles; if speed was already greater than the maximum, branch
		move.w	d1,d0

loc_13278Knuckles:
		btst	#bitR,(v_jpadhold2).w ; is right being pressed?
		beq.s	obj03_JumpMove	; if not, branch
		bclr	#0,obStatus(a0)
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	obj03_JumpMove
		sub.w	d5,d0			; +++ remove this frame's acceleration change
		cmp.w	d6,d0			; +++ compare speed with top speed
		bge.s	obj03_JumpMove		; +++ if speed was already greater than the maximum, branch
		move.w	d6,d0

obj03_JumpMove:
		move.w	d0,obVelX(a0)	; change Knuckles's horizontal speed

obj03_ResetScr2:
		cmpi.w	#$60,(v_lookshift).w ; is the screen in its default position?
		beq.s	loc_132A4Knuckles	; if yes, branch
		bcc.s	loc_132A0Knuckles
		addq.w	#4,(v_lookshift).w

loc_132A0Knuckles:
		subq.w	#2,(v_lookshift).w

loc_132A4Knuckles:
		cmpi.w	#-$400,obVelY(a0) ; is Knuckles moving faster than -$400 upwards?
		blo.s	locret_132D2Knuckles	; if yes, branch
		move.w	obVelX(a0),d0
		move.w	d0,d1
		asr.w	#5,d1
		beq.s	locret_132D2Knuckles
		bmi.s	loc_132C6Knuckles
		sub.w	d1,d0
		bcc.s	loc_132C0Knuckles
		move.w	#0,d0

loc_132C0Knuckles:
		move.w	d0,obVelX(a0)
		rts
; ===========================================================================

loc_132C6Knuckles:
		sub.w	d1,d0
		bcs.s	loc_132CEKnuckles
		move.w	#0,d0

loc_132CEKnuckles:
		move.w	d0,obVelX(a0)

locret_132D2Knuckles:
		rts
; End of function Knuckles_JumpDirection

; ===========================================================================
; ---------------------------------------------------------------------------
; Unused subroutine to squash Knuckles
; ---------------------------------------------------------------------------

Knuckles_SquashUnused:
		;dont

.return:
		rts

; ---------------------------------------------------------------------------
; Subroutine to prevent Knuckles leaving the boundaries of a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_LevelBound:
		move.l	obX(a0),d1
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		swap	d1
		move.w	(v_limitleft2).w,d0
		addi.w	#$10,d0
		cmp.w	d1,d0		; has Knuckles touched the side boundary?
		bhi.s	.sides		; if yes, branch
		move.w	(v_limitright2).w,d0
		addi.w	#$128,d0
		tst.b	(f_lockscreen).w
		bne.s	.screenlocked
		addi.w	#$40,d0

.screenlocked:
		cmp.w	d1,d0		; has Knuckles touched the side boundary?
		bls.s	.sides		; if yes, branch

.chkbottom:
		move.w	(v_limitbtm2).w,d0
	if FixBugs
		; The original code does not consider that the camera boundary
		; may be in the middle of lowering itself, which is why going
		; down the S-tunnel in Green Hill Zone Act 1 fast enough can
		; kill Knuckles.
		move.w	(v_limitbtm1).w,d1
		cmp.w	d0,d1
		blo.s	.skip
		move.w	d1,d0
.skip:
	endif
		addi.w	#224,d0
		cmp.w	obY(a0),d0	; has Knuckles touched the bottom boundary?
		blt.s	.bottom		; if yes, branch
		rts
; ===========================================================================

; Boundary_Bottom
.bottom:
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w ; is level SBZ2 ?
		bne.w	.kill	; if not, kill Knuckles
		cmpi.w	#$2000,(v_player+obX).w
		blo.w	.kill
		clr.b	(v_lastlamp).w	; clear lamppost counter
		move.w	#1,(f_restart).w ; restart the level
		move.w	#(id_LZ<<8)+3,(v_zone).w ; set level to SBZ3 (LZ4)
		rts
.dontkill:
		rts
.kill:
		jsr	KillSonic
		rts
; ===========================================================================

; Boundary_Sides
.sides:
		move.w	d0,obX(a0)
		move.w	#0,obX+2(a0)
		move.w	#0,obVelX(a0)	; stop Knuckles moving
		move.w	#0,obInertia(a0)
		bra.s	.chkbottom
; End of function Knuckles_LevelBound

; ---------------------------------------------------------------------------
; Subroutine allowing Knuckles to roll when he's moving
; also enables ducking while slow (s3 port)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_Roll:
		tst.b	(f_slidemode).w
		bne.s	.noroll
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL+btnR,d0	; is left/right being pressed?
		bne.s	.noroll		; if yes, branch
		btst	#bitDn,(v_jpadhold2).w ; is down being pressed?
		beq.s	.knuckleschkwalk	; if yes, branch
		move.w	obInertia(a0),d0
		bpl.s	.ispositive
		neg.w	d0

.ispositive:
		cmpi.w	#$100,d0		; is Knuckles moving at $100 speed or faster?
		bhs.s	Knuckles_ChkRoll	; if yes, branch
		btst	#3,obStatus(a0)
		bne.s	.noroll
		move.b	#id_Duck,obAnim(a0)	; if so, enter walking animation
; obj03_NoRoll
.noroll:
		rts
; ===========================================================================

; obj03_ChkRoll
.knuckleschkwalk:
		cmpi.b	#id_Duck,obAnim(a0)	; is Sonic ducking?
		bne.s	.noroll
		move.b	#id_Walk,obAnim(a0)	; if so, enter walking animation
		rts
; ===========================================================================

; obj03_ChkRoll
Knuckles_ChkRoll:
		btst	#2,obStatus(a0)	; is Knuckles already rolling?
		beq.s	.roll		; if not, branch
		rts
; ===========================================================================

; obj03_DoRoll
.roll:
		bset	#2,obStatus(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		addq.w	#5,obY(a0)
		;jsr	TailsRollHeight
		move.w	#sfx_Roll,d0
		jsr	(QueueSound2).l	; play rolling sound
		tst.w	obInertia(a0)
		bne.s	.ismoving
		move.w	#$200,obInertia(a0) ; set inertia if 0

.ismoving:
		rts
; End of function Knuckles_Roll

; ---------------------------------------------------------------------------
; Subroutine allowing Knuckles to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_Jump:
		move.b	(v_jpadpress2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		beq.w	.return	; if not, branch
		moveq	#0,d0
		move.b	obAngle(a0),d0
		addi.b	#$80,d0
		jsr	sub_14D48	;originally bsr.w
		cmpi.w	#6,d1
		blt.w	.return
		move.w	#$600,d2	; set initial jump force.
		btst	#6,obStatus(a0)	; is Knuckles underwater?
		beq.s	.notunderwater	; if not, continue.
		move.w	#$300,d2	; set underwater jump force.

.notunderwater:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l	; find the direction Knuckles should jump.
		muls.w	d2,d1	; apply jump force to the cosine angle.
		asr.l	#8,d1
		add.w	d1,obVelX(a0)	; apply to X speed.
		muls.w	d2,d0	; apply jump force to the sine angle.
		asr.l	#8,d0
		add.w	d0,obVelY(a0)	; apply to Y speed.
		bset	#1,obStatus(a0)	; set in-air flag.
		bclr	#5,obStatus(a0)	; clear pushing flag.
		addq.l	#4,sp	; Run in-air subroutines when we return.
		move.b	#1,jumping(a0)	; set jump flag.
		clr.b	sticktoconvex(a0)
		move.w	#sfx_Jump,d0
		jsr	(QueueSound2).l	; play jumping sound
		move.b	#$13,obHeight(a0)	; set Knuckles's hitbox to standing size. This is a leftover from the victory animation in prototypes.
		;jsr	TailsHeight
		move.b	#9,obWidth(a0)
		btst	#2,obStatus(a0)	; is Knuckles already in a ball state?
		bne.s	.rolljump	; if so, branch.
		move.b	#$E,obHeight(a0)	; set Knuckles's hitbox to ball size.
		move.b	#7,obWidth(a0)
		move.b	#id_Roll,obAnim(a0) ; use "jumping" animation
		bset	#2,obStatus(a0)
		move.b	obHeight(a0),d0		;jump routine part grabbed from Knuckles 3 (prototype), just without Obj_Height_2 and 3
		sub.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,obY(a0)

.return:
		rts

.rolljump:
		;bset	#4,obStatus(a0)	; set roll-jump flag.
		rts
; End of function Knuckles_Jump

; ---------------------------------------------------------------------------
; Subroutine controlling Knuckles's jump height/duration
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_JumpHeight:
		tst.b	jumping(a0)	; has Knuckles jumped?
		beq.s	.capyvel		; if not, just cap Y speed normally.
		move.w	#-$400,d1		; set max jump height.
		btst	#6,obStatus(a0)	; is Knuckles underwater?
		beq.s	.notunderwater	; if not, continue.
		move.w	#-$200,d1		; set underwater jump height.

.notunderwater:
		cmp.w	obVelY(a0),d1	; get current y speed.
		ble.s	.midairability
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		bne.s	.return	; if yes, branch
		move.w	d1,obVelY(a0)

.return:
		rts
.midairability:
		jsr	Sonic_CheckGoSuper
		;jsr	KnucklesGlideCustom
		jsr	Knuckles_BeginGlide
		rts

.capyvel:
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	.return2
		move.w	#-$FC0,obVelY(a0)

.return2:
		rts
; End of function Knuckles_JumpHeight

; ---------------------------------------------------------------------------
; Subroutine to slow Knuckles walking up a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_SlopeResist:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bhs.s	locret_13508Knuckles
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		beq.s	locret_13508Knuckles
		bmi.s	loc_13504Knuckles
		tst.w	d0
		beq.s	locret_13502Knuckles
		add.w	d0,obInertia(a0) ; change Knuckles's inertia

locret_13502Knuckles:
		rts
; ===========================================================================

loc_13504Knuckles:
		add.w	d0,obInertia(a0)

locret_13508Knuckles:
		rts
; End of function Knuckles_SlopeResist

; ---------------------------------------------------------------------------
; Subroutine to push Knuckles down a slope while he's rolling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_RollRepel:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#-$40,d0
		bhs.s	locret_13544Knuckles
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	#$50,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		bmi.s	loc_1353AKnuckles
		tst.w	d0
		bpl.s	loc_13534Knuckles
		asr.l	#2,d0

loc_13534Knuckles:
		add.w	d0,obInertia(a0)
		rts
; ===========================================================================

loc_1353AKnuckles:
		tst.w	d0
		bmi.s	loc_13540Knuckles
		asr.l	#2,d0

loc_13540Knuckles:
		add.w	d0,obInertia(a0)

locret_13544Knuckles:
		rts
; End of function Knuckles_RollRepel

; ---------------------------------------------------------------------------
; Subroutine to push Knuckles down a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_SlopeRepel:
		nop	
		tst.b	sticktoconvex(a0)
		bne.s	locret_13580Knuckles
		tst.w	locktime(a0)
		bne.s	loc_13582Knuckles
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	locret_13580Knuckles
		move.w	obInertia(a0),d0
		bpl.s	loc_1356AKnuckles
		neg.w	d0

loc_1356AKnuckles:
		cmpi.w	#$280,d0
		bhs.s	locret_13580Knuckles
		clr.w	obInertia(a0)
		bset	#1,obStatus(a0)
		move.w	#30,locktime(a0)

locret_13580Knuckles:
		rts
; ===========================================================================

loc_13582Knuckles:
		subq.w	#1,locktime(a0)
		rts
; End of function Knuckles_SlopeRepel

; ---------------------------------------------------------------------------
; Subroutine to return Knuckles's angle to 0 as he jumps
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_JumpAngle:
		move.b	obAngle(a0),d0	; get Knuckles's angle
		beq.s	.return	; if already 0, branch
		bpl.s	.decrease	; if higher than 0, branch
		addq.b	#2,d0		; increase angle
		bcc.s	.dontclear	; if the angle's still below 0, dont clear the angle.
		moveq	#0,d0

.dontclear:
		bra.s	.applyangle

.decrease:
		subq.b	#2,d0		; decrease angle
		bcc.s	.applyangle	; if the angle's still above 0, don't clear the angle.
		moveq	#0,d0

.applyangle:
		move.b	d0,obAngle(a0)

.return:
		rts
; End of function Knuckles_JumpAngle

; ---------------------------------------------------------------------------
; Subroutine for Knuckles to interact with the floor after jumping/falling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_Floor:
		move.w	obVelX(a0),d1
		move.w	obVelY(a0),d2
		jsr	(CalcAngle).l
		move.b	d0,(v_unused3).w
		subi.b	#$20,d0
		move.b	d0,(v_unused4).w
		andi.b	#$C0,d0
		move.b	d0,(v_unused5).w
		cmpi.b	#$40,d0
		beq.w	loc_13680Knuckles
		cmpi.b	#$80,d0
		beq.w	loc_136E2Knuckles
		cmpi.b	#$C0,d0
		beq.w	loc_1373EKnuckles
		jsr	Sonic_HitWall	;originally bsr.w
		tst.w	d1
		bpl.s	loc_135F0Knuckles
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		;old gliding code
		;cmpi.b	#id_Glide,obAnim(a0)	;is Knuckles already gliding
		;bne.s	loc_135F0Knuckles	;if not, don't do this part
		;move.b	#1,(f_doublejump).w ;set thing for go on wall
		

loc_135F0Knuckles:
		jsr	sub_14EB4	;originally bsr.w
		tst.w	d1
		bpl.s	loc_13602Knuckles
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		;old gliding code
		;cmpi.b	#id_Glide,obAnim(a0)	;is Knuckles already gliding
		;bne.s	loc_13602Knuckles	;if not, don't do this part
		;move.b	#1,(f_doublejump).w ;set thing for go on wall
		

loc_13602Knuckles:
		jsr	Sonic_HitFloor	;originally bsr.w
		move.b	d1,(v_unused6).w
		tst.w	d1
		bpl.s	locret_1367EKnuckles
		move.b	obVelY(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	loc_1361EKnuckles
		cmp.b	d2,d0
		blt.s	locret_1367EKnuckles

loc_1361EKnuckles:
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Knuckles_ResetOnFloor
		move.b	#id_Walk,obAnim(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_1365CKnuckles
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_1364EKnuckles
		asr	obVelY(a0)
		bra.s	loc_13670Knuckles
; ===========================================================================

loc_1364EKnuckles:
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		rts
; ===========================================================================

loc_1365CKnuckles:
		move.w	#0,obVelX(a0)
		cmpi.w	#$FC0,obVelY(a0)
		ble.s	loc_13670Knuckles
		move.w	#$FC0,obVelY(a0)

loc_13670Knuckles:
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_1367EKnuckles
		neg.w	obInertia(a0)

locret_1367EKnuckles:
		rts
; ===========================================================================

loc_13680Knuckles:
		jsr	Sonic_HitWall	;originally bsr.w
		tst.w	d1
		bpl.s	loc_1369AKnuckles
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts
; ===========================================================================

loc_1369AKnuckles:
		jsr	Sonic_DontRunOnWalls	;originally bsr.w
		tst.w	d1
		bpl.s	loc_136B4Knuckles
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_136B2Knuckles
		move.w	#0,obVelY(a0)

locret_136B2Knuckles:
		rts
; ===========================================================================

loc_136B4Knuckles:
		tst.w	obVelY(a0)
		bmi.s	locret_136E0Knuckles
		jsr	Sonic_HitFloor	;originally bsr.w
		tst.w	d1
		bpl.s	locret_136E0Knuckles
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Knuckles_ResetOnFloor
		move.b	#id_Walk,obAnim(a0)
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_136E0Knuckles:
		rts
; ===========================================================================

loc_136E2Knuckles:
		jsr	Sonic_HitWall	;originally bsr.w
		tst.w	d1
		bpl.s	loc_136F4Knuckles
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_136F4Knuckles:
		jsr	sub_14EB4	;originally bsr.w
		tst.w	d1
		bpl.s	loc_13706Knuckles
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_13706Knuckles:
		jsr	Sonic_DontRunOnWalls	;originally bsr.w
		tst.w	d1
		bpl.s	locret_1373CKnuckles
		sub.w	d1,obY(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_13726Knuckles
		move.w	#0,obVelY(a0)
		rts
; ===========================================================================

loc_13726Knuckles:
		move.b	d3,obAngle(a0)
		bsr.w	Knuckles_ResetOnFloor
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_1373CKnuckles
		neg.w	obInertia(a0)

locret_1373CKnuckles:
		rts
; ===========================================================================

loc_1373EKnuckles:
		jsr	sub_14EB4	;originally bsr.w
		tst.w	d1
		bpl.s	loc_13758Knuckles
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts
; ===========================================================================

loc_13758Knuckles:
		jsr	Sonic_DontRunOnWalls	;originally bsr.w
		tst.w	d1
		bpl.s	loc_13772Knuckles
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_13770Knuckles
		move.w	#0,obVelY(a0)

locret_13770Knuckles:
		rts
; ===========================================================================

loc_13772Knuckles:
		tst.w	obVelY(a0)
		bmi.s	locret_1379EKnuckles
		jsr	Sonic_HitFloor	;originally bsr.w
		tst.w	d1
		bpl.s	locret_1379EKnuckles
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Knuckles_ResetOnFloor
		move.b	#id_Walk,obAnim(a0)
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_1379EKnuckles:
		rts
; End of function Knuckles_Floor

; ---------------------------------------------------------------------------
; Subroutine to reset Knuckles's mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_ResetOnFloor:
		clr.b	(f_tailscarrysonic).w                   ; clear tails carrying sonic
		btst	#4,obStatus(a0)	; is Knuckles roll-jumping?
		beq.s	.notrolljump	; if not, skip.
		nop	; Unknown removed code.
		nop	
		nop	

.notrolljump:		;kis2 landing code
	move.b	obHeight(a0),d0
	move.b	#19,obHeight(a0)
	move.b	#9,obWidth(a0)
	btst	#2,obStatus(a0)
	beq.s	.notball
	bclr	#2,obStatus(a0)
	move.b	#id_Walk,obAnim(a0)	; use running/walking/standing animation
	subi.b	#19,d0
	ext.w	d0
	add.w	d0,obY(a0)

.notball:
		bclr	#5,obStatus(a0)	; clear push flag.
		bclr	#1,obStatus(a0)	; clear in-air flag.
		bclr	#4,obStatus(a0)	; clear roll-jump flag.
		move.b	#0,jumping(a0)	; clear jump flag.
		move.w	#0,(v_itembonus).w	; clear enemy score chain.
		clr.b	(f_doublejump).w
		rts
; End of function Knuckles_ResetOnFloor

; ---------------------------------------------------------------------------
; Knuckles when he gets hurt
; ---------------------------------------------------------------------------

; obj03_Hurt:
Knuckles_Hurt:	; Routine 4
		jsr	(SpeedToPos).l
		addi.w	#$30,obVelY(a0)
		btst	#6,obStatus(a0)
		beq.s	.notunderwater
		subi.w	#$20,obVelY(a0)

.notunderwater:
		bsr.w	Knuckles_HurtStop
		bsr.w	Knuckles_LevelBound
		bsr.w	Knuckles_RecordPosition
		bsr.w	Knuckles_Animate
		bsr.w	Knuckles_LoadGfx
		jmp	(DisplaySprite).l

; ---------------------------------------------------------------------------
; Subroutine to stop Knuckles falling after he's been hurt
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_HurtStop:
		move.w	(v_limitbtm2).w,d0
	if FixBugs
		; The original code does not consider that the camera boundary
		; may be in the middle of lowering itself, which is why going
		; down the S-tunnel in Green Hill Zone Act 1 fast enough can
		; kill Knuckles.
		move.w	(v_limitbtm1).w,d1
		cmp.w	d0,d1
		blo.s	.skip
		move.w	d1,d0
.skip:
	endif
		addi.w	#224,d0
		cmp.w	obY(a0),d0
		blo.w	.killKnuckles
		bsr.w	Knuckles_Floor
		btst	#1,obStatus(a0)
		bne.s	locret_13860Knuckles
		moveq	#0,d0
		move.w	d0,obVelY(a0)
		move.w	d0,obVelX(a0)
		move.w	d0,obInertia(a0)
		move.b	#$13,obHeight(a0)	; set Knuckles's hitbox to standing.
		;jsr	TailsHeight		;check if tails, if yes then load his height
		move.b	#9,obWidth(a0)	;set Knuckles's width
		move.b	#id_Walk,obAnim(a0)
		subq.b	#2,obRoutine(a0)
		move.w	#120,flashtime(a0)	; set flash time to 2 seconds
		jmp	locret_13860Knuckles
		rts
.killKnuckles:
		jmp	KillSonic

locret_13860Knuckles:
		rts
; End of function Knuckles_HurtStop

; ---------------------------------------------------------------------------
; Knuckles when he dies
; ---------------------------------------------------------------------------

; obj03_Death:
Knuckles_Death:	; Routine 6
		bsr.w	GameOverKnuckles
		jsr	(ObjectFall).l
		bsr.w	Knuckles_RecordPosition
		bsr.w	Knuckles_Animate
		bsr.w	Knuckles_LoadGfx
		jmp	(DisplaySprite).l

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


GameOverKnuckles:
	if FixBugs
		; Fix the death boundary bug
		; https://info.Knucklesretro.org/SCHG_How-to:Fix_the_death_boundary_bug
		move.w	(v_screenposy).w,d0
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bge.w	locret_13900Knuckles
	else
		move.w	(v_limitbtm2).w,d0
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bhs.w	locret_13900Knuckles
	endif
		move.w	#-$38,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		clr.b	(f_timecount).w	; stop time counter
		addq.b	#1,(f_lifecount).w ; update lives counter
		subq.b	#1,(v_lives).w	; subtract 1 from number of lives
		bne.s	loc_138D4Knuckles
		move.w	#0,restartime(a0)
		move.b	#id_GameOverCard,(v_gameovertext1).w ; load GAME object
		move.b	#id_GameOverCard,(v_gameovertext2).w ; load OVER object
		move.b	#1,(v_gameovertext2+obFrame).w ; set OVER object to correct frame
		clr.b	(f_timeover).w

loc_138C2Knuckles:
		move.w	#bgm_GameOver,d0
		jsr	(QueueSound1).l	; play game over music
		moveq	#plcid_GameOver,d0
		jsr	(AddPLC).l	; load game over patterns
		lea	(v_hud).w,a0	;move the hut to be deleted
		jsr	DeleteObject
		lea	(v_player2).w,a0	;move the 2nd player to be deleted
		jmp	DeleteObject
; ===========================================================================

loc_138D4Knuckles:
		move.w	#60,restartime(a0)	; set time delay to 1 second
		tst.b	(f_timeover).w	; is TIME OVER tag set?
		beq.s	locret_13900Knuckles	; if not, branch
		move.w	#0,restartime(a0)
		move.b	#id_GameOverCard,(v_gameovertext1).w ; load TIME object
		move.b	#id_GameOverCard,(v_gameovertext2).w ; load OVER object
		move.b	#2,(v_gameovertext1+obFrame).w
		move.b	#3,(v_gameovertext2+obFrame).w
		bra.s	loc_138C2Knuckles
; ===========================================================================

locret_13900Knuckles:
		rts
; End of function GameOver

; ---------------------------------------------------------------------------
; Knuckles when the level is restarted
; ---------------------------------------------------------------------------

; obj03_ResetLevel:
Knuckles_ResetLevel:; Routine 8
		tst.w	restartime(a0)
		beq.s	.return
		subq.w	#1,restartime(a0)	; subtract 1 from time delay
		bne.s	.return
		move.w	#1,(f_restart).w ; restart the level

.return:
		rts
; End of function Knuckles_ResetLevel

	if FixBugs
		; Fix drowning bugs
		; https://info.Knucklesretro.org/SCHG_How-to:Correct_Drowning_Bugs_in_Knuckles_1
; ---------------------------------------------------------------------------
; Knuckles when he's drowning
; ---------------------------------------------------------------------------
Knuckles_Drowned:
		jsr	SpeedToPos		; Make Knuckles able to move	originally bsr.w
		addi.w	#$10,obVelY(a0)		; Apply gravity
		bsr.w	Knuckles_RecordPosition	; Record position
		bsr.w	Knuckles_Animate		; Animate Knuckles
		bsr.w	Knuckles_LoadGfx		; Load Knuckles's DPLCs
		jmp	DisplaySprite		; And finally, display Knuckles originally bra.w
; End of function Knuckles_Drowned
	endif

; ---------------------------------------------------------------------------
; Subroutine to make Knuckles run around loops (GHZ/SLZ)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_Loops:
		cmpi.b	#id_SLZ,(v_zone).w ; is level SLZ ?
		beq.s	.isstarlight	; if yes, branch
		tst.b	(v_zone).w	; is level GHZ ?
		bne.w	.noloops	; if not, branch

.isstarlight:
		move.w	obY(a0),d0
		lsr.w	#1,d0
		andi.w	#$380,d0
		move.b	obX(a0),d1
		andi.w	#$7F,d1
		add.w	d1,d0
		lea	(v_lvllayout).w,a1
		move.b	(a1,d0.w),d1	; d1 is the 256x256 tile Knuckles is currently on

		cmp.b	(v_256roll1).w,d1 ; is Knuckles on a "roll tunnel" tile?
		beq.w	Knuckles_ChkRoll	; if yes, branch
		cmp.b	(v_256roll2).w,d1
		beq.w	Knuckles_ChkRoll

		cmp.b	(v_256loop1).w,d1 ; is Knuckles on a loop tile?
		beq.s	.chkifleft	; if yes, branch
		cmp.b	(v_256loop2).w,d1
		beq.s	.chkifinair
		bclr	#6,obRender(a0) ; return Knuckles to high plane
		rts
; ===========================================================================

.chkifinair:
		btst	#1,obStatus(a0)	; is Knuckles in the air?
		beq.s	.chkifleft	; if not, branch

		bclr	#6,obRender(a0)	; return Knuckles to high plane
		rts
; ===========================================================================

.chkifleft:
		move.w	obX(a0),d2
		cmpi.b	#$2C,d2
		bhs.s	.chkifright

		bclr	#6,obRender(a0)	; return Knuckles to high plane
		rts
; ===========================================================================

.chkifright:
		cmpi.b	#$E0,d2
		blo.s	.chkangle1

		bset	#6,obRender(a0)	; send Knuckles to low plane
		rts
; ===========================================================================

.chkangle1:
		btst	#6,obRender(a0) ; is Knuckles on low plane?
		bne.s	.chkangle2	; if yes, branch

		move.b	obAngle(a0),d1
		beq.s	.done
		cmpi.b	#$80,d1		; is Knuckles upside-down?
		bhi.s	.done		; if yes, branch
		bset	#6,obRender(a0)	; send Knuckles to low plane
		rts
; ===========================================================================

.chkangle2:
		move.b	obAngle(a0),d1
		cmpi.b	#$80,d1		; is Knuckles upright?
		bls.s	.done		; if yes, branch
		bclr	#6,obRender(a0)	; send Knuckles to high plane

.noloops:
.done:
		rts
; End of function Knuckles_Loops

; ---------------------------------------------------------------------------
; Subroutine to animate Knuckles's sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Knuckles_Animate:
.Knucklesani:
		lea	(Ani_Knuckles).l,a1
Knuckles_Animate2:
		moveq	#0,d0
		move.b	obAnim(a0),d0
		cmp.b	obPrevAni(a0),d0 ; has animation changed?
		beq.s	.do		; if not, branch
		move.b	d0,obPrevAni(a0)
		move.b	#0,obAniFrame(a0) ; reset animation
		move.b	#0,obTimeFrame(a0) ; reset frame duration

; SAnim_Do:
.do:
		add.w	d0,d0
		adda.w	(a1,d0.w),a1	; jump to appropriate animation script
		move.b	(a1),d0
		bmi.s	.walkrunroll	; if animation is walk/run/roll/jump, branch
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.s	.delay		; if time remains, branch
		move.b	d0,obTimeFrame(a0) ; load frame duration

; SAnim_Do2:
.loadframe:
		moveq	#0,d1
		move.b	obAniFrame(a0),d1 ; load current frame number
		move.b	1(a1,d1.w),d0	; read sprite number from script
		cmpi.b	#afChange,d0		; MJ: is it a flag from FD to FF?
		bhs.s	.end_FF			; MJ: if so, branch to flag routines

; SAnim_Next:
.next:
		move.b	d0,obFrame(a0)	; load sprite number
		addq.b	#1,obAniFrame(a0) ; next frame number

; SAnim_Delay:
.delay:
		rts
; ===========================================================================

; SAnim_End_FF:
.end_FF:
		addq.b	#1,d0		; is the end flag = $FF ?
		bne.s	.end_FE		; if not, branch
		move.b	#0,obAniFrame(a0) ; restart the animation
		move.b	1(a1),d0	; read sprite number
		bra.s	.next
; ===========================================================================

; SAnim_End_FE
.end_FE:
		addq.b	#1,d0		; is the end flag = $FE ?
		bne.s	.end_FD		; if not, branch
		move.b	2(a1,d1.w),d0	; read the next byte in the script
		sub.b	d0,obAniFrame(a0) ; jump back d0 bytes in the script
		sub.b	d0,d1
		move.b	1(a1,d1.w),d0	; read sprite number
		bra.s	.next
; ===========================================================================

; SAnim_End_FD:
.end_FD:
		addq.b	#1,d0		; is the end flag = $FD ?
		bne.s	.end		; if not, branch
		move.b	2(a1,d1.w),obAnim(a0) ; read next byte, run that animation

; SAnim_End:
.end:
		rts
; ===========================================================================

; SAnim_WalkRun:
.walkrunroll:
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.s	.delay		; if time remains, branch
		addq.b	#1,d0		; is animation walking/running?
		bne.w	.rolljump	; if not, branch
		moveq	#0,d1
		move.b	obAngle(a0),d0	; get Knuckles's angle
		move.b	obStatus(a0),d2
		andi.b	#1,d2		; is Knuckles mirrored horizontally?
		bne.s	.flip		; if yes, branch
		not.b	d0		; reverse angle

.flip:
		addi.b	#$10,d0		; add $10 to angle
		bpl.s	.noinvert	; if angle is $0-$7F, branch
		moveq	#3,d1

.noinvert:
		andi.b	#$FC,obRender(a0)
		eor.b	d1,d2
		or.b	d2,obRender(a0)
		btst	#5,obStatus(a0)	; is Knuckles pushing something?
		bne.w	.push		; if yes, branch

		lsr.b	#4,d0		; divide angle by $10
		andi.b	#6,d0		; angle must be 0, 2, 4 or 6
		move.w	obInertia(a0),d2 ; get Knuckles's speed
		bpl.s	.nomodspeed
		neg.w	d2		; modulus speed

.nomodspeed:
		cmpi.b	#1,(v_s1peelout).w	; check if s1 peelout flag to 1
		beq.w	.skiptonormalrun	;intentionally skip so $1000 inertia doesn't do cd anim
		lea	(KnucklesAni_RunFast).l,a1 		;use fastest running animation
		cmpi.w	#$A00,d2	; is Knuckles at higher running speed?
		bcc.s	.running	; if yes, branch
	.skiptonormalrun:
		lea	(KnucklesAni_Run).l,a1 ; use running animation
		cmpi.w	#$600,d2	; is Knuckles at running speed?
		bhs.s	.running	; if yes, branch

		lea	(KnucklesAni_Walk).l,a1 ; use walking animation
		add.b	d0,d0

.running:
		add.b	d0,d0
		move.b	d0,d3
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	.belowmax
		moveq	#0,d2		; max animation speed

.belowmax:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		bsr.w	.loadframe
		add.b	d3,obFrame(a0)	; modify frame number
		rts
;-----------------------------------------------------------------------------------------
; ===========================================================================

; SAnim_RollJump:
.rolljump:
		addq.b	#1,d0		; is animation rolling/jumping?
		bne.s	.jumptopush		; if not, branch
		move.w	obInertia(a0),d2 ; get Knuckles's speed
		bpl.s	.nomodspeed2
		neg.w	d2
		jmp	.nomodspeed2
		rts
.jumptopush:
		jmp	.push
		rts

.nomodspeed2:

.Knucklesani3:
		lea	(KnucklesAni_Roll2).l,a1 ; use fast animation
		cmpi.w	#$600,d2	; is Knuckles moving fast?
		bcc.s	.rollfast	; if yes, branch
		lea	(KnucklesAni_Roll).l,a1 ; use slower	animation
		jsr	.rollfast
		rts

.rollfast:
		neg.w	d2
		addi.w	#$400,d2
		bpl.s	.belowmax2
		moveq	#0,d2

.belowmax2:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	.loadframe
; ===========================================================================

; SAnim_Push:
.push:
		move.w	obInertia(a0),d2 ; get Knuckles's speed
		bmi.s	.negspeed
		neg.w	d2

.negspeed:
		addi.w	#$800,d2
		bpl.s	.belowmax3	
		moveq	#0,d2

.belowmax3:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
.Knucklesanipush:
		lea	(KnucklesAni_Push).l,a1
.loadanipush:

		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	.loadframe

; End of function Knuckles_Animate

		include	"_anim/Knuckles.asm"

; ---------------------------------------------------------------------------
; Knuckles graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; LoadKnucklesDynPLC:
Knuckles_LoadGfx:
	.Knucklestestanimnull:
		cmpi.b	#$FA,obFrame(a0) ; higher than $FA?
		bhi.s	.nullanim		; if yes, branch to avoid invalid animations
		bra.s	.movefromanimtest		; branch to rest of code
.nullanim
		move.b	#0,obFrame(a0)	; load sprite number
		rts
	.movefromanimtest:
		move.b	obFrame(a0),d0			; get Knuckles's current frame
		cmp.b	(v_sonframenum).w,d0		; has the frame changed?
		beq.s	.end				; if not, nothing to do
		move.b	d0,(v_sonframenum).w		; update cached frame number
	.Knucklesplc:
		lea	(KnucklesDynPLC).l,a2		; load Knuckles DPLC table
	.loadplc:
		move.w	#ArtTile_Sonic*tile_size,d4	; starting VRAM tile
	.Knucklesart:
		move.l	#Art_Knuckles,d6			; base Knuckles art pointer
	.loadart:
		jmp	(LoadDynPLC).l			; load DPLC
.end:
		rts					; return
; End of function Knuckles_LoadGfx
