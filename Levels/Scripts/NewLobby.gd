extends Node2D

@onready var players = $Players
@onready var objects = $Objects


func _ready():
	# Called every time the node is added to the scene.
	gamestate.connect("connection_failed", _on_connection_failed)
	gamestate.connect("connection_succeeded", _on_connection_success)
	gamestate.connect("player_list_changed", Callable(self, "refresh_lobby"))
	gamestate.connect("game_ended", _on_game_ended)
	gamestate.connect("game_error", _on_game_error)
	
	# Set the player name according to the system username. Fallback to the path.
	#if OS.has_environment("USERNAME"):
	#	connect_name.text = OS.get_environment("USERNAME")
	#else:
	#	var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).replace("\\", "/").split("/")
	#	connect_name.text = desktop_path[desktop_path.size() - 2]


func _on_connection_failed():
	pass


func _on_connection_success():
	pass


func _on_game_ended():
	pass


func refresh_lobby():
	pass


func _on_game_error(err):
	pass


func _on_host_area_body_entered(body):
	pass
