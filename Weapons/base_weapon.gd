extends Node2D

class_name Base_Weapon

@export var weapon_info: Weapon_info

@onready var attackTimer = $AttackTimer
@onready var player = get_parent()


func _ready():
	attackTimer.wait_time = weapon_info.rate_of_fire
	print_debug("оружие выдано")


func update_bullet(new_bullet):
	weapon_info.bullet = new_bullet


func _on_attack_timer_timeout():
	var new_bullet = weapon_info.bullet.instantiate()
	gamestate.current_world_scene.players_bullets.add_child(new_bullet)
	new_bullet.fire(
		player.global_position,
		global_position.direction_to(get_global_mouse_position()).angle()
	)
	
