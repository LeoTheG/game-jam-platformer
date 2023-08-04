extends CharacterBody2D

# create custom signal to be detected by the global script
signal player_died

var Bullet = load("res://projectiles/bullet.tscn")

@onready var animatedSprite2D = $AnimatedSprite2D
@onready var effectsAnimatedSprite2D = $EffectsAnimatedSprite2D
@onready var effectsAnimationPlayer = $EffectsAnimationPlayer
@onready var invincibilityTimer = $InvincibilityTimer
@onready var healthBar = $HealthBarColorRect
@onready var area2D = $Area2D
@onready var arm = $Arm

const SPEED = 300.0
const JUMP_VELOCITY = -650.0
const HEALTH_BAR_MAX_WIDTH_PX = 40
const BULLET_POSITION_RIGHT = Vector2(63, -1)
const BULLET_POSITION_LEFT = Vector2(-65, -1)
const MAX_NUM_TIMES_JUMPED_IN_AIR = 1
const WEAPON_COOLDOWN_SECONDS = 0.5
const MAX_HEALTH = 100

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facingDirection = "right"
var actionRestTimer
var numTimesJumpedInAir = 0
var isHoldingMouseDown = false
var health = MAX_HEALTH


func _ready():
	actionRestTimer = Timer.new()
	actionRestTimer.one_shot = true
	add_child(actionRestTimer)

	invincibilityTimer.connect("timeout", _on_invincibilityTimer_timeout)
	area2D.connect("body_entered", _on_area2D_body_entered)

	# connect to mouse movement signal


const TILE_ATLAS_COORDS_OUT_OF_BOUNDS = Vector2i(2, 0)


func _on_area2D_body_entered(body):
	if body is TileMap:
		var cellPosition = body.local_to_map(area2D.get_global_position() + Vector2(0, 0))
		var cellAtlasCoords = body.get_cell_atlas_coords(0, cellPosition)

		if cellAtlasCoords == TILE_ATLAS_COORDS_OUT_OF_BOUNDS:
			player_died.emit()


func _on_invincibilityTimer_timeout():
	animatedSprite2D.set_modulate(Color(1, 1, 1, 1))
	healthBar.hide()


func _physics_process(delta):
	if Globals.GameOverScreen.is_visible():
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		numTimesJumpedInAir = 0

	# Handle Jump.
	if (
		Input.is_action_just_pressed("jump")
		and (is_on_floor() or numTimesJumpedInAir < MAX_NUM_TIMES_JUMPED_IN_AIR)
	):
		velocity.y = JUMP_VELOCITY
		if not is_on_floor():
			numTimesJumpedInAir += 1
			effectsAnimationPlayer.seek(0)
			effectsAnimationPlayer.play("activate")

	var direction = Input.get_axis("left", "right")

	if velocity.x > 0:
		facingDirection = "right"
		animatedSprite2D.set_flip_h(false)
		arm.set_flip_v(false)
	elif velocity.x < 0:
		facingDirection = "left"
		animatedSprite2D.set_flip_h(true)
		arm.set_flip_v(true)

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _input(_event):
	if Input.is_action_pressed("fire_weapon"):
		isHoldingMouseDown = true
	else:
		isHoldingMouseDown = false


func _process(_delta):
	var mouse_position = get_global_mouse_position()

	# angle from player to mouse
	var angle = get_global_position().angle_to_point(mouse_position)

	# rotate arm
	arm.set_rotation(angle)

	if isHoldingMouseDown:
		if actionRestTimer.time_left == 0:
			handleFireWeapon()


func handleFireWeapon():
	spawnBullet()
	setActionTimer()


func spawnBullet():
	var bullet = Bullet.instantiate()
	bullet.isFiredByPlayer = true

	# angle bullet based on mouse position relative to player position
	var mousePosition = get_global_mouse_position()
	var playerPosition = get_global_position()
	var angle = playerPosition.angle_to_point(mousePosition)

	# limit angle based on player's facing direction
	# prevent shooting behind player
	if facingDirection == "right":
		if not (angle > -PI / 2 and angle < PI / 2):
			if angle > PI / 2:
				angle = PI / 2
			else:
				angle = -PI / 2
	elif facingDirection == "left":
		if not ((angle > PI / 2 and angle < PI) or (angle < -PI / 2 and angle > -PI)):
			if angle > 0:
				angle = PI / 2
			else:
				angle = -PI / 2

	bullet.set_rotation(angle)

	Globals.Root.add_child(bullet)

	if facingDirection == "right":
		bullet.set_position(get_position() + BULLET_POSITION_RIGHT)
	else:
		bullet.set_position(get_position() + BULLET_POSITION_LEFT)


func setActionTimer():
	actionRestTimer.start(WEAPON_COOLDOWN_SECONDS)


# called by enemies, dangerous objects, projectiles, etc
func damage(amount):
	if invincibilityTimer.time_left > 0:
		return

	health -= amount

	if health <= 0:
		player_died.emit()
		return

	healthBar.set_size(Vector2(HEALTH_BAR_MAX_WIDTH_PX * health / 100, 10))
	healthBar.show()

	invincibilityTimer.start()
	animatedSprite2D.set_modulate(Color(1, 0, 0, 1))
