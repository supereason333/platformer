extends CharacterBody2D

signal health_updated(health)
signal killed()				# got fucked
signal money_updated(money)

# Theres a lot of varibles but i dont give a fuck
# not really when i think about it again

var hit_damage = 10

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DASH_VELOCITY = 900
var jumps_remaining = 0
var dash_dir = Vector2(0, 0)
var last_direction = 1
var in_controll = true		# can the player move (MAKE A FUNCTION FOR THIS THAT HAS A TALLY SO YOU CAN ADD/DECREASE SO THE SETTING CAN STACK)

var last_spawnpoint = Vector2(0, 0)
var last_resetpoint = Vector2(0, 0)

var health = GlobalPlayer.player_max_health: 			# Player health and what happens when it dose the set get
	set(value): 
		var prev_health = health
		health = clamp(value, 0, GlobalPlayer.player_max_health)
		if health != prev_health:
			emit_signal("health_updated", health)
			if health <= 0:
				kill()
			emit_signal("killed")
	get:
		return health

var money = 0:		# are you poor or rich
	set(value):
		var prev_money = money
		money = value
		if money != prev_money:
			emit_signal("money_updated", money)
	get:
		return money

@onready var invulnerability_timer = $"timers/invulnerability timer"
@onready var jump_timer = $"timers/jump timer"
@onready var dash_timer = $"timers/dash timer"
@onready var dash_cooldown_timer = $"timers/dash cooldown timer"
@onready var reset_timer = $"timers/reset timer"
@onready var knockback_NC_timer = $"timers/knockback no controll timer"
# name these fuckers better ^^^^^

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass

func _process(_delta):
	
	animation()

#***************************************
#			Physics and movement
#***************************************

func _physics_process(delta):
	if in_controll: movement()
	add_gravity(delta)
	move_and_slide()

func movement():
	if Input.is_action_just_pressed("dash_key") and dash_timer.is_stopped() and GlobalPlayer.player_dash:
		dash_dir = Vector2(0, 0)
		if Input.is_action_pressed("left_key"):
			dash_dir.x -= 1
		if Input.is_action_pressed("right_key"):
			dash_dir.x += 1
		if Input.is_action_pressed("down_key"):
			dash_dir.y += 1
		else:
			dash_dir.x = last_direction
		dash_dir = dash_dir.normalized()
		if dash_dir != Vector2(0, 0) and dash_cooldown_timer.is_stopped():
			dash_timer.start()
			dash_cooldown_timer.start()
	
	if !dash_timer.is_stopped():
		velocity = dash_dir * DASH_VELOCITY
	else:
		handle_jump()
		handle_direction()

func handle_direction():
	var direction = Input.get_axis("left_key", "right_key")
	if direction:
		velocity.x = direction * SPEED
		last_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func handle_jump():
	# yeah hopw the jump wprks im not gonna expain it that much
	if is_on_floor() and !Input.is_action_pressed("jump_key") and jumps_remaining != GlobalPlayer.player_jumps:		# you are touching the ground --> reset jumps
		jumps_remaining = GlobalPlayer.player_jumps

	if Input.is_action_pressed("jump_key") and jumps_remaining > 0 and !jump_timer.is_stopped() and velocity.y != 0:# keep jumping
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump_key") and jumps_remaining > 0 and jump_timer.is_stopped():				# initiate jumping / first jump
		velocity.y = JUMP_VELOCITY
		jump_timer.start()
	elif !jump_timer.is_stopped() and velocity.y == 0:																# hit your head owie
		jump_timer.stop()
	elif Input.is_action_just_released("jump_key") and velocity.y <= 30:											# make you go down for better controll in jump
		velocity.y += 300
	
	if Input.is_action_just_released("jump_key"):
		jumps_remaining -= 1

func reset_movement():
	jump_timer.stop()
	jumps_remaining = 0
	dash_timer.stop()
	dash_cooldown_timer.stop()
	self.velocity *= 0

func add_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func animation():
	pass

#***********************************
#			Damage and Violence
#***********************************

func damage(amount: int, is_reset: bool, direction: int):
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		# play damage and invulrability anim
		self.modulate = Color(1, 0, 0, 1)
		
		knockback(direction)
		if is_reset and health - amount > 0: 
			reset_timer.start()
		if is_reset: in_controll = false
		health -= amount
		self.velocity *= 0

func _on_hit_detector_area_entered(area):				# to get position of area it is "area.position"
	print_debug("Entered area " + area.name)
	if area.has_node("damager"):		# all damage things like spikes and damage hitboxes should have a node called "damager" and "(int) plr_damage" and "(bool) plr_reset"
		damage(area.plr_damage, area.plr_reset, (self.position - area.get_node("./area").position).normalized().x)		# i cut my life into pieces
	elif "spawnpoint" in area.name:					# inside checkpoints and shit
		last_spawnpoint = area.position
		print_debug("last spawnpoint is set to: " + str(area.position))
	elif "resetpoint" in area.name:
		last_resetpoint = area.position
		print_debug("last resetpoint is set to: " + str(area.position))

func _on_hit_detector_area_exited(area):
	print_debug("Exited area " + area.name)

func kill():
	health = GlobalPlayer.player_max_health
	respawn_to_spawn()

#***********Subsection: attacks********************

# ummmmm attack??? idk this needs code i think

#**************************************************
#			respawns and shit
#**************************************************

func respawn_to_spawn():
	in_controll = true
	self.position = last_spawnpoint

func knockback(direction):				# it knocks the player in a direction and stops them from moving (DOSENT WORK)
	velocity.y = -200
	velocity.x = 1000 * direction
	knockback_NC_timer.start()

func reset():							# respawn to last resetpoint
	in_controll = true
	reset_movement()
	invulnerability_timer.start()
	self.position = last_resetpoint

#**********************************************
#				TIMER TIMEOUTS AIUOWHDUIAHIWUDHOPWAIU
#**********************************************

func _on_reset_timer_timeout():
	reset()

func _on_knockback_no_controll_timer_timeout():
	pass
	
func _on_invulnerability_timer_timeout():
	self.modulate = Color(1, 1, 1, 1)	# should reset animation (it dosent cus theres no animation to reset)

#***************************************
#				DEBUG MENU
#***************************************

func _on_debug_menu_debug_player_set_health(value):
	health = value
