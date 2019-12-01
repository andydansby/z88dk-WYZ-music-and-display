# z88dk-WYZ-music-and-display

This is a minimilist example on how to get the WYZ Player
at https://sites.google.com/site/wyzplayer/
to work with Z88dk and bank switching.

What this allows us to do is play music by Banking in RAM 1
while displaying images from either the same RAM bank or a 
different RAM bank.

WYZ player plays files from the WYZ Tracker, available at
https://github.com/AugustoRuiz/WYZTracker

The images are compressed with the ZX7 compressor and are
placed in various via SECTIONS.  The music files are
compressed with APack and are placed in RAM Bank 1.

The WYZ player has APack built in so uncompresses the
music into Bank 1.  Compressing the songs will allow
you to store a good number of songs in memory, 
uncompress them as needed and play back while periodically
uncompressing image files.

Program flows like this:

initilize loop tick
disable interupts
initilize WYZ player
turn off player
load song - uncompress song also in this step

start endless loop
  Play music
  loop tick = 1 then Uncompress Image 0 (bank 0)
  loop tick = 500 then Uncompress Image 1 (bank 1)
  loop tick = 1000 then Uncompress Image 2 (bank 1)
  loop tick = 1500 then Uncompress Image 3 (bank 6)
  loop tick = 2000 then Uncompress Image 4 (bank 6)
  loop tick = 2500 then Uncompress Image 5 (bank 6)
  loop tick = 3000 then Uncompress Image 6 (bank 6)
  loop tick = 3500 then restart loop tick
  increase loop tick
  pause 15 milliseconds (the ammount of time for any extra logic)
Go back to loop start
  
