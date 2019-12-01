
; https://sites.google.com/site/wyzplayer/

; ZX PSG proPLAYER V 0.3 - WYZ 19.03.2016
;	ORG $C000

; ASSEMBLE WITH  z80asm



; THE DATA TO BE CHANGED :
; * SOUND BUFFER WHERE THE MUSIC FILE IS DECODED COMPLETELY
; * SONG NUMBER
; * SONG TABLE


PUBLIC _INICIO
_INICIO:

	CALL ROUT
		
	LD HL,PSG_REG
	LD DE,PSG_REG_SEC
	LD BC,14
	LDIR	
	CALL REPRODUCE_SONIDO
	CALL PLAY

	CALL REPRODUCE_EFECTO
	RET		
                
 ; BEFORE YOU BEGIN (WITH DI):
PUBLIC _INIT_BUFFERS
_INIT_BUFFERS:
	LD BC, $30
	LD HL, BUFFERS_CANALES
	LD (CANAL_A), HL
	ADD HL, BC
	LD (CANAL_B), HL
	ADD HL, BC
	LD (CANAL_C), HL
	ADD HL, BC
	LD (CANAL_P), HL
	RET     	

;PLAY SOUND EFFECTS
REPRODUCE_SONIDO:

	LD HL,INTERR   
	BIT 2,(HL)          ;IS THE EFFECT IS ACTIVATED?
	RET Z
	LD HL,(PUNTERO_SONIDO)
	LD A,(HL)
	CP $FF
	JR Z,FIN_SONIDO
	LD DE,(SFX_L)
	LD (DE),A
	INC HL
	LD A,(HL)
	RRCA
	RRCA
	RRCA
	RRCA
	AND 00001111B
	LD DE,(SFX_H)
	LD (DE),A
	LD A,(HL)
	AND 00001111B
	LD	DE,(SFX_V)
	LD (DE),A
                
	INC HL
	LD A,(HL)
	LD B,A
	BIT 7,A		;09.08.13 ;MORE SIGNFICANT BIT IS SIGNIFICANT ACTIVE ENVELOPES	
	JR Z,NO_ENVOLVENTES_SONIDO
	LD A,$12
	LD (DE),A
	INC	HL
	LD A,(HL)
	LD	(PSG_REG_SEC+11),A
	INC	HL
	LD A,(HL)
	LD (PSG_REG_SEC+12),A
	INC	HL
	LD A,(HL)
	CP 1
	JR Z,NO_ENVOLVENTES_SONIDO		;DO NOT WRITE THE ENVELOPE IF YOUR VALUE IS 1
	LD (PSG_REG_SEC+13),A                


NO_ENVOLVENTES_SONIDO:

	LD	A,B
	RES	7,A
	AND A
	JR Z,NO_RUIDO
	LD (PSG_REG_SEC+6),A
	LD A,(SFX_MIX)
	JR      SI_RUIDO
	
NO_RUIDO:
	XOR A
	LD (PSG_REG_SEC+6),A
	LD A,10111000B
	
SI_RUIDO:
	LD (PSG_REG_SEC+7),A
       
	INC HL
	LD (PUNTERO_SONIDO),HL
	RET
	
FIN_SONIDO:
	LD HL,INTERR
	RES 2,(HL)
	LD A,(ENVOLVENTE_BACK)		;DO NOT RESTORE THE ENVELOPE IF IT IS 0
	AND	A
	JR Z,FIN_NOPLAYER
       		;xor	a ; ***
	LD (PSG_REG_SEC+13),A			;08.13 RESTORE THE ENVELOPE AFTER THE SFX
       		
FIN_NOPLAYER:
	LD A,10111000B
	LD (PSG_REG_SEC+7),A

	RET                        
		


;SOUND BUFFER TURNS TO PSG

ROUT:
	LD A,(PSG_REG+13)			
	AND	A			;It is zero?
	JR Z,NO_BACKUP_ENVOLVENTE
	LD (ENVOLVENTE_BACK),A	;08.13 / SAVE THE ENVELOPE IN THE BACKUP


NO_BACKUP_ENVOLVENTE:
	;SOUND BUFFER TURNS TO SPECTRUM PSG

	XOR A
	
ROUT_A0:
	LD DE,0xFFBF
	LD BC,0xFFFD
	LD HL,PSG_REG_SEC
	
LOUT:
	OUT (C),A
	LD B,E
	OUTI 
	LD B,D
	INC A
	CP 13
	JR NZ,LOUT
	OUT (C),A
	LD A,(HL)
	AND A
	RET Z
	LD B,E
	OUTI
	XOR A
	LD (PSG_REG_SEC+13),A
	LD (PSG_REG+13),A
	RET


;START THE SOUND NUMBER (A)

INICIA_SONIDO:
	;CP	8		;SFX SPEECH
	;JP	Z,SLOOP		;

	LD HL,TABLA_SONIDOS
	CALL EXT_WORD
	LD (PUNTERO_SONIDO),HL
	LD HL,INTERR
	SET 2,(HL)
	RET
	
	
;PLAYER OFF
PUBLIC _PLAYER_OFF
_PLAYER_OFF:
	XOR	A			;***** IMPORTANT IF THERE IS NO MUSIC ****
	LD	(INTERR),A
	;LD	(FADE),A		;solo si hay fade out

CLEAR_PSG_BUFFER:
	LD HL,PSG_REG
	LD DE,PSG_REG+1
	LD BC,14
	LD (HL),A
	LDIR
		
	LD A,10111000B		; **** JUST IN CASE ****
	LD (PSG_REG+7),A
		
	LD HL,PSG_REG
	LD DE,PSG_REG_SEC
	LD BC,14
	LDIR		

	CALL ROUT
	RET


;LOAD A SONG
;IN:(A)=SONG NUMBER
PUBLIC _CARGA_CANCION
_CARGA_CANCION:
	LD HL,INTERR       ;LOAD SONG
		
	SET 1,(HL)          ;PLAY SONG
	LD HL,SONG
	LD (HL),A          ;NUMBER A

                

;DECODE
;IN-> INTERR 0 ON
;     SONG

;LOAD SONG YES / NO

DECODE_SONG:
	LD A,(SONG)

;READ HEAD OF THE SONG
;BYTE 0=TEMPO

	LD      HL,TABLA_SONG
	CALL    EXT_WORD
; decompress            
	ld		de, BUFFER_UNPACK
	push 	de
	push 	ix
	push 	iy
	call 	depack
	pop		iy
	pop		ix
	pop		de
	ld		hl, BUFFER_UNPACK
; finISH

	LD      A,(HL)
	LD      (TEMPO),A
	DEC	A
	LD	(TTEMPO),A
                
;HEADER BYTE 1
;[-|-|-|-|  3-1 | 0  ]
;[-|-|-|-|FX CHN|LOOP]

	INC	HL		;LOOP 1=ON/0=OFF?
	LD	A,(HL)
	BIT	0,A
	JR	Z,NPTJP0
	PUSH	HL
	LD	HL,INTERR
	SET	4,(HL)
	POP	HL
                
              
             
;CHANNEL OF RHYTHM EFFECT CHANNEL

NPTJP0:
	AND	00000110B 
	RRA
	;LD	(SELECT_CANAL_P),A

	PUSH	HL
	LD	HL,TABLA_DATOS_CANAL_SFX
	CALL    EXT_WORD
	PUSH	HL
	POP	IX
	LD	E,(IX+0)
	LD	D,(IX+1)
	LD	(SFX_L),DE

	LD	E,(IX+2)
	LD	D,(IX+3)
	LD	(SFX_H),DE

	LD	E,(IX+4)
	LD	D,(IX+5)
	LD	(SFX_V),DE

	LD	A,(IX+6)
	LD	(SFX_MIX),A
	POP	HL
		
	INC	HL		;2 BYTES RESERVED
	INC	HL
	INC	HL

;SEARCH AND SAVE START OF THE CHANNELS IN THE MUS MODULE (OPTIMIZE****************)
;ADD LOOP OFFSET

	PUSH	HL			;IX STOP OFFSETS LOOP PER CHANNEL
	POP	IX
		
	LD	DE,8		;UNTIL THE CHANNEL BEGINS A
	ADD	HL,DE
			
	LD	(PUNTERO_P_DECA),HL	;POINT START CHANNEL START
	LD	E,(IX+0)
	LD	D,(IX+1)
	ADD	HL,DE
	LD	(PUNTERO_L_DECA),HL	;STOP POINT STOP LOOP

	CALL BGICMODBC1
	LD (PUNTERO_P_DECB),HL
	LD E,(IX+2)
	LD D,(IX+3)
	ADD	HL,DE
	LD (PUNTERO_L_DECB),HL

	CALL BGICMODBC1
	LD (PUNTERO_P_DECC),HL
	LD E,(IX+4)
	LD D,(IX+5)
	ADD	HL,DE
	LD (PUNTERO_L_DECC),HL
		
	CALL BGICMODBC1
	LD (PUNTERO_P_DECP),HL
	LD E,(IX+6)
	LD D,(IX+7)
	ADD	HL,DE
	LD (PUNTERO_L_DECP),HL
		
                
;READ DATA FROM THE NOTES
;(|)(|||||) LENGTH OF NOTE

INIT_DECODER:
	LD DE,(CANAL_A)
	LD (PUNTERO_A),DE
	LD HL,(PUNTERO_P_DECA)
	CALL DECODE_CANAL    	;CHANNEL A
	LD (PUNTERO_DECA),HL
                
	LD DE,(CANAL_B)
	LD (PUNTERO_B),DE
	LD HL,(PUNTERO_P_DECB)
	CALL DECODE_CANAL    	;CHANNEL B
	LD	(PUNTERO_DECB),HL
                
	LD DE,(CANAL_C)
	LD (PUNTERO_C),DE
	LD HL,(PUNTERO_P_DECC)
	CALL DECODE_CANAL    	;CHANNEL C
	LD (PUNTERO_DECC),HL
                
	LD DE,(CANAL_P)
	LD (PUNTERO_P),DE
	LD HL,(PUNTERO_P_DECP)
	CALL DECODE_CANAL    	;CHANNEL P
	LD (PUNTERO_DECP),HL
	RET

;LOOK FOR CHANNEL START

BGICMODBC1:
	XOR	A			;LOOK FOR THE BYTE 0
	LD E,0x3F			;INSTRUMENT CODE 0
	LD B,0xFF			;THE MODULE MUST HAVE A LENGTH LESS THAN $FF00 ... o_O!
	CPIR
		
	DEC	HL
	DEC	HL
	LD A,E			;IT IS THE INSTRUMENT 0??
	CP (HL)
	INC	HL
	INC	HL
	JR Z,BGICMODBC1

	DEC	HL
	DEC	HL
	DEC	HL
	LD A,E			;IT'S VOLUME 0??
	CP (HL)
	INC	HL
	INC	HL
	INC	HL
	JR Z,BGICMODBC1
	RET

;DECODE NOTES OF A CHANNEL
;IN (DE)= DESTINATION ADDRESS
;NOTE=0 FINISH CHANNEL
;NOTE=1 SILENCE
;NOTE=2 PUNTILLO
;NOTE=3 COMMAND I

DECODE_CANAL:
	LD A,(HL)
	AND A               ;END OF CHANNEL?
	JR Z,FIN_DEC_CANAL
	CALL GETLEN

	CP 00000001B       ;IT IS SILENT?
	JR NZ,NO_SILENCIO
	SET 6,A
	JR NO_MODIFICA
                
NO_SILENCIO:
	CP 00111110B       ;IS PUNTILLO?
	JR NZ,NO_PUNTILLO
	OR A
	RRC B
	XOR A
	JR NO_MODIFICA

NO_PUNTILLO:
	CP 00111111B       ;IT IS COMMAND?
	JR NZ,NO_MODIFICA
	BIT 0,B             ;COMMAND = INSTRUMENT?
	JR Z,NO_INSTRUMENTO   
	LD A,11000001B     ;INSTRUMENT CODE      
	LD (DE),A
	INC HL
	INC DE
	LD A,(HL)          ;INSTRUMENT NUMBER
	LD (DE),A
	INC DE
	INC	HL
	LD A,(HL)          ;RELATIVE INSTRUMENT VOLUME
	LD (DE),A
	INC DE
	INC	HL
	JR DECODE_CANAL
                
NO_INSTRUMENTO:
	BIT 2,B
	JR Z,NO_ENVOLVENTE
	LD A,11000100B     ;ENVELOPE CODE
	LD (DE),A
	INC DE
	INC	HL
	LD A,(HL)
	LD (DE),A
	INC	DE
	INC	HL
	JR DECODE_CANAL
     
NO_ENVOLVENTE:
	BIT 1,B
	JR Z,NO_MODIFICA           
	LD A,11000010B     ;EFFECT CODE
	LD (DE),A                  
	INC HL                      
	INC DE                      
	LD A,(HL)                  
	CALL GETLEN   
                
NO_MODIFICA:
	LD (DE),A
	INC DE
	XOR A
	DJNZ NO_MODIFICA
	SET 7,A
	SET 0,A
	LD (DE),A
	INC DE
	INC	HL
	RET			;** JR      DECODE_CANAL
                
FIN_DEC_CANAL:
	SET 7,A
	LD (DE),A
	INC DE
	RET

GETLEN:
	LD B,A
	AND 63		;00111111B
	PUSH AF
	LD A,B
	AND 192		;  11000000B
	RLCA
	RLCA
	INC A
	LD B,A
	LD A, 128		;10000000B
DCBC0:
	RLCA
	DJNZ DCBC0
	LD B,A
	POP AF
	RET
                
                

        
                
;PLAY __________________________________________________


PLAY:
	LD HL,INTERR       ;PLAY BIT 1 ON?
	BIT 1,(HL)
	RET Z
	
;TEMPO          
	LD HL,TTEMPO       ;TEMPO COUNTER
	INC (HL)
	LD A,(TEMPO)
	CP (HL)
	JR NZ,PAUTAS
	LD (HL),0
                
;INTERPRETER      
	LD IY,PSG_REG
	LD IX,PUNTERO_A
	LD BC,PSG_REG+8
	CALL LOCALIZA_NOTA
	LD IY,PSG_REG+2
	LD IX,PUNTERO_B
	LD BC,PSG_REG+9
	CALL LOCALIZA_NOTA
	LD IY,PSG_REG+4
	LD IX,PUNTERO_C
	LD BC,PSG_REG+10
	CALL LOCALIZA_NOTA
	LD IX,PUNTERO_P    ;EL CHANNEL DE EFECTOS ENMASCARA OTRO CHANNEL
	CALL LOCALIZA_EFECTO              

;PAUTAS 
                
PAUTAS:
	LD IY,PSG_REG+0
	LD IX,PUNTERO_P_A
	LD HL,PSG_REG+8
	CALL PAUTA           ;PAUTA CHANNEL A
	LD IY,PSG_REG+2
	LD IX,PUNTERO_P_B
	LD HL,PSG_REG+9
	CALL PAUTA           ;PAUTA CHANNEL B
	LD IY,PSG_REG+4
	LD IX,PUNTERO_P_C
	LD HL,PSG_REG+10
	CALL PAUTA           ;PAUTA CHANNEL C                

	RET
                


;LOCATE NOTE CHANNEL A
;IN (PUNTERO_A)

;LOCATE NOTE CHANNEL A
;IN (PUNTERO_A)

LOCALIZA_NOTA:
	LD L,(IX+PUNTERO_A-PUNTERO_A)	;HL=(PUNTERO_A_C_B)
	LD H,(IX+PUNTERO_A-PUNTERO_A+1)
	LD A,(HL)
	AND 11000000B      			;COMMAND?
	CP 11000000B
	JR NZ,LNJP0

;BIT(0)=INSTRUMENT
                
COMANDOS:
	LD A,(HL)
	BIT 0,A             		;INSTRUMENT
	JR Z,COM_EFECTO

	INC HL
	LD A,(HL)          		;Nº DE PAUTA
	INC HL
	LD E,(HL)				
                
	PUSH HL				;;TEMPO ******************
	LD HL,TEMPO
	BIT	5,E
	JR Z,NO_DEC_TEMPO
	DEC	(HL)
				
NO_DEC_TEMPO:
	BIT	6,E
	JR Z,NO_INC_TEMPO
	INC (HL)
		
NO_INC_TEMPO:
	RES	5,E				;ALWAYS RESET THE TEMPO BITS		
	RES	6,E
	POP	HL
                
	LD (IX+VOL_INST_A-PUNTERO_A),E	;REGISTRATION OF RELATIVE VOLUME
	INC	HL
	LD (IX+PUNTERO_A-PUNTERO_A),L
	LD (IX+PUNTERO_A-PUNTERO_A+1),H
	LD HL,TABLA_PAUTAS
	CALL EXT_WORD
	LD (IX+PUNTERO_P_A0-PUNTERO_A),L
	LD (IX+PUNTERO_P_A0-PUNTERO_A+1),H
	LD (IX+PUNTERO_P_A-PUNTERO_A),L
	LD (IX+PUNTERO_P_A-PUNTERO_A+1),H
	LD L,C
	LD H,B
	RES 4,(HL)        			;SHUT DOWN ENVELOPE EFFECT
	XOR A
	LD (PSG_REG_SEC+13),A
	LD (PSG_REG+13),A
	;LD	(ENVOLVENTE_BACK),A		;08.13 / RESET THE BACKUP OF THE ENVELOPE
	JR LOCALIZA_NOTA

COM_EFECTO:
	BIT 1,A             		;SOUND EFFECT
	JR Z,COM_ENVOLVENTE

	INC HL
	LD A,(HL)
	INC HL
	LD (IX+PUNTERO_A-PUNTERO_A),L
	LD (IX+PUNTERO_A-PUNTERO_A+1),H
	CALL INICIA_SONIDO
	RET

COM_ENVOLVENTE:
	BIT 2,A
	RET Z               		;IGNORE - ERROR            
           
	INC HL
	LD A,(HL)			;LOAD ENVELOPE CODE
	LD (ENVOLVENTE),A
	INC HL
	LD (IX+PUNTERO_A-PUNTERO_A),L
	LD (IX+PUNTERO_A-PUNTERO_A+1),H
	LD L,C
	LD H,B
	LD (HL),00010000B          	;TURN ON ENVELOPE EFFECT
	JR LOCALIZA_NOTA
                
              
LNJP0:
	LD A,(HL)
	INC HL
	BIT 7,A
	JR Z,NO_FIN_CANAL_A	;
	BIT	0,A
	JR Z,FIN_CANAL_A

FIN_NOTA_A:
	LD E,(IX+CANAL_A-PUNTERO_A)
	LD D,(IX+CANAL_A-PUNTERO_A+1)	;HOME POINTER BUFFER
	LD (IX+PUNTERO_A-PUNTERO_A),E
	LD (IX+PUNTERO_A-PUNTERO_A+1),D
	LD L,(IX+PUNTERO_DECA-PUNTERO_A)	;DECODER POINT LOAD
	LD H,(IX+PUNTERO_DECA-PUNTERO_A+1)
	PUSH BC
	CALL DECODE_CANAL    		;CHANNEL DECODE
	POP	BC
	LD (IX+PUNTERO_DECA-PUNTERO_A),L	;DECODER POINT GUARD
	LD (IX+PUNTERO_DECA-PUNTERO_A+1),H
	JP LOCALIZA_NOTA
                
FIN_CANAL_A:
	LD HL,INTERR			;LOOP?
	BIT	4,(HL)              
	JR NZ,FCA_CONT
	POP	AF
	JP _PLAYER_OFF
                

FCA_CONT:
	LD L,(IX+PUNTERO_L_DECA-PUNTERO_A)	;INITIAL DECODER POINT LOAD
	LD H,(IX+PUNTERO_L_DECA-PUNTERO_A+1)
	LD (IX+PUNTERO_DECA-PUNTERO_A),L
	LD (IX+PUNTERO_DECA-PUNTERO_A+1),H
	JR FIN_NOTA_A
                
NO_FIN_CANAL_A:
	LD (IX+PUNTERO_A-PUNTERO_A),L        	;(PUNTERO_A_B_C)=HL POINT GUARD
	LD (IX+PUNTERO_A-PUNTERO_A+1),H
	AND A               		;DO NOT PLAY NOTE YES NOTE=0
	JR Z,FIN_RUTINA
	BIT 6,A             		;SILENT?
	JR Z,NO_SILENCIO_A
	LD A,(BC)
	AND	00010000B
	JR NZ,SILENCIO_ENVOLVENTE
                
	XOR A
	LD (BC),A			;RESET VOLUME OF THE CORRESPONDING CHIP
	LD (IY+0),A
	LD (IY+1),A
	RET
		
SILENCIO_ENVOLVENTE:
	LD A,0xFF
	LD (PSG_REG+11),A
	LD (PSG_REG+12),A               
	XOR	A
	LD (PSG_REG+13),A                               
	LD (IY+0),A
	LD (IY+1),A
	RET

