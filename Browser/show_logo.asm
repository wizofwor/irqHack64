	;************* first and second row *********

	lda #60 		;wait for raster
-	cmp $d012
	bne -

	inc $d020

	lda #%11101110
	sta $d010	;sprite-x in second page

	lda #$2140/$40 	;set sprite pointers
	sta $07f8
	lda #$2180/$40
	sta $07f9
	lda #$21C0/$40
	sta $07fa
	lda #$2200/$40
	sta $07fb
	lda #$2240/$40
	sta $07fc
	lda #$2280/$40
	sta $07fd
	lda #$22c0/$40
	sta $07fe
	lda #$2300/$40
	sta $07ff

	lda #232
	sta $d000
	sta $d008
	lda #00
	sta $d002
	sta $d00a
	lda #24
	sta $d004
	sta $d00c
	lda #48
	sta $d006
	sta $d00e
	lda #65
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	lda #86
	sta $d009
	sta $d00b
	sta $d00d
	sta $d00f

	;********* third row *********
	lda #110 		;wait for raster
-	cmp $d012
	bne -

	inc $d020

	lda #%11011110
	sta $d010

	lda #$2340/$40 	;set sprite pointers
	sta $07f8
	lda #$2380/$40
	sta $07f9
	lda #$23c0/$40
	sta $07fa
	lda #$2400/$40
	sta $07fb
	lda #$2440/$40
	sta $07fc
	lda #$2480/$40 	;also for fourth row
	sta $07fd
	lda #$24c0/$40
	sta $07fe
	lda #$2500/$40
	sta $07ff

	lda #232
	sta $d000
	sta $d00a
	lda #00
	sta $d002
	sta $d00c
	lda #24
	sta $d004
	sta $d00e
	lda #48
	sta $d006
	sta $d0
	lda #72
	sta $d008
	lda #112
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	sta $d009
	lda #132
	sta $d00b
	sta $d00d
	sta $d00f

	;********* Fourth row *********

	lda #131 		;wait for raster
-	cmp $d012
	bne -

	lda #$2540/$40 	;set sprite pointers
	sta $07fb
	lda #$2580/$40
	sta $07fc

	lda #133
	sta $d007
	sta $d009

	;********* Fifth & eight row *********
	lda #154 		;wait for raster
-	cmp $d012
	bne -

	inc $d020

	lda #%1110110
	sta $d010

	lda #$25c0/$40 	;set sprite pointers
	sta $07f8
	lda #$2600/$40
	sta $07f9
	lda #$2640/$40
	sta $07fa
	lda #$2680/$40
	sta $07fb
	lda #$26c0/$40
	sta $07fc
	lda #$2700/$40 
	sta $07fd

	lda #232
	sta $d000
	sta $d006
	lda #00
	sta $d002
	sta $d008
	lda #24
	sta $d004
	sta $d00a
	lda #158
	sta $d001
	sta $d003
	sta $d005
	lda #179
	sta $d007
	sta $d009
	sta $d00b

	lda #$00
	sta $d020