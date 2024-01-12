extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "player":
		if body.position.x > position.x:
			get_node("res://player/player.gd").damage(1, true, 1)
		else:
			get_node("res://player/player.gd").damage(1, true, -1)
