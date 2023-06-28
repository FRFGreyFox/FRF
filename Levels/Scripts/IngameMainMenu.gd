extends Control

@onready var ingame_panel = $IngameMainPanel
@onready var settings_panel = $SettingsMenu


func _on_return_pressed():
	hide()


func _on_exit_game_pressed():
	get_tree().quit()


func _on_settings_pressed():
	settings_panel.set_parrent_menu(ingame_panel)
	ingame_panel.hide()
	settings_panel.show()


func _on_exit_main_menu_pressed():
	multiplayer.set_multiplayer_peer(null)
	var main_menu = load("res://Levels/Menues/MainMenu.tscn").instantiate()
	get_tree().get_root().add_child(main_menu)
	gamestate.current_world_scene.queue_free()
	queue_free()
