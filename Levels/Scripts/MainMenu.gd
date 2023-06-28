extends Control

@onready var main_panel = $MainPanel
@onready var settings_panel = $SettingsMenu
@onready var music_slider = $SettingsMenu/SettingsPanel/SettingsSoundPanel/SettingsSoundGroup/MusicGroup/MusicSlider
@onready var sound_slider = $SettingsMenu/SettingsPanel/SettingsSoundPanel/SettingsSoundGroup/SoundGroup/SoundSlider
@onready var display_mode = $SettingsMenu/SettingsPanel/SettingsScreenPanel/SettingsScreenGroup/WindowModeGroup/DisplayMode
@onready var vsync_mode = $SettingsMenu/SettingsPanel/SettingsScreenPanel/SettingsScreenGroup/VsyncGroup/VSYNC


func _on_exit_button_pressed():
	get_tree().quit()


func _on_play_button_pressed():
	var lobby = load("res://Levels/Scenes/lobby.tscn").instantiate()
	get_tree().get_root().add_child(lobby)
	queue_free()


func _on_settings_button_pressed():
	main_panel.hide()
	settings_panel.set_parrent_menu(main_panel)
	settings_panel.show()
