OptionSelect:
		cmpi.w	#$1,d0		; have you selected item $1 (sonic)?
		bne.w	.tails	; if not, go to tails
		move.b	#0,(v_character).w	; set the multiple character flag to 0 (indicating Sonic)
		move.b	#sfx_Ring,d0		; put value of ring sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.tails:
		cmpi.w	#$2,d0		; have you selected item $2 (tails)?
		bne.w	.knuckles	; if not, go to knuckles
		move.b	#1,(v_character).w	; set the multiple character flag to 1 (indicating Tails)
		move.b	#sfx_Spring,d0		; put value of Spring sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.sonicandtails:
		cmpi.w	#$5,d0		; have you selected item $3 (sonic and tails)?
		bne.w	.disableflight	; if not, go to disable flight
		cmpi.b	#1,(v_havepartner).w	; already have this?
		beq.s	.turnofftails		; if yes, turn off tails
		move.b	#1,(v_havepartner).w	; set the partner flag to 1 (indicating Tails can follow)
		move.b	#sfx_Lamppost,d0		; put value of Roll sound into d0
		bsr.w	.optionplaysound
		bra.s	.knuckles
	.turnofftails:
		move.b	#0,(v_havepartner).w	; set the partner flag to 1 (indicating Tails can follow)
		move.b	#sfx_Bumper,d0		; put value of Bumper sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.knuckles:
		cmpi.w	#$3,d0		; have you selected item $4 (knuckles)?
		bne.w	.sonicandtails	; if not, go to disable flight
		move.b	#3,(v_character).w	; set the multiple character flag to 3 (indicating Knuckles)
		move.b	#sfx_HitBoss,d0		; put value of HitBoss sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.disableflight:
		cmpi.w	#$6,d0		; have you selected item $4 (disable tails' flight)?
		bne.w	.spindashdisable	; if not, do nothing
		move.b	#1,(v_flighttoggle).w	; set the flight toggle to 1 (disable tails' flight)
		move.b	#sfx_Skid,d0		; put value of teleport sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.spindashdisable:
		cmpi.w	#$7,d0		; have you selected item $5 (s1 style peelout)?
		bne.w	.peeloutdisable	; if not, do nothing
		move.b	#1,(v_spindashtoggle).w	; set the spindash toggle to 0 (enable spindash)
		move.b	#sfx_Roll,d0		; put value of Roll sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.peeloutdisable:
		cmpi.w	#$8,d0		; have you selected item $9 (disable peelout)?
		bne.w	.movesenable	; if not, do nothing
		move.b	#1,(v_peelouttoggle).w	; set the moves usability flag to 1 (indicating no moves)
		move.b	#sfx_Bumper,d0		; put value of bumper sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.movesenable:
		cmpi.w	#$9,d0		; have you selected item $8 (enable moves)?
		bne.w	.s1peelout	; if not, go to sound test
		move.b	#0,(v_flighttoggle).w	; set the flight toggle to 0 (enable tails' flight)
		move.b	#0,(v_spindashtoggle).w	; set the spindash toggle to 0 (enable spindash)
		move.b	#0,(v_peelouttoggle).w	; set the moves usability flag to 0 (enable peelout)
		move.b	#sfx_Lamppost,d0		; put value of lamppost sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.s1peelout:
		cmpi.w	#$A,d0		; have you selected item $6 (s1 style peelout)?
		bne.w	.cdpeelout	; if not, do nothing
		move.b	#1,(v_s1peelout).w	; set the moves usability flag to 1 (s1 peelout)
		move.b	#sfx_Ring,d0		; put value of Ring sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.cdpeelout:
		cmpi.w	#$B,d0		; have you selected item $7 (cd style peelout)?
		bne.w	.gotopage2	; if not, do nothing
		move.b	#0,(v_s1peelout).w	; set the moves usability flag to 1 (cd peelout)
		move.b	#sfx_Ring,d0		; put value of Ring sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.gotopage2:
		cmpi.w	#$D,d0		; have you selected item $C (go to page 2)?
		bne.w	.startgame	; if not, do nothing
		move.b	#2,(v_menupage)	;set page number 2
		move.w	#$13,(v_levselitem).w	;select "GO BACK"
		jsr	LevSelTextLoad	;reload text
		jmp	LevelSelect	;go back in code
		rts
;-----------------------------------------------------------------------------------------------------------
	.startgame:
		cmpi.w	#$13,d0		; have you selected item $13 (start game)?
		bne.w	.soundtest	; if not, go to sound test
		tst.b	(f_levselcheat).w ; check if level select code is on
		bne.w	.levsel	; if yes, do level select
		jmp	PlayLevel
