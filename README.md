# Steam Godot Template
This project uses [Gramps' GodotSteam addon](https://github.com/GodotSteam/GodotSteam) and [Expresso Bits' SteamMultiplayerPeer addon](https://github.com/expressobits/steam-multiplayer-peer) for Steamworks inntegration.  
It also uses [derkork's Godot State Charts](https://github.com/derkork/godot-statecharts)  
Made with Godot 4.4  
This project contains a main menu with saved and applied settings, the ability to create and join LAN servers, and the ability to create and join Steam servers.  
Invite friends directly through Steam.  
Will work for a 2D or 3D project.  
All control elements use the theme at assets/misc/main_menu.tres  

I built this template for myself first and foremost to reduce time spent on boilerplate however I am making effort for it to be as workflow agnostic as possible.  
An exception to this is Godot State Charts. I now consider this plugin essential to all my projects so it will be a dependency here on out.  
The styling of the UI is very basic as no matter what it is it will be replaced with the game's own theme.  
Pull requests and even alternate branches like one including a lobby browser for example are more than welcome.  

Creates 4 player lobbies by default. Does not include lobby browser. Lobbies are friends only by default.  
I may create a branch with a lobby browser but I don't use them in my own games so we'll see.  
UI is controllable via mouse.  

Launch flags:
- --no-sound
  - Mutes all audio for that instance
- --host
  - Hosts a LAN lobby
- --join
  - Joins said LAN lobby.

SC of a LAN lobby:
![image](https://github.com/user-attachments/assets/e96f0b55-0593-45da-8cd1-3a9c38fc5de6)

SC of the settings page:
![settings](https://github.com/user-attachments/assets/853d9b53-aee4-4c3f-bafe-bb4b0b122371)

# 11/05/25 
- Update to 4.4 and new plugin versions
- Refactored menu UI to use state chart. Previously this was a gross hack of a state machine I made because I didn't want to force a dependency
- Fixed Steam.SteamInit missing first arg [resulting in this issue on linux](https://github.com/Malcolm-Q/SteamGodotTemplate/issues/3)
- Added launch args for --host --join and --no-sound
- Created SettingsController a class that can be placed and linked to settings controls wherever they may be
- Removed SFX code in main.gd. I do not use this design pattern so I'm not sure why it was there
- Changed how music works in main.gd and added support for synchronizing music across clients
- Removed SignalBus and migrated existing signals to respective classes. It's easy to add a SignalBus but tedious to remove it
- Made it so instead of 'Create Lobby' and 'LAN' it's 'Steam' and 'LAN'
- When you select Steam it still shows host/join and if you hit host it will open the steam overlay (overlay only works when steam is wrapping the game)
- Fixed some settings formatting issues

