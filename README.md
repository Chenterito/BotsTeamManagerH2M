# BotsTeamManagerH2M

Script to manage bots on the server, through dvars in the CFG file you establish how many bots you want to add to the server in each game, additionally it has a manager that monitors that the teams are always balanced as long as there are bots in the game, changing the bot team to balance them. It will depend on the configuration and the type of game if it is in teams or not.

# How to implement.

Copy the script ""BotsTeamManagerH2M" into "rootgame MWR\user_scripts\mp" of your server folder.

Set that dvars in your server configuration file with the values you want.

Restart server.

```set bots_manage_mode 0```// Sets the way to monitor bots. If it is a team gametype set it to 1, otherwise set it to 0. 

```set bots_manage_add 8``` // Number of bots at game start. This will be controlled if ```bots_manage_mode``` is set to ```0```.

```set bots_manage_fill 10``` // Number of players and bots that the script will monitor. As there are players, bots will be expelled. This will be controlled if ```bots_manage_mode``` is set to ```0```.

```set bots_team_allies 7``` // Number of bots in the "allies" team

```set bots_team_axis 7``` // Number of bots in the "axis" team

```initBotNames()``` //You can set your own bot names. Make sure there are 40 names. Look in the script for the list.

```level.difficultyBotsList = [ "recruit", "hardened" , "veteran" ];``` // Add or remove "regular", "recruit", "hardened" , "veteran"

Bots will appear once the initial countdown is over. You will notice that bots will be added to both teams, I don't know if it's a bug in the game but I haven't been able to get them to be added to a specific team. But don't worry, as soon as the bot quota is filled, the script will automatically set the bots to each team based on the DVAR settings.

In round based type of games you may have problems.
