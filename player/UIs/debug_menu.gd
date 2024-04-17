extends CanvasLayer

signal debug_player_set_health(value)

var player = get_parent()
var health_spin_box = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("debug_menu_toggle_key"):
		self.visible = !self.visible

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
