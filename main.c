//sccz80

//https://github.com/z88dk/z88dk/wiki/CallingConventions

#include <arch/zx.h>
#include <input.h>

//#include <compress/aplib.h>
#include <compress/zx7.h>

#include "ram6.h"
#include "ram0.h"
#include "ram1.h"



extern void __FASTCALL__ blackout(void);

extern void __FASTCALL__ bank(unsigned char ramBank);

void screen0display(void)
{
	bank(0);
	blackout();
	//aplib_depack(16384,(unsigned char)screen0);
	dzx7_turbo(((unsigned char *)screen0), ((unsigned char *)16384));
}
void screen1display(void)
{
	bank(1);
	blackout();
	//aplib_depack(16384,(unsigned char)screen1);
	dzx7_turbo(((unsigned char *)screen1), ((unsigned char *)16384));
}
void screen2display(void)
{
	bank(1);
	blackout();
	dzx7_turbo(((unsigned char *)screen2), ((unsigned char *)16384));
}
void screen3display(void)
{
	bank(6);
	blackout();
	dzx7_turbo(((unsigned char *)screen3), ((unsigned char *)16384));
}
void screen4display(void)
{
	bank(6);
	blackout();
	dzx7_turbo(((unsigned char *)screen4), ((unsigned char *)16384));
}
void screen5display(void)
{
	bank(6);
	blackout();
	dzx7_turbo(((unsigned char *)screen5), ((unsigned char *)16384));
}
void screen6display(void)
{
	bank(6);
	blackout();
	dzx7_turbo(((unsigned char *)screen6), ((unsigned char *)16384));
}


void main(void)
{
	unsigned int displayPause = 1;
	
	__asm
		di;pesky interupts need to be disabled
	__endasm
	
	
	zx_border(0);
	
	bank(1);
	INIT_BUFFERS();//check
	PLAYER_OFF();//check
	wyz_load_music (0);
	
   
	while (1)
	{
		bank(1);
		INICIO();//check
		
		if (displayPause == 1)
			screen0display();

		if (displayPause == 500)
			screen1display();
		
		if (displayPause == 1000)
			screen2display();
		
		if (displayPause == 1500)
			screen3display();
		
		if (displayPause == 2000)
			screen4display();
		
		if (displayPause == 2500)
			screen5display();
		
		if (displayPause == 3000)
			screen6display();

		
		if (displayPause == 3500)
		{
			displayPause = 0;
		}
		
		
		displayPause ++;
		in_pause(15);  // in milliseconds
		
	}
}