NO_SILENCIO_A:
	LD (IX+REG_NOTA_A-PUNTERO_A),A	;CHANNEL NOTE RECORD
	CALL NOTA            		;REPRODUCE NOTE
	LD L,(IX+PUNTERO_P_A0-PUNTERO_A)     ;HL=(PUNTERO_P_A0) RESET PATTERN 
	LD H,(IX+PUNTERO_P_A0-PUNTERO_A+1)
	LD (IX+PUNTERO_P_A-PUNTERO_A),L       ;(PUNTERO_P_A)=HL
	LD (IX+PUNTERO_P_A-PUNTERO_A+1),H
	
FIN_RUTINA:
	RET


;FIND EFFECT
;IN HL=(PUNTERO_P)

LOCALIZA_EFECTO:
	LD L,(IX+0)       ;HL=(PUNTERO_P)
	LD H,(IX+1)
	LD A,(HL)
	CP 11000010B
	JR NZ,LEJP0

	INC HL
	LD A,(HL)
	INC HL
	LD (IX+00),L
	LD (IX+01),H
	CALL INICIA_SONIDO
	RET
            
              
LEJP0:
	INC HL
	BIT 7,A
	JR Z,NO_FIN_CANAL_P	;
	BIT	0,A
	JR Z,FIN_CANAL_P

FIN_NOTA_P:
	LD DE,(CANAL_P)
	LD (IX+0),E
	LD (IX+1),D
	LD HL,(PUNTERO_DECP)	;DECODER POINT LOAD
	PUSH BC
	CALL DECODE_CANAL    	;DECODE CHANNEL
	POP	BC
	LD (PUNTERO_DECP),HL	;DECODER POINT GUARD
	JP LOCALIZA_EFECTO
                
FIN_CANAL_P:
	LD HL,(PUNTERO_L_DECP)	;INITIAL DECODER POINT LOAD
	LD (PUNTERO_DECP),HL
	JR FIN_NOTA_P
                
NO_FIN_CANAL_P:
	LD (IX+0),L        ;(PUNTERO_A_B_C)=HL POINT GUARD
	LD (IX+1),H
	RET

; GUIDE OF THE 3 CHANNELS
; IN:(IX):POINTER OF guideline
;    (HL):VOLUME RECORD
;    (IY):FREQUENCY RECORDS

; GUIDELINE FORMAT
;	    7    6     5     4   3-0                        3-0  
; BYTE 1 [LOOP|OCT-1|OCT+1|ORNMT|VOL] - BYTE 2 [ | | | |PITCH/NOTE]

PAUTA:
	BIT 4,(HL)        ;IF THE ENVELOPE IS ACTIVATED DOES NOT ACT
	RET NZ

	LD A,(IY+0)
	LD B,(IY+1)
	OR B
	RET	Z


	PUSH HL
           
PCAJP4:
	LD L,(IX+0)
	LD H,(IX+1)         
	LD	A,(HL)
		
	BIT 7,A		;LOOP / THE REST OF BITS DO NOT AFFECT
	JR Z,PCAJP0
	AND 00011111B       ;MAXIMUM LOOP PATTERN (0,32)X2!!!-> FOR ORNAMENTS
	RLCA			;X2
	LD D,0
	LD E,A
	SBC HL,DE
	LD A,(HL)

PCAJP0:
	BIT	6,A		;EIGHTH -1
	JR Z,PCAJP1
	LD E,(IY+0)
	LD D,(IY+1)

	AND	A
	RRC	D
	RR E
	LD (IY+0),E
	LD (IY+1),D
	JR PCAJP2
		
PCAJP1:
	BIT	5,A		;EIGHTH +1
	JR Z,PCAJP2
	LD E,(IY+0)
	LD D,(IY+1)

	AND	A
	RLC	E
	RL D
	LD (IY+0),E
	LD (IY+1),D		




PCAJP2:
	LD A,(HL)
	BIT	4,A
	JR NZ,PCAJP6	;SELECTED ORNAMENTS

	INC HL		;__ PITCH FREQUENCY FUNCTION__		
	PUSH HL
	LD E,A
	LD A,(HL)		;FREQUENCY PITCH
	LD L,A
	AND	A
	LD A,E
	JR Z,ORNMJP1

	LD A,(IY+0)	;IF THE FREQUENCY IS 0 THERE IS NO PITCH
	ADD	A,(IY+1)
	AND	A		;attention
	LD A,E
	JR Z,ORNMJP1

	BIT	7,L
	JR Z,ORNNEG
	LD H,0xFF
	JR PCAJP3
ORNNEG:
	LD	H,0
		
PCAJP3:
	LD E,(IY+0)
	LD D,(IY+1)
	ADC HL,DE
	LD (IY+0),L
	LD (IY+1),H
	JR ORNMJP1


PCAJP6:
	INC	HL		;___ FUNCTION ORNAMENTS ___	
		
	PUSH HL
	PUSH AF
	LD A,(IX+REG_NOTA_A-PUNTERO_P_A)	;RECOVER NOTE REGISTRATION AT CHANNEL
	LD E,(HL)		;
	ADC A,E       	; NOTE 
	CALL TABLA_NOTAS
	POP	AF	
		
		
ORNMJP1:
	POP	HL
		
	INC	HL
	LD (IX+0),L
	LD (IX+1),H
	
