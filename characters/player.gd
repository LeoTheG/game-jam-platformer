extends CharacterBody2D

var Bullet = load("res://projectiles/bullet.tscn")

@onready var animatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -650.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
# idk where this is set in the project settings, copied from the docs
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var facingDirection = "right"
var actionRestTimer

const BULLET_POSITION_RIGHT = Vector2(63, -1)
const BULLET_POSITION_LEFT = Vector2(-65, -1)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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


var isHoldingMouseDown = false


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
	print("angle is ", angle)

	# limit angle based on player's facing direction
	# prevent shooting behind player
	if facingDirection == "right":
		if not (angle > -PI / 2 and angle < PI / 2):
			return
		# angle = clamp(angle, -PI / 2, PI / 2)
	elif facingDirection == "left":
		if not ((angle > PI / 2 and angle < PI) or (angle < -PI / 2 and angle > -PI)):
			return
		# angle = clamp(angle, PI / 2, PI)

	bullet.set_rotation(angle)

	Globals.Root.add_child(bullet)

	if facingDirection == "right":
		bullet.set_position(get_position() + BULLET_POSITION_RIGHT)
	else:
		bullet.set_position(get_position() + BULLET_POSITION_LEFT)


func _ready():
	actionRestTimer = Timer.new()
	actionRestTimer.one_shot = true
	add_child(actionRestTimer)


var WEAPON_COOLDOWN_SECONDS = 0.05


func setActionTimer():
	actionRestTimer.start(WEAPON_COOLDOWN_SECONDS)
