extends Node


# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 10567

# Max number of players.
const MAX_PEERS = 12

var peer = null

# Name for my player.
var player_name = "Pleyer"

# Names for remote players in id:name format.
var players = {}
var players_ready = []


func _ready():
	multiplayer.connect("peer_connected", self._player_connected)
	multiplayer.connect("peer_disconnected", Callable(self, "_player_disconnected"))
	multiplayer.connect("connected_to_server", Callable(self, "_connected_ok"))
	multiplayer.connect("connection_failed", Callable(self, "_connected_fail"))
	multiplayer.connect("server_disconnected", Callable(self, "_server_disconnected"))


# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if multiplayer.is_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
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


# Lobby management functions.

@rpc("any_peer") func register_player(new_player_name):
	var id = multiplayer.get_remote_sender_id()
	print(id)
	players[id] = new_player_name
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")


@rpc("any_peer") func pre_start_game(spawn_points):
	# Change scene.
	var world = load("res://Levels/Scenes/endless.tscn").instantiate()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("lobby").hide()

	var player_scene = load("res://Player/player.tscn")

	for p_id in spawn_points:
		var spawn_pos = world.get_node("PlayersSpawnPoints/" + str(spawn_points[p_id])).position
		var player = player_scene.instantiate()

		player.set_name(str(p_id)) # Use unique ID as node name.
		player.position = spawn_pos
		player.set_multiplayer_authority(p_id) #set unique id as master.

		if p_id == multiplayer.get_unique_id():
			# If node for this peer id, set name.
			player.set_player_name(player_name)
		else:
			# Otherwise set name from peer.
			player.set_player_name(players[p_id])

		world.get_node("Players").add_child(player)

	# Set up score.
	# world.get_node("Score").add_player(multiplayer.get_unique_id(), player_name)
	# for pn in players:
	# 	world.get_node("Score").add_player(pn, players[pn])

	if not multiplayer.is_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", multiplayer.get_unique_id())
	#elif players.size() == 0:
	#	post_start_game()


#@rpc("any_peer") func post_start_game():
#	multiplayer.set_pause(false) # Unpause and unleash the game!


@rpc("any_peer") func ready_to_start(id):
	assert(multiplayer.is_server())

	if not id in players_ready:
		players_ready.append(id)

	#if players_ready.size() == players.size():
	#	for p in players:
	#		rpc_id(p, "post_start_game")
	#	post_start_game()


func host_game(new_player_name):
	player_name = new_player_name
	peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	multiplayer.set_multiplayer_peer(peer)


func join_game(ip, new_player_name):
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
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)

	pre_start_game(spawn_points)


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	emit_signal("game_ended")
	players.clear()
