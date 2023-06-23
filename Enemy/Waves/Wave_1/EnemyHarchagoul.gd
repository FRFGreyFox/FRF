extends BasicEnemy

@onready var sprite = $sprite
@onready var anim = $AnimationPlayer
@onready var health_bar = $HealthBar


func _ready():
	anim.play("walk")


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


func _on_hurt_box_hurt(damage: int):
	take_damage(damage)
	if current_hp <= 0:
		queue_free()
