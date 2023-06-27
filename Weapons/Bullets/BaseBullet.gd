extends Node2D

class_name Base_bullet

@onready var life_timer = $LifeTimer
@export var bullet_info: Bullet_info

func fire(start_position: Vector2, new_rotation):
	global_position = start_position
	rotation = new_rotation
	
func _life_timer_end():
	queue_free()

func _ready():
	life_timer.start(bullet_info.life_time)

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += bullet_info.speed * direction * delta
