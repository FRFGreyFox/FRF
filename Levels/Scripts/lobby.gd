extends Control

@onready var players_node = $Players
@onready var players_list = $Players/PlayersList
@onready var players_start = $Players/Start
@onready var connect_node = $Connect
@onready var connect_name = $Connect/Name
@onready var connect_error_text = $Connect/ErrorLabel
@onready var connect_ip = $Connect/IP
@onready var host_button = $Connect/Host
@onready var join_button = $Connect/Join


func _ready():
	# Called every time the node is added to the scene.
	gamestate.connect("connection_failed", Callable(self, "_on_connection_failed"))
	gamestate.connect("connection_succeeded", Callable(self, "_on_connection_success"))
	gamestate.connect("player_list_changed", Callable(self, "refresh_lobby"))
	gamestate.connect("game_ended", Callable(self, "_on_game_ended"))
	gamestate.connect("game_error", Callable(self, "_on_game_error"))
	# Set the player name according to the system username. Fallback to the path.
	if OS.has_environment("USERNAME"):
		connect_name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		connect_name.text = desktop_path[desktop_path.size() - 2]


func _on_host_pressed():
	if connect_name.text == "":
		connect_error_text.set_text("Invalid name!")
		return

	connect_node.hide()
	players_node.show()
	connect_error_text.set_text("")

	var player_name = connect_name.text
	gamestate.host_game(player_name)
	refresh_lobby()


func _on_join_pressed():
	if connect_name.text == "":
		connect_error_text.set_text("Invalid name!")
		return

	var ip = connect_ip.text
	if not ip.is_valid_ip_address():
		connect_error_text.set_text("Invalid IP address!")
		return

	connect_error_text.set_text("")
	host_button.disabled = true

	var player_name = connect_name.text
	gamestate.join_game(ip, player_name)


func _on_connection_success():
	connect_node.hide()
	players_node.show()


func _on_connection_failed():
	host_button.disabled = false
	join_button.disabled = false
	connect_error_text.set_text("Connection failed.")


func _on_game_ended():
	show()
	connect_node.show()
	players_node.hide()
	host_button.disabled = false
	join_button.disabled = false


func _on_game_error(errtxt):
	# $ErrorDialog.dialog_text = errtxt
	# $ErrorDialog.popup_centered_clamped()
	host_button.disabled = false
	join_button.disabled = false


func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	players_list.clear()
	players_list.add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		players_list.add_item(p)

	players_start.disabled = not multiplayer.is_server()


func _on_start_pressed():
	gamestate.begin_game()


func _on_find_public_ip_pressed():
	OS.shell_open("https://icanhazip.com/")