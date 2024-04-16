extends CanvasLayer

@onready var player = $".."

func update_gui():
	$"health".text = "HP: " + str(player.health)
	$"money".text = "Money: " + str(player.money)

func _ready():
	update_gui()

func _on_player_health_updated(_health):
	update_gui()

func _on_player_money_updated(_money):
	update_gui()