;-----------------------------------------------------------------------------------------------------------
	.soundtest:
		cmpi.w	#$14,d0		; have you selected item $14 (sound test)?
		bne.w	.donothing	; if not, do nothing
		bra.w	.soundtestsel
	.donothing:
		jmp	LevelSelect
;-----------------------------------------------------------------------------------------------------------
.optionplaysound:
		jsr	QueueSound2	; jump to the subroutine that plays the sound currently in d0
		rts
.soundtestsel:
		jmp	SoundTestSelection
.levsel:
		move.b	#1,(v_menupage)
		move.w	#$0,(v_levselitem).w	;go to top of list
		jsr	LevSelTextLoad
		jmp	LevelSelect
		rts
;----------------------------------------------------------------------------------------------------------
OptionSelect2:
	.watereverywhere:
		cmpi.w	#$2,d0		; have you selected item $2 (water everywhere)?
		bne.w	.superforms	; if not, do nothing
		move.b	#2,(v_bonusfeat).w	; set the bonus feature flag to 2 (indicating water everywhere)
		move.b	#sfx_Bubble,d0		; put value of Bubble sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.superforms:
		cmpi.w	#$3,d0		; have you selected item $3 (super forms)?
		bne.w	.eggmantraps	; if not, do nothing
		move.b	#1,(v_bonusfeat).w	; set the bonus feature flag to 1 (indicating super forms)
		move.b	#sfx_Teleport,d0		; put value of Teleport sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.eggmantraps:
		cmpi.w	#$4,d0		; have you selected item $4 (eggman's traps)?
		bne.w	.disablebonuses	; if not, do nothing
		move.b	#3,(v_bonusfeat).w	; set the bonus feature flag to 3 (indicating eggman's traps)
		move.b	#sfx_Death,d0		; put value of Death sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.disablebonuses:
		cmpi.w	#$5,d0		; have you selected item $5 (disable bonuses)?
		bne.w	.goodend	; if not, do nothing
		move.b	#0,(v_bonusfeat).w	; set the bonus feature flag to 0 (indicating no bonuses)
		move.b	#sfx_Bumper,d0		; put value of Bumper sound into d0
		bsr.w	.optionplaysound
;-----------------------------------------------------------------------------------------------------------
	.goodend:
		cmpi.w	#$8,d0		; have you selected item $5 (disable bonuses)?
		bne.w	.badend	; if not, do nothing
		move.b	#6,(v_emeralds).w	;set up good ending by giving all emeralds
		bra.s	.playending		; if yes, branch
;-----------------------------------------------------------------------------------------------------------
	.badend:
		cmpi.w	#$9,d0		; have you selected item $5 (disable bonuses)?
		bne.w	.credits	; if not, do nothing
		move.b	#0,(v_emeralds).w	;set up bad ending by not having emeralds
		bra.s	.playending		; if yes, branch
;-----------------------------------------------------------------------------------------------------------
	.credits:
		cmpi.w	#$A,d0		; have you selected item $5 (disable bonuses)?
		bne.w	.goback	; if not, do nothing
		move.b	#0,(v_emeralds).w
		bra.w	.playcredits		; if yes, branch
;-----------------------------------------------------------------------------------------------------------
	.goback:
		cmpi.w	#$13,d0		; have you selected item $13 (go back)?
		bne.w	.soundtest	; if not, do nothing
		move.b	#0,(v_menupage)
		move.w	#$C,(v_levselitem).w	;reselect "GO TO PAGE 2"
		jsr	LevSelTextLoad
		jmp	LevelSelect
		rts
;-----------------------------------------------------------------------------------------------------------
	.soundtest:
		cmpi.w	#$14,d0		; have you selected item $14 (sound test)?
		bne.w	.donothing	; if not, do nothing
		bra.w	.soundtestsel
;-----------------------------------------------------------------------------------------------------------
	.donothing:
		jmp	LevelSelect
.optionplaysound:
		jsr	QueueSound2	; jump to the subroutine that plays the sound currently in d0
		rts
.soundtestsel:
		jmp	SoundTestSelection
.playending:
		move.b	#id_Ending,(v_gamemode).w ; set screen mode to $18 (Ending)
		move.w	#(id_EndZ<<8),(v_zone).w  ; set level to 0600 (good Ending)
		rts
.playcredits:
		move.b	#id_Credits,(v_gamemode).w ; set screen mode to $1C (Credits)
		move.b	#bgm_Credits,d0		; set credits music
		bsr.w	.optionplaysound		; play it
		move.w	#0,(v_creditsnum).w	; start at the first credits page
		rts