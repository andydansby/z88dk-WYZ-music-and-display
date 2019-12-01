#ifndef RAM1_H
#define RAM1_H

// located in bank 1

extern unsigned char screen1[];
extern unsigned char screen2[];

//extern void __FASTCALL__ ROUT();//does this really need to be public?
extern void __FASTCALL__ INICIO();//play song

extern void __FASTCALL__ INIT_BUFFERS();

extern void __FASTCALL__ PLAYER_OFF();//stops playing

extern void __FASTCALL__ CARGA_CANCION();//load song


void __FASTCALL__ wyz_load_music (unsigned char mzk_number)
{
	//fastcall will use the L register
	__asm
		;ld A, L	; A gets the song number		
		LD A,0	; SONG #0 (THE 1ST OF THE LIST)	49156
		call _CARGA_CANCION	
	__endasm
}







/*
void __FASTCALL__ wyz_init (void) {
	#asm
		di
		call INIT_BUFFERS
		ei
	#endasm
}
*/

/*
void __FASTCALL__ wyz_player_off (void) {
	#asm
		CALL PLAYER_OFF
	#endasm
}
*/

/*
void __FASTCALL__ wyz_load_music (unsigned char mzk_number)
{
	//fastcall will use the L register
	#asm
		; CALL PLAYER_OFF
		; push af
		
		
		ld A, L	; A gets the song number		
		;LD A,2	; SONG #0 (THE 1ST OF THE LIST)	49156
		call CARGA_CANCION	
		
		;pop af
		;ld c, a			; C gets the song number
		;ld b, 0
	#endasm
}
*/

/*
void __FASTCALL__ wyz_play(void)
{
	#asm
		halt
		;//push ix
		;//push iy
		call INICIO
		;//pop ix
		;//pop iy
	#endasm
}
*/
#endif