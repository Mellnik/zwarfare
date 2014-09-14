/*======================================================================*\
|| #################################################################### ||
|| # Project Zombie Multiplayer - Maps			           			  # ||
|| # ---------------------------------------------------------------- # ||
|| # Copyright ©2013-2014 Zombie Warfare     		  				  # ||
|| # Created by Mellnik                                               # ||
|| # ---------------------------------------------------------------- # ||
|| # http://zwarfare.com    	                          			  # ||
|| #################################################################### ||
\*======================================================================*/

/*
1. Do not map objects away from the mainland or the map gets bugged
2. Put the huge road object(180° for invisibility) around the map so players can't escape (if needed)
3. Always try to NOT place the map in the air or players may fall through it
4. Build 1 or more defense places where players can fight against zombies
5. Make the map challenging and interesting, nobody wants to play a boring map
6. Always try to keep the object count low < 500 OBJECTS! or players can't see the entire map at once
*/

#define FILTERSCRIPT

#include <a_samp>       // 0.3z-R4
#include <streamer>     // v2.7.4

/*
Maps: (id:mapname) `maps` table
- <name>
*/

public OnFilterScriptInit()
{
	print("ZombieMP map script loaded");
	BuildMaps();
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

BuildMaps()
{
	// <name>
}
