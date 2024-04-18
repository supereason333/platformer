extends CanvasLayer

signal debug_player_set_health(value)

var player = get_parent()
var health_spin_box = 0
var dragging = false
var menu_pos_rel_mouse_on_clicked = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("debug_menu_toggle_key"):
		self.visible = !self.visible
	if dragging:
		$"HBoxContainer".position.x = clamp(get_viewport().get_mouse_position().x + menu_pos_rel_mouse_on_clicked.x, 0, get_viewport().size.x - $"HBoxContainer".size.x)	# you cant drag it off your screen (i might make a function for it for dragging objects)
		$"HBoxContainer".position.y = clamp(get_viewport().get_mouse_position().y + menu_pos_rel_mouse_on_clicked.y, 0, get_viewport().size.y - $"HBoxContainer".size.y)	#        ^^^^

func _on_spin_box_value_changed(value):
	GlobalPlayer.player_jumps = int(value)

func _on_health_set_value_changed(value):
	health_spin_box = value

func _on_set_health_pressed():
	emit_signal("debug_player_set_health", health_spin_box)

func _on_restore_health_pressed():
	emit_signal("debug_player_set_health", GlobalPlayer.player_max_health)

func _on_kill_pressed():
	emit_signal("debug_player_set_health", 0)

func _on_set_max_health_pressed():
	GlobalPlayer.player_max_health = health_spin_box

func _on_button_button_down():
	dragging = true
	menu_pos_rel_mouse_on_clicked = $"HBoxContainer".position - get_viewport().get_mouse_position()

func _on_button_button_up():
	dragging = false
