extends Control


@onready var settings_game = $SettingsPanel/SettingsGamePanel
@onready var settings_screen = $SettingsPanel/SettingsScreenPanel
@onready var settings_audio = $SettingsPanel/SettingsSoundPanel
@onready var settings_control = $SettingsPanel/SettingsControllPanel
@onready var save_label = $SettingsPanel/SaveLabel
@onready var save_label_timer = $SettingsPanel/SaveLabelTimer
@onready var music_slider = $SettingsPanel/SettingsSoundPanel/SettingsSoundGroup/MusicGroup/MusicSlider
@onready var sound_slider = $SettingsPanel/SettingsSoundPanel/SettingsSoundGroup/SoundGroup/SoundSlider
@onready var display_mode = $SettingsPanel/SettingsScreenPanel/SettingsScreenGroup/WindowModeGroup/DisplayMode
@onready var vsync_mode = $SettingsPanel/SettingsScreenPanel/SettingsScreenGroup/VsyncGroup/VSYNC
@onready var settings_list = [
	settings_game,
	settings_screen,
	settings_audio,
	settings_control,
]


var parent_menu


func _ready():
	
	var music_volume = settings.get_config("sound", "music")
	if not music_volume == null:
		music_slider.value = music_volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume)
	
	var sound_volume = settings.get_config("sound", "sound")
	if not sound_volume == null:
		sound_slider.value = sound_volume
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), sound_volume)
	
	var display_mode_config = settings.get_config("display", "display_mode")
	if not display_mode_config == null:
		_update_display_mode(display_mode_config)
		display_mode.selected = display_mode_config
	
	var vsync_mode_config = settings.get_config("display", "vsync")
	if not vsync_mode_config == null:
		var vsync_mode_value: int = 0
		match vsync_mode_config:
			0: vsync_mode_value = DisplayServer.VSYNC_DISABLED
			1: vsync_mode_value = DisplayServer.VSYNC_ENABLED
			2: vsync_mode_value = DisplayServer.VSYNC_ADAPTIVE
		vsync_mode.selected = vsync_mode_config
		DisplayServer.window_set_vsync_mode(vsync_mode_value)
	else:
		vsync_mode.selected = 1
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func set_parrent_menu(new_parent_menu):
	parent_menu = new_parent_menu


func _update_display_mode(idx: int):
	var display_mode_value: int = 0
	match idx:
		0: display_mode_value = DisplayServer.WINDOW_MODE_WINDOWED
		1: display_mode_value = DisplayServer.WINDOW_MODE_MAXIMIZED
		2: display_mode_value = DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(display_mode_value)


func _tab_choiced(tab):
	for tab_ in settings_list:
		if tab_ == tab:
			tab_.show()
		else:
			tab_.hide()


func _on_settings_bar_tab_selected(tab: int):
	var selected_tab
	match tab:
		0:
			selected_tab = settings_game
		1:
			selected_tab = settings_screen
		2:
			selected_tab = settings_audio
		3:
			selected_tab = settings_control
	_tab_choiced(selected_tab)


func _on_back_button_pressed():
	assert(parent_menu, "parent menu must be implemented")
	
	hide()
	parent_menu.show()


func _on_apply_button_pressed():
	save_label_timer.stop()
	save_label.modulate.a = 1
	save_label.show()
	save_label_timer.start()
	
	_update_display_mode(display_mode.selected)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_slider.value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), sound_slider.value)

	# Сохранение громкости музыки
	settings.save_config("sound", "music", music_slider.value)
	
	# Сохранение громкости звука
	settings.save_config("sound", "sound", sound_slider.value)
	
	# Сохранение режима отображения экрана
	settings.save_config("display", "display_mode", display_mode.selected)
	
	# Сохранение VSYNC
	settings.save_config("display", "vsync", vsync_mode.selected)


func _on_save_label_timer_timeout():
	save_label.modulate.a -= 0.1
	var a = save_label.modulate.a
	if save_label.modulate.a < 0:
		save_label_timer.stop()
		save_label.hide()
		save_label.modulate.a = 1
