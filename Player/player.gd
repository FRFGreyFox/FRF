extends CharacterBody2D


<<<<<<< HEAD
@export var movement_speed = 200
@export var max_hp = 50
@export var hp_bar_fill_color = Color(0, 190, 0)
=======
var movement_speed = 200
var hp = 50

#attack
var iceSpear = preload("res://Player/weapon/ice_spear.tscn")

#AttackNodes
@onready var iceSpearTimer = get_node("%iceSpearTimer")
@onready var iceSpearAttackTimer = get_node("%iceSpearAttackTimer")

#iceSpear
var iceSpear_ammo = 0
var iceSpear_baseammo = 1
var iceSpear_attackspeed = 1.5
var iceSpear_level = 1

#enemy related
var enemy_close = []
>>>>>>> 48d4984 (skill)

@onready var sprite = $Sprite
@onready var walkTimer = $walkTimer
@onready var health_bar = $HealthBar

var hp = 50

func _ready():
	attack()


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
	
func attack():
	if iceSpear_level > 0:
		iceSpearTimer.wait_time = iceSpear_attackspeed
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()

func _on_hurt_box_hurt(damage):
	hp -= damage
	print(hp)


func _on_ice_spear_timer_timeout():
	iceSpear_ammo += iceSpear_baseammo
	iceSpearAttackTimer.start()


func _on_ice_spear_attack_timer_timeout():
	if iceSpear_ammo > 0:
		var iceSpear_attack = iceSpear.instantiate()
		iceSpear_attack.position = position
		iceSpear_attack.target = get_random_target()
		iceSpear_attack.level = iceSpear_level
		add_child(iceSpear_attack)
		iceSpear_ammo -= 1
		if iceSpear_ammo > 0:
			iceSpearAttackTimer.start()
		else:
			iceSpearAttackTimer.stop()
			
func get_random_target():
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position
	else:
		return Vector2.UP


func _on_enemy_detection_area_body_entered(body):
	if not enemy_close.has(body):
		enemy_close.append(body)


func _on_enemy_detection_area_body_exited(body):
	if enemy_close.has(body):
		enemy_close.erase(body)
		
