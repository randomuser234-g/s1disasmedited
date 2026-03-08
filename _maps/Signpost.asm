; --------------------------------------------------------------------------------
; Sprite mappings - output from ClownMapEd - MapMacros format
; --------------------------------------------------------------------------------

.offsets:	mappingsTable
	mappingsTableEntry.w	.frame0
	mappingsTableEntry.w	.frame1
	mappingsTableEntry.w	.frame2
	mappingsTableEntry.w	.frame3
	mappingsTableEntry.w	.frame4
	mappingsTableEntry.w	.frame5

.frame0:	spriteHeader
	spritePiece -24, -16, 3, 4, 0, 0, 0, 0, 0
	spritePiece 0, -16, 3, 4, 0, 1, 0, 0, 0
	spritePiece -4, 16, 1, 2, 12, 0, 0, 0, 0
.frame0_End

.frame1:	spriteHeader
	spritePiece -16, -16, 4, 4, 0, 0, 0, 0, 0
	spritePiece -4, 16, 1, 2, 16, 0, 0, 0, 0
.frame1_End

.frame2:	spriteHeader
	spritePiece -4, -16, 1, 4, 0, 0, 0, 0, 0
	spritePiece -4, 16, 1, 2, 4, 1, 0, 0, 0
.frame2_End

.frame3:	spriteHeader
	spritePiece -16, -16, 4, 4, 0, 1, 0, 0, 0
	spritePiece -4, 16, 1, 2, 16, 1, 0, 0, 0
.frame3_End

.frame4:	spriteHeader
	spritePiece -24, -16, 3, 4, 0, 0, 0, 0, 0
	spritePiece 0, -16, 3, 4, 12, 0, 0, 0, 0
	spritePiece -4, 16, 1, 2, 24, 0, 0, 0, 0
.frame4_End

.frame5:	spriteHeader
	spritePiece -24, -16, 3, 4, 2, 0, 0, 0, 0
	spritePiece 0, -16, 3, 4, 2, 1, 0, 0, 0
	spritePiece -4, 16, 1, 2, 0, 0, 0, 0, 0
.frame5_End

	even
