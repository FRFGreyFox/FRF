extends CharacterBody2D

class_name BasicEnemy

@export var max_hp: int = 150
@export var movement_speed = 100.0
@export var hp_bar_fill_color = Color(190, 0, 0)

var current_hp = max_hp


func set_hp(new_hp: int):
	current_hp = new_hp

func set_movement_speed(new_speed: float):
	movement_speed = new_speed

func take_damage(damage_count: int):
	current_hp -= damage_count
