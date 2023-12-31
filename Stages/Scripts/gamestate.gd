extends Node

signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players. 1 + MAX_PEERS
const MAX_PEERS = 3

var peer = null

# Name for my player.
var player_name = "Player"

# Names for remote players in id:name format.
var players = {}
var players_ready = []
var player_names = {}

var current_world_scene: BaseLevel

var players_objs: Dictionary


func _ready():
	multiplayer.connect("peer_connected", _player_connected)
	multiplayer.connect("peer_disconnected", _player_disconnected)
	multiplayer.connect("connected_to_server", _connected_ok)
	multiplayer.connect("connection_failed", _connected_fail)
	multiplayer.connect("server_disconnected", _server_disconnected)


@rpc("call_remote") func _disconnect(id):
	multiplayer.set_multiplayer_peer(null)
	push_warning(str(id) + "is disconnected")


# Callback from SceneTree.
func _player_connected(id):
	rpc_id(id, "register_player", player_name)
	load_new_player(id)


@rpc("any_peer") 
func register_player(new_player_name: String):
	var id = multiplayer.get_remote_sender_id()
	player_names[id] = new_player_name
	players[id].set_player_name(new_player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if multiplayer.is_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		#unregister_player(id)
		pass


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	var player_id = multiplayer.get_unique_id()
	player_names[player_id] = player_name
	rpc("update_player_names", player_id, player_name)
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	multiplayer.set_multiplayer_peer(null) # Remove peer
	emit_signal("connection_failed")


@rpc("call_local") func pre_start_game(spawn_points):
	# Change scene.
	current_world_scene = load("res://Levels/Scenes/endless.tscn").instantiate()
	get_tree().get_root().add_child(current_world_scene)
	get_tree().get_root().get_node("lobby").hide()
	var player_scene = load("res://Player/player.tscn")
	var collision_index = 1
	for p_id in spawn_points:
		var player = player_scene.instantiate()
		player.collision_layer = collision_index
		player.collision_mask = collision_index
		collision_index += 1
		player.set_name(str(p_id)) # Use unique ID as node name.
		player.position = current_world_scene.get_node(
			"PlayersSpawnPoints/" + str(spawn_points[p_id])
		).position
		player.set_multiplayer_authority(p_id) # Set unique id as master.
		if p_id == multiplayer.get_unique_id():
			# If node for this peer id, set name.
			player.set_player_name(player_name)
		else:
			# Otherwise set name from peer.
			player.set_player_name(self.players[p_id])
		player.set_player_id(p_id)
		current_world_scene.get_node("Players").add_child(player)
	if not multiplayer.is_server():
		rpc_id(1, "ready_to_start", multiplayer.get_unique_id())


@rpc("any_peer") func ready_to_start(id):
	assert(multiplayer.is_server())

	if not id in players_ready:
		players_ready.append(id)


func start_server(new_player_name: String):
	player_name = new_player_name
	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	multiplayer.set_multiplayer_peer(peer)
	player_names[1] = new_player_name


func join_game(ip: String, new_player_name: String):
	player_name = new_player_name
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, DEFAULT_PORT)
	multiplayer.set_multiplayer_peer(peer)


func get_player_list():
	return players.values()


func get_player_name():
	return player_name


func begin_game():
	assert(multiplayer.is_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing.
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points.
	for player in players:
		rpc_id(player, "pre_start_game", spawn_points)
	pre_start_game(spawn_points)


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	emit_signal("game_ended")
	players.clear()


func load_current_world_scene(is_debug: bool):
	"""Прогружаем ресурс лобби и отрисовываем его."""
	if is_debug:
		current_world_scene = load("res://Stages/Debug/DebugLevel.tscn").instantiate()
	else:
		current_world_scene = load("res://Stages/Hub/Hub.tscn").instantiate()
	get_tree().get_root().add_child(current_world_scene)


func load_hub_server(new_player_name: String, is_debug: bool = false):
	load_current_world_scene(is_debug)
	var self_player = load_new_player(1)
	self_player.set_player_name(new_player_name)


func load_hub_client(new_player_name: String, is_debug: bool = false):
	load_current_world_scene(is_debug)
	var player_id = multiplayer.get_unique_id()
	player_names[player_id] = new_player_name
	var self_player = load_new_player(multiplayer.get_unique_id())
	self_player.set_player_name(new_player_name)


func load_new_player(player_id: int):
	var player = load("res://Heroes/GreyFox/GreyFox.tscn").instantiate()
	player.set_name(str(player_id))
	player.set_player_id(player_id)
	current_world_scene.spawn_player(player)
	player.set_multiplayer_authority(player_id)
	players[player_id] = player
	player.set_player_id(player_id)
	return player


@rpc("any_peer", "call_local")
func update_player_names(player_id, new_name):
	player_names[player_id] = new_name
