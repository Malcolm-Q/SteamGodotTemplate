extends Node

var multiplayer_peer = null

var lobby_id = 0
var players : Dictionary = {}
var lan : bool = false

func _ready():
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))
	Steam.steamInit(480)
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	Steam.join_requested.connect(_on_lobby_join_requested)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connection_failed.connect(_connection_failed)
	check_command_line()

func _connection_failed() -> void:
	multiplayer.multiplayer_peer.close()
	SignalBus.display_error.emit('FAILED TO CONNECT...')

func _peer_disconnected(id: int) -> void:
	if id == 1:
		_leave_lobby()
	else:
		players.erase(id)
		SignalBus.players_changed.emit()

func _connected_to_server() -> void:
	var id = multiplayer.get_unique_id()
	if lan:
		sync_info.rpc("", id)
	else:
		var my_name : String = Steam.getPersonaName()
		if len(my_name) > 17:
			my_name = my_name.substr(0,17) + '...'
		players[id] = {"name": my_name, "id": Steam.getSteamID()}
		sync_info.rpc(players[id]["name"], players[id]["id"])

@rpc
func _receive_player_data(data : Dictionary, id:int) -> void:
	players = data
	if id == multiplayer.get_unique_id():
		_transition_to_lobby()
	else:
		SignalBus.players_changed.emit()

@rpc("any_peer")
func sync_info(name_: String, id: int) -> void:
	var peer_id = multiplayer.get_remote_sender_id()
	if lan:
		players[peer_id] = {"name": "Player " + str(len(multiplayer.get_peers())), "id": id}
	else:
		players[peer_id] = {"name": name_, "id": id}
	var minimum_data = {}
	for p in players:
		minimum_data[p] = {"name": players[p]["name"], "id": players[p]["id"]}
	_receive_player_data.rpc(minimum_data, peer_id)
	SignalBus.players_changed.emit()

func _process(_d:float) -> void:
	Steam.run_callbacks()

func _on_lobby_created(conn, id) -> void:
	if conn == 1:
		lobby_id = id
		var my_name : String = Steam.getPersonaName()
		if len(my_name) > 17:
			my_name = my_name.substr(0,17) + '...'
		Steam.setLobbyData(lobby_id, "name", (my_name+"'s Lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		multiplayer_peer = SteamMultiplayerPeer.new()
		var error = multiplayer_peer.create_host(0) # this is virtual port not player limit do not change
		if error != OK:
			multiplayer_peer.close()
			Steam.leaveLobby(lobby_id)
			SignalBus.display_error.emit("ERROR CREATING HOST CLIENT\nCODE: " + str(error))
			return
		multiplayer.set_multiplayer_peer(multiplayer_peer)
		players[1] = {"name": my_name, "id": Steam.getSteamID()}
		Steam.allowP2PPacketRelay(true)
		_transition_to_lobby()
	else:
		SignalBus.display_error.emit('ERROR CREATING STEAM LOBBY\nCODE: '+str(conn))

func _on_lobby_joined(lobby: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		var id = Steam.getLobbyOwner(lobby)
		if id != Steam.getSteamID():
			lobby_id = lobby
			players[1] = {"name": Steam.getFriendPersonaName(id), "id": id}
			multiplayer_peer = SteamMultiplayerPeer.new()
			var error = multiplayer_peer.create_client(id, 0)
			if error != OK:
				multiplayer_peer.close()
				Steam.leaveLobby(lobby_id)
				SignalBus.display_error.emit("ERROR CREATING CLIENT\nCODE: " + str(error))
				return
			multiplayer.set_multiplayer_peer(multiplayer_peer)
	else:
		var FAIL_REASON: String
		match response:
			2:  FAIL_REASON = "This lobby no longer exists."
			3:  FAIL_REASON = "You don't have permission to join this lobby."
			4:  FAIL_REASON = "The lobby is now full."
			5:  FAIL_REASON = "Something unexpected happened!"
			6:  FAIL_REASON = "You are banned from this lobby."
			7:  FAIL_REASON = "You cannot join due to having a limited account."
			8:  FAIL_REASON = "This lobby is locked or disabled."
			9:  FAIL_REASON = "This lobby is community locked."
			10: FAIL_REASON = "A user in the lobby has blocked you from joining."
			11: FAIL_REASON = "A user you have blocked is in the lobby."
		SignalBus.display_error.emit(FAIL_REASON)

func _transition_to_lobby() -> void:
	await get_tree().process_frame
	GameManager.main.add_child(GameManager.lobby)
	GameManager.main.remove_child(GameManager.main_menu)

func _leave_lobby() -> void:
	GameManager.main.remove_child(GameManager.lobby)
	GameManager.main.add_child(GameManager.main_menu)
	GameManager.main_menu.enter()
	if !lan:
		Steam.leaveLobby(lobby_id)
	multiplayer.multiplayer_peer.close()
	players.clear()

func _on_join_lan() -> void:
	lan = true
	multiplayer_peer = ENetMultiplayerPeer.new()
	var error = multiplayer_peer.create_client("localhost", 8565)
	if error != OK:
		SignalBus.display_error.emit("FAILED TO CREATE CLIENT\nCODE: " + str(error))
		multiplayer_peer.close()
		return
	multiplayer.multiplayer_peer = multiplayer_peer

func _on_host_lan() -> void:
	lan = true
	multiplayer_peer = ENetMultiplayerPeer.new()
	var error = multiplayer_peer.create_server(8565, 3) # allow 3 peers for 4 player lobby
	if error != OK:
		SignalBus.display_error.emit("FAILED TO CREATE HOST\nCODE: " + str(error))
		multiplayer_peer.close()
		return
	multiplayer.multiplayer_peer = multiplayer_peer
	players[1] = {"name": "Player 1 (you)", "id": 1}
	_transition_to_lobby()

func _on_host_steam() -> void:
	lan = false
	Steam.createLobby(Steam.LOBBY_TYPE_FRIENDS_ONLY, 4) # 4 player lobby

func check_command_line() -> void:
	var these_arguments: Array = OS.get_cmdline_args()
	if these_arguments.size() > 0:
		if these_arguments[0] == "+connect_lobby":
			if int(these_arguments[1]) > 0:
				Steam.joinLobby(int(these_arguments[1]))

func _on_lobby_join_requested(this_lobby_id: int, friend_id: int) -> void:
	lan = false
	Steam.joinLobby(int(this_lobby_id))
