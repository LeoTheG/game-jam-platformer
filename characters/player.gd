extends CharacterBody2D

# create custom signal to be detected by the global script
signal player_died

var Bullet = load("res://projectiles/bullet.tscn")

@onready var animatedSprite2D = $AnimatedSprite2D
@onready var effectsAnimatedSprite2D = $EffectsAnimatedSprite2D
@onready var effectsAnimationPlayer = $EffectsAnimationPlayer
@onready var invincibilityTimer = $InvincibilityTimer
@onready var healthBar = $HealthBarColorRect

const SPEED = 300.0
const JUMP_VELOCITY = -650.0
const HEALTH_BAR_MAX_WIDTH_PX = 40
const BULLET_POSITION_RIGHT = Vector2(63, -1)
const BULLET_POSITION_LEFT = Vector2(-65, -1)
const MAX_NUM_TIMES_JUMPED_IN_AIR = 1
const WEAPON_COOLDOWN_SECONDS = 0.05
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
	elif velocity.x < 0:
		facingDirection = "left"
		animatedSprite2D.set_flip_h(true)

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
	if isHoldingMouseDown:
		if actionRestTimer.time_left == 0:
			handleFireWeapon()


func handleFireWeapon():
	spawnBullet()
	setActionTimer()


func spawnBullet():
	var bullet = Bullet.instantiate()

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

		# restart player position, hp, etc
		set_position(Vector2(5, -78))
		animatedSprite2D.set_flip_h(false)
		health = MAX_HEALTH
		return

	healthBar.set_size(Vector2(HEALTH_BAR_MAX_WIDTH_PX * health / 100, 10))
	healthBar.show()

	invincibilityTimer.start()
	animatedSprite2D.set_modulate(Color(1, 0, 0, 1))
