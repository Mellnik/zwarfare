/*======================================================================*\
|| #################################################################### ||
|| # Project Zombie Multiplayer - Maps			           			  # ||
|| # ---------------------------------------------------------------- # ||
|| # Copyright ©2013-2014 Zombie Multiplayer		  				  # ||
|| # Created by Mellnik                                               # ||
|| # ---------------------------------------------------------------- # ||
|| # http://ZombieMP.com		                          			  # ||
|| #################################################################### ||
\*======================================================================*/

/*
1. Do not map objects away from the mainland or the map gets bugged
2. Put the huge road object(180° for invisibility) around the map so players cant escape
3. Always try to NOT place the map in the air or players may fall through it
4. Build 1 or more defense places where players can fight against zombies
5. Make the map interesting and challenging for players to play on
6. Always try to keep the object count low < 500 OBJECTS! or players can't see the entire map
*/

#define FILTERSCRIPT

#include <a_samp>       // 0.3z-R3
#include <streamer>     // v2.7.2

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
