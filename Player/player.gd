extends CharacterBody2D

@export var movement_speed = 200
@export var max_hp = 50
@export var hp_bar_fill_color = Color(0, 190, 0)

@onready var sprite = $Sprite
@onready var walkTimer = $walkTimer
@onready var health_bar = $HealthBar

var puppet_pos = Vector2()
var puppet_motion = Vector2()

var hp = 50
	
@rpc("any_peer") func _update_state(p_pos, p_motion):
	puppet_pos = p_pos
	puppet_motion = p_motion

func _physics_process(_delta):
	_new_movement()

func _new_movement():
	var motion = Vector2()

	if is_multiplayer_authority():
		if Input.is_action_pressed("move_left"):
			motion += Vector2(-1, 0)
		if Input.is_action_pressed("move_right"):
			motion += Vector2(1, 0)
		if Input.is_action_pressed("move_up"):
			motion += Vector2(0, -1)
		if Input.is_action_pressed("move_down"):
			motion += Vector2(0, 1)
		rpc("_update_state", position, motion)
	else:
		position = puppet_pos
		motion = puppet_motion

	var animation: AnimationPlayer = get_node("Animation")
	if motion.x != 0 or motion.y != 0:
		animation.play("walk")
	else:
		animation.stop()

	# FIXME: Use move_and_slide
	set_velocity(motion * movement_speed)
	move_and_slide()
	if not is_multiplayer_authority():
		puppet_pos = position # To avoid jitter
	
func movement():
	var x_mov = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_mov = Input.get_action_strength("down") - Input.get_action_strength("up")
	var mov = Vector2(x_mov, y_mov)
	
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

func set_player_name(new_name):
	# get_node("label").set_text(new_name)
	pass
