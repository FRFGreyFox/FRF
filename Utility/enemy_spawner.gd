extends Node2D

@export var spawns: Array[Spawn_info] = []

@onready var player = get_tree().get_first_node_in_group("player")

var time = 0

signal changetime(time)

func _ready():
	connect("changetime",Callable(player,"change_time"))

func _on_timer_timeout():
	time += 1
	var enemy_spawns = spawns
	for i in enemy_spawns:
		if time >= i.time_start and time <= i.time_end:
			if i.spawn_delay_counter < i.enemy_spawn_delay:
				i.spawn_delay_counter += 1
			else:
				i.spawn_delay_counter = 0
				var new_enemy = i.enemy
				var counter = 0
				while counter < i.enemy_number:
					var enemy_spawn = new_enemy.instantiate()
					enemy_spawn.global_position = get_random_position()
					add_child(enemy_spawn)
					counter += 1


func get_random_position(up = true, down = true, left = true, right = true):
	var viewport_size = get_viewport_rect().size * randf_range(1.1, 1.4)
	var min_x = player.global_position.x - viewport_size.x / 2
	var min_y = player.global_position.y - viewport_size.y / 2
	match randi_range(1,4):
		1:
			return Vector2(randf_range(min_x, min_x + viewport_size.x), min_y)
		2:
			return Vector2(randf_range(min_x, min_x + viewport_size.x), min_y + viewport_size.y)
		3:
			return Vector2(min_x + viewport_size.x, randf_range(min_y, min_y + viewport_size.y))
		4:
			return Vector2(min_x, randf_range(min_y, min_y + viewport_size.y))
