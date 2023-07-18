extends CanvasLayer

@onready var animation_player = $AnimationPlayer 

func change_scene():
	animation_player.play("dissolve")
