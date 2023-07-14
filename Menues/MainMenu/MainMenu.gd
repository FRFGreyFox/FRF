extends Control

@onready var main_panel = $MainPanel
@onready var settings_panel = $SettingsMenu
@onready var connect_menu = $ConnectMenu
@onready var connect_name = $ConnectMenu/PlayerNameZone/Name
@onready var connect_error_text = $ConnectMenu/ErrorLabel
@onready var connect_ip = $ConnectMenu/IPHostZone/IP


func _ready():
	# Called every time the node is added to the scene.
	gamestate.connect("connection_failed", Callable(self, "_on_connection_failed"))
	gamestate.connect("connection_succeeded", Callable(self, "_on_connection_success"))
	gamestate.connect("game_ended", Callable(self, "_on_game_ended"))
	gamestate.connect("game_error", Callable(self, "_on_game_error"))
	# Set the player name according to the system username. Fallback to the path.
	if OS.has_environment("USERNAME"):
		connect_name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).replace("\\", "/").split("/")
		connect_name.text = desktop_path[desktop_path.size() - 2]


func _check_player_name(player_name: String) -> bool:
	if player_name == "":
		connect_error_text.set_text("Invalid name!")
		return false
	return true


func _on_host_pressed():
	if not _check_player_name(connect_name.text):
		return
	
	# TODO: delete this
	var is_debug: CheckBox = $ConnectMenu/ButtonsZone/is_debug
	
	gamestate.start_server(connect_name.text)
	gamestate.load_hub_server(connect_name.text, is_debug.button_pressed)
	queue_free()


func _on_exit_button_pressed():
	get_tree().quit()


func _on_play_button_pressed():
	main_panel.hide()
	connect_menu.show()


func _on_settings_button_pressed():
	main_panel.hide()
	settings_panel.set_parrent_menu(main_panel)
	settings_panel.show()


func _on_button_pressed():
	connect_menu.hide()
	main_panel.show()


func _on_join_pressed():
	if not _check_player_name(connect_name.text):
		return

	var ip = connect_ip.text
	if not ip.is_valid_ip_address():
		connect_error_text.set_text("Invalid IP address!")
		return

	gamestate.join_game(ip, connect_name.text)
	gamestate.load_hub_client(connect_name.text)
	queue_free()
