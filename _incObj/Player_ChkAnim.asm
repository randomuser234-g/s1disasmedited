Player_ChkAnim:
		cmpi.b	#0,(v_character).w	; is the multiple character flag set to 0 (Sonic)?
		beq.w	Sonic_Animate	;	if yes, sonic animations
		cmpi.b	#1,(v_character).w	; is the multiple character flag set to 1 (Tails)?
		beq.w	Tails_Animate	;if yes, tails animations
		cmpi.b	#3,(v_character).w	; is the multiple character flag set to 3 (Knuckles)?
		beq.w	.knucklesanimate	;if yes, knuckles animations
		bra.w	Sonic_Animate	;sonic animations as fallback


		.knucklesanimate:
		jmp	Knuckles_Animate


		rts

Player_ChkGfx:
		cmpi.b	#0,(v_character).w	; is the multiple character flag set to 0 (Sonic)?
		beq.w	Sonic_LoadGfx	;	if yes, sonic animations
		cmpi.b	#1,(v_character).w	; is the multiple character flag set to 1 (Tails)?
		beq.w	Tails_LoadGfx	;if yes, tails animations
		cmpi.b	#3,(v_character).w	; is the multiple character flag set to 3 (Knuckles)?
		beq.w	.knucklesloadgfx	;if yes, tails animations
		bra.w	Sonic_LoadGfx	;sonic animations as fallback
		.knucklesloadgfx:
		jmp	Knuckles_LoadGfx
