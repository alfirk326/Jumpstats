#include <sourcemod>
#include <sdktools>
#define MAX_TICKS 20


new bool:g_sEnable[MAXPLAYERS+1];
new bool:g_cEnable[MAXPLAYERS+1];
new g_iTicks[MAXPLAYERS+1];
new String:sWeapon[MAXPLAYERS+1][64];


public OnPluginStart()
{
	RegConsoleCmd("sm_f", Command_Jumpstats, "jumpstats");
}


public Action:Command_Jumpstats(client, args)
{
	if(g_sEnable[client])
	{
		g_sEnable[client]=false;
		PrintToChat(client, "점프 타이밍 측정을 비활성화 합니다.");
	}
	else
	{
		g_sEnable[client]=true;
		PrintToChat(client, "점프 타이밍을 측정합니다.");
	}
}

public OnClientPutInServer(client)
{
	g_sEnable[client] = false;
	PrintToChat(client, "\x05type !f to enable jumpstats.");
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if(g_sEnable[client] && IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client))
	{
		if(g_iTicks[client] >= MAX_TICKS)
		{
			g_iTicks[client] = 0;
			g_cEnable[client] = false;
		}
	
		if(!(GetEntityFlags(client) & FL_ONGROUND) && g_cEnable[client] == false)
		{
			return Plugin_Continue;
		}
		
		if((buttons & IN_JUMP) && (g_cEnable[client] == false))
		{
			return Plugin_Continue;
		}
	
		GetClientWeapon(client, sWeapon[client], 64);
		
		if (buttons & IN_ATTACK && StrEqual(sWeapon[client], "weapon_flashbang"))
		{
			g_iTicks[client] = 0;
			g_cEnable[client] = true;
		}
		
		if(!(buttons & IN_ATTACK) && g_cEnable[client] == true)
		{
			if(buttons & IN_JUMP)
			{
				g_cEnable[client] = false;
				PrintToChat(client, "%dms", g_iTicks[client] * 10); // 100tick/1s = 1tick/0.01s = 1tick/10ms
				return Plugin_Continue;
			}
			g_iTicks[client]++;
		}
	}
	return Plugin_Continue;
}
