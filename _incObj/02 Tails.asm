; ---------------------------------------------------------------------------
; Object 02 - Tails
; ---------------------------------------------------------------------------

; Obj02:
TailsPlayer:
		tst.w	(v_debuguse).w	; is debug mode being used?
		beq.s	Tails_Normal	; if not, branch
		jmp	(DebugMode).l
; ===========================================================================

; Obj02_Normal:
Tails_Normal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0	
		jmp	Sonic_Normal
		rts