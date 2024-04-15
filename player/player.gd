extends CharacterBody2D

signal health_updated(health)
signal killed()
signal money_updated(money)

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DASH_VELOCITY = 900
var jumps_remaining = 0
var dash_dir = Vector2(0, 0)
var last_direction = 1

var health = GlobalPlayer.player_max_health: 
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

var money = 0:
	set(value):
		var prev_money = money
		money = value
		if money != prev_money:
			emit_signal("money_updated", money)
	get:
		return money

@onready var invulnerability_timer = $"invulnerability timer"
@onready var jump_timer = $"jump timer"
@onready var dash_timer = $"dash timer"
@onready var dash_cooldown_timer = $"dash cooldown timer"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	add_gravity(delta)
	animation()
	movement()
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
	if is_on_floor() and !Input.is_action_pressed("jump_key") and jumps_remaining != GlobalPlayer.player_jumps:
		jumps_remaining = GlobalPlayer.player_jumps

	if Input.is_action_pressed("jump_key") and jumps_remaining > 0 and !jump_timer.is_stopped():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("jump_key") and jumps_remaining > 0 and jump_timer.is_stopped():
		velocity.y = JUMP_VELOCITY
		jump_timer.start()
	elif Input.is_action_just_released("jump_key") and velocity.y <= 30:
		velocity.y += 300
	
	if Input.is_action_just_released("jump_key"):
		jumps_remaining -= 1

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
		health -= damage

func knockback(direction):
	velocity.y -= 20
	velocity.x += 200 * direction

func reset():
	pass

func respawn_to_spawn():
	pass

func kill():
	respawn_to_spawn()

func _on_invulnerability_timer_timeout():
	pass # reset animation


func _on_attacked_hitbox_body_entered(body):
	if body.has_node("damager"):
		var damage = body.plr_damage
		var reset = false
		var direction = (body.position - self.position).normalized()
		health -= damage
		print_debug("damaged")
