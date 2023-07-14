extends Panel


@onready var up_button: Button = $"ScrollButtonsContainer/VerticalButtonsCOntainer/move_up/ButtonContainer/move_up"
@onready var down_button: Button = $"ScrollButtonsContainer/VerticalButtonsCOntainer/move_down/ButtonContainer/move_down"
@onready var left_button: Button = $"ScrollButtonsContainer/VerticalButtonsCOntainer/move_left/ButtonContainer/move_left"
@onready var right_button: Button = $"ScrollButtonsContainer/VerticalButtonsCOntainer/move_right/ButtonContainer/move_right"

@onready var buttons: Array[Button] = [
	up_button,
	down_button,
	left_button,
	right_button,
]

var can_change_key = false
var action_string: String


func _ready():
	# Drop to default
	# InputMap.load_from_project_settings()
	
	update_buttons_text()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and can_change_key:
		if InputMap.has_action(action_string):
			InputMap.action_erase_event(action_string, InputMap.action_get_events(action_string)[0])
		InputMap.action_add_event(action_string, event)
		update_buttons_text()
		can_change_key = false


func set_key_to_action_event(action: String, key: int) -> void:
	var new_input = InputEventKey.new()
	new_input.physical_keycode = key
	new_input.keycode = key
	new_input.key_label = key
	if InputMap.has_action(action):
		InputMap.action_erase_event(action, InputMap.action_get_events(action)[0])
	InputMap.action_add_event(action, new_input)
	update_buttons_text()


func set_untoggled_buttons(ignore_button: Button = null) -> void:
	for button in buttons:
		if button != ignore_button:
			button.set_pressed_no_signal(false)


func update_buttons_text() -> void:
	for button in buttons:
		button.set_text(
			InputMap.action_get_events(button.name)[0].as_text_physical_keycode()
		)
	set_untoggled_buttons()


func _button_toggle(button: Button, toggled: bool) -> void:
	set_untoggled_buttons(button)
	if toggled:
		set_untoggled_buttons(button)
		can_change_key = true
		action_string = button.name
	else:
		set_untoggled_buttons()
		can_change_key = false


func _on_move_up_toggled(button_pressed: bool) -> void:
	_button_toggle(up_button, button_pressed)


func _on_move_down_toggled(button_pressed: bool) -> void:
	_button_toggle(down_button, button_pressed)


func _on_move_left_toggled(button_pressed: bool) -> void:
	_button_toggle(left_button, button_pressed)


func _on_move_right_toggled(button_pressed: bool) -> void:
	_button_toggle(right_button, button_pressed)
