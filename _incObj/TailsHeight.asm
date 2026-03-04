TailsHeight:
		;cmpi.b	#1,(v_character).w	; check if the multiple character flag is 1 (indicating Tails)
		;bne.w	rts_TailsHeight		;if not, do nothing
		move.b	#$F,obHeight(a0)	; put Tails height value

rts_TailsHeight:
		rts
		
TailsRollHeight:
		;cmpi.b	#1,(v_character).w	; check if the multiple character flag is 1 (indicating Tails)
		;bne.w	rts_TailsHeight		;if not, do nothing
		subq.w	#4,obY(a0)		; Subtract the object Y to get Tails' value
		nop
		rts
Tails_HeightAfterLanding:
		;cmpi.b	#1,(v_character).w	; check if the multiple character flag is 1 (indicating Tails)
		;bne.w	rts_TailsHeight		;if not, do nothing
		addq.w	#4,obY(a0)	; lower Tails 4 pixels, leaving 1 pixel to land on ground
		rts.