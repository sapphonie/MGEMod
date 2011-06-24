#pragma semicolon 1 // Force strict semicolon mode.

// ====[ INCLUDES ]====================================================
#include <sourcemod>
#include <tf2_stocks>
#include <entity_prop_stocks>
#include <sdkhooks>
#include <colors> 

// ====[ CONSTANTS ]===================================================
#define PL_VERSION "0.0.6-Beta1" 
#define MAX_FILE_LEN 80
#define MAXARENAS 15
#define MAXSPAWNS 15
#define HUDFADEOUTTIME 120.0
#define MAPCONFIGFILE "configs/mgemod_spawns.cfg"
#define STATSCONFIGFILE "configs/mgemod_stats.cfg"
#define SLOT_ONE 1 //arena slot 1
#define SLOT_TWO 2 //arena slot 2
//tf teams
#define TEAM_SPEC 1
#define TEAM_RED 2
#define TEAM_BLU 3
//arena status
#define AS_IDLE 0
#define AS_PRECOUNTDOWN 1
#define AS_COUNTDOWN 2
#define AS_FIGHT 3
#define AS_AFTERFIGHT 4
#define AS_REPORTED 5
//sounds
#define STOCK_SOUND_COUNT 7
//
#define DEFAULT_CDTIME 3
//
#define MODEL_BRIEFCASE "models/flag/briefcase.mdl"
#define MODEL_AMMOPACK "models/items/ammopack_small.mdl"

//stat tracking
#define MAXWEAPONS 31 // Max # of weapons to track stats for.


// ====[ VARIABLES ]===================================================
// Handle, String, Float, Bool, Int, TFCT
new bool:g_bNoStats;
new bool:g_bNoDisplayRating;

// HUD Handles
new Handle:hm_HP = INVALID_HANDLE,
Handle:hm_Airshot = INVALID_HANDLE,
Handle:hm_Score = INVALID_HANDLE,
Handle:hm_Accuracy = INVALID_HANDLE;

// Global Variables
new String:g_sMapName[64],
Float:g_fMeatshotPercent,
bool:g_bBlockFallDamage,
bool:g_bUseSQLite,
bool:g_bAutoCvar,
g_iDefaultFragLimit,
g_iAirshotHeight = 80;

// Database
new Handle:db = INVALID_HANDLE, // Connection to SQL database.
Handle:g_hDBReconnectTimer = INVALID_HANDLE,
String:g_sDBConfig[64],
g_iReconnectInterval;

// Global CVar Handles
new Handle:gcvar_WfP = INVALID_HANDLE,
Handle:gcvar_fragLimit = INVALID_HANDLE,
Handle:gcvar_allowedClasses = INVALID_HANDLE,
Handle:gcvar_blockFallDamage = INVALID_HANDLE,
Handle:gcvar_dbConfig = INVALID_HANDLE,
Handle:gcvar_midairHP = INVALID_HANDLE,
Handle:gcvar_airshotHeight = INVALID_HANDLE,
Handle:gcvar_RocketForceX = INVALID_HANDLE,
Handle:gcvar_RocketForceY = INVALID_HANDLE,
Handle:gcvar_RocketForceZ = INVALID_HANDLE,
Handle:gcvar_autoCvar = INVALID_HANDLE,
Handle:gcvar_bballParticle_red = INVALID_HANDLE,
Handle:gcvar_bballParticle_blue = INVALID_HANDLE,
Handle:gcvar_meatshotPercent = INVALID_HANDLE,
Handle:gcvar_noDisplayRating = INVALID_HANDLE,
Handle:gcvar_stats = INVALID_HANDLE,
Handle:gcvar_reconnectInterval = INVALID_HANDLE;

// Classes
new g_tfctClassAllowed[TFClassType]; // Special "TFClass_Type" data type.

// Arena Vars
new String:g_sArenaName[MAXARENAS+1][64],
Float:g_fArenaSpawnOrigin[MAXARENAS+1][MAXSPAWNS+1][3],
Float:g_fArenaSpawnAngles[MAXARENAS+1][MAXSPAWNS+1][3],
Float:g_fArenaHPRatio[MAXARENAS+1],
Float:g_fArenaMinSpawnDist[MAXARENAS+1],
Float:g_fArenaRespawnTime[MAXARENAS+1],
bool:g_bArenaAmmomod[MAXARENAS+1],
bool:g_bArenaMidair[MAXARENAS+1],
bool:g_bArenaMGE[MAXARENAS+1],
bool:g_bArenaEndif[MAXARENAS+1],
bool:g_bArenaBBall[MAXARENAS+1],
bool:g_bVisibleHoops[MAXARENAS+1],
bool:g_bArenaInfAmmo[MAXARENAS+1],
bool:g_bArenaShowHPToPlayers[MAXARENAS+1],
g_iArenaCount,
g_iArenaScore[MAXARENAS+1][3],
g_iArenaQueue[MAXARENAS+1][MAXPLAYERS+1],
g_iArenaStatus[MAXARENAS+1],
g_iArenaCd[MAXARENAS+1],//countdown to round start
g_iArenaFraglimit[MAXARENAS+1],
g_iArenaMinRating[MAXARENAS+1],
g_iArenaMaxRating[MAXARENAS+1],
g_iArenaCdTime[MAXARENAS+1],
g_iArenaSpawns[MAXARENAS+1],
g_iBBallHoop[MAXARENAS+1][3], // [What arena the hoop is in][Hoop 1 or Hoop 2]
g_iBBallIntel[MAXARENAS+1],
g_iArenaEarlyLeave[MAXARENAS+1],
g_tfctArenaAllowedClasses[MAXARENAS+1][TFClassType]; // Special "TFClass_Type" data type.

// Player vars
new Handle:g_hWelcomeTimer[MAXPLAYERS+1],
String:g_sPlayerSteamID[MAXPLAYERS+1][32],//saving steamid
bool:g_bPlayerTakenDirectHit[MAXPLAYERS+1],//player was hit directly
bool:g_bPlayerRestoringAmmo[MAXPLAYERS+1],//player is awaiting full ammo restore
bool:g_bPlayerHasIntel[MAXPLAYERS+1],
bool:g_bHitBlip[MAXPLAYERS+1],
bool:g_bShowHud[MAXPLAYERS+1] = true,
bool:g_bPlayerApplyQuickShot[MAXPLAYERS+1],
g_iPlayerAttackUsedWeaponIdx[MAXPLAYERS+1],
g_iPlayerArena[MAXPLAYERS+1],
g_iPlayerSlot[MAXPLAYERS+1],
g_iPlayerHP[MAXPLAYERS+1], //true HP of players
g_iPlayerSpecTarget[MAXPLAYERS+1],
g_iPlayerMaxHP[MAXPLAYERS+1],
g_iClientParticle[MAXPLAYERS+1],
g_iPlayerClip[MAXPLAYERS+1][3],
g_iPlayerWins[MAXPLAYERS+1],
g_iPlayerLosses[MAXPLAYERS+1],
g_iPlayerRating[MAXPLAYERS+1],
TFClassType:g_tfctPlayerClass[MAXPLAYERS+1];

// Bot things
new bool:g_bPlayerAskedForBot[MAXPLAYERS+1];

// Midair
new g_iMidairHP;

// Debug log
new String:g_sLogFile[PLATFORM_MAX_PATH];

// Endif
new Float:g_fRocketForceX,
Float:g_fRocketForceY,
Float:g_fRocketForceZ;

// Bball
new String:g_sBBallParticleRed[64],
String:g_sBBallParticleBlue[64];

// Stat tracking
new	String:g_sWeaponName[MAXWEAPONS+1][64],
bool:g_bWeaponProjectile[MAXWEAPONS+1],
g_iWeaponCount,
g_iWeaponMaxDmg[MAXWEAPONS+1],
g_iPlayerShotCount[MAXPLAYERS+1][MAXWEAPONS+1],
g_iPlayerHitCount[MAXPLAYERS+1][MAXWEAPONS+1],
g_iPlayerDamageDealt[MAXPLAYERS+1][MAXWEAPONS+1],
g_iPlayerDirectHitCount[MAXPLAYERS+1][MAXWEAPONS+1],
g_iPlayerAirshotCount[MAXPLAYERS+1][MAXWEAPONS+1],
g_iPreviousAmmo[MAXPLAYERS+1], // Ammo of player in the last gameframe
g_iPlayerWeapon[MAXPLAYERS+1], // Handle of the currently equipped weapon of a player
g_iPlayerWeaponIndex[MAXPLAYERS+1], // Index of the currently equipped weapon in TFWeapon_Track array. -1 if weapon is not tracked
g_iWeaponIdx[MAXWEAPONS+1] = -1;

static const String:stockSounds[][]= // Sounds that do not need to be downloaded, but should still be cached.
{ 						
	"buttons/button17.wav",
	"vo/intel_teamcaptured.wav",
	"vo/intel_teamdropped.wav",
	"vo/intel_teamstolen.wav",
	"vo/intel_enemycaptured.wav",
	"vo/intel_enemydropped.wav",
	"vo/intel_enemystolen.wav",
	"items/spawn_item.wav"
};

public Plugin:myinfo =
{
	name = "MGEMod",
	author = "Lange; based on kAmmomod by Krolus.",
	description = "Duel mod with realistic game situations.",
	version = PL_VERSION,
	url = "http://mygamingedge.com/, http://steamcommunity.com/id/langeh"
}

/*
** ------------------------------------------------------------------
**	   ____           ______                  __  _                  
**	  / __ \____     / ____/__  ______  _____/ /_(_)____  ____  _____
**	 / / / / __ \   / /_   / / / / __ \/ ___/ __/ // __ \/ __ \/ ___/
**	/ /_/ / / / /  / __/  / /_/ / / / / /__/ /_/ // /_/ / / / (__  ) 
**	\____/_/ /_/  /_/     \__,_/_/ /_/\___/\__/_/ \____/_/ /_/____/  
**
** ------------------------------------------------------------------
**/

/* OnPluginStart()
*
* When the plugin is loaded.
* Cvars, variables, and console commands are initialzed here.
* -------------------------------------------------------------------------- */
public OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mgemod.phrases");
	//ConVars
	CreateConVar("sm_mgemod_version", PL_VERSION, "MGEMod version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	gcvar_fragLimit = CreateConVar("mgemod_fraglimit", "3", "Default frag limit in duel", FCVAR_PLUGIN|FCVAR_NOTIFY,true, 1.0);
	gcvar_allowedClasses = CreateConVar("mgemod_allowed_classes", "soldier demoman scout", "Classes that players allowed to choose by default", FCVAR_PLUGIN|FCVAR_NOTIFY);
	gcvar_blockFallDamage = CreateConVar("mgemod_blockdmg_fall", "0", "Block falldamage? (0 = Disabled)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gcvar_dbConfig = CreateConVar("mgemod_dbconfig", "mgemod", "Name of database config", FCVAR_PLUGIN|FCVAR_NOTIFY);
	gcvar_stats = CreateConVar("mgemod_players", "1", "Enable/Disable stats.", FCVAR_PLUGIN|FCVAR_NOTIFY);
	gcvar_airshotHeight = CreateConVar("mgemod_airshot_height", "80", "The minimum height at which a shot will count as an airshot", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 10.0, true, 500.0);
	gcvar_RocketForceX = CreateConVar("mgemod_endif_force_x", "1.1", "The amount by which to multiply the X push force on Endif.", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 1.0, true, 10.0);
	gcvar_RocketForceY = CreateConVar("mgemod_endif_force_y", "1.1", "The amount by which to multiply the Y push force on Endif.", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 1.0, true, 10.0);
	gcvar_RocketForceZ = CreateConVar("mgemod_endif_force_z", "2.15", "The amount by which to multiply the Z push force on Endif.", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 1.0, true, 10.0);
	gcvar_autoCvar = CreateConVar("mgemod_autocvar", "1", "Automatically set reccomended game cvars? (0 = Disabled)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gcvar_bballParticle_red = CreateConVar("mgemod_bball_particle_red", "player_intel_trail_red", "Particle effect to attach to Red players in BBall.", FCVAR_PLUGIN|FCVAR_NOTIFY);
	gcvar_bballParticle_blue = CreateConVar("mgemod_bball_particle_blue", "player_intel_trail_blue", "Particle effect to attach to Blue players in BBall.", FCVAR_PLUGIN|FCVAR_NOTIFY);
	gcvar_WfP = FindConVar("mp_waitingforplayers_cancel");
	gcvar_midairHP = CreateConVar("mgemod_midair_hp", "5", "Default health multiplication for midair arenas.", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 1.0);
	gcvar_meatshotPercent = CreateConVar("mgemod_meatshot_percent", "0.9", "Percent of a weapon's max damage must that be achieved to count as a meatshot.", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.1, true, 1.0);
	gcvar_noDisplayRating = CreateConVar("mgemod_hide_rating", "0", "Hide the in-game display of rating points. They will still be tracked in the database.", FCVAR_PLUGIN|FCVAR_NOTIFY);
	gcvar_reconnectInterval = CreateConVar("mgemod_reconnect_interval", "5", "How long (in minutes) to wait between database reconnection attempts.", FCVAR_PLUGIN|FCVAR_NOTIFY);
	
	// Populate global variables with their corresponding convar values.
	g_iDefaultFragLimit = GetConVarInt(gcvar_fragLimit);
	g_bBlockFallDamage = GetConVarInt(gcvar_blockFallDamage) ? true : false;
	GetConVarString(gcvar_dbConfig,g_sDBConfig,sizeof(g_sDBConfig));
	g_bNoStats = (GetConVarBool(gcvar_stats)) ? false : true;
	g_iAirshotHeight = GetConVarInt(gcvar_airshotHeight);
	g_iMidairHP = GetConVarInt(gcvar_midairHP);
	g_fRocketForceX = GetConVarFloat(gcvar_RocketForceX);
	g_fRocketForceY = GetConVarFloat(gcvar_RocketForceY);
	g_fRocketForceZ = GetConVarFloat(gcvar_RocketForceZ);
	g_bAutoCvar = GetConVarInt(gcvar_autoCvar) ? true : false;
	g_fMeatshotPercent = GetConVarFloat(gcvar_meatshotPercent);
	GetConVarString(gcvar_bballParticle_red, g_sBBallParticleRed, sizeof(g_sBBallParticleRed));
	GetConVarString(gcvar_bballParticle_blue, g_sBBallParticleBlue, sizeof(g_sBBallParticleBlue));
	g_bNoDisplayRating = GetConVarInt(gcvar_noDisplayRating) ? true : false;
	g_iReconnectInterval = GetConVarInt(gcvar_reconnectInterval);
	
	// Parse default list of allowed classes.
	ParseAllowedClasses("",g_tfctClassAllowed);
	
	// Only connect to the SQL DB if stats are enabled.
	if(!g_bNoStats)
		PrepareSQL();
	
	// Hook convar changes.
	HookConVarChange(gcvar_fragLimit, handler_ConVarChange);
	HookConVarChange(gcvar_allowedClasses, handler_ConVarChange);
	HookConVarChange(gcvar_blockFallDamage, handler_ConVarChange);
	HookConVarChange(gcvar_airshotHeight, handler_ConVarChange);
	HookConVarChange(gcvar_midairHP, handler_ConVarChange);
	HookConVarChange(gcvar_RocketForceX, handler_ConVarChange);
	HookConVarChange(gcvar_RocketForceY, handler_ConVarChange);
	HookConVarChange(gcvar_RocketForceZ, handler_ConVarChange);
	HookConVarChange(gcvar_autoCvar, handler_ConVarChange);
	HookConVarChange(gcvar_meatshotPercent, handler_ConVarChange);
	HookConVarChange(gcvar_noDisplayRating, handler_ConVarChange);
	HookConVarChange(gcvar_stats, handler_ConVarChange);
	HookConVarChange(gcvar_reconnectInterval, handler_ConVarChange);
	
	// Create/register client commands.
	RegConsoleCmd("mgemod", Command_Menu, "MGEMod Menu");
	RegConsoleCmd("add", Command_Menu, "Usage: add <arena number/arena name>. Add to an arena.");
	RegConsoleCmd("remove", Command_Remove, "Remove from current arena.");
	RegConsoleCmd("top5", Command_Top5, "Display the Top 5 players.");
	RegConsoleCmd("hitblip", Command_ToogleHitblip, "Toggle hitblip.");
	RegConsoleCmd("hud", Command_ToggleHud, "Toggle text hud.");
	RegConsoleCmd("hidehud", Command_ToggleHud, "Toggle text hud. (alias)");
	RegConsoleCmd("rank", Command_Rank, "Usage: rank <player name>. Show that player's rank.");
	RegConsoleCmd("stats", Command_Rank, "Alias for \"rank\".");
	RegConsoleCmd("mgehelp", Command_Help);
	RegConsoleCmd("first", Command_First, "Join the first available arena.");
	RegConsoleCmd("spec_next", Command_Spec);
	RegConsoleCmd("spec_prev", Command_Spec);
	RegConsoleCmd("joinclass", Command_JoinClass);
	RegAdminCmd("loc", Command_Loc, ADMFLAG_BAN, "Shows client origin and angle vectors");
	RegAdminCmd("tryme", Command_AddBot, ADMFLAG_BAN, "Add bot to your arena");
	RegAdminCmd("botme", Command_AddBot, ADMFLAG_BAN, "Add bot to your arena (alias)");
	RegAdminCmd("conntest", Command_ConnectionTest, ADMFLAG_BAN, "Connection test.");
	
	// Create the HUD text handles for later use.
	hm_Airshot = CreateHudSynchronizer();
	hm_HP = CreateHudSynchronizer();
	hm_Score = CreateHudSynchronizer();
	hm_Accuracy = CreateHudSynchronizer();
	
	// Set up the log file for debug logging.
	BuildPath(Path_SM, g_sLogFile, sizeof(g_sLogFile), "logs/mgemod.log");
	
	/*	This is here in the event of the plugin being hot-loaded while players are in the server.
	Should probably delete this, as the rest of the code doesn't really support hot-loading. */
	if(!g_bNoStats)
	{ 
		for (new i=1;i<=MaxClients;i++)
		{
			if(IsValidClient(i))
			{
				g_bHitBlip[i] = false;
				decl String:steamid_dirty[31], String:steamid[64], String:query[256];
				GetClientAuthString(i, steamid_dirty, sizeof(steamid_dirty));
				SQL_EscapeString(db, steamid_dirty, steamid, sizeof(steamid));
				strcopy(g_sPlayerSteamID[i],32,steamid);
				Format(query, sizeof(query), "SELECT rating, wins, losses, hitblip, hud FROM mgemod_players WHERE steamid='%s' LIMIT 1", steamid);
				SQL_TQuery(db, T_SQLQueryOnConnect, query, i);
				OnClientPostAdminCheck(i);
			}
		}
	}
}

/* OnGetGameDescription(String:gameDesc[64])
*
* Used to change the game description from
* "Team Fortress 2" to "MGEMod vx.x.x"
* -------------------------------------------------------------------------- */
public Action:OnGetGameDescription(String:gameDesc[64])
{
	Format(gameDesc, sizeof(gameDesc), "MGEMod v%s",PL_VERSION);
	return Plugin_Changed;
}

/* OnMapStart()
*
* When the map starts.
* Sounds, models, and spawns are loaded here.
* Most events are hooked here as well.
* -------------------------------------------------------------------------- */
public OnMapStart()
{	
	for (new i=0;i<=STOCK_SOUND_COUNT;i++) /* Stock sounds are considered mandatory. */
		PrecacheSound(stockSounds[i], true);
	
	// Models. These are used for the artifical flag in BBall.
	PrecacheModel(MODEL_BRIEFCASE, true);
	PrecacheModel(MODEL_AMMOPACK, true);
	
	g_bNoStats = (GetConVarBool(gcvar_stats)) ? false : true; /* Reset this variable, since it is forced to false during Event_WinPanel */
	
	// Spawns
	new isMapAm = LoadSpawnPoints();
	if(isMapAm)
	{
		for (new i = 0;i<=g_iArenaCount;i++)
		{
			if(g_bArenaBBall[i])
			{
				g_iBBallHoop[i][SLOT_ONE] = -1;
				g_iBBallHoop[i][SLOT_TWO] = -1;
				g_iBBallIntel[i] = -1;
			}
		}
		
		CreateTimer(1.0, Timer_SpecHudToAllArenas, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		
		if(g_bAutoCvar)
		{
			/*	MGEMod often creates situtations where the number of players on RED and BLU will be uneven.
			If the server tries to force a player to a different team due to autobalance being on, it will interfere with MGEMod's queue system.
			These cvar settings are considered mandatory for MGEMod. */
			ServerCommand("mp_autoteambalance 0");
			ServerCommand("mp_teams_unbalance_limit 32");
			ServerCommand("mp_tournament 0");
			LogMessage("AutoCvar: Setting mp_autoteambalance 0, mp_teams_unbalance_limit 32, & mp_tournament 0");
		}
		
		HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
		HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Post);
		HookEvent("player_hurt", Event_PlayerHurt, EventHookMode_Pre);
		HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);
		HookEvent("teamplay_round_start", Event_RoundStart, EventHookMode_Post);
		HookEvent("teamplay_win_panel", Event_WinPanel, EventHookMode_Post);
		
		AddNormalSoundHook(sound_hook);
		
		if(!g_bNoStats)
		{
			new useStats = LoadStatsCfg();
			if(!useStats)
				g_bNoStats = true;
		}
	} else {
		SetFailState("Map not supported. MGEMod disabled.");
	}
}

/* OnMapEnd()
*
* When the map ends.
* Repeating timers can be killed here.
* -------------------------------------------------------------------------- */
public OnMapEnd()
{
	g_hDBReconnectTimer = INVALID_HANDLE;
	g_bNoStats = (GetConVarBool(gcvar_stats)) ? false : true;
}

/* OnEntityCreated(entity, const String:classname[])
*
* When an entity is created.
* This is an SDKHooks forward.
* -------------------------------------------------------------------------- */
public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname,"tf_projectile_rocket") || StrEqual(classname,"tf_projectile_pipe"))
		SDKHook(entity, SDKHook_Touch, OnProjectileTouch);
}

/* OnProjectileTouch(entity, other)
*
* When a projectile is touched.
* This is how direct hits from pipes are rockets are detected.
* -------------------------------------------------------------------------- */
public OnProjectileTouch(entity, other)
{
	if(other>0 && other<=MaxClients)
		g_bPlayerTakenDirectHit[other] = true;
}

/* OnClientPostAdminCheck(client)
*
* Called once a client is authorized and fully in-game.
* Client-specific variables are initialized here.
* -------------------------------------------------------------------------- */
public OnClientPostAdminCheck(client)
{
	if (client)
	{
		if (IsFakeClient(client))
		{
			for (new i=1;i<=MaxClients;i++)
			{
				if (g_bPlayerAskedForBot[i])
				{
					new arena_index = g_iPlayerArena[i];		
					new Handle:pk;
					CreateDataTimer(1.5,Timer_AddBotInQueue,pk);
					WritePackCell(pk, GetClientUserId(client));
					WritePackCell(pk, arena_index);
					g_iPlayerRating[client] = 1551;
					g_bPlayerAskedForBot[i] = false;
					break;
				}
			}
		} else {
			CreateTimer(5.0, Timer_ShowAdv, GetClientUserId(client)); /* Show advice to type !add in chat */
			g_bHitBlip[client] = false;
			g_bShowHud[client] = true;
			g_bPlayerRestoringAmmo[client] = false;
			g_hWelcomeTimer[client] = CreateTimer(15.0, Timer_WelcomePlayer, GetClientUserId(client));
			
			if (!g_bNoStats)
			{
				decl String:steamid_dirty[31], String:steamid[64], String:query[256];
				GetClientAuthString(client, steamid_dirty, sizeof(steamid_dirty));
				SQL_EscapeString(db, steamid_dirty, steamid, sizeof(steamid));
				strcopy(g_sPlayerSteamID[client],32,steamid);
				Format(query, sizeof(query), "SELECT rating, wins, losses, hitblip, hud FROM mgemod_players WHERE steamid='%s' LIMIT 1", steamid);
				SQL_TQuery(db, T_SQLQueryOnConnect, query, client);
			}
		}
	}
	
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

/* OnClientDisconnect(client)
*
* When a client disconnects from the server.
* Client-specific timers are killed here.
* -------------------------------------------------------------------------- */
public OnClientDisconnect(client)
{
	if (IsValidClient(client) && g_iPlayerArena[client])
	{
		RemoveFromQueue(client,true);
	} else {
		new arena_index = g_iPlayerArena[client],
			player_slot = g_iPlayerSlot[client],
			after_leaver_slot = player_slot + 1,
			foe_slot = player_slot==SLOT_ONE ? SLOT_TWO : SLOT_ONE,
			foe = g_iArenaQueue[arena_index][foe_slot];
		if (g_iArenaQueue[arena_index][SLOT_TWO+1])
		{
			new next_client = g_iArenaQueue[arena_index][SLOT_TWO+1];
			g_iArenaQueue[arena_index][SLOT_TWO+1] = 0;
			g_iArenaQueue[arena_index][player_slot] = next_client;
			g_iPlayerSlot[next_client] = player_slot;
			after_leaver_slot = SLOT_TWO + 2;
			new String:playername[MAX_NAME_LENGTH];
			CreateTimer(2.0,Timer_StartDuel,arena_index);
			GetClientName(next_client,playername,sizeof(playername));
			
			if (!g_bNoStats && !g_bNoDisplayRating)
				CPrintToChatAll("%t","JoinsArena",playername,g_iPlayerRating[next_client],g_sArenaName[arena_index]);
			else
			CPrintToChatAll("%t","JoinsArenaNoStats",playername,g_sArenaName[arena_index]);
			
			
		} else {
			if (foe && IsFakeClient(foe))
			{
				new Handle:cvar = FindConVar("tf_bot_quota");
				new quota = GetConVarInt(cvar);
				ServerCommand("tf_bot_quota %d", quota - 1);
			}
			
			g_iArenaStatus[arena_index] = AS_IDLE;
			return;
		}
		
		if (g_iArenaQueue[arena_index][after_leaver_slot])
		{
			while (g_iArenaQueue[arena_index][after_leaver_slot])
			{
				g_iArenaQueue[arena_index][after_leaver_slot-1] = g_iArenaQueue[arena_index][after_leaver_slot];
				g_iPlayerSlot[g_iArenaQueue[arena_index][after_leaver_slot]] -= 1;
				after_leaver_slot++;
			}
			g_iArenaQueue[arena_index][after_leaver_slot-1] = 0;
		}
	}
	
	if (g_hWelcomeTimer[client] != INVALID_HANDLE)
	{
		KillTimer(g_hWelcomeTimer[client]);
		g_hWelcomeTimer[client] = INVALID_HANDLE;
	}
}

/* OnGameFrame()
*
* This code is run on every frame. Can be very hardware intensive.
* -------------------------------------------------------------------------- */
public OnGameFrame()
{
	new arena_index;
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client) && IsPlayerAlive(client))
		{	
			arena_index = g_iPlayerArena[client];
			if(!g_bArenaBBall[arena_index] && !g_bArenaMGE[arena_index])
			{
				/*	This is a hack that prevents people from getting one-shot by things
				like the direct hit in the Ammomod arenas. */
				new replacement_hp = (g_iPlayerMaxHP[client] + 512);
				SetEntProp(client, Prop_Send, "m_iHealth", replacement_hp, 1);
			}
			
			DetectShot(client);
		}
	}
}

/* OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
*
* When a client takes damage.
* -------------------------------------------------------------------------- */
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(victim) || !IsValidClient(attacker))
		return Plugin_Continue;
	
	// Fall damage negation.
	if ((damagetype & DMG_FALL) && g_bBlockFallDamage)
	{
		damage = 0.0;
		return Plugin_Changed;
	}
	
	// Sloppy work-around for determining which weapon to add stats for during an attack.
	g_iPlayerAttackUsedWeaponIdx[attacker] = -1;
	decl String:classname[64];
	GetEdictClassname(inflictor, classname, sizeof(classname));
	if (attacker > 0 && victim != attacker) /* If the attacker wasn't the person being hurt, or the world (fall damage). */
	{
		if(IsValidEntity(inflictor))
		{
			if(StrEqual(classname,"tf_projectile_pipe_remote"))		/* Projectile belonged to a secondary weapon slot. */
				g_iPlayerAttackUsedWeaponIdx[attacker] = GetWeaponIndex(GetPlayerWeaponSlot(attacker, 1));
			else if(StrEqual(classname,"tf_projectile_stun_ball"))	/* Projectile belonged to a melee weapon slot. */
				g_iPlayerAttackUsedWeaponIdx[attacker] = GetWeaponIndex(GetPlayerWeaponSlot(attacker, 2));
			else if(StrContains(classname,"tf_projectile_") == 0)	/* Projectile belonged to a primary weapon slot. */
				g_iPlayerAttackUsedWeaponIdx[attacker] = GetWeaponIndex(GetPlayerWeaponSlot(attacker, 0));
			else													/* Wasn't a projectile weapon. */
				g_iPlayerAttackUsedWeaponIdx[attacker] = g_iPlayerWeaponIndex[attacker];
		}
	}
	
	return Plugin_Continue;
}

/* OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
*
* When a client runs a command.
* Infinite ammo is triggered here.
* -------------------------------------------------------------------------- */
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{ 
	new arena_index = g_iPlayerArena[client];
	if(g_bArenaInfAmmo[arena_index])
	{
		if (!g_bPlayerRestoringAmmo[client] && (buttons & IN_ATTACK))
		{
			g_bPlayerRestoringAmmo[client] = true;
			CreateTimer(0.4,Timer_GiveAmmo,GetClientUserId(client));
		}
	}
}

/* OnTouchHoop(entity, other)
*
* When a hoop is touched by a player in BBall.
* -------------------------------------------------------------------------- */
public Action:OnTouchHoop(entity, other)
{
	new client = other;
	
	if(!IsValidClient(client))
		return;
	
	new arena_index = g_iPlayerArena[client];
	new fraglimit = g_iArenaFraglimit[arena_index];
	new client_slot = g_iPlayerSlot[client];
	new foe_slot = (client_slot==SLOT_ONE) ? SLOT_TWO : SLOT_ONE;
	new foe = g_iArenaQueue[arena_index][foe_slot];
	
	if(!IsValidClient(foe) || !g_bArenaBBall[arena_index])
		return;
	
	if(entity == g_iBBallHoop[arena_index][foe_slot] && g_bPlayerHasIntel[client])
	{
		// Remove the particle effect attached to the player carrying the intel.
		RemoveClientParticle(client);
		
		new String:foe_name[MAX_NAME_LENGTH];
		GetClientName(foe, foe_name, sizeof(foe_name));
		new String:client_name[MAX_NAME_LENGTH];
		GetClientName(client, client_name, sizeof(client_name));
		
		CPrintToChat(client, "%t", "bballdunk", foe_name);
		
		g_bPlayerHasIntel[client] = false;
		g_iArenaScore[arena_index][client_slot] += 1;
		
		if (fraglimit>0 && g_iArenaScore[arena_index][client_slot] >= fraglimit && g_iArenaStatus[arena_index] >= AS_FIGHT && g_iArenaStatus[arena_index] < AS_REPORTED)
		{
			g_iArenaStatus[arena_index] = AS_REPORTED;
			GetClientName(client,client_name, sizeof(client_name));
			CPrintToChatAll("%t","XdefeatsY", client_name, g_iArenaScore[arena_index][client_slot], foe_name, g_iArenaScore[arena_index][foe_slot], fraglimit, g_sArenaName[arena_index]);
			
			if (!g_bNoStats)
				CalcELO(client,foe);
			
			if(IsValidEdict(g_iBBallIntel[arena_index]) && g_iBBallIntel[arena_index] > -1)
			{
				SDKUnhook(g_iBBallIntel[arena_index], SDKHook_StartTouch, OnTouchIntel);
				RemoveEdict(g_iBBallIntel[arena_index]);
				g_iBBallIntel[arena_index] = -1;
			}
			
			if (g_iArenaQueue[arena_index][SLOT_TWO+1])
			{
				RemoveFromQueue(foe,false);
				AddInQueue(foe,arena_index,false);
			} else {
				CreateTimer(3.0,Timer_StartDuel,arena_index);
			}
		} else {
			ResetPlayer(client);
			ResetPlayer(foe);
			CreateTimer(0.15, Timer_ResetIntel, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		ShowPlayerHud(client); 
		ShowPlayerHud(foe);
		EmitSoundToClient(client, "vo/intel_teamcaptured.wav");
		EmitSoundToClient(foe, "vo/intel_enemycaptured.wav");
		ShowSpecHudToArena(arena_index);
	}
}

/* OnTouchIntel(entity, other)
*
* When the intel is touched by a player in BBall.
* -------------------------------------------------------------------------- */
public Action:OnTouchIntel(entity, other)
{
	new client = other;
	
	if(!IsValidClient(client))
		return;
	
	new arena_index = g_iPlayerArena[client];
	g_bPlayerHasIntel[client] = true;
	new String:msg[64];
	Format(msg,sizeof(msg),"You have the intel!");
	PrintCenterText(client,msg);
	
	if(entity == g_iBBallIntel[arena_index] && IsValidEdict(g_iBBallIntel[arena_index]) && g_iBBallIntel[arena_index] > 0)
	{
		SDKUnhook(g_iBBallIntel[arena_index], SDKHook_StartTouch, OnTouchIntel);
		RemoveEdict(g_iBBallIntel[arena_index]);
		g_iBBallIntel[arena_index] = -1;
	}
	
	new particle;
	new TFTeam:team = TFTeam:GetEntProp(client, Prop_Send, "m_iTeamNum");
	
	// Create a fancy lightning effect to make it abundantly clear that the intel has just been picked up.
	if (team==TFTeam_Red)
		AttachParticle(client,"teleported_red",particle);
	else
		AttachParticle(client,"teleported_blue",particle);
	
	// Attach a team-colored particle to give a visual cue that a player is holding the intel, since we can't attach models.
	particle = EntRefToEntIndex(g_iClientParticle[client]);
	if (particle==0 || !IsValidEntity(particle))	
	{
		if (team==TFTeam_Red)
			AttachParticle(client,g_sBBallParticleRed,particle);
		else
			AttachParticle(client,g_sBBallParticleBlue,particle);
		
		g_iClientParticle[client] = EntIndexToEntRef(particle);
	}
	
	ShowPlayerHud(client);
	EmitSoundToClient(client, "vo/intel_teamstolen.wav", _, _, _, _, 1.0);
	
	new foe = g_iArenaQueue[g_iPlayerArena[client]][g_iPlayerSlot[client]==SLOT_ONE ? SLOT_TWO : SLOT_ONE];
	if(IsValidClient(foe))
	{
		EmitSoundToClient(foe, "vo/intel_enemystolen.wav");
		ShowPlayerHud(foe);
	}
}

/*
** -------------------------------------------------------------------------------
**	    ____       _              ______                  __  _                  
**	   / __ \_____(_)_   __      / ____/__  ______  _____/ /_(_)____  ____  _____
**	  / /_/ / ___/ /| | / /     / /_   / / / / __ \/ ___/ __/ // __ \/ __ \/ ___/
**	 / ____/ /  / / | |/ /_    / __/  / /_/ / / / / /__/ /_/ // /_/ / / / (__  ) 
**	/_/   /_/  /_/  |___/(_)  /_/     \__,_/_/ /_/\___/\__/_/ \____/_/ /_/____/  
**	
** -------------------------------------------------------------------------------
**/

StartCountDown(arena_index)
{
	new red_f1 = g_iArenaQueue[arena_index][SLOT_ONE]; /* Red (slot one) player. */
	new blu_f1 = g_iArenaQueue[arena_index][SLOT_TWO]; /* Blu (slot two) player. */
	
	if(red_f1)
		ResetPlayer(red_f1);
	if(blu_f1)
		ResetPlayer(blu_f1);
	
	if (red_f1 && blu_f1)
	{
		ResetAccuracyStats(g_iArenaQueue[arena_index][SLOT_ONE]);
		ResetAccuracyStats(g_iArenaQueue[arena_index][SLOT_TWO]);
		
		new Float:enginetime = GetGameTime();
		
		for (new i=0;i<=2;i++)
		{
			new ent = GetPlayerWeaponSlot(red_f1, i);
			
			if(IsValidEntity(ent))
				SetEntPropFloat(ent, Prop_Send, "m_flNextPrimaryAttack", enginetime+1.1);
			
			ent = GetPlayerWeaponSlot(blu_f1, i);
			
			if(IsValidEntity(ent))
				SetEntPropFloat(ent, Prop_Send, "m_flNextPrimaryAttack", enginetime+1.1);
		}
		
		g_iArenaCd[arena_index] = g_iArenaCdTime[arena_index] + 1;
		g_iArenaStatus[arena_index] = AS_PRECOUNTDOWN;
		CreateTimer(0.0,Timer_CountDown,arena_index,TIMER_FLAG_NO_MAPCHANGE);
		return 1;
	} else {
		g_iArenaStatus[arena_index] = AS_IDLE;
		return 0;
	}
}

// ====[ HUD ]====================================================
ShowSpecHudToArena(arena_index)
{
	if (!arena_index)
		return;
	
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsValidClient(i) && GetClientTeam(i)==TEAM_SPEC && g_iPlayerSpecTarget[i]>0 && g_iPlayerArena[g_iPlayerSpecTarget[i]]==arena_index)
			ShowSpecHudToClient(i);
	}
}

ShowCountdownToSpec(arena_index,String:text[])
{
	if (!arena_index)
		return;
	
	for (new i=1;i<=MaxClients;i++)
	{
		if (IsValidClient(i) && GetClientTeam(i)==TEAM_SPEC && g_iPlayerArena[g_iPlayerSpecTarget[i]]==arena_index)
			PrintCenterText(i,text);
	}
}

ShowPlayerHud(client)
{
	if (!IsValidClient(client)) 
		return;
	
	// Clear the spectator accuracy stats.
	ShowSyncHudText(client, hm_Accuracy, "");
	SetHudTextParams(0.01, 0.80, HUDFADEOUTTIME, 255,255,255,255);
	
	// HP
	new arena_index = g_iPlayerArena[client];
	new client_foe = g_iArenaQueue[g_iPlayerArena[client]][g_iPlayerSlot[client]==SLOT_ONE ? SLOT_TWO : SLOT_ONE]; //test
	
	if(g_bArenaShowHPToPlayers[arena_index])
	{
		new Float:hp_ratio = ((float(g_iPlayerHP[client])) / (float(g_iPlayerMaxHP[client])*g_fArenaHPRatio[arena_index]));
		if(hp_ratio > 0.66)
			SetHudTextParams(0.01, 0.80, HUDFADEOUTTIME, 0,255,0,255); // Green
		else if(hp_ratio >= 0.33)
			SetHudTextParams(0.01, 0.80, HUDFADEOUTTIME, 255,255,0,255); // Yellow
		else if(hp_ratio < 0.33)
			SetHudTextParams(0.01, 0.80, HUDFADEOUTTIME, 255,0,0,255); // Red
		
		ShowSyncHudText(client, hm_HP, "Health : %d", g_iPlayerHP[client]);
	} else {
		ShowSyncHudText(client, hm_HP, "", g_iPlayerHP[client]);
	}
	
	// We want ammomod players to be able to see what their health is, even when they have the text hud turned off. 
	if(!g_bShowHud[client])
		return;
	
	if(g_bArenaBBall[arena_index])
	{
		if(g_iArenaStatus[arena_index] == AS_FIGHT)
		{
			if(g_bPlayerHasIntel[client])
				ShowSyncHudText(client, hm_HP, "You have the intel!", g_iPlayerHP[client]);
			else if(g_bPlayerHasIntel[client_foe])
				ShowSyncHudText(client, hm_HP, "Enemy has the intel!", g_iPlayerHP[client]);
			else
			ShowSyncHudText(client, hm_HP, "Get the intel!", g_iPlayerHP[client]);
		} else {
			ShowSyncHudText(client, hm_HP, "", g_iPlayerHP[client]);
		}
	}
	
	// Score
	SetHudTextParams(0.01, 0.01, HUDFADEOUTTIME, 255,255,255,255);
	new String:report[128];
	new fraglimit = g_iArenaFraglimit[arena_index];
	
	if(g_bArenaBBall[arena_index])
	{
		if (fraglimit>0)
			Format(report,sizeof(report),"Arena %s. Capture Limit(%d)",g_sArenaName[arena_index],fraglimit);
		else
		Format(report,sizeof(report),"Arena %s. No Capture Limit",g_sArenaName[arena_index]);
	} else {
		if (fraglimit>0)
			Format(report,sizeof(report),"Arena %s. Frag Limit(%d)",g_sArenaName[arena_index],fraglimit);
		else
		Format(report,sizeof(report),"Arena %s. No Frag Limit",g_sArenaName[arena_index]);
	}
	
	new red_f1 = g_iArenaQueue[arena_index][SLOT_ONE];
	new blu_f1 = g_iArenaQueue[arena_index][SLOT_TWO];
	
	if (red_f1)
	{
		if (g_bNoStats || g_bNoDisplayRating)
			Format(report,sizeof(report),"%s\n%N : %d",report,red_f1,g_iArenaScore[arena_index][SLOT_ONE]);
		else
		Format(report,sizeof(report),"%s\n%N (%d) : %d",report,red_f1,g_iPlayerRating[red_f1],g_iArenaScore[arena_index][SLOT_ONE]);
	}
	
	if (blu_f1)
	{
		if (g_bNoStats || g_bNoDisplayRating)
			Format(report,sizeof(report),"%s\n%N : %d",report,blu_f1,g_iArenaScore[arena_index][SLOT_TWO]);
		else
		Format(report,sizeof(report),"%s\n%N (%d) : %d",report,blu_f1,g_iPlayerRating[blu_f1],g_iArenaScore[arena_index][SLOT_TWO]);
	}
	
	ShowSyncHudText(client, hm_Score, "%s",report);
}

ShowSpecHudToClient(client)
{
	if (!IsValidClient(client) || !IsValidClient(g_iPlayerSpecTarget[client]) || !g_bShowHud[client]) 
		return;
	
	new arena_index = g_iPlayerArena[g_iPlayerSpecTarget[client]];
	new red_f1 = g_iArenaQueue[arena_index][SLOT_ONE];
	new blu_f1 = g_iArenaQueue[arena_index][SLOT_TWO];
	new String:hp_report[128];
	
	if (red_f1)
		Format(hp_report,sizeof(hp_report),"%N : %d", red_f1,g_iPlayerHP[red_f1]);
	
	if (blu_f1)
		Format(hp_report,sizeof(hp_report),"%s\n%N : %d",hp_report,blu_f1, g_iPlayerHP[blu_f1]);
	
	SetHudTextParams(0.01, 0.80, HUDFADEOUTTIME, 255,255,255,255);
	ShowSyncHudText(client, hm_HP, hp_report);
	
	// Accuracy
	new String:report[128];
	new target = g_iPlayerSpecTarget[client];
	
	if(IsValidClient(target))
	{
		new pri_weap = GetPlayerWeaponSlot(target, 0);
		new sec_weap = GetPlayerWeaponSlot(target, 1);
		new pri_acc;
		new sec_acc;
		
		// Primary
		if(IsValidEntity(pri_weap))
		{
			pri_weap = GetWeaponIndex(pri_weap);
			if(pri_weap != -1 && g_iPlayerShotCount[target][pri_weap] > 0)
				pri_acc = RoundToNearest((float(g_iPlayerHitCount[target][pri_weap])/float(g_iPlayerShotCount[target][pri_weap]))*100.0);
		}
		
		// Secondary
		if(IsValidEntity(sec_weap))
		{
			sec_weap = GetWeaponIndex(sec_weap);
			if(sec_weap != -1 && g_iPlayerShotCount[target][sec_weap] > 0)
				sec_acc = RoundToNearest((float(g_iPlayerHitCount[target][sec_weap])/float(g_iPlayerShotCount[target][sec_weap]))*100.0);
		}	
		
		if(pri_weap && sec_weap)
			Format(report,sizeof(report),"%N's Acc.\nPri: \t%i%s\nSec:\t%i%%", target, pri_acc, "%%", sec_acc);
		else if(pri_weap)
			Format(report,sizeof(report),"%N's Acc.\nPri: \t%i%s\nSec:\tN\\A", target, pri_acc, "%%");
		else if(sec_weap)
			Format(report,sizeof(report),"%N's Acc.\nPri: \tN\\A\nSec:\t%i%%", target, sec_acc);
		else
		Format(report,sizeof(report),"%N's Acc.\nPri: \tN\\A\nSec:\tN\\A", target);
		
		SetHudTextParams(0.01, 0.17, HUDFADEOUTTIME, 255,255,255,255);
		ShowSyncHudText(client, hm_Accuracy, report);
	}
	
	// Score
	SetHudTextParams(0.01, 0.01, HUDFADEOUTTIME, 255,255,255,255);
	
	new fraglimit = g_iArenaFraglimit[arena_index];
	
	if (g_iArenaStatus[arena_index] != AS_IDLE)
	{
		if (fraglimit>0)
			Format(report,sizeof(report),"Arena %s. Frag Limit(%d)",g_sArenaName[arena_index],fraglimit);
		else
		Format(report,sizeof(report),"Arena %s. No Frag Limit",g_sArenaName[arena_index]);
	} else
	Format(report,sizeof(report),"Arena[%s]",g_sArenaName[arena_index]);
	
	if (red_f1)
		if (g_bNoStats || g_bNoDisplayRating)
			Format(report,sizeof(report),"%s\n%N : %d",report,red_f1,g_iArenaScore[arena_index][SLOT_ONE]);
		else
	Format(report,sizeof(report),"%s\n%N (%d): %d",report,red_f1,g_iPlayerRating[red_f1],g_iArenaScore[arena_index][SLOT_ONE]);
	
	if (g_iArenaQueue[arena_index][SLOT_TWO])
	{
		if (g_bNoStats || g_bNoDisplayRating)
			Format(report,sizeof(report),"%s\n%N : %d",report,blu_f1,g_iArenaScore[arena_index][SLOT_TWO]);
		else
		Format(report,sizeof(report),"%s\n%N (%d): %d",report,blu_f1,g_iPlayerRating[blu_f1],g_iArenaScore[arena_index][SLOT_TWO]);
	}
	
	ShowSyncHudText(client, hm_Score, "%s",report);
}

ShowHudToAll()
{
	for(new i = 1; i <= g_iArenaCount; i++)
		ShowSpecHudToArena(i);
	
	for(new i = 1; i <= MAXPLAYERS; i++)
	{
		if(g_iPlayerArena[i])
			ShowPlayerHud(i);
	}	
}

HideHud(client)
{
	if (!IsValidClient(client))
		return;
	
	ClearSyncHud(client,hm_Score);
	ClearSyncHud(client,hm_HP);
	ClearSyncHud(client,hm_Airshot);
	ClearSyncHud(client,hm_Accuracy);
}

// ====[ QUEUE ]====================================================
RemoveFromQueue(client, bool:calcstats=false, bool:specfix=false)
{
	new arena_index = g_iPlayerArena[client];
	
	if (arena_index == 0)
		return;
	
	new player_slot = g_iPlayerSlot[client];
	g_iPlayerArena[client] = 0;
	g_iPlayerSlot[client] = 0;
	g_iArenaQueue[arena_index][player_slot] = 0;
	
	if (IsValidClient(client) && GetClientTeam(client) != TEAM_SPEC)
	{
		ChangeClientTeam(client, 1);
		
		if(specfix)
			CreateTimer(0.1, Timer_SpecFix, GetClientUserId(client));
	}
	
	new after_leaver_slot = player_slot + 1; 
	
	if (player_slot==SLOT_ONE || player_slot==SLOT_TWO)
	{
		new foe_slot = player_slot==SLOT_ONE ? SLOT_TWO : SLOT_ONE;
		new foe = g_iArenaQueue[arena_index][foe_slot];
		
		if(g_bArenaBBall[arena_index])
		{
			if(IsValidEdict(g_iBBallIntel[arena_index]) && g_iBBallIntel[arena_index] > 0)
			{
				SDKUnhook(g_iBBallIntel[arena_index], SDKHook_StartTouch, OnTouchIntel);
				RemoveEdict(g_iBBallIntel[arena_index]);
				g_iBBallIntel[arena_index] = -1;
			}
			
			RemoveClientParticle(client);
			g_bPlayerHasIntel[client] = false;
			
			if(foe)
			{
				RemoveClientParticle(foe);
				g_bPlayerHasIntel[foe] = false;
			}
		}
		
		if (g_iArenaStatus[arena_index] >= AS_FIGHT && g_iArenaStatus[arena_index] < AS_REPORTED && calcstats && !g_bNoStats && foe)
		{
			new String:foe_name[MAX_NAME_LENGTH];
			new String:player_name[MAX_NAME_LENGTH];
			GetClientName(foe,foe_name, sizeof(foe_name));
			GetClientName(client,player_name, sizeof(player_name));
			
			g_iArenaStatus[arena_index] = AS_REPORTED;
			
			if(g_iArenaScore[arena_index][foe_slot] > g_iArenaScore[arena_index][player_slot])
			{
				if(g_iArenaScore[arena_index][foe_slot] >= g_iArenaEarlyLeave[arena_index])
				{
					CalcELO(foe,client);
					CPrintToChatAll("%t","XdefeatsYearly", foe_name, g_iArenaScore[arena_index][foe_slot], player_name, g_iArenaScore[arena_index][player_slot], g_sArenaName[arena_index]);
				}
			}
		}
		
		if (g_iArenaQueue[arena_index][SLOT_TWO+1])
		{
			new next_client = g_iArenaQueue[arena_index][SLOT_TWO+1];
			g_iArenaQueue[arena_index][SLOT_TWO+1] = 0;
			g_iArenaQueue[arena_index][player_slot] = next_client;
			g_iPlayerSlot[next_client] = player_slot;
			after_leaver_slot = SLOT_TWO + 2;
			new String:playername[MAX_NAME_LENGTH];
			CreateTimer(2.0,Timer_StartDuel,arena_index);
			GetClientName(next_client,playername,sizeof(playername));
			
			if (!g_bNoStats && !g_bNoDisplayRating)
				CPrintToChatAll("%t","JoinsArena",playername,g_iPlayerRating[next_client],g_sArenaName[arena_index]);
			else
			CPrintToChatAll("%t","JoinsArenaNoStats",playername,g_sArenaName[arena_index]);
			
			
		} else {
			if (foe && IsFakeClient(foe))
			{
				new Handle:cvar = FindConVar("tf_bot_quota");
				new quota = GetConVarInt(cvar);
				ServerCommand("tf_bot_quota %d", quota - 1);
			}
			
			g_iArenaStatus[arena_index] = AS_IDLE;
			return;
		}
	}	
	
	if (g_iArenaQueue[arena_index][after_leaver_slot])
	{
		while (g_iArenaQueue[arena_index][after_leaver_slot])
		{
			g_iArenaQueue[arena_index][after_leaver_slot-1] = g_iArenaQueue[arena_index][after_leaver_slot];
			g_iPlayerSlot[g_iArenaQueue[arena_index][after_leaver_slot]] -= 1;
			after_leaver_slot++;
		}
		g_iArenaQueue[arena_index][after_leaver_slot-1] = 0;
	}
}

AddInQueue(client,arena_index, bool:showmsg = true)
{
	if(!IsValidClient(client))
		return;
	
	if (g_iPlayerArena[client])
		PrintToChatAll("client <%N> is already on arena %d",client,arena_index);
	
	new player_slot = SLOT_ONE;
	
	while (g_iArenaQueue[arena_index][player_slot])
		player_slot++;
	
	g_iPlayerArena[client] = arena_index;
	g_iPlayerSlot[client] = player_slot;
	g_iArenaQueue[arena_index][player_slot] = client;
	
	SetPlayerToAllowedClass(client, arena_index);
	
	if (showmsg)
		CPrintToChat(client,"%t","ChoseArena",g_sArenaName[arena_index]);
	
	if (player_slot <= SLOT_TWO)
	{
		decl String:name[MAX_NAME_LENGTH];
		GetClientName(client,name,sizeof(name));
		
		if(!g_bNoStats && !g_bNoDisplayRating)	
			CPrintToChatAll("%t","JoinsArena",name,g_iPlayerRating[client],g_sArenaName[arena_index]);
		else
		CPrintToChatAll("%t","JoinsArenaNoStats",name,g_sArenaName[arena_index]);
		
		if (g_iArenaQueue[arena_index][SLOT_ONE] && g_iArenaQueue[arena_index][SLOT_TWO])
			CreateTimer(1.5,Timer_StartDuel,arena_index);
		else
		CreateTimer(0.1,Timer_ResetPlayer,GetClientUserId(client));
	} else {
		if (GetClientTeam(client) != TEAM_SPEC)
			ChangeClientTeam(client, TEAM_SPEC);
		if (player_slot == SLOT_TWO + 1)
			CPrintToChat(client,"%t","NextInLine");
		else
		CPrintToChat(client,"%t","InLine",player_slot-SLOT_TWO);
	}
	
	return;
}

// ====[ STATS ]====================================================
CalcELO(winner, loser)
{
	if (IsFakeClient(winner) || IsFakeClient(loser) || g_bNoStats)
		return;
	
	
	new Float:El = 1/(Pow(10.0, float((g_iPlayerRating[winner]-g_iPlayerRating[loser]))/400)+1);
	new k = (g_iPlayerRating[winner]>=2400) ? 10 : 15;
	new winnerscore = RoundFloat(k*El);
	g_iPlayerRating[winner] += winnerscore;
	k = (g_iPlayerRating[loser]>=2400) ? 10 : 15;
	new loserscore = RoundFloat(k*El);
	g_iPlayerRating[loser] -= loserscore;
	
	decl String:query[512], String:sCleanArenaname[128], String:sCleanMapName[128];
	new String:sWinnerStats[1024], String:sLoserStats[1024];
	new arena_index = g_iPlayerArena[winner], time = GetTime();
	new Float:fAccuracy[3][g_iWeaponCount]; // Winner = SLOT_ONE, Loser = SLOT_TWO
	SQL_EscapeString(db, g_sArenaName[g_iPlayerArena[winner]], sCleanArenaname, sizeof(sCleanArenaname));
	SQL_EscapeString(db, g_sMapName, sCleanMapName, sizeof(sCleanMapName));
	
	if(IsValidClient(winner) && !g_bNoDisplayRating)
		CPrintToChat(winner, "%t","GainedPoints",winnerscore);
	
	if(IsValidClient(loser) && !g_bNoDisplayRating)
		CPrintToChat(loser, "%t","LostPoints",loserscore);
	
	//winner's stats
	Format(query, sizeof(query), 	"UPDATE mgemod_players SET rating=%i,wins=wins+1,lastplayed=%i WHERE steamid='%s'", 
									g_iPlayerRating[winner], time, g_sPlayerSteamID[winner]);
	SQL_TQuery(db, SQLErrorCheckCallback, query);
	
	//loser's stats
	Format(query, sizeof(query), 	"UPDATE mgemod_players SET rating=%i,losses=losses+1,lastplayed=%i WHERE steamid='%s'", 
									g_iPlayerRating[loser], time, g_sPlayerSteamID[loser]);
	SQL_TQuery(db, SQLErrorCheckCallback, query);
	
	for(new i = 0; i <= g_iWeaponCount; ++i)
	{
		new Float:accuracy;
		if (g_iPlayerShotCount[winner][i] > 0)
		{
			accuracy = ((float(g_iPlayerHitCount[winner][i])/float(g_iPlayerShotCount[winner][i]))*100.0);
			fAccuracy[SLOT_ONE][i] = RoundToFloor(accuracy) + FloatFraction(accuracy);
			Format(sWinnerStats, sizeof(sWinnerStats), 	"%i, %i, %i, %f, %i, %i, %i\\n%s", 
														g_iWeaponIdx[i], g_iPlayerHitCount[winner][i], g_iPlayerShotCount[winner][i], 
														fAccuracy[SLOT_ONE][i], g_iPlayerDamageDealt[winner][i], g_iPlayerDirectHitCount[winner][i], 
														g_iPlayerAirshotCount[winner][i], sWinnerStats);
		}
		
		if (g_iPlayerShotCount[loser][i] > 0)
		{
			accuracy = ((float(g_iPlayerHitCount[loser][i])/float(g_iPlayerShotCount[loser][i]))*100.0);
			fAccuracy[SLOT_TWO][i] = RoundToFloor(accuracy) + FloatFraction(accuracy);
			Format(sLoserStats, sizeof(sLoserStats), 	"%i, %i, %i, %f, %i, %i, %i\\n%s", 	
														g_iWeaponIdx[i], g_iPlayerHitCount[loser][i], g_iPlayerShotCount[loser][i], 
														fAccuracy[SLOT_TWO][i], g_iPlayerDamageDealt[loser][i], g_iPlayerDirectHitCount[loser][i], 
														g_iPlayerAirshotCount[loser][i], sLoserStats);
		}
	}

	// DB entry for this specific duel.
	if(g_bUseSQLite)
	{
		Format(query, sizeof(query), 	"INSERT INTO mgemod_duels VALUES ('%s', '%s', %i, %i, %i, %i, '%s', '%s')", 
										g_sPlayerSteamID[winner], g_sPlayerSteamID[loser], g_iArenaScore[arena_index][g_iPlayerSlot[winner]], 
										g_iArenaScore[arena_index][g_iPlayerSlot[loser]], g_iArenaFraglimit[arena_index], time, g_sMapName, 
										g_sArenaName[arena_index]);
		SQL_TQuery(db, SQLErrorCheckCallback, query);
	} else {
		Format(query, sizeof(query), 	"INSERT INTO mgemod_duels (gametime, winner, loser, winnerscore, loserscore, winnerstats, loserstats, mapname, arenaname, fraglimit) VALUES (%i, '%s', '%s', %i, %i, '%s', '%s', '%s', '%s', %i)", 
										time, g_sPlayerSteamID[winner], g_sPlayerSteamID[loser], g_iArenaScore[arena_index][g_iPlayerSlot[winner]],
										g_iArenaScore[arena_index][g_iPlayerSlot[loser]], sWinnerStats, sLoserStats, sCleanMapName, sCleanArenaname, 
										g_iArenaFraglimit[arena_index]);
		SQL_TQuery(db, SQLErrorCheckCallback, query);
	}
}

GetWeaponIndex(weapon) 
{
	if(IsValidEntity(weapon))
	{
		new weaponIdx = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		return BinarySearch(g_iWeaponIdx, g_iWeaponCount, weaponIdx);
	} else {
		return -1;
	}
}

AddHit(attacker, damage)
{
	if(g_bNoStats)
		return;
	
	new weaponIndex = g_iPlayerAttackUsedWeaponIdx[attacker];
	if (weaponIndex != -1)
	{
		g_iPlayerHitCount[attacker][weaponIndex] += 1;
		g_iPlayerDamageDealt[attacker][weaponIndex] += damage;
	}
	
	ShowSpecHudToArena(g_iPlayerArena[attacker]);
}

//to detect shots, check wether the ammo of a player decreased 
DetectShot(client)
{
	if(g_bNoStats || HasSwitchedWeapons(client) || g_iPlayerWeaponIndex[client] == -1) 
		return;
	
	new curAmmo = GetClientClipAmmo(client);
	new prevAmmo = g_iPreviousAmmo[client];
	
	if (curAmmo == prevAmmo) 
		return;
	
	if(curAmmo < prevAmmo)
	{
		g_iPlayerShotCount[client][g_iPlayerWeaponIndex[client]] += prevAmmo - curAmmo;
		
		ShowSpecHudToArena(g_iPlayerArena[client]);
	}
	
	g_iPreviousAmmo[client] = curAmmo;
}

//detect wether client switched weapons and reset g_iPreviousAmmo count in case
bool:HasSwitchedWeapons(client)
{
	new activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (activeWeapon != g_iPlayerWeapon[client] && activeWeapon != -1)
	{
		g_iPlayerWeaponIndex[client] = GetWeaponIndex(activeWeapon);
		g_iPlayerWeapon[client] = activeWeapon;
		new prevAmmo = GetEntProp(activeWeapon, Prop_Send, "m_iClip1");
		g_iPreviousAmmo[client] = prevAmmo;
		
		return true;
	}
	return false;
}

GetClientClipAmmo(client)
{
	new activeWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if(!IsValidEntity(activeWeapon))
		return -1;
	
	return GetEntProp(activeWeapon, Prop_Send, "m_iClip1");
}

BinarySearch(const array[], size, value)
{
	new min = 0;
	new max = size - 1;
	new mid = 0;
	do {
		mid = min + ((max - min) / 2);
		
		if(array[mid] == value) {
			return mid;
		}
		
		if (array[mid] > value){
			max = mid - 1;
		} else {
			min = mid + 1;
		}
	} while (max >= min);
	
	return -1;
}

ResetAccuracyStats(client)
{
	for(new i = 0; i <= g_iWeaponCount; ++i)
	{
		g_iPlayerHitCount[client][i] = 0;
		g_iPlayerShotCount[client][i] = 0;
		g_iPlayerDamageDealt[client][i] = 0;
		g_iPlayerAirshotCount[client][i] = 0;
		g_iPlayerDirectHitCount[client][i] = 0;
	}
}

// ====[ UTIL ]====================================================
LoadSpawnPoints()
{
	new String:txtfile[256];
	BuildPath(Path_SM, txtfile, sizeof(txtfile), MAPCONFIGFILE);
	
	new String:spawn[64];
	GetCurrentMap(g_sMapName,sizeof(g_sMapName));
	
	new Handle:kv = CreateKeyValues("SpawnConfig");
	
	new String:spawnCo[6][16];
	new String:kvmap[32];
	new count;
	new i;
	g_iArenaCount = 0;
	
	for(i=0; i<=MAXARENAS; i++)
		g_iArenaSpawns[i] = 0;
	
	if (FileToKeyValues(kv, txtfile))
	{
		if (KvGotoFirstSubKey(kv))
		{
			do
			{
				KvGetSectionName(kv, kvmap, 64);
				if (StrEqual(g_sMapName, kvmap, false))
				{
					if (KvGotoFirstSubKey(kv))
					{
						do
						{
							g_iArenaCount++;
							KvGetSectionName(kv, g_sArenaName[g_iArenaCount], 64);
							new id;
							if (KvGetNameSymbol(kv, "1", id))
							{
								new String:intstr[4];
								new String:intstr2[4];
								do
								{
									g_iArenaSpawns[g_iArenaCount]++;
									IntToString(g_iArenaSpawns[g_iArenaCount], intstr, sizeof(intstr));
									IntToString(g_iArenaSpawns[g_iArenaCount]+1, intstr2, sizeof(intstr2));
									KvGetString(kv, intstr, spawn, sizeof(spawn));
									count = ExplodeString(spawn, " ", spawnCo, 6, 16);
									if (count==6)
									{
										for (i=0; i<3; i++)
										{
											g_fArenaSpawnOrigin[g_iArenaCount][g_iArenaSpawns[g_iArenaCount]][i] = StringToFloat(spawnCo[i]);
										}
										for (i=3; i<6; i++)
										{
											g_fArenaSpawnAngles[g_iArenaCount][g_iArenaSpawns[g_iArenaCount]][i-3] = StringToFloat(spawnCo[i]);
										}
									} else if(count==4) {
										for (i=0; i<3; i++)
										{
											g_fArenaSpawnOrigin[g_iArenaCount][g_iArenaSpawns[g_iArenaCount]][i] = StringToFloat(spawnCo[i]);
										}
										g_fArenaSpawnAngles[g_iArenaCount][g_iArenaSpawns[g_iArenaCount]][0] = 0.0;
										g_fArenaSpawnAngles[g_iArenaCount][g_iArenaSpawns[g_iArenaCount]][1] = StringToFloat(spawnCo[3]);
										g_fArenaSpawnAngles[g_iArenaCount][g_iArenaSpawns[g_iArenaCount]][2] = 0.0;
									} else {
										SetFailState("Error in cfg file. Wrong number of parametrs (%d) on spawn <%i> in arena <%s>",count,g_iArenaSpawns[g_iArenaCount],g_sArenaName[g_iArenaCount]);
									}
								} while (KvGetNameSymbol(kv, intstr2, id));
								LogMessage("Loaded %d spawns on arena %s.",g_iArenaSpawns[g_iArenaCount], g_sArenaName[g_iArenaCount]);
							} else {
								LogError("Could not load spawns on arena %s.", g_sArenaName[g_iArenaCount]);
							}
							
							//optional parametrs
							g_iArenaFraglimit[g_iArenaCount] = KvGetNum(kv, "fraglimit", g_iDefaultFragLimit);
							g_iArenaMinRating[g_iArenaCount] = KvGetNum(kv, "minrating", -1);
							g_iArenaMaxRating[g_iArenaCount] = KvGetNum(kv, "maxrating", -1);
							g_bArenaMidair[g_iArenaCount] = KvGetNum(kv, "midair", 0) ? true : false ;
							g_iArenaCdTime[g_iArenaCount] = KvGetNum(kv, "cdtime", DEFAULT_CDTIME);
							g_bArenaMGE[g_iArenaCount] = KvGetNum(kv, "mge", 0) ? true : false ;
							g_fArenaHPRatio[g_iArenaCount] = KvGetFloat(kv, "hpratio", 1.5);
							g_bArenaEndif[g_iArenaCount] = KvGetNum(kv, "endif", 0) ? true : false ;
							g_bArenaBBall[g_iArenaCount] = KvGetNum(kv, "bball", 0) ? true : false ;
							g_bVisibleHoops[g_iArenaCount] = KvGetNum(kv, "vishoop", 0) ? true : false ;
							g_iArenaEarlyLeave[g_iArenaCount] = KvGetNum(kv, "earlyleave", 0);
							g_bArenaInfAmmo[g_iArenaCount] = KvGetNum(kv, "infammo", 1) ? true : false ;
							g_bArenaShowHPToPlayers[g_iArenaCount] = KvGetNum(kv, "showhp", 1) ? true : false ;
							g_fArenaMinSpawnDist[g_iArenaCount] = KvGetFloat(kv, "mindist", 100.0);
							g_fArenaRespawnTime[g_iArenaCount] = KvGetFloat(kv, "respawntime", 0.1);
							g_bArenaAmmomod[g_iArenaCount] = KvGetNum(kv, "ammomod", 0) ? true : false ;
							//parsing allowed classes for current arena
							decl String:sAllowedClasses[128];
							KvGetString(kv, "classes", sAllowedClasses, sizeof(sAllowedClasses));
							LogMessage("%s classes: <%s>", g_sArenaName[g_iArenaCount], sAllowedClasses);
							ParseAllowedClasses(sAllowedClasses,g_tfctArenaAllowedClasses[g_iArenaCount]); 
						} while (KvGotoNextKey(kv));
					}
					break;
				}
			} while (KvGotoNextKey(kv));
			if (g_iArenaCount)
			{
				LogMessage("Loaded %d arenas. MGEMod enabled.",g_iArenaCount);
				CloseHandle(kv);
				return true;
			} else {	
				CloseHandle(kv);
				return false;
			}
		} else {
			LogError("Error in cfg file.");
			return false;
		}
	} else {
		LogError("Error. Can't find cfg file");
		return false;
	}
}

LoadStatsCfg()
{
	new String:txtfile[256];
	BuildPath(Path_SM, txtfile, sizeof(txtfile), STATSCONFIGFILE);
	
	new Handle:kv = CreateKeyValues("StatsConfig");
	g_iWeaponCount = 0;
	
	for(new i = 0; i <= MAXWEAPONS; i++)
		g_iWeaponIdx[i] = -1;
	
	if (FileToKeyValues(kv, txtfile))
	{
		if (KvGotoFirstSubKey(kv))
		{
			do
			{
				g_iWeaponCount++;
				KvGetSectionName(kv, g_sWeaponName[g_iWeaponCount], 64);
				g_iWeaponIdx[g_iWeaponCount] = KvGetNum(kv, "idx");
				g_iWeaponMaxDmg[g_iWeaponCount] = KvGetNum(kv, "maxdmg", -1);
				g_bWeaponProjectile[g_iWeaponCount] = KvGetNum(kv, "projectile", 0) ? true : false ;
				LogMessage("Added weapon %s.", g_sWeaponName[g_iWeaponCount]);
			} while (KvGotoNextKey(kv));
			
			if (g_iWeaponCount)
			{
				LogMessage("Stats enabled for %i weapons.", g_iWeaponCount);
				CloseHandle(kv);
				return true;
			} else {
				LogError("Can't find stats cfg. Stats disabled");	
				CloseHandle(kv);
				return false;
			}
		} else {
			LogError("Error in stats cfg file.");
			return false;
		}
	} else {
		LogError("Error. Can't find stats cfg file");
		return false;
	}
}

