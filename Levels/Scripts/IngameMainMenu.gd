extends Control

@onready var ingame_panel = $IngameMainPanel
@onready var settings_panel = $SettingsMenu

signal exit_pressed()


func _on_return_pressed():
	hide()


func _on_exit_game_pressed():
	emit_signal("exit_pressed")
	get_tree().quit()


func _on_settings_pressed():
	settings_panel.set_parrent_menu(ingame_panel)
	ingame_panel.hide()
	settings_panel.show()


func _on_exit_main_menu_pressed():
	emit_signal("exit_pressed")
