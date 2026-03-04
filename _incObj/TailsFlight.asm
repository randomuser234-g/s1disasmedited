Tails_Flight:
		cmpi.b	#1,(v_flighttoggle).w	; check if flight toggle is 1 (indicating no flight)
		beq.w	rts_TailsFlight
		btst	#2,obStatus(a0)
		beq.w	rts_TailsFlight
		move.b	(v_jpadpress2p2).w,d0
		andi.b	#btnB|btnC|btnA,d0
		beq.s	rts_TailsFlight
		jsr	Tails_StartFlying
		move.b	#id_Fly,obAnim(a0)

rts_TailsFlight:
		rts

Tails_StartFlying:
		jsr	FlyP1
		move.b	(v_jpadpress2p2).w,d0
		andi.b	#btnB|btnC|btnA,d0
		beq.s	Tails_Speed1
		subi.w	#$400,obVelY(a0)
		bra.s	Tails_Speed2

Tails_Speed1:
		move.b	(v_jpadpress2p2).w,d0
		andi.b	#$40,d0
		beq.s	Tails_Speed2
		subi.w	#$100,obVelY(a0)

Tails_Speed2:
		addi.w	#8,obVelY(a0)	; apply to Y speed.
		cmpi.w	#-$300,obVelY(a0)	; apply to Y speed.
		bge.s	Fly_DoNothing
		move.w	#-$300,obVelY(a0)	; apply to Y speed.

Fly_DoNothing:
                rts
FlyP1:
		move.b	(v_jpadpress2p2).w,d0
		andi.b	#btnB|btnC|btnA,d0
		beq.s	FlyP2
		tst.w	obVelY(a0)
		bmi.s	FlyP3
		subi.w	#$3000,obVelY(a0)
		bra.s	FlyP3

FlyP2:
		move.b	(v_jpadpress2p2).w,d0
		andi.b	#btnB|btnC|btnA,d0
		beq.s	FlyP3
		tst.w	obVelY(a0)
		bmi.s	FlyP3
		subi.w	#$2000,obVelY(a0)

FlyP3:
		addi.w	#8,obVelY(a0)
		rts
; End of function Tails_StartFlying
