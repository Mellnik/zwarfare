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

#define FILTERSCRIPT

#include <a_samp>       // 0.3z-R2-2
#include <streamer>     // v2.7.2

/*
Maps:
- <name>
*/

public OnFilterScriptInit()
{
	print("ZombieMP map script loading");
    BuildMaps();
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

BuildMaps()
{
	print("> Loading map <name>");

}