PCAJP5:
	POP	HL
	LD B,(IX+VOL_INST_A-PUNTERO_P_A)	;RELATIVE VOLUME
		
	ADD B; attention
		
	JP P,PCAJP7
	LD A,1		;THE VOLUME IS NOT EXTINGUISHED
	
PCAJP7:
	AND 15	;	00001111B	;MODULATED FINAL VOLUME
	LD (HL),A
	RET



;NOTE : PLAY A NOTE
;IN (A)=NOTE CODE
;   (IY)=FREQUENCY RECORDS


NOTA:
	LD L,C
	LD H,B
	BIT 4,(HL)
	LD B,A
	JR NZ,EVOLVENTES
	LD A,B
	
TABLA_NOTAS:
	LD HL,DATOS_NOTAS		;LOOK FOR FREQUENCY
	CALL EXT_WORD
	LD (IY+0),L
	LD (IY+1),H
	RET


;IN (A)=ENVELOPE CODE
;   (IY)=FREQUENCY RECORD

EVOLVENTES:
	LD HL,DATOS_NOTAS
		;SUB	12
	RLCA                    ;X2
	LD D,0
	LD E,A
	ADD HL,DE
	LD E,(HL)
	INC	HL
	LD D,(HL)
		
	PUSH DE
	LD A,(ENVOLVENTE)		;FREQUENCY OF CHANNEL ON / OFF
	RRA
	JR NC,FRECUENCIA_OFF
	LD (IY+0),E
	LD (IY+1),D
	JR CONT_ENV
				
FRECUENCIA_OFF:
	LD DE,0x0000
	LD (IY+0),E
	LD (IY+1),D
	;RATIO CALCULATION (EIGHTH UP)
CONT_ENV:
	POP	DE
	PUSH AF
	PUSH BC
	AND	3		;00000011B
	LD B,A
	;INC	B
		
	;AND	A			;1/2
	RR D
	RR E
		
CRTBC0:
	;AND	A			;1/4 - 1/8 - 1/16
	RR D
	RR E
	DJNZ CRTBC0
	LD A,E
	LD (PSG_REG+11),A
	LD A,D
	AND	3		;00000011B
	LD (PSG_REG+12),A
	POP BC
	POP AF			;ENVELOPE SHAPE SELECTION
                
	RRA
	AND	00000110B		;00000110B=6 	;0x08,0x0A,0x0C,0x0E
	ADD 8;attention
	LD (PSG_REG+13),A
	LD (ENVOLVENTE_BACK),A
	RET


;EXTRACT A WORD FROM A TABLE
;IN:(HL)=DIRECCION TABLE
;   (A)= POSITION
;OUT(HL)=WORD

EXT_WORD:
	LD D,0
	RLCA
	LD E,A
	ADD HL,DE
	LD E,(HL)
	INC HL
	LD D,(HL)
	EX DE,HL
	RET

;;;;;;;; SOUND EFFECTS VARIABLES;;;;;;;;;;;

;TABLA_EFECTOS		DW EFFECTS ADDRESS CHART
;TABLA_EFECTOS:
;		defw 0
; VARIABLES
;___________

;EFECTOS
N_EFECTO:
	defb 0
	
;PUNTERO_EFECTO	EQU	$E451 EFFECTS ADDRESS CHART
PUNTERO_EFECTO:
	defw 0
	
;CANAL_EFECTOS	EQU	$E453	
;DB : 1:CHANNEL A - 2:CHANNEL B - 3:CHANNEL C
CANAL_EFECTOS:
	defb 1	

;;;;;;;; SOUND EFFECTS ROUTINES;;;;;;;;;;;
INICIA_EFECTO:
	LD A,B
	LD HL,TABLA_EFECTOS
	CALL EXT_WORD
	LD (PUNTERO_EFECTO),HL
	LD HL,INTERR
	SET 3,(HL)
	RET
	
REPRODUCE_EFECTO:

	LD HL,INTERR   
	BIT 3,(HL)          	;IS THE EFFECT ACTIVATED?
	RET Z
	LD HL,[PUNTERO_EFECTO]
	LD A,(HL)
	CP 0xFF
	JP Z,FIN_EFECTO
	LD B,A			;FINE FREQUENCY
	INC HL
	LD A,(HL)
	RRCA
	RRCA
	RRCA
	RRCA
	AND 00001111B
	LD C,A			;	MAJOR FREQUENCY
	;LD      A,10111000B		;	REMOVE NOISE
	;LD      [PSG_REG_SEC+7],A
	LD A,(HL)
	DEC	A	;DEC A TO LOWER VOLUME !! OR PUT VARIABLE
	;DEC	A
	AND 00001111B

	LD D,A	;VOLUME
	INC HL			;INCREASE AND KEEP THE POINTER
	LD (PUNTERO_EFECTO),HL   
	LD IX,PSG_REG_SEC
	LD A,(CANAL_EFECTOS);question FIX THIS	;SELECCION DE CHANNEL *********
	CP 1
	JR Z,RS_CANALA
	CP 2
	JR Z,RS_CANALB
		
RS_CANALC:
	LD (IX+4),B
	LD (IX+5),C
	LD (IX+10),D
	RET		
		
RS_CANALA:
	LD (IX+0),B
	LD (IX+1),C
	LD (IX+8),D
	RET
                
RS_CANALB:
	LD (IX+2),B
	LD (IX+3),C
	LD (IX+9),D
	RET
                
