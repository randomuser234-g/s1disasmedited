; ---------------------------------------------------------------------------
; Object 02 - Tails	(placeholder, this mostly just does Sonic's code)
; ---------------------------------------------------------------------------
;top_solid_bit = 	$3E ; the bit to check for top solidity (either $C or $E)
;lrb_solid_bit =		$3F ; the bit to check for left/right/bottom solidity (either $D or $F)
;move_lock =		locktime, it's same between oil ocean slides and labyrinth
; Obj02:
TailsPlayer:
		cmpa.w	#v_player,a0	;is Tails player 1?
		bne.w	Tails_Normal;if not, don't do debug mode
		tst.w	(v_debuguse).w	; is debug mode being used?
		beq.s	Tails_Normal	; if not, branch
		jmp	(DebugMode).l
; ===========================================================================

; Obj02_Normal:
Tails_Normal:
	cmpi.w	#1,(v_character).w
	bne.s	+
	move.w	(v_limitleft2).w,(v_limitleft2tails).w
	move.w	(v_limitright2).w,(v_limitright2tails).w
	move.w	(v_limitbtm2).w,(v_limittop2tails).w
+
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
		move.b	#1<<7|1<<2,obRender(a0) ; render_flags(Tails) = $80 | initial render_flags(Sonic)
		move.b	#0,(v_super).w	; turn off Super
		move.b	#0,(v_shoes).w	; turn off speed shoes
		move.w	#$600,(v_sonspeedmax).w ; Sonic's top speed
		move.w	#$C,(v_sonspeedacc).w ; Sonic's acceleration
		move.w	#$80,(v_sonspeeddec).w ; Sonic's deceleration
		move.b	#id_TailsTails,(v_tailstails).w ; load Tails' tails object
		move.w	a0,(v_tailstails+objoff_3E).w ; set Tails' tails parent object to the character

; Obj02_Control:
Tails_Control:	; Routine 2
		cmpa.w	#v_player,a0	;is Tails player 1?
		bne.w	.player2	;if not, cpu controls
		move.w	(v_jpadhold2).w,(v_jpadhold2p2).w
		bsr.w	Sonic_PanCamera		; Run extended camera panning calculations
		tst.w	(f_debugmode).w	; is debug cheat enabled?
		beq.s	.nodebug	; if not, branch
		btst	#bitB,(v_jpadpress1).w ; is button B pressed?
		beq.s	.nodebug	; if not, branch
		move.w	#1,(v_debuguse).w ; change Sonic into a ring/item
		clr.b	(f_lockctrl).w
		rts

.nodebug:
		tst.b	(f_lockctrl).w	; are controls locked?
		bne.s	.ignorecontrols	; if yes, branch
		move.w	(v_jpadhold1).w,(v_jpadhold2p2).w ; enable joypad control
		move.w	(v_jpadhold1).w,(v_jpadhold2).w ; enable joypad control
		bra.s	.ignorecontrols
; ===========================================================================
.player2:
	tst.b	(f_lockctrlp2).w
	bne.s	+
	move.w	(v_jpadhold1p2).w,(v_jpadhold2p2).w
+
	bsr.w	TailsCPU_Control

.ignorecontrols:
		btst	#0,(f_playerctrl).w ; are controls locked?
		bne.s	.ignoremodes	; if yes, branch
		btst	#0,(f_playerctrl2).w ; are controls locked?
		bne.s	.ignoremodes	; if yes, branch
		moveq	#0,d0
		move.b	obStatus(a0),d0
		andi.w	#6,d0
		move.w	Tails_Modes(pc,d0.w),d1
		jsr	Tails_Modes(pc,d1.w)

.ignoremodes:
		bsr.s	Tails_Display
		bsr.w	Sonic_Super
		bsr.w	Tails_RecordPosition
		bsr.w	Tails_Water
		move.b	(v_anglebuffer).w,angleright(a0)
		move.b	(v_anglebuffer2).w,angleleft(a0)
		tst.b	(f_wtunnelmode).w
		beq.s	.nowindtunnel
		tst.b	obAnim(a0)
		bne.s	.nowindtunnel
		move.b	obPrevAni(a0),obAnim(a0)

.nowindtunnel:
		bsr.w	Tails_Animate
		tst.b	(f_playerctrl).w
		bmi.s	.ignoreobjcoll
		tst.b	(f_playerctrl2).w
		bmi.s	.ignoreobjcoll
		jsr	(ReactToItem).l

.ignoreobjcoll:
		bsr.w	Tails_Loops
		bsr.w	Tails_LoadGfx
		rts
; ===========================================================================
; Obj02_Modes:
Tails_Modes:	dc.w Tails_MdNormal-Tails_Modes
		dc.w Tails_MdJump-Tails_Modes
		dc.w Tails_MdRoll-Tails_Modes
		dc.w Tails_MdJump2-Tails_Modes
; ---------------------------------------------------------------------------
; Music to play after invincibility wears off
; ---------------------------------------------------------------------------
MusicList2Dup:
		dc.b bgm_GHZ
		dc.b bgm_LZ
		dc.b bgm_MZ
		dc.b bgm_SLZ
		dc.b bgm_SYZ
		dc.b bgm_SBZ
		zonewarning MusicList2Dup,1
		; The ending doesn't get an entry
		even

; ---------------------------------------------------------------------------
; Subroutine to display Tails and set music
; ---------------------------------------------------------------------------
Tails_Display:
		move.w	flashtime(a0),d0
		beq.s	.display
		subq.w	#1,flashtime(a0)
		lsr.w	#3,d0
		bcc.s	.chkinvincible

.display:
		jsr	(DisplaySprite).l

.chkinvincible:
		tst.b	(v_invinc).w	; does Sonic have invincibility?
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
		lea	(MusicList2Dup).l,a1
		move.b	(a1,d0.w),d0
		jsr	(QueueSound1).l	; play normal music

.removeinvincible:
		move.b	#0,(v_invinc).w ; cancel invincibility

.chkshoes:
		tst.b	(v_shoes).w	; does Sonic have speed shoes?
		beq.s	.exit		; if not, branch
		tst.w	shoetime(a0)	; check time remaining
		beq.s	.exit
		tst.b	(v_super).w	; is Sonic already Super?
		bne.s	.chkshoescont		; if yes, branch
		subq.w	#1,shoetime(a0)	; subtract 1 from time
		bne.s	.exit
		btst	#6,obStatus(a0)	;is Sonic underwater?
		beq.s	.normalshoes	;if not, then normal shoes speed restored
	.normalshoeswater:
		move.w	#$300,(v_sonspeedmax).w ; change Sonic's top speed
		move.w	#6,(v_sonspeedacc).w ; change Sonic's acceleration
		move.w	#$40,(v_sonspeeddec).w ; change Sonic's deceleration
		bra.s	.chkshoescont
	.normalshoes:
		move.w	#$600,(v_sonspeedmax).w ; restore Sonic's speed
		move.w	#$C,(v_sonspeedacc).w ; restore Sonic's acceleration
		move.w	#$80,(v_sonspeeddec).w ; restore Sonic's deceleration
	.chkshoescont:
		move.b	#0,(v_shoes).w	; cancel speed shoes
		move.w	#0,(v_player+shoetime).w	;remove time limit for the power-up
		move.w	#bgm_Slowdown,d0
		jmp	(QueueSound1).l	; run music at normal speed

.exit:
		rts
; ---------------------------------------------------------------------------
; Tails' AI code; rather idiotic in this version, as it only really is
; programmed to copy Sonic's inputs and make no effort to correct itself
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; loc_10F96: Tails_Control2:
TailsCPU_Control: ; a0=Tails
	move.b	(v_jpadhold2p2).w,d0	; did the real player 2 hit something?
	andi.b	#btnUp|btnDn|btnL|btnR|btnB|btnC|btnA,d0
	beq.s	+			; if not, branch
	move.w	#600,(v_tailscontrol).w ; give player 2 control for 10 seconds (minimum)
+
	lea	(v_player).w,a1 ; a1=character ; a1=Sonic
	move.w	(v_tailscpuroutine).w,d0
	move.w	TailsCPU_States(pc,d0.w),d0
	jmp	TailsCPU_States(pc,d0.w)
; ===========================================================================
; off_1BAF4:
TailsCPU_States:
	dc.w TailsCPU_Init-TailsCPU_States	; 0
	dc.w TailsCPU_Spawning-TailsCPU_States	; 2
	dc.w TailsCPU_Flying-TailsCPU_States	; 4
	dc.w TailsCPU_Normal-TailsCPU_States	; 6
	dc.w TailsCPU_Panic-TailsCPU_States	; 8

; ===========================================================================
; initial AI State
; ---------------------------------------------------------------------------
; loc_1BAFE:
TailsCPU_Init:
	move.w	#6,(v_tailscpuroutine).w	; => TailsCPU_Normal
	move.b	#$0,(f_playerctrl2).w
	move.b	#id_Walk,obAnim(a0)
	move.w	#0,obVelX(a0)
	move.w	#0,obVelY(a0)
	move.w	#0,obInertia(a0)
	move.b	#0,obStatus(a0)
	move.w	#0,(v_tailsrespawn).w
	rts
; ===========================================================================
; AI State where Tails is waiting to respawn
; ---------------------------------------------------------------------------
; loc_1BB30:
TailsCPU_Spawning:
	move.b	(v_jpadhold2p2).w,d0
	andi.b	#btnB|btnC|btnA|btnStart,d0
	bne.s	TailsCPU_Respawn
	move.w	(v_framecount).w,d0
	andi.w	#$3F,d0
	bne.s	return_1BB88
	tst.b	(f_playerctrl).w	;is Sonic frozen?
	bne.s	return_1BB88	 	;if yes, branch
	move.b	obStatus(a1),d0
	andi.b	#1<<1|1<<4|1<<6|1<<7,d0
	bne.s	return_1BB88
; loc_1BB54:
TailsCPU_Respawn:
	move.w	#4,(v_tailscpuroutine).w	; => TailsCPU_Flying
	move.w	obX(a1),d0
	move.w	d0,obX(a0)
	move.w	d0,(v_tailscputargetx).w
	move.w	obY(a1),d0
	move.w	d0,(v_tailscputargety).w
	subi.w	#$C0,d0
	move.w	d0,obY(a0)
	ori.w	#(1<<15),obGfx(a0)
	move.b	#0,spindash_flag(a0)
	move.w	#0,spindash_counter(a0)

return_1BB88:
	rts
; ===========================================================================
; AI State where Tails pretends to be a helicopter
; ---------------------------------------------------------------------------
; loc_1BB8A:
TailsCPU_Flying:
	btst	#7,obRender(a0)
	bne.s	TailsCPU_FlyingOnscreen
	addq.w	#1,(v_tailsrespawn).w
	cmpi.w	#$12C,(v_tailsrespawn).w
	blo.s	TailsCPU_Flying_Part2
	move.w	#0,(v_tailsrespawn).w
	move.w	#2,(v_tailscpuroutine).w	; => TailsCPU_Spawning
	move.b	#$81,(f_playerctrl2).w ; lock controls and disable object interaction
	move.b	#1<<1,obStatus(a0)
	move.w	#0,obX(a0)
	move.w	#0,obY(a0)
	move.b	#id_Fly,obAnim(a0)
	rts
; ---------------------------------------------------------------------------
; loc_1BBC8:
TailsCPU_FlyingOnscreen:
	move.w	#0,(v_tailsrespawn).w
; loc_1BBCE:
TailsCPU_Flying_Part2:
		move.w	(v_trackpos).w,d0
		lea	(v_tracksonic).w,a1
		sub.b	d1,d0
		lea	(a1,d0.w),a1
		move.w	(a1)+,d2			; Use previous player x_pos  d2 = earlier x position of Sonic
		move.w	(a1)+,d3			; Use previous player y_pos  d3 = earlier y position of Sonic
	move.w	d2,(v_tailscputargetx).w
	move.w	d3,(v_tailscputargety).w
	tst.b	(f_water).w
	beq.s	+
	move.w	(v_waterpos1).w,d0
	subi.w	#$10,d0
	cmp.w	(v_tailscputargety).w,d0
	bge.s	+
	move.w	d0,(v_tailscputargety).w
+
	move.w	obX(a0),d0
	sub.w	(v_tailscputargetx).w,d0
	beq.s	loc_1BC54
	mvabs.w	d0,d2
	lsr.w	#4,d2
	cmpi.w	#$C,d2
	blo.s	+
	moveq	#$C,d2
+
	mvabs.b	obVelX(a1),d1
	add.b	d1,d2
	addq.w	#1,d2
	tst.w	d0
	bmi.s	loc_1BC40P2
	bset	#0,obStatus(a0)
	cmp.w	d0,d2
	blo.s	+
	move.w	d0,d2
	moveq	#0,d0
+
	neg.w	d2
	bra.s	loc_1BC50
; ---------------------------------------------------------------------------

loc_1BC40P2:
	bclr	#0,obStatus(a0)
	neg.w	d0
	cmp.w	d0,d2
	blo.s	loc_1BC50
	move.b	d0,d2
	moveq	#0,d0

loc_1BC50:
	add.w	d2,obX(a0)

loc_1BC54:
	moveq	#1,d2
	move.w	obY(a0),d1
	sub.w	(v_tailscputargety).w,d1
	beq.s	loc_1BC68
	bmi.s	loc_1BC64
	neg.w	d2

loc_1BC64:
	add.w	d2,obY(a0)

loc_1BC68:
	lea	(v_trackstatsonic).w,a2
	move.b	2(a2,d3.w),d2
	andi.b	#$0,d2
	bne.s	return_1BCDE
	or.w	d0,d1
	bne.s	return_1BCDE
	cmpi.b	#6,(v_player+obRoutine).w	; is Sonic dead?
	blo.s	TailsCPU_Flying_SonicOK		; if not, branch
	bra.s	return_1BCDE
TailsCPU_Flying_SonicOK:
	move.w	#6,(v_tailscpuroutine).w	; => TailsCPU_Normal
	move.b	#$0,(f_playerctrl2).w
	move.b	#id_Walk,obAnim(a0)
	move.w	#0,obVelX(a0)
	move.w	#0,obVelY(a0)
	move.w	#0,obInertia(a0)
	move.b	#1<<1,obStatus(a0)
	move.w	#0,locktime(a0)
	andi.w	#$7FFF,obGfx(a0)
	tst.b	obGfx(a1)
	bpl.s	+
	ori.w	#(1<<15),obGfx(a0)
+
	;move.b	top_solid_bit(a1),top_solid_bit(a0)
	;move.b	lrb_solid_bit(a1),lrb_solid_bit(a0)
	cmpi.b	#id_SpinDash,obAnim(a1)
	beq.s	return_1BCDE
	move.b	spindash_flag(a0),d0
	beq.s	return_1BCDE
	move.b	d0,spindash_flag(a1)
	bsr.w	Tails_ChkRoll

return_1BCDE:
	rts
; ===========================================================================
; AI State where Tails follows the player normally
; ---------------------------------------------------------------------------
; loc_1BCE0:
TailsCPU_Normal:
			cmpi.b	#6,(v_player+obRoutine).w	; is Sonic dead?
	blo.s	TailsCPU_Normal_SonicOK		; if not, branch
	; Sonic's dead; fly down to his corpse
	move.w	#4,(v_tailscpuroutine).w	; => TailsCPU_Flying
	move.b	#0,spindash_flag(a0)
	move.w	#0,spindash_counter(a0)
	move.b	#$81,(f_playerctrl2).w ; lock controls and disable object interaction
	move.b	#1<<1,obStatus(a0)
	move.b	#id_Fly,obAnim(a0)
	rts
; ---------------------------------------------------------------------------
; loc_1BD0E:
TailsCPU_Normal_SonicOK:
	bsr.w	TailsCPU_CheckDespawn
	tst.w	(v_tailscontrol).w	; if CPU has control
	bne.w	TailsCPU_Normal_HumanControl		; (if not, branch)
	tst.b	(f_playerctrl2).w			; and Tails isn't fully object controlled (&$80)
	bmi.w	TailsCPU_Normal_HumanControl		; (if not, branch)
	tst.w	locktime(a0)			; and Tails' movement is locked (usually because he just fell down a slope)
	beq.s	+					; (if not, branch)
	tst.w	obInertia(a0)			; and Tails is stopped, then...
	bne.s	+					; (if not, branch)
	move.w	#8,(v_tailscpuroutine).w	; => TailsCPU_Panic
+
		move.w	(v_trackpos).w,d0
		lea	(v_tracksonic).w,a1
		sub.b	d1,d0
		lea	(a1,d0.w),a1
		move.w	(a1)+,d2			; Use previous player x_pos  d2 = earlier x position of Sonic
		move.w	(a1)+,d3			; Use previous player y_pos  d3 = earlier y position of Sonic
	lea	(v_trackstatsonic).w,a1
	move.w	(a1,d0.w),d1	; d1 = earlier input of Sonic
	move.b	2(a1,d0.w),d4	; d4 = earlier status of Sonic
	move.w	d1,d0
	btst	#5,obStatus(a0)	; is Tails pushing against something?
	beq.s	+					; if not, branch
	btst	#5,d4		; was Sonic pushing against something?
	beq.w	TailsCPU_Normal_FilterAction_Part2	; if not, branch elsewhere

; either Tails isn't pushing, or Tails and Sonic are both pushing
+	sub.w	obX(a0),d2
	beq.s	TailsCPU_Normal_Stand ; branch if Tails is already lined up horizontally with Sonic
	bpl.s	TailsCPU_Normal_FollowRight
	neg.w	d2

; Tails wants to go left because that's where Sonic is
; loc_1BD76: TailsCPU_Normal_FollowLeft:
		tst.b	(f_tailscarrysonic).w                   ; is tails flying?
                beq.s   .dontflysonic				;if not, don't do this
		btst	#bitL,(v_jpadhold2).w ; is left being pressed?
		beq.s	+
		andi.w	#~(((btnL|btnR)<<8)|(btnL|btnR)),d1	; AND out Sonic's left/right input...
		ori.w	#(btnL<<8)|btnL,d1	; ...and give Tails his own
		bra.s	+
.dontflysonic:
	cmpi.w	#$10,d2
	blo.s	+
	andi.w	#~(((btnL|btnR)<<8)|(btnL|btnR)),d1	; AND out Sonic's left/right input...
	ori.w	#(btnL<<8)|btnL,d1	; ...and give Tails his own
+
	tst.w	obInertia(a0)
	beq.s	TailsCPU_Normal_FilterAction
	btst	#0,obStatus(a0)
	beq.s	TailsCPU_Normal_FilterAction
	subq.w	#1,obX(a0)
	bra.s	TailsCPU_Normal_FilterAction
; ===========================================================================
; Tails wants to go right because that's where Sonic is
; loc_1BD98:
TailsCPU_Normal_FollowRight:
		tst.b	(f_tailscarrysonic).w                   ; is tails flying?
                beq.s   .dontflysonic				;if not, don't do this
		btst	#bitR,(v_jpadhold2).w ; is left being pressed?
		beq.s	+
		andi.w	#~(((btnL|btnR)<<8)|(btnL|btnR)),d1	; AND out Sonic's left/right input...
		ori.w	#(btnR<<8)|btnR,d1	; ...and give Tails his own
		bra.s	+
.dontflysonic:
	cmpi.w	#$10,d2
	blo.s	+
	andi.w	#~(((btnL|btnR)<<8)|(btnL|btnR)),d1	; AND out Sonic's left/right input
	ori.w	#(btnR<<8)|btnR,d1	; ...and give Tails his own
+
	tst.w	obInertia(a0)
	beq.s	TailsCPU_Normal_FilterAction
	btst	#0,obStatus(a0)
	bne.s	TailsCPU_Normal_FilterAction
	addq.w	#1,obX(a0)
	bra.s	TailsCPU_Normal_FilterAction
; ===========================================================================
; Tails is happy where he is
; loc_1BDBA:
TailsCPU_Normal_Stand:
	bclr	#0,obStatus(a0)
	move.b	d4,d0
	andi.b	#1,d0
	beq.s	TailsCPU_Normal_FilterAction
	bset	#0,obStatus(a0)

; Filter the action we chose depending on a few things
; loc_1BDCE:
TailsCPU_Normal_FilterAction:
	tst.b	(v_tailscpujump).w
	beq.s	+
	ori.w	#((btnB|btnC|btnA)<<8),d1
	btst	#1,obStatus(a0)
	bne.s	TailsCPU_Normal_SendAction
	move.b	#0,(v_tailscpujump).w
+
	move.w	(v_framecount).w,d0
	andi.w	#$FF,d0
	beq.s	+
	cmpi.w	#$40,d2
	bhs.s	TailsCPU_Normal_SendAction
+
	sub.w	obY(a0),d3
	beq.s	TailsCPU_Normal_SendAction
	bpl.s	TailsCPU_Normal_SendAction
	neg.w	d3
	cmpi.w	#$20,d3
	blo.s	TailsCPU_Normal_SendAction
; loc_1BE06:
TailsCPU_Normal_FilterAction_Part2:
	move.b	(v_framecount+1).w,d0
	andi.b	#$3F,d0
	bne.s	TailsCPU_Normal_SendAction
	cmpi.b	#id_Duck,obAnim(a0)
	beq.s	TailsCPU_Normal_SendAction
	ori.w	#((btnB|btnC|btnA)<<8)|(btnB|btnC|btnA),d1
	move.b	#1,(v_tailscpujump).w

; Send the action we chose by storing it into player 2's input
; loc_1BE22:
TailsCPU_Normal_SendAction:
	move.w	d1,(v_jpadhold2p2).w
	rts

; ===========================================================================
; Follow orders from controller 2
; and decrease the counter to when the CPU will regain control
; loc_1BE28:
TailsCPU_Normal_HumanControl:
	tst.w	(v_tailscontrol).w
	beq.s	+	; don't decrease if it's already 0
	subq.w	#1,(v_tailscontrol).w
+
	rts

; ===========================================================================
; loc_1BE34:
TailsCPU_Despawn:
	move.w	#0,(v_tailscontrol).w
	move.w	#0,(v_tailsrespawn).w
	move.w	#2,(v_tailscpuroutine).w	; => TailsCPU_Spawning
	move.b	#$81,(f_playerctrl2).w ; lock controls and disable object interaction
	move.b	#1<<1,obStatus(a0)
	move.w	#$4000,obX(a0)
	move.w	#0,obY(a0)
	move.b	#id_Fly,obAnim(a0)
	rts
; ===========================================================================
; sub_1BE66:
TailsCPU_CheckDespawn:
	btst	#7,obRender(a0)
	bne.s	TailsCPU_ResetRespawnTimer
	btst	#3,obStatus(a0)
	beq.s	TailsCPU_TickRespawnTimer

	moveq	#0,d0
	move.b	standonobject(a0),d0
    if object_size=$40
	lsl.w	#object_size_bits,d0
    else
	mulu.w	#object_size,d0
    endif
	addi.l	#v_objspace,d0
	movea.l	d0,a3	; a3=object
	move.b	(v_tailsinteract).w,d0
	cmp.b	obID(a3),d0
	bne.s	BranchTo_TailsCPU_Despawn

; loc_1BE8C:
TailsCPU_TickRespawnTimer:
	addq.w	#1,(v_tailsrespawn).w
	cmpi.w	#$12C,(v_tailsrespawn).w
	blo.s	TailsCPU_UpdateObjInteract

BranchTo_TailsCPU_Despawn ; BranchTo
	bra.w	TailsCPU_Despawn
; ===========================================================================
; loc_1BE9C:
TailsCPU_ResetRespawnTimer:
	move.w	#0,(v_tailsrespawn).w
; loc_1BEA2:
TailsCPU_UpdateObjInteract:
	moveq	#0,d0
	move.b	standonobject(a0),d0
    if object_size=$40
	lsl.w	#object_size_bits,d0
    else
	mulu.w	#object_size,d0
    endif
	addi.l	#v_objspace,d0
	movea.l	d0,a3	; a3=object
	move.b	obID(a3),(v_tailsinteract).w
	rts

; ===========================================================================
; AI State where Tails stops, drops, and spindashes in Sonic's direction
; ---------------------------------------------------------------------------
; loc_1BEB8:
TailsCPU_Panic:
	bsr.w	TailsCPU_CheckDespawn
	tst.w	(v_tailscontrol).w
	bne.w	return_1BF36
	tst.w	locktime(a0)
	bne.w	return_1BF36
	cmpi.b	#id_SpinDash,obAnim(a0) ; is this "spindash" animation?
	beq.s	.skipwaitanim	;if yes, skip check for standing animation
	cmpi.b	#id_Duck,obAnim(a0) ; is this "duck" animation?
	beq.s	.skipwaitanim	;if yes, skip check for standing animation
	cmpi.b	#id_Wait,obAnim(a0) ; is this "standing" animation?
	bne.s	return_1BF36	;if not, don't attempt spindash until you're standing, workaround for tails attempting spindash too early
	.skipwaitanim:
	cmpi.b	#1,spindash_flag(a0)	;is this spindash flag
	bne.s	TailsCPU_Panic_ChargingDash	;if not, begin charging

	tst.w	obInertia(a0)
	bne.s	return_1BF36
	bclr	#0,obStatus(a0)
	move.w	obX(a0),d0
	sub.w	obX(a1),d0
	bcs.s	+
	bset	#0,obStatus(a0)
+
	move.w	#(btnDn<<8)|btnDn,(v_jpadhold2p2).w
	move.b	(v_framecount+1).w,d0
	andi.b	#$7F,d0
	beq.s	TailsCPU_Panic_ReleaseDash

	cmpi.b	#id_Duck,obAnim(a0)
	bne.s	return_1BF36
	move.w	#((btnDn|btnB|btnC|btnA)<<8)|(btnDn|btnB|btnC|btnA),(v_jpadhold2p2).w
	rts
; ---------------------------------------------------------------------------
; loc_1BF0C:
TailsCPU_Panic_ChargingDash:
	move.w	#(btnDn<<8)|btnDn,(v_jpadhold2p2).w
	move.b	(v_framecount+1).w,d0
	andi.b	#$7F,d0
	bne.s	TailsCPU_Panic_RevDash

; loc_1BF1C:
TailsCPU_Panic_ReleaseDash:
	move.w	#0,(v_jpadhold2p2).w
	move.w	#6,(v_tailscpuroutine).w	; => TailsCPU_Normal
	rts
; ---------------------------------------------------------------------------
; loc_1BF2A:
TailsCPU_Panic_RevDash:
	andi.b	#$1F,d0
	bne.s	return_1BF36
	ori.w	#((btnB|btnC|btnA)<<8)|(btnB|btnC|btnA),(v_jpadhold2p2).w

return_1BF36:
	rts
; End of function TailsCPU_Control

; ---------------------------------------------------------------------------
; Subroutine to record Tails' previous positions for invincibility stars
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Sonic_RecordPos:
Tails_RecordPosition:
		move.w	(v_trackpos).w,d0
		lea	(v_tracksonic).w,a1
		lea	(a1,d0.w),a1
		move.w	obX(a0),(a1)+
		move.w	obY(a0),(a1)+
		addq.b	#4,(v_trackbyte).w
		rts
; End of function Tails_RecordPosition
; ---------------------------------------------------------------------------
; Subroutine for Tails when he's underwater
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_Water:
		cmpi.b	#1,(f_water).w	; is there water?
		beq.s	.islabyrinth	; if yes, branch

.exit:
		rts
; ===========================================================================

; Obj02_InWater:
.islabyrinth:
		move.w	(v_waterpos1).w,d0
		cmp.w	obY(a0),d0	; is Tails above the water?
		bge.s	.abovewater	; if yes, branch
		bset	#6,obStatus(a0)
		bne.s	.exit
		bsr.w	ResumeMusic
		move.b	#id_DrownCount,(v_sonicbubbles).w ; load bubbles object from Sonic's mouth
		move.b	#$81,(v_sonicbubbles+obSubtype).w
		tst.b	(v_super).w	; is Sonic Super?
		bne.s	.skipspeedslow		; if yes, branch
		tst.b	(v_shoes).w	; does Sonic have speed shoes?
		bne.s	.skipspeedslow		; if yes, branch
		move.w	#$300,(v_sonspeedmax).w ; change Sonic's top speed
		move.w	#6,(v_sonspeedacc).w ; change Sonic's acceleration
		move.w	#$40,(v_sonspeeddec).w ; change Sonic's deceleration
	.skipspeedslow:
		asr	obVelX(a0)
		asr	obVelY(a0)
		asr	obVelY(a0)	; slow Sonic
		beq.s	.exit		; branch if Sonic stops moving
		move.b	#id_Splash,(v_splash).w ; load splash object
		move.w	#sfx_Splash,d0
		jmp	(QueueSound2).l	 ; play splash sound
; ===========================================================================

; Obj01_OutWater:
.abovewater:
		bclr	#6,obStatus(a0)
		beq.s	.exit
		bsr.w	ResumeMusic
		tst.b	(v_super).w	; is Tails Super?
		bne.s	.speedshoesexitwater		; if yes, branch
		tst.b	(v_shoes).w	; does Sonic have speed shoes?
		bne.s	.speedshoesexitwater		; if yes, branch
		move.w	#$600,(v_sonspeedmax).w ; restore Sonic's speed
		move.w	#$C,(v_sonspeedacc).w ; restore Sonic's acceleration
		move.w	#$80,(v_sonspeeddec).w ; restore Sonic's deceleration
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
; End of function Tails_Water
; ===========================================================================
; ---------------------------------------------------------------------------
; Modes for controlling Tails
; ---------------------------------------------------------------------------

; Obj02_MdNormal:
Tails_MdNormal:
		bsr.w	TailsSetHeight
		bsr.w	Tails_SpinDash
		;bsr.w	Sonic_Peelout
		bsr.w	Tails_Jump
		bsr.w	Tails_SlopeResist
		bsr.w	Tails_Move
		bsr.w	Tails_Roll
		bsr.w	Tails_LevelBound
		jsr	(SpeedToPos).l
		bsr.w	Sonic_AnglePos	;sonic code
		bsr.w	Tails_SlopeRepel
		rts
; ===========================================================================

; Obj02_MdJump:
Tails_MdJump:	;flying thing here
                tst.b   (f_doublejumpp2).w                    ; is tails flying?
                bne.s   .flying				;if yes, do this
		move.b	#0,(f_tailscarrysonic).w
		bsr.w	Tails_JumpHeight
		bsr.w	Tails_JumpDirection
		bsr.w	Tails_LevelBound
		jsr	(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	.notunderwater
		subi.w	#$28,obVelY(a0)

.notunderwater:
		bsr.w	Tails_JumpAngle
		bsr.w	Tails_Floor
		rts
;Offset_0x00DBC2
.flying:
		bsr.w	Tails_StartFlying
                bsr     Tails_JumpDirection                       ; Offset_0x00E0EC
                bsr     Tails_LevelBound                  ; Offset_0x00E17C
                jsr     (SpeedToPos)                           ; Offset_0x01111E
                bsr     Tails_JumpAngle                        ; Offset_0x00E590
                movem.l A4-A6, -(A7)
                bsr     Tails_Floor                            ; Offset_0x00E5F0
                movem.l (A7)+, A4-A6
		;where carrying sonic data would be
		cmpa.w	#v_player,a0	;is Tails player 1?
		beq.w	.dontflysonic	;if yes, don't fly sonic
		lea	(v_player).w,a1 ; a1=character
		move.w	(v_jpadhold1p2).w,d0
		jsr	Tails_CarrySonic
		rts
	.dontflysonic:
	btst	#bitDn,(v_jpadhold2p2).w ; is down being pressed?
	beq.s	.end	; if not, branch
	move.b	#id_Roll,(v_player+obAnim).w ; use "jumping" animation, flight cancel
	.end:
		rts
; ===========================================================================

; Obj02_MdRoll:
Tails_MdRoll:
		bsr.w	Tails_Jump
		bsr.w	Tails_RollRepel
		bsr.w	Tails_RollSpeed
		bsr.w	Tails_LevelBound
		jsr	(SpeedToPos).l
		bsr.w	Sonic_AnglePos	;sonic code
		bsr.w	Tails_SlopeRepel
		rts
; ===========================================================================

; Obj02_MdJump2:
Tails_MdJump2:
		bsr.w	Tails_JumpHeight
		bsr.w	Tails_JumpDirection
		bsr.w	Tails_LevelBound
		jsr	(ObjectFall).l
		btst	#6,obStatus(a0)
		beq.s	.notunderwater
		subi.w	#$28,obVelY(a0)

.notunderwater:
		bsr.w	Tails_JumpAngle
		bsr.w	Tails_Floor
		rts


; ---------------------------------------------------------------------------
; Subroutine to make Tails walk/run
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Tails_Move:
		move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		move.w	(v_sonspeeddec).w,d4
		tst.b	(f_slidemode).w
		bne.w	loc_12FEEDup
		tst.w	locktime(a0)	; is Sonic's D-Pad input temporarily locked?
		bne.w	Tails_ResetScr	; if yes, ignore D-Pad input
		btst	#bitL,(v_jpadhold2p2).w ; is left being pressed?
		beq.s	.notleft	; if not, branch
		bsr.w	Tails_MoveLeft

.notleft:
		btst	#bitR,(v_jpadhold2p2).w ; is right being pressed?
		beq.s	.notright	; if not, branch
		bsr.w	Tails_MoveRight

.notright:
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0		; is Sonic on a slope?
		bne.w	Tails_ResetScr	; if yes, branch
		tst.w	obInertia(a0)	; is Sonic moving?
		bne.w	Tails_ResetScr	; if yes, branch
		bclr	#5,obStatus(a0)
		move.b	#id_Wait,obAnim(a0) ; use "standing" animation
		btst	#3,obStatus(a0)
		beq.s	Tails_Balance
		moveq	#0,d0
		move.b	standonobject(a0),d0
		lsl.w	#object_size_bits,d0
		lea	(v_objspace).w,a1
		lea	(a1,d0.w),a1
		tst.b	obStatus(a1)
		bmi.s	Tails_LookUp
		moveq	#0,d1
		move.b	obActWid(a1),d1
		move.w	d1,d2
		add.w	d2,d2
		subq.w	#4,d2
		add.w	obX(a0),d1
		sub.w	obX(a1),d1
		cmpi.w	#4,d1
		blt.s	loc_12F6ADup
		cmp.w	d2,d1
		bge.s	loc_12F5ADup
		bra.s	Tails_LookUp
; ===========================================================================
Tails_Balance:
		jsr	(ObjFloorDist).l
		cmpi.w	#$C,d1
		blt.s	Tails_LookUp
		cmpi.b	#3,angleright(a0)
		bne.s	loc_12F62Dup

loc_12F5ADup:
		bclr	#0,obStatus(a0)
		bra.s	loc_12F70Dup
; ===========================================================================

loc_12F62Dup:
		cmpi.b	#3,angleleft(a0)
		bne.s	Tails_LookUp

loc_12F6ADup:
		bset	#0,obStatus(a0)

loc_12F70Dup:
		move.b	#id_Balance,obAnim(a0) ; use "balancing" animation
		bra.s	Tails_ResetScr
; ===========================================================================

Tails_LookUp:
		btst	#bitUp,(v_jpadhold2p2).w ; is up being pressed?
		beq.s	Tails_Duck	; if not, branch
		move.b	#id_LookUp,obAnim(a0) ; use "looking up" animation
		cmpi.w	#$C8,(v_lookshift).w
		beq.s	loc_12FC2Dup
		addq.w	#2,(v_lookshift).w
		bra.s	loc_12FC2Dup
; ===========================================================================

Tails_Duck:
		btst	#bitDn,(v_jpadhold2p2).w ; is down being pressed?
		beq.s	Tails_ResetScr	; if not, branch
		move.b	#id_Duck,obAnim(a0) ; use "ducking" animation
		cmpi.w	#8,(v_lookshift).w
		beq.s	loc_12FC2Dup
		subq.w	#2,(v_lookshift).w
		bra.s	loc_12FC2Dup
; ===========================================================================

; Obj02_ResetScr
Tails_ResetScr:
		cmpi.w	#$60,(v_lookshift).w ; is screen in its default position?
		beq.s	loc_12FC2Dup	; if yes, branch
		bcc.s	loc_12FBEDup
		addq.w	#4,(v_lookshift).w ; move screen back to default

loc_12FBEDup:
		subq.w	#2,(v_lookshift).w ; move screen back to default

loc_12FC2Dup:
		move.b	(v_jpadhold2p2).w,d0
		andi.b	#btnL+btnR,d0	; is left/right pressed?
		bne.s	loc_12FEEDup	; if yes, branch
		move.w	obInertia(a0),d0
		beq.s	loc_12FEEDup
		bmi.s	loc_12FE2Dup
		sub.w	d5,d0
		bcc.s	loc_12FDCDup
		move.w	#0,d0

loc_12FDCDup:
		move.w	d0,obInertia(a0)
		bra.s	loc_12FEEDup
; ===========================================================================

loc_12FE2Dup:
		add.w	d5,d0
		bcc.s	loc_12FEADup
		move.w	#0,d0

loc_12FEADup:
		move.w	d0,obInertia(a0)

loc_12FEEDup:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		move.w	d1,obVelX(a0)
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)

loc_1300CDup:
		move.b	obAngle(a0),d0
		addi.b	#$40,d0
		bmi.s	locret_1307CDup
		move.b	#$40,d1
		tst.w	obInertia(a0)
		beq.s	locret_1307CDup
		bmi.s	loc_13024Dup
		neg.w	d1

loc_13024Dup:
		move.b	obAngle(a0),d0
		add.b	d1,d0
		move.w	d0,-(sp)
		bsr.w	Sonic_WalkSpeed	;sonic code
		move.w	(sp)+,d0
		tst.w	d1
		bpl.s	locret_1307CDup
		asl.w	#8,d1
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	loc_13078Dup
		cmpi.b	#$40,d0
		beq.s	loc_13066Dup
		cmpi.b	#$80,d0
		beq.s	loc_13060Dup
		add.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts
; ===========================================================================

loc_13060Dup:
		sub.w	d1,obVelY(a0)
		rts
; ===========================================================================

loc_13066Dup:
		sub.w	d1,obVelX(a0)
		bset	#5,obStatus(a0)
		move.w	#0,obInertia(a0)
		rts
; ===========================================================================

loc_13078Dup:
		add.w	d1,obVelY(a0)

locret_1307CDup:
		rts
; End of function Tails_Move

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

Tails_MoveLeft:
		btst	#2,obStatus(a0)	; is Sonic already rolling?
		bne.s	locret_130E8Dup		; if yes, branch
		move.w	obInertia(a0),d0
		beq.s	loc_13086Dup
		bpl.s	loc_130B2Dup

loc_13086Dup:
		bset	#0,obStatus(a0)
		bne.s	loc_1309ADup
		bclr	#5,obStatus(a0)
		move.b	#id_Run,obPrevAni(a0) ; restart Sonic's animation

loc_1309ADup:
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_130A6Dup
		add.w	d5,d0	; remove this frame's acceleration change
		cmp.w	d1,d0	; compare speed with top speed
		ble.s	loc_130A6Dup; if speed was already greater than the maximum, branch
		move.w	d1,d0

loc_130A6Dup:
		move.w	d0,obInertia(a0)
		move.b	#id_Walk,obAnim(a0) ; use walking animation
		rts
; ===========================================================================

loc_130B2Dup:
		sub.w	d4,d0
		bcc.s	loc_130BADup
		move.w	#-$80,d0

loc_130BADup:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_130E8Dup
		cmpi.w	#$400,d0
		blt.s	locret_130E8Dup
		move.b	#id_Stop,obAnim(a0) ; use "stopping" animation
		bclr	#0,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr	(QueueSound2).l	; play stopping sound

locret_130E8Dup:
		rts
; End of function Tails_MoveLeft

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_MoveRight:
		btst	#2,obStatus(a0)	; is Sonic already rolling?
		bne.s	locret_1314EDup		; if yes, branch
		move.w	obInertia(a0),d0
		bmi.s	loc_13118Dup
		bclr	#0,obStatus(a0)
		beq.s	loc_13104Dup
		bclr	#5,obStatus(a0)
		move.b	#id_Run,obPrevAni(a0) ; restart Sonic's animation

loc_13104Dup:
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	loc_1310CDup
		sub.w	d5,d0	; remove this frame's acceleration change
		cmp.w	d1,d0	; compare speed with top speed
		bge.s	loc_1310CDup; if speed was already greater than the maximum, branch
		move.w	d6,d0

loc_1310CDup:
		move.w	d0,obInertia(a0)
		move.b	#id_Walk,obAnim(a0) ; use walking animation
		rts
; ===========================================================================

loc_13118Dup:
		add.w	d4,d0
		bcc.s	loc_13120Dup
		move.w	#$80,d0

loc_13120Dup:
		move.w	d0,obInertia(a0)
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		bne.s	locret_1314EDup
		cmpi.w	#-$400,d0
		bgt.s	locret_1314EDup
		move.b	#id_Stop,obAnim(a0) ; use "stopping" animation
		bset	#0,obStatus(a0)
		move.w	#sfx_Skid,d0
		jsr	(QueueSound2).l	; play stopping sound

locret_1314EDup:
		rts
; End of function Tails_MoveRight
; ---------------------------------------------------------------------------
; Subroutine to change Tails' speed as he rolls
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_RollSpeed:
		move.w	(v_sonspeedmax).w,d6
		asl.w	#1,d6
		moveq	#6,d5	; natural roll deceleration = 1/2 normal acceleration
		move.w	(v_sonspeeddec).w,d4
		asr.w	#2,d4
		tst.b	(f_slidemode).w
		bne.w	loc_131CCDup
		tst.w	locktime(a0)	; is Sonic's D-Pad input temporarily locked?
		bne.s	.notright	; if yes, ignore D-Pad input
		btst	#bitL,(v_jpadhold2p2).w ; is left being pressed?
		beq.s	.notleft	; if not, branch
		bsr.w	Tails_RollLeft

.notleft:
		btst	#bitR,(v_jpadhold2p2).w ; is right being pressed?
		beq.s	.notright	; if not, branch
		bsr.w	Tails_RollRight

.notright:
		move.w	obInertia(a0),d0
		beq.s	loc_131AADup
		bmi.s	loc_1319EDup
		sub.w	d5,d0
		bcc.s	loc_13198Dup
		move.w	#0,d0

loc_13198Dup:
		move.w	d0,obInertia(a0)
		bra.s	loc_131AADup
; ===========================================================================

loc_1319EDup:
		add.w	d5,d0
		bcc.s	loc_131A6Dup
		move.w	#0,d0

loc_131A6Dup:
		move.w	d0,obInertia(a0)

loc_131AADup:
		tst.w	obInertia(a0)	; is Sonic moving?
		bne.s	loc_131CCDup	; if yes, branch
		bclr	#2,obStatus(a0)
		move.b	#$F,obHeight(a0)
		;jsr	TailsHeight
		move.b	#9,obWidth(a0)
		move.b	#id_Wait,obAnim(a0) ; use "standing" animation
		subq.w	#1,obY(a0)
loc_131CCDup:
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	obInertia(a0),d0
		asr.l	#8,d0
		move.w	d0,obVelY(a0)
		muls.w	obInertia(a0),d1
		asr.l	#8,d1
		cmpi.w	#$1000,d1
		ble.s	loc_131F0Dup
		move.w	#$1000,d1

loc_131F0Dup:
		cmpi.w	#-$1000,d1
		bge.s	loc_131FADup
		move.w	#-$1000,d1

loc_131FADup:
		move.w	d1,obVelX(a0)
		bra.w	loc_1300CDup
; End of function Tails_RollSpeed

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_RollLeft:
		move.w	obInertia(a0),d0
		beq.s	loc_1320ADup
		bpl.s	loc_13218Dup

loc_1320ADup:
		bset	#0,obStatus(a0)
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		rts
; ===========================================================================

loc_13218Dup:
		sub.w	d4,d0
		bcc.s	loc_13220Dup
		move.w	#-$80,d0

loc_13220Dup:
		move.w	d0,obInertia(a0)
		rts
; End of function Tails_RollLeft
; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_RollRight:
		move.w	obInertia(a0),d0
		bmi.s	loc_1323ADup
		bclr	#0,obStatus(a0)
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		rts
; ===========================================================================

loc_1323ADup:
		add.w	d4,d0
		bcc.s	loc_13242Dup
		move.w	#$80,d0

loc_13242Dup:
		move.w	d0,obInertia(a0)
		rts
; End of function Tails_RollRight
; ---------------------------------------------------------------------------
; Subroutine to change Tails' direction while jumping
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; Sonic_ChgJumpDir
Tails_JumpDirection:
		move.w	(v_sonspeedmax).w,d6
		move.w	(v_sonspeedacc).w,d5
		asl.w	#1,d5
		btst	#4,obStatus(a0)
		bne.s	Obj02_ResetScr2
		move.w	obVelX(a0),d0
		btst	#bitL,(v_jpadhold2p2).w ; is left being pressed?
		beq.s	loc_13278Dup	; if not, branch
		bset	#0,obStatus(a0)
		sub.w	d5,d0
		move.w	d6,d1
		neg.w	d1
		cmp.w	d1,d0
		bgt.s	loc_13278Dup
		add.w	d5,d0	; remove this frame's acceleration change
		cmp.w	d1,d0	; compare speed with top speed
		ble.s	loc_13278Dup; if speed was already greater than the maximum, branch
		move.w	d1,d0

loc_13278Dup:
		btst	#bitR,(v_jpadhold2p2).w ; is right being pressed?
		beq.s	Obj02_JumpMove	; if not, branch
		bclr	#0,obStatus(a0)
		add.w	d5,d0
		cmp.w	d6,d0
		blt.s	Obj02_JumpMove
		sub.w	d5,d0			; +++ remove this frame's acceleration change
		cmp.w	d6,d0			; +++ compare speed with top speed
		bge.s	Obj02_JumpMove		; +++ if speed was already greater than the maximum, branch
		move.w	d6,d0

Obj02_JumpMove:
		move.w	d0,obVelX(a0)	; change Sonic's horizontal speed

Obj02_ResetScr2:
		cmpi.w	#$60,(v_lookshift).w ; is the screen in its default position?
		beq.s	loc_132A4Dup	; if yes, branch
		bcc.s	loc_132A0Dup
		addq.w	#4,(v_lookshift).w

loc_132A0Dup:
		subq.w	#2,(v_lookshift).w

loc_132A4Dup:
		cmpi.w	#-$400,obVelY(a0) ; is Sonic moving faster than -$400 upwards?
		blo.s	locret_132D2Dup	; if yes, branch
		move.w	obVelX(a0),d0
		move.w	d0,d1
		asr.w	#5,d1
		beq.s	locret_132D2Dup
		bmi.s	loc_132C6Dup
		sub.w	d1,d0
		bcc.s	loc_132C0Dup
		move.w	#0,d0

loc_132C0Dup:
		move.w	d0,obVelX(a0)
		rts
; ===========================================================================

loc_132C6Dup:
		sub.w	d1,d0
		bcs.s	loc_132CEDup
		move.w	#0,d0

loc_132CEDup:
		move.w	d0,obVelX(a0)

locret_132D2Dup:
		rts
; End of function Tails_JumpDirection
; ===========================================================================
; ---------------------------------------------------------------------------
; Unused subroutine to squash Tails
; ---------------------------------------------------------------------------

Tails_SquashUnused:
		;dont

.return:
		rts
; ---------------------------------------------------------------------------
; Subroutine to prevent Sonic leaving the boundaries of a level
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_LevelBound:
		move.l	obX(a0),d1
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d1
		swap	d1
		move.w	(v_limitleft2).w,d0
		addi.w	#$10,d0
		cmp.w	d1,d0		; has Sonic touched the side boundary?
		bhi.s	.sides		; if yes, branch
		move.w	(v_limitright2).w,d0
		addi.w	#$128,d0
		tst.b	(f_lockscreen).w
		bne.s	.screenlocked
		addi.w	#$40,d0

.screenlocked:
		cmp.w	d1,d0		; has Sonic touched the side boundary?
		bls.s	.sides		; if yes, branch

.chkbottom:
		move.w	(v_limitbtm2).w,d0
	if FixBugs
		; The original code does not consider that the camera boundary
		; may be in the middle of lowering itself, which is why going
		; down the S-tunnel in Green Hill Zone Act 1 fast enough can
		; kill Sonic.
		move.w	(v_limitbtm1).w,d1
		cmp.w	d0,d1
		blo.s	.skip
		move.w	d1,d0
.skip:
	endif
		addi.w	#224,d0
		cmp.w	obY(a0),d0	; has Sonic touched the bottom boundary?
		blt.s	.bottom		; if yes, branch
		rts
; ===========================================================================

; Boundary_Bottom
.bottom:
		cmpi.w	#(id_SBZ<<8)+1,(v_zone).w ; is level SBZ2 ?
		bne.w	.kill	; if not, kill Sonic
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
		move.w	#0,obVelX(a0)	; stop Sonic moving
		move.w	#0,obInertia(a0)
		bra.s	.chkbottom
; End of function Tails_LevelBound
; ---------------------------------------------------------------------------
; Subroutine allowing Sonic to roll when he's moving
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_Roll:
		tst.b	(f_slidemode).w
		bne.s	.noroll
		move.w	obInertia(a0),d0
		bpl.s	.ispositive
		neg.w	d0

.ispositive:
		cmpi.w	#$80,d0		; is Sonic moving at $80 speed or faster?
		blo.s	.noroll		; if not, branch
		move.b	(v_jpadhold2p2).w,d0
		andi.b	#btnL+btnR,d0	; is left/right being pressed?
		bne.s	.noroll		; if yes, branch
		btst	#bitDn,(v_jpadhold2p2).w ; is down being pressed?
		bne.s	Tails_ChkRoll	; if yes, branch

; Obj02_NoRoll
.noroll:
		rts
; ===========================================================================

; Obj02_ChkRoll
Tails_ChkRoll:
		btst	#2,obStatus(a0)	; is Sonic already rolling?
		beq.s	.roll		; if not, branch
		rts
; ===========================================================================

; Obj02_DoRoll
.roll:
		bset	#2,obStatus(a0)
		move.b	#$E,obHeight(a0)
		move.b	#7,obWidth(a0)
		move.b	#id_Roll,obAnim(a0) ; use "rolling" animation
		addq.w	#1,obY(a0)
		move.w	#sfx_Roll,d0
		jsr	(QueueSound2).l	; play rolling sound
		tst.w	obInertia(a0)
		bne.s	.ismoving
		move.w	#$200,obInertia(a0) ; set inertia if 0

.ismoving:
		rts
; End of function Tails_Roll
; ---------------------------------------------------------------------------
; Subroutine allowing Tails to jump
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_Jump:
		move.b	(v_jpadpress2p2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		beq.w	.return	; if not, branch
		moveq	#0,d0
		move.b	obAngle(a0),d0
		addi.b	#$80,d0
		bsr.w	sub_14D48	;sonic code
		cmpi.w	#6,d1
		blt.w	.return
		move.w	#$680,d2	; set initial jump force.
		tst.b	(v_super).w
		beq.s	.chkunderwater
		move.w	#$800,d2	; set higher jump speed if super
	.chkunderwater:
		btst	#6,obStatus(a0)	; is Sonic underwater?
		beq.s	.notunderwater	; if not, continue.
		move.w	#$380,d2	; set underwater jump force.

.notunderwater:
		moveq	#0,d0
		move.b	obAngle(a0),d0
		subi.b	#$40,d0
		jsr	(CalcSine).l	; find the direction Sonic should jump.
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
		move.b	#$F,obHeight(a0)	; set Sonic's hitbox to standing size. This is a leftover from the victory animation in prototypes.
		;jsr	TailsHeight
		move.b	#9,obWidth(a0)
		btst	#2,obStatus(a0)	; is Sonic already in a ball state?
		bne.s	.rolljump	; if so, branch.
		move.b	#$E,obHeight(a0)	; set Sonic's hitbox to ball size.
		move.b	#7,obWidth(a0)
		move.b	#id_Roll,obAnim(a0) ; use "jumping" animation
		bset	#2,obStatus(a0)
		move.b	obHeight(a0),d0		;jump routine part grabbed from Sonic 3 (prototype), just without Obj_Height_2 and 3
		sub.b	obHeight(a0),d0
		ext.w	d0
		sub.w	d0,obY(a0)

.return:
		rts

.rolljump:
		;bset	#4,obStatus(a0)	; set roll-jump flag.
		rts
; End of function Tails_Jump

; ---------------------------------------------------------------------------
; Subroutine controlling Tails' jump height/duration
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_JumpHeight:
		tst.b	jumping(a0)	; has Sonic jumped?
		beq.s	.capyvel		; if not, just cap Y speed normally.
		move.w	#-$400,d1		; set max jump height.
		btst	#6,obStatus(a0)	; is Sonic underwater?
		beq.s	.notunderwater	; if not, continue.
		move.w	#-$200,d1		; set underwater jump height.

.notunderwater:
		cmp.w	obVelY(a0),d1	; get current y speed.
		ble.s	.tails
		move.b	(v_jpadhold2p2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		bne.s	.return	; if yes, branch
		move.w	d1,obVelY(a0)

.return:
		rts
.tails:
		jsr	Sonic_CheckGoSuper
		;jsr	Sonic_DropDash
		jsr	Tails_Flight
		rts

.capyvel:
		cmpi.w	#-$FC0,obVelY(a0)
		bge.s	.return2
		move.w	#-$FC0,obVelY(a0)

.return2:
		rts
; End of function Tails_JumpHeight
; ---------------------------------------------------------------------------
; Subroutine to slow Sonic walking up a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_SlopeResist:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#$C0,d0
		bhs.s	locret_13508Dup
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	#$20,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		beq.s	locret_13508Dup
		bmi.s	loc_13504Dup
		tst.w	d0
		beq.s	locret_13502Dup
		add.w	d0,obInertia(a0) ; change Sonic's inertia

locret_13502Dup:
		rts
; ===========================================================================

loc_13504Dup:
		add.w	d0,obInertia(a0)

locret_13508Dup:
		rts
; End of function Tails_SlopeResist
; ---------------------------------------------------------------------------
; Subroutine to push Tails down a slope while he's rolling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_RollRepel:
		move.b	obAngle(a0),d0
		addi.b	#$60,d0
		cmpi.b	#-$40,d0
		bhs.s	locret_13544Dup
		move.b	obAngle(a0),d0
		jsr	(CalcSine).l
		muls.w	#$50,d0
		asr.l	#8,d0
		tst.w	obInertia(a0)
		bmi.s	loc_1353ADup
		tst.w	d0
		bpl.s	loc_13534Dup
		asr.l	#2,d0

loc_13534Dup:
		add.w	d0,obInertia(a0)
		rts
; ===========================================================================

loc_1353ADup:
		tst.w	d0
		bmi.s	loc_13540Dup
		asr.l	#2,d0

loc_13540Dup:
		add.w	d0,obInertia(a0)

locret_13544Dup:
		rts
; End of function Tails_RollRepel

; ---------------------------------------------------------------------------
; Subroutine to push Tails down a slope
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_SlopeRepel:
		nop	
		tst.b	sticktoconvex(a0)
		bne.s	locret_13580Dup
		tst.w	locktime(a0)
		bne.s	loc_13582Dup
		move.b	obAngle(a0),d0
		addi.b	#$20,d0
		andi.b	#$C0,d0
		beq.s	locret_13580Dup
		move.w	obInertia(a0),d0
		bpl.s	loc_1356ADup
		neg.w	d0

loc_1356ADup:
		cmpi.w	#$280,d0
		bhs.s	locret_13580Dup
		clr.w	obInertia(a0)
		bset	#1,obStatus(a0)
		move.w	#30,locktime(a0)

locret_13580Dup:
		rts
; ===========================================================================

loc_13582Dup:
		subq.w	#1,locktime(a0)
		rts
; End of function Tails_SlopeRepel
; ---------------------------------------------------------------------------
; Subroutine to return Tails' angle to 0 as he jumps
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_JumpAngle:
		move.b	obAngle(a0),d0	; get Sonic's angle
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
; End of function Tails_JumpAngle
; ---------------------------------------------------------------------------
; Subroutine for Sonic to interact with the floor after jumping/falling
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_Floor:
		move.w	obVelX(a0),d1
		move.w	obVelY(a0),d2
		jsr	(CalcAngle).l
		move.b	d0,(v_unused3).w
		subi.b	#$20,d0
		move.b	d0,(v_unused4).w
		andi.b	#$C0,d0
		move.b	d0,(v_unused5).w
		cmpi.b	#$40,d0
		beq.w	loc_13680Dup
		cmpi.b	#$80,d0
		beq.w	loc_136E2Dup
		cmpi.b	#$C0,d0
		beq.w	loc_1373EDup
		bsr.w	Sonic_HitWall	;sonic code
		tst.w	d1
		bpl.s	loc_135F0Dup
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_135F0Dup:
		bsr.w	sub_14EB4	;sonic code
		tst.w	d1
		bpl.s	loc_13602Dup
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_13602Dup:
		bsr.w	Sonic_HitFloor	;sonic code
		move.b	d1,(v_unused6).w
		tst.w	d1
		bpl.s	locret_1367EDup
		move.b	obVelY(a0),d2
		addq.b	#8,d2
		neg.b	d2
		cmp.b	d2,d1
		bge.s	loc_1361EDup
		cmp.b	d2,d0
		blt.s	locret_1367EDup

loc_1361EDup:
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Tails_ResetOnFloor
		;jsr	Sonic_StartDropDash
		move.b	#id_Walk,obAnim(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_1365CDup
		move.b	d3,d0
		addi.b	#$10,d0
		andi.b	#$20,d0
		beq.s	loc_1364EDup
		asr	obVelY(a0)
		bra.s	loc_13670Dup
; ===========================================================================

loc_1364EDup:
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)
		rts
; ===========================================================================

loc_1365CDup:
		move.w	#0,obVelX(a0)
		cmpi.w	#$FC0,obVelY(a0)
		ble.s	loc_13670Dup
		move.w	#$FC0,obVelY(a0)

loc_13670Dup:
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_1367EDup
		neg.w	obInertia(a0)

locret_1367EDup:
		rts
; ===========================================================================

loc_13680Dup:
		bsr.w	Sonic_HitWall	;sonic code
		tst.w	d1
		bpl.s	loc_1369ADup
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts
; ===========================================================================

loc_1369ADup:
		bsr.w	Sonic_DontRunOnWalls	;sonic code
		tst.w	d1
		bpl.s	loc_136B4Dup
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_136B2Dup
		move.w	#0,obVelY(a0)

locret_136B2Dup:
		rts
; ===========================================================================

loc_136B4Dup:
		tst.w	obVelY(a0)
		bmi.s	locret_136E0Dup
		bsr.w	Sonic_HitFloor	;sonic code
		tst.w	d1
		bpl.s	locret_136E0Dup
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Tails_ResetOnFloor
		move.b	#id_Walk,obAnim(a0)
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_136E0Dup:
		rts
; ===========================================================================

loc_136E2Dup:
		bsr.w	Sonic_HitWall	;sonic code
		tst.w	d1
		bpl.s	loc_136F4Dup
		sub.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_136F4Dup:
		bsr.w	sub_14EB4	;sonic code
		tst.w	d1
		bpl.s	loc_13706Dup
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)

loc_13706Dup:
		bsr.w	Sonic_DontRunOnWalls	;sonic code
		tst.w	d1
		bpl.s	locret_1373CDup
		sub.w	d1,obY(a0)
		move.b	d3,d0
		addi.b	#$20,d0
		andi.b	#$40,d0
		bne.s	loc_13726Dup
		move.w	#0,obVelY(a0)
		rts
; ===========================================================================

loc_13726Dup:
		move.b	d3,obAngle(a0)
		bsr.w	Tails_ResetOnFloor
		move.w	obVelY(a0),obInertia(a0)
		tst.b	d3
		bpl.s	locret_1373CDup
		neg.w	obInertia(a0)

locret_1373CDup:
		rts
; ===========================================================================

loc_1373EDup:
		bsr.w	sub_14EB4	;sonic code
		tst.w	d1
		bpl.s	loc_13758Dup
		add.w	d1,obX(a0)
		move.w	#0,obVelX(a0)
		move.w	obVelY(a0),obInertia(a0)
		rts
; ===========================================================================

loc_13758Dup:
		bsr.w	Sonic_DontRunOnWalls	;sonic code
		tst.w	d1
		bpl.s	loc_13772Dup
		sub.w	d1,obY(a0)
		tst.w	obVelY(a0)
		bpl.s	locret_13770Dup
		move.w	#0,obVelY(a0)

locret_13770Dup:
		rts
; ===========================================================================

loc_13772Dup:
		tst.w	obVelY(a0)
		bmi.s	locret_1379EDup
		bsr.w	Sonic_HitFloor	;sonic code
		tst.w	d1
		bpl.s	locret_1379EDup
		add.w	d1,obY(a0)
		move.b	d3,obAngle(a0)
		bsr.w	Tails_ResetOnFloor
		move.b	#id_Walk,obAnim(a0)
		move.w	#0,obVelY(a0)
		move.w	obVelX(a0),obInertia(a0)

locret_1379EDup:
		rts
; End of function Tails_Floor

; ---------------------------------------------------------------------------
; Subroutine to reset Tails' mode when he lands on the floor
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_ResetOnFloor:
		btst	#4,obStatus(a0)	; is Sonic roll-jumping?
		beq.s	.notrolljump	; if not, skip.
		nop	; Unknown removed code.
		nop	
		nop	

.notrolljump:
		bclr	#5,obStatus(a0)	; clear push flag.
		bclr	#1,obStatus(a0)	; clear in-air flag.
		bclr	#4,obStatus(a0)	; clear roll-jump flag.
                move.b  #$00, (f_doublejumpp2).w              ; clear jump flag
		btst	#2,obStatus(a0)	; check if Sonic is in a ball state.
		beq.s	.notball	; if not, skip.
		bclr	#2,obStatus(a0)	; clear ball flag.
		move.b	#$F,obHeight(a0)	; set Sonic's hitbox to standing.
		move.b	#9,obWidth(a0)
		move.b	#id_Walk,obAnim(a0) ; use running/walking animation
		subq.w	#1,obY(a0)	; raise Sonic up 5 pixels so he's not inside the ground.

.notball:
		move.b	#0,jumping(a0)	; clear jump flag.
		move.w	#0,(v_itembonus).w	; clear enemy score chain.
		rts
; End of function Tails_ResetOnFloor



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
		bsr.w	Tails_HurtStop
		bsr.w	Tails_LevelBound
		bsr.w	Tails_RecordPosition
		bsr.w	Tails_Animate
		bsr.w	Tails_LoadGfx
		jmp	(DisplaySprite).l
	rts
; ---------------------------------------------------------------------------
; Subroutine to stop Tails falling after he's been hurt
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_HurtStop:
		move.w	(v_limitbtm2).w,d0
	if FixBugs
		; The original code does not consider that the camera boundary
		; may be in the middle of lowering itself, which is why going
		; down the S-tunnel in Green Hill Zone Act 1 fast enough can
		; kill Sonic.
		move.w	(v_limitbtm1).w,d1
		cmp.w	d0,d1
		blo.s	.skip
		move.w	d1,d0
.skip:
	endif
		addi.w	#224,d0
		cmp.w	obY(a0),d0
		blo.w	.killsonic
		bsr.w	Tails_Floor
		btst	#1,obStatus(a0)
		bne.s	locret_13860Dup
		moveq	#0,d0
		move.w	d0,obVelY(a0)
		move.w	d0,obVelX(a0)
		move.w	d0,obInertia(a0)
		move.b	#$F,obHeight(a0)	; set Sonic's hitbox to standing.
		;jsr	TailsHeight		;check if tails, if yes then load his height
		move.b	#9,obWidth(a0)	;set sonic's width
		move.b	#id_Walk,obAnim(a0)
		subq.b	#2,obRoutine(a0)
		move.w	#120,flashtime(a0)	; set flash time to 2 seconds
		jmp	locret_13860Dup
		rts
.killsonic:
		jmp	KillSonic

locret_13860Dup:
		rts
; End of function Tails_HurtStop

; ---------------------------------------------------------------------------
; Tails when he dies (placeholder)
; ---------------------------------------------------------------------------
; Obj02_Death
Tails_Death:	; Routine 6
		bsr.w	GameOverDup
		jsr	(ObjectFall).l
		bsr.w	Tails_RecordPosition
		bsr.w	Tails_Animate
		bsr.w	Tails_LoadGfx
		jmp	(DisplaySprite).l
		rts
; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


GameOverDup:
	cmpa.w	#v_player,a0	;is Tails player 1?
	beq.w	.gameover	;if not, cpu controls
	;move.b	#1,(Scroll_lock_P2).w
	move.b	#0,spindash_flag(a0)
	move.w	(v_limittop2tails).w,d0
	addi.w	#$100,d0
	cmp.w	obY(a0),d0
	bge.w	locret_13900Dup
	move.b	#2,obRoutine(a0)
	bra.w	TailsCPU_Despawn
.gameover:
	if FixBugs
		; Fix the death boundary bug
		; https://info.sonicretro.org/SCHG_How-to:Fix_the_death_boundary_bug
		move.w	(v_screenposy).w,d0
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bge.w	locret_13900Dup
	else
		move.w	(v_limitbtm2).w,d0
		addi.w	#$100,d0
		cmp.w	obY(a0),d0
		bhs.w	locret_13900Dup
	endif
		move.w	#-$38,obVelY(a0)
		addq.b	#2,obRoutine(a0)
		clr.b	(f_timecount).w	; stop time counter
		addq.b	#1,(f_lifecount).w ; update lives counter
		subq.b	#1,(v_lives).w	; subtract 1 from number of lives
		bne.s	loc_138D4Dup
		move.w	#0,restartime(a0)
		move.b	#id_GameOverCard,(v_gameovertext1).w ; load GAME object
		move.b	#id_GameOverCard,(v_gameovertext2).w ; load OVER object
		move.b	#1,(v_gameovertext2+obFrame).w ; set OVER object to correct frame
		clr.b	(f_timeover).w

loc_138C2Dup:
		move.w	#bgm_GameOver,d0
		jsr	(QueueSound1).l	; play game over music
		moveq	#plcid_GameOver,d0
		jsr	(AddPLC).l	; load game over patterns
		lea	(v_hud).w,a0	;move the hut to be deleted
		jmp	DeleteObject
; ===========================================================================

loc_138D4Dup:
		move.w	#60,restartime(a0)	; set time delay to 1 second
		tst.b	(f_timeover).w	; is TIME OVER tag set?
		beq.s	locret_13900Dup	; if not, branch
		move.w	#0,restartime(a0)
		move.b	#id_GameOverCard,(v_gameovertext1).w ; load TIME object
		move.b	#id_GameOverCard,(v_gameovertext2).w ; load OVER object
		move.b	#2,(v_gameovertext1+obFrame).w
		move.b	#3,(v_gameovertext2+obFrame).w
		bra.s	loc_138C2Dup
; ===========================================================================

locret_13900Dup:
		rts
; End of function GameOverDup


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
		jsr	SpeedToPos		; Make Sonic able to move
		addi.w	#$10,obVelY(a0)		; Apply gravity
		bsr.w	Tails_RecordPosition	; Record position
		bsr.w	Tails_Animate		; Animate Sonic
		bsr.w	Tails_LoadGfx		; Load Sonic's DPLCs
		jmp	DisplaySprite		; And finally, display Sonic
; End of function Tails_Drowned
	endif
		rts

; ---------------------------------------------------------------------------
; Subroutine to make Tails run around loops (GHZ/SLZ)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_Loops:
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
		move.b	(a1,d0.w),d1	; d1 is the 256x256 tile Sonic is currently on

		cmp.b	(v_256roll1).w,d1 ; is Sonic on a "roll tunnel" tile?
		beq.w	Tails_ChkRoll	; if yes, branch
		cmp.b	(v_256roll2).w,d1
		beq.w	Tails_ChkRoll

		cmp.b	(v_256loop1).w,d1 ; is Sonic on a loop tile?
		beq.s	.chkifleft	; if yes, branch
		cmp.b	(v_256loop2).w,d1
		beq.s	.chkifinair
		bclr	#6,obRender(a0) ; return Sonic to high plane
		rts
; ===========================================================================

.chkifinair:
		btst	#1,obStatus(a0)	; is Sonic in the air?
		beq.s	.chkifleft	; if not, branch

		bclr	#6,obRender(a0)	; return Sonic to high plane
		rts
; ===========================================================================

.chkifleft:
		move.w	obX(a0),d2
		cmpi.b	#$2C,d2
		bhs.s	.chkifright

		bclr	#6,obRender(a0)	; return Sonic to high plane
		rts
; ===========================================================================

.chkifright:
		cmpi.b	#$E0,d2
		blo.s	.chkangle1

		bset	#6,obRender(a0)	; send Sonic to low plane
		rts
; ===========================================================================

.chkangle1:
		btst	#6,obRender(a0) ; is Sonic on low plane?
		bne.s	.chkangle2	; if yes, branch

		move.b	obAngle(a0),d1
		beq.s	.done
		cmpi.b	#$80,d1		; is Sonic upside-down?
		bhi.s	.done		; if yes, branch
		bset	#6,obRender(a0)	; send Sonic to low plane
		rts
; ===========================================================================

.chkangle2:
		move.b	obAngle(a0),d1
		cmpi.b	#$80,d1		; is Sonic upright?
		bls.s	.done		; if yes, branch
		bclr	#6,obRender(a0)	; send Sonic to high plane

.noloops:
.done:
		rts
; End of function Tails_Loops

; ---------------------------------------------------------------------------
; Subroutine to animate Tails' sprites
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


Tails_Animate:
		lea	(Ani_Tails).l,a1	; load Tails' animations

Tails_Animate2:
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
;----------------------------------------------------------------------------------------------------------
.walkrunroll:
		subq.b	#1,obTimeFrame(a0) ; subtract 1 from frame duration
		bpl.w	.delay		; if time remains, branch
		addq.b	#1,d0		; is animation walking/running?
		bne.w	.rolljump	; if not, branch
		moveq	#0,d1
		move.b	obAngle(a0),d0	; get Sonic's angle
		move.b	obStatus(a0),d2
		andi.b	#1,d2		; is Sonic mirrored horizontally?
		bne.s	.fliptails		; if yes, branch
		not.b	d0		; reverse angle

.fliptails:
		addi.b	#$10,d0		; add $10 to angle
		bpl.s	.noinverttails	; if angle is $0-$7F, branch
		moveq	#3,d1

.noinverttails:
		andi.b	#$FC,obRender(a0)
		eor.b	d1,d2
		or.b	d2,obRender(a0)
		btst	#5,obStatus(a0)	; is Sonic pushing something?
		bne.w	.push		; if yes, branch

		lsr.b	#4,d0		; divide angle by $10
		andi.b	#6,d0		; angle must be 0, 2, 4 or 6
		move.w	obInertia(a0),d2 ; get Sonic's speed
		bpl.s	.nomodspeedtails
		neg.w	d2		; modulus speed

.nomodspeedtails:
		lea	(TlsAni_RunFast).l,a1 ; use Tails' running animation
		cmpi.w	#$700,d2	; is Tails at higher running speed?
		bcc.s	.runningtails	; if yes, branch
		lea	(TlsAni_Run).l,a1 ; use Tails' running animation
		cmpi.w	#$600,d2	; is Tails at running speed?
		bcc.s	.runningtails	; if yes, branch
		lea	(TlsAni_Walk).l,a1 ; use Tails' walking animation
		add.b	d0,d0
.runningtails:
		cmpi.w	#$700,d2	; is Tails at higher running speed?
		bcc.s	.peeloutfasttails	; if yes, branch
		add.b	d0,d0
		move.b	d0,d3
		neg.w	d2
		addi.w	#$800,d2
		bpl.s	.belowmaxtails
	.fastanimtaiks:
		moveq	#0,d2		; max animation speed

.belowmaxtails:
		lsr.w	#8,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		bsr.w	.loadframe
		add.b	d3,obFrame(a0)	; modify frame number
		rts
.peeloutfasttails:
		move.b	d0,d1	;move angle to d1
		lsr.b	#1,d1	;half	value of d1
		move.b	d1,d0	;move back to d0
		add.b	d0,d0	;multiply by itself
		move.b	d0,d3	;move to d3?
		neg.w	d2
		jsr	.belowmaxtails
		rts

; ===========================================================================

; SAnim_RollJump:
.rolljump:
		addq.b	#1,d0		; is the end flag = $FE?
		bne.w	.TAnim_GetTailFrame	; if not, branch
		move.w	obInertia(a0),d2 ; get Sonic's speed
		bpl.s	.nomodspeed2
		neg.w	d2
		jmp	.nomodspeed2
		rts
.jumptopush:
		jmp	.push
		rts

.nomodspeed2:
		lea	(TlsAni_Roll2).l,a1 ; use fast animation
		cmpi.w	#$600,d2	; is Tails moving fast?
		bcc.s	.rollfast	; if yes, branch
		lea	(TlsAni_Roll).l,a1 ; use slower	animation
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
		move.w	obInertia(a0),d2 ; get Sonic's speed
		bmi.s	.negspeed
		neg.w	d2

.negspeed:
		addi.w	#$800,d2
		bpl.s	.belowmax3	
		moveq	#0,d2

.belowmax3:
		lsr.w	#6,d2
		move.b	d2,obTimeFrame(a0) ; modify frame duration
		lea	(TlsAni_Push).l,a1
.loadanipush:

		move.b	obStatus(a0),d1
		andi.b	#1,d1
		andi.b	#$FC,obRender(a0)
		or.b	d1,obRender(a0)
		bra.w	.loadframe

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

.TAnim_GetTailFrame:				; CODE XREF: Tails_Animate+1B8j
		move.w	obVelX(a2),d1
		move.w	obVelY(a2),d2
		jsr	(CalcAngle).l
		moveq	#0,d1
		move.b	obStatus(a0),d2
		andi.b	#1,d2
		bne.s	.loc_11BA6
		not.b	d0
		bra.s	.loc_11BAA
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

.loc_11BA6:				; CODE XREF: Tails_Animate+204j
		addi.b	#$80,d0

.loc_11BAA:				; CODE XREF: Tails_Animate+208j
		addi.b	#$10,d0
		bpl.s	.loc_11BB2
		moveq	#3,d1

.loc_11BB2:				; CODE XREF: Tails_Animate+212j
		andi.b	#$FC,obRender(a0)
		eor.b	d1,d2
		or.b	d2,obRender(a0)
		lsr.b	#3,d0
		andi.b	#$C,d0
		move.b	d0,d3
		lea	(Obj05Ani_Directional).l,a1
		move.b	#3,obTimeFrame(a0)
		bsr.w	.loadframe
		add.b	d3,obFrame(a0)
		rts

; End of function Tails_Animate

TlsAniData:	include	"_anim/Tails.asm"

; ---------------------------------------------------------------------------
; Tails graphics loading subroutine
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; LoadMilesDynPLC:

Tails_LoadGfx:
		cmpi.b	#$8D,obFrame(a0) ; higher than $8D?
		bhi.s	.nullanim		; if yes, branch to avoid invalid animations
		bra.s	.movefromanimtest		; branch to rest of code
.nullanim
		move.b	#0,obFrame(a0)	; load sprite number
		rts
	.movefromanimtest:
		move.b	obFrame(a0),d0			; get Sonic's current frame
		cmp.b	(v_tlsframenum).w,d0		; has the frame changed?
		beq.s	.end				; if not, nothing to do
		move.b	d0,(v_tlsframenum).w		; update cached frame number
		lea	(MilesDynPLC).l,a2	; load Tails' DPLC
		move.w	#ArtTile_Tails*tile_size,d4	; starting VRAM tile
		move.l	#Art_Miles,d6
		jmp	(LoadDynPLC).l			; load DPLC
.end:
		rts					; return

		include	"_incObj/Tails_CarrySonic.asm"
; End of function Tails_LoadGfx
