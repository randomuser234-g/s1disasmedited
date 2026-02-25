; ----------------------------------------------------------------------------


; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_213E:
PalCycle_SuperSonic:
	move.b	(v_supersonpal).w,d0
	beq.s	.return	; return, if Sonic isn't super
	bmi.w	.normal	; branch, if fade-in is done
	subq.b	#1,d0
	bne.s	.revert	; branch for values greater than 1

	; fade from Sonic's to Super Sonic's palette
	; run frame timer
	subq.b	#1,(v_supersonpaltimer).w
	bpl.s	.return
	move.b	#3,(v_supersonpaltimer).w

	; increment palette frame and update Sonic's palette
	lea	(CyclingPal_SSTransformation).l,a0
	move.b	(v_supersonpalnum).w,d0
	addq.b	#8,(v_supersonpalnum).w	; 1 palette entry = 1 word, Sonic uses 4 shades of blue
	cmpi.b	#$30,(v_supersonpalnum).w	; has palette cycle reached the 6th frame?
	blo.s	+			; if not, branch
	move.b	#-1,(v_supersonpal).w	; mark fade-in as done
	move.b	#0,(f_playerctrl).w	; restore Sonic's movement
+
	lea	(v_palette+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
	; underwater palettes
	lea	(CyclingPal_CPZUWTransformation).l,a0
	cmpi.b	#3,(v_act).w	; is act number 3?
	beq.s	+
	cmpi.b	#1,(f_water).w	; is there water?
	bne.s	.return
	lea	(CyclingPal_ARZUWTransformation).l,a0
+	lea	(v_palette_water+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
.return:
	rts
; ===========================================================================
; loc_2188: PalCycle_SuperSonic_revert:
.revert:	; runs the fade in transition backwards
	; run frame timer
	subq.b	#1,(v_supersonpaltimer).w
	bpl.s	.return
	move.b	#3,(v_supersonpaltimer).w

	; decrement palette frame and update Sonic's palette
	lea	(CyclingPal_SSTransformation).l,a0
	move.b	(v_supersonpalnum).w,d0
	subq.b	#8,(v_supersonpalnum).w	; previous frame
	bcc.s	+			; branch, if it isn't the first frame
	move.b	#0,(v_supersonpalnum).w
	move.b	#0,(v_supersonpal).w	; stop palette cycle
+
	lea	(v_palette+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
	; underwater palettes
	lea	(CyclingPal_CPZUWTransformation).l,a0
	cmpi.b	#3,(v_act).w	; is act number 3? scrap brain zone
	beq.s	+
	cmpi.b	#1,(f_water).w	; is there water?
	bne.s	.return
	lea	(CyclingPal_ARZUWTransformation).l,a0
+	lea	(v_palette_water+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
	rts
; ===========================================================================
; loc_21E6: PalCycle_SuperSonic_normal:
.normal:
	; run frame timer
	subq.b	#1,(v_supersonpaltimer).w
	bpl.s	.return
	move.b	#7,(v_supersonpaltimer).w

	; increment palette frame and update Sonic's palette
	lea	(CyclingPal_SSTransformation).l,a0
	move.b	(v_supersonpalnum).w,d0
	addq.b	#8,(v_supersonpalnum).w	; next frame
	cmpi.b	#$78,(v_supersonpalnum).w	; is it the last frame?
	bls.s	+			; if not, branch
	move.b	#$30,(v_supersonpalnum).w	; reset frame counter (Super Sonic's normal palette cycle starts at $30. Everything before that is for the palette fade)
+
	lea	(v_palette+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
	; underwater palettes
	lea	(CyclingPal_CPZUWTransformation).l,a0
	cmpi.b	#3,(v_act).w	; is act number 3?
	beq.s	+
	cmpi.b	#1,(f_water).w	; is there water?
	bne.w	.return
	lea	(CyclingPal_ARZUWTransformation).l,a0
+	lea	(v_palette_water+4).w,a1
	move.l	(a0,d0.w),(a1)+
	move.l	4(a0,d0.w),(a1)
	rts
; End of function PalCycle_SuperSonic

; ===========================================================================
;----------------------------------------------------------------------------
;Palette for transformation to Super Sonic
;----------------------------------------------------------------------------
; Pal_2246:
CyclingPal_SSTransformation:
	BINCLUDE	"palette/Super Sonic transformation.bin"
;----------------------------------------------------------------------------
;Palette for transformation to Super Sonic while underwater in CPZ
;----------------------------------------------------------------------------
; Pal_22C6:
CyclingPal_CPZUWTransformation:
	BINCLUDE	"palette/CPZWater SS transformation.bin"
;----------------------------------------------------------------------------
;Palette for transformation to Super Sonic while underwater in ARZ
;----------------------------------------------------------------------------
; Pal_2346:
CyclingPal_ARZUWTransformation:
	BINCLUDE	"palette/ARZWater SS transformation.bin"