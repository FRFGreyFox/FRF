extends Control
@export_file var stage_select
@export_file var level1_1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_back_button_pressed():
	get_tree().change_scene_to_file(stage_select)


func _on_button_pressed():
	get_tree().change_scene_to_file(level1_1)
