extends CharacterBody2D


@export var movement_speed = 100.0
@export var hp = 10
@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $sprite
@onready var anim = $AnimationPlayer

func _ready():
	anim.play("walk")



func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction*movement_speed
	move_and_slide()

	if direction.x < 0.1:
		sprite.flip_h = true
	elif direction.x > -0.1:
		sprite.flip_h = false


func _on_hurt_box_hurt(damage):
	hp -= damage
	if hp <= 0:
		queue_free()
