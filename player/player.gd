extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_JUMP_TIME = 15
const DASH_COOLDOWN = 60
const MAX_DASH_TIME = 20
const DASH_VELOCITY = 900
var jump_time = 0
var is_jumping = false
var frames_since_damage = 0
var jumps_remaining = GlobalPlayer.player_jumps
var dashing = false
var frame_since_dash = 0
var dash_time = 0
var dash_dir = Vector2(0, 0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	get_node("GUI").update_gui()

func _process(delta):
	if frames_since_damage < GlobalPlayer.immunity_frames:
		frames_since_damage += 1
	if !dashing and frame_since_dash < DASH_COOLDOWN:
		frame_since_dash += 1

func _physics_process(delta):
	add_gravity(delta)
	animation()
	movement()
	move_and_slide()

func movement():
	if Input.is_action_just_pressed("dash_key") and frame_since_dash >= DASH_COOLDOWN and GlobalPlayer.player_dash:
		frame_since_dash = 0
		if !dashing:
			dashing = true
			dash_time = 0
			dash_dir *= 0
			if Input.is_action_pressed("left_key"):
				dash_dir.x -= DASH_VELOCITY
			if Input.is_action_pressed("right_key"):
				dash_dir.x += DASH_VELOCITY
			#if Input.is_action_pressed("up_key"):
			#	dash_dir.y -= DASH_VELOCITY
			if Input.is_action_pressed("down_key"):
				dash_dir.y += DASH_VELOCITY
			if dash_dir.x == 0 and dash_dir.y == 0:
				dashing = false
	
	if dashing and dash_time <= MAX_DASH_TIME:
		dash_time += 1
		velocity = dash_dir
		if dash_time >= MAX_DASH_TIME - 6:
			velocity *= 0
	elif dash_time > MAX_DASH_TIME:
		dashing = false
	
	# handles jump 
	if Input.is_action_just_pressed("jump_key") and is_on_floor() and !dashing:
		is_jumping = true
		jumps_remaining = GlobalPlayer.player_jumps
	elif Input.is_action_just_pressed("jump_key") and jumps_remaining > 1 and !dashing:
		is_jumping = true
		jumps_remaining -= 1
	
	if is_jumping:
		if Input.is_action_pressed("jump_key") and jump_time <= MAX_JUMP_TIME:
			jump_time += 1
			velocity.y = JUMP_VELOCITY
		else:
			jump_time = 0
			is_jumping = false
		
	if Input.is_action_just_released("jump_key") and velocity.y < 0:
		velocity.y += 180
	
	# handles left and right
	if !dashing:
		var direction = Input.get_axis("left_key", "right_key")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

func animation():
	pass

func add_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func damage(damage: int,reset: bool, direction: int):
	if frames_since_damage >= GlobalPlayer.immunity_frames:
		frames_since_damage = 0
		knockback(direction)
		if GlobalPlayer.health - damage <= 0:
			respawn_to_spawn()
		else:
			GlobalPlayer.health - damage
		
		if reset:
			reset()

func knockback(direction):
	velocity.y -= 20
	velocity.x += 200 * direction

func reset():
	pass

func respawn_to_spawn():
	pass
