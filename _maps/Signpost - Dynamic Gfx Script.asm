; --------------------------------------------------------------------------------
; Dynamic Pattern Loading Cues - output from ClownMapEd - MapMacros format
; --------------------------------------------------------------------------------

.offsets:	mappingsTable
	mappingsTableEntry.w	.frame0
	mappingsTableEntry.w	.frame1
	mappingsTableEntry.w	.frame2
	mappingsTableEntry.w	.frame3
	mappingsTableEntry.w	.frame4
	mappingsTableEntry.w	.frame5

.frame0:	dplcHeader
	dplcEntry	12, 0
	dplcEntry	2, 56
.frame0_End

.frame1:	dplcHeader
	dplcEntry	16, 12
	dplcEntry	2, 56
.frame1_End

.frame2:	dplcHeader
	dplcEntry	4, 28
	dplcEntry	2, 56
.frame2_End

.frame3:	dplcHeader
	dplcEntry	16, 12
	dplcEntry	2, 56
.frame3_End

.frame4:	dplcHeader
	dplcEntry	16, 32
	dplcEntry	10, 48
.frame4_End

.frame5:	dplcHeader
	dplcEntry	14, 56
.frame5_End

	even
