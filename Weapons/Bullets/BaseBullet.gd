extends Node2D

class_name Base_bullet

@onready var life_timer = $LifeTimer
@onready var hit_box = $HitBox

@export var damage: int = 1
@export var life_time: float = 5.0
@export var speed: float = 450.0
@export var through_limit: int = 1

var current_through: int = 0


func fire(start_position: Vector2, angle: float):
	global_position = start_position
	rotation = angle
	

func _life_timer_end():
	queue_free()


func _ready():
	life_timer.start(life_time)
	hit_box.set_damage(damage)


func _physics_process(delta):
	global_position += speed * Vector2.RIGHT.rotated(rotation) * delta


func _on_hit_box_area_entered(area):
	if area.is_in_group("enemy") and area.get_parent().target_player.player_id == multiplayer.get_unique_id():
		current_through += 1
		if current_through >= through_limit:
			queue_free()
