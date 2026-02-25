; ---------------------------------------------------------------------------
; Subroutine translating object speed to update object position
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||


SpeedToPos:
		movem.w	obVelX(a0),d0/d1	; load x and y speed
		asl.l	#8,d0			; multiply speed by $100
		add.l	d0,obX(a0)		; add to x-axis	position
		asl.l	#8,d1			; multiply speed by $100
		add.l	d1,obY(a0)		; add to y-axis	position
		rts	

; End of function SpeedToPos
