extends Control



func _on_main_menu_button_pressed():
	multiplayer.set_multiplayer_peer(null)
	var main_menu = load("res://Levels/Menues/MainMenu.tscn").instantiate()
	get_tree().get_root().add_child(main_menu)
	queue_free()
	gamestate.current_world_scene.queue_free()


func _on_exit_button_pressed():
	get_tree().quit()
