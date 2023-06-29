extends CharacterBody2D

class_name BasicEnemy

@export var max_hp: int = 150
@export var movement_speed: float = 100.0
@export var collision_damage: int = 10
@export var hp_fill_style: StyleBoxFlat

@onready var animation = $Animation
@onready var sprite = $Sprite
@onready var health_bar = $HealthBar
@onready var hit_box = $HitBox

var current_hp: int = max_hp
var target_player


func _ready():
	hit_box.set_damage(collision_damage)
	health_bar.set_new_stylebox(hp_fill_style)
	animation.play("walk")
	if target_player.player_id != multiplayer.get_unique_id():
		modulate.a = 0.5
		health_bar.hide()


@rpc
func _update_position(new_position):
	position = new_position


func _physics_process(_delta):
	if is_multiplayer_authority():
		var direction = global_position.direction_to(target_player.global_position)
		velocity = direction * movement_speed
		move_and_slide()

		if direction.x < 0.1:
			sprite.flip_h = true
		elif direction.x > -0.1:
			sprite.flip_h = false
		rpc("_update_position", position)


func set_hp(new_hp: int):
	current_hp = new_hp


func set_movement_speed(new_speed: float):
	movement_speed = new_speed


@rpc("call_local")
func take_damage(damage_count: int):
	current_hp -= damage_count
	
	if is_multiplayer_authority() and current_hp <= 0:
		rpc("die")
	
	health_bar.update_health_bar(current_hp)


@rpc("call_local")
func die():
	queue_free()


func _on_hurt_box_hurt(damage: int):
	if is_multiplayer_authority():
		rpc("take_damage", damage)
