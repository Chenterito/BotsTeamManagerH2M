/*
*
*	 Creator : Kalitos
*	 Project : monitosBotsTeams
*    Mode : Multiplayer
*	 Date : 2024/08/28 - 11:22:19	
*
*/	

#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\bots\_bots;


init()
{	
	SetDvarIfNotInizialized("bots_manage_add", 10);
	SetDvarIfNotInizialized("bots_manage_fill", 10);
    SetDvarIfNotInizialized("bots_manage_mode", 0); //1 to assign allies and axis || 0 to autoassign
    SetDvarIfNotInizialized("bots_team_allies", 5);
	SetDvarIfNotInizialized("bots_team_axis", 5);
    initBotNames(); // define names to bots
    level.difficultyBotsList = [ "recruit", "hardened" , "veteran" ]; // Add or remove "regular", "recruit", "hardened" , "veteran"
	thread monitorBots();
	thread onPlayerConnect();
	printLn("Script Loaded: BotManager");
}

monitorBots()
{
	level endon("game_ended");

	//level waittill("matchStartTimer");
    level waittill("prematch_over");
	
	level.botsToAdd = getdvarint("bots_manage_add");
	level.botsToFill = getdvarint("bots_manage_fill");
    level.botsManageMode = getdvarint("bots_manage_mode");
    level.botsAddtoAllies = getdvarint("bots_team_allies");
    level.botsAddtoAxis = getdvarint("bots_team_axis");

/*     if(!level.teambased) // If it's not team game mode
    {
        level.botsManageMode = 0;
        setdvar("bots_manage_mode", 0);
    }
    else
    {
        level.botsManageMode = 1;
        setdvar("bots_manage_mode", 1);
    }  */  

	if(level.botsToAdd > 17)
		level.botsToAdd = 17;
    
    if(level.botsToFill > 17)
		level.botsToFill = 17;

    if(level.botsAddtoAllies > 8)
		level.botsAddtoAllies = 8;

    if(level.botsAddtoAxis > 8)
		level.botsAddtoAxis = 8;

    if(level.botsManageMode)
    {
        setdvar("scr_teambalance","0");
    }
    else
    {
        setdvar("scr_teambalance","1");
    }
	
	if (level.botsToAdd > 0 )
	{
		if(!level.botsManageMode)
        {
            for ( i = 0; i < level.botsToAdd; i++ )
            {
                addmfbot(1, "autoassign");
                logprint("Autoassign \n");
                wait 1;	
            }
            wait 1;
            level thread teamBots();
        }
        else
        {
            for ( i = 0; i < level.botsAddtoAllies; i++ )
            {
                addmfbot(1, "allies");
                logprint("allies \n");
                wait 1;	
            }
            for ( i = 0; i < level.botsAddtoAxis; i++ )
            {
                addmfbot(1, "axis");
                logprint("axis \n");
                wait 1;	
            } 
            wait 1;
            level thread modeBots();
        }
	}
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);
        if(isBot(player))
        {
            player maps\mp\bots\_bots_util::bot_set_difficulty( random( level.difficultyBotsList ), undefined );
            player thread kickLeftoverBot();
        }
		else
		{
			player waittill("spawned_player");
            if(!level.botsManageMode)
            {
                kickBot();
            }
            else
            {
                kickBotTeam(player.team);
            }
        }
    }
}

onPlayerSpawned()
{
    self endon("disconnect");
	level endon("game_ended");
    for(;;)
    {
        self waittill("spawned_player");		
    }
}


kickLeftoverBot()
{
    self endon("spawned_player");
    wait 10;
    kick(self getentitynumber());

}

botCount()
{
    count = 0;
	for( i = 0; i < level.players.size; i++)
	{
		if(isbot(level.players[i]))
		{
			count++;
		}			
	}
	return count;
}

playerCount()
{
    count = 0;
	for( i = 0; i < level.players.size; i++)
	{
		if(!isbot(level.players[i]))
		{
			count++;
		}			
	}
	return count;
}

/////////////////

botCountAllies()
{
    count = 0;
	for( i = 0; i < level.players.size; i++)
	{
		if(isbot(level.players[i]) && level.players[i].team == "allies")
		{
			count++;
		}			
	}
	return count;
}

playerCountAllies()
{
    count = 0;
	for( i = 0; i < level.players.size; i++)
	{
		if(!isbot(level.players[i]) && (level.players[i].team == "allies"))
		{
			count++;
		}			
	}
	return count;
}

/////////////////

botCountAxis()
{
    count = 0;
	for( i = 0; i < level.players.size; i++)
	{
		if(isbot(level.players[i]) && level.players[i].team == "axis")
		{
			count++;
		}			
	}
	return count;
}

playerCountAxis()
{
    count = 0;
	for( i = 0; i < level.players.size; i++)
	{
		if(!isbot(level.players[i]) && (level.players[i].team == "axis"))
		{
			count++;
		}			
	}
	return count;
}

////////////////

kickBot()
{
	for( i = 0; i < level.players.size; i++)
	{
		if(isbot(level.players[i]))
		{
			kick(level.players[i] getentitynumber());
			break;
		}			
	}

}

kickBotTeam(t)
{
	for( i = 0; i < level.players.size; i++)
	{
		if(isbot(level.players[i]) && level.players[i].team == t)
		{
			kick(level.players[i] getentitynumber());
			break;
		}			
	}

}

spawnBotswrapper(a,t)
{
    spawn_bots(a, t);
}

SetDvarIfNotInizialized(dvar, value)
{
	if (!IsInizialized(dvar))
		setDvar(dvar, value);
}

IsInizialized(dvar)
{
	result = getDvar(dvar);
	return result != "";
} 

teamBots_loop()
{
	toTeam = "";
	alliesbots = 0;
	alliesplayers = 0;
	axisbots = 0;
	axisplayers = 0;
	alliesbotsArray = [];
	axisbotsArray = [];
	botToChange = undefined;

	playercount = level.players.size;

	for ( i = 0; i < playercount; i++ )
	{
		player = level.players[ i ];

		if ( !isdefined( player.pers[ "team" ] ) )
		{
			continue;
		}

		if (  isBot(player) )
		{
			if ( player.pers[ "team" ] == "allies" )
			{
				alliesbots++;
				alliesbotsArray[alliesbotsArray.size] = player;
			}
			else if ( player.pers[ "team" ] == "axis" )
			{
				axisbots++;
				axisbotsArray[axisbotsArray.size] = player;
			}
		}
		else
		{
			if ( player.pers[ "team" ] == "allies" )
			{
				alliesplayers++;
			}
			else if ( player.pers[ "team" ] == "axis" )
			{
				axisplayers++;
			}
		}
	}

	allies = alliesbots + alliesplayers;
	axis = axisbots + axisplayers;

	if ( ( axis - allies ) > 1 )
		toTeam = "allies";
	
	if ( ( allies - axis ) > 1 )
		toTeam = "axis";

	if( toTeam == "allies")
	{
		if(axisbots > 0)
		{
			for ( i = 0; i < axisbotsArray.size; i++ )
			{
				if ( !isdefined( botToChange ) )
                {
                    botToChange = axisbotsArray[i];
                    continue;
                }

                if ( axisbotsArray[i].pers["score"] < botToChange.pers["score"] )
                    botToChange = axisbotsArray[i];
			}
			
			botToChange [[ level.onteamselection ]]( "allies" );
		}
	}
	else if( toTeam == "axis")
	{
		if(alliesbots > 0)
		{
			for ( i = 0; i < alliesbotsArray.size; i++ )
			{
				if ( !isdefined( botToChange ) )
                {
                    botToChange = alliesbotsArray[i];
                    continue;
                }

                if ( alliesbotsArray[i].pers["score"] < botToChange.pers["score"] )
                    botToChange = alliesbotsArray[i];
			}

			botToChange [[ level.onteamselection ]]( "axis" );
		}
	}
}

/*
	A server thread for monitoring all bot's teams for custom server settings.
*/
teamBots()
{
	level endon("game_ended");
    if(level.teambased)
    {
        for ( ;; )
        {
            while(botCount() + playerCount() < level.botsToFill)
            {
                addmfbot(1, "autoassign");
                wait 1;			
            }

            wait 1;

            if( botCount() + playerCount() > level.botsToFill && botCount() > 0)
                kickBot();

            wait 1.5;
            teamBots_loop();
        }
    }
    else
    {
        for(;;)
        {
            while(botCount() + playerCount() < level.botsToFill)
            {
                addmfbot(1, "autoassign");
                wait 1;			
            }

            wait 1;

            if( botCount() + playerCount() > level.botsToFill && botCount() > 0)
                kickBot();
        }
    }	
}

modeBots()
{
    level endon("game_ended");
    for(;;)
    {
        while(botCountAllies() + playerCountAllies() < level.botsAddtoAllies)
        {
            addmfbot(1, "allies");
            wait 1;			
        }

        wait 1;

        if( botCountAllies() + playerCountAllies() > level.botsAddtoAllies && botCountAllies() > 0)
            kickBotTeam("allies");

        while(botCountAxis() + playerCountAxis() < level.botsAddtoAxis)
        {
            addmfbot(1, "axis");;
            wait 1;			
        }

        wait 1;

        if( botCountAxis() + playerCountAxis() > level.botsAddtoAxis && botCountAxis() > 0)
            kickBotTeam("axis");
    }
}

set_team(team)
{
    if (team != self.pers["team"])
    {
        self.switching_teams = true;
        self.joining_team = team;
        self.leaving_team = self.pers["team"];
    }

    if (self.sessionstate == "playing")
    {
        self suicide();
    }

    maps\mp\gametypes\_menus::addtoteam(team);
    maps\mp\gametypes\_menus::endrespawnnotify();
}

addmfbot(amount, team)
{
    level thread spawn_bots_stub(amount, team, undefined, undefined, "spawned_player", random( level.difficultyBotsList )); //difficulty
}

spawn_bots_stub(count, team, callback, stopWhenFull, notifyWhenDone, difficulty)
{
    name = level.botnames[level.botcount];
    if(level.botcount == (level.botnames.size - 1))
        level.botcount = 0;
    else
        level.botcount++;
    
    time = gettime() + 10000;
    connectingArray = [];
    squad_index = connectingArray.size;
    while(level.players.size < maps\mp\bots\_bots_util::bot_get_client_limit() && connectingArray.size < count && gettime() < time)
    {
        maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause(0.05);
        botent                 = addbot(name,team);
        connecting             = spawnstruct();
        connecting.bot         = botent;
        connecting.ready       = 0;
        connecting.abort       = 0;
        connecting.index       = squad_index;
        connecting.difficultyy = difficulty;
        connectingArray[connectingArray.size] = connecting;
        connecting.bot thread maps\mp\bots\_bots::spawn_bot_latent(team,callback,connecting);
        squad_index++;
    }

    connectedComplete = 0;
    time = gettime() + -5536;
    while(connectedComplete < connectingArray.size && gettime() < time)
    {
        connectedComplete = 0;
        foreach(connecting in connectingArray)
        {
            if(connecting.ready || connecting.abort)
                connectedComplete++;
        }
        wait 0.05;
    }

    if(isdefined(notifyWhenDone))
        self notify(notifyWhenDone);
}

spawn_bot_latent( var_0, var_1, var_2 )
{
    var_3 = gettime() + 60000;

    while ( !self canspawntestclient() )
    {
        if ( gettime() >= var_3 )
        {
            kick( self.entity_number, "EXE_PLAYERKICKED_BOT_BALANCE" );
            var_2.abort = 1;
            return;
        }

        wait 0.05;

        if ( !isdefined( self ) )
        {
            var_2.abort = 1;
            return;
        }
    }

    maps\mp\gametypes\_hostmigration::waitlongdurationwithhostmigrationpause( randomfloatrange( 0.25, 2.0 ) );

    if ( !isdefined( self ) )
    {
        var_2.abort = 1;
        return;
    }

    self spawntestclient();
    self.equipment_enabled = 1;
    //self.team = var_0;
    self.bot_team = var_0;

    if ( isdefined( var_2.difficulty ) )
        maps\mp\bots\_bots_util::bot_set_difficulty( var_2.difficulty );

    if ( isdefined( var_1 ) )
        self [[ var_1 ]]();

    self thread [[ level.bot_funcs["think"] ]]();
    var_2.ready = 1;
}

initBotNames()
{
    level.botnames = [
    "[^2~M~^7] Ana",
    "[^2~M~^7] Carlos",
    "[^2~M~^7] Elena",
    "[^2~M~^7] Diego",
    "[^2~M~^7] Fernanda",
    "[^2~M~^7] Gabriel",
    "[^2~M~^7] Isabel",
    "[^2~M~^7] Javier",
    "[^2~M~^7] Luis",
    "[^2~M~^7] Maria",
    "[^2~M~^7] Natalia",
    "[^2~M~^7] Oscar",
    "[^2~M~^7] Paula",
    "[^2~M~^7] Ricardo",
    "[^2~M~^7] Sofia",
    "[^2~M~^7] Tomas",
    "[^2~M~^7] Valentina",
    "[^2~M~^7] Ximena",
    "[^2~M~^7] Yanira",
    "[^2~M~^7] Zoe",
    "[^2~M~^7] Andres",
    "[^2~M~^7] Beatriz",
    "[^2~M~^7] Cesar",
    "[^2~M~^7] Diana",
    "[^2~M~^7] Esteban",
    "[^2~M~^7] Francisca",
    "[^2~M~^7] Gonzalo",
    "[^2~M~^7] Helena",
    "[^2~M~^7] Ivan",
    "[^2~M~^7] Jimena",
    "[^2~M~^7] Kevin",
    "[^2~M~^7] Laura",
    "[^2~M~^7] Manuel",
    "[^2~M~^7] Nadia",
    "[^2~M~^7] Omar",
    "[^2~M~^7] Patricia",
    "[^2~M~^7] Quirino",
    "[^2~M~^7] Raquel"
];
}
