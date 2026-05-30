Tails_Flight:
		cmpi.b	#1,(v_flighttoggle).w	; check if flight toggle is 1 (indicating no flight)
		beq.w	rts_TailsFlight
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
		move.b	#id_Fly,obAnim(a0)

;Offset_0x00E39A:
rts_TailsFlight:
		rts
; End of function Tails_Flight
;---------------------------------------------------------------------------------------------------------
Tails_StartFlying:
		cmpi.b	#id_Fly,obAnim(a0)	;is tails in flying animation?
		beq.s	.flying		;if yes, fly
	.noflying:
		move.b	#0,(f_doublejumpp2).w	;otherwise, stop flying
		clr.b	(f_tailscarrysonic).w
		rts
	.flying:
		move.b	(v_framecount+1).w,d0
		addq.b	#8,d0
		andi.b	#$F,d0
		bne.s	.skipsound
	move.w	#sfx_Flying,d0
	jsr	(QueueSound2).l	; play flying sound
.skipsound:
		cmpi.b	#1,(f_doublejumpp2).w
		bne.s	FlyP1
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
