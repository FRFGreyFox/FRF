extends Node2D

class_name Base_bullet

@onready var life_timer = $LifeTimer
@export var bullet_info: Bullet_info

func run():
	print("вылетила пуля")

func _life_timer_end():
	queue_free()

func _ready():
	life_timer.wait_time = bullet_info.life_time
