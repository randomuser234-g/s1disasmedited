Tails_Flight:
		cmpi.b	#1,(v_flighttoggle).w	; check if flight toggle is 1 (indicating no flight)
		beq.w	rts_TailsFlight
		btst	#2,obStatus(a0)		; tails is rolling?
		beq.w	rts_TailsFlight		;if not, don't fly
		move.b	(v_jpadpress2p2).w,d0
		andi.b	#btnABC,d0	; is A, B or C pressed?
		beq.s	rts_TailsFlight		;if not, don't fly
		;tst.w	(v_tailscontrol).w	;don't know how to use this correctly so disabled
		;beq.s	rts_TailsFlight
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
		move.b	#1,(f_doublejump).w
		andi.b	#$30,d0
		beq.s	.20anim
		move.b	#2,(f_doublejump).w

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
		bne.s	.noflying		;if not, don't fly
		bra.s	.flying			;otherwise fly
	.noflying:
		move.b	#0,(f_doublejump).w
		rts
	.flying:
		cmpi.b	#1,(f_doublejump).w
		bne.s	Offset_0x00DC3E
		move.b	(v_jpadhold2p2+1).w,d0
		andi.b	#$30,d0		;not sure of button value $30, doesn't get mentioned in s1 constants
		beq.s	Offset_0x00DC18
		subi.w	#$40,obVelY(a0)
		bra.s	Offset_0x00DC28

Offset_0x00DC18:
		move.b	(v_jpadhold2p2).w,d0
		andi.b	#btnA,d0		;2 flying styles, if A is held, smooth acceleration flight
		beq.s	Offset_0x00DC28		;if A isn't held, C must be pressed and will "bob" tails up in the air in multiple spirts, similar to jump
		subi.w	#$10,obVelY(a0)

Offset_0x00DC28:
		addi.w	#8,obVelY(a0)
		cmpi.w	#-$100,obVelY(a0)
		bge.s	Offset_0x00DC3C
		move.w	#-$100,obVelY(a0)

Offset_0x00DC3C:
                rts
; ---------------------------------------------------------------------------

Offset_0x00DC3E:
		move.b	(v_jpadhold2p2+1).w,d0
		andi.b	#$30,d0
		beq.s	Offset_0x00DC56
		tst.w	obVelY(a0)
		bmi.s	Offset_0x00DC6C
		subi.w	#$300,obVelY(a0)
		bra.s	Offset_0x00DC6C

Offset_0x00DC56:
		move.b	(v_jpadhold2p2).w,d0
		andi.b	#btnA,d0
		beq.s	Offset_0x00DC6C
		tst.w	obVelY(a0)
		bmi.s	Offset_0x00DC6C
		subi.w	#$200,obVelY(a0)

Offset_0x00DC6C:
		addi.w	#8,obVelY(a0)
		rts
; End of function Tails_StartFlying
