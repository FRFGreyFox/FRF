extends Control

@onready var bar = $ProgressBar


func set_max_value(max_value):
	self.bar.max_value = max_value


func update_health_bar(currennt_health):
	self.bar.value = currennt_health