FIN_EFECTO:
	LD HL,INTERR
	RES 3,(HL)			;DISABLE EFFECT
	RET  	
	
;;;;;;;; SOUND EFFECTS ;;;;;;;;;;;


;DATA CHART OF THE RHYTHM EFFECT CHANNEL SELECTOR

TABLA_DATOS_CANAL_SFX:
	;DW	SELECT_CANAL_A,SELECT_CANAL_B,SELECT_CANAL_C
	defw	SELECT_CANAL_A,SELECT_CANAL_B,SELECT_CANAL_C


;BYTE 0:SFX_L	
;BYTE 1:SFX_H	
;BYTE 2:SFX_V	
;BYTE 3:SFX_MIX

SELECT_CANAL_A:
	defw PSG_REG_SEC+0,PSG_REG_SEC+1,PSG_REG_SEC+8
	defb 177	;10110001B
		
SELECT_CANAL_B:
	defw PSG_REG_SEC+2,PSG_REG_SEC+3,PSG_REG_SEC+9
	defb 170	;10101010B
		
SELECT_CANAL_C:
	defw	PSG_REG_SEC+4,PSG_REG_SEC+5,PSG_REG_SEC+10
	defb 156	;10011100B


;____________________________________
; APLIB
; aPPack decompressor
; original source by dwedit
; very slightly adapted by utopian
; optimized by Metalbrain

;hl = source
;de = dest

depack:
	ld ixl,128
	
apbranch1:
	ldi
	
aploop0:
	ld	ixh,1		;LWM = 0
	
aploop:
	call ap_getbit
	jr nc,apbranch1
	call ap_getbit
	jr nc,apbranch2
	ld b,0
	call ap_getbit
	jr nc,apbranch3
	ld c,16		;get an offset
		
apget4bits:
	call ap_getbit
	rl c
	jr nc,apget4bits
	jr nz,apbranch4
	ld a,b
		
apwritebyte:
	ld (de),a		;write a 0
	inc de
	jr aploop0
		
apbranch4:
	and	a
	ex de,hl 		;write a previous byte (1-15 away from dest)
	sbc hl,bc
	ld a,(hl)
	add	hl,bc
	ex de,hl
	jr apwritebyte
	
apbranch3:
	ld 	c,(hl)		;use 7 bit offset, length = 2 or 3
	inc hl
	rr c
	ret z		;if a zero is encountered here, it is EOF
	ld a,2
	adc a,b
	push hl
	ld iyh,b
	ld iyl,c
	ld h,d
	ld l,e
	sbc hl,bc
	ld c,a
	jr ap_finishup2
		
apbranch2:
	call ap_getgamma	;use a gamma code * 256 for offset, another gamma code for length
		dec 	c
		ld	a,c
		sub	ixh
		jr 	z,ap_r0_gamma		;if gamma code is 2, use old r0 offset,
		dec 	a
		;do I even need this code?
		;bc=bc*256+(hl), lazy 16bit way
		ld 	b,a
		ld 	c,(hl)
		inc 	hl
		ld	iyh,b
		ld	iyl,c

		push 	bc
		
		call 	ap_getgamma

		ex 	(sp),hl		;bc = len, hl=offs
		push 	de
		ex 	de,hl

		ld	a,4
		cp	d
		jr 	nc,apskip2
		inc 	bc
		or	a
apskip2:
	ld 	hl,127
		sbc 	hl,de
		jr 	c,apskip3
		inc 	bc
		inc 	bc
apskip3:
	pop 	hl		;bc = len, de = offs, hl=junk
		push 	hl
		or 	a
ap_finishup:
	sbc 	hl,de
		pop 	de		;hl=dest-offs, bc=len, de = dest
ap_finishup2:
	ldir
		pop 	hl
		ld	ixh,b
		jr 	aploop

ap_r0_gamma:
	call 	ap_getgamma		;and a new gamma code for length
		push 	hl
		push 	de
		ex	de,hl

		ld	d,iyh
		ld	e,iyl
		jr 	ap_finishup


ap_getbit:
	ld	a,ixl
		add	a,a
		ld	ixl,a
		ret	nz
		ld	a,(hl)
		inc	hl
		rla
		ld	ixl,a
		ret

ap_getgamma:
	ld 	bc,1
ap_getgammaloop:
	call 	ap_getbit
		rl 	c
		rl 	b
		call 	ap_getbit
		jr 	c,ap_getgammaloop
		ret
		
;____________________________________

INTERR:         ;DB     0
defb     00
		;SWITCHES 1=ON 0=OFF
		;BIT 0=LOAD SONG ON/OFF
		;BIT 1=PLAYER ON/OFF
		;BIT 2=EFFECTS ON/OFF
		;BIT 3=SFX ON/OFF
		;BIT 4=LOOP
;INTERRUPTION CONTROL

;HOOK:           DB     0

;MUSIC **** THE ORDER OF THE VARIABLES IS FIXED ******


;---------------------------
SONG:
defb     00			;SONG NUMBER

TEMPO:
defb 	00			;TEMPO

TTEMPO:
defb 	00			;TEMPO COUNTER

;---------------------------
	
PUNTERO_A:
defw	00			;POINTER OF CHANNEL A
	
PUNTERO_B:
defw	00			;POINTER OF CHANNEL B

PUNTERO_C:
defw	00			;POINTER OF CHANNEL C
;---------------------------

CANAL_A:
defw	BUFFER_DEC	;MUSIC START ADDRESS A


