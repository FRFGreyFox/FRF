extends CharacterBody2D

class_name BasicEnemy

@export var max_hp: int = 150
@export var movement_speed = 100.0
@export var hp_fill_style: StyleBoxFlat

@onready var animation = $Animation
@onready var sprite = $Sprite
@onready var health_bar = $HealthBar

var current_hp = max_hp


func _ready():
	health_bar.set_new_stylebox(hp_fill_style)
	animation.play("walk")


func _physics_process(_delta):
	var nearest_player
	var min_distance = 100000
	var distance = 0
	for player in get_tree().get_nodes_in_group("player"):
		distance = self.global_position.distance_to(player.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest_player = player
	var direction = global_position.direction_to(nearest_player.global_position)
	velocity = direction * movement_speed
	move_and_slide()

	if direction.x < 0.1:
		sprite.flip_h = true
	elif direction.x > -0.1:
		sprite.flip_h = false


func set_hp(new_hp: int):
	current_hp = new_hp


func set_movement_speed(new_speed: float):
	movement_speed = new_speed


func take_damage(damage_count: int):
	current_hp -= damage_count


func _on_hurt_box_hurt(damage: int):
	take_damage(damage)
	if current_hp <= 0:
		queue_free()
	health_bar.update_health_bar(current_hp)
