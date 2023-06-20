extends Control

@export var color = Color(0, 187, 0)

@onready var bar: ProgressBar = $ProgressBar

func _ready():
	self.bar.max_value = self.get_parent().max_hp

func set_fill_color(color: Color):
	self.bar.get_theme_stylebox("fill").bg_color = color

func set_max_value(max_value):
	self.bar.max_value = max_value

func update_health_bar(currennt_health):
	self.bar.value = currennt_health