CANAL_B:
defw	00			;START ADDRESS OF MUSIC B
	

CANAL_C:
defw	00			;HOME ADDRESS OF MUSIC C
;---------------------------

PUNTERO_P_A:
defw	00			;PATTERN POINTER CHANNEL A
	

PUNTERO_P_B:
defw	00			;PATTERN POINTER CHANNEL B

PUNTERO_P_C:
defw	00			;PATTERN POINTER CHANNEL C
;---------------------------

PUNTERO_P_A0:
defw	00			;INI PATTERN POINTER CHANNEL A

PUNTERO_P_B0:
defw	00			;INI PATTERN POINTER CHANNEL B

PUNTERO_P_C0:
defw	00			;INI PATTERN POINTER CHANNEL C
;---------------------------

PUNTERO_P_DECA:
defw	00			;START OF DECODER POINTER CHANNEL A

PUNTERO_P_DECB:
defw	00			;START OF DECODER POINTER CHANNEL B

PUNTERO_P_DECC:
defw	00			;START OF DECODER POINTER CHANNEL C
;---------------------------

PUNTERO_DECA:
defw	00			;POINTER DECODER CHANNEL A

PUNTERO_DECB:
defw	00			;POINTER DECODER CHANNEL B

PUNTERO_DECC:
defw	00			;POINTER DECODER CHANNEL C
;---------------------------

REG_NOTA_A:
defb	00			;REGISTRATION OF THE NOTE IN CHANNEL A

VOL_INST_A:
defb	00			;CHANNEL INSTRUMENT RELATIVE VOLUME A


REG_NOTA_B:
defb	00			;REGISTER OF THE NOTE IN CHANNEL B

VOL_INST_B:
defb	00			;CHANNEL B INSTRUMENT RELATIVE VOLUME
					;EMPTY

REG_NOTA_C:
defb	00			;REGISTER OF THE NOTE IN CHANNEL C

VOL_INST_C:
defb	00			;RELATIVE VOLUME OF THE INSTRUMENT OF CHANNEL C

;---------------------------

PUNTERO_L_DECA:
defw	00
;HOME POINT OF THE LOOP OF DECODER CHANNEL A
	
PUNTERO_L_DECB:
defw	00
;HOME POINT OF THE LOOP OF THE DECODER CHANNEL B

PUNTERO_L_DECC:
defw	00
;HOME POINT OF THE LOOP OF THE DECODER CHANNEL C

;---------------------------

;RHYTHM EFFECT CHANNEL - MASK ANOTHER CHANNEL

PUNTERO_P:
defw	00			;CHANNEL POINTS EFFECTS

	
CANAL_P:
defw	00			;DIRECTION OF START OF THE EFFECTS

	
PUNTERO_P_DECP:
defw	00			;HOME POINT OF DECODER CHANNEL P

PUNTERO_DECP:
defw	00			;POINTER DECODER CHANNEL P

PUNTERO_L_DECP:
defw	00			;HOME POINT OF THE LOOP OF DECODER CHANNEL P


;SELECT_CANAL_P	DB	INTERR+$36	
;CHANNEL SELECTION OF RHYTHM EFFECTS
;---------------------------

SFX_L:
defw	00;BUFFER ADDRESS EFFECTS OF LOW REGISTRATION RATE

SFX_H:
defw	00;BUFFER ADDRESS EFFECTS OF HIGH REGISTRATION RHYTHM

SFX_V:
defw	00;BUFFER ADDRESS EFFECTS OF RHYTHM RECORD VOLUME

SFX_MIX:
defw	00;BUFFER ADDRESS EFFECTS OF RHYTHM MIXER REGISTRATION

;---------------------------

;SOUND EFFECTS

N_SONIDO:        	; SOUND NUMBER
	defb	0

PUNTERO_SONIDO:
defw	0			; POINTER OF THE SOUND THAT IS REPRODUCED
;---------------------------


; PSG RECORD BUFFERs

PSG_REG:
defs	16

PSG_REG_SEC:
defs	16

ENVOLVENTE:
defb 	0			; SHAPE OF THE ENVELOPE
	


	;BIT 0	  : FREQUENCY CHANNEL ON/OFF
	;BIT 1-2  : RATIO 
	;BIT 3-3  : SHAPE
	
ENVOLVENTE_BACK:
defb 	0			;BACKUP OF THE SHAPE OF THE ENVELOPE


;-------------------------------------

BUFFER_DEC:
	defb      0x00;attention


	
;************************* a lot of attention!!!!
; here the song is decoded you have to leave enough free space.
;*************************
   
;; Here the player is added with the sample!!!
;INCLUDE "wave.asm"
;; REMOVE!!

;; INCLUDE MUSIC DATA (PATTERNS/EFFECTS)

	INCLUDE "instrumentos.asm"

;; The songs have to be compressed with aplib

CURRENT_SONG:
defb	0


SONG_0:
binary "funkyfun2.bin"



				
TABLA_SONG:
	defw	SONG_0
	
;; INCLUDE SOUND EFFECTS:
INCLUDE "efectos.asm"

TABLA_EFECTOS:
	defw  	EFECTO0


;; THE CURRENT SONG IS UNCOMPRESSED HERE:
BUFFER_UNPACK:
	DEFS	4096
	
;; NOTHING FROM HERE!!!
BUFFERS_CANALES:
	defb		0
	
	

