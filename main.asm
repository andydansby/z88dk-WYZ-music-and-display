

SECTION code_user
	PUBLIC _blackout
	_blackout:
	   ld hl, 22528
	   ld (hl), 0
	   push hl
	   pop de
	   inc de
	   ld bc, 767
	   ldir   
	ret


;;SECTION code_user
;;	PUBLIC _switchScreen
;;	_switchScreen:
;;	   ld a,($5b5c)   ;//System variable with the previous value
;;	   xor   8			;//Change screen
;;	   ld bc,$7ffd		;//Port to write
;;	   di				;//disable interupts
;;	   ld ($5b5c),a		;//Update system variable
;;	   out   (c),a		;//Address
;;	   ei				;//enable interupts
;;   ret


; void bank(unsigned char ramBank)
; fastcall linkage
SECTION code_crt_common   ; keep it early in the binary
	PUBLIC _bank
	_bank:
		ld a,(0x5b5c)   ;//System variable with the previous value
		and 0xf8
		or L
		ld bc,0x7ffd		;//Port to write
		;;di
		ld (0x5b5c),a		;//Update system variable
		out   (c),a		;//Address
		;;ei				;//enable interupts
	ret

