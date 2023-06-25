extends Node2D

class_name Base_Weapon

@export var weapon_info: Weapon_info

@onready var attackTimer = $AttackTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	attackTimer.wait_time = weapon_info.rate_of_fire
	print("оружие выдано") # Replace with function body.

func update_bullet(new_bullet):
	weapon_info.bullet = new_bullet

func _on_attack_timer_timeout():
	var new_bullet = weapon_info.bullet.instantiate()
	get_parent().get_parent().add_child(new_bullet)
	new_bullet.run()
	print("выстрел")
