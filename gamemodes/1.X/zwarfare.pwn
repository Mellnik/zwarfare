/*======================================================================*\
|| #################################################################### ||
|| # Project Zombie Warfare - 1.X Series            			  	  # ||
|| # ---------------------------------------------------------------- # ||
|| # Copyright ©2013-2014 Zombie Warfare     		  				  # ||
|| # Created by Mellnik                                               # ||
|| # ---------------------------------------------------------------- # ||
|| # http://zwarfare.com		                          			  # ||
|| #################################################################### ||
\*======================================================================*/


/* Build Dependencies
|| SA-MP Server 0.3z-R4
|| YSI Library 3.1
|| sscanf Plugin 2.8.1
|| Streamer Plugin v2.7.4
|| MySQL Plugin R38
|| hash-plugin 0.0.4
||
|| Build specific:
||
|| Script limits:
|| Maximum maps: 20 (MAX_MAPS)
||
||
|| Notes:
|| maybe remove ZMP_SyncPlayer in future? (global weather being set before)
|| Prefixes: i = Integer, s = String, b = bool, f = Float, p = Pointer, t3d = 3DTextLabel, g_ = Global, g = game, tick = tickcount, t = Timer, bw = bitwise
*/

#pragma dynamic 8192        	// Required for md-sort

#define IS_RELEASE_BUILD (true)
#define RUS_BUILD (false)
#define _YSI_NO_VERSION_CHECK
#define YSI_IS_SERVER

#include <a_samp>
#undef MAX_PLAYERS
#define MAX_PLAYERS (200)
#include <crashdetect>
#include <YSI\y_iterate>
#include <YSI\y_commands>
#include <YSI\y_master>
#include <YSI\y_stringhash>
#include <progress2>
#include <sscanf2>
#include <streamer>
#include <a_mysql_R38>
#include <hash>
#include <md-sort>
#include <utconvert>

// Missing function natives
native gpci(playerid, serial[], maxlen); // undefined in a_samp.inc

// Prototypes
Float:GetDistance3D(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2);
Float:GetDistanceBetweenPlayers(playerid1, playerid2);

// Server
#define VERSION                         "1.0.0"
#define URL                     		"www.zwarfare.com"
#define FANCY_URL                       "www.zwarfare.com"
#if RUS_BUILD == true
#define HOSTNAME                        "[RUS] « "ZWAR_NAME" v"VERSION" (0.3z) »"
#else
#define HOSTNAME                        "[ENG] « "ZWAR_NAME" v"VERSION" (0.3z) »"
#endif
#define ZWAR_NAME              			"Zombie Warfare"
#define ZWAR_SHORT              		"ZWAR"
#define zwar                            "{FFFFFF}[{969696}ZWAR{FFFFFF}]"
#define server_sign                     "{FFFFFF}[{FF005F}SERVER{FFFFFF}]"
#define SQL_HOST   						"::1"
#define SQL_PORT                        (3306)
#if IS_RELEASE_BUILD == true
#define SQL_USER   						"zwarserver"
#define SQL_PASS   						"JESIcFVvHC;qkC$Aj(XK2y%HvMoZ"
#define SQL_DATA   						"zwarserver"
#else
#define SQL_USER   						"zmpdev"
#define SQL_PASS   						"pass2"
#define SQL_DATA                        "zmpdev"
#endif

// General rule set
#define MAX_REPORTS 					(7)
#define MAX_MAPS                        (20)
#define MAX_MAPS_STRING                 "20"
#define MAX_ADMIN_LEVEL         		(6)
#define MAX_WARNINGS 					(3)
#define COOLDOWN_CMD                  	(5000)
#define COOLDOWN_TEXT                   (5000)
#define COOLDOWN_CHAT                   (5500)
#define COOLDOWN_CMD_REPORT             (30000)
#define COOLDOWN_CMD_CHANGEPASS         (60000)
#define COOLDOWN_JUMP                   (5000)
#define COOLDOWN_CMD_MEDKIT             (30000)
#define RANDOM_BROADCAST_TIME           (300000)

// Accounting
#define MAX_ADMIN_LEVEL         		(6)
#define MAX_PLAYER_IP                   (16)
#define SALT_LENGTH                     (32)

// Scripting
#define DEPRECATED                      stock
#define INVALID_TIMER                   (-1)
#define SCM SendClientMessage
#define SPD ShowPlayerDialog
#define SCMToAll SendClientMessageToAll
#define nocash(%1) GameTextForPlayer(%1, "~g~~h~~h~Not enough money!", 2000, 3)
#define Key(%0) 						(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define function:%1(%2) \
	forward public %1(%2); \
	public %1(%2)

// Gameplay
#define TEAM_Z                          (10)
#define TEAM_H                          (20)
#define ID_HUNTER                       (230)
#define ID_BLOOMER                      (264)
#define DEFAULT_INFESTATION_TIME        (65)
#define DEFAULT_RESCUE_TIME             (420)

// Visuals
#define er                      		"{F42626}[INFO] {D2D2D2}"
#define NO_PERM                     	"{F42626}[INFO] {D2D2D2}Insufficient Permissions"
#define dl                              "{969696}• {F0F0F0}"
#define NOT_AVAIL                       "{2DFF00}Info: {D2D2D2}You can't use this command now!"
#define SEMI_TRANS                      (0x0A0A0A55)
#define SEMI_WHITE                      (0xFEFEFEC3)
#define PURPLE                  		(0x7800FF85)
#define GREEN 							(0x0BDDC400)
#define GREEN2		 					(0x3BBD44FF)
#define RED        						(0xF4262600)
#define ORANGE 							(0xFF96008B)
#define BLUE 							(0x00A5FFFF)
#define YELLOW 							(0xF2F853FF)
#define LIGHT_YELLOW                    (0xFFFF0066)
#define WHITE 							(0xFEFEFEFF)
#define PINK 							(0xFF00EB80)
#define LILA 							(0xFF005FFF)
#define GREY 							(0x8C8C8CFF)
#define BROWN 							(0xA52A2AAA)
#define BLACK       					(0x0A0A0AFF)
#define ADMIN       					(0xF50000FF)
#define BESCH                           (0xE8D04C00)
#define R_BESCH                         (0x00FFB4FF)
#define r_besch                         "{00FFB4}"
#define besch                           "{E8D04C}"
#define lila                            "{FF005F}"
#define vlila                           "{4764EF}"
#define lgreen                          "{88EE88}"
#define green2                          "{43D017}"
#define vgreen                          "{6EF83C}"
#define purple                          "{7800FF}"
#define green                           "{0BDDC4}"
#define yellow                          "{F2F853}"
#define yellow_e                        "{DBED15}"
#define light_yellow                    "{FFFA00}"
#define white                           "{F0F0F0}"
#define blue							"{0087FF}"
#define orange                          "{FFA000}"
#define grey                            "{969696}"
#define red                             "{F42626}"
#define lb_e 							"{15D4ED}"
#define LG_E 							"{00FF00}"
#define LB_E 							"{15D4ED}"
#define COLOR_RED 						(0xFF0000FF)
#define COLOR_HUMAN                     (0x3BBD44FF)
#define COLOR_ZOMBIE                    (0xFF0000FF)
#define RED_E 							"{FF0000}"
#define BLUE_E 							"{004BFF}"
#define PINK_E 							"{FFB6C1}"
#define YELLOW_E 						"{DBED15}"
#define LG_E 							"{00FF00}"
#define LB_E 							"{15D4ED}"
#define LB2_E							"{87CEFA}"
#define GREY_E 							"{BABABA}"
#define GREY2_E 						"{778899}"
#define WHITE_E 						"{FFFFFF}"
#define WHITEP_E 						"{FFE4C4}"
#define IVORY_E 						"{FFFF82}"
#define ORANGE_E 						"{DB881A}"
#define GREEN_E 						"{3BBD44}"
#define PURPLE_E 						"{5A00FF}"

enum E_PLAYER_DATA
{
	/* ORM */
	ORM:pORM,

	/* ACCOUNT */
    iAccountID,
	sName[MAX_PLAYER_NAME + 1],
	sIP[MAX_PLAYER_IP + 1],
	iKills,
	iDeaths,
	iAdminLevel,
	iMapper,
	iEXP,
	iMoney,
	iTime,
	iVIP,
	iSkin,
	iMedkits,
	iCookies,
	iLastLogin,
	iLastNC,
	iTimesKick,
	iTimesLogin,
	iRegisterDate,
	
	/* INTERNAL */
	iLastPM,
	iWarnings,
	iConnectTime,
	iTimesHit,
	gSpecialZed,
	tickLastMedkit,
	tickLastChat,
	tickLastJump,
	tickLastReport,
	tickPlayerUpdate,
	tickLastPW,
	iLastDeathTime,
	iDeathCountThreshold,
	tLoadMap,
	tMedkit,
	iMedkitTime,
	iMute,
	Text3D:t3dVIPLabel,
	iExitType,
	bool:bIsDead,
	bool:bLoadMap,
	bool:bLogged,
	bool:bFirstSpawn,
	bool:bSoundsDisabled,
	bool:bOpenSeason,
	bool:bExploded
};

enum
{
	EXIT_NONE,
	EXIT_LOGGED,
	EXIT_FIRST_SPAWNED
};

enum (+= 21)
{
	NO_DIALOG_ID,
 	DIALOG_REGISTER,
	DIALOG_LOGIN,
	DIALOG_SHOP,
	DIALOG_HELP,
    DIALOG_TOPLIST,
    DIALOG_NAMECHANGE,
    DIALOG_LABEL
};

enum (+= 10)
{
    ACCOUNT_REQUEST_PRELOAD_ID,
	ACCOUNT_REQUEST_BANNED,
	ACCOUNT_REQUEST_IP_BANNED,
	ACCOUNT_REQUEST_AUTO_LOGIN,
	ACCOUNT_REQUEST_LOAD,
	ACCOUNT_REQUEST_GANG_LOAD,
	ACCOUNT_REQUEST_ACHS_LOAD,
	ACCOUNT_REQUEST_TOYS_LOAD,
	ACCOUNT_REQUEST_PVS_LOAD
};

enum
{
	gNONE,
	gZOMBIE,
	gHUMAN
};

enum
{
	zedZOMBIE,
	zedHUNTER,
	zedBLOOMER,
};

enum E_LOG_LEVEL
{
	LOG_INIT,
	LOG_EXIT,
	LOG_ONLINE,
	LOG_NET,
	LOG_PLAYER,
	LOG_WORLD,
	LOG_FAIL,
	LOG_SUSPECT
};

enum E_MAP_DATA
{
	e_id,
	e_mapname[25],
	e_author[MAX_PLAYER_NAME + 1],
	Float:e_spawn_x,
	Float:e_spawn_y,
	Float:e_spawn_z,
	Float:e_spawn_a,
	e_weather,
	e_time,
	Float:e_shop_x,
	Float:e_shop_y,
	Float:e_shop_z,
	e_times_played,
	e_require_preload,
	e_world,
	e_countdown
};

enum
{
	e_Status_Inactive,
	e_Status_Prepare,
	e_Status_Playing,
	e_Status_RoundEnd
};

enum e_top_richlist
{
	E_playerid,
	E_money
};

enum e_top_score
{
	E_playerid,
	E_pscore
};

enum e_top_kills
{
	E_playerid,
	E_kills
};

enum e_top_deaths
{
	E_playerid,
	E_deaths
};

enum e_top_time
{
	E_playerid,
	E_time
};

enum e_top_rtests
{
	E_playerid,
	E_test
};

new	g_pSQL = -1,
	g_World = 0,
	g_ShopID = -1,
	g_GlobalStatus = e_Status_Inactive,
	g_MapCount = 0,
	g_Maps[MAX_MAPS][E_MAP_DATA],
    g_ForceMap = -1,
	g_sReports[MAX_REPORTS][144],
	g_iStartTime,
	bool:g_bMapLoaded = false,
	bool:g_bPlayerHit[MAX_PLAYERS] = {false, ...},
	bool:bGlobalShutdown = false,
	bool:bInfestationArrived = false,
	gstr[144],
	gstr2[255],
	gTeam[MAX_PLAYERS] = {gNONE, ...},
	Text:txtZMPLogo[3],
	Text:txtHealthOverlay,
	Text:txtInfestationArrival,
	Text:txtRescue,
	Text:txtLoading,
	PlayerText:TXTMoney[MAX_PLAYERS],
	PlayerText:TXTScore[MAX_PLAYERS],
	PlayerText:TXTPlayerStats[MAX_PLAYERS],
	PlayerText:TXTMoneyOverlay[MAX_PLAYERS],
	PlayerText:TXTPlayerHealth[MAX_PLAYERS],
	PlayerData[MAX_PLAYERS][E_PLAYER_DATA],
	g_CurrentMap = -1,
	tInfestation = INVALID_TIMER,
	iInfestaion = DEFAULT_INFESTATION_TIME,
	tRescue = INVALID_TIMER,
	iRescue = DEFAULT_RESCUE_TIME,
	iOldMap = -1;
	
static const zedskins[7] =
{
    134,
    135,
    136,
    137,
    168,
    212,
    218
};

static const humanskins[10] =
{
	1,
	10,
	17,
	26,
	145,
	227,
 	249,
 	259,
 	290,
 	299
};

static const g_szRandomServerMessages[9][] =
{
	""yellow_e"- Server - "grey"Visit our site: "FANCY_URL"",
	""yellow_e"- Server - "grey"View /help and /cmds for more information",
	""yellow_e"- Server - "grey"Join our forums! "FANCY_URL"",
	""yellow_e"- Server - "grey"Get VIP (/vip) today! "URL"/vip",
	""yellow_e"- Server - "grey"Saw a cheater? Use /report and don't write in chat",
	""yellow_e"- Server - "grey"Please follow the /rules",
	""yellow_e"- Server - "grey"View changelogs on our forums "URL"",
	""yellow_e"- Server - "grey"Great VIP features are waiting for you (/vip). Constantly updating!",
	""yellow_e"- Server - "grey"Welcome on Zombie Warfare "VERSION""
};

main()
{

}

public OnGameModeInit()
{
	Log(LOG_INIT, "NEF Server Copyright (c)2013 - 2014 "ZWAR_NAME"");
	Log(LOG_INIT, "Mod Zombie Warfare "VERSION"");
	#if IS_RELEASE_BUILD == true
	Log(LOG_INIT, "Build Configuration: Release");
	#else
	Log(LOG_INIT, "Build Configuration: Development");
	#endif
	Log(LOG_INIT, "MySQL: LOG_ALL");
	mysql_log(LOG_ALL, LOG_TYPE_TEXT);

    SQL_Connect();
    SQL_CleanUp();
    
    server_initialize();
    server_load_textdraws();
	server_fetch_mapdata();

    SetTimer("ProcessTick", 1000, 1);
    SetTimer("server_broadcast_random", RANDOM_BROADCAST_TIME, 1);
    
	AddPlayerClass(0, 1958.3783, 1343.1572, 15.3746, 269.1425, 0, 0, 0, 0, 0, 0);
	return 1;
}

public OnGameModeExit()
{
	mysql_stat(gstr2, g_pSQL, sizeof(gstr2));
	Log(LOG_EXIT, "MySQL: %s", gstr2);

    Log(LOG_EXIT, "MySQL: Closing");
	mysql_close(g_pSQL);
	
	Log(LOG_EXIT, "Now exiting.");
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    if(bGlobalShutdown)
		return 0;
    
    TogglePlayerControllable(playerid, 1);
    
    SetTimerEx("ForceClassSpawn", 15, 0, "ii", playerid, YHash(__GetName(playerid)));
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 0; // Yes we block it
}

public OnIncomingConnection(playerid, ip_address[], port)
{
	Log(LOG_NET, "OnIncomingConnection(%i, %s, %i)", playerid, ip_address, port);

	new connections = 0, buffer[16];
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(i == playerid || !IsPlayerConnected(i))
	        continue;

	    GetPlayerIp(i, buffer, sizeof(buffer)); // Not save to use __GetIP here

	    if(!strcmp(buffer, ip_address))
			connections++;
	}

	if(connections >= 3)
	{
	    BlockIpAddress(ip_address, 60000);
	    Log(LOG_NET, "%i connections detected by (%s, %i, %i), hard ipban issued for 60 seconds", connections, ip_address, port, playerid);
	    Kick(playerid);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	ResetPlayerVars(playerid);
	
    GetPlayerName(playerid, PlayerData[playerid][sName], MAX_PLAYER_NAME + 1);
    GetPlayerIp(playerid, PlayerData[playerid][sIP], MAX_PLAYER_IP + 1);
	
	if(bGlobalShutdown)
	{
  		Kick(playerid);
	}
	else
	{
        PlayAudioStreamForPlayer(playerid, "http://s.utnet.net/z/zw.mp3");
		TogglePlayerSpectating(playerid, true);

        player_init_session(playerid);
        ZMP_ShowLogo(playerid);
		
		mysql_format(g_pSQL, gstr, sizeof(gstr), "SELECT `id` FROM `accounts` WHERE `name` = '%e' LIMIT 1;", __GetName(playerid));
		mysql_pquery(g_pSQL, gstr, "OnPlayerAccountRequest", "iii", playerid, YHash(__GetName(playerid)), ACCOUNT_REQUEST_PRELOAD_ID);
 	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    PlayerData[playerid][bLoadMap] = false;
    
   	if(PlayerData[playerid][iExitType] == EXIT_FIRST_SPAWNED && PlayerData[playerid][bLogged])
	{
		SQL_SaveAccount(playerid);
	    SQL_LogPlayerOut(playerid);
	}
	
    switch(gTeam[playerid])
    {
        case gHUMAN:
        {
            gTeam[playerid] = gNONE;

            if(g_GlobalStatus == e_Status_Playing)
            {
				if(ZMP_GetPlayers() == 0) // Going inactive
				{
					Map_Unload();
					g_GlobalStatus = e_Status_Inactive;
					
			        KillTimer(tRescue);
			        KillTimer(tInfestation);
				}
	            else if(ZMP_GetPlayers() == 1 || ZMP_GetHumans() == 0)
	            {
			        TextDrawSetString(txtRescue, "~w~Rescue abandoned!");

			        if(!bInfestationArrived) GameTextForAll("~w~Zombies win!", 10000, 5);

					ZMP_EndGame();

			        format(gstr, sizeof(gstr), ""zwar" Round end! Humans left: "lb_e"%i "white"| Zombies: "lb_e"%i", ZMP_GetHumans(), ZMP_GetZombies());
			        SCMToAll(-1, gstr);
				}
			}
        }
        case gZOMBIE:
        {
            gTeam[playerid] = gNONE;

            if(g_GlobalStatus == e_Status_Playing)
            {
				if(ZMP_GetPlayers() == 0) // Going inactive
				{
					Map_Unload();
					g_GlobalStatus = e_Status_Inactive;
					
					KillGameTimers();
				}
	            else if(ZMP_GetPlayers() == 1)
	            {
			        TextDrawSetString(txtRescue, "~w~Rescue abandoned!");

			        if(!bInfestationArrived) GameTextForAll("~w~Humans win!", 10000, 5);

					ZMP_EndGame();

			        format(gstr, sizeof(gstr), ""zwar" Round end! Humans left: "lb_e"%i "white"| Zombies: "lb_e"%i", ZMP_GetHumans(), ZMP_GetZombies());
			        SCMToAll(-1, gstr);
				}
	            else if(ZMP_GetZombies() == 0)
	            {
	                ZMP_RandomInfection();
	            }
			}
        }
    }
	
	gTeam[playerid] = gNONE;
		
    ResetPlayerVars(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	PlayerData[playerid][bIsDead] = false;

	ZMP_HideLogo(playerid);
	
	if(PlayerData[playerid][bFirstSpawn])
	{
	    PlayerData[playerid][bFirstSpawn] = false;
	    PlayerData[playerid][iExitType] = EXIT_FIRST_SPAWNED;
	    
	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	    SetCameraBehindPlayer(playerid);
	    StopAudioStreamForPlayer(playerid);
	    
		TextDrawShowForPlayer(playerid, txtHealthOverlay);
		PlayerTextDrawShow(playerid, TXTMoneyOverlay[playerid]);
		PlayerTextDrawShow(playerid, TXTPlayerStats[playerid]);
		PlayerTextDrawShow(playerid, TXTPlayerHealth[playerid]);
	}
	
	ZMP_UpdatePlayerHealthTD(playerid);
	
	switch(g_GlobalStatus)
	{
		case e_Status_Inactive: // Server was probably empty and this player is the first one
		{
		    ZMP_BeginNewGame();
		}
		case e_Status_Prepare: // Round is in prepare phase
		{
			ZMP_SetPlayerHuman(playerid);
			ZMP_SyncPlayer(playerid);
			
			TextDrawShowForPlayer(playerid, txtInfestationArrival);
			LoadMap(playerid);
		}
		case e_Status_Playing: // Round already started
		{
		    if(gTeam[playerid] == gHUMAN)
				ZMP_SetPlayerHuman(playerid);
			else
				ZMP_SetPlayerZombie(playerid);

			ZMP_SyncPlayer(playerid);

			TextDrawShowForPlayer(playerid, txtRescue);
			LoadMap(playerid);
		}
		case e_Status_RoundEnd: // Rounde ended and is scheduled for restart
		{
			SetPlayerPos(playerid, g_Maps[g_CurrentMap][e_spawn_x], g_Maps[g_CurrentMap][e_spawn_y], g_Maps[g_CurrentMap][e_spawn_z] + 4.0);
			SetPlayerFacingAngle(playerid, g_Maps[g_CurrentMap][e_spawn_a]);
			TogglePlayerControllable(playerid, 0);
		}
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	// Closing open dialogs in order to avoid some exploits.
	ShowPlayerDialog(playerid, -1, DIALOG_STYLE_LIST, "Close", "Close", "Close", "Close");
	
    PlayerData[playerid][bIsDead] = true;
	
	new cstime = gettime(); // http://forum.sa-mp.com/showpost.php?p=1820351&postcount=41
	switch(cstime - PlayerData[playerid][iLastDeathTime])
	{
	    case 0..3:
	    {
		    if(++PlayerData[playerid][iDeathCountThreshold] == 4)
		    {
			    format(gstr, sizeof(gstr), "[SUSPECT] Fake deaths/kills detected, kicking (%s, %i)", __GetName(playerid), playerid);
			    //admin_broadcast(RED, gstr);
			    Log(LOG_NET, gstr);
				return Kick(playerid);
		    }
	    }
	    default: PlayerData[playerid][iDeathCountThreshold] = 0;
	}
	PlayerData[playerid][iLastDeathTime] = cstime;
    
    PlayerData[playerid][iDeaths]++;
    ZMP_PlayerStatsUpdate(playerid);
	SendDeathMessage(killerid, playerid, reason);
    
	if(PlayerData[playerid][bLoadMap])
	{
		KillTimer(PlayerData[playerid][tLoadMap]);
		PlayerData[playerid][tLoadMap] = -1;
		PlayerData[playerid][bLoadMap] = false;
		TogglePlayerControllable(playerid, 1);
		TextDrawHideForPlayer(playerid, txtLoading);
	}
    
    if(IsPlayerAvail(killerid))
    {
        PlayerData[killerid][iKills]++;
        ZMP_PlayerStatsUpdate(killerid);

		if(gTeam[killerid] == gZOMBIE && gTeam[playerid] == gHUMAN)
		{
			if(ZMP_GetHumans() == 0)
			{
		        TextDrawSetString(txtRescue, "~w~Rescue abandoned!");
		        GameTextForAll("~w~Zombies win!", 10000, 5);

				ZMP_EndGame();

		        format(gstr, sizeof(gstr), ""zwar" Round end! Humans left: "lb_e"%i "white"| Zombies: "lb_e"%i", ZMP_GetHumans(), ZMP_GetZombies());
		        SCMToAll(-1, gstr);
			}
			else
			{
				SCM(playerid, -1, ""er"You have been infected! Now infect humans by punching them!");
				gTeam[playerid] = gZOMBIE;
				PlayInfectSound();
			}
			
            GivePlayerMoneyEx(killerid, 1700);
            GivePlayerScoreEx(killerid, 4);
		}
		else if(gTeam[playerid] == gZOMBIE && gTeam[killerid] == gHUMAN)
		{
		    switch(PlayerData[playerid][gSpecialZed])
		    {
		        case zedZOMBIE:
		        {
		            GivePlayerMoneyEx(killerid, 1500);
		            GivePlayerScoreEx(killerid, 3);
		        }
		        case zedHUNTER:
		        {
		            GivePlayerMoneyEx(killerid, 2000);
		            GivePlayerScoreEx(killerid, 5);
		        }
		        case zedBLOOMER:
		        {
		            GivePlayerMoneyEx(killerid, 2000);
		            GivePlayerScoreEx(killerid, 5);
		        }
		    }
		}
	}
	else if(g_GlobalStatus == e_Status_Playing)
	{
	    if(gTeam[playerid] == gHUMAN)
	    {
			SCM(playerid, -1, ""er"You have been infected! Now infect humans by punching them!");
			gTeam[playerid] = gZOMBIE;
			PlayInfectSound();
		}
		
		if(ZMP_GetHumans() == 0)
		{
	        TextDrawSetString(txtRescue, "~w~Rescue abandoned!");
	        GameTextForAll("~w~Zombies win!", 10000, 5);

			ZMP_EndGame();

	        format(gstr, sizeof(gstr), ""zwar" Round end! Humans left: "lb_e"%i "white"| Zombies: "lb_e"%i", ZMP_GetHumans(), ZMP_GetZombies());
	        SCMToAll(-1, gstr);
		}
	}
    
    ZMP_ShowLogo(playerid);
	return 1;
}

public OnPlayerText(playerid, text[])
{
    if(PlayerData[playerid][bOpenSeason])
		return 0;

	if(PlayerData[playerid][iExitType] != EXIT_FIRST_SPAWNED)
	{
	    SCM(playerid, -1, ""er"You need to spawn to use the chat!");
	    return 0;
	}

	if(gettime() < PlayerData[playerid][iMute])
	{
	    SCM(playerid, RED, "You are muted! Wait until the time is over.");
	    return 0;
	}
	PlayerData[playerid][iMute] = 0;

	if(strfind(text, "/q", true) != -1 || strfind(text, "/ q", true) != -1)
	{
		SCM(playerid, -1, ""er"Please do not type /q in chat");
  		return 0;
  	}
	
    new File:lFile = fopen("Logs/chatlog.txt", io_append),
        time[3];

    gettime(time[0], time[1], time[2]);

    format(gstr2, sizeof(gstr2), "[%02d:%02d:%02d] [%i]%s: %s \r\n", time[0], time[1], time[2], playerid, __GetName(playerid), text);
    fwrite(lFile, gstr2);
    fclose(lFile);

	if(IsAd(text))
	{
	  	format(gstr, sizeof(gstr), ""yellow"** "red"Suspicion advertising | Player: %s(%i) Advertised IP: %s - PlayerIP: %s", __GetName(playerid), playerid, text, __GetIP(playerid));
		broadcast_admin(RED, gstr);

        SCM(playerid, RED, "Advertising is not allowed!");
        return 0;
	}
	
	if(text[0] == '#' && PlayerData[playerid][iAdminLevel] >= 1)
	{
		format(gstr, sizeof(gstr), "[ADMIN CHAT] "LG_E"%s(%i): "LB_E"%s", __GetName(playerid), playerid, text[1]);
		broadcast_admin(COLOR_RED, gstr);
		return 0;
	}

	SetPlayerChatBubble(playerid, text, WHITE, 50.0, 7000);

	if(strlen(text) > 80)
	{
		new pos = strfind(text, " ", true, 60);
		
		if(pos == -1 || pos > 80)
			pos = 70;

		gstr[0] = EOS;
		
		if(PlayerData[playerid][iAdminLevel] != 0)
			strcat(gstr, "{A8DBFF}");

		strcat(gstr, text[pos], sizeof(gstr));
		text[pos] = EOS;

		if(PlayerData[playerid][iAdminLevel] == 0)
		{
			format(gstr2, sizeof(gstr2), "{%06x}%s"white"(%i): %s", GetPlayerColor(playerid) >>> 8, __GetName(playerid), playerid, text);
			SCMToAll(-1, gstr2);
			SCMToAll(-1, gstr);
		}
		else
		{
			format(gstr2, sizeof(gstr2), "{%06x}%s"white"(%i): {A8DBFF}%s", GetPlayerColor(playerid) >>> 8, __GetName(playerid), playerid, text);
			SCMToAll(-1, gstr2);
			SCMToAll(-1, gstr);
		}
	}
	else
	{
		if(PlayerData[playerid][iAdminLevel] == 0)
		{
	 		format(gstr, sizeof(gstr), "{%06x}%s"white"(%i): %s", GetPlayerColor(playerid) >>> 8, __GetName(playerid), playerid, text);
			SCMToAll(-1, gstr);
  		}
		else
		{
 	 		format(gstr, sizeof(gstr), "{%06x}%s"white"(%i): {A8DBFF}%s", GetPlayerColor(playerid) >>> 8, __GetName(playerid), playerid, text);
			SCMToAll(-1, gstr);
		}
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerPickUpDynamicPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	printf("[CHEAT] [%i]%s mods a vehicle", playerid, __GetName(playerid));
	return 0;
}

public OnPlayerUpdate(playerid)
{
    PlayerData[playerid][tickPlayerUpdate] = GetTickCountEx();
    
    if(IsPlayerAvail(playerid))
    {
	    if(g_GlobalStatus == e_Status_Playing)
	    {
		    new id = GetPlayerWeapon(playerid);

		    if(gTeam[playerid] == gZOMBIE && id != 0)
		    {
				ResetPlayerWeapons(playerid);
				return 0;
		    }
	    
		    switch(id)
		    {
		        case 38, 37, 36, 35:
		        {
		            if(!PlayerData[playerid][bOpenSeason])
		            {
		                PlayerData[playerid][bOpenSeason] = true;
			            ResetPlayerWeapons(playerid);
			            format(gstr2, sizeof(gstr2), ""yellow"** "red"%s(%i) has been auto-kicked by BitchOnDuty [Reason: Weapon cheats]", __GetName(playerid), playerid);
			            SCMToAll(-1, gstr2);
			            print(gstr2);
			            Kick(playerid);
					}
		            return 0;
				}
		    }
		}
	}
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(Key(KEY_JUMP) && gTeam[playerid] == gZOMBIE && PlayerData[playerid][gSpecialZed] == zedHUNTER && g_GlobalStatus == e_Status_Playing)
	{
	    new tick = GetTickCountEx();
		if((PlayerData[playerid][tickLastJump] + COOLDOWN_JUMP) >= tick)
		{
	    	return 1;
		}
		
	    new Float:POS[3];
		GetPlayerVelocity(playerid, POS[0], POS[1], POS[2]);
		SetPlayerVelocity(playerid, POS[0], POS[1], floatadd(POS[2], 1.5));

		PlayerData[playerid][tickLastJump] = tick;
	}
	if((Key(KEY_YES) || Key(KEY_NO)) && gTeam[playerid] == gZOMBIE && PlayerData[playerid][gSpecialZed] == zedBLOOMER && !PlayerData[playerid][bIsDead] && g_GlobalStatus == e_Status_Playing)
	{
	    if(!PlayerData[playerid][bExploded])
	    {
	        PlayerData[playerid][bExploded] = true;

			new Float:POS[3];
			GetPlayerPos(playerid, POS[0], POS[1], POS[2]);
            SetPlayerHealth(playerid, 0.0);
			CreateExplosion(POS[0], POS[1], POS[2]+0.5, 1, 10);
			GameTextForPlayer(playerid, "~w~You exploded and infected all humans in range!", 3000, 3);

			for(new i = 0; i < MAX_PLAYERS; i++)
			{
			    if(GetDistanceBetweenPlayers(playerid, i) <= 2.5 && IsPlayerAvail(i) && i != playerid)
			    {
				    GameTextForPlayer(i, "~w~Infected!", 3000, 5);
					SCM(i, -1, ""er"You have been infected! Now infect humans by punching them!");
					ZMP_SetPlayerZombie(i, false);

			        GivePlayerMoneyEx(playerid, 2000);
			        GivePlayerScoreEx(playerid, 5);
			        PlayerData[playerid][iKills]++;
                    PlayInfectSound();
                    
					if(ZMP_GetHumans() == 0)
					{
				        TextDrawSetString(txtRescue, "~w~Rescue abandoned!");

				        GameTextForAll("~w~Zombies win!", 10000, 5);

						ZMP_EndGame();

				        format(gstr, sizeof(gstr), ""zwar" Round end! Humans left: "lb_e"%i "white"| Zombies: "lb_e"%i", ZMP_GetHumans(), ZMP_GetZombies());
				        SCMToAll(-1, gstr);
					}
			    }
			}
		}
	}
	/*if(Key(KEY_FIRE) && gTeam[playerid] == gZOMBIE && !PlayerData[playerid][bIsDead])
	{
        if(GetPlayerWeapon(playerid) == 9 || GetPlayerWeapon(playerid) == 0)
		{
            new victimid = GetClosestPlayer(playerid);
            if(IsPlayerAvail(victimid) && gTeam[victimid] == gHUMAN)
			{
                if(GetDistanceBetweenPlayers(playerid, victimid) < 1.5)
				{
				    if(PlayerData[victimid][iTimesHit] >= 2)
				    {
				        PlayerData[victimid][iTimesHit] = 0;
				        
					    GameTextForPlayer(victimid, "~w~Infected!", 3000, 5);
						SCM(victimid, -1, ""er"You have been infected! Now infect humans by punching them!");
						ZMP_SetPlayerZombie(victimid, false);

				        GivePlayerMoneyEx(playerid, 2000);
				        GivePlayerScoreEx(playerid, 5);

	                    PlayInfectSound();
						if(ZMP_GetHumans() == 0)
						{
					        TextDrawSetString(txtRescue, "~w~Rescue abandoned!");

					        GameTextForAll("~w~Zombies win!", 10000, 5);

							ZMP_EndGame();

					        KillTimer(tRescue);
					        KillTimer(tInfestation);

					        new str[144];
					        format(str, sizeof(str), ""zwar" Round end! Humans left: "lb_e"%i "white"| Zombies: "lb_e"%i", ZMP_GetHumans(), ZMP_GetZombies());
					        SCMToAll(-1, str);
						}
					}
					else
					{
					    PlayerData[victimid][iTimesHit]++;
					}
                }
            }
        }
	}*/
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	for(new i = 0, l = strlen(inputtext); i < l; i++)
	{
		if(inputtext[i] == '%' || inputtext[i] == ''')
		{
			inputtext[i] = '#';
		}
	}
	
	if(response)
	{
	    switch(dialogid)
	    {
	        case DIALOG_LABEL:
	        {
	            if(strlen(inputtext) > 35 || strlen(inputtext) < 3)
					return SCM(playerid, -1, ""er"Inputlength: 3-35");

	            new text[37];
	            sscanf(inputtext, "s[36]", text);

				if(IsAd(text))
				{
				  	format(gstr, sizeof(gstr), ""yellow"** "red"Suspicion advertising | Player: %s(%i) Advertised IP: %s - PlayerIP: %s", __GetName(playerid), playerid, text, __GetIP(playerid));
					broadcast_admin(RED, gstr);

			        SCM(playerid, RED, "Advertising is not allowed!");
			        return 1;
				}

	            PlayerData[playerid][t3dVIPLabel] = CreateDynamic3DTextLabel(text, -1, 0.0, 0.0, 0.65, 20.0, playerid, INVALID_VEHICLE_ID, 1, -1, -1, -1, 20.0);

                SCM(playerid, -1, ""er"Label attached! Note: You can't see the label yourself");
				return true;
	        }
	        case DIALOG_LABEL + 1:
	        {
	            if(strlen(inputtext) > 35 || strlen(inputtext) < 3) return SCM(playerid, -1, ""er"Inputlength: 3-35");

	            new text[37];
	            sscanf(inputtext, "s[36]", text);

				if(IsAd(text))
				{
				  	format(gstr, sizeof(gstr), ""yellow"** "red"Suspicion advertising | Player: %s(%i) Advertised IP: %s - PlayerIP: %s", __GetName(playerid), playerid, text, __GetIP(playerid));
					broadcast_admin(RED, gstr);

			        SCM(playerid, RED, "Advertising is not allowed!");
			        return 1;
				}

				UpdateDynamic3DTextLabelText(PlayerData[playerid][t3dVIPLabel], -1, text);
	            SCM(playerid, -1, ""er"Label text changed!");
	            return true;
	        }
	        case DIALOG_NAMECHANGE:
	        {
	            if(strlen(inputtext) > 21 || strlen(inputtext) < 3) return SCM(playerid, -1, ""er"Name length: 3-21");
                if(!strcmp(inputtext, __GetName(playerid), false)) return SCM(playerid, -1, ""er"You are already using that name");
	            if(!strcmp(inputtext, __GetName(playerid), true)) return SCM(playerid, -1, ""er"The name only differs in case. Just relog with that.");

				new newname[MAX_PLAYER_NAME + 1];
				mysql_escape_string(inputtext, newname, g_pSQL, MAX_PLAYER_NAME + 1);

                format(gstr, sizeof(gstr), "SELECT `id` FROM `accounts` WHERE `name` = '%s';", newname);
                mysql_tquery(g_pSQL, gstr, "OnPlayerNameChangeRequest", "is", playerid, newname);
	            return true;
	        }
	        case DIALOG_TOPLIST:
	        {
	            switch(listitem)
	            {
	                case 0: Command_ReProcess(playerid, "/richlist", false);
	                case 1: Command_ReProcess(playerid, "/score", false);
	                case 2: Command_ReProcess(playerid, "/kills", false);
	                case 3: Command_ReProcess(playerid, "/deaths", false);
                    case 4: Command_ReProcess(playerid, "/toptime", false);
				}
	            return true;
	        }
	        case DIALOG_LOGIN:
			{
				if(strlen(inputtext) < 3 || strlen(inputtext) > 32)
				{
				    SCM(playerid, -1, ""er"Password length: 3 - 32 characters");
					return RequestLogin(playerid);
				}
				if(isnull(inputtext)) return RequestLogin(playerid);
				extract inputtext -> new string:password[33]; else
				{
				    SCM(playerid, -1, ""er"Length 3 - 32");
					return RequestLogin(playerid);
				}

				mysql_format(g_pSQL, gstr2, sizeof(gstr2), "SELECT `hash`, `salt` FROM `accounts` WHERE `id` = %i LIMIT 1;", PlayerData[playerid][iAccountID]);
				mysql_tquery(g_pSQL, gstr2, "OnPlayerLoginAttempt", "iis", playerid, YHash(__GetName(playerid)), password);
			    return true;
			}
	        case DIALOG_REGISTER:
			{
			    if(strlen(inputtext) < 3 || strlen(inputtext) > 32)
				{
					SCM(playerid, -1, ""er"Password length: 3 - 32 characters");
					return RequestRegistration(playerid);
				}
				if(isnull(inputtext)) return RequestRegistration(playerid);
				extract inputtext -> new string:password[33]; else
				{
					return RequestRegistration(playerid);
				}

				new hash[SHA3_LENGTH + 1];
				sha3(password, hash, sizeof(hash));

			    SQL_RegisterAccount(playerid, hash);
			    return true;
			}
			case DIALOG_SHOP:
			{
			    switch(listitem)
			    {
			        case 0:
			        {
			    		ShowPlayerDialog(playerid, DIALOG_SHOP + 1, DIALOG_STYLE_LIST, ""zwar" - Shop > Weapons", "$500\tChainsaw\n$800\tMolotov Cocktail\n$400\tDesert Eagle\n$320\tShotgun\n$550\tCombat Shotgun\n$500\tMP5\n$600\tAK-47\n$620\tM4\n$500\tTEC-9\n$700\tSniper", "Buy", "Back");
					}
					case 1:
					{
					    ShowPlayerDialog(playerid, DIALOG_SHOP + 2, DIALOG_STYLE_LIST, ""zwar" - Shop > Skins", "$50\tAndre\n$75\tBarry \"Big Bear\" Thorne [Big]\n$65\tTruth\n$30\tUnemployed\n$100\tBackpacker\n$80\tMafia Boss\n$50\tJohhny Sindacco\n$75\tFarm Inhabitant\n$100\tBig Smoke Armored\n$90\tBlack MIB agent\n$150\tJeffery \"OG Loc\" Martin/Cross\n$200\tClaude Speed\n$190\tMichael Toreno", "Buy", "Back");
					}
					case 2:
					{
					    ShowPlayerDialog(playerid, DIALOG_SHOP + 3, DIALOG_STYLE_LIST, ""zwar" - Shop > V.I.P Packages", ""white"FREE\tUZI\n$300\tSawn-Off\nFREE\tJizzy\nFREE\tKatana", "Select", "Back");
					}
					case 3:
					{
			            if(GetPlayerMoneyEx(playerid) < 900) return nocash(playerid);
			            PlayerData[playerid][iMedkits]++;
			            GivePlayerMoneyEx(playerid, -900);
			            SCM(playerid, -1, ""er"Use /med to consume a medkit!");
					}
				}
				return true;
			}
			case DIALOG_SHOP + 1:
			{
			    switch(listitem)
			    {
			        case 0: // Chainsaw
			        {
			            if(GetPlayerMoneyEx(playerid) < 500) return nocash(playerid);
			            GivePlayerWeapon(playerid, 9, 1);
			            GivePlayerMoneyEx(playerid, -500);
			        }
			        case 1: // Molotov Cocktail
			        {
			            if(GetPlayerMoneyEx(playerid) < 800) return nocash(playerid);
			            GivePlayerWeapon(playerid, 18, 3);
			            GivePlayerMoneyEx(playerid, -800);
			        }
			        case 2: // Desert Eaogle
			        {
			            if(GetPlayerMoneyEx(playerid) < 400) return nocash(playerid);
			            GivePlayerWeapon(playerid, 24, 50);
			            GivePlayerMoneyEx(playerid, -400);
			        }
			        case 3: // Shotgun
			        {
			            if(GetPlayerMoneyEx(playerid) < 320) return nocash(playerid);
			            GivePlayerWeapon(playerid, 25, 45);
			            GivePlayerMoneyEx(playerid, -320);
			        }
			        case 4: // Combat Shotgun
			        {
			            if(GetPlayerMoneyEx(playerid) < 550) return nocash(playerid);
			            GivePlayerWeapon(playerid, 27, 65);
			            GivePlayerMoneyEx(playerid, -550);
			        }
			        case 5: // MP5
			        {
			            if(GetPlayerMoneyEx(playerid) < 500) return nocash(playerid);
			            GivePlayerWeapon(playerid, 29, 150);
			            GivePlayerMoneyEx(playerid, -500);
			        }
			        case 6: // Ak-47
			        {
			            if(GetPlayerMoneyEx(playerid) < 600) return nocash(playerid);
			            GivePlayerWeapon(playerid, 30, 170);
			            GivePlayerMoneyEx(playerid, -600);
			        }
			        case 7: // M4
			        {
			            if(GetPlayerMoneyEx(playerid) < 620) return nocash(playerid);
			            GivePlayerWeapon(playerid, 31, 170);
			            GivePlayerMoneyEx(playerid, -620);
			        }
			        case 8: // TEC-9
			        {
			            if(GetPlayerMoneyEx(playerid) < 500) return nocash(playerid);
			            GivePlayerWeapon(playerid, 32, 150);
			            GivePlayerMoneyEx(playerid, -500);
			        }
			        case 9: // Sniper
			        {
			            if(GetPlayerMoneyEx(playerid) < 700) return nocash(playerid);
			            GivePlayerWeapon(playerid, 34, 30);
			            GivePlayerMoneyEx(playerid, -700);
			        }
			    }
			    ShowPlayerDialog(playerid, DIALOG_SHOP, DIALOG_STYLE_LIST, ""zwar" - Shop", ""dl"Weapons\n"dl"Skins\n"dl"V.I.P Packages\n"dl"$900\tMedkit", "Select", "Cancel");
			    return true;
			}
			case DIALOG_SHOP + 2:
			{
			    switch(listitem)
			    {
			        case 0: // Andre
			        {
			            if(GetPlayerMoneyEx(playerid) < 50) return nocash(playerid);
			            SetPlayerSkin(playerid, 3);
			            GivePlayerMoneyEx(playerid, -50);
			        }
			        case 1: // Barry "Big Bear" Thorne [Big]
			        {
			            if(GetPlayerMoneyEx(playerid) < 75) return nocash(playerid);
			            SetPlayerSkin(playerid, 5);
						GivePlayerMoneyEx(playerid, -75);
			        }
			        case 2: // Truth
			        {
			            if(GetPlayerMoneyEx(playerid) < 65) return nocash(playerid);
			            SetPlayerSkin(playerid, 1);
						GivePlayerMoneyEx(playerid, -65);
			        }
			        case 3: // Unemployed
			        {
			            if(GetPlayerMoneyEx(playerid) < 30) return nocash(playerid);
			            SetPlayerSkin(playerid, 78);
						GivePlayerMoneyEx(playerid, -30);
			        }
			        case 4: // Backpacker
			        {
			            if(GetPlayerMoneyEx(playerid) < 100) return nocash(playerid);
			            SetPlayerSkin(playerid, 26);
						GivePlayerMoneyEx(playerid, -100);
			        }
			        case 5: // Mafia Boss
			        {
			            if(GetPlayerMoneyEx(playerid) < 80) return nocash(playerid);
			            SetPlayerSkin(playerid, 112);
						GivePlayerMoneyEx(playerid, -80);
			        }
			        case 6: // Johhny Sindacco
			        {
			            if(GetPlayerMoneyEx(playerid) < 50) return nocash(playerid);
			            SetPlayerSkin(playerid, 119);
						GivePlayerMoneyEx(playerid, -50);
			        }
			        case 7: // Farm Inhabitant
			        {
			            if(GetPlayerMoneyEx(playerid) < 75) return nocash(playerid);
			            SetPlayerSkin(playerid, 128);
						GivePlayerMoneyEx(playerid, -75);
			        }
			        case 8: // Big Smoke Armored
			        {
			            if(GetPlayerMoneyEx(playerid) < 100) return nocash(playerid);
			            SetPlayerSkin(playerid, 149);
						GivePlayerMoneyEx(playerid, -100);
			        }
			        case 9: // Black MIB agent
			        {
			            if(GetPlayerMoneyEx(playerid) < 90) return nocash(playerid);
			            SetPlayerSkin(playerid, 166);
						GivePlayerMoneyEx(playerid, -90);
			        }
			        case 10: // Jeffery "OG Loc" Martin/Cross
			        {
			            if(GetPlayerMoneyEx(playerid) < 150) return nocash(playerid);
			            SetPlayerSkin(playerid, 293);
						GivePlayerMoneyEx(playerid, -150);
			        }
			        case 11: // Claude Speed
			        {
			            if(GetPlayerMoneyEx(playerid) < 200) return nocash(playerid);
			            SetPlayerSkin(playerid, 299);
						GivePlayerMoneyEx(playerid, -200);
			        }
			        case 12: // Michael Toreno
			        {
			            if(GetPlayerMoneyEx(playerid) < 190) return nocash(playerid);
			            SetPlayerSkin(playerid, 295);
						GivePlayerMoneyEx(playerid, -190);
			        }
			    }
			    ShowPlayerDialog(playerid, DIALOG_SHOP, DIALOG_STYLE_LIST, ""zwar" - Shop", ""dl"Weapons\n"dl"Skins\n"dl"V.I.P Packages\n"dl"$900 Medkit", "Select", "Cancel");
			    return true;
			}
			case DIALOG_SHOP + 3:
			{
			    if(PlayerData[playerid][iVIP] == 0) return SCM(playerid, -1, ""er"You need to be V.I.P");
			    switch(listitem)
			    {
			        case 0:
			        {
			            GivePlayerWeapon(playerid, 28, 150);
			        }
			        case 1:
			        {
			            if(GetPlayerMoneyEx(playerid) < 300) return nocash(playerid);
			            GivePlayerWeapon(playerid, 26, 46);
						GivePlayerMoneyEx(playerid, -300);
			        }
			        case 2:
			        {
			            SetPlayerSkin(playerid, 296);
			        }
			        case 3:
			        {
			            GivePlayerWeapon(playerid, 8, 1);
			        }
			    }
			    ShowPlayerDialog(playerid, DIALOG_SHOP, DIALOG_STYLE_LIST, ""zwar" - Shop", ""dl"Weapons\n"dl"Skins\n"dl"V.I.P Packages\n"dl"$900 Medkit", "Select", "Cancel");
			    return true;
			}
			case DIALOG_HELP:
			{
			    switch(listitem)
			    {
					case 0:
					{
					    ShowPlayerDialog(playerid, DIALOG_HELP + 1, DIALOG_STYLE_MSGBOX, ""zwar" - Help", ""dl"What can I do on this server?\n\nSurvive with others, when you get infected, go and hunt humans!", "OK", "Back");
					}
					case 1:
					{
					    ShowPlayerDialog(playerid, DIALOG_HELP + 2, DIALOG_STYLE_MSGBOX, ""zwar" - Help", ""dl"How do I infect others?\n\nPunch humans to infect them.", "OK", "Back");
					}
					case 2:
					{
					    ShowPlayerDialog(playerid, DIALOG_HELP + 3, DIALOG_STYLE_MSGBOX, ""zwar" - Help", ""dl"How do I get money/score and what can I do with it?\n\nKill zombies or infect humans to get money and score. You can\nspend your money on weapons, equipment and skins.", "OK", "Back");
					}
					case 3:
					{
					    ShowPlayerDialog(playerid, DIALOG_HELP + 4, DIALOG_STYLE_MSGBOX, ""zwar" - Help", ""dl"How do I become a V.I.P?\n\nSimply go to "URL"/vip.php", "OK", "Back");
					}
					case 4:
					{
					    ShowPlayerDialog(playerid, DIALOG_HELP + 5, DIALOG_STYLE_MSGBOX, ""zwar" - Help", ""dl"I found a bug/glitch where can I report it?\n\nPlease report them on our forums "URL"", "OK", "Back");
					}
					case 5:
					{
					    ShowPlayerDialog(playerid, DIALOG_HELP + 6, DIALOG_STYLE_MSGBOX, ""zwar" - Help", ""dl"I have more questions!\n\nFeel free to join our forums for questions "URL"", "OK", "Back");
					}
					case 6:
					{
					    ShowPlayerDialog(playerid, DIALOG_HELP + 7, DIALOG_STYLE_MSGBOX, ""zwar" - Help", ""dl"How do I use medkits?\n\nUse /mk to consume them. See /stats for amount available.", "OK", "Back");
					}
			    }
			    return true;
			}
	    }
	}
	else if(!response)
	{
	    switch(dialogid)
	    {
	        case DIALOG_HELP +1..DIALOG_HELP+7:
	        {
	            Command_ReProcess(playerid, "/help", false);
	            return true;
	        }
	        case DIALOG_SHOP + 1..DIALOG_SHOP + 3:
	        {
	            ShowPlayerDialog(playerid, DIALOG_SHOP, DIALOG_STYLE_LIST, ""zwar" - Shop", ""dl"Weapons\n"dl"Skins\n"dl"V.I.P Packages\n"dl"$900 Medkit", "Select", "Cancel");
	            return true;
	        }
	        case DIALOG_LOGIN:
	        {
				RequestLogin(playerid);
	            return true;
	        }
	        case DIALOG_REGISTER:
	        {
	            RequestRegistration(playerid);
	            return true;
	        }
	    }
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	if(IsPlayerAvail(playerid))
	{
		new string[30];
		format(string, sizeof(string), "/stats %i", clickedplayerid);
		Command_ReProcess(playerid, string, false);
	}
	return 1;
}

public OnQueryError(errorid, error[], callback[], query[], connectionHandle)
{
	Log(LOG_FAIL, "MySQL: OnQueryError(%i, %s, %s, %s, %i)", errorid, error, callback, query, connectionHandle);
	return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[])
{
	if(PlayerData[playerid][bIsDead])
	{
	    SCM(playerid, -1, ""er"You can't use commands while being dead!");
	    return 0;
	}
	if(PlayerData[playerid][iExitType] != EXIT_FIRST_SPAWNED)
	{
	    SCM(playerid, -1, ""er"You need to spawn to use commands!");
	    return 0;
	}
	if(PlayerData[playerid][bLoadMap])
	{
	    SCM(playerid, -1, ""er"You can't use commands now!");
	    return 0;
	}

	ShowPlayerDialog(playerid, -1, DIALOG_STYLE_LIST, "Close", "Close", "Close", "Close");
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
    new File:lFile = fopen("Logs/cmdlog.txt", io_append),
        time[3];

    gettime(time[0], time[1], time[2]);

    format(gstr2, sizeof(gstr2), "[%02d:%02d:%02d] [%i]%s -> %s success: %i\r\n", time[0], time[1], time[2], playerid, __GetName(playerid), cmdtext, success);
    fwrite(lFile, gstr2);
    fclose(lFile);

	if(!success)
	{
	    SCM(playerid, -1, ""er" This command does not exist! Try /cmds and /help");
	    PlaySound(playerid, 1085);
	}
	return 1;
}

public OnPlayerEnterDynamicCP(playerid, checkpointid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING) return 1;
    
    if(checkpointid == g_ShopID && gTeam[playerid] == gHUMAN && g_GlobalStatus == e_Status_Prepare)
    {
        ShowPlayerDialog(playerid, DIALOG_SHOP, DIALOG_STYLE_LIST, ""zwar" - Shop", ""dl"Weapons\n"dl"Skins\n"dl"V.I.P Packages\n"dl"$900 Medkit", "Select", "Cancel");
    }
	return 1;
}

/* AUTHORITATIVE SERVER */
public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	/* Bullet Crasher http://forum.sa-mp.com/showthread.php?t=535559 */
	if(hittype == BULLET_HIT_TYPE_PLAYER) {
	    if( !( -20.0 <= fX <= 20.0 ) || !( -20.0 <= fY <= 20.0 ) || !( -20.0 <= fZ <= 20.0 ) ) {
		    return 0;
  		}
	}

	/* ANTI FAKE DATA */
	if(weaponid == 0) {
		Log(LOG_SUSPECT, "OPWS triggered by %i using %i, %i, %i", playerid, weaponid, hittype, hitid);
	    return 0;
	}
	
	/* PLAYER QUEUED FOR KICK */
	if(hittype == BULLET_HIT_TYPE_PLAYER) {
	    if(hitid != INVALID_PLAYER_ID) {
		    if(PlayerData[playerid][bOpenSeason] || PlayerData[hitid][bOpenSeason]) {
		        return 0;
		    }
		}
	}
	return 1;
}

public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z)
{
	if(PlayerData[playerid][bOpenSeason]) {
		return 0;
	}
	return 1;
}

public OnTrailerUpdate(playerid, vehicleid)
{
	if(PlayerData[playerid][bOpenSeason]) {
		return 0;
	}
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
    ZMP_UpdatePlayerHealthTD(playerid);
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid, bodypart)
{
	if(damagedid == INVALID_PLAYER_ID || playerid == INVALID_PLAYER_ID) return 1;
    if(!g_bPlayerHit[damagedid])
    {
	    g_bPlayerHit[damagedid] = true;
	    SetPlayerAttachedObject(damagedid, 8, 1240, 2, 0.44099, 0.0000, 0.02300, -1.79999, 84.09998, 0.00000, 1.00000, 1.00000, 1.00000);
	    SetTimerEx("remove_health_obj", 800, 0, "i", damagedid);
	}
	if(gTeam[playerid] == gHUMAN && gTeam[damagedid] == gZOMBIE)
	{
		new Float:h, string[128];
		GetPlayerHealth(damagedid, h);
		format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~w~DAMAGE GIVE: ~g~~h~~h~%.2f~n~~w~ZOMBIE HP: ~g~~h~~h~%.2f", amount, h);
		GameTextForPlayer(playerid, string, 3000, 3);
	}
	if(gTeam[playerid] == gZOMBIE && gTeam[damagedid] == gHUMAN)
	{
	    if(PlayerData[damagedid][iTimesHit] >= 2)
	    {
	        PlayerData[damagedid][iTimesHit] = 0;

		    GameTextForPlayer(damagedid, "~w~Infected!", 3000, 5);
			SCM(damagedid, -1, ""er"You have been infected! Now infect humans by punching them!");
			ZMP_SetPlayerZombie(damagedid, false);

	        GivePlayerMoneyEx(playerid, 2000);
	        GivePlayerScoreEx(playerid, 5);
	        PlayerData[playerid][iKills]++;

	        PlayInfectSound();
			if(ZMP_GetHumans() == 0)
			{
		        TextDrawSetString(txtRescue, "~w~Rescue abandoned!");

		        GameTextForAll("~w~Zombies win!", 10000, 5);

				ZMP_EndGame();

		        format(gstr, sizeof(gstr), ""zwar" Round end! Humans left: "lb_e"%i "white"| Zombies: "lb_e"%i", ZMP_GetHumans(), ZMP_GetZombies());
		        SCMToAll(-1, gstr);
			}
		}
		else
		{
		    PlayerData[damagedid][iTimesHit]++;
		}
	}
	return 1;
}

YCMD:shutdown(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] == MAX_ADMIN_LEVEL && IsPlayerAdmin(playerid))
	{
	    bGlobalShutdown = true;

	    for(new i = 0; i < MAX_PLAYERS; i++)
	    {
	        SCM(i, -1, "Server restart! Restart your game. IP: samp.nefserver.net:7777");
	    }

	    SetTimer("server_init_shutdown", 3000, 0);
 	}
	return 1;
}

YCMD:vips(playerid, params[], help)
{
	new finstring[1024], count = 0;
	format(finstring, sizeof(finstring), ""yellow"ID:\t\tName:\n"white"");

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(!IsPlayerAvail(i)) continue;
	    
	    if(PlayerData[i][iVIP] == 1)
	    {
            if(IsPlayerOnDesktop(i))
				format(gstr, sizeof(gstr), "%i\t\t%s | [AFK]\n", i, __GetName(i));
			else
			    format(gstr, sizeof(gstr), "%i\t\t%s\n", i, __GetName(i));

			strcat(finstring, gstr);
			count++;
	    }
	}
	if(count == 0)
	{
	    SCM(playerid, -1, ""er"No VIPs online!");
	}
	else
	{
	    format(gstr, sizeof(gstr), "\n\n"white"Total of "blue"%i "white"aVIPs online!", count);
	    strcat(finstring, gstr);
		ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - VIPs", finstring, "OK", "");
	}
	return 1;
}

YCMD:vip(playerid, params[], help)
{
	new string[1024];

	strcat(string, ""blue"Very Important Player (VIP)\n\n"yellow_e"Features:\n"dl" VIP Chat (/p)\n"dl" Access to V.I.P Packages\n");
	strcat(string, ""dl" Access to VIP Forums\n"dl" Access to Beta Changelogs\n"dl" Custom Label (/label)\n");
	strcat(string, ""dl" Get listed in /vips\n"dl" Namechange lookup (/ncrecords)\n"dl" Special forum rank\n");
	strcat(string, "\n"dl" Message to all players when joining the server");
	strcat(string, "\n\n"blue"Get VIP today! Go To:\n");
	strcat(string, ""red"-> "yellow_e""URL"/vip.php");
    ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Very Important Player (VIP)", string, "OK", "");
	return 1;
}

YCMD:label(playerid, params[], help)
{
    if(PlayerData[playerid][iVIP] == 1)
	{
	    if(PlayerData[playerid][t3dVIPLabel] == Text3D:-1)
	    {
	        ShowPlayerDialog(playerid, DIALOG_LABEL, DIALOG_STYLE_INPUT, ""zwar" - Attach VIP Label", ""white"Enter some text which your label shall display\n"blue"* "white"Input length: 3-35", "Next", "Cancel");
	    }
	    else
	    {
			SCM(playerid, -1, ""er"You already got a label. Tpye /elabel to edit or /dlabel to detach it.");
		}
	}
	else
	{
		Command_ReProcess(playerid, "/vip", false);
	}
	return 1;
}

YCMD:elabel(playerid, params[], help)
{
    if(PlayerData[playerid][iVIP] == 1)
	{
	    if(PlayerData[playerid][t3dVIPLabel] != Text3D:-1)
	    {
	        ShowPlayerDialog(playerid, DIALOG_LABEL + 1, DIALOG_STYLE_INPUT, ""zwar" - Change VIP Label Text", ""white"Enter the new text which your label shall display\n"blue"* "white"Input length: 3-35", "Next", "Cancel");
	    }
	    else
	    {
		    SCM(playerid, -1, ""er"No label attached");
		}
	}
	else
	{
	    Command_ReProcess(playerid, "/vip", false);
	}
	return 1;
}

YCMD:dlabel(playerid, params[], help)
{
    if(PlayerData[playerid][iVIP] == 1)
	{
	    if(PlayerData[playerid][t3dVIPLabel] != Text3D:-1)
	    {
	        DestroyDynamic3DTextLabel(PlayerData[playerid][t3dVIPLabel]);
	        PlayerData[playerid][t3dVIPLabel] = Text3D:-1;
	        SCM(playerid, -1, ""er"Label removed!");
	    }
	    else
	    {
			SCM(playerid, -1, ""er"No label attached");
		}
	}
	else
	{
	    Command_ReProcess(playerid, "/vip", false);
	}
	return 1;
}

YCMD:p(playerid, params[], help)
{
	if(PlayerData[playerid][iVIP] != 1 && PlayerData[playerid][iAdminLevel] == 0) return Command_ReProcess(playerid, "/vip", false);

	if(sscanf(params, "s[144]", gstr))
	{
	    return SCM(playerid, YELLOW, "Usage: /p <text>");
	}

	if(IsAd(gstr))
	{
	  	format(gstr2, sizeof(gstr2), ""yellow"** "red"Suspicion advertising | Player: %s(%i) Advertised IP: %s - PlayerIP: %s", __GetName(playerid), playerid, gstr, __GetIP(playerid));
		broadcast_admin(RED, gstr2);

        SCM(playerid, RED, "Advertising is not allowed!");
        return 1;
	}

	format(gstr2, sizeof(gstr2), ""white"["lb_e"VIP CHAT"white"] {%06x}%s"white"(%i): %s", GetPlayerColor(playerid) >>> 8, __GetName(playerid), playerid, gstr);
	broadcast_vip(-1, gstr2);
	return 1;
}

YCMD:stats(playerid, params[], help)
{
	new player1,
		player;

	if(sscanf(params, "r", player))
	{
		player1 = playerid;
	}
	else
	{
	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

		player1 = player;
	}

	if(IsPlayerAvail(player1))
	{
		new	string1[500],
			string2[355],
			pDeaths,
			finstring[sizeof(string1) + sizeof(string2) + 5 + 35];

 		if(PlayerData[player1][iDeaths] == 0)
	 		pDeaths = 1;
	 	else
	 		pDeaths = PlayerData[player1][iDeaths];

 		format(string1, sizeof(string1), ""blue"Stats of the player: "white"%s\n\n\
	 	Kills: %i\nDeaths: %i\nK/D: %0.2f\nScore: %i\nMoney: $%s\n",
   			__GetName(player1),
	 		PlayerData[player1][iKills],
        	PlayerData[player1][iDeaths],
        	Float:PlayerData[player1][iKills] / Float:pDeaths,
        	PlayerData[player1][iEXP],
        	number_format(GetPlayerMoneyEx(player1)));

        format(string2, sizeof(string2), "Playing Time: %s\nVIP: %s\nMedkits: %i\nRegister Date: %s\nLast log in: %s",
            GetPlayingTimeFormat(player1),
			PlayerData[player1][iVIP] == 0 ? ("No") : ("Yes"),
			PlayerData[player1][iMedkits],
			UTConvert(PlayerData[player1][iRegisterDate]),
			UTConvert(PlayerData[player1][iLastLogin]));

		strcat(finstring, string1);
		strcat(finstring, string2);

		ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Player Statistics", finstring, "OK", "");
	}
	else
	{
		SCM(playerid, -1, ""er"Player is not available!");
	}
	return 1;
}

YCMD:asay(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 1)
	{
	    extract params -> new string:text[144]; else
	    {
	        return SCM(playerid, YELLOW, "Usage: /asay <message>");
	    }

	    if(strlen(text) > 100 || strlen(text) < 3) return SCM(playerid, -1, ""er"Length: 3-100");

		format(gstr, sizeof(gstr), ""yellow"** "red"Admin %s(%i): %s", __GetName(playerid), playerid, text);
		SCMToAll(-1, gstr);
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:warn(playerid, params[], help)
{
    if(PlayerData[playerid][iAdminLevel] >= 1)
	{
 		new player, reason[144];
		if(sscanf(params, "rs[144]", player, reason))
		{
			return SCM(playerid, YELLOW, "Usage: /warn <playerid> <reason>");
		}

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

		if(PlayerData[player][iAdminLevel] == MAX_ADMIN_LEVEL)
		{
	 		return SCM(playerid, -1, ""er"You cannot use this command on this admin");
		}

	 	if(IsPlayerAvail(player) && player != playerid)
	 	{
			PlayerData[player][iWarnings]++;
			if(PlayerData[player][iWarnings] == MAX_WARNINGS)
			{
				format(gstr, sizeof(gstr), ""yellow"** "red"%s(%i) has been kicked. [Reason: %s] [Warning: %i/%i] [Warn by: %s(%i)]", __GetName(player), player, reason, PlayerData[player][iWarnings], MAX_WARNINGS, __GetName(playerid), playerid);
				SCMToAll(-1, gstr);
				print(gstr);
				Kick(player);
			}
			else
			{
				format(gstr, sizeof(gstr), ""yellow"** "red"Admin %s(%i) has given %s(%i) a kick warning. [Reason: %s] [Warning: %i/%i]", __GetName(playerid), playerid, __GetName(player), player, reason, PlayerData[player][iWarnings], MAX_WARNINGS);
				SCMToAll(-1, gstr);
			}
		}
		else
		{
			SCM(playerid, -1, ""er"Player is not connected or invalid");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:slap(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 1)
	{
	    new player;
	 	if(sscanf(params, "r", player))
		{
			return SCM(playerid, YELLOW, "Usage: /slap <playerid>");
	  	}

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

		if(IsPlayerAvail(player) && PlayerData[player][iAdminLevel] != MAX_ADMIN_LEVEL)
		{
		    switch(gTeam[player])
		    {
		        case gNONE: return SCM(playerid, -1, ""er"You can't use this command on that player now");
		    }
  			new Float:Health,
			  	Float:POS[3];

  			GetPlayerHealth(player, Health);
			SetPlayerHealth(player, floatsub(Health, 25.0));
			GetPlayerPos(player, POS[0], POS[1], POS[2]);
			SetPlayerPos(player, POS[0], POS[1], floatadd(POS[2], 10.0));
			format(gstr, sizeof(gstr), "You have slapped %s(%i)", __GetName(player), player);
			SCM(playerid, BLUE, gstr);
		}
		else
		{
			SCM(playerid, -1, ""er"Player is not connected or is the highest level admin or in a minigame");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:disarm(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 1)
	{
	    new player;
		if(sscanf(params, "r", player))
		{
		    return SCM(playerid, YELLOW, "Usage: /disarm <playerid>");
		}

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

		if(IsPlayerAvail(player) && PlayerData[player][iAdminLevel] != MAX_ADMIN_LEVEL)
		{
		    if(!IsPlayerAvail(player) || PlayerData[player][iAdminLevel] >= PlayerData[playerid][iAdminLevel]) return SCM(playerid, -1, ""er"Player is not available or is an higher level admin than you");

			ResetPlayerWeapons(player);

			SCM(playerid, RED, "An Admin reset your weapons!");
			SCM(playerid, RED, "Player's has been disarmed!");
		}
		else
		{
			SCM(playerid, -1, ""er"Player is not connected or is the highest level admin");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:pweaps(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 1)
	{
	    new player;
	    if(sscanf(params, "r", player))
		{
	        return SCM(playerid, YELLOW, "Usage: /pweaps <playerid>");
	    }

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

		if(IsPlayerAvail(player))
		{
		    new bullets[12],
		 		weapons[12],
		 		weapname[12][50],
		 		string[512];

			for(new i = 0; i < 12; i++)
			{
			    GetPlayerWeaponData(player, i + 1, weapons[i], bullets[i]);
			}

			for(new i = 0; i < 11; i++)
			{
			    GetWeaponName(weapons[i], weapname[i], 50);
			}

		    format(string, sizeof(string), ""yellow"- - - - -  [ %s's Weapons ] - - - - -", __GetName(player));
		    SCM(playerid, -1, string);
		    format(string, sizeof(string), "%s(0) - %s(%i) - %s(%i) - %s(%i) - %s(%i) - %s(%i)", weapname[0], weapname[1], bullets[1], weapname[2], bullets[2], weapname[3], bullets[3], weapname[4], bullets[4], weapname[5], bullets[5]);
		    SCM(playerid, WHITE, string);
		    format(string, sizeof(string), "%s(%i) - %s(%i) - %s(%i) - %s(0) - %s(0) - %s(0)", weapname[6], bullets[6], weapname[7], bullets[7] ,weapname[8], bullets[8], weapname[9], weapname[10], weapname[11]);
		    SCM(playerid, WHITE, string);
		}
		else
		{
			SCM(playerid, -1, ""er"Player is not available");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
    return 1;
}

YCMD:mute(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 1)
	{
 		new player, time, reason[144];
		if(sscanf(params, "ris[144]", player, time, reason))
		{
			return SCM(playerid, YELLOW, "Usage: /mute <playerid> <seconds> <reason>");
		}

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");
		if(time < 1) return SCM(playerid, -1, ""er"Seconds must be greather than 0.");

		if(IsPlayerAvail(player) && player != playerid && PlayerData[player][iAdminLevel] != MAX_ADMIN_LEVEL)
		{
			if(PlayerData[player][iMute] != 0)
			{
				return SCM(playerid, -1, ""er"This player is already muted");
			}

	    	format(gstr, sizeof(gstr), ""yellow"** "red"%s(%i) has been muted by Admin %s(%i) for %i seconds [Reason: %s]", __GetName(player), player, __GetName(playerid), playerid, time, reason);
            SCMToAll(YELLOW, gstr);
            print(gstr);
            
			PlayerData[player][iMute] = gettime() + (time * 1000);
		}
		else
		{
			SCM(playerid, -1, ""er"Player is not connected or is yourself or is the highest level admin");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:unmute(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 1)
	{
 		new player;
		if(sscanf(params, "r", player))
		{
			return SCM(playerid, YELLOW, "Usage: /unmute <playerid>");
		}

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

		if(IsPlayerAvail(player) && player != playerid)
		{
			if(PlayerData[player][iMute] == 0)
			{
				return SCM(playerid, -1, ""er"This player is not muted");
			}

			format(gstr, sizeof(gstr), ""yellow"** "red"%s(%i) has been unmuted by Admin %s(%i)", __GetName(player), player, __GetName(playerid), playerid);
			SCMToAll(RED, gstr);
            SCM(player, RED, "You have been unmuted!");

            PlayerData[player][iMute] = 0;
		}
		else
		{
            SCM(playerid, -1, ""er"Player is not available or yourself");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:ncrecords(playerid, params[], help)
{
    if(PlayerData[playerid][iVIP] != 1 && PlayerData[playerid][iAdminLevel] == 0) return Command_ReProcess(playerid, "/vip", false);

	new name[25];
	if(sscanf(params, "s[24]", name))
	{
		mysql_tquery(g_pSQL, "SELECT * FROM `ncrecords` ORDER BY `id` DESC LIMIT 10;", "OnNCReceive", "i", playerid);
	}
	else
	{
		mysql_format(g_pSQL, gstr, sizeof(gstr), "SELECT * FROM `ncrecords` WHERE `oldname` = '%e' OR `newname` = '%e';", name, name);
		mysql_tquery(g_pSQL, gstr, "OnNCReceive2", "is", playerid, name);
	}
	return 1;
}

YCMD:clearchat(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 3)
	{
		for(new i = 0; i < 129; i++)
		{
			SCMToAll(GREEN, " ");
		}
 	}
 	else
 	{
	 	SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:announce(playerid, params[], help)
{
    if(PlayerData[playerid][iAdminLevel] >= 3 || IsPlayerAdmin(playerid))
	{
	    extract params -> new string:text[144]; else
	    {
	        return SCM(playerid, YELLOW, "Usage: /announce <message>");
	    }

	    if(strfind(text, "~", true) != -1) return SCM(playerid, -1, ""er"'~' is not allowed in announce.");
	    if(strfind(text, "#", true) != -1) return SCM(playerid, -1, ""er"'#' is not allowed in announce.");
	    if(strfind(text, "%", true) != -1) return SCM(playerid, -1, ""er"'%' is not allowed in announce.");
	    if(strlen(text) > 50 || strlen(text) < 1) return SCM(playerid, -1, ""er"Length 1-50");

		format(gstr, sizeof(gstr), "%s: %s", __GetName(playerid), text);

		GameTextForAll(gstr, 4000, 3);
    }
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:giveweapon(playerid, params[], help)
{
    if(PlayerData[playerid][iAdminLevel] >= 4)
    {
		new weaponID, weaponName[20], player, ammo_a, str[144];

		if(sscanf(params, "rii", player, weaponID, ammo_a))
		{
		    SCM(playerid, YELLOW, "Usage: /giveweapon <playerid> <weaponid> <ammo>");
		    return 1;
		}

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");
		if(gTeam[player] != gHUMAN) return SCM(playerid, -1, ""er"You can only give weapons to humans");

		if(IsPlayerAvail(player))
		{
			if(ammo_a < 0 || ammo_a > 10000)
			{
			    format(str, sizeof(str), ""er"Invalid ammo provided!");
			    SCM(playerid, COLOR_RED, str);
			    return 1;
			}

	        if(weaponID == 38 || weaponID == 36 || weaponID == 35 || weaponID == 39 || weaponID == 44 || weaponID == 45|| weaponID == 40) return SCM(playerid, -1, ""er"Can't give restriced weapon");

			if(weaponID <= 0 && weaponID >= 47)
			{
			    if(weaponID == 20)
			    {
					SCM(playerid, -1, ""er"Invalid weapon ID provided!");
					return 1;
				}
				SCM(playerid, -1, ""er"Invalid weapon ID provided!");
				return 1;
			}

			GivePlayerWeapon(player, weaponID, ammo_a);
			GetWeaponName(weaponID, weaponName, sizeof(weaponName));

			format(str, sizeof(str), ""WHITE_E"["BLUE_E""ZWAR_SHORT""WHITE_E"] "GREY_E"Administrator %s(%i) gave you a %s(%i) with %i ammo.", __GetName(playerid), playerid, weaponName, weaponID, ammo_a);
			SCM(player, -1, str);
			format(str, sizeof(str), ""WHITE_E"["BLUE_E""ZWAR_SHORT""WHITE_E"] "GREY_E"You gave %s(%i) a %s(%i) with %i ammo.", __GetName(player), player, weaponName, weaponID, ammo_a);
			SCM(playerid, -1, str);
		}
		else
		{
            SCM(playerid, -1, ""er"Player is not available!");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:sethealth(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 4)
	{
	    if(g_GlobalStatus != e_Status_Playing || g_GlobalStatus != e_Status_Prepare) return SCM(playerid, -1, ""er"Not possible now!");
	    
	    new player, Float:amount;
	    if(sscanf(params, "rf", player, amount))
	    {
	        return SCM(playerid, YELLOW, "Usage: /sethealth <playerid> <health>");
	    }

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

	    if(amount > 100 || amount <= 1) return SCM(playerid, -1, ""er"Do not set it higher than 100 or lower than 1");

 		if(IsPlayerAvail(player))
		{
			if(player != playerid)
			{
				format(gstr, sizeof(gstr), "Admin %s(%i) has set your health to %f.", __GetName(playerid), playerid, amount);
				SCM(player, YELLOW, gstr);
				format(gstr, sizeof(gstr), "You have set %s's health to %f.", __GetName(player), amount);
				SCM(playerid, YELLOW, gstr);
			}
			else
			{
				format(gstr, sizeof(gstr), "You have set your health to %f.", amount);
				SCM(playerid, YELLOW, gstr);
			}
			SetPlayerHealth(player, amount);
		}
		else
		{
			SCM(playerid, -1, ""er"Player is not available");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:ip(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 4)
	{
	    new player;
	 	if(sscanf(params, "r", player))
		{
			return SCM(playerid, YELLOW, "Usage: /ip <playerid>");
	  	}

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

		if(PlayerData[player][iAdminLevel] == MAX_ADMIN_LEVEL && PlayerData[playerid][iAdminLevel] != MAX_ADMIN_LEVEL)
		{
			return SCM(playerid, -1, ""er"You cannot use this command on this admin");
		}

        if(IsPlayerAvail(player))
		{
			new string[64];
			format(string, sizeof(string), "%s's ip is %s", __GetName(player), __GetIP(player));
			SCM(playerid, BLUE, string);
	    }
		else
		{
			SCM(playerid, -1, ""er"Player is not connected");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:setcash(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 5)
	{
	    new player, amount;
	    if(sscanf(params, "ri", player, amount))
	    {
	        return SCM(playerid, YELLOW, "Usage: /setcash <playerid> <amount>");
	    }

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

    	if(amount < 0 || amount > 50000000)
		{
			return SCM(playerid, -1, ""er"$0 - $50,000,000");
		}

		if(IsPlayerAvail(player))
		{
			if(player != playerid)
			{
				format(gstr, sizeof(gstr), "Admin %s(%i) has set your cash to $%s.", __GetName(playerid), playerid, number_format(amount));
				SCM(player, YELLOW, gstr);
				format(gstr, sizeof(gstr), "You have set %s's cash to $%s.", __GetName(player), number_format(amount));
				SCM(playerid, YELLOW, gstr);
			}
			else
			{
				format(gstr, sizeof(gstr), "You have set your cash to $%s.", number_format(amount));
				SCM(playerid, YELLOW, gstr);
			}
			SetPlayerMoneyEx(player, amount);
		}
		else
		{
			SCM(playerid, -1, ""er"Player is not connected or unavailable");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:setscore(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 5)
	{
	    new player, amount;
	    if(sscanf(params, "ri", player, amount))
	    {
	        return SCM(playerid, YELLOW, "Usage: /setscore <playerid> <score>");
	    }

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

    	if(amount < 0 || amount > 1000000)
		{
			return SCM(playerid, -1, ""er"Score: 0 - 1,000,000");
		}

		if(IsPlayerAvail(player))
		{
			if(player != playerid)
			{
				format(gstr, sizeof(gstr), "Admin %s(%i) has set your score to %i.", __GetName(playerid), playerid, amount);
				SCM(player, YELLOW, gstr);
				format(gstr, sizeof(gstr), "You set %s's score to %i.", __GetName(player), amount);
				SCM(playerid, YELLOW, gstr);
			}
			else
			{
				format(gstr, sizeof(gstr), "You have set your score to %i.", amount);
				SCM(playerid, YELLOW, gstr);
			}
			SetPlayerScoreEx(player, amount);
		}
	 	else
	 	{
		 	SCM(playerid, -1, ""er"Player is not connected or unavailable");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:setadminlevel(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] == MAX_ADMIN_LEVEL || IsPlayerAdmin(playerid))
	{
	    new player, alevel;
	 	if(sscanf(params, "ri", player, alevel))
		{
			return SCM(playerid, YELLOW, "Usage: /setadminlevel <playerid> <level>");
	  	}

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

		if(IsPlayerAvail(player))
		{
			if(alevel > MAX_ADMIN_LEVEL)
			{
				return SCM(playerid, -1, ""er"Incorrect Level");
			}
			if(alevel == PlayerData[player][iAdminLevel])
			{
				return SCM(playerid, -1, ""er"Player is already this level");
			}
  			new time[3];
   			gettime(time[0], time[1], time[2]);

			if(alevel > 0)
				format(gstr, sizeof(gstr), "Admin %s has set you to Admin Status [level %i]", __GetName(playerid), alevel);
			else
				format(gstr, sizeof(gstr), "Admin %s has set you to Player Status [level %i]", __GetName(playerid), alevel);

			SCM(player, BLUE, gstr);

			if(alevel > PlayerData[player][iAdminLevel])
				GameTextForPlayer(player, "Promoted", 5000, 3);
			else
				GameTextForPlayer(player, "Demoted", 5000, 3);

			format(gstr, sizeof(gstr), "You have made %s Level %i at %i:%i:%i", __GetName(player), alevel, time[0], time[1], time[2]);
			SCM(playerid, BLUE, gstr);
			format(gstr, sizeof(gstr), "Admin %s has made %s Level %i at %i:%i:%i", __GetName(playerid), __GetName(player), alevel, time[0], time[1], time[2]);
            SCM(player, BLUE, gstr);
            print(gstr);
			PlayerData[player][iAdminLevel] = alevel;
		}
		else
		{
			SCM(playerid, -1, ""er"Cannot assign permissions");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:burn(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 2)
	{
	    new player;
	 	if(sscanf(params, "r", player))
		{
			return SCM(playerid, YELLOW, "Usage: /burn <playerid>");
	  	}

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

        if(IsPlayerAvail(player))
		{
			if(PlayerData[player][iAdminLevel] > 0)
			{
				return SCM(playerid, -1, ""er"You cannot use this command on an admin");
			}

		    new string[64],
				Float:POS[3];

			format(string, sizeof(string), "You have burnt %s(%i)", __GetName(player), player);
			SCM(playerid, BLUE, string);
			GetPlayerPos(player, POS[0], POS[1], POS[2]);
			CreateExplosion(POS[0], POS[1], POS[2] + 3, 1, 10);
	    }
		else
		{
			SCM(playerid, -1, ""er"Player is not connected");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:healall(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 4)
	{
	   	for(new i = 0; i < MAX_PLAYERS; i++)
 		{
			if((IsPlayerAvail(i)) && (i != playerid) && (i != MAX_ADMIN_LEVEL) && (gTeam[i] != gNONE))
			{
				PlayerPlaySound(i, 1057, 0.0, 0.0, 0.0);
				SetPlayerHealth(i, 100.0);
			}
		}

		format(gstr, sizeof(gstr), "Admin %s(%i) healed all players", __GetName(playerid), playerid);
		SCMToAll(BLUE, gstr);
		GameTextForAll("Health for all!", 3000, 3);
		SetPlayerHealth(playerid, 100.0);
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:get(playerid, params[], help)
{
    if(PlayerData[playerid][iAdminLevel] >= 3)
	{
	    new player;
	 	if(sscanf(params, "r", player))
		{
			return SCM(playerid, YELLOW, "Usage: /get <playerid>");
	  	}

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");
		if(gTeam[playerid] == gNONE) return SCM(playerid, -1, ""er"Not useable on this player");

		if(PlayerData[player][iAdminLevel] == MAX_ADMIN_LEVEL && PlayerData[playerid][iAdminLevel] != MAX_ADMIN_LEVEL)
		{
			return SCM(playerid, -1, ""er"You cannot use this command on this admin");
		}

	 	if(IsPlayerAvail(player) && player != playerid)
	 	{
			new Float:POS[3];

			GetPlayerPos(playerid, POS[0], POS[1], POS[2]);
			SetPlayerInterior(player, GetPlayerInterior(playerid));
			SetPlayerVirtualWorld(player, GetPlayerVirtualWorld(playerid));
			if(GetPlayerState(player) == PLAYER_STATE_DRIVER)
			{
			    new VehicleID = GetPlayerVehicleID(player);
				SetVehiclePos(VehicleID, floatadd(POS[0], 2), POS[1], POS[2]);
				LinkVehicleToInterior(VehicleID, GetPlayerInterior(playerid));
				SetVehicleVirtualWorld(GetPlayerVehicleID(player), GetPlayerVirtualWorld(playerid));
			}
			else
			{
				SetPlayerPos(player, floatadd(POS[0], 2), POS[1], POS[2]);
			}

			format(gstr, sizeof(gstr), "You have been teleported to Admin %s's location", __GetName(playerid));
			SCM(player, BLUE, gstr);
			format(gstr, sizeof(gstr), "You have teleported %s(%i) to your location", __GetName(player), player);
			SCM(playerid, BLUE, gstr);
		}
		else
		{
			SCM(playerid, -1, ""er"Player is not connected or is yourself");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:go(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 3 || IsPlayerAdmin(playerid))
	{
	    if(gTeam[playerid] == gNONE) return SCM(playerid, RED, NOT_AVAIL);
	    
	    new player;
	 	if(sscanf(params, "r", player))
		{
			return SCM(playerid, YELLOW, "Usage: /go <playerid>");
	  	}

		if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");
		if(!IsPlayerAvail(player)) return SCM(playerid, -1, ""er"Player is not avialable");
		if(gTeam[player] == gNONE) return SCM(playerid, -1, ""er"Player is currently unavailable to goto");

	 	if(player != playerid)
	 	{
			new Float:POS[3];

			GetPlayerPos(player, POS[0], POS[1], POS[2]);
			SetPlayerInterior(playerid, GetPlayerInterior(player));
			SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(player));
			if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			{
				SetVehiclePos(GetPlayerVehicleID(playerid), floatadd(POS[0], 2), POS[1], POS[2]);
				LinkVehicleToInterior(GetPlayerVehicleID(playerid), GetPlayerInterior(player));
				SetVehicleVirtualWorld(GetPlayerVehicleID(playerid), GetPlayerVirtualWorld(player));
			}
			else
			{
				SetPlayerPos(playerid, floatadd(POS[0], 2), POS[1], POS[2]);
			}
			format(gstr, sizeof(gstr), "You have teleported to %s(%i)", __GetName(player), player);
			SCM(playerid, BLUE, gstr);
		}
		else
		{
			SCM(playerid, -1, ""er"Player is not available or is yourself");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:kick(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 2)
	{
 		new player, reason[144];
		if(sscanf(params, "rs[144]", player, reason))
		{
			return SCM(playerid, YELLOW, "Usage: /kick <playerid> <reason>");
		}

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

		if(isnull(reason)) return SCM(playerid, YELLOW, "Usage: /kick <playerid> <reason>");

		if(PlayerData[player][bOpenSeason]) return SCM(playerid, -1, ""er"Can't kick this player!");

		if(IsPlayerAvail(player) && player != playerid && PlayerData[player][iAdminLevel] != MAX_ADMIN_LEVEL)
		{
		    PlayerData[player][bOpenSeason] = true;

			format(gstr, sizeof(gstr), ""yellow"** "red"%s(%i) has been kicked by Admin %s(%i) [Reason: %s]", __GetName(player), player, __GetName(playerid), playerid, reason);
			SCMToAll(YELLOW, gstr);
			print(gstr);

  			KickEx(player);
		}
		else
		{
			SCM(playerid, -1, ""er"Player is not connected or is yourself or is the highest level admin");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:offlineban(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 3)
	{
	    new player[144], reason[144];
	    if(sscanf(params, "s[144]s[144]", player, reason))
	    {
	        return SCM(playerid, YELLOW, "Usage: /offlineban <name> <reason>");
	    }

		if(strlen(reason) > 128) return SCM(playerid, -1, ""er"Keep the reason below 128");
	  	if(isnull(reason) || strlen(reason) < 2) return SCM(playerid, YELLOW, "Usage: /offlineban <name> <reason>");
	    if(strlen(player) > 24 || strlen(player) < 3) return SCM(playerid, -1, ""er"Name length 3 - 24");
	    if(__GetPlayerID(player) != INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Player seems to be online!");

	    new escape[25], ereason[128];
	    mysql_escape_string(player, escape, g_pSQL, sizeof(escape));
	    mysql_escape_string(reason, ereason, g_pSQL, sizeof(ereason));

	    format(player, sizeof(player), "SELECT `id` FROM `bans` WHERE `name` = '%s';", escape);
	    mysql_tquery(g_pSQL, player, "OnOfflineBanAttempt", "iss", playerid, escape, ereason);
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:unban(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 3)
	{
	    new player[144];
	    if(sscanf(params, "s[144]", player))
	    {
	        return SCM(playerid, YELLOW, "Usage: /unban <name>");
	    }
	    
	    if(strlen(player) > 24 || strlen(player) < 3) return SCM(playerid, -1, ""er"Name length 3 - 24");
	    if(__GetPlayerID(player) != INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Player seems to be online!");
	    
	    new escape[25];
	    mysql_escape_string(player, escape, g_pSQL, sizeof(escape));
	    
	    format(player, sizeof(player), "SELECT `id` FROM `bans` WHERE `name` = '%s';", escape);
	    mysql_tquery(g_pSQL, player, "OnUnbanAttempt", "is", playerid, escape);
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:ban(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 3)
	{
	    new player, reason[144];
	    if(sscanf(params, "rs[144]", player, reason))
	    {
	        return SCM(playerid, YELLOW, "Usage: /ban <playerid> <reason>");
	    }

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

		if(strlen(reason) > 128) return SCM(playerid, -1, ""er"Keep the reason below 128");
	    if(player == playerid) return SCM(playerid, -1, ""er"Fail :P");
	  	if(isnull(reason) || strlen(reason) < 2) return SCM(playerid, YELLOW, "Usage: /ban <playerid> <reason>");
        if(PlayerData[player][bOpenSeason]) return SCM(playerid, -1, ""er"Can't ban this player!");

	    if(strfind(reason, "-", false) != -1)
		{
	        return SCM(playerid, -1, ""er"- ist not allowed");
		}
	    if(strfind(reason, "|", false) != -1)
		{
	        return SCM(playerid, -1, ""er"| ist not allowed");
		}
	    if(strfind(reason, ",", false) != -1)
		{
	        return SCM(playerid, -1, ""er", ist not allowed");
		}
	    if(strfind(reason, "@", false) != -1)
		{
	        return SCM(playerid, -1, ""er"@ ist not allowed");
		}
	    if(strfind(reason, "*", false) != -1)
		{
	        return SCM(playerid, -1, ""er"* ist not allowed");
		}
	    if(strfind(reason, "'", false) != -1)
		{
	        return SCM(playerid, -1, ""er"' ist not allowed");
		}
	    if((strfind(reason, "`", false) != -1) || (strfind(reason, "´", false) != -1))
		{
	        return SCM(playerid, -1, ""er"`´ ist not allowed");
		}

	  	if(PlayerData[player][iAdminLevel] != MAX_ADMIN_LEVEL)
	  	{
		 	if(IsPlayerAvail(player) && player != playerid && PlayerData[player][iAdminLevel] != MAX_ADMIN_LEVEL)
			{
                PlayerData[player][bOpenSeason] = true;

	   			SQL_CreateBan(__GetName(player), __GetName(playerid), reason);
                SQL_BanIP(__GetIP(player));

				format(gstr2, sizeof(gstr2), ""yellow"** "red"%s(%i) has been banned by Admin %s(%i) [Reason: %s]", __GetName(player), player, __GetName(playerid), playerid, reason);
				SCMToAll(YELLOW, gstr2);
				print(gstr2);

	    		format(gstr2, sizeof(gstr2), ""red"You have been banned!"white"\n\nAdmin:\t\t%s\nReason:\t\t%s\n\nIf you think that you have been banned wrongly,\nwrite a ban appeal on "URL"", __GetName(playerid), reason);
	    		ShowPlayerDialog(player, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Notice", gstr2, "OK", "");
	    		KickEx(player);

	    		PlayerPlaySound(playerid, 1184, 0.0, 0.0, 0.0);
				return 1;
			}
			else
			{
				SCM(playerid, -1, ""er"Player is not connected or is yourself or is the highest level admin");
			}
		}
		else
		{
		    format(gstr, sizeof(gstr), "OMGLOL: %s just tried to ban you with reason: %s", __GetName(playerid), reason);
		    SCM(player, RED, gstr);
		    SCM(playerid, RED, "I hope that was a joke");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:tban(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 3)
	{
	    new player, mins, reason[144];
	    if(sscanf(params, "ris[144]", player, mins, reason))
	    {
	        return SCM(playerid, YELLOW, "Usage: /tban <playerid> <minutes> <reason>");
	    }

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

		if(mins < 5 || mins > 10080) return SCM(playerid, -1, ""er"Min. ban time is 5 max is 10080");
		if(strlen(reason) > 128) return SCM(playerid, -1, ""er"Keep the reason below 128");
	    if(player == playerid) return SCM(playerid, -1, ""er"Fail :P");
	  	if(isnull(reason) || strlen(reason) < 2) return SCM(playerid, YELLOW, "Usage: /tban <playerid> <minutes> <reason>");
        if(PlayerData[player][bOpenSeason]) return SCM(playerid, -1, ""er"Can't ban this player!");

	    if(strfind(reason, "-", false) != -1)
		{
	        return SCM(playerid, -1, ""er"- ist not allowed");
		}
	    if(strfind(reason, "|", false) != -1)
		{
	        return SCM(playerid, -1, ""er"| ist not allowed");
		}
	    if(strfind(reason, ",", false) != -1)
		{
	        return SCM(playerid, -1, ""er", ist not allowed");
		}
	    if(strfind(reason, "@", false) != -1)
		{
	        return SCM(playerid, -1, ""er"@ ist not allowed");
		}
	    if(strfind(reason, "*", false) != -1)
		{
	        return SCM(playerid, -1, ""er"* ist not allowed");
		}
	    if(strfind(reason, "'", false) != -1)
		{
	        return SCM(playerid, -1, ""er"' ist not allowed");
		}
	    if((strfind(reason, "`", false) != -1) || (strfind(reason, "´", false) != -1))
		{
	        return SCM(playerid, -1, ""er"`´ ist not allowed");
		}

	  	if(PlayerData[player][iAdminLevel] != MAX_ADMIN_LEVEL)
	  	{
		 	if(IsPlayerAvail(player) && player != playerid && PlayerData[player][iAdminLevel] != MAX_ADMIN_LEVEL)
			{
			    PlayerData[player][bOpenSeason] = true;

	   			SQL_CreateBan(__GetName(player), __GetName(playerid), reason, gettime() + (mins * 60));

				format(gstr2, sizeof(gstr2), ""yellow"** "red"%s(%i) has been time banned for %i minutes by Admin %s(%i) [Reason: %s]", __GetName(player), player, mins, __GetName(playerid), playerid, reason);
				SCMToAll(YELLOW, gstr2);
				print(gstr2);

	    		format(gstr2, sizeof(gstr2), ""red"You have been time banned!"white"\n\nAdmin:\t\t%s\nReason:\t\t%s\nExpires:\t\t%s\nIf you think that you have been banned wrongly,\nwrite a ban appeal on "URL"", __GetName(playerid), reason, UTConvert(gettime() + (mins * 60)));
	    		ShowPlayerDialog(player, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Notice", gstr2, "OK", "");
	    		KickEx(player);

	    		PlayerPlaySound(playerid, 1184, 0.0, 0.0, 0.0);
				return 1;
			}
			else
			{
				SCM(playerid, -1, ""er"Player is not connected or is yourself or is the highest level admin");
			}
		}
		else
		{
		    format(gstr, sizeof(gstr), "OMGLOL: %s just tried to ban you with reason: %s", __GetName(playerid), reason);
		    SCM(player, RED, gstr);
		    SCM(playerid, RED, "I hope that was a joke");
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:mapchange(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 2)
	{
	    new map[144];
	    if(sscanf(params, "s[144]", map))
	    {
	        return SCM(playerid, YELLOW, "Usage: /mapchange <mapname>");
	    }

	    for(new i = 0; i < g_MapCount; i++)
	    {
	        if(!strcmp(map, g_Maps[i][e_mapname], true))
	        {
				format(gstr, sizeof(gstr), ""red"Admin %s(%i) set the next map to %s", __GetName(playerid), playerid, g_Maps[i][e_mapname]);
				SCMToAll(-1, gstr);
				
				g_ForceMap = i;
				return 1;
	        }
	    }
	    SCM(playerid, -1, ""er"Map not found!");
	}
  	else
	{
  		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:reloadmapdata(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 4)
	{
	    if(g_GlobalStatus == e_Status_RoundEnd)
	    {
	        server_fetch_mapdata();
	        SCM(playerid, -1, ""er"Map data has been re-fetched from the db");
	    }
	    else
	    {
	        SCM(playerid, -1, ""er"Map data reload only possible during round end.");
	    }
	}
  	else
	{
  		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:setvip(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] == MAX_ADMIN_LEVEL)
	{
	    new player;
	    if(sscanf(params, "r", player))
	    {
	        return SCM(playerid, YELLOW, "Usage: /setvip <playerid>");
	    }

	    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
		if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

		if(IsPlayerAvail(player))
		{
		    if(PlayerData[player][iVIP] == 1)
		    {
				format(gstr, sizeof(gstr), ""zwar" Admin %s(%i) has removed %s(%i) VIP status.", __GetName(playerid), playerid, __GetName(player), player);
				PlayerData[player][iVIP] = 0;
		    }
		    else
		    {
				format(gstr, sizeof(gstr), ""zwar" Admin %s(%i) has given %s(%i) VIP status.", __GetName(playerid), playerid, __GetName(player), player);
				PlayerData[player][iVIP] = 1;
		    }
		    SCMToAll(-1, gstr);
		    SQL_SaveAccount(player);
		}
	}
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:adminhelp(playerid, params[], help)
{
	if(PlayerData[playerid][iAdminLevel] >= 1)
	{
	    new string[1024];

	    strcat(string, ""yellow_e"Level 1:\n"white"/warn /slap /reports /disarm\n/pweaps /mute /unmute /ncrecords\n\n");
	    strcat(string, ""yellow_e"Level 2:\n"white"/asay /kick /burn /mapchange\n\n");
	    strcat(string, ""yellow_e"Level 3:\n"white"/ban /tban /go /get /clearchat /announce /unban /offlineban\n\n");
	    strcat(string, ""yellow_e"Level 4:\n"white"/giveweapon /sethealth /ip /healall\n\n");
	    strcat(string, ""yellow_e"Level 5:\n"white"/setcash /setscore\n\n");
	    strcat(string, ""yellow_e"Level 6:\n"white"/main /setvip /reloadmaps");

        ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Admin Commands", string, "OK", "");
	}
  	else
	{
  		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:cmds(playerid, params[], help)
{
	new cstring[1024];

	strcat(cstring, ""yellow"/sounds "white"- enable/disable sounds (streams only)\n");
	strcat(cstring, ""yellow"/mk "white"- use a medkit\n");
	strcat(cstring, ""yellow"/help "white"- some usefull explanations\n");
	strcat(cstring, ""yellow"/pm "white"- write a personal message to a player\n");
	strcat(cstring, ""yellow"/r "white"- reply to your last pm\n");
	strcat(cstring, ""yellow"/id "white"- get the id of a player\n");
	strcat(cstring, ""yellow"/admins "white"- a list of all online admins\n");
	strcat(cstring, ""yellow"/top "white"- top list selection\n");
	strcat(cstring, ""yellow"/report "white"- report a player to admins\n");
	strcat(cstring, ""yellow"/changename "white"- change your account's nickname\n");
	strcat(cstring, ""yellow"/changepass "white"- change your account's password\n");
	strcat(cstring, ""yellow"/stats "white"- stats of a player also /stats <playerid>\n");
	strcat(cstring, ""yellow"/uptime "white"- see the uptime of the server\n");
	strcat(cstring, ""yellow"/anims "white"- a lsit of all animations\n");
	strcat(cstring, ""yellow"/stopanim "white"- stop animations\n");
	strcat(cstring, ""yellow"/pay "white"- pay someone money\n");

	ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Commands", cstring, "OK", "");
	return 1;
}

YCMD:help(playerid, params[], help)
{
	new string[512];
	
	strcat(string, ""dl"What can I do on this server?\n");
	strcat(string, ""dl"How do I infect others?\n"dl"How do I get money/score and what can I do with it?\n"dl"How do I become a V.I.P?\n"dl"I found a bug/glitch where can I report it?\n"dl"I have more questions!");
	strcat(string, ""dl"How do I use medkits?");
	
	ShowPlayerDialog(playerid, DIALOG_HELP, DIALOG_STYLE_LIST, ""zwar" - Help", string, "OK", "");
    return 1;
}

YCMD:med(playerid, params[], help)
{
	if(gTeam[playerid] == gZOMBIE) return SCM(playerid, -1, ""er"Not useable as zombie");
	
	if(PlayerData[playerid][iMedkits] <= 0)
	{
	    return SCM(playerid, -1, ""er"You don't own any medkits!");
	}

	new tick = GetTickCountEx();
	if((PlayerData[playerid][tickLastMedkit] + COOLDOWN_CMD_MEDKIT) >= tick)
	{
    	return SCM(playerid, -1, ""er"Please wait a bit before using this cmd again!");
	}
	
	new Float:Health;
	GetPlayerHealth(playerid, Health);
	if(Health >= 100.0)
	{
	    return SCM(playerid, -1, ""er"You are already at full health");
	}

	PlayerData[playerid][iMedkitTime] = 50;
	PlayerData[playerid][iMedkits]--;

	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

	PlayerData[playerid][tMedkit] = SetTimerEx("p_medkit", 200, 1, "i", playerid);

	GameTextForPlayer(playerid, "~y~~h~Medkit used!", 3000, 5);
	PlayerData[playerid][tickLastMedkit] = tick;
	return 1;
}

YCMD:unstuck(playerid, params[], help)
{
	if(g_GlobalStatus == e_Status_Playing)
	{
	    TogglePlayerControllable(playerid, 1);
	}
	return 1;
}

YCMD:changename(playerid, params[], help)
{
	if(GetPlayerMoneyEx(playerid) < 50000)
	{
		format(gstr, sizeof(gstr), ""red"Namechange possible"white"\nCurrent Name: %s\nYou need $50,000 for a namechange!", __GetName(playerid));
		ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Namechange", gstr, "OK", "");
	}
	else
	{
		format(gstr, sizeof(gstr), ""green"Namechange possible"white"\nCurrent Name: %s\nA namechange costs $50,000\n\nEnter a new valid nickname below:", __GetName(playerid));
		ShowPlayerDialog(playerid, DIALOG_NAMECHANGE, DIALOG_STYLE_INPUT, ""zwar" - Namechange", gstr, "OK", "Cancel");
	}
	return 1;
}

YCMD:changepass(playerid, params[], help)
{
    new tick = GetTickCountEx();
	if((PlayerData[playerid][tickLastPW] + COOLDOWN_CMD_CHANGEPASS) >= tick)
	{
    	return SCM(playerid, -1, ""er"Please wait a bit before using this cmd again!");
	}

	new pass[144];
	if(sscanf(params, "s[144]", pass))
	{
		SCM(playerid, YELLOW, "Usage: /changepass <new pass>");
	    return 1;
	}
	
	if(strlen(pass) < 3 || strlen(pass) > 32)
	{
		SCM(playerid, -1, ""er"Allowed password length (3 - 32)");
		return 1;
	}
	
	new hash[SHA3_LENGTH + 1];
	sha3(pass, hash, sizeof(hash));
	
    SQL_UpdatePlayerPass(playerid, hash);
	PlaySound(playerid, 1057);
    format(gstr, sizeof(gstr), ""server_sign" "r_besch"You have successfully changed your password to %s", pass);
	SCM(playerid, -1, gstr);
	
	PlayerData[playerid][tickLastPW] = tick;
	return 1;
}

YCMD:anims(playerid, params[], help)
{
    new cstring[1024];
    strcat(cstring, ""blue"All animations are listed below:\n");
    strcat(cstring, ""white"/piss - /wank - /dance [1-3] /vomit\n/drunk - /sit - /wave - /lay - /smoke\n/rob - /cigar - /laugh - /handsup - /fucku\n\n");
	strcat(cstring, ""blue"To stop an animation:");
	strcat(cstring, "\n"white"You can press: [SHIFT], [ENTER], [LMB].\nOr try /stopanim");

	ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Animations", cstring, "OK", "");
	return 1;
}

YCMD:stopanim(playerid, params[], help)
{
    ClearAnimations(playerid);
	return 1;
}

YCMD:sit(playerid, params[], help)
{
    if((g_GlobalStatus != e_Status_Playing && g_GlobalStatus != e_Status_Prepare) || gTeam[playerid] != gHUMAN) return SCM(playerid, RED, NOT_AVAIL);
    ApplyAnimation(playerid, "BEACH", "ParkSit_M_loop", 4.1, 1, 0, 0, 0, 0);
	return 1;
}

YCMD:handsup(playerid, params[], help)
{
    if((g_GlobalStatus != e_Status_Playing && g_GlobalStatus != e_Status_Prepare) || gTeam[playerid] != gHUMAN) return SCM(playerid, RED, NOT_AVAIL);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_HANDSUP);
	return 1;
}

YCMD:cigar(playerid, params[], help)
{
    if((g_GlobalStatus != e_Status_Playing && g_GlobalStatus != e_Status_Prepare) || gTeam[playerid] != gHUMAN) return SCM(playerid, RED, NOT_AVAIL);
    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);
	return 1;
}

YCMD:piss(playerid, params[], help)
{
    if((g_GlobalStatus != e_Status_Playing && g_GlobalStatus != e_Status_Prepare) || gTeam[playerid] != gHUMAN) return SCM(playerid, RED, NOT_AVAIL);
    ApplyAnimation(playerid, "PAULNMAC", "Piss_loop", 4.1, 1, 0, 0, 0, 0);
	return 1;
}

YCMD:wank(playerid, params[], help)
{
    if((g_GlobalStatus != e_Status_Playing && g_GlobalStatus != e_Status_Prepare) || gTeam[playerid] != gHUMAN) return SCM(playerid, RED, NOT_AVAIL);
    ApplyAnimation(playerid, "PAULNMAC", "wank_loop", 4.1, 1, 0, 0, 0, 0);
	return 1;
}

YCMD:dance(playerid, params[], help)
{
   	if((g_GlobalStatus != e_Status_Playing && g_GlobalStatus != e_Status_Prepare) || gTeam[playerid] != gHUMAN) return SCM(playerid, RED, NOT_AVAIL);

    extract params -> new dance; else
    {
        return SCM(playerid, YELLOW, "Usage: /dance <1-3>");
    }

  	if(dance == 1)
  	{
  	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE1);
  	}
  	else if(dance == 2)
  	{
  	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE2);
  	}
  	else if(dance == 3)
  	{
  	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_DANCE3);
  	}
  	else
  	{
  	    SCM(playerid, YELLOW, "Usage: /dance <1-3>");
  	}
	return 1;
}

YCMD:vomit(playerid, params[], help)
{
    if((g_GlobalStatus != e_Status_Playing && g_GlobalStatus != e_Status_Prepare) || gTeam[playerid] != gHUMAN) return SCM(playerid, RED, NOT_AVAIL);
    ApplyAnimation(playerid, "FOOD", "EAT_Vomit_P", 4.1, 1, 0, 0, 0, 0);
	return 1;
}

YCMD:drunk(playerid, params[], help)
{
    if((g_GlobalStatus != e_Status_Playing && g_GlobalStatus != e_Status_Prepare) || gTeam[playerid] != gHUMAN) return SCM(playerid, RED, NOT_AVAIL);
    ApplyAnimation(playerid, "PED", "WALK_DRUNK", 4.1, 1, 0, 0, 0, 0);
	return 1;
}

YCMD:wave(playerid, params[], help)
{
    if((g_GlobalStatus != e_Status_Playing && g_GlobalStatus != e_Status_Prepare) || gTeam[playerid] != gHUMAN) return SCM(playerid, RED, NOT_AVAIL);
    ApplyAnimation(playerid, "ON_LOOKERS", "wave_loop", 4.1, 1, 0, 0, 0, 0);
	return 1;
}

YCMD:lay(playerid, params[], help)
{
    if((g_GlobalStatus != e_Status_Playing && g_GlobalStatus != e_Status_Prepare) || gTeam[playerid] != gHUMAN) return SCM(playerid, RED, NOT_AVAIL);
    ApplyAnimation(playerid, "BEACH", "Lay_Bac_Loop", 4.1, 1, 0, 0, 0, 0);
	return 1;
}

YCMD:smoke(playerid, params[], help)
{
    if((g_GlobalStatus != e_Status_Playing && g_GlobalStatus != e_Status_Prepare) || gTeam[playerid] != gHUMAN) return SCM(playerid, RED, NOT_AVAIL);
    ApplyAnimation(playerid, "SHOP", "Smoke_RYD", 4.1, 1, 0, 0, 0, 0);
	return 1;
}

YCMD:uptime(playerid, params[], help)
{
	SCM(playerid, GREY, GetUptime());
	return 1;
}

YCMD:top(playerid, params[], help)
{
	ShowPlayerDialog(playerid, DIALOG_TOPLIST, DIALOG_STYLE_LIST, ""zwar" - Toplists", ""dl"Richlist (/richlist)\n"dl"Score (/score)\n"dl"Most Kills (/kills)\n"dl"Most Deaths (/deaths)\n"dl"Most playing time (/toptime)", "Select", "Cancel");
	return 1;
}

YCMD:toptime(playerid, params[], help)
{
	new playingtime[MAX_PLAYERS][e_top_time],
		finstring[2048],
		tmpstring[68];

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerAvail(i))
	    {
	        playingtime[i][E_playerid] = i;
		    PlayerData[i][iTime] = PlayerData[i][iTime] + (gettime() - PlayerData[i][iConnectTime]);
		    PlayerData[i][iConnectTime] = gettime();
	        playingtime[i][E_time] = PlayerData[i][iTime];
	    }
	    else
	    {
	        playingtime[i][E_playerid] = -1;
	        playingtime[i][E_time] = -1;
	    }
	}

	SortDeepArray(playingtime, E_time, .order = SORT_DESC);

	for(new i = 0; i < 30; i++)
	{
	    if(playingtime[i][E_time] != -1)
	    {
		    format(tmpstring, sizeof(tmpstring), "{%06x}%i - %s(%i) - Time: %s\n", GetPlayerColor(playingtime[i][E_playerid]) >>> 8, i + 1, __GetName(playingtime[i][E_playerid]), playingtime[i][E_playerid], GetPlayingTimeFormat(playingtime[i][E_playerid]));
		    strcat(finstring, tmpstring);
		}
		else
		{
		    format(tmpstring, sizeof(tmpstring), ""white"%i - ---\n", i + 1);
		    strcat(finstring, tmpstring);
		}
	}

    ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Most Playing Time", finstring, "OK", "");
	return 1;
}

YCMD:deaths(playerid, params[], help)
{
	new deaths[MAX_PLAYERS][e_top_deaths],
		finstring[2048],
		tmpstring[68];

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerAvail(i))
	    {
	        deaths[i][E_playerid] = i;
	        deaths[i][E_deaths] = PlayerData[i][iDeaths];
	    }
	    else
	    {
	        deaths[i][E_playerid] = -1;
	        deaths[i][E_deaths] = -1;
	    }
	}

	SortDeepArray(deaths, E_deaths, .order = SORT_DESC);

	for(new i = 0; i < 30; i++)
	{
	    if(deaths[i][E_deaths] != -1)
	    {
		    format(tmpstring, sizeof(tmpstring), "{%06x}%i - %s(%i) - Deaths: %i\n", GetPlayerColor(deaths[i][E_playerid]) >>> 8, i + 1, __GetName(deaths[i][E_playerid]), deaths[i][E_playerid], deaths[i][E_deaths]);
		    strcat(finstring, tmpstring);
		}
		else
		{
		    format(tmpstring, sizeof(tmpstring), ""white"%i - ---\n", i + 1);
		    strcat(finstring, tmpstring);
		}
	}

    ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Most Deaths", finstring, "OK", "");
	return 1;
}

YCMD:kills(playerid, params[], help)
{
	new kills[MAX_PLAYERS][e_top_kills],
		finstring[2048],
		tmpstring[68];

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerAvail(i))
	    {
	        kills[i][E_playerid] = i;
	        kills[i][E_kills] = PlayerData[i][iKills];
	    }
	    else
	    {
	        kills[i][E_playerid] = -1;
	        kills[i][E_kills] = -1;
	    }
	}

	SortDeepArray(kills, E_kills, .order = SORT_DESC);

	for(new i = 0; i < 30; i++)
	{
	    if(kills[i][E_kills] != -1)
	    {
		    format(tmpstring, sizeof(tmpstring), "{%06x}%i - %s(%i) - Kills: %i\n", GetPlayerColor(kills[i][E_playerid]) >>> 8, i + 1, __GetName(kills[i][E_playerid]), kills[i][E_playerid], kills[i][E_kills]);
		    strcat(finstring, tmpstring);
		}
		else
		{
		    format(tmpstring, sizeof(tmpstring), ""white"%i - ---\n", i + 1);
		    strcat(finstring, tmpstring);
		}
	}

    ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Most Kills", finstring, "OK", "");
	return 1;
}

YCMD:richlist(playerid, params[], help)
{
	new richlist[MAX_PLAYERS][e_top_richlist],
		finstring[2048],
		tmpstring[68];

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerAvail(i))
	    {
	        richlist[i][E_playerid] = i;
	        richlist[i][E_money] = PlayerData[i][iMoney];
	    }
	    else
	    {
	        richlist[i][E_playerid] = -1;
	        richlist[i][E_money] = -1;
	    }
	}

	SortDeepArray(richlist, E_money, .order = SORT_DESC);

	for(new i = 0; i < 30; i++)
	{
	    if(richlist[i][E_money] != -1)
	    {
		    format(tmpstring, sizeof(tmpstring), "{%06x}%i - %s(%i) - Money: $%s\n", GetPlayerColor(richlist[i][E_playerid]) >>> 8, i + 1, __GetName(richlist[i][E_playerid]), richlist[i][E_playerid], number_format(richlist[i][E_money]));
		    strcat(finstring, tmpstring);
		}
		else
		{
		    format(tmpstring, sizeof(tmpstring), ""white"%i - ---\n", i + 1);
		    strcat(finstring, tmpstring);
		}
	}

    ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Richlist", finstring, "OK", "");
	return 1;
}

YCMD:score(playerid, params[], help)
{
	new score[MAX_PLAYERS][e_top_score],
		finstring[2048],
		tmpstring[68];

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerAvail(i))
	    {
	        score[i][E_playerid] = i;
	        score[i][E_pscore] = GetPlayerScoreEx(i);
	    }
	    else
	    {
	        score[i][E_playerid] = -1;
	        score[i][E_pscore] = -1;
	    }
	}

	SortDeepArray(score, E_pscore, .order = SORT_DESC);

	for(new i = 0; i < 30; i++)
	{
	    if(score[i][E_pscore] != -1)
	    {
		    format(tmpstring, sizeof(tmpstring), "{%06x}%i - %s(%i) - Score: %i\n", GetPlayerColor(score[i][E_playerid]) >>> 8, i + 1, __GetName(score[i][E_playerid]), score[i][E_playerid], score[i][E_pscore]);
		    strcat(finstring, tmpstring);
		}
		else
		{
		    format(tmpstring, sizeof(tmpstring), ""white"%i - ---\n", i + 1);
		    strcat(finstring, tmpstring);
		}
	}
	ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Score", finstring, "OK", "");
	return 1;
}

YCMD:ping(playerid, params[], help)
{
	new player;
	if(sscanf(params, "r", player))
	{
        return SCM(playerid, YELLOW, "Usage: /ping <playerid>");
	}

    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
	if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

	format(gstr, sizeof(gstr), ""green" %s's(%i) ping is %i", __GetName(player), player, GetPlayerPing(player));
	SCM(playerid, -1, gstr);
	return 1;
}

COMMAND:pay(playerid, params[])
{
	new player, cash;
	if(sscanf(params, "ri", player, cash))
	{
		return SCM(playerid, YELLOW, "Usage: /pay <playerid> <money>");
	}
	
    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
	if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");
	
	if(IsPlayerAvail(player))
	{
    	if(GetPlayerMoneyEx(playerid) < cash)
		{
			return SCM(playerid, RED, "You don't have that much!");
		}
    	if(cash < 1000 || cash > 1000000)
		{
			return SCM(playerid, YELLOW, "Info: $1,000 - $1,000,000");
		}
    	if(player == playerid)
		{
			return SCM(playerid, RED, "You can't pay yourself");
		}
		new string[100];
      	GivePlayerMoneyEx(playerid, -cash);
      	GivePlayerMoneyEx(player, cash);
        format(string, sizeof(string), "Info: %s paid you $%s", __GetName(playerid), number_format(cash));
        SCM(player, YELLOW, string);
        SCM(playerid, YELLOW, "Successfully paid the money!");
    }
    else
    {
        SCM(playerid, -1, ""er"Player is not connected");
    }
	return 1;
}

COMMAND:pornos(playerid, params[])
{
    SCM(playerid, RED, "Du kannst mir mal fett ein kauen, kein Godfather.");
	return 1;
}

YCMD:report(playerid, params[], help)
{
	new tick = GetTickCountEx();
	if((PlayerData[playerid][tickLastReport] + COOLDOWN_CMD_REPORT) >= tick)
	{
    	return SCM(playerid, -1, ""er"Please wait a bit before using this cmd again!");
	}

	new	player, reason[144];
	if(sscanf(params, "rs[144]", player, reason))
	{
		return SCM(playerid, YELLOW, "Usage: /report <playerid> <reason>");
	}

    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
	if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

 	if(IsPlayerAvail(player) && player != playerid && PlayerData[player][iAdminLevel] == 0)
	{
		if(strlen(reason) < 4) return SCM(playerid, -1, ""er"Please write more");

		new time[3];
		gettime(time[0], time[1], time[2]);

		format(gstr, sizeof(gstr), ""YELLOW_E"Report(%02i:%02i:%02i) "RED_E"%s(%i) -> %s(%i) -> %s", time[0], time[1], time[2], __GetName(playerid), playerid, __GetName(player), player, reason);
		for(new i = 1; i < MAX_REPORTS - 1; i++)
		{
			g_sReports[i] = g_sReports[i + 1];
		}
		g_sReports[MAX_REPORTS - 1] = gstr;

        broadcast_admin(-1, gstr);

		SCM(playerid, YELLOW, "Your report has been sent to online Admins");
		PlayerData[playerid][tickLastReport] = tick;
	}
	else
	{
		SCM(playerid, -1, ""er"You cannot report this player!");
	}
	return 1;
}

YCMD:reports(playerid, params[], help)
{
    if(PlayerData[playerid][iAdminLevel] >= 1)
	{
        new ReportCount;
		for(new i = 1; i < MAX_REPORTS; i++)
		{
			if(strcmp(g_sReports[i], "<none>", true) != 0)
			{
				ReportCount++;
				SCM(playerid, WHITE, g_sReports[i]);
			}
		}

		if(ReportCount == 0)
		{
			SCM(playerid, WHITE, "There have been no reports");
		}
    }
	else
	{
		SCM(playerid, -1, NO_PERM);
	}
	return 1;
}

YCMD:admins(playerid, params[], help)
{
	new finstring[2048], count = 0;
	format(finstring, sizeof(finstring), ""blue"Admins:\n"white"");

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(!IsPlayerAvail(i)) continue;
	    
	    if(PlayerData[i][iAdminLevel] > 0)
	    {
	        if(IsPlayerOnDesktop(i))
				format(gstr, sizeof(gstr), "%s(%i) | Level: %i | [AFK]\n", __GetName(i), i, PlayerData[i][iAdminLevel]);
			else
			    format(gstr, sizeof(gstr), "%s(%i) | Level: %i\n", __GetName(i), i, PlayerData[i][iAdminLevel]);

			strcat(finstring, gstr);
			count++;
	    }
	}

	if(count == 0)
	{
	    SCM(playerid, -1, ""er"No admins online!");
	}
	else
	{
	    format(gstr, sizeof(gstr), "\n"white"Total of "blue"%i "white"Admins online!", count);
	    strcat(finstring, gstr);
		ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Admins", finstring, "OK", "");
	}
	return 1;
}

YCMD:id(playerid, params[], help)
{
	if(isnull(params))
	{
		return SCM(playerid, YELLOW, "Usage: /id <nick/part of nick>");
	}

	new found, playername[MAX_PLAYER_NAME + 1];
	format(gstr, sizeof(gstr), "Searched for: %s", params);
	SCM(playerid, GREEN, gstr);

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerAvail(i))
		{
	  		GetPlayerName(i, playername, MAX_PLAYER_NAME+1);
			new namelen = strlen(playername), bool:searched = false;
	    	for(new pos = 0; pos < namelen; pos++)
			{
				if(!searched)
				{
					if(strfind(playername, params, true) == pos)
					{
						format(gstr, sizeof(gstr), "%i. %s (ID %i)", ++found, playername, i);
						SCM(playerid, GREEN, gstr);
						searched = true;
					}
				}
			}
		}
	}
	if(found == 0) SCM(playerid, -1, ""er"No players have this in their nick");
	return 1;
}

YCMD:pm(playerid, params[], help)
{
	if(PlayerData[playerid][iMute] != 0)
	{
	    SCM(playerid, RED, "You are muted! Wait until the time is over!");
	    return 0;
	}
	
	new player, msg[144];
	if(sscanf(params, "rs[144]", player, msg))
	{
		return SCM(playerid, YELLOW, "Usage: /pm <playerid> <message>");
	}
	
    if(player == INVALID_PLAYER_ID) return SCM(playerid, -1, ""er"Invalid player!");
	if(!IsPlayerConnected(player)) return SCM(playerid, -1, ""er"Player not connected!");

	if(IsAd(msg))
	{
	  	format(gstr2, sizeof(gstr2), ""yellow"** "red"Suspicion advertising | Player: %s(%i) Advertised IP: %s - PlayerIP: %s", __GetName(playerid), playerid, msg, __GetIP(playerid));
		broadcast_admin(RED, gstr2);

        SCM(playerid, RED, "Advertising is not allowed!");
        return 1;
	}
	
	if(!IsPlayerAvail(player))
	{
		return SCM(playerid, -1, ""er"Player is not connected!");
	}
	if(player == playerid)
	{
	    return SCM(playerid, -1, ""er"You can't pm yourself");
	}
	
	format(gstr, sizeof(gstr), "***[PM] from %s(%i): %s", __GetName(playerid), playerid, msg);
    SCM(player, YELLOW, gstr);
	format(gstr, sizeof(gstr), ">>>[PM] to %s(%i): %s", __GetName(player), player, msg);
	SCM(playerid, YELLOW, gstr);
	PlayerData[PlayerData[playerid][iLastPM]][iLastPM] = playerid;
	
	PlaySound(playerid, 1057);
	PlaySound(player, 1057);
	
	format(gstr, sizeof(gstr), "[PM] from %s(%i) to %s(%i): %s", __GetName(playerid), playerid, __GetName(player), player, msg);
	broadcast_admin(GREY, gstr);
	return 1;
}

YCMD:r(playerid, params[], help)
{
    if(PlayerData[playerid][iLastPM] == INVALID_PLAYER_ID)
	{
		return SCM(playerid, -1, ""er"Nobody has send you a message yet");
	}

	extract params -> new string:msg[128]; else
	{
	    return SCM(playerid, YELLOW, "Usage: /r <message>");
	}

	if(IsAd(msg))
	{
	  	format(gstr, sizeof(gstr), ""yellow"** "red"Suspicion advertising | Player: %s(%i) Advertised IP: %s - PlayerIP: %s", __GetName(playerid), playerid, msg, __GetIP(playerid));
		broadcast_admin(RED, gstr);

        SCM(playerid, RED, "Advertising is not allowed!");
        return 1;
	}

	if(!IsPlayerAvail(PlayerData[playerid][iLastPM]))
	{
		return SCM(playerid, -1, ""er"Player is not connected!");
	}

	format(gstr, sizeof(gstr), "***[PM] from %s(%i): %s", __GetName(playerid), playerid, msg);
    SCM(PlayerData[playerid][iLastPM], YELLOW, gstr);
	format(gstr, sizeof(gstr), ">>>[PM] to %s(%i): %s", __GetName(PlayerData[playerid][iLastPM]), PlayerData[playerid][iLastPM], msg);
	SCM(playerid, YELLOW, gstr);
	PlayerData[PlayerData[playerid][iLastPM]][iLastPM] = playerid;

	PlaySound(playerid, 1057);
	PlaySound(PlayerData[playerid][iLastPM], 1057);

	format(gstr, sizeof(gstr), ""grey"[PM] from %s(%i) to %s(%i): %s", __GetName(playerid), playerid, __GetName(PlayerData[playerid][iLastPM]), PlayerData[playerid][iLastPM], msg);
	broadcast_admin(GREY, gstr);
	return 1;
}

YCMD:sounds(playerid, params[], help)
{
    if(PlayerData[playerid][bSoundsDisabled])
    {
        SCM(playerid, -1, ""er"You enabled all (streamed) sounds!");
        PlayerData[playerid][bSoundsDisabled] = false;
	}
	else
	{
	    SCM(playerid, -1, ""er"You disabled all (streamed) sounds!");
	    PlayerData[playerid][bSoundsDisabled] = true;
	}
	return 1;
}

YCMD:rules(playerid, params[], help)
{
	new rules[700];

	strcat(rules, ""white"- No cheating of any kind\n- No mods that affect other player's gameplay\n- No insults\n- No advertising of any kind\n- No (command)spamming\n");
	strcat(rules, "- No abusing bugs/glitches/commands\n- Do not share your account details\n- Do not ask for an unban ingame\n- Do not ask for an admin level/free VIP");
	strcat(rules, "\n- Do not go AFK for too long or you may get kicked");
	strcat(rules, "\n- No score/money farming\n- Do not use joypad\n- No spawnkilling!\n\nNever give your password to anyone!");

    ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Rules", rules, "OK", "");
	return 1;
}

SQL_Connect()
{
    g_pSQL = mysql_connect(SQL_HOST, SQL_USER, SQL_DATA, SQL_PASS, SQL_PORT, true);

    if(mysql_errno(g_pSQL) == 0)
    {
		Log(LOG_INIT, "MySQL: Connected @ ["SQL_HOST"]:%i", SQL_PORT);
    }
    else
    {
        Log(LOG_INIT, "MySQL: Failed to connect. Error: ", mysql_errno(g_pSQL));

        SendRconCommand("exit");
    }
}

SQL_RegisterAccount(playerid, hash[])
{
	PlayerData[playerid][iLastLogin] = gettime();
    PlayerData[playerid][iRegisterDate] = gettime();

    new ORM:ormid = PlayerData[playerid][pORM] = orm_create("accounts");

    AssembleORM(ormid, playerid);

	orm_setkey(ormid, "id");
	orm_insert(ormid, "OnPlayerRegister", "iissss", playerid, YHash(__GetName(playerid)), hash, __GetName(playerid), __GetIP(playerid), __GetSerial(playerid));
}

AssembleORM(ORM:ormid, playerid)
{
	orm_addvar_int(ormid, PlayerData[playerid][iAccountID], "id");
	orm_addvar_string(ormid, PlayerData[playerid][sName], MAX_PLAYER_NAME + 1, "name");
	orm_addvar_int(ormid, PlayerData[playerid][iAdminLevel], "admin");
	orm_addvar_int(ormid, PlayerData[playerid][iMapper], "mapper");
	orm_addvar_int(ormid, PlayerData[playerid][iEXP], "exp");
	orm_addvar_int(ormid, PlayerData[playerid][iMoney], "money");
	orm_addvar_int(ormid, PlayerData[playerid][iKills], "kills");
	orm_addvar_int(ormid, PlayerData[playerid][iDeaths], "deaths");
	orm_addvar_int(ormid, PlayerData[playerid][iTime], "time");
	orm_addvar_int(ormid, PlayerData[playerid][iVIP], "vip");
	orm_addvar_int(ormid, PlayerData[playerid][iSkin], "skin");
	orm_addvar_int(ormid, PlayerData[playerid][iCookies], "cookies");
	orm_addvar_int(ormid, PlayerData[playerid][iMedkits], "medkits");
	orm_addvar_int(ormid, PlayerData[playerid][iLastNC], "lastnc");
	orm_addvar_int(ormid, PlayerData[playerid][iLastLogin], "lastlogin");
	orm_addvar_int(ormid, PlayerData[playerid][iTimesKick], "timeskick");
	orm_addvar_int(ormid, PlayerData[playerid][iTimesLogin], "timeslogin");
	orm_addvar_int(ormid, PlayerData[playerid][iRegisterDate], "regdate");
}

SQL_CleanUp()
{
	mysql_tquery(g_pSQL, "UPDATE `accounts` SET `signed` = 0;");
}

SQL_UpdateAccount(playerid)
{
    mysql_format(g_pSQL, gstr2, sizeof(gstr2), "UPDATE `accounts` SET `signed` = 1, `ip` = '%s', `serial` = '%e', `version` = '%e' WHERE `id` = %i LIMIT 1;",
		__GetIP(playerid),
		__GetSerial(playerid),
		__GetVersion(playerid),
		PlayerData[playerid][iAccountID]);
		
    mysql_tquery(g_pSQL, gstr2);
}

SQL_LoadAccount(playerid)
{
	mysql_format(g_pSQL, gstr2, sizeof(gstr2), "SELECT * FROM `accounts` WHERE `id` = %i LIMIT 1;", PlayerData[playerid][iAccountID]);
	mysql_tquery(g_pSQL, gstr2, "OnPlayerAccountRequest", "iii", playerid, YHash(__GetName(playerid)), ACCOUNT_REQUEST_LOAD);
}

SQL_LogPlayerOut(playerid)
{
	mysql_format(g_pSQL, gstr2, sizeof(gstr2), "UPDATE `accounts` SET `signed` = 0 WHERE `id` = %i LIMIT 1;", PlayerData[playerid][iAccountID]);
	mysql_tquery(g_pSQL, gstr2);
}

SQL_UpdatePlayerPass(playerid, hash[])
{
	new salt[SALT_LENGTH + 1];
	random_string(SALT_LENGTH, salt, sizeof(salt)); // Generate a new salt for this account

	mysql_format(g_pSQL, gstr2, sizeof(gstr2), "UPDATE `accounts` SET `hash` = '%s', `salt` = '%s' WHERE `name` = '%s' LIMIT 1;", hash, salt, __GetName(playerid));
 	mysql_tquery(g_pSQL, gstr2);
}

SQL_CreateBan(PlayerName[], AdminName[], Reason[], lift=0)
{
	new query[300], rescape[129], aescape[25], pescape[25];
	mysql_escape_string(Reason, rescape, g_pSQL, 129);
	mysql_escape_string(AdminName, aescape, g_pSQL, 25);
	mysql_escape_string(PlayerName, pescape, g_pSQL, 25);
    format(query, sizeof(query), "INSERT INTO `bans` VALUES (NULL, '%s', '%s', '%s', %i, %i);", pescape, aescape, rescape, lift, gettime());
    mysql_tquery(g_pSQL, query, "", "");
}

SQL_BanIP(const ip[])
{
	new query[100];
 	format(query, sizeof(query), "INSERT INTO `blacklist` VALUES (NULL, '%s', %i);", ip, gettime());
 	mysql_tquery(g_pSQL, query, "", "");
}

SQL_SaveAccount(playerid)
{
    if(PlayerData[playerid][pORM] == ORM:-1) {
    	Log(LOG_PLAYER, "Crit: ORM -1 in SaveAccount %s, %i", __GetName(playerid), playerid);
	} else {
	    orm_update(PlayerData[playerid][pORM]);
	}
}

KickEx(playerid)
{
	PlayerData[playerid][bOpenSeason] = true;
	SetTimerEx("Kick_Delay", 3000, 0, "ii", playerid, YHash(__GetName(playerid)));
	return 1;
}

function:Kick_Delay(playerid, namehash)
{
	if(YHash(__GetName(playerid)) == namehash)
	{
		Kick(playerid);
	}
	return 1;
}

function:ZMP_InfestationCountDown()
{
	if(iInfestaion >= 0)
	{
        format(gstr, sizeof(gstr), "~w~Infestation arrival in ~r~~h~~h~%i ~w~seconds.~n~Prepare your ass!", iInfestaion);
        TextDrawSetString(txtInfestationArrival, gstr);

		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerConnected(i))
			{
				PlaySound(i, 1056);
			}
		}

        iInfestaion--;
	}
	else
	{
	    KillTimer(tInfestation);
        KillTimer(tRescue);
        
		if(ZMP_GetPlayers() <= 1)
		{
		    SCMToAll(-1, ""zwar" "red"Could not infect due to lack of players!");

			ZMP_EndGame();
		}
		else
		{
	        bInfestationArrived = true;
            g_GlobalStatus = e_Status_Playing;
            
	        TextDrawHideForAll(txtInfestationArrival);
			TextDrawShowForAll(txtRescue);

			iRescue = DEFAULT_RESCUE_TIME;
			tRescue = SetTimer("ZMP_RescueCountDown", 1000, 1);
			
			ZMP_RandomInfection();
		}
	}
	return 1;
}

function:ZMP_RescueCountDown()
{
	if(iRescue > 0)
	{
        format(gstr, sizeof(gstr), "~w~Rescue in: ~r~~h~~h~%s", ZMP_ConvertTime(iRescue));
        TextDrawSetString(txtRescue, gstr);
	        
	    iRescue--;
	}
	else if(iRescue <= 0)
	{
	    if(ZMP_GetHumans() > 0)
	    {
	        TextDrawSetString(txtRescue, "~w~Rescue arrived!");
	        GameTextForAll("~w~Humans win!", 10000, 5);
		}
		else
		{
	        TextDrawSetString(txtRescue, "~w~Rescue abandoned!");
	        GameTextForAll("~w~Zombies win!", 10000, 5);
		}
		
		ZMP_EndGame();

        format(gstr, sizeof(gstr), ""zwar" Round end! Humans left: "lb_e"%i "white"| Zombies: "lb_e"%i", ZMP_GetHumans(), ZMP_GetZombies());
        SCMToAll(-1, gstr);
	}
	return 1;
}

function:ZMP_SwitchMap()
{
    ZMP_BeginNewGame();
    return 1;
}

function:ForceClassSpawn(playerid, namehash)
{
	if(IsPlayerConnected(playerid) && YHash(__GetName(playerid)) == namehash)
	{
    	SpawnPlayer(playerid);
	}
	return 1;
}

function:HideMoneyTD(playerid, namehash)
{
	if(IsPlayerConnected(playerid) && YHash(__GetName(playerid)) == namehash)
	{
    	PlayerTextDrawHide(playerid, TXTMoney[playerid]);
	}
}

function:HideScoreTD(playerid, namehash)
{
	if(IsPlayerConnected(playerid) && YHash(__GetName(playerid)) == namehash)
	{
    	PlayerTextDrawHide(playerid, TXTScore[playerid]);
	}
}

function:OnNCReceive(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields);

	if(rows > 0)
	{
	    new tmp[128], string[1024], oldname[25], newname[25];
	    strcat(string, ""white"Displaying last 10 Name Change Records:\n\n");
	    for(new i = 0; i < rows; i++)
	    {
	        cache_get_row(i, 1, oldname, g_pSQL, sizeof(oldname));
	        cache_get_row(i, 2, newname, g_pSQL, sizeof(newname));
	        format(tmp, sizeof(tmp), "%i - %s changed their name to %s on %s\n", i + 1, oldname, newname, UTConvert(cache_get_row_int(i, 3, g_pSQL)));
	        strcat(string, tmp);
	    }

		ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Namechange Records", string, "OK", "");
	}
	return 1;
}

function:OnNCReceive2(playerid, name[])
{
	new rows, fields;
	cache_get_data(rows, fields, g_pSQL);

	if(rows > 0)
	{
	    new tmp[128], string[1024], oldname[25], newname[25];
	    format(tmp, sizeof(tmp), ""white"%i Name Change Records for %s\n\n", rows, name);
	    strcat(string, tmp);
	    for(new i = 0; i < rows; i++)
	    {
	        cache_get_row(i, 1, oldname, g_pSQL, sizeof(oldname));
	        cache_get_row(i, 2, newname, g_pSQL, sizeof(newname));
	        format(tmp, sizeof(tmp), "%i - %s changed their name to %s on %s\n", i + 1, oldname, newname, UTConvert(cache_get_row_int(i, 3, g_pSQL)));
	        strcat(string, tmp);
	    }

		ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Namechange Records", string, "OK", "");
	}
	else SCM(playerid, -1, ""er"No records found for that player");
	return 1;
}

function:ProcessTick()
{
	if(g_GlobalStatus != e_Status_Inactive)
	{
		new string[64];
		format(string, sizeof(string), "(%i|%i) ZombieSurvivalFunHorror", ZMP_GetZombies(), ZMP_GetHumans());
		SetGameModeText(string);
	}
	
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerAvail(i) && gTeam[i] != gNONE)
	    {
			if(!IsPlayerOnDesktop(i, 2500))
			{
	        	ZMP_UpdatePlayerHealthTD(i);
			}
		}
		
		if(g_GlobalStatus == e_Status_Playing)
		{
			if(gTeam[i] == gHUMAN && IsPlayerConnected(i) && !PlayerData[i][bOpenSeason])
			{
				if(IsPlayerOnDesktop(i, 10000) && bad_afk_detect() && !PlayerData[i][bOpenSeason])
				{
				    // Kick afk players
				    PlayerData[i][bOpenSeason] = true;

					format(gstr, sizeof(gstr), ""yellow"** "red"%s(%i) has been auto-kicked by BitchOnDuty [Reason: Critical AFK time]", __GetName(i), i);
					SCMToAll(YELLOW, gstr);
					print(gstr);

		  			KickEx(i);
				}
			}
		}
	}
	return 1;
}

function:OnPlayerNameChangeRequest(playerid, newname[])
{
	if(cache_get_row_count() > 0)
	{
	    SCM(playerid, -1, ""er"Your name is already in use or contains invalid characters");
	}
	else
	{
		if(GetPlayerMoneyEx(playerid) < 50000)
			return 1;

	    new oldname[MAX_PLAYER_NAME + 1];
	    strmid(oldname, __GetName(playerid), 0, sizeof(oldname), sizeof(oldname));

		if(SetPlayerName(playerid, newname) == 1) // If successfull
        {
			strmid(PlayerData[playerid][sName], newname, MAX_PLAYER_NAME + 1, MAX_PLAYER_NAME + 1);
			GivePlayerMoneyEx(playerid, -50000);

            format(gstr2, sizeof(gstr2), "UPDATE `accounts` SET `name` = '%s' WHERE `name` = '%s' LIMIT 1;", newname, oldname);
            mysql_tquery(g_pSQL, gstr2);

            format(gstr2, sizeof(gstr2), "INSERT INTO `ncrecords` VALUES (NULL, '%s', '%s', UNIX_TIMESTAMP());", oldname, newname);
            mysql_tquery(g_pSQL, gstr2);

			format(gstr2, sizeof(gstr2), ""white"You have successfully changed your name.\n\nNew name: %s\nOld name: %s", newname, oldname);
			ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" - Namechange", gstr2, "OK", "");

			format(gstr2, sizeof(gstr2), ""zwar" %s(%i) has changed their name to %s", oldname, playerid, newname);
			SCMToAll(-1, gstr2);

			SQL_SaveAccount(playerid);
        }
        else
        {
            SCM(playerid, -1, ""er"Your name is already in use or contains invalid characters");
        }
	}
	return 1;
}

function:player_free(playerid, namehash)
{
	if(namehash == YHash(__GetName(playerid)))
	{
		if(PlayerData[playerid][bLoadMap])
		{
			TogglePlayerControllable(playerid, 1);
			TextDrawHideForPlayer(playerid, txtLoading);
			PlayerData[playerid][tLoadMap] = -1;
			PlayerData[playerid][bLoadMap] = false;
		}
	}
	return 1;
}

function:p_medkit(playerid)
{
	if(PlayerData[playerid][iMedkitTime] > 0)
	{
	    if(!IsPlayerConnected(playerid))
	    {
			KillTimer(PlayerData[playerid][tMedkit]);
			PlayerData[playerid][tMedkit] = -1;
			return 1;
	    }

		new Float:health;
		GetPlayerHealth(playerid, health);

		if(health + 1.0 >= 100.0)
		{
			KillTimer(PlayerData[playerid][tMedkit]);
			PlayerData[playerid][tMedkit] = -1;
			GameTextForPlayer(playerid, "~g~~h~~h~Max. Health reached!", 3000, 5);
			return 1;
		}

		SetPlayerHealth(playerid, health + 1.0);
		SetPlayerChatBubble(playerid, ""green"Used 1 Medkit!", -1, 15.0, 200);

		PlayerData[playerid][iMedkitTime]--;
	}
	else
	{
	    KillTimer(PlayerData[playerid][tMedkit]);
	    PlayerData[playerid][tMedkit] = -1;
	    GameTextForPlayer(playerid, "~g~~h~~h~Medkit depleted!", 3000, 5);
	}
	return 1;
}

function:server_broadcast_random()
{
    SCMToAll(WHITE, g_szRandomServerMessages[random(sizeof(g_szRandomServerMessages))]);
	return 1;
}

function:OnUnbanAttempt(playerid, unban[])
{
	new rows, fields;
	cache_get_data(rows, fields, g_pSQL);
	
	if(rows > 0)
	{
	    new query[128];
	    format(query, sizeof(query), "DELETE FROM `bans` WHERE `name` = '%s' LIMIT 1;", unban);
	    
	    mysql_tquery(g_pSQL, query, "", "");
	    
	    SCM(playerid, -1, ""er"Player has been unbanned!");
	}
	else
	{
	    SCM(playerid, -1, ""er"Player is not banned or does not exist");
	}
	return 1;
}

function:OnOfflineBanAttempt(playerid, ban[], reason[])
{
	new rows, fields;
	cache_get_data(rows, fields, g_pSQL);

	if(rows > 0)
	{
	    SCM(playerid, -1, ""er"Player is already banned!");
	}
	else
	{
	    format(gstr, sizeof(gstr), "SELECT `adminlevel`, `ip` FROM `accounts` WHERE `name` = '%s';", ban);
	    mysql_tquery(g_pSQL, gstr, "OnOfflineBanAttempt2", "iss", playerid, ban, reason);
	}
	return 1;
}

function:OnOfflineBanAttempt2(playerid, ban[], reason[])
{
	new rows, fields;
	cache_get_data(rows, fields, g_pSQL);

	if(rows > 0)
	{
	    if(cache_get_row_int(0, 0, g_pSQL) != 0)
	    {
	        return SCM(playerid, -1, ""er"You may not ban admins");
	    }
	    
	    new ip[16];
		cache_get_row(0, 1, ip, g_pSQL, sizeof(ip));
	    
		SQL_CreateBan(ban, __GetName(playerid), reason);
		SQL_BanIP(ip);
		
		SCM(playerid, -1, ""er"Player has been banned!");
	}
	else
	{
	    SCM(playerid, -1, ""er"Player does not exist!");
	}
	return 1;
}

function:OnPlayerAccountRequest(playerid, namehash, request)
{
    if(!IsPlayerConnected(playerid))
		return 0;

	if(YHash(__GetName(playerid)) != namehash) {
	    Log(LOG_NET, "OnPlayerAccountRequest data race detected, kicking (%s, %i, %i, %i, req:%i)", __GetName(playerid), playerid, YHash(__GetName(playerid)), namehash, request);
	    Kick(playerid);
		return 0;
	}

	switch(request)
	{
	    case ACCOUNT_REQUEST_PRELOAD_ID:
	    {
	        if (cache_get_row_count() == 0)
	        {
	            // Account does not exist and therefore not banned but might their IP
		        mysql_format(g_pSQL, gstr2, sizeof(gstr2), "SELECT * FROM `blacklist` WHERE `ip` = '%e' LIMIT 1;", __GetIP(playerid));
		        mysql_pquery(g_pSQL, gstr2, "OnPlayerAccountRequest", "iii", playerid, YHash(__GetName(playerid)), ACCOUNT_REQUEST_IP_BANNED + 1);
	        }
	        else
	        {
	            PlayerData[playerid][iAccountID] = cache_get_row_int(0, 0);

				mysql_format(g_pSQL, gstr2, sizeof(gstr2), "SELECT accounts.name, bans.reason, bans.lift, bans.date, UNIX_TIMESTAMP() FROM bans INNER JOIN accounts ON accounts.id = bans.admin_id WHERE bans.id = %i LIMIT 1;",
							PlayerData[playerid][iAccountID]);
				mysql_pquery(g_pSQL, gstr2, "OnPlayerAccountRequest", "iii", playerid, YHash(__GetName(playerid)), ACCOUNT_REQUEST_BANNED);
	        }
			return 1;
	    }
	    case ACCOUNT_REQUEST_BANNED:
	    {
	        if(cache_get_row_count() == 0)
	        {
	            // No ban row associated with the account therefore not banned
	            goto _continue;
	        }
	        else
	        {
	            new szAdmin[MAX_PLAYER_NAME + 1],
					szReason[64 + 1],
					u_iLift,
					u_iDate,
					u_iTime;
					
				cache_get_row(0, 0, szAdmin);
				cache_get_row(0, 1, szReason);
				u_iLift = cache_get_row_int(0, 2);
				u_iDate = cache_get_row_int(0, 3);
				u_iTime = cache_get_row_int(0, 4);
				
				if(u_iLift < u_iTime && u_iLift != 0)
				{
					// The time ban expired, delete it from database and continue
				    mysql_format(g_pSQL, gstr2, sizeof(gstr2), "DELETE FROM `bans` WHERE `id` = %i LIMIT 1;", PlayerData[playerid][iAccountID]);
				    mysql_pquery(g_pSQL, gstr2);

				    SCM(playerid, -1, ""zwar" Your time ban expired, you've been unbanned!");
				    goto _continue;
				}
				else if(u_iLift != 0)
				{
				    format(gstr2, sizeof(gstr2), ""red"You have been time banned!"white"\n\nAdmin: %s\nYour name: %s\nReason: %s\nBan Expires: %s\n\nIf you think that you have been banned wrongly,\nwrite a ban appeal on "URL"",
								szAdmin,
								__GetName(playerid),
								szReason,
								UTConvert(u_iLift));
								
					ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" :: Notice", gstr2, "OK", "");
					KickEx(playerid);
					return 1;
				}
				else if(u_iLift == 0)
				{
				    format(gstr2, sizeof(gstr2), ""red"You have been permanently banned!"white"\n\nAdmin: %s\nYour name: %s\nReason: %s\nDate: %s\n\nIf you think that you have been banned wrongly,\nwrite a ban appeal on "URL"",
								szAdmin,
								__GetName(playerid),
								szReason,
								UTConvert(u_iDate));
								
					ShowPlayerDialog(playerid, NO_DIALOG_ID, DIALOG_STYLE_MSGBOX, ""zwar" :: Notice", gstr2, "OK", "");
					KickEx(playerid);
					return 1;
				}
	        }
	        
	        _continue:
	        mysql_format(g_pSQL, gstr2, sizeof(gstr2), "SELECT * FROM `blacklist` WHERE `ip` = '%e' LIMIT 1;", __GetIP(playerid));
	        mysql_pquery(g_pSQL, gstr2, "OnPlayerAccountRequest", "iii", playerid, YHash(__GetName(playerid)), ACCOUNT_REQUEST_IP_BANNED);
	        return 1;
	    }
	    case ACCOUNT_REQUEST_IP_BANNED:
	    {
            if(cache_get_row_count() == 0)
            {
                // IP Address is not blacklisted
				mysql_format(g_pSQL, gstr2, sizeof(gstr2), "SELECT `id` FROM `accounts` WHERE `id` = %i AND `ip` = '%s' LIMIT 1;", PlayerData[playerid][iAccountID], __GetIP(playerid));
				mysql_pquery(g_pSQL, gstr2, "OnPlayerAccountRequest", "iii", playerid, YHash(__GetName(playerid)), ACCOUNT_REQUEST_AUTO_LOGIN); // Check auto login
            }
            else
			{
	 		   	SCM(playerid, -1, ""server_sign" You have been banned.");
       			KickEx(playerid);
			}
	        return 1;
	    }
		case ACCOUNT_REQUEST_IP_BANNED + 1:
		{
            if(cache_get_row_count() == 0)
            {
                // IP Address is not blacklisted
				RequestRegistration(playerid);

				InterpolateCameraPos(playerid, -2004.7083, 760.5217, 54.0513, -1999.1829, 921.1962, 56.4846, 50000, CAMERA_MOVE);
				InterpolateCameraLookAt(playerid, -2004.4877, 759.5416, 53.9013, -1998.5679, 920.4014, 56.3046, 50000, CAMERA_MOVE);
            }
            else
			{
	 		   	SCM(playerid, -1, ""server_sign" You have been banned.");
       			KickEx(playerid);
			}
	        return 1;
		}
	    case ACCOUNT_REQUEST_AUTO_LOGIN:
	    {
	        if(cache_get_row_count() > 0) // Account with IP found
	        {
	            // Auto Login
				AutoLogin(playerid);
	        }
	        else // IP on account is not the same as current connection
	        {
	            // Login Dialog
	            RequestLogin(playerid);

	     		InterpolateCameraPos(playerid, -2004.7083, 760.5217, 54.0513, -1999.1829, 921.1962, 56.4846, 50000, CAMERA_MOVE);
			    InterpolateCameraLookAt(playerid, -2004.4877, 759.5416, 53.9013, -1998.5679, 920.4014, 56.3046, 50000, CAMERA_MOVE);
	        }
	        return 1;
	    }
	    case ACCOUNT_REQUEST_LOAD:
	    {
			if(cache_get_row_count() > 0)
			{
				new ORM:ormid = PlayerData[playerid][pORM] = orm_create("accounts");

				AssembleORM(ormid, playerid);

				orm_setkey(ormid, "id");
				orm_apply_cache(ormid, 0);

			 	SetPlayerMoneyEx(playerid, PlayerData[playerid][iMoney]);
			 	SetPlayerScore(playerid, PlayerData[playerid][iEXP]);
			 	PlayerData[playerid][iConnectTime] = gettime();

				if(PlayerData[playerid][iAdminLevel] > 0)
				{
					format(gstr, sizeof(gstr), ""server_sign" "grey"Successfully logged in. (Adminlevel %i)", PlayerData[playerid][iAdminLevel]);
					SCM(playerid, -1, gstr);
					format(gstr, sizeof(gstr), ""server_sign" "grey"You were last online at %s and registered on %s", UTConvert(PlayerData[playerid][iLastLogin]), UTConvert(PlayerData[playerid][iRegisterDate]));
  					SCM(playerid, -1, gstr);
					format(gstr, sizeof(gstr), ""server_sign" "grey"You've been online for %s", GetPlayingTimeFormat(playerid));
					SCM(playerid, -1, gstr);
		   		}
		   		else
		   		{
				   	SCM(playerid, -1, ""server_sign" "grey"Successfully logged in!");
					format(gstr, sizeof(gstr), ""server_sign" "grey"You were last online at %s and registered on %s", UTConvert(PlayerData[playerid][iLastLogin]), UTConvert(PlayerData[playerid][iRegisterDate]));
  					SCM(playerid, -1, gstr);
					format(gstr, sizeof(gstr), ""server_sign" "grey"You've been online for %s", GetPlayingTimeFormat(playerid));
					SCM(playerid, -1, gstr);
				}

				if(PlayerData[playerid][iVIP] == 1)
				{
                    format(gstr, sizeof(gstr), ""server_sign" "grey"VIP %s(%i) logged in!", __GetName(playerid), playerid);
                    SCMToAll(-1, gstr);
				}
			}
			return 1;
		}
	}
	return 0;
}

function:OnPlayerLoginAttempt(playerid, namehash, password[])
{
	if(namehash != YHash(__GetName(playerid)))
		return 0;
		
	if(cache_get_row_count() != 1)
	    return SCM(playerid, -1, ""er"Fatal login error, account key not found or multiple results.");

	new db_hash[SHA3_LENGTH + 1], db_salt[SALT_LENGTH + 1];
	new hash[SHA3_LENGTH + 1], validate[sizeof(db_hash) + sizeof(db_salt) + 1];

	cache_get_row(0, 0, db_hash, g_pSQL, sizeof(db_hash));
	cache_get_row(0, 1, db_salt, g_pSQL, sizeof(db_salt));
	
	format(validate, sizeof(validate), "%s%s", password, db_salt);
	sha3(validate, hash, sizeof(hash));
	
	if(strcmp(db_hash, hash))
	{
	    SCM(playerid, -1, ""er"Login failed, incorrect password!");
	    RequestLogin(playerid);
	}
	else
	{
		PlayerData[playerid][bLogged] = true;
		PlayerData[playerid][bFirstSpawn] = true;
		PlayerData[playerid][iExitType] = EXIT_LOGGED;
		PlayerData[playerid][iLastLogin] = gettime();
		TogglePlayerSpectating(playerid, false);
		SQL_UpdateAccount(playerid);
		SQL_LoadAccount(playerid);
	}
	return 1;
}

function:OnPlayerRegister(playerid, namehash, hash[], playername[], ip_address[], serial[])
{
	new salt[SALT_LENGTH + 1], tosave[sizeof(salt) + SHA3_LENGTH + 1], query[512];
	random_string(SALT_LENGTH, salt, sizeof(salt));
	format(tosave, sizeof(tosave), "%s%s", hash, salt);

	mysql_format(g_pSQL, query, sizeof(query), "UPDATE `accounts` SET `hash` = '%e', `salt` = '%e', `ip` = '%e', `serial` = '%e' WHERE `name` = '%e' LIMIT 1;", tosave, salt, ip_address, serial, playername);
	mysql_tquery(g_pSQL, query);

	if(namehash == YHash(__GetName(playerid)))
	{
		PlayerData[playerid][iConnectTime] = gettime();
	    PlayerData[playerid][bLogged] = true;
	    PlayerData[playerid][bFirstSpawn] = true;
        PlayerData[playerid][iExitType] = EXIT_LOGGED;
        TogglePlayerSpectating(playerid, false);

		format(gstr, sizeof(gstr), ""zwar" %s(%i) "grey"registered, making the server have a total of "green"%i "grey"players registered.", __GetName(playerid), playerid, cache_insert_id());
		SCMToAll(-1, gstr);

        GivePlayerMoneyEx(playerid, 10000);
	    GameTextForPlayer(playerid, "Welcome", 3000, 4);
  		GameTextForPlayer(playerid, "~n~+$10,000~n~Startcash", 3000, 1);
		SCM(playerid, -1, ""server_sign" "grey"You are now registered, and have been logged in!");
		PlaySound(playerid, 1057);
	}
	return 1;
}

function:remove_health_obj(damagedid)
{
	if(IsPlayerConnected(damagedid))
	{
	    RemovePlayerAttachedObject(damagedid, 8);
	    g_bPlayerHit[damagedid] = false;
	}
	return 1;
}

function:server_init_shutdown()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i))
	    {
			Kick(i);
		}
	}
	SetTimer("_server_shutdown", 2000, 0);
	return 1;
}

function:_server_shutdown()
{
	Log(LOG_EXIT, "server_shutdown called");
	SendRconCommand("exit");
	return 1;
}

function:OnMapDataLoad()
{
	for(new i = 0, c = cache_get_row_count(); i < c; ++i)
	{
	    g_Maps[i][e_id] = cache_get_row_int(i, 0);
	    cache_get_row(i, 1, g_Maps[i][e_mapname], g_pSQL, 24);
	    g_Maps[i][e_spawn_x] = cache_get_row_float(i, 3);
	    g_Maps[i][e_spawn_y] = cache_get_row_float(i, 4);
	    g_Maps[i][e_spawn_z] = cache_get_row_float(i, 5);
	    g_Maps[i][e_spawn_a] = cache_get_row_float(i, 6);
	    g_Maps[i][e_weather] = cache_get_row_int(i, 7);
	    g_Maps[i][e_time] = cache_get_row_int(i, 8);
	    g_Maps[i][e_shop_x] = cache_get_row_float(i, 9);
	    g_Maps[i][e_shop_y] = cache_get_row_float(i, 10);
	    g_Maps[i][e_shop_z] = cache_get_row_float(i, 11);
	    g_Maps[i][e_times_played] = cache_get_row_int(i, 12);
	    g_Maps[i][e_require_preload] = cache_get_row_int(i, 13);
		g_Maps[i][e_world] = cache_get_row_int(i, 14);
		g_Maps[i][e_countdown] = cache_get_row_int(i, 15);
	    cache_get_row(i, 15, g_Maps[i][e_author], g_pSQL, MAX_PLAYER_NAME + 1);

        g_MapCount++;
	}
	Log(LOG_ONLINE, "Retrieved %i maps", g_MapCount);
	return 1;
}

server_initialize()
{
	format(gstr, sizeof(gstr), "hostname %s", HOSTNAME);
	SendRconCommand(gstr);
	SendRconCommand("weburl "URL"");
    SetGameModeText("(-|-) ZombieSurvivalFunHorror");
	SendRconCommand("mapname ZombieSurvivalFunHorror");
	
	FuckOffGayAssFaggotNigger();
    EnableVehicleFriendlyFire();
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_STREAMED);
    DisableInteriorEnterExits();
    ShowNameTags(1);
    SetNameTagDrawDistance(50.0);
    AllowInteriorWeapons(1);
    UsePlayerPedAnims();
    EnableStuntBonusForAll(0);
	SetWeather(43);
    SetWorldTime(7);

	g_iStartTime = gettime();
    
 	Command_AddAltNamed("cmds", "commands");
	Command_AddAltNamed("stats", "statistics");
	Command_AddAltNamed("sounds", "sound");
	Command_AddAltNamed("adminhelp", "ahelp");
	Command_AddAltNamed("adminhelp", "acmds");
	Command_AddAltNamed("go", "goto");
	Command_AddAltNamed("stopanim", "stopanims");
	Command_AddAltNamed("mk", "medkit");
	Command_AddAltNamed("mk", "medkits");
}

GetTickCountEx()
{
	return (GetTickCount() + 3600000);
}

Log(E_LOG_LEVEL:log_level, const fmat[], va_args<>)
{
	va_format(gstr2, sizeof(gstr2), fmat, va_start<2>);
	
	switch(log_level)
	{
	    case LOG_INIT: strins(gstr2, "LogInit: ", 0, sizeof(gstr2));
		case LOG_EXIT: strins(gstr2, "LogExit: ", 0, sizeof(gstr2));
		case LOG_ONLINE: strins(gstr2, "LogOnline: ", 0, sizeof(gstr2));
		case LOG_NET: strins(gstr2, "LogNet: ", 0, sizeof(gstr2));
		case LOG_PLAYER: strins(gstr2, "LogPlayer: ", 0, sizeof(gstr2));
		case LOG_WORLD: strins(gstr2, "LogWorld: ", 0, sizeof(gstr2));
		case LOG_FAIL: strins(gstr2, "LogError: ", 0, sizeof(gstr2));
		case LOG_SUSPECT: strins(gstr2, "LogSuspect: ", 0, sizeof(gstr2));
	}
	return print(gstr2);
}

stock GetWeaponModel(weaponid)
{
    switch(weaponid)
    {
        case 1: return 331;
        case 2..8: return weaponid+331;
		case 9: return 341;
		case 10..15: return weaponid+311;
		case 16..18: return weaponid+326;
		case 22..29: return weaponid+324;
		case 30,31: return weaponid+325;
		case 32: return 372;
		case 33..45: return weaponid+324;
		case 46: return 371;
    }
    return 0;
}

stock Float:GetDistance3D(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
{
	return VectorSize(x1 - x2, y1 - y2, z1 - z2);
}

Float:GetDistanceBetweenPlayers(playerid1, playerid2)
{
	if(playerid1 == INVALID_PLAYER_ID || playerid2 == INVALID_PLAYER_ID)
	    return -1.00;

	if(!IsPlayerConnected(playerid1) || !IsPlayerConnected(playerid2))
	    return -1.00;

	new Float:pPOS[2][3];

	GetPlayerPos(playerid1, pPOS[0][0], pPOS[0][1], pPOS[0][2]);
	GetPlayerPos(playerid2, pPOS[1][0], pPOS[1][1], pPOS[1][2]);

	return VectorSize(pPOS[0][0] - pPOS[1][0], pPOS[0][1] - pPOS[1][1], pPOS[0][2] - pPOS[1][2]);
}

LoadMap(playerid)
{
	if(g_Maps[g_CurrentMap][e_require_preload])
	{
		Streamer_Update(playerid);
		PlayerData[playerid][bLoadMap] = true;
		TogglePlayerControllable(playerid, 0);
		TextDrawShowForPlayer(playerid, txtLoading);

		switch(GetPlayerPing(playerid))
		{
			case 0..50:
			{
			    PlayerData[playerid][tLoadMap] = SetTimerEx("player_free", 1500, 0, "ii", playerid, YHash(__GetName(playerid)));
			}
			case 51..100:
			{
			    PlayerData[playerid][tLoadMap] = SetTimerEx("player_free", 2100, 0, "ii", playerid, YHash(__GetName(playerid)));
			}
			case 101..200:
			{
			    PlayerData[playerid][tLoadMap] = SetTimerEx("player_free", 2500, 0, "ii", playerid, YHash(__GetName(playerid)));
			}
			default:
			{
			    PlayerData[playerid][tLoadMap] = SetTimerEx("player_free", 3100, 0, "ii", playerid, YHash(__GetName(playerid)));
			}
		}
	}
}

PlayInfectSound()
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerAvail(i))
	    {
	        PlaySound(i, 1039);
	    }
	}
}

__GetPlayerID(const playername[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
    {
    	if(IsPlayerConnected(i))
      	{
        	if(!strcmp(playername, __GetName(i)))
        	{
          		return i;
        	}
      	}
    }
    return INVALID_PLAYER_ID;
}

__GetName(playerid)
{
    new name[MAX_PLAYER_NAME + 1];

	strcat(name, PlayerData[playerid][sName], MAX_PLAYER_NAME + 1);
    return name;
}

__GetIP(playerid)
{
	new ip[MAX_PLAYER_IP + 1];

	strcat(ip, PlayerData[playerid][sIP], MAX_PLAYER_IP + 1);
    return ip;
}

__GetSerial(playerid)
{
	new tmp[64];

    gpci(playerid, tmp, sizeof(tmp));
    return tmp;
}

__GetVersion(playerid)
{
	new tmp[20 + 1];
	
	GetPlayerVersion(playerid, tmp, sizeof(tmp));
	
	if(strlen(tmp) > 20)
		strmid(tmp, "INVALID_VERSION", 0, 20, 20);
		
	return tmp;
}

GetUptime()
{
    new	Remaining = gettime() - g_iStartTime,
        Time[4];

    Time[0] = Remaining % 60;
    Remaining /= 60;
    Time[1] = Remaining % 60;
    Remaining /= 60;
    Time[2] = Remaining % 24;
    Remaining /= 24;
    Time[3] = Remaining;

    if(Time[3])
    {
        format(gstr, sizeof(gstr), ""white"Server is up for %i days, %i hours, %i minutes and %i seconds", Time[3], Time[2], Time[1], Time[0]);
	}
    else if(Time[2])
    {
        format(gstr, sizeof(gstr), ""white"Server is up for %i hours, %i minutes and %i seconds", Time[2], Time[1], Time[0]);
	}
    else if(Time[1])
    {
        format(gstr, sizeof(gstr), ""white"Server is up for %i minutes and %i seconds", Time[1], Time[0]);
	}
    else
    {
        format(gstr, sizeof(gstr), ""white"Server is up for %i seconds", Time[0]);
	}
    return gstr;
}

ZMP_PlayerStatsUpdate(playerid)
{
	format(gstr2, sizeof(gstr2), "~w~Score: %i~n~Money: $%s~n~Kills: %i~n~Deaths: %i~n~K/D: %.2f",
	    PlayerData[playerid][iEXP],
	    number_format(PlayerData[playerid][iMoney]),
	    PlayerData[playerid][iKills],
	    PlayerData[playerid][iDeaths],
        Float:PlayerData[playerid][iKills] / (PlayerData[playerid][iDeaths] == 0 ? 1.00 : Float:PlayerData[playerid][iDeaths]));

	PlayerTextDrawSetString(playerid, TXTPlayerStats[playerid], gstr2);
}

ZMP_UpdatePlayerHealthTD(playerid)
{
	const Float:MIN = 497.00;
	const Float:MAX = 605.00;

	new Float:h, Float:POS;
	GetPlayerHealth(playerid, h);

	if(gTeam[playerid] == gZOMBIE && h >= 1.00)
	{
		h = h / 2.00;
	}

	if(h >= 100.00)
	{
	    POS = MAX;
	}
	else if(h <= 0.00)
	{
		POS = MIN;
	}
	else
	{
	    POS = floatadd(floatmul(h, 1.08), MIN);
	}

    PlayerTextDrawTextSize(playerid, TXTPlayerHealth[playerid], POS, -80.000000);
    PlayerTextDrawHide(playerid, TXTPlayerHealth[playerid]);
    PlayerTextDrawShow(playerid, TXTPlayerHealth[playerid]);
}

IsPlayerOnDesktop(playerid, afktimems = 5000)
{
	if((PlayerData[playerid][tickPlayerUpdate] + afktimems) < (GetTickCountEx())) return 1;
	return 0;
}

ZMP_RandomInfection()
{
	new Iterator:count<MAX_PLAYERS>;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerAvail(i) && gTeam[i] == gHUMAN)
	    {
	        Iter_Add(count, i);
	    }
	}

	if(Iter_Count(count) <= 1)
	{
        TextDrawSetString(txtRescue, "~w~Rescue abandoned!");

        if(!bInfestationArrived) GameTextForAll("~w~Humans win!", 10000, 5);

		ZMP_EndGame();

        format(gstr, sizeof(gstr), ""zwar" Round end! Humans left: "lb_e"%i "white"| Zombies: "lb_e"%i", ZMP_GetHumans(), ZMP_GetZombies());
        SCMToAll(-1, gstr);

	    // Server empty or what? lol | this shouldn't even be called lul
	    printf("[DEBUG] RI = %i Z = %i", Iter_Count(count), ZMP_GetZombies());
	}
	else
	{
		new Iterator:count2<MAX_PLAYERS>;
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
		    if(IsPlayerAvail(i) && gTeam[i] == gHUMAN && !IsPlayerOnDesktop(i, 1000))
		    {
		        Iter_Add(count2, i);
		    }
		}

		new pid;
		if(Iter_Count(count2) == 0)
		{
	        pid = Iter_Random(count);
		}
		else
		{
	        pid = Iter_Random(count2);
		}

		format(gstr, sizeof(gstr), ""zwar" "yellow"%s(%i) has been infected by the infestation!", __GetName(pid), pid);
		SCMToAll(-1, gstr);

        ZMP_SetPlayerZombie(pid, false);
        PlayInfectSound();

        GameTextForPlayer(pid, "~w~Infect others by punching them!", 3000, 5);
	}
	return 1;
}

ZMP_SetPlayerHuman(playerid)
{
	ClearAnimations(playerid);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    SetPlayerVirtualWorld(playerid, g_World);
	SetPlayerPos(playerid, g_Maps[g_CurrentMap][e_spawn_x], g_Maps[g_CurrentMap][e_spawn_y], g_Maps[g_CurrentMap][e_spawn_z] + 4.0);
	SetPlayerFacingAngle(playerid, g_Maps[g_CurrentMap][e_spawn_a]);
	SetCameraBehindPlayer(playerid);

    gTeam[playerid] = gHUMAN;
    SetPlayerTeam(playerid, TEAM_H);
    SetPlayerColor(playerid, trans(COLOR_HUMAN));

    ResetPlayerWeapons(playerid);
    GivePlayerWeapon(playerid, 22, 999999);
    GivePlayerWeapon(playerid, 25, 15);
    SetPlayerSkin(playerid, humanskins[random(sizeof(humanskins))]);
    SetPlayerHealth(playerid, 100.0);

	PlayerData[playerid][iTimesHit] = 0;

    TogglePlayerControllable(playerid, 1);
}

ZMP_SetPlayerZombie(playerid, bool:homespawn = true)
{
	ClearAnimations(playerid);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
    SetPlayerVirtualWorld(playerid, g_World);

    if(homespawn)
    {
		SetPlayerPos(playerid, g_Maps[g_CurrentMap][e_spawn_x], g_Maps[g_CurrentMap][e_spawn_y], g_Maps[g_CurrentMap][e_spawn_z] + 4.0);
		SetPlayerFacingAngle(playerid, g_Maps[g_CurrentMap][e_spawn_a]);
	}

	SetCameraBehindPlayer(playerid);

    gTeam[playerid] = gZOMBIE;
    SetPlayerTeam(playerid, TEAM_Z);
    SetPlayerColor(playerid, trans(COLOR_ZOMBIE));
    ResetPlayerWeapons(playerid);
    SetPlayerHealth(playerid, 200.0);

    switch(random(10))
    {
		case 6, 1: // Hunter
		{
		    GameTextForPlayer(playerid, "~r~~h~~h~You spawned as a Hunter!~n~~w~You can now jump higher!", 3000, 3);
		    SetPlayerSkin(playerid, ID_HUNTER);
		    PlayerData[playerid][gSpecialZed] = zedHUNTER;
		}
		case 8, 5: // Bloomer
		{
		    GameTextForPlayer(playerid, "~r~~h~~h~You spawned as a Bloomer!~n~~w~Press ~k~~CONVERSATION_NO~ or ~k~~CONVERSATION_YES~ to explode!", 3000, 3);
		    SetPlayerSkin(playerid, ID_BLOOMER);
		    PlayerData[playerid][gSpecialZed] = zedBLOOMER;
		    PlayerData[playerid][bExploded] = false;
		}
		case 0, 2, 3, 4, 7, 9: // Normal Zombie
		{
		    SetPlayerSkin(playerid, zedskins[random(sizeof(zedskins))]);
		    PlayerData[playerid][gSpecialZed] = zedZOMBIE;
		}
    }

	TogglePlayerControllable(playerid, 1);
}

KillGameTimers()
{
    KillTimer(tRescue);
    KillTimer(tInfestation);
}

ZMP_EndGame()
{
	KillGameTimers();

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerAvail(i))
		{
	    	if(!PlayerData[i][bIsDead])
				TogglePlayerControllable(i, 0);
		}
	}

	Map_Unload();

	g_GlobalStatus = e_Status_RoundEnd;
	SetTimer("ZMP_SwitchMap", 10000, 0);
	return 1;
}

ZMP_BeginNewGame()
{
    g_GlobalStatus = e_Status_Prepare;
    bInfestationArrived = false;
    new bool:bFound = false;

    do
    {
        if(g_ForceMap != -1)
        {
            g_CurrentMap = g_ForceMap;
            g_ForceMap = -1;
			iOldMap = g_CurrentMap;
			bFound = true;
			break;
        }

   		g_CurrentMap = CPRNG_Generate(0, g_MapCount - 1);

        if(g_CurrentMap != iOldMap || g_MapCount == 1 )
        {
            iOldMap = g_CurrentMap;
            bFound = true;
		}
    }
    while(!bFound);

	Map_Load(g_CurrentMap);

	TextDrawHideForAll(txtRescue);

	format(gstr, sizeof(gstr), ""zwar" "green"Starting new round! Map: %s", g_Maps[g_CurrentMap][e_mapname]);
	SCMToAll(-1, gstr);

	if(g_Maps[g_CurrentMap][e_world] == 0)
		g_World = random_int(1000, 100000);
	else
		g_World = g_Maps[g_CurrentMap][e_world];

	new count = 0;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerAvail(i))
		{
		    ZMP_SetPlayerHuman(i);
            ZMP_SyncPlayer(i);

			LoadMap(i);
			
            count++;
		}
	}
	if(count <= 0)
	{
		Map_Unload();
		g_GlobalStatus = e_Status_Inactive;
	    return 1;
	}

	iInfestaion = DEFAULT_INFESTATION_TIME;
    tInfestation = SetTimer("ZMP_InfestationCountDown", 1000, 1);
	TextDrawShowForAll(txtInfestationArrival);
	return 1;
}

DEPRECATED PlayAudio(playerid, url[])
{
	if(!PlayerData[playerid][bSoundsDisabled] && !IsPlayerOnDesktop(playerid, 3000))
	{
	    PlayAudioStreamForPlayer(playerid, url);
	}
}

PlaySound(playerid, id)
{
	if(!PlayerData[playerid][bSoundsDisabled] && !IsPlayerOnDesktop(playerid, 1000))
	{
	    PlayerPlaySound(playerid, id, 0.0, 0.0, 0.0);
	}
}

trans(col)
{
	return (col - 0xBB);
}

RequestRegistration(playerid)
{
    format(gstr, sizeof(gstr), ""zwar" Registration - %s", __GetName(playerid));
	format(gstr2, sizeof(gstr2), ""white"Welcome "grey"%s"red" to Zombie "white"Warfare"white"!\n\nEnter a password for your new account below:", __GetName(playerid));
	ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, gstr, gstr2, "Register", "");
	return 1;
}

AutoLogin(playerid)
{
    PlayerData[playerid][bLogged] = true;
    PlayerData[playerid][bFirstSpawn] = true;
    PlayerData[playerid][iExitType] = EXIT_LOGGED;
    TogglePlayerSpectating(playerid, false);
    SQL_UpdateAccount(playerid);
    SQL_LoadAccount(playerid);
	return 1;
}

RequestLogin(playerid)
{
    format(gstr, sizeof(gstr), ""zwar" Login - %s", __GetName(playerid));
    format(gstr2, sizeof(gstr2), ""white"Welcome "grey"%s"white" to "blue"Zombie Warfare"white"!\n\nThe name you are using is registered! Please enter the password:", __GetName(playerid));
	ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, gstr, gstr2, "Login", "");
    return 1;
}

SetPlayerMoneyEx(playerid, amount)
{
	if(playerid == INVALID_PLAYER_ID) return 1;
    ResetPlayerMoney(playerid);
	PlayerData[playerid][iMoney] = amount;
    GivePlayerMoney(playerid, PlayerData[playerid][iMoney]);
    ZMP_PlayerStatsUpdate(playerid);
    return 1;
}

GivePlayerMoneyEx(playerid, amount, bool:populate = true)
{
	if(playerid == INVALID_PLAYER_ID) return 1;

    ResetPlayerMoney(playerid);

    PlayerData[playerid][iMoney] += amount;

    GivePlayerMoney(playerid, PlayerData[playerid][iMoney]);

    ZMP_PlayerStatsUpdate(playerid);

    if(populate)
    {
        new str[64];
        if(amount < 0)
        {
            format(str, sizeof(str), "~r~~h~~h~-$%i", amount * -1);
        }
        else
        {
	        format(str, sizeof(str), "~g~~h~~h~+$%s", number_format(amount));
		}
		PlayerTextDrawSetString(playerid, TXTMoney[playerid], str);
        PlayerTextDrawShow(playerid, TXTMoney[playerid]);
		SetTimerEx("HideMoneyTD", 3000, 0, "ii", playerid, YHash(__GetName(playerid)));
    }
	return 1;
}

GetPlayerMoneyEx(playerid)
{
    if(playerid == INVALID_PLAYER_ID) return 1;
	return (PlayerData[playerid][iMoney]);
}

GivePlayerScoreEx(playerid, amount, bool:populate = true)
{
    if(playerid == INVALID_PLAYER_ID) return 1;

    PlayerData[playerid][iEXP] += amount;
	SetPlayerScore(playerid, PlayerData[playerid][iEXP]);

    ZMP_PlayerStatsUpdate(playerid);

    if(populate)
    {
        new str[64];
        if(amount < 0)
        {
            format(str, sizeof(str), "~r~~h~~h~-%i Score", amount * -1);
        }
        else
        {
	        format(str, sizeof(str), "~y~~h~+%s Score", number_format(amount));
		}
		PlayerTextDrawSetString(playerid, TXTScore[playerid], str);
        PlayerTextDrawShow(playerid, TXTScore[playerid]);
		SetTimerEx("HideScoreTD", 3000, 0, "ii", playerid, YHash(__GetName(playerid)));
    }
	return 1;
}

SetPlayerScoreEx(playerid, amount)
{
    if(playerid == INVALID_PLAYER_ID) 
		return -1;
		
	PlayerData[playerid][iEXP] = amount;
    SetPlayerScore(playerid, PlayerData[playerid][iEXP]);
    ZMP_PlayerStatsUpdate(playerid);
	return 1;
}

GetPlayerScoreEx(playerid)
{
    if(playerid == INVALID_PLAYER_ID) 
		return -1;
		
	return PlayerData[playerid][iEXP];
}

GetPlayingTimeFormat(playerid)
{
    PlayerData[playerid][iTime] = PlayerData[playerid][iTime] + (gettime() - PlayerData[playerid][iConnectTime]);
    PlayerData[playerid][iConnectTime] = gettime();

    new ptime[32],
        time[3];

    time[0] = floatround(PlayerData[playerid][iTime] / 3600, floatround_floor);
    time[1] = floatround(PlayerData[playerid][iTime] / 60, floatround_floor) % 60;
    time[2] = floatround(PlayerData[playerid][iTime] % 60, floatround_floor);

	format(ptime, sizeof(ptime), "%ih %02im %02is", time[0], time[1], time[2]);
	return ptime;
}

UTConvert(unixtime)
{
	new u_year,
	    u_month,
	    u_day,
		u_hour,
		u_minute,
		u_second,
		u_date[50];

    TimestampToDate(unixtime, u_year, u_month, u_day, u_hour, u_minute, u_second, 1);

    format(u_date, sizeof(u_date), "%02i/%02i/%i %02i:%02i:%02i", u_day, u_month, u_year, u_hour, u_minute, u_second);
	return u_date;
}

CPRNG_Generate(min, max_deduct)
{
	if(min == max_deduct)
	    return min;
	return random_int(min, max_deduct);
}

number_format(num)
{
    new szStr[16];
    format(szStr, sizeof(szStr), "%i", num);

    for(new iLen = strlen(szStr) - (num < 0 ? 4 : 3); iLen > 0; iLen -= 3)
    {
        strins(szStr, ",", iLen);
    }
    return szStr;
}

FuckOffGayAssFaggotNigger()
{
	new a[][] =
	{
		"Unarmed (Fist)",
		"Brass K"
	};
	#pragma unused a
}

IsAd(const text[])
{
	new is1 = 0,
		r = 0;

 	while(strlen(text[is1]))
 	{
  		if('0' <= text[is1] <= '9')
  		{
 			new is2 = is1 + 1,
			 	p = 0;

			while(p == 0)
  			{
   				if('0' <= text[is2] <= '9' && strlen(text[is2]))
		   		{
			  		is2++;
				}
 				else
  				{
				   	strmid(gstr2[r], text, is1, is2, sizeof(gstr2));
				   	if(strval(gstr2[r]) < sizeof(gstr2)) r++;
				    is1 = is2;
				    p = 1;
				}
			}
		}
 		is1++;
 	}
	if(r >= 4 && r <= 8) return true;
	return false;
}

ZMP_ConvertTime(seconds)
{
	new tmp[16];
 	new minutes = floatround(seconds / 60);
  	seconds -= minutes * 60;
   	format(tmp, sizeof(tmp), "%02i:%02i", minutes, seconds);
   	return tmp;
}

ZMP_ShowLogo(playerid)
{
	for(new i = 0; i < sizeof(txtZMPLogo); i++)
	{
 		TextDrawShowForPlayer(playerid, txtZMPLogo[i]);
	}
}

ZMP_HideLogo(playerid)
{
	for(new i = 0; i < sizeof(txtZMPLogo); i++)
	{
	    TextDrawHideForPlayer(playerid, txtZMPLogo[i]);
	}
}

server_load_textdraws()
{
	txtZMPLogo[0] = TextDrawCreate(231.000000, 85.000000, "Zombie~n~   ~r~~h~~h~Warfare");
	TextDrawBackgroundColor(txtZMPLogo[0], 255);
	TextDrawFont(txtZMPLogo[0], 0);
	TextDrawLetterSize(txtZMPLogo[0], 0.959999, 3.899998);
	TextDrawColor(txtZMPLogo[0], -1);
	TextDrawSetOutline(txtZMPLogo[0], 1);
	TextDrawSetProportional(txtZMPLogo[0], 1);
	TextDrawSetSelectable(txtZMPLogo[0], 0);

	txtZMPLogo[1] = TextDrawCreate(324.000000, 99.000000, "~r~~h~~h~z~w~warfare.com");
	TextDrawBackgroundColor(txtZMPLogo[1], 255);
	TextDrawFont(txtZMPLogo[1], 1);
	TextDrawLetterSize(txtZMPLogo[1], 0.299999, 1.699999);
	TextDrawColor(txtZMPLogo[1], -1);
	TextDrawSetOutline(txtZMPLogo[1], 1);
	TextDrawSetProportional(txtZMPLogo[1], 1);
	TextDrawSetSelectable(txtZMPLogo[1], 0);

	txtZMPLogo[2] = TextDrawCreate(231.000000, 132.000000, ""VERSION"");
	TextDrawBackgroundColor(txtZMPLogo[2], 255);
	TextDrawFont(txtZMPLogo[2], 1);
	TextDrawLetterSize(txtZMPLogo[2], 0.309999, 1.899999);
	TextDrawColor(txtZMPLogo[2], -1);
	TextDrawSetOutline(txtZMPLogo[2], 1);
	TextDrawSetProportional(txtZMPLogo[2], 1);
	TextDrawSetSelectable(txtZMPLogo[2], 0);

	txtHealthOverlay = TextDrawCreate(546.000000, 67.000000, " ~r~~h~~h~Z~w~warfare.com");
	TextDrawBackgroundColor(txtHealthOverlay, 255);
	TextDrawFont(txtHealthOverlay, 1);
	TextDrawLetterSize(txtHealthOverlay, 0.240000, 0.799999);
	TextDrawColor(txtHealthOverlay, -1);
	TextDrawSetOutline(txtHealthOverlay, 0);
	TextDrawSetProportional(txtHealthOverlay, 1);
	TextDrawSetShadow(txtHealthOverlay, 1);
	TextDrawUseBox(txtHealthOverlay, 1);
	TextDrawBoxColor(txtHealthOverlay, 255);
	TextDrawTextSize(txtHealthOverlay, 607.000000, 0.000000);
	TextDrawSetSelectable(txtHealthOverlay, 0);

	txtInfestationArrival = TextDrawCreate(322.000000, 25.000000, "~w~Infestation arrival in ~r~~h~~h~65 ~w~seconds.~n~Prepare your ass!");
	TextDrawAlignment(txtInfestationArrival, 2);
	TextDrawBackgroundColor(txtInfestationArrival, 255);
	TextDrawFont(txtInfestationArrival, 1);
	TextDrawLetterSize(txtInfestationArrival, 0.209998, 0.999998);
	TextDrawColor(txtInfestationArrival, -1);
	TextDrawSetOutline(txtInfestationArrival, 1);
	TextDrawSetProportional(txtInfestationArrival, 1);
	TextDrawSetSelectable(txtInfestationArrival, 0);

	txtRescue = TextDrawCreate(283.000000, 5.000000, "~w~Rescue in: ~r~~h~~h~7:00");
	TextDrawBackgroundColor(txtRescue, 255);
	TextDrawFont(txtRescue, 1);
	TextDrawLetterSize(txtRescue, 0.279999, 1.299998);
	TextDrawColor(txtRescue, -1);
	TextDrawSetOutline(txtRescue, 1);
	TextDrawSetProportional(txtRescue, 1);
	TextDrawSetSelectable(txtRescue, 0);

    txtLoading = TextDrawCreate(319.000000, 208.000000, "Loading...");
	TextDrawAlignment(txtLoading, 2);
	TextDrawBackgroundColor(txtLoading, 255);
	TextDrawFont(txtLoading, 2);
	TextDrawLetterSize(txtLoading, 0.469998, 2.099998);
	TextDrawColor(txtLoading, -1);
	TextDrawSetOutline(txtLoading, 1);
	TextDrawSetProportional(txtLoading, 1);
	TextDrawUseBox(txtLoading, 1);
	TextDrawBoxColor(txtLoading, 170);
	TextDrawTextSize(txtLoading, -9.000000, -152.000000);
}

server_fetch_mapdata()
{
	mysql_tquery(g_pSQL, "SELECT `maps`.*, `accounts`.`name` FROM `maps` INNER JOIN `accounts` ON `accounts`.`id` = `maps`.`author` LIMIT "MAX_MAPS_STRING";", "OnMapDataLoad");
}

Map_Load(index)
{
	if(g_bMapLoaded)
	    return 0;

	SetWorldTime(g_Maps[index][e_time]);
	SetWeather(g_Maps[index][e_weather]);
	
	g_ShopID = CreateDynamicCP(g_Maps[index][e_shop_x], g_Maps[index][e_shop_y], g_Maps[index][e_shop_z], 5.0);

	g_bMapLoaded = true;
	return 1;
}

Map_Unload()
{
	if(!g_bMapLoaded)
		return 0;

	DestroyDynamicCP(g_ShopID);
	g_ShopID = -1;

	g_bMapLoaded = false;
	return 1;
}

ZMP_GetZombies()
{
	new count = 0;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i) && gTeam[i] == gZOMBIE)
	    {
	        count++;
	    }
	}
	return count;
}

bad_afk_detect()
{
	new count = 0;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i) && gTeam[i] == gHUMAN && IsPlayerOnDesktop(i, 10000))
	    {
	        count++;
	    }
	}

	if(count == ZMP_GetHumans())
	{
	    return 1;
	}
	return 0;
}

ZMP_GetHumans()
{
	new count = 0;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i) && gTeam[i] == gHUMAN)
	    {
	        count++;
	    }
	}
	return count;
}

ZMP_GetPlayers()
{
	new count = 0;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i) && (gTeam[i] == gHUMAN || gTeam[i] == gZOMBIE))
	    {
	        count++;
	    }
	}
	return count;
}

ZMP_SyncPlayer(playerid)
{
    SetPlayerTime(playerid, g_Maps[g_CurrentMap][e_time], 0);
	SetPlayerWeather(playerid, g_Maps[g_CurrentMap][e_weather]);
}

broadcast_admin(color, const string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerAvail(i) && (PlayerData[i][iAdminLevel] >= 1))
		{
			SCM(i, color, string);
		}
	}
}

broadcast_vip(color, const string[])
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerAvail(i) && (PlayerData[i][iVIP] == 1 || PlayerData[i][iAdminLevel] > 0))
		{
			SCM(i, color, string);
		}
	}
}

ResetPlayerVars(playerid)
{
    gTeam[playerid] = gNONE;
    PlayerData[playerid][iExitType] = EXIT_NONE;
	PlayerData[playerid][iKills] = 0;
	PlayerData[playerid][iDeaths] = 0;
	PlayerData[playerid][bIsDead] = false;
	PlayerData[playerid][bLoadMap] = false;
    PlayerData[playerid][iEXP] = 0;
    PlayerData[playerid][iAdminLevel] = 0;
    PlayerData[playerid][iMoney] = 0;
    PlayerData[playerid][iTime] = 0;
    PlayerData[playerid][iVIP] = 0;
    PlayerData[playerid][iWarnings] = 0;
    PlayerData[playerid][iMedkits] = 0;
    PlayerData[playerid][iCookies] = 0;
    PlayerData[playerid][bLogged] = false;
   	PlayerData[playerid][iLastLogin] = 0;
   	PlayerData[playerid][iLastNC] = 0;
	PlayerData[playerid][iRegisterDate] = 0;
	PlayerData[playerid][iLastDeathTime] = 0;
	PlayerData[playerid][iDeathCountThreshold] = 0;
	PlayerData[playerid][iConnectTime] = 0;
	PlayerData[playerid][tickLastChat] = 0;
	PlayerData[playerid][tickPlayerUpdate] = 0;
	PlayerData[playerid][tickLastReport] = 0;
	PlayerData[playerid][tickLastPW] = 0;
	PlayerData[playerid][tickLastJump] = 0;
	PlayerData[playerid][tickLastMedkit] = 0;
	PlayerData[playerid][bSoundsDisabled] = false;
	PlayerData[playerid][bOpenSeason] = false;
	PlayerData[playerid][tLoadMap] = INVALID_TIMER;
	PlayerData[playerid][tMedkit] = INVALID_TIMER;
	PlayerData[playerid][iMute] = 0;
	PlayerData[playerid][iTimesHit] = 0;
	PlayerData[playerid][iLastPM] = INVALID_PLAYER_ID;
	g_bPlayerHit[playerid] = false;
	PlayerData[playerid][gSpecialZed] = zedZOMBIE;

    if(PlayerData[playerid][t3dVIPLabel] != Text3D:-1)
    {
        DestroyDynamic3DTextLabel(PlayerData[playerid][t3dVIPLabel]);
        PlayerData[playerid][t3dVIPLabel] = Text3D:-1;
    }
}

player_init_session(playerid)
{
	TXTMoney[playerid] = CreatePlayerTextDraw(playerid, 323.000000, 247.000000, "~g~~h~~h~+$100");
	PlayerTextDrawAlignment(playerid, TXTMoney[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid, TXTMoney[playerid], 255);
	PlayerTextDrawFont(playerid, TXTMoney[playerid], 1);
	PlayerTextDrawLetterSize(playerid, TXTMoney[playerid], 0.299999, 1.399999);
	PlayerTextDrawColor(playerid, TXTMoney[playerid], -1);
	PlayerTextDrawSetOutline(playerid, TXTMoney[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TXTMoney[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TXTMoney[playerid], 0);

	TXTScore[playerid] = CreatePlayerTextDraw(playerid, 323.000000, 262.000000, "~y~~h~+1 Score");
	PlayerTextDrawAlignment(playerid, TXTScore[playerid], 2);
	PlayerTextDrawBackgroundColor(playerid, TXTScore[playerid], 255);
	PlayerTextDrawFont(playerid, TXTScore[playerid], 1);
	PlayerTextDrawLetterSize(playerid, TXTScore[playerid], 0.299999, 1.399999);
	PlayerTextDrawColor(playerid, TXTScore[playerid], -1);
	PlayerTextDrawSetOutline(playerid, TXTScore[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TXTScore[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, TXTScore[playerid], 0);

	TXTPlayerStats[playerid] = CreatePlayerTextDraw(playerid, 500.000000, 377.000000, "~w~Score: 0~n~Money: $0~n~Kills: 0~n~Deaths: 0~n~K/D: 0.00");
	PlayerTextDrawBackgroundColor(playerid, TXTPlayerStats[playerid], 255);
	PlayerTextDrawFont(playerid, TXTPlayerStats[playerid], 1);
	PlayerTextDrawLetterSize(playerid, TXTPlayerStats[playerid], 0.260000, 1.000000);
	PlayerTextDrawColor(playerid, TXTPlayerStats[playerid], -1);
	PlayerTextDrawSetOutline(playerid, TXTPlayerStats[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TXTPlayerStats[playerid], 1);
	PlayerTextDrawUseBox(playerid, TXTPlayerStats[playerid], 1);
	PlayerTextDrawBoxColor(playerid, TXTPlayerStats[playerid], 168430148);
	PlayerTextDrawTextSize(playerid, TXTPlayerStats[playerid], 607.000000, 13.000000);
	PlayerTextDrawSetSelectable(playerid, TXTPlayerStats[playerid], 0);

	TXTMoneyOverlay[playerid] = CreatePlayerTextDraw(playerid, 498.000000, 79.000000, "~n~");
	PlayerTextDrawBackgroundColor(playerid, TXTMoneyOverlay[playerid], 255);
	PlayerTextDrawFont(playerid, TXTMoneyOverlay[playerid], 1);
	PlayerTextDrawLetterSize(playerid, TXTMoneyOverlay[playerid], 0.240000, 2.000000);
	PlayerTextDrawColor(playerid, TXTMoneyOverlay[playerid], -1);
	PlayerTextDrawSetOutline(playerid, TXTMoneyOverlay[playerid], 0);
	PlayerTextDrawSetProportional(playerid, TXTMoneyOverlay[playerid], 1);
	PlayerTextDrawSetShadow(playerid, TXTMoneyOverlay[playerid], 1);
	PlayerTextDrawUseBox(playerid, TXTMoneyOverlay[playerid], 1);
	PlayerTextDrawBoxColor(playerid, TXTMoneyOverlay[playerid], 255);
	PlayerTextDrawTextSize(playerid, TXTMoneyOverlay[playerid], 607.000000, 0.000000);
	PlayerTextDrawSetSelectable(playerid, TXTMoneyOverlay[playerid], 0);

	TXTPlayerHealth[playerid] = CreatePlayerTextDraw(playerid, 500.000000, 81.000000, "~n~");
	PlayerTextDrawBackgroundColor(playerid, TXTPlayerHealth[playerid], 255);
	PlayerTextDrawFont(playerid, TXTPlayerHealth[playerid], 1);
	PlayerTextDrawLetterSize(playerid, TXTPlayerHealth[playerid], 0.240000, 1.500000);
	PlayerTextDrawColor(playerid, TXTPlayerHealth[playerid], -1);
	PlayerTextDrawSetOutline(playerid, TXTPlayerHealth[playerid], 0);
	PlayerTextDrawSetProportional(playerid, TXTPlayerHealth[playerid], 1);
	PlayerTextDrawSetShadow(playerid, TXTPlayerHealth[playerid], 1);
	PlayerTextDrawUseBox(playerid, TXTPlayerHealth[playerid], 1);
	PlayerTextDrawBoxColor(playerid, TXTPlayerHealth[playerid], -16773172);
	PlayerTextDrawTextSize(playerid, TXTPlayerHealth[playerid], 605.000000, -80.000000);
	PlayerTextDrawSetSelectable(playerid, TXTPlayerHealth[playerid], 0);
	return 1;
}

IsPlayerAvail(playerid)
{
	if(IsPlayerConnected(playerid) && playerid != INVALID_PLAYER_ID && PlayerData[playerid][iExitType] == EXIT_FIRST_SPAWNED)
	{
	    return 1;
	}
	return 0;
}

/*
1. Do not map objects away from the mainland or the map gets bugged
2. Put the huge road object(180° for invisibility) around the map so players can't escape (if needed)
3. Always try to NOT place the map in the air or players may fall through it
4. Build 1 or more defense places where players can fight against zombies
5. Make the map challenging and interesting, nobody wants to play a boring map
6. Always try to keep the object count low < 500 OBJECTS! or players can't see the entire map at once
*/
