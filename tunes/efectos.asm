;#asm
; [0] Select
EFECTO0:
	defb 	$51,$1A
				defb	$5A,$0F
				defb	$3C,$0F
				defb	$1E,$0E
				defb	$2D,$E
				defb	$5A,$0B
				defb	$3C,$0B
				defb	$1E,$0A
				defb	$2D,$0A
				defb	$B4,$01
				defb	$FF
				
; [1] Start
EFECTO1:
	defb 	$25,$1C
				defb 	$3A,$0F
				defb	$2D,$0F
				defb	$E2,$0F
				defb	$BC,$0F
				defb	$96,$0D
				defb	$4B,$0D
				defb	$32,$0D
				defb 	$3A,$0D
				defb	$2D,$0D
				defb	$E2,$0D
				defb	$BC,$0D
				defb	$96,$0D
				defb	$4B,$0D
				defb	$32,$0D
				defb 	$3A,$0D
				defb	$2D,$0C
				defb	$E2,$0C
				defb	$BC,$0C
				defb	$96,$0B
				defb	$4B,$0B
				defb	$32,$0B
				defb 	$3A,$0B
				defb	$2D,$0B
				defb	$E2,$0B
				defb	$BC,$0B
				defb	$96,$0B
				defb	$4B,$0A
				defb	$32,$0A
				defb 	$3A,$0A
				defb	$2D,$09
				defb	$E2,$09
				defb	$BC,$08
				defb	$96,$08
				defb	$4B,$08
				defb	$32,$07
				defb 	$3A,$07
				defb	$2D,$06
				defb	$E2,$06
				defb	$BC,$06
				defb	$96,$05
				defb	$4B,$05
				defb	$32,$05
				defb 	$3A,$04
				defb	$2D,$04
				defb	$E2,$03
				defb	$BC,$03
				defb	$96,$03
				defb	$4B,$03
				defb	$32,$02
				defb 	$3A,$01
				defb	$2D,$01
				defb	$E2,$01
				defb	$BC,$01
				defb	$FF
				
; [2] Sartar
EFECTO2:
	defb	$E8,$1B
				defb	$B4,$0F
				defb	$A0,$0E
				defb	$90,$0D
				defb	$87,$0D
				defb	$78,$0C	
				defb	$6C,$0B	
				defb	$60,$0A	
				defb	$5A,$09
				defb	$FF	
				
; [3] Disparo 1
EFECTO3:
	defb	$1F,$0B
				defb	$5A,$0F
				defb	$3C,$0F
				defb	$1E,$0A
				defb	$2D,$0A
				defb	$5A,$05
				defb	$3C,$05
				defb	$1E,$04
				defb	$2D,$02
				defb	$B4,$01
				defb	$FF
	
; [4] Disparo 2
EFECTO4:
	defb	$1F,$0B
				defb	$AF,$0F
				defb	$8A,$0F
				defb	$71,$0F
				defb	$64,$0F
				defb	$3E,$0C
				defb	$25,$0C
				defb	$25,$0C
				defb	$25,$0C
				defb	$25,$0A
				defb	$4B,$0A
				defb	$4B,$0A
				defb	$4B,$0A
				defb	$3E,$08
				defb	$3E,$08
				defb	$3E,$08
				defb	$71,$08
				defb	$3E,$07
				defb	$25,$05
				defb	$25,$02
				defb	$FF
				
; [5] Vida
EFECTO5:
	defb	$1A,$0E
				defb	$B4,$0E
				defb	$B4,$0E
				defb	$B4,$0E
				defb	$B4,$0E
				defb	$B4,$0E
				defb	$B4,$0E
				defb	$B4,$0E
				defb	$B4,$0E	
				defb	$A0,$0E
				defb	$A0,$0E
				defb	$A0,$0E
				defb	$A0,$0E
				defb	$A0,$0E
				defb	$A0,$0E
				defb	$A0,$0E
				defb	$87,$0E
				defb	$87,$0E
				defb	$87,$0E
				defb	$87,$0E
				defb	$87,$0E
				defb	$87,$0E
				defb	$87,$0E
				defb	$87,$0E
				defb	$87,$0E		
				defb	$78,$0E
				defb	$78,$0E
				defb	$78,$0D
				defb	$78,$0D
				defb	$78,$0D
				defb	$78,$0D
				defb	$78,$0D
				defb	$78,$0D
				defb	$78,$0C
				defb	$78,$09
				defb	$78,$06
				defb	$78,$05	
				defb	$FF
				
; [6] Daño Colision Disparo
EFECTO6:
	defb 	$E8,$1B
	defb	$15,$0F
	defb	$0E,$0F
	defb	$35,$0F
	defb	$1F,$0F
	defb	$14,$0E
	defb	$64,$0E	
	defb	$36,$0D
	defb	$1D,$0D
	defb	$2F,$0C
	defb	$FF	
				
; [7] Daño Colisión Enemigo
EFECTO7:
	defb	$C3,$0E
	defb	$15,$0F
	defb	$2A,$0F
	defb 	$E8,$1B
	defb 	$80,$2B
	defb	$FF
				
; [8] Puncho
EFECTO8:
	defb 	$E8,$1B
	defb	$15,$0F
	defb	$2A,$0F
	defb	$00,$00
	defb 	$80,$0F
	defb	$FF	

; [9] Lava
EFECTO9:
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FE, $FF
defb $22, $EF
defb $01, $DF
defb $1F, $CF
defb $6F, $BF
defb $B7, $9F
defb $FF 
			
;#endasm