ResetPlayer(client)
{
	new arena_index = g_iPlayerArena[client];
	new player_slot = g_iPlayerSlot[client];
	
	if (!arena_index || !player_slot)
		return 0;
	
	g_iPlayerSpecTarget[client] = 0;
	
	new team = GetClientTeam(client);
	
	if (player_slot - team != SLOT_ONE - TEAM_RED)
		ChangeClientTeam(client, player_slot + TEAM_RED - SLOT_ONE);
	
	new TFClassType:class;
	class = g_tfctPlayerClass[client] ? g_tfctPlayerClass[client] : TFClass_Soldier;
	
	if (!IsPlayerAlive(client) || g_bArenaBBall[arena_index])
	{
		if (class != TF2_GetPlayerClass(client)) 
			TF2_SetPlayerClass(client,class);
		
		TF2_RespawnPlayer(client);
	} else {
		TF2_RegeneratePlayer(client);
		ExtinguishEntity(client);
	}
	
	g_iPlayerMaxHP[client] = GetEntProp(client, Prop_Data, "m_iMaxHealth");
	
	if (g_bArenaMidair[arena_index])
		g_iPlayerHP[client] = g_iMidairHP;
	else
	g_iPlayerHP[client] = RoundToNearest(float(g_iPlayerMaxHP[client])*g_fArenaHPRatio[arena_index]);
	
	if (g_bArenaMGE[arena_index] || g_bArenaBBall[arena_index])
		SetEntProp(client, Prop_Data, "m_iHealth", RoundToNearest(float(g_iPlayerMaxHP[client])*g_fArenaHPRatio[arena_index]));
	
	ShowPlayerHud(client);
	ResetClientAmmoCounts(client);
	CreateTimer(0.1,Timer_Tele,GetClientUserId(client));
	
	return 1;
}

ResetClientAmmoCounts(client)
{
	// Crutch.
	g_iPlayerClip[client][SLOT_ONE] = -1;
	g_iPlayerClip[client][SLOT_TWO] = -1;
	
	// Check how much ammo each gun can hold in its clip and store it in a global variable so it can be set to that amount later.
	if(IsValidEntity(GetPlayerWeaponSlot(client, 0)))
		g_iPlayerClip[client][SLOT_ONE] = GetEntProp(GetPlayerWeaponSlot(client, 0), Prop_Data, "m_iClip1");
	if(IsValidEntity(GetPlayerWeaponSlot(client, 1)))
		g_iPlayerClip[client][SLOT_TWO] = GetEntProp(GetPlayerWeaponSlot(client, 1), Prop_Data, "m_iClip1");
}

ResetIntel(arena_index, any:client = -1)
{
	if(g_bArenaBBall[arena_index])
	{
		if(IsValidEdict(g_iBBallIntel[arena_index]) && g_iBBallIntel[arena_index] > 0)
		{
			SDKUnhook(g_iBBallIntel[arena_index], SDKHook_StartTouch, OnTouchIntel);
			RemoveEdict(g_iBBallIntel[arena_index]);
			g_iBBallIntel[arena_index] = -1;
		}
		
		if (g_iBBallIntel[arena_index] == -1)
			g_iBBallIntel[arena_index] = CreateEntityByName("item_ammopack_small");
		else
		LogError("[%s] Intel [%i] already exists.", g_sArenaName[arena_index], g_iBBallIntel[arena_index]);
		
		
		new Float:intel_loc[3];
		
		if(client != -1)
		{
			new client_slot = g_iPlayerSlot[client];
			g_bPlayerHasIntel[client] = false;
			
			if(client_slot == SLOT_ONE)
			{
				intel_loc[0] = g_fArenaSpawnOrigin[arena_index][g_iArenaSpawns[arena_index]-3][0];
				intel_loc[1] = g_fArenaSpawnOrigin[arena_index][g_iArenaSpawns[arena_index]-3][1];
				intel_loc[2] = g_fArenaSpawnOrigin[arena_index][g_iArenaSpawns[arena_index]-3][2];
			} else if(client_slot == SLOT_TWO) {
				intel_loc[0] = g_fArenaSpawnOrigin[arena_index][g_iArenaSpawns[arena_index]-2][0];
				intel_loc[1] = g_fArenaSpawnOrigin[arena_index][g_iArenaSpawns[arena_index]-2][1];
				intel_loc[2] = g_fArenaSpawnOrigin[arena_index][g_iArenaSpawns[arena_index]-2][2];
			}
		} else {	
			intel_loc[0] = g_fArenaSpawnOrigin[arena_index][g_iArenaSpawns[arena_index]-4][0];
			intel_loc[1] = g_fArenaSpawnOrigin[arena_index][g_iArenaSpawns[arena_index]-4][1];
			intel_loc[2] = g_fArenaSpawnOrigin[arena_index][g_iArenaSpawns[arena_index]-4][2];
		}
		
		DispatchSpawn(g_iBBallIntel[arena_index]);
		TeleportEntity(g_iBBallIntel[arena_index], intel_loc, NULL_VECTOR, NULL_VECTOR);
		SetEntProp(g_iBBallIntel[arena_index], Prop_Send, "m_iTeamNum", 1, 4);
		SetEntityModel(g_iBBallIntel[arena_index], MODEL_BRIEFCASE);
		SDKUnhook(g_iBBallIntel[arena_index], SDKHook_StartTouch, OnTouchIntel);
		SDKHook(g_iBBallIntel[arena_index], SDKHook_StartTouch, OnTouchIntel);
		AcceptEntityInput(g_iBBallIntel[arena_index], "Enable");
	}
}

SetPlayerToAllowedClass(client, arena_index)
{// If a player's class isn't allowed, set it to one that is.
	if (g_tfctPlayerClass[client]==TFClassType:0 || !g_tfctArenaAllowedClasses[arena_index][g_tfctPlayerClass[client]])
	{
		for(new i=1;i<=9;i++)
		{
			if (g_tfctArenaAllowedClasses[arena_index][i])
			{
				g_tfctPlayerClass[client] = TFClassType:i;
				break;
			}
		}
	}
}

ParseAllowedClasses(const String:sList[],output[TFClassType])
{
	new count, String:a_class[9][8];
	
	if (strlen(sList)>0)
	{
		count = ExplodeString(sList, " ", a_class, 9, 8);
	} else {
		decl String:sDefList[128];
		GetConVarString(gcvar_allowedClasses,sDefList,sizeof(sDefList));
		count = ExplodeString(sDefList, " ", a_class, 9, 8);
	}
	
	for (new i=1;i<=9;i++)
		output[i] = 0;
	
	for (new i=0;i<count;i++)
	{
		new TFClassType:c = TF2_GetClass(a_class[i]); 
		
		if (c) 
			output[c] = 1;
	}
}

// ====[ PARTICLES ]====================================================

AttachParticle(ent, String:particleType[],&particle) // Particle code borrowed from "The Amplifier" and "Presents!".
{
	particle = CreateEntityByName("info_particle_system");
	
	decl Float:pos[3];
	
	// Get position of entity
	GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
	
	// Teleport, set up
	TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchKeyValue(particle, "effect_name", particleType);
	
	SetVariantString("!activator");
	AcceptEntityInput(particle, "SetParent", ent, particle, 0);
	
	// All entities in presents are given a targetname to make clean up easier
	DispatchKeyValue(particle, "targetname", "tf2particle");
	
	// Spawn and start
	DispatchSpawn(particle);
	ActivateEntity(particle);
	AcceptEntityInput(particle, "Start");
}

RemoveClientParticle(client)
{
	new particle = EntRefToEntIndex(g_iClientParticle[client]);
	
	if (particle != 0 && IsValidEntity(particle))
		RemoveEdict(particle);
	
	g_iClientParticle[client]=0;
}

// ====[ MAIN MENU ]====================================================
ShowMainMenu(client,bool:listplayers=true)
{
	if (client<=0)
		return;
	
	decl String:title[128];
	decl String:menu_item[128];
	
	new Handle:menu = CreateMenu(Menu_Main);
	
	Format(title, sizeof(title), "%T","MenuTitle",client);
	SetMenuTitle(menu, title);
	new String:si[4];
	
	for (new i=1;i<=g_iArenaCount;i++)
	{
		new numslots = 0;
		for(new int = 1; int <= MAXPLAYERS+1; int++)
		{
			if(g_iArenaQueue[i][int])
				numslots++;
			else
				break;
		}
		
		if(numslots > 2)
			Format(menu_item,sizeof(menu_item),"%s (2)(%d)", g_sArenaName[i], (numslots - 2));
		else if(numslots > 0)
			Format(menu_item,sizeof(menu_item),"%s (%d)", g_sArenaName[i], numslots);
		else
		Format(menu_item,sizeof(menu_item),"%s", g_sArenaName[i]);
		
		IntToString(i,si,sizeof(si));
		AddMenuItem(menu, si, menu_item);
	}
	
	Format(menu_item,sizeof(menu_item),"%T","MenuRemove",client);
	AddMenuItem(menu, "1000", menu_item);
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
	
	new String:report[128];
	
	//listing players
	if (!listplayers)
		return;
	
	for (new i=1;i<=g_iArenaCount;i++)
	{
		new red_f1 = g_iArenaQueue[i][SLOT_ONE];
		new blu_f1 = g_iArenaQueue[i][SLOT_TWO];
		if (red_f1>0 || blu_f1>0)
		{
			Format(report,sizeof(report),"\x05%s:",g_sArenaName[i]);
			
			if (!g_bNoDisplayRating)
			{
				if (red_f1>0 && blu_f1>0)
					Format(report,sizeof(report),"%s \x04%N \x03(%d) \x05vs \x04%N (%d) \x05",report,red_f1,g_iPlayerRating[red_f1],blu_f1,g_iPlayerRating[blu_f1]);
				else if (red_f1>0)
					Format(report,sizeof(report),"%s \x04%N (%d)\x05",report,red_f1,g_iPlayerRating[red_f1]);
				else if (blu_f1>0)
					Format(report,sizeof(report),"%s \x04%N (%d)\x05",report,blu_f1,g_iPlayerRating[blu_f1]);	
			} else {
				if (red_f1>0 && blu_f1>0)
					Format(report,sizeof(report),"%s \x04%N \x05vs \x04%N \x05",report,red_f1,blu_f1);
				else if (red_f1>0)
					Format(report,sizeof(report),"%s \x04%N \x05",report,red_f1);
				else if (blu_f1>0)
					Format(report,sizeof(report),"%s \x04%N \x05",report,blu_f1);
			}
			
			if (g_iArenaQueue[i][SLOT_TWO + 1])
			{
				Format(report,sizeof(report),"%s Waiting: ",report);
				new j = SLOT_TWO + 1;
				while (g_iArenaQueue[i][j + 1])
				{
					Format(report,sizeof(report),"%s\x04%N \x05, ",report,g_iArenaQueue[i][j]);
					j++;
				}
				Format(report,sizeof(report),"%s\x04%N",report,g_iArenaQueue[i][j]);
			}
			PrintToChat(client,"%s",report);
		}
	}
}

public Menu_Main(Handle:menu, MenuAction:action, param1, param2)
{ 
	switch (action)
	{
		case MenuAction_Select:
		{
			new client = param1;
			if (!client) return;
			new String:capt[32];
			new String:sanum[32];
			
			GetMenuItem(menu, param2, sanum,sizeof(sanum), _,capt, sizeof(capt));
			new arena_index = StringToInt(sanum);
			
			if (arena_index>0 && arena_index <=g_iArenaCount)
			{
				if (arena_index == g_iPlayerArena[client])
				{
					//show warn msg
					ShowMainMenu(client,false);
					return;
				}
				
				//checking rating
				new playerrating = g_iPlayerRating[client];
				new minrating = g_iArenaMinRating[arena_index];
				new maxrating = g_iArenaMaxRating[arena_index];
				
				if (minrating>0 && playerrating < minrating)
				{
					CPrintToChat(client,"%t","LowRating",playerrating,minrating);
					ShowMainMenu(client,false);
					return;
				} else if (maxrating>0 && playerrating > maxrating){
					CPrintToChat(client,"%t","HighRating",playerrating,maxrating);
					ShowMainMenu(client,false);
					return;
				}
				
				if (g_iPlayerArena[client])
					RemoveFromQueue(client, true);
				
				AddInQueue(client,arena_index);
				
			} else {
				RemoveFromQueue(client);
			}
		}
		case MenuAction_Cancel:
		{
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}

ShowTop5Menu(client, String:name[][], rating[])
{
	if (client<=0)
		return;
	
	decl String:title[128];
	decl String:menu_item[128];
	
	new Handle:menu = CreateMenu(Menu_Top5);
	
	Format(title, sizeof(title), "%T","Top5Title", client);
	SetMenuTitle(menu, title);
	new String:si[4];
	
	if(!g_bNoDisplayRating)
	{
		for (new i=0;i<5;i++)
		{
			IntToString(i, si, sizeof(si));
			Format(menu_item, sizeof(menu_item), "%s (%i)", name[i], rating[i]);
			AddMenuItem(menu, si, menu_item);
		}
	} else {
		for (new i=0;i<5;i++)
		{
			IntToString(i, si, sizeof(si));
			Format(menu_item, sizeof(menu_item), "%s", name[i]);
			AddMenuItem(menu, si, menu_item);
		}
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 0);
}

public Menu_Top5(Handle:menu, MenuAction:action, param1, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
		}
		case MenuAction_Cancel:
		{
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}
// ====[ ENDIF ]====================================================
public Action:BoostVectors(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	new Float:vecClient[3];
	new Float:vecBoost[3];
	
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vecClient);
	
	vecBoost[0] = vecClient[0] * g_fRocketForceX;
	vecBoost[1] = vecClient[1] * g_fRocketForceY;
	if(vecClient[2] > 0)
	{
		vecBoost[2] = vecClient[2] * g_fRocketForceZ;
	} else {
		vecBoost[2] = vecClient[2];
	}
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecBoost);
}

// ====[ CVARS ]====================================================
public handler_ConVarChange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if (convar == gcvar_blockFallDamage) {
		StringToInt(newValue) ? (g_bBlockFallDamage = true) : (g_bBlockFallDamage = false);
		if (g_bBlockFallDamage)
			AddNormalSoundHook(sound_hook);
		else
		RemoveNormalSoundHook(sound_hook);
	}
	else if (convar == gcvar_fragLimit)
		g_iDefaultFragLimit = StringToInt(newValue);
	else if (convar == gcvar_airshotHeight)
		g_iAirshotHeight = StringToInt(newValue);
	else if (convar == gcvar_midairHP)
		g_iMidairHP = StringToInt(newValue);
	else if (convar == gcvar_RocketForceX)
		g_fRocketForceX = StringToFloat(newValue);
	else if (convar == gcvar_RocketForceY)
		g_fRocketForceY = StringToFloat(newValue);
	else if (convar == gcvar_RocketForceZ)
		g_fRocketForceZ = StringToFloat(newValue);
	else if (convar == gcvar_autoCvar)
		StringToInt(newValue) ? (g_bAutoCvar = true) : (g_bAutoCvar = false);
	else if (convar == gcvar_bballParticle_red)
		strcopy(g_sBBallParticleRed, sizeof(g_sBBallParticleRed), newValue);
	else if (convar == gcvar_bballParticle_blue)
		strcopy(g_sBBallParticleBlue, sizeof(g_sBBallParticleBlue), newValue);
	else if (convar == gcvar_meatshotPercent)
		g_fMeatshotPercent = StringToFloat(newValue);
	else if (convar == gcvar_noDisplayRating)
		StringToInt(newValue) ? (g_bNoDisplayRating = true) : (g_bNoDisplayRating = false);
	else if (convar == gcvar_stats)
		g_bNoStats = (GetConVarBool(gcvar_stats)) ? false : true;
	else if (convar == gcvar_reconnectInterval)
		g_iReconnectInterval = StringToInt(newValue);
}

// ====[ COMMANDS ]====================================================
public Action:Command_Menu(client, args)
{ //handle commands "!ammomod" "!add" and such //building queue's menu and listing arena's	
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	new String:sArg[32];
	if(GetCmdArg(1, sArg, sizeof(sArg)) > 0)
	{
		// Was the argument an arena_index number?
		new iArg = StringToInt(sArg);
		if(iArg > 0 && iArg <= g_iArenaCount)
		{
			if(g_iPlayerArena[client] == iArg)
				return Plugin_Handled;
			
			if (g_iPlayerArena[client])
				RemoveFromQueue(client, true);
			
			AddInQueue(client,iArg);
			return Plugin_Handled;
		}
		
		// Was the argument an arena name?
		GetCmdArgString(sArg, sizeof(sArg));
		new count;
		new found_arena;
		for(new i = 1; i <= g_iArenaCount; i++)
		{
			if(StrContains(g_sArenaName[i], sArg, false) >= 0)
			{
				count++;
				found_arena = i;
				if(count > 1)
				{
					ShowMainMenu(client);
					return Plugin_Handled;
				}
			}
		}
		
		// If there was only one string match, and it was a valid match, place the player in that arena if they aren't already in it.
		if(found_arena > 0 && found_arena <= g_iArenaCount && found_arena != g_iPlayerArena[client])
		{
			if (g_iPlayerArena[client])
				RemoveFromQueue(client, true);
			
			AddInQueue(client, found_arena);
			return Plugin_Handled;
		}
	}
	
	// Couldn't find a matching arena for the argument.
	ShowMainMenu(client);
	return Plugin_Handled;
}

public Action:Command_Top5(client, args)
{
	if (g_bNoStats || !IsValidClient(client))
		return Plugin_Continue;
	
	decl String:query[256];
	Format(query, sizeof(query), "SELECT name, rating FROM mgemod_players ORDER BY rating DESC LIMIT 5");
	SQL_TQuery(db, T_SQL_Top5, query, client);
	return Plugin_Continue;
}

public Action:Command_Remove(client, args)
{
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	RemoveFromQueue(client, true);
	return Plugin_Handled;
}

public Action:Command_JoinClass(client, args)
{
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	if (args)
	{
		new String:s_class[64];
		GetCmdArg(1, s_class, sizeof(s_class));
		new TFClassType:new_class = TF2_GetClass(s_class);
		
		if (new_class == g_tfctPlayerClass[client])
			return Plugin_Handled; // no need to do anything, as nothing has changed
		
		new arena_index = g_iPlayerArena[client];
		
		if (arena_index == 0) // if client is on arena
		{
			if (!g_tfctClassAllowed[new_class]) // checking global class restrctions
			{ 
				CPrintToChat(client,"%t","ClassIsNotAllowed");
				return Plugin_Handled;
			} else {
				TF2_SetPlayerClass(client, new_class);
				g_tfctPlayerClass[client] = new_class;
				ChangeClientTeam(client,TEAM_SPEC);
				ShowSpecHudToArena(g_iPlayerArena[client]);
			}
		} else {
			if (!g_tfctArenaAllowedClasses[arena_index][new_class])
			{
				CPrintToChat(client,"%t","ClassIsNotAllowed");
				return Plugin_Handled;
			}
			
			if (g_iPlayerSlot[client]==SLOT_ONE || g_iPlayerSlot[client]==SLOT_TWO)
			{
				if (g_iArenaStatus[arena_index] != AS_FIGHT || g_bArenaMGE[arena_index] || g_bArenaEndif[arena_index])
				{
					TF2_SetPlayerClass(client, new_class);
					g_tfctPlayerClass[client] = new_class;
					
					if(g_iArenaStatus[arena_index] == AS_FIGHT && g_bArenaMGE[arena_index] || g_bArenaEndif[arena_index])
					{
						new killer_slot = (g_iPlayerSlot[client]==SLOT_ONE) ? SLOT_TWO : SLOT_ONE;
						new fraglimit = g_iArenaFraglimit[arena_index];
						new killer = g_iArenaQueue[arena_index][killer_slot];
						
						if(g_iArenaStatus[arena_index] == AS_FIGHT && killer)
						{
							g_iArenaScore[arena_index][killer_slot] += 1;
							CPrintToChat(killer,"%t","ClassChangePointOpponent");	
							CPrintToChat(client,"%t","ClassChangePoint");
						}
						
						ShowPlayerHud(client);
						
						if(IsValidClient(killer))
						{
							TF2_RegeneratePlayer(killer);
							new raised_hp = RoundToNearest(float(g_iPlayerMaxHP[killer])*g_fArenaHPRatio[arena_index]);
							g_iPlayerHP[killer] = raised_hp;
							SetEntProp(killer, Prop_Data, "m_iHealth", raised_hp);
							ShowPlayerHud(killer);
						}
						
						if (g_iArenaStatus[arena_index] == AS_FIGHT && fraglimit>0 && g_iArenaScore[arena_index][killer_slot] >= fraglimit)
						{
							new String:killer_name[MAX_NAME_LENGTH];
							new String:victim_name[MAX_NAME_LENGTH];
							GetClientName(killer,killer_name, sizeof(killer_name));
							GetClientName(client,victim_name, sizeof(victim_name));
							CPrintToChatAll("%t","XdefeatsY", killer_name, g_iArenaScore[arena_index][killer_slot], victim_name, g_iArenaScore[arena_index][g_iPlayerSlot[client]], fraglimit, g_sArenaName[arena_index]);
							
							g_iArenaStatus[arena_index] = AS_REPORTED;
							
							if (!g_bNoStats /* && !g_arenaNoStats[arena_index]*/)
								CalcELO(killer,client);
							
							if (g_iArenaQueue[arena_index][SLOT_TWO+1])
							{
								RemoveFromQueue(client,false);
								AddInQueue(client,arena_index,false);
							} else {
								CreateTimer(3.0,Timer_StartDuel,arena_index);
							}
						}
					}
					
					CreateTimer(0.1,Timer_ResetPlayer,GetClientUserId(client));
					ShowSpecHudToArena(g_iPlayerArena[client]);
					return Plugin_Continue;
				} else {
					CPrintToChat(client, "%t", "NoClassChange");
					return Plugin_Handled;
				}
			} else {
				g_tfctPlayerClass[client] = new_class;
				ChangeClientTeam(client,TEAM_SPEC);
			}
		}
	}
	
	return Plugin_Handled;
}

public Action:Command_Spec(client, args)
{ //detecting spectator target
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	CreateTimer(0.1,Timer_ChangeSpecTarget,GetClientUserId(client));
	return Plugin_Continue;
}

public Action:Command_AddBot(client, args)
{ //adding bot to client's arena
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	new arena_index = g_iPlayerArena[client];
	new player_slot = g_iPlayerSlot[client];
	
	if (arena_index && (player_slot==SLOT_ONE || player_slot==SLOT_TWO))
	{
		ServerCommand("tf_bot_add");
		g_bPlayerAskedForBot[client] = true;
	}
	return Plugin_Handled;
}

public Action:Command_Loc(client, args)
{
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	new Float:vec[3];
	new Float:ang[3];
	GetClientAbsOrigin(client, vec);
	GetClientEyeAngles(client, ang);
	PrintToChat(client,"%.0f %.0f %.0f %.0f",vec[0],vec[1],vec[2],ang[1]);
	return Plugin_Handled;
}

public Action:Command_ToogleHitblip(client, args)
{
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	g_bHitBlip[client] = !g_bHitBlip[client];
	
	if (!g_bNoStats)
	{
		decl String:query[256];
		Format(query, sizeof(query), "UPDATE mgemod_players SET hitblip=%i WHERE steamid='%s'", g_bHitBlip[client]?1:0, g_sPlayerSteamID[client]);
		SQL_TQuery(db, SQLErrorCheckCallback, query);
	}
	
	PrintToChat(client, "\x01Hitblip is \x04%sabled\x01.", g_bHitBlip[client]?"en":"dis");
	return Plugin_Handled;
}

public Action:Command_ConnectionTest(client, args)
{
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	decl String:query[256];
	Format(query, sizeof(query), "SELECT rating FROM mgemod_players LIMIT 1");
	SQL_TQuery(db, T_SQL_Test, query, client);
	
	return Plugin_Handled;
}

public Action:Command_ToggleHud(client, args)
{
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	g_bShowHud[client] = !g_bShowHud[client];
	
	if(g_bShowHud[client])
	{
		if(g_iPlayerArena[client])
			ShowPlayerHud(client);
		else
		ShowSpecHudToClient(client);
	} else {
		HideHud(client);
	}
	
	if (!g_bNoStats)
	{
		decl  String:query[256];
		Format(query, sizeof(query), "UPDATE mgemod_players SET hud=%i WHERE steamid='%s'", g_bHitBlip[client]?1:0, g_sPlayerSteamID[client]);
		SQL_TQuery(db, SQLErrorCheckCallback, query);
	}
	
	PrintToChat(client, "\x01HUD is \x04%sabled\x01.", g_bShowHud[client]?"en":"dis");
	return Plugin_Handled;
}

public Action:Command_Rank(client, args)
{
	if (g_bNoStats || !IsValidClient(client))
		return Plugin_Continue;
	
	if(args==0)
	{
		if(g_bNoDisplayRating)
			CPrintToChat(client, "%t","MyRankNoRating",g_iPlayerWins[client],g_iPlayerLosses[client]);
		else
		CPrintToChat(client, "%t","MyRank",g_iPlayerRating[client],g_iPlayerWins[client],g_iPlayerLosses[client]);
	} else {
		decl String:argstr[64];
		GetCmdArgString(argstr, sizeof(argstr));
		new targ = FindTarget(0, argstr, false, false);
		
		if(targ == client)
		{
			if(g_bNoDisplayRating)
				CPrintToChat(client, "%t","MyRankNoRating",g_iPlayerWins[client],g_iPlayerLosses[client]);
			else
			CPrintToChat(client, "%t","MyRank",g_iPlayerRating[client],g_iPlayerWins[client],g_iPlayerLosses[client]);
		} else if(targ!=-1) {
			if(g_bNoDisplayRating)
				PrintToChat(client, "\x03%N\x01 has \x04%i\x01 wins and \x04%i\x01 losses. You have a \x04%i%%\x01 chance of beating him.", targ, g_iPlayerWins[targ], g_iPlayerLosses[targ], RoundFloat((1/(Pow(10.0, float((g_iPlayerRating[targ]-g_iPlayerRating[client]))/400)+1))*100));
			else
			PrintToChat(client, "\x03%N\x01's rating is \x04%i\x01. You have a \x04%i%%\x01 chance of beating him.", targ, g_iPlayerRating[targ], RoundFloat((1/(Pow(10.0, float((g_iPlayerRating[targ]-g_iPlayerRating[client]))/400)+1))*100));
		}
	}
	
	return Plugin_Handled;
}

public Action:Command_Help(client, args)
{
	if (!client || !IsValidClient(client))
		return Plugin_Continue;
	
	PrintToChat(client, "%t", "Cmd_SeeConsole");
	PrintToConsole(client, "%t", "\n\n----------------------------");
	PrintToConsole(client, "%t", "Cmd_MGECmds");
	PrintToConsole(client, "%t", "Cmd_MGEMod");
	PrintToConsole(client, "%t", "Cmd_Add");
	PrintToConsole(client, "%t", "Cmd_Remove");
	PrintToConsole(client, "%t", "Cmd_First");
	PrintToConsole(client, "%t", "Cmd_Top5");
	PrintToConsole(client, "%t", "Cmd_Rank");
	PrintToConsole(client, "%t", "Cmd_HitBlip");
	PrintToConsole(client, "%t", "Cmd_Hud");
	PrintToConsole(client, "%t", "----------------------------\n\n");
	
	return Plugin_Handled;
}

public Action:Command_First(client, args)
{
	if (!client || !IsValidClient(client))
		return Plugin_Continue;
	
	// Try to find an arena with one person in the queue..
	for(new i = 1; i <= g_iArenaCount; i++)
	{
		if(!g_iArenaQueue[i][SLOT_TWO] && g_iPlayerArena[client] != i)
		{
			if(g_iArenaQueue[i][SLOT_ONE])
			{
				if(g_iPlayerArena[client])
					RemoveFromQueue(client, true);
				
				AddInQueue(client, i, true);
				return Plugin_Handled;
			}
		}
	}
	
	// Couldn't find an arena with only one person in the queue, so find one with none.
	for(new i = 1; i <= g_iArenaCount; i++)
	{
		if(!g_iArenaQueue[i][SLOT_TWO] && g_iPlayerArena[client] != i)
		{
			if(g_iPlayerArena[client])
				RemoveFromQueue(client, true);
			
			AddInQueue(client, i, true);
			return Plugin_Handled;
		}
	}
	
	// Couldn't find any empty or half-empty arenas, so display the menu.
	ShowMainMenu(client);
	return Plugin_Handled;
}

//blocking sounds
public Action:sound_hook(clients[64], &numClients, String:sample[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	if(StrContains(sample,"pl_fallpain")>=0 && g_bBlockFallDamage)
		return Plugin_Handled;
	
	return Plugin_Continue;
}

// ====[ SQL ]====================================================
PrepareSQL() // Opens the connection to the database, and creates the tables if they dont exist.
{
	decl String:error[256];
	
	if(SQL_CheckConfig(g_sDBConfig))
		db = SQL_Connect(g_sDBConfig, true, error, sizeof(error));
	
	if(db==INVALID_HANDLE)
	{
		LogError("Cant use database config <%s> <Error: %s>, trying SQLite <storage-local>...",g_sDBConfig, error);
		db = SQL_Connect("storage-local", true, error, sizeof(error));
		
		if(db==INVALID_HANDLE)
			SetFailState("Could not connect to database: %s", error);
		else
			LogError("Success, using SQLite <storage-local>",g_sDBConfig, error);
	}
	
	decl String:ident[16];
	SQL_ReadDriver(db, ident, sizeof(ident));
	
	if(StrEqual(ident, "mysql", false))
		g_bUseSQLite = false;
	else if(StrEqual(ident, "sqlite", false))
		g_bUseSQLite = true;
	else
		SetFailState("Invalid database.");
	
	if(g_bUseSQLite)
	{
		SQL_TQuery(db, SQLErrorCheckCallback, "CREATE TABLE IF NOT EXISTS mgemod_players (rating INTEGER, steamid TEXT, name TEXT, wins INTEGER, losses INTEGER, lastplayed INTEGER, hitblip INTEGER)");
		SQL_TQuery(db, SQLErrorCheckCallback, "CREATE TABLE IF NOT EXISTS mgemod_weapons (steamid TEXT, gametime INTEGER, weapon TEXT, hits INTEGER, shots INTEGER, accuracy FLOAT, damage INTEGER, directs INTEGER, airshots INTEGER)");
		SQL_TQuery(db, SQLErrorCheckCallback, "CREATE TABLE IF NOT EXISTS mgemod_duels (winner TEXT, loser TEXT, winnerscore INTEGER, loserscore INTEGER, winlimit INTEGER, gametime INTEGER, mapname TEXT, arenaname TEXT)");
	} else {
		SQL_TQuery(db, SQLErrorCheckCallback, "CREATE TABLE IF NOT EXISTS mgemod_players (steamid VARCHAR(32) NOT NULL, name VARCHAR(64) NOT NULL, rating INT(4) NOT NULL, wins INT(4) NOT NULL, losses INT(4) NOT NULL, lastplayed INT(11) NOT NULL, hitblip INT(2) NOT NULL, hud INT(2) NOT NULL, career VARCHAR(2048) NOT NULL, PRIMARY KEY (steamid)) ENGINE = InnoDB");
		SQL_TQuery(db, SQLErrorCheckCallback, "CREATE TABLE IF NOT EXISTS mgemod_duels (gametime INT(11) NOT NULL, winner VARCHAR(32) NOT NULL, loser VARCHAR(32) NOT NULL,  winnerscore INT(4) NOT NULL, loserscore INT(4) NOT NULL, winnerstats VARCHAR(1024) NOT NULL,  loserstats VARCHAR(1024) NOT NULL, mapname VARCHAR(64) NOT NULL, arenaname VARCHAR(64) NOT NULL, fraglimit INT(4) NOT NULL, PRIMARY KEY (winner, loser, gametime)) ENGINE = InnoDB");
	}
}

public T_SQLQueryOnConnect(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	
	if(hndl==INVALID_HANDLE)
	{
		LogError("T_SQLQueryOnConnect failed: %s", error);
		return;
	} 
	
	if (client < 1 || client > MaxClients || !IsClientConnected(client))
	{
		LogError("T_SQLQueryOnConnect failed: client %d <%s> is invalid.", client, g_sPlayerSteamID[client]);
		return;
	}
	
	decl String:query[512];
	decl String:namesql_dirty[MAX_NAME_LENGTH], String:namesql[(MAX_NAME_LENGTH*2)+1];
	GetClientName(client, namesql_dirty, sizeof(namesql_dirty));
	SQL_EscapeString(db, namesql_dirty, namesql, sizeof(namesql));
	
	if(SQL_FetchRow(hndl))
	{
		g_iPlayerRating[client] = SQL_FetchInt(hndl, 0);
		g_iPlayerWins[client] = SQL_FetchInt(hndl, 1);
		g_iPlayerLosses[client] = SQL_FetchInt(hndl, 2);
		g_bHitBlip[client] = SQL_FetchInt(hndl, 3) ? true : false;
		g_bShowHud[client] = SQL_FetchInt(hndl, 4) ? true : false;
		
		Format(query, sizeof(query), "UPDATE mgemod_players SET name='%s' WHERE steamid='%s'", namesql, g_sPlayerSteamID[client]);
		SQL_TQuery(db, SQLErrorCheckCallback, query);
	} else {
		if(g_bUseSQLite)
		{
			Format(query, sizeof(query), "INSERT INTO mgemod_players VALUES(1600, '%s', '%s', 0, 0, %i, 1)", g_sPlayerSteamID[client], namesql, GetTime());
			SQL_TQuery(db, SQLErrorCheckCallback, query);
		} else {
			Format(query, sizeof(query), "INSERT INTO mgemod_players (steamid, name, rating, wins, losses, lastplayed, hitblip, hud, career) VALUES ('%s', '%s', 1600, 0, 0, %i, 1, 1, 'NONE')", g_sPlayerSteamID[client], namesql, GetTime());
			SQL_TQuery(db, SQLErrorCheckCallback, query);
		}
		
		g_iPlayerRating[client] = 1600;
		g_bHitBlip[client] = false;
	}
}

public T_SQL_Top5(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	
	if(hndl==INVALID_HANDLE)
	{
		LogError("[Top5] Query failed: %s", error);
		return;
	} 
	
	if(client < 1 || client > MaxClients || !IsClientConnected(client))
	{
		LogError("T_SQL_Top5 failed: client %d <%s> is invalid.", client, g_sPlayerSteamID[client]);
		return;
	}
	
	if(SQL_GetRowCount(hndl) == 5)
	{
		new rating[5], String:name[5][MAX_NAME_LENGTH], i = 0;
		
		while(SQL_FetchRow(hndl))
		{
			if(i > 5)
				break;
			
			SQL_FetchString(hndl, 0, name[i], 64);
			rating[i] = SQL_FetchInt(hndl, 1);
			
			i++;
		}
		
		ShowTop5Menu(client, name, rating);	
	} else {
		CPrintToChat(client, "%t", "top5error");
	}
	
}

public T_SQL_Test(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	new client = data;
	
	if(hndl==INVALID_HANDLE)
	{
		LogError("[Test] Query failed: %s", error);
		PrintToChat(client, "[Test] Query failed: %s", error);
		return;
	}
	
	if(client < 1 || client > MaxClients || !IsClientConnected(client))
	{
		LogError("T_SQL_Test failed: client %d <%s> is invalid.", client, g_sPlayerSteamID[client]);
		return;
	}
	
	if(SQL_FetchRow(hndl))
		PrintToChat(client, "\x01Database is \x04Up\x01.");
	else
		PrintToChat(client, "\x01Database is \x04Down\x01.");
}

public SQLErrorCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(!StrEqual("", error))
	{
		LogError("Query failed: %s", error);
		
		if(!g_bNoStats)
		{
			g_bNoStats = true;
			PrintHintTextToAll("%t", "DatabaseDown", g_iReconnectInterval);
			
			// Refresh all huds to get rid of stats display.
			ShowHudToAll();
			
			LogError("Lost connection to database, attempting reconnect in %i minutes.", g_iReconnectInterval);
			
			if(g_hDBReconnectTimer == INVALID_HANDLE)
				g_hDBReconnectTimer = CreateTimer(float(60 * g_iReconnectInterval), Timer_ReconnectToDB, TIMER_FLAG_NO_MAPCHANGE);
		}
		
	}
}

public SQLDbConnTest(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(!StrEqual("", error))
	{
		LogError("Query failed: %s", error);
		LogError("Database reconnect failed, next attempt in %i minutes.", g_iReconnectInterval);
		PrintHintTextToAll("%t", "DatabaseDown", g_iReconnectInterval);
		
		if(g_hDBReconnectTimer == INVALID_HANDLE)
			g_hDBReconnectTimer = CreateTimer(float(60 * g_iReconnectInterval), Timer_ReconnectToDB, TIMER_FLAG_NO_MAPCHANGE);
	} else {
		g_bNoStats = (GetConVarBool(gcvar_stats)) ? false : true;
		
		if(!g_bNoStats)
		{	
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsValidClient(i))
				{
					decl String:steamid_dirty[31];
					decl String:steamid[64];
					GetClientAuthString(i, steamid_dirty, sizeof(steamid_dirty));
					SQL_EscapeString(db, steamid_dirty, steamid, sizeof(steamid));
					decl String:query[256];
					Format(query, sizeof(query), "SELECT rating, wins, losses, hitblip, hud FROM mgemod_players WHERE steamid='%s' LIMIT 1", steamid);
					SQL_TQuery(db, T_SQLQueryOnConnect, query, i);
					strcopy(g_sPlayerSteamID[i],32,steamid);
				}
			}
			
			// Refresh all huds to show stats again.
			ShowHudToAll();
			
			PrintHintTextToAll("%t", "StatsRestored");
		} else {
			PrintHintTextToAll("%t", "StatsRestoredDown");
		}
		
		LogError("Database connection restored.");
	}
}


/*
** ------------------------------------------------------------------
**		______                  __      
**	   / ____/_   _____  ____  / /______
**	  / __/  | | / / _ \/ __ \/ __/ ___/
**	 / /___  | |/ /  __/ / / / /_(__  ) 
**	/_____/  |___/\___/_/ /_/\__/____/  
** 
** ------------------------------------------------------------------
**/

public Event_PlayerSpawn(Handle:event,const String:name[],bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new arena_index = g_iPlayerArena[client];
	
	g_tfctPlayerClass[client] = TF2_GetPlayerClass(client);
	
	ResetClientAmmoCounts(client);
	
	// Equip the player's primary weapon.
	new pri_weap = GetPlayerWeaponSlot(client, 0);
	if(IsValidEntity(pri_weap))
		EquipPlayerWeapon(client, pri_weap);
	
	if(g_iPlayerSlot[client] != SLOT_ONE && g_iPlayerSlot[client] != SLOT_TWO)
		ChangeClientTeam(client, TEAM_SPEC);
	
	if(g_bArenaMGE[arena_index])
	{
		g_iPlayerHP[client] = RoundToNearest(float(g_iPlayerMaxHP[client])*g_fArenaHPRatio[arena_index]);
		ShowSpecHudToArena(arena_index);
	}
	
	if(g_bArenaBBall[arena_index])
		g_bPlayerHasIntel[client] = false;
}

public Event_WinPanel(Handle:event,const String:name[],bool:dontBroadcast)
{
	// Disable stats so people leaving at the end of the map don't lose points.
	g_bNoStats = true;
}

public Action:Event_PlayerHurt(Handle:event,const String:name[],bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(!IsValidClient(victim))
		return Plugin_Continue;
	
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new arena_index = g_iPlayerArena[victim];
	new iDamage = GetEventInt(event, "damageamount");
	
	if (attacker > 0 && victim != attacker) // If the attacker wasn't the person being hurt, or the world (fall damage).
	{
		AddHit(attacker, iDamage);
		
		new bool:shootsRocketsOrPipes = ShootsRocketsOrPipes(attacker);
		if(g_bArenaEndif[arena_index])
		{
			if(shootsRocketsOrPipes)
				CreateTimer(0.01, BoostVectors, GetClientUserId(victim));
		}
		
		
		if(g_iPlayerWeaponIndex[attacker] != -1)
		{		
			// Meatshot detection
			if(g_iWeaponMaxDmg[g_iPlayerWeaponIndex[attacker]] != -1)
			{
				if(iDamage >= RoundToNearest(g_fMeatshotPercent * float(g_iWeaponMaxDmg[g_iPlayerWeaponIndex[attacker]])))
					g_iPlayerDirectHitCount[attacker][g_iPlayerWeaponIndex[attacker]] += 1;
			}
		}
		
		if (g_bPlayerTakenDirectHit[victim])
		{
			new bool:isVictimInAir = !(GetEntityFlags(victim) & (FL_ONGROUND));
			//increment directhit / airshot count for accuracy tracking
			if(g_iPlayerAttackUsedWeaponIdx[attacker] != -1)
			{
				if (g_bWeaponProjectile[g_iPlayerAttackUsedWeaponIdx[attacker]])
				{
					g_iPlayerDirectHitCount[attacker][g_iPlayerAttackUsedWeaponIdx[attacker]] += 1;
					
					if (isVictimInAir && !g_bArenaEndif[arena_index])
					{
						new Float:dist = DistanceAboveGround(victim);
						
						if (dist >= g_iAirshotHeight)
							g_iPlayerAirshotCount[attacker][g_iPlayerAttackUsedWeaponIdx[attacker]] += 1;
					}
				}	
			}
			
			if (!isVictimInAir || g_bArenaMGE[arena_index])
			{	
				if(!g_bArenaMidair[arena_index] && g_bHitBlip[attacker])
				{
					new pitch = 150 - iDamage;
					
					if(pitch<45)
						pitch = 45;
					
					EmitSoundToClient(attacker, "buttons/button17.wav", _, _, _, _, 1.0, pitch);
				}
			} else { //airshot
				new Float:dist = DistanceAboveGround(victim);
				if (dist >= g_iAirshotHeight)
				{
					if (g_bArenaMidair[arena_index])
						g_iPlayerHP[victim] -= 1;
					
					if(g_bArenaEndif[arena_index] && dist >= 250)
					{
						g_iPlayerHP[victim] = -1;
						
						if(g_iPlayerAttackUsedWeaponIdx[attacker] != -1)
							g_iPlayerAirshotCount[attacker][g_iPlayerAttackUsedWeaponIdx[attacker]] += 1;
					}
				}
			}
		}
	}
	
	g_bPlayerTakenDirectHit[victim] = false;
	
	if(g_bArenaMGE[arena_index] || g_bArenaBBall[arena_index])
		g_iPlayerHP[victim] = GetClientHealth(victim);
	else if (g_bArenaAmmomod[arena_index])
		g_iPlayerHP[victim] -= iDamage;
	
	g_bPlayerRestoringAmmo[attacker] = false;		//inf ammo crutch
	
	if(g_bArenaAmmomod[arena_index] || g_bArenaMidair[arena_index] || g_bArenaEndif[arena_index])
	{
		if (g_iPlayerHP[victim] <= 0)
			SetEntityHealth(victim,0);
		else
		SetEntityHealth(victim,g_iPlayerMaxHP[victim]);
	}
	
	ShowPlayerHud(victim);
	ShowPlayerHud(attacker);
	ShowSpecHudToArena(g_iPlayerArena[victim]);
	
	return Plugin_Continue;
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new arena_index = g_iPlayerArena[victim];
	
	RemoveClientParticle(victim);
	
	if (!arena_index)
		ChangeClientTeam(victim, TEAM_SPEC);
	
	if (g_iArenaStatus[arena_index]<AS_FIGHT || g_iArenaStatus[arena_index]>AS_FIGHT)
	{
		CreateTimer(0.1,Timer_ResetPlayer,GetClientUserId(victim));
		return Plugin_Handled;
	}
	
	new victim_slot = g_iPlayerSlot[victim];
	new killer_slot = (victim_slot==SLOT_ONE) ? SLOT_TWO : SLOT_ONE;
	new killer = g_iArenaQueue[arena_index][killer_slot];
	
	
	if (!IsPlayerAlive(killer))
	{
		if(g_bArenaAmmomod[arena_index] || g_bArenaMidair[arena_index])
			return Plugin_Handled;
	}
	
	if (!g_bArenaBBall[arena_index])	// Kills shouldn't give points in bball.
		g_iArenaScore[arena_index][killer_slot] += 1;
	
	if(!g_bArenaEndif[arena_index])		// Endif does not need to display health, since it is one-shot kills.
	{
		if(IsPlayerAlive(killer))
		{
			if(g_bArenaMGE[arena_index] || g_bArenaBBall[arena_index])
				CPrintToChat(victim, "%t", "HPLeft", GetClientHealth(killer));
			else
			CPrintToChat(victim, "%t", "HPLeft", g_iPlayerHP[killer]);
		}
	}
	
	if(g_bArenaAmmomod[arena_index] || g_bArenaMidair[arena_index])	
		g_iArenaStatus[arena_index] = AS_AFTERFIGHT;
	
	new fraglimit = g_iArenaFraglimit[arena_index];
	
	if (g_iArenaStatus[arena_index] >= AS_FIGHT && g_iArenaStatus[arena_index] < AS_REPORTED && fraglimit > 0 && g_iArenaScore[arena_index][killer_slot] >= fraglimit)
	{
		g_iArenaStatus[arena_index] = AS_REPORTED;
		new String:killer_name[128];
		new String:victim_name[128];
		GetClientName(killer,killer_name, sizeof(killer_name));
		GetClientName(victim,victim_name, sizeof(victim_name));
		CPrintToChatAll("%t","XdefeatsY", killer_name, g_iArenaScore[arena_index][killer_slot], victim_name, g_iArenaScore[arena_index][victim_slot], fraglimit, g_sArenaName[arena_index]);
		
		if(g_iPlayerAttackUsedWeaponIdx[killer] != -1)
		{
			if(!g_bWeaponProjectile[g_iPlayerAttackUsedWeaponIdx[killer]]) // Hitscan-only workaround
			{
				g_iPlayerShotCount[killer][g_iPlayerAttackUsedWeaponIdx[killer]] += 1;
			}
		}
		
		if (!g_bNoStats)
			CalcELO(killer,victim);
		
		if (g_iArenaQueue[arena_index][SLOT_TWO+1])
		{
			RemoveFromQueue(victim,false,true);
			AddInQueue(victim,arena_index,false);
		} else {
			CreateTimer(3.0,Timer_StartDuel,arena_index);
		}
	} else if(g_bArenaAmmomod[arena_index] || g_bArenaMidair[arena_index]) {
		CreateTimer(3.0,Timer_NewRound,arena_index);
	} else {
		if(g_bArenaBBall[arena_index])
		{
			if (g_bPlayerHasIntel[victim])
			{
				g_bPlayerHasIntel[victim] = false;
				
				new Float:pos[3];
				GetClientAbsOrigin(victim, pos);
				pos[2] = g_fArenaSpawnOrigin[arena_index][g_iArenaSpawns[arena_index]-3][2];
				
				if (g_iBBallIntel[arena_index] == -1)
					g_iBBallIntel[arena_index] = CreateEntityByName("item_ammopack_small");
				else
				LogError("[%s] Player died with intel, but intel [%i] already exists.", g_sArenaName[arena_index], g_iBBallIntel[arena_index]);
				
				TeleportEntity(g_iBBallIntel[arena_index], pos, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(g_iBBallIntel[arena_index]);
				SetEntProp(g_iBBallIntel[arena_index], Prop_Send, "m_iTeamNum", 1, 4);
				SetEntityModel(g_iBBallIntel[arena_index], MODEL_BRIEFCASE);
				SDKUnhook(g_iBBallIntel[arena_index], SDKHook_StartTouch, OnTouchIntel);
				SDKHook(g_iBBallIntel[arena_index], SDKHook_StartTouch, OnTouchIntel);
				AcceptEntityInput(g_iBBallIntel[arena_index], "Enable");
				
				EmitSoundToClient(victim, "vo/intel_teamdropped.wav");
				if(IsValidClient(killer))
					EmitSoundToClient(killer, "vo/intel_enemydropped.wav");
			}
		} else {
			if(g_bArenaMGE[arena_index] && g_iPlayerWeaponIndex[killer] != -1)
			{
				if(!g_bWeaponProjectile[g_iPlayerWeaponIndex[killer]]) // Hitscan-only workaround
				{
					g_iPlayerShotCount[killer][g_iPlayerWeaponIndex[killer]] += 1;
				}
			}
			
			TF2_RegeneratePlayer(killer);
			new raised_hp = RoundToNearest(float(g_iPlayerMaxHP[killer])*g_fArenaHPRatio[arena_index]);
			g_iPlayerHP[killer] = raised_hp;
			SetEntProp(killer, Prop_Data, "m_iHealth", raised_hp);
		}
		
		CreateTimer(g_fArenaRespawnTime[arena_index],Timer_ResetPlayer,GetClientUserId(victim));
	}
	
	ShowPlayerHud(victim); 
	ShowPlayerHud(killer);
	ShowSpecHudToArena(arena_index);
	
	return Plugin_Continue;
}

public Action:Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"userid"));
	
	if (!client)
		return Plugin_Continue;
	
	new team = GetEventInt(event,"team");
	
	if (team == TEAM_SPEC)
	{
		HideHud(client);
		CreateTimer(1.0, Timer_ChangeSpecTarget, GetClientUserId(client));
		new arena_index = g_iPlayerArena[client];
		
		if (arena_index && g_iPlayerSlot[client] <= SLOT_TWO)
		{
			CPrintToChat(client,"%t","SpecRemove");
			RemoveFromQueue(client);
		}
	} else if (IsValidClient(client)) { // this code fixing spawn exploit
		new arena_index = g_iPlayerArena[client];
		
		if (arena_index == 0)
		{
			TF2_SetPlayerClass(client,TFClassType:0);
		}
	}
	
	SetEventInt(event, "silent", true);
	return Plugin_Changed;
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	SetConVarInt(gcvar_WfP,1); //cancel waiting for players
	
	for (new i = 0;i<=g_iArenaCount;i++)
	{
		if(g_bArenaBBall[i])
		{
			new Float:hoop_2_loc[3];
			hoop_2_loc[0] = g_fArenaSpawnOrigin[i][g_iArenaSpawns[i]][0];
			hoop_2_loc[1] = g_fArenaSpawnOrigin[i][g_iArenaSpawns[i]][1];
			hoop_2_loc[2] = g_fArenaSpawnOrigin[i][g_iArenaSpawns[i]][2];
			new Float:hoop_1_loc[3];
			hoop_1_loc[0] = g_fArenaSpawnOrigin[i][g_iArenaSpawns[i]-1][0];
			hoop_1_loc[1] = g_fArenaSpawnOrigin[i][g_iArenaSpawns[i]-1][1];
			hoop_1_loc[2] = g_fArenaSpawnOrigin[i][g_iArenaSpawns[i]-1][2];
			
			if(IsValidEdict(g_iBBallHoop[i][SLOT_ONE]) && g_iBBallHoop[i][SLOT_ONE] > 0)
			{
				RemoveEdict(g_iBBallHoop[i][SLOT_ONE]);
				g_iBBallHoop[i][SLOT_ONE] = -1;
			} else if(g_iBBallHoop[i][SLOT_ONE] != -1) { // g_iBBallHoop[i][SLOT_ONE] equaling -1 is not a bad thing, so don't print an error for it.
				//LogError("[%s] Event_RoundStart fired, but could not remove old hoop [%d]!.", g_sArenaName[i], g_iBBallHoop[i][SLOT_ONE]);
				//LogError("[%s] Resetting SLOT_ONE hoop array index %i.", g_sArenaName[i], i);
				g_iBBallHoop[i][SLOT_ONE] = -1;
			}
			
			if(IsValidEdict(g_iBBallHoop[i][SLOT_TWO]) && g_iBBallHoop[i][SLOT_TWO] > 0)
			{
				RemoveEdict(g_iBBallHoop[i][SLOT_TWO]);
				g_iBBallHoop[i][SLOT_TWO] = -1;
			} else if(g_iBBallHoop[i][SLOT_TWO] != -1) { // g_iBBallHoop[i][SLOT_TWO] equaling -1 is not a bad thing, so don't print an error for it.
				//LogError("[%s] Event_RoundStart fired, but could not remove old hoop [%d]!.", g_sArenaName[i], g_iBBallHoop[i][SLOT_TWO]);
				//LogError("[%s] Resetting SLOT_TWO hoop array index %i.", g_sArenaName[i], i);
				g_iBBallHoop[i][SLOT_TWO] = -1;
			}
			
			if (g_iBBallHoop[i][SLOT_ONE] == -1)
			{
				g_iBBallHoop[i][SLOT_ONE] = CreateEntityByName("item_ammopack_small");
				TeleportEntity(g_iBBallHoop[i][SLOT_ONE], hoop_1_loc, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(g_iBBallHoop[i][SLOT_ONE]);
				SetEntProp(g_iBBallHoop[i][SLOT_ONE], Prop_Send, "m_iTeamNum", 1, 4);
				
				SDKUnhook(g_iBBallHoop[i][SLOT_ONE], SDKHook_StartTouch, OnTouchHoop);
				SDKHook(g_iBBallHoop[i][SLOT_ONE], SDKHook_StartTouch, OnTouchHoop);
			}
			
			if (g_iBBallHoop[i][SLOT_TWO] == -1)
			{
				g_iBBallHoop[i][SLOT_TWO] = CreateEntityByName("item_ammopack_small");
				TeleportEntity(g_iBBallHoop[i][SLOT_TWO], hoop_2_loc, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(g_iBBallHoop[i][SLOT_TWO]);
				SetEntProp(g_iBBallHoop[i][SLOT_TWO], Prop_Send, "m_iTeamNum", 1, 4);
				
				SDKUnhook(g_iBBallHoop[i][SLOT_TWO], SDKHook_StartTouch, OnTouchHoop);
				SDKHook(g_iBBallHoop[i][SLOT_TWO], SDKHook_StartTouch, OnTouchHoop);
			}
			
			if(g_bVisibleHoops[i] == false)
			{
				// Could have used SetRenderMode here, but it had the unfortunate side-effect of also making the intel invisible.
				// Luckily, inputting "Disable" to most entities makes them invisible, so it was a valid workaround.
				AcceptEntityInput(g_iBBallHoop[i][SLOT_ONE], "Disable");
				AcceptEntityInput(g_iBBallHoop[i][SLOT_TWO], "Disable");
			}
		}
	}
	
	return Plugin_Continue;
}

/*
** ------------------------------------------------------------------
**	 _______                          
**	 /_  __(_)____ ___  ___  __________
**	  / / / // __ `__ \/ _ \/ ___/ ___/
**	 / / / // / / / / /  __/ /  (__  ) 
**	/_/ /_//_/ /_/ /_/\___/_/  /____/  
**	
** ------------------------------------------------------------------
**/

public Action:Timer_WelcomePlayer(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	
	CPrintToChat(client, "%t", "Welcome1");
	if(StrContains(g_sMapName, "mge_", false) == 0)
		CPrintToChat(client, "%t", "Welcome2");
	CPrintToChat(client, "%t", "Welcome3");
	g_hWelcomeTimer[client] = INVALID_HANDLE;
}

public Action:Timer_SpecFix(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if(!IsValidClient(client))
		return;
	
	ChangeClientTeam(client, TEAM_RED);
	ChangeClientTeam(client, TEAM_SPEC);
}

public Action:Timer_SpecHudToAllArenas(Handle:timer, any:userid)
{	
	for(new i = 1; i <= g_iArenaCount; i++)
		ShowSpecHudToArena(i);
	
	return Plugin_Continue;
}

public Action:Timer_ResetIntel(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	new arena_index = g_iPlayerArena[client];
	
	ResetIntel(arena_index, client);
}

public Action:Timer_CountDown(Handle:timer, any:arena_index)
{
	new red_f1 = g_iArenaQueue[arena_index][SLOT_ONE];
	new blu_f1 = g_iArenaQueue[arena_index][SLOT_TWO];
	
	if (red_f1 && blu_f1)
	{
		g_iArenaCd[arena_index]--;
		
		if (g_iArenaCd[arena_index]>0)
		{ // blocking +attack
			new Float:enginetime = GetGameTime();
			
			for (new i=0;i<=2;i++)
			{
				new ent = GetPlayerWeaponSlot(red_f1, i);
				
				if(IsValidEntity(ent))
					SetEntPropFloat(ent, Prop_Send, "m_flNextPrimaryAttack", enginetime+float(g_iArenaCd[arena_index]));
				
				ent = GetPlayerWeaponSlot(blu_f1, i);
				
				if(IsValidEntity(ent))
					SetEntPropFloat(ent, Prop_Send, "m_flNextPrimaryAttack", enginetime+float(g_iArenaCd[arena_index]));
			}
		}
		
		if (g_iArenaCd[arena_index] <= 3 && g_iArenaCd[arena_index] >= 1)
		{
			new String:msg[64];
			
			switch (g_iArenaCd[arena_index])
			{
				case 1: msg = "ONE";
				case 2: msg = "TWO";
				case 3: msg = "THREE";
			}
			
			PrintCenterText(red_f1,msg);
			PrintCenterText(blu_f1,msg);
			ShowCountdownToSpec(arena_index,msg);
			g_iArenaStatus[arena_index] = AS_COUNTDOWN;
		} else if (g_iArenaCd[arena_index] <= 0) {
			g_iArenaStatus[arena_index] = AS_FIGHT;
			new String:msg[64];
			Format(msg,sizeof(msg),"FIGHT",g_iArenaCd[arena_index]);
			PrintCenterText(red_f1,msg);
			PrintCenterText(blu_f1,msg);
			ShowCountdownToSpec(arena_index,msg);
			
			//For bball.
			if(g_bArenaBBall[arena_index])
			{
				ResetIntel(arena_index);
			}
			
			return Plugin_Stop;
		}
		
		CreateTimer(1.0,Timer_CountDown,arena_index,TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Stop;	
	} else {
		g_iArenaStatus[arena_index] = AS_IDLE;
		g_iArenaCd[arena_index] = 0;
		return Plugin_Stop;	
	}
}

public Action:Timer_Tele(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	new arena_index = g_iPlayerArena[client];
	
	if (!arena_index)
		return;
	
	new player_slot = g_iPlayerSlot[client];
	
	if (player_slot>SLOT_TWO)
	{
		return;
	}
	
	g_bPlayerApplyQuickShot[client] = true;
	
	new Float:vel[3]={0.0,0.0,0.0};
	
	// BBall handles spawns differently, each team (or rather, SLOT), has their own spawns.
	if(g_bArenaBBall[arena_index])
	{
		new random_int;
		new offset_high, offset_low;
		if(g_iPlayerSlot[client] == SLOT_ONE)
		{
			offset_high = ((g_iArenaSpawns[arena_index] - 5) / 2);
			random_int = GetRandomInt(1, offset_high); //The first half of the player spawns are for slot one.
		} else {
			offset_high = (g_iArenaSpawns[arena_index] - 5);
			offset_low = (((g_iArenaSpawns[arena_index] - 5) / 2) + 1);
			random_int = GetRandomInt(offset_low, offset_high); //The last 5 spawns are for the intel and trigger spawns, not players.
		}
		
		TeleportEntity(client,g_fArenaSpawnOrigin[arena_index][random_int],g_fArenaSpawnAngles[arena_index][random_int],vel);
		EmitAmbientSound("items/spawn_item.wav", g_fArenaSpawnOrigin[arena_index][random_int], _, SNDLEVEL_NORMAL, _, 1.0);
		ShowPlayerHud(client);
		return;
	}
	
	// Create an array that can hold all the arena's spawns.
	new RandomSpawn[g_iArenaSpawns[arena_index]+1];
	
	// Fill the array with the spawns.
	for(new i = 1; i <= g_iArenaSpawns[arena_index]; i++)
		RandomSpawn[i] = i;
	
	// Shuffle them into a random order.
	SortIntegers(RandomSpawn, g_iArenaSpawns[arena_index], Sort_Random);
	
	// Now when the array is gone through sequentially, it will still provide a random spawn.
	new Float:besteffort_dist;
	new besteffort_spawn;
	for(new i = 1; i <= g_iArenaSpawns[arena_index]; i++)
	{
		new client_slot = g_iPlayerSlot[client];
		new foe_slot = (client_slot==SLOT_ONE) ? SLOT_TWO : SLOT_ONE;
		if(foe_slot)
		{
			new Float:distance;
			new foe = g_iArenaQueue[arena_index][foe_slot];
			if(IsValidClient(foe))
			{
				new Float:foe_pos[3];
				GetClientAbsOrigin(foe, foe_pos);
				distance = GetVectorDistance(foe_pos, g_fArenaSpawnOrigin[arena_index][RandomSpawn[i]]);
				if(distance > g_fArenaMinSpawnDist[arena_index])
				{
					TeleportEntity(client,g_fArenaSpawnOrigin[arena_index][RandomSpawn[i]],g_fArenaSpawnAngles[arena_index][RandomSpawn[i]],vel);
					EmitAmbientSound("items/spawn_item.wav", g_fArenaSpawnOrigin[arena_index][RandomSpawn[i]], _, SNDLEVEL_NORMAL, _, 1.0);
					ShowPlayerHud(client);
					return;
				} else if(distance > besteffort_dist){
					besteffort_dist = distance;
					besteffort_spawn = i;
				}
			}
		}
	}
	
	if(besteffort_spawn)
	{
		// Couldn't find a spawn that was far enough away, so use the one that was the farthest.
		TeleportEntity(client,g_fArenaSpawnOrigin[arena_index][besteffort_spawn],g_fArenaSpawnAngles[arena_index][besteffort_spawn],vel);
		EmitAmbientSound("items/spawn_item.wav", g_fArenaSpawnOrigin[arena_index][besteffort_spawn], _, SNDLEVEL_NORMAL, _, 1.0);
		ShowPlayerHud(client);
		return;
	} else {
		// No foe, so just pick a random spawn.
		new random_int = GetRandomInt(1, g_iArenaSpawns[arena_index]);
		TeleportEntity(client,g_fArenaSpawnOrigin[arena_index][random_int],g_fArenaSpawnAngles[arena_index][random_int],vel);
		EmitAmbientSound("items/spawn_item.wav", g_fArenaSpawnOrigin[arena_index][random_int], _, SNDLEVEL_NORMAL, _, 1.0);
		ShowPlayerHud(client);
		return;
	}
}

public Action:Timer_NewRound(Handle:timer, any:arena_index)
{
	StartCountDown(arena_index);
}

public Action:Timer_StartDuel(Handle:timer, any:arena_index)
{
	g_iArenaScore[arena_index][SLOT_ONE] = 0;
	g_iArenaScore[arena_index][SLOT_TWO] = 0;
	ShowPlayerHud(g_iArenaQueue[arena_index][SLOT_ONE]);
	ShowPlayerHud(g_iArenaQueue[arena_index][SLOT_TWO]);
	ShowSpecHudToArena(arena_index);	
	StartCountDown(arena_index);
}

public Action:Timer_ResetPlayer(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	
	if (IsValidClient(client))	
		ResetPlayer(client);
}

public Action:Timer_ChangeSpecTarget(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	
	if (!client || !IsValidClient(client))
		return Plugin_Stop;
	
	new target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	
	if (IsValidClient(target) && g_iPlayerArena[target]){
		g_iPlayerSpecTarget[client] = target;
		ShowSpecHudToClient(client);
	} else {
		HideHud(client);
		g_iPlayerSpecTarget[client] = 0;
	}
	
	return Plugin_Stop;
}

public Action:Timer_ShowAdv(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	
	if (IsValidClient(client) && g_iPlayerArena[client]==0)
	{
		CPrintToChat(client,"%t","Adv");
		CreateTimer(15.0, Timer_ShowAdv, userid);
	}
	
	return Plugin_Continue;
}

public Action:Timer_GiveAmmo(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (!client || !IsValidEntity(client))
		return;
	
	g_bPlayerRestoringAmmo[client] = false;
	
	new weapon;
	
	if (g_iPlayerClip[client][SLOT_ONE] != -1)
	{
		weapon = GetPlayerWeaponSlot(client, 0);
		
		if (IsValidEntity(weapon))
			SetEntProp(weapon, Prop_Send, "m_iClip1", g_iPlayerClip[client][SLOT_ONE]);
	}
	
	if (g_iPlayerClip[client][SLOT_TWO] != -1)
	{
		weapon = GetPlayerWeaponSlot(client, 1);
		
		if (IsValidEntity(weapon))
			SetEntProp(weapon, Prop_Send, "m_iClip1", g_iPlayerClip[client][SLOT_TWO]);
	}
}

public Action:Timer_DeleteParticle(Handle:timer, any:particle)
{
	if (IsValidEdict(particle))
	{
		new String:classname[64];
		GetEdictClassname(particle, classname, sizeof(classname));
		
		if (StrEqual(classname, "info_particle_system", false))
		{
			RemoveEdict(particle);
		}
	}
}

public Action:Timer_AddBotInQueue(Handle:timer, Handle:pk)
{
	ResetPack(pk);
	new client = GetClientOfUserId(ReadPackCell(pk));
	new arena_index = ReadPackCell(pk);
	AddInQueue(client,arena_index);
}

public Action:Timer_ReconnectToDB(Handle:timer)
{
	g_hDBReconnectTimer = INVALID_HANDLE;
	
	decl String:query[256];
	Format(query, sizeof(query), "SELECT rating FROM mgemod_players LIMIT 1");
	SQL_TQuery(db, SQLDbConnTest, query);
}

/*
** ------------------------------------------------------------------
**		__  ____           
**	   /  |/  (_)__________
**	  / /|_/ / // ___/ ___/
**	 / /  / / /(__  ) /__  
**	/_/  /_/_//____/\___/  
**						   
** ------------------------------------------------------------------
**/

/* TraceEntityFilterPlayer()
*
* Ignores players.
* -------------------------------------------------------------------------- */
public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > MaxClients || !entity;
}

/* TraceEntityPlayersOnly()
*
* Returns only players.
* -------------------------------------------------------------------------- */
public bool:TraceEntityPlayersOnly(entity, mask, any:client)
{
	if (IsValidClient(entity) && entity != client)
	{
		PrintToChatAll("returning true for %d<%N>", entity, entity);
		return true;
	} else {
		PrintToChatAll("returning false for %d<%N>", entity, entity);
		return false;
	}
}

/* IsValidClient()
*
* Checks if a client is valid.
* -------------------------------------------------------------------------- */
bool:IsValidClient(iClient)
{
	if(iClient < 1 || iClient > MaxClients)
		return false;
	if(!IsClientConnected(iClient))
		return false;
	if(IsClientInKickQueue(iClient))
		return false;
	return IsClientInGame(iClient);
}

/* ShootsRocketsOrPipes()
*
* Does this player's gun shoot rockets or pipes? 
* -------------------------------------------------------------------------- */
bool:ShootsRocketsOrPipes(client)
{
	decl String:weapon[64];
	GetClientWeapon(client, weapon, sizeof(weapon));
	return (StrContains(weapon, "tf_weapon_rocketlauncher") == 0)|| StrEqual(weapon, "tf_weapon_grenadelauncher");
}

/* DistanceAboveGround()
*
* How high off the ground is the player?
* -------------------------------------------------------------------------- */
Float:DistanceAboveGround(victim)
{
	decl Float:vStart[3];
	decl Float:vEnd[3];
	new Float:vAngles[3]={90.0,0.0,0.0};
	GetClientAbsOrigin(victim,vStart);
	new Handle:trace = TR_TraceRayFilterEx(vStart, vAngles, MASK_SHOT, RayType_Infinite,TraceEntityFilterPlayer);
	
	new Float:distance = -1.0;
	if(TR_DidHit(trace))
	{   	 
		TR_GetEndPosition(vEnd, trace);
		distance = GetVectorDistance(vStart, vEnd, false);
	} else  {
		LogError("trace error. victim %N(%d)",victim,victim);
	}
	
	CloseHandle(trace);
	return distance;
}

/* FindEntityByClassname2()
*
* Finds entites, and won't error out when searching invalid entities.
* -------------------------------------------------------------------------- */
stock FindEntityByClassname2(startEnt, const String:classname[])
{
	/* If startEnt isn't valid shifting it back to the nearest valid one */
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
		
	return FindEntityByClassname(startEnt, classname);
}