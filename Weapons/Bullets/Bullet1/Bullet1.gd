extends Base_bullet

@onready var animplayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	animplayer.play("fire")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
