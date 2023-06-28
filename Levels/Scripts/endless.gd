extends Node2D

@export var current_wave_id: int = 0

@onready var waves_node = $Waves
@onready var enemies = $Enemies
@onready var players = $Players
@onready var players_bullets = $PlayersBullets

var current_wave: BasicWave

signal game_ended(is_loose)


func _run_current_wave():
	current_wave = waves_node.get_child(current_wave_id)
	current_wave.run()


func _update_current_wave_index():
	current_wave_id += 1


func _on_first_wave_timer_timeout():
	_run_current_wave()


func _on_waves_timer_timeout():
	_update_current_wave_index()
	_run_current_wave()


func _on_players_life_check_timer_timeout():
	var died_players_counter = 0
	var players_ = players.get_children()
	for player in players_:
		if not player.is_alive:
			died_players_counter += 1
	if players_.size() == died_players_counter:
		emit_signal("game_ended", true)
