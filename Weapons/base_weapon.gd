extends Node2D

class_name Base_Weapon

@export var bullet: Resource
@export var rate_of_fire: float = 1.0

@onready var attackTimer = $AttackTimer
@onready var player = get_parent()

var is_shooting: bool = true


func _ready():
	attackTimer.wait_time = rate_of_fire


func update_bullet(new_bullet):
	bullet = new_bullet


func stop_shooting():
	is_shooting = false


func start_shooting():
	is_shooting = true


func _on_attack_timer_timeout():
	if is_shooting:
		var new_bullet = bullet.instantiate()
		gamestate.current_world_scene.players_bullets.add_child(new_bullet)
		new_bullet.fire(player.global_position, player.angle)
