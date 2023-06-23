extends Node2D

@export var current_wave_id: int = 0

@onready var waves_node = $Waves
@onready var enemies = $Enemies

var current_wave: BasicWave


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
