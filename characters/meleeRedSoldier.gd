extends CharacterBody2D

var Bullet = load("res://projectiles/bullet.tscn")
var playEveryOtherSecond = false
var animationPlaying = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var isCloseToPlayer = false
var isFacingRight = true

const INITIAL_POSITION = Vector2(600, -9)


func _ready():
	set_position(INITIAL_POSITION)


func _physics_process(delta):
	var pos = get_global_position()
	var playerPos = Globals.Player.get_global_position()
	var _distance = pos.distance_to(playerPos)
	self.distance = _distance
	var distanceDiff = playerPos - pos
	if distanceDiff.x < 0:
		$AnimatedSprite2D.set_flip_h(true)
		isFacingRight = false
	else:
		$AnimatedSprite2D.set_flip_h(false)
		isFacingRight = true

	if distance < 100:
		isCloseToPlayer = true
		$AnimatedSprite2D.play("Slash")
	else:
		isCloseToPlayer = false
		$AnimatedSprite2D.play("Idle")

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	move_and_slide()


var distance = 0
