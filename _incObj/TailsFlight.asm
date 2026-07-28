Tails_Flight:
		cmpi.b	#1,(v_flighttoggle).w	; check if flight toggle is 1 (indicating no flight)
		beq.w	rts_TailsFlight
		cmpi.b	#id_Transform,obAnim(a0)			; is Tails transforming?
		beq.w	rts_TailsFlight						;if yes, don't fly
		btst	#2,obStatus(a0)		; tails is rolling?
		beq.w	rts_TailsFlight		;if not, don't fly
		move.b	(v_jpadpress2p2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		beq.s	rts_TailsFlight		;if not, don't fly
		btst	#bitUp,(v_jpadhold2p2).w ; is up being pressed?
		bne.s	.skipcpucheck		;if yes, enable flying even with cpu
		tst.w	(v_tailscontrol).w	;is Tails CPU controlled?
		beq.s	rts_TailsFlight		;if yes, don't fly
.skipcpucheck:
		; we already checked this earlier...
		btst	#2,obStatus(a0)
		beq.s	Offset_0x00E382
		bclr	#2,obStatus(a0)
		;move.b	Obj_Height_2(a0),d1			
		;move.b	Obj_Height_3(a0),Obj_Height_2(a0)
		;move.b	Obj_Width_3(a0),Obj_Width_2(a0)
		;sub.b	Obj_Height_3(a0),d1
		;ext.w	d1
		;add.w	d1,obY(a0)
		;move.b	#id_Walk,obAnim(a0)

Offset_0x00E382:
		move.b	#1,(f_doublejumpp2).w
		andi.b	#btnB|btnC,d0
		beq.s	.20anim
		move.b	#2,(f_doublejumpp2).w

;Offset_0x00E394:
.20anim:
		move.w	#60*8,(v_flytimer).w	;8 seconds of flight
		bsr.w	Tails_SetFlyingAnimation

;Offset_0x00E39A:
rts_TailsFlight:
		rts
; End of function Tails_Flight
;---------------------------------------------------------------------------------------------------------
Tails_StartFlying:	;is tails in these flying/swimming animations?
		cmpi.b	#id_Fly,obAnim(a0)	;is tails in flying animation?
		beq.s	.flying		;if yes, fly
		cmpi.b	#id_Carry,obAnim(a0)	;is tails in flying animation?
		beq.s	.flying		;if yes, fly
		cmpi.b	#id_CarryUp,obAnim(a0)	;is tails in flying animation?
		beq.s	.flying		;if yes, fly
		cmpi.b	#id_FlyTired,obAnim(a0)	;is tails in flying animation?
		beq.s	.flying		;if yes, fly
		cmpi.b	#id_CarryTired,obAnim(a0)	;is tails in flying animation?
		beq.s	.flying		;if yes, fly
		cmpi.b	#id_Swim,obAnim(a0)	;is tails in swimming animation?
		beq.s	.flying		;if yes, fly
		cmpi.b	#id_SwimUp,obAnim(a0)	;is tails in swimming animation?
		beq.s	.flying		;if yes, fly
		cmpi.b	#id_SwimCarry,obAnim(a0)	;is tails in swimming animation?
		beq.s	.flying		;if yes, fly
		cmpi.b	#id_SwimTired,obAnim(a0)	;is tails in swimming animation?
		beq.s	.flying		;if yes, fly
	.noflying:
		;if not in the animations, do not fly
		move.b	#0,(f_doublejumpp2).w
		clr.b	(f_tailscarrysonic).w
		rts
	.flying:
		bsr.w	Tails_SetFlyingAnimation
		cmpi.b	#1,(f_doublejumpp2).w
		bne.s	FlyP1
		cmpi.w	#0,(v_flytimer).w		;out of time?
		beq.s	Tails_Speed2			;skip controls if tired
		cmpi.b	#id_SwimCarry,obAnim(a0)	;is tails in carry swim animation?
		beq.s	Tails_Speed2		;if yes, skip controls as if tired
		move.b	(v_jpadhold2p2+1).w,d0
		andi.b	#btnB|btnC,d0		;$30?
		beq.s	Tails_Speed1
		subi.w	#$40,obVelY(a0)
		bra.s	Tails_Speed2

;Offset_0x00DC18:
Tails_Speed1:
		move.b	(v_jpadhold2p2).w,d0
		andi.b	#btnA,d0		;2 flying styles, if A is held, smooth acceleration flight
		beq.s	Tails_Speed2		;if A isn't held, C must be pressed and will "bob" tails up in the air in multiple spirts, similar to jump
		subi.w	#$10,obVelY(a0)

;Offset_0x00DC28:
Tails_Speed2:
		addi.w	#8,obVelY(a0)
		cmpi.w	#-$100,obVelY(a0)
		bge.s	Fly_DoNothing
		move.w	#-$100,obVelY(a0)

;Offset_0x00DC3C:
Fly_DoNothing:
                rts
; ---------------------------------------------------------------------------

;Offset_0x00DC3E:
FlyP1:
		cmpi.w	#0,(v_flytimer).w		;out of time?
		beq.s	FlyP3				;skip controls if yes
		cmpi.b	#id_SwimCarry,obAnim(a0)	;is tails in carry swim animation?
		beq.s	FlyP3		;if yes, skip controls as if tired
		move.b	(v_jpadhold2p2+1).w,d0
		andi.b	#btnB|btnC,d0
		beq.s	FlyP2
		tst.w	obVelY(a0)
		bmi.s	FlyP3
		subi.w	#$300,obVelY(a0)
		bra.s	FlyP3

;Offset_0x00DC56:
FlyP2:
		move.b	(v_jpadhold2p2).w,d0
		andi.b	#btnA,d0
		beq.s	FlyP3
		tst.w	obVelY(a0)
		bmi.s	FlyP3
		subi.w	#$200,obVelY(a0)

;Offset_0x00DC6C:
FlyP3:
		addi.w	#8,obVelY(a0)
		rts
; End of function Tails_StartFlying
Tails_SonicControl:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnL|btnR,d0
		beq.s	.ABC
		or.b	(v_jpadhold2p2).w,d0
		move.b	d0,(v_jpadhold2p2).w
.ABC:
		move.b	(v_jpadhold2).w,d0
		andi.b	#btnA+btnB+btnC,d0	;little issue, only A responds to flying
		beq.s	.donothing
		or.b	(v_jpadhold2p2).w,d0
		move.b	d0,(v_jpadhold2p2).w
.donothing:
		rts
Tails_SetFlyingAnimation:
		cmpi.w	#0,(v_flytimer).w
		beq.s	Tails_FlyAnimNoTimer
		subq.w	#1,(v_flytimer).w
Tails_FlyAnimNoTimer:
		clr.b	(v_tailscpujump).w		;clear cpu thing, prevent spam of jump
		btst	#6,obStatus(a0)			;underwater?	
		bne.s	.underwater			;if yes, play underwater animations
		cmpi.b	#1,(f_tailscarrysonic).w		;carrying sonic?
		beq.s	.carry				;if yes, carrying animation
		cmpi.w	#0,(v_flytimer).w		;out of time?
		beq.s	.flytired			;if yes, tired animation
		move.b	#id_Fly,obAnim(a0)
.sound:
		;sound effect
		move.b	(v_framecount+1).w,d0
		addq.b	#8,d0
		andi.b	#$F,d0
		bne.s	.skipsound
		move.w	#sfx_Flying,d0
		jsr	(QueueSound2).l	; play flying sound
		rts
.carry:
		cmpi.w	#0,(v_flytimer).w		;out of time
		beq.s	.carrytired			;if yes, tired animation
		move.b	#id_Carry,obAnim(a0)
		tst.w	obVelY(a0)			;flying higher?
		bpl.s	.sound				;if not, don't do anim
		move.b	#id_CarryUp,obAnim(a0)		;otherwise, carry up animation
		bra.s	.sound
.carrytired:
		move.b	#id_CarryTired,obAnim(a0)
		rts
		
.flytired:	
		move.b	#id_FlyTired,obAnim(a0)
.skipsound:

		rts
.underwater:
		cmpi.b	#1,(f_tailscarrysonic).w		;carrying sonic?
		beq.s	.swimcarry				;if yes, carrying animation
		cmpi.w	#0,(v_flytimer).w		;out of time
		beq.s	.swimtired			;if yes, tired animation
		move.b	#id_Swim,obAnim(a0)
		tst.w	obVelY(a0)			;flying higher?
		bpl.s	.skipsound				;if not, don't do anim
		move.b	#id_SwimUp,obAnim(a0)		;otherwise, carry up animation
		rts
.swimtired:
		move.b	#id_SwimTired,obAnim(a0)
		rts
.swimcarry:
		move.b	#id_SwimCarry,obAnim(a0)	
		rts