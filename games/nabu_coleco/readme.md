# Description

This is a ColecoVision ROM loader/emulator for the NABU PC. It will allow loading and running of unmodified ColecoVision ROMs on the NABU. It does this by using a patched version of the ColecoVision BIOS that has the VDP IO address changed to use the NABU address. In addition it has been patched to emulate the SN76489 using the NABU's AY-3-8910 PSG and joysticks.

Some ROMs will need to be patched before use because they do some direct hardware access, the loader has a list of ROMs that need patches and can automatically apply this based on the crc16 of the ROM.


# Usage
The loader uses the HCCA to request paks and consists of four main paks:

 - 000001.nabu - The loader itself
 - 000002.nabu - The customized BIOS
 - 000003.nabu - Patch data
 - 000004.nabu - Menu data

Paks 5+ are the ColecoVision ROMS

This system allows the the BIOS or Patch/Menu data to be update independently of the loader itself as well as the ROM to be updated easily as well.

 # Build
 In order to build this you will need the following compiler and linker:

  * [vasm](http://sun.hasenbraten.de/vasm/)
  * [vlink](http://sun.hasenbraten.de/vlink/)

To build the loader and associated paks just type ```make```

This will create ```000001.nabu```, ```000002.nabu```, ```000003.nabu```, and ```000004.nabu```

# Controller Support
The ColecoVision keypad input is mapped to 0-9,- (*) , =(#) on the NABU keyboard.  The joystick is mapped onto the cursor keys with the two triggers mapped to previous page and next page keys. You can switch which ColecoVision controller the joystick and keypad are mapped to by using the SYM key on the nabu keyboard.

The NABU joystick is also mapped to the currently selected ColecoVision controller, but has a few limitations. The first is that it only supports a single trigger, the second one is that only a single joystick is supported (though the SYMN does switch which ColecoVision controller it operates). Both of these are due to an issue with handling multi byte scan codes while running a ColecoVision game.

# Games
Current games known working:

- BC's Quest for Tires II - Grog's Revenge (1984) (32k)
- Bump 'N' Jump (1982-84) (Data East)
- Burgertime (1982-84) (Data East)
- Carnival (1982)
- Congo Bongo (1984)
- Cosmic Avenger (1982) (Universal)
- Dacman (Aug 16) by Daniel Bienvenu (2000) (PD)
- Dam Busters, The (1984)
- Dance Fantasy (1984) (Fisher-Price)
- Dig Dug (1983) (Atarisoft) (Prototype)
- Digger (1983) (Windmill Software)
- Donkey Kong for Adam (1982)
- Donkey Kong Jr (1982-83)
- Easter Bunny (2007)
- Escape From The Mind Master (1983) (Starpath) (Prototype)
- Evolution (1983) (Sydney)
- Frenzy! (1982-83)
- Frogger (1982-83) (Parker Bros)
- Gateway to Apshai (1984) (Epyx)
- Gorf (1981-83) (Midway)
- Joust (2014) (Team Pixelboy)
- Jumpman Junior (1984) (Epyx)
- Ken Uston's Blackjack-Poker (1983)
- Lady Bug (1982) (Universal)
- Learning With Leeper (1983) (Sierravision) [!]
- Montezuma's Revenge (1984) (Parker Bros)
- Motocross Racer (1984) (Xonox)
- Mountain King (1983-84) (Sunrise) [!]
- Mr. Do! (1983) (Universal)
- Ms. Space Fury (Digital Press) (2001)
- Nova Blast (1983) (Imagic) [!]
- Oil's Well (1984) (Sierravision)
- Omega Race (1981-83) (Midway)
- Pac-Man (1983) (Atarisoft) (Prototype)
- Pepper II (1983) (Exidy)
- Pitfall II - Lost Caverns (1983-84) (Activision)
- Pitfall! (1983) (Activision)
- Purple Dinosaur Massacre by John Dondzila (1996) (PD)
- Q-bert II (1984) (Parker Bros)
- Robin Hood (1984) (Xonox)
- Rocky Super-Action Boxing (1983) (Coleco)
- Sega Flipper (2021) (Team Pixelboy)
- Skiing (1986) (Telegames)
- Smurf - Rescue in Gargamel's Castle (1982)
- Space Fury (1983) (Sega)
- Space Panic (1983) (Universal)
- Squish 'Em Sam! (1983) (Interphase)
- Star Trek - Strategic Operations Simulator (1984) (Sega)
- Tank Wars (1983) (Bit Corp) [!]
- Tomarc the Barbarian (1984) (Xonox)
- Tutankham (1983) (Parker Bros)
Up 'N Down (1984) (Sega)
Zaxxon (1982) (Sega)
