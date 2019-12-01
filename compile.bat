REM sccz80
SET PATH=c:\z88dk199b;c:\z88dk199b\bin;c:\z88dk199b\lib\;c:\z88dk199b\lib\clibs;c:\z88dk199b\lib\config;C:\Program Files\SDCC\bin 

cls

cd gfx
	zx7 screen0.scr screen0.bin
	zx7 screen1.scr screen1.bin
	zx7 screen2.scr screen2.bin
	zx7 screen3.scr screen3.bin
	zx7 screen4.scr screen4.bin
	zx7 screen5.scr screen5.bin
	zx7 screen6.scr screen6.bin
	move "*.bin" "..\"
cd ..

rem compress and move songs
cd tunes
	apack c funkyfun2.mus funkyfun2.bin
	move "*.bin" "..\"
	copy "instrumentos.asm" "..\"
	copy "efectos.asm" "..\"
	copy "WYZPROPLAY47cZX.ASM" "..\"
cd ..


@rem pause
@rem cls

cd utils
	call loader.bat
@rem	copy /b loader.tap + loadscreen.tap + bank.tap
cd ..


@rem cls

rem BUILD CONSOLIDATED OBJECT FILE
zcc +zx -v -c -clib=new --fsigned-char -o objects @zproject.lst

@rem pause

zcc +zx -v -m -startup=31 -clib=new objects.o -o compiled -pragma-include:zpragma.inc

@REM pause

appmake +zx -b compiled_BANK_06.bin -o bank06.tap --org 49152 --noloader --blockname bank06

appmake +zx -b compiled_BANK_00.bin -o bank00.tap --org 49152 --noloader --blockname bank00

appmake +zx -b compiled_BANK_01.bin -o bank01.tap --org 49152 --noloader --blockname bank01

appmake +zx -b compiled_CODE.bin -o lowRAM.tap --org 24450 --noloader --blockname lowRAM






@rem pause
@rem cls


copy /b loader.tap + bank00.tap + bank01.tap + bank06.tap + lowRAM.tap  1output.tap

echo off

call cleanup.bat



