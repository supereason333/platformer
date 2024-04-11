extends CharacterBody2D

signal health_updated(health)
signal killed()

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DASH_COOLDOWN = 120
const DASH_FRAMES_MAX = 20
const DASH_VELOCITY = 900
var jumps_remaining = 0
var frame_since_dash = 0
var dash_frames = 6969
var dash_dir = Vector2(0, 0)

@onready var invulnerability_timer = $"invulnerability timer"
@onready var jump_timer = $"jump timer"

var health = GlobalPlayer.player_max_health: 
	set(value): 
		_set_health(value)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	#$GUI.update_gui()
	pass

func _process(delta):
	pass

func _physics_process(delta):
	add_gravity(delta)
	animation()
	movement()
	move_and_slide()

func movement():
	if Input.is_action_just_pressed("dash_key") and frame_since_dash >= DASH_COOLDOWN and GlobalPlayer.player_dash:
		dash_dir *= 0
		if Input.is_action_pressed("left_key"):
			dash_dir.x -= 1
		if Input.is_action_pressed("right_key"):
			dash_dir.x += 1
		if Input.is_action_pressed("down_key"):
			dash_dir.y += 1
		dash_dir = dash_dir.normalized()
		if dash_dir != Vector2(0, 0):
			frame_since_dash = 0
			dash_frames = 0
	
	if dash_frames < DASH_FRAMES_MAX:
		dash_frames += 1
		velocity = dash_dir * DASH_VELOCITY
	else:
		handle_jump()
		handle_direction()

func handle_direction():
	var direction = Input.get_axis("left_key", "right_key")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func handle_jump():
	if is_on_floor() and !Input.is_action_pressed("jump_key"):
		jumps_remaining = GlobalPlayer.player_jumps
		
	if Input.is_action_pressed("jump_key") and jumps_remaining > 0 and !jump_timer.is_stopped():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump_key") and jumps_remaining > 0 and jump_timer.is_stopped():
		velocity.y = JUMP_VELOCITY
		jump_timer.start()
	elif Input.is_action_just_released("jump_key") and velocity.y <= 30:
		velocity.y += 300
	elif jumps_remaining == 0:
		jumps_remaining = -1
	
	if Input.is_action_just_released("jump_key"):
		jumps_remaining -= 1
		
	print_debug(jumps_remaining)

func animation():
	pass

func add_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func damage(damage: int, reset: bool, direction: int):
	if invulnerability_timer.is_stopped():
		invulnerability_timer.start()
		# play damage and invulrability anim
		knockback(direction)
		_set_health(health - damage)

func knockback(direction):
	velocity.y -= 20
	velocity.x += 200 * direction

func reset():
	pass

func respawn_to_spawn():
	pass

func kill():
	respawn_to_spawn()

func _set_health(value):
	var prev_health = health
	health = clamp(value, 0, GlobalPlayer.player_max_health)
	if health != prev_health:
		emit_signal("health_updated", health)
		if health <= 0:
			kill()
			emit_signal("killed")


func _on_invulnerability_timer_timeout():
	pass # reset animation
