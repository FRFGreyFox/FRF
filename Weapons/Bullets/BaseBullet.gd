extends Node2D

class_name Base_bullet

@onready var life_timer = $LifeTimer
@export var bullet_info: Bullet_info


func fire(start_position: Vector2):
	global_position = start_position


func _life_timer_end():
	queue_free()


func _ready():
	life_timer.start(bullet_info.life_time)
