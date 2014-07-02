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
Maps: (id:mapname) `maps` table
- <name>
*/

public OnFilterScriptInit()
{
	print("ZombieMP map script loaded");
	return 1;
}

public OnFilterScriptExit()
{
	return 1;
}

forward BuildMap(index, name[]);
public BuildMap(index, name[]) // To be called by CallRemoteFunction
{
	printf("> Loading map (%i:%s)", index, name);
	
	switch(index)
	{
	    case 1: // index equals id in maps table
	    {
	        // mapcodes
	    }
	    case 2:
	    {
	    
	    }
	    default:
	    {
	        print("> Unkown map");
	    }
	}
}
