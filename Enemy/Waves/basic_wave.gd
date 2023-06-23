extends Node2D

class_name BasicWave

@export var spawn_info: Spawn_info

@onready var spawn_timer = $spawn_timer
@onready var current_enemeis_count = spawn_info.enemy_first_wave_count


func run():
	# Стартуем что-бы сразу начался вызов призыва.
	spawn_timer.start()
	# Корректируем таймер под задержку.
	spawn_timer.wait_time = spawn_info.enemy_spawn_delay


func get_enemy_random_position():
	var viewport_size = get_viewport_rect().size * randf_range(1.1, 1.4)
	# var min_x = player.global_position.x - viewport_size.x / 2
	# var min_y = player.global_position.y - viewport_size.y / 2
	var min_x = 0
	var min_y = 0
	match randi_range(1,4):
		1:
			return Vector2(randf_range(min_x, min_x + viewport_size.x), min_y)
		2:
			return Vector2(randf_range(min_x, min_x + viewport_size.x), min_y + viewport_size.y)
		3:
			return Vector2(min_x + viewport_size.x, randf_range(min_y, min_y + viewport_size.y))
		4:
			return Vector2(min_x, randf_range(min_y, min_y + viewport_size.y))


func _on_spawn_timer_timeout():
	for enemy_id in range(current_enemeis_count):
		var new_enemy = spawn_info.enemy.instantiate()
		new_enemy.global_position = get_enemy_random_position()
		self.get_parent().get_parent().get_node("Enemies").add_child(new_enemy)
	current_enemeis_count += spawn_info.enemy_count_escalating
