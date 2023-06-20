extends CharacterBody2D


@export var movement_speed = 200
@export var max_hp = 50
@export var hp_bar_fill_color = Color(0, 190, 0)

@onready var sprite = $Sprite
@onready var walkTimer = $walkTimer
@onready var health_bar = $HealthBar

var hp = 50

func _physics_process(_delta):
	movement()
	
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov,y_mov)
	
	if x_mov < 0:
		sprite.flip_h = true
	elif x_mov > 0:
		sprite.flip_h = false
	
	if mov != Vector2.ZERO:
		if walkTimer.is_stopped():
			if sprite.frame >= sprite.hframes - 1:
				sprite.frame = 0
			else:
				sprite.frame += 1
			walkTimer.start()
	velocity = mov.normalized()*movement_speed
	move_and_slide()
	
func _process(delta):
	self.health_bar.update_health_bar(self.hp)

func _on_hurt_box_hurt(damage):
	hp -= damage
