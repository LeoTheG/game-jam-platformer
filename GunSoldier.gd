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

const INITIAL_POSITION = Vector2(710, -9)


func _ready():
	$Timer.connect("timeout", _on_timer_timeout)
	set_position(INITIAL_POSITION)


func _physics_process(delta):
	var pos = get_global_position()
	var playerPos = Globals.Player.get_global_position()
	var _distance = pos.distance_to(playerPos)
	self.distance = _distance
	var distanceDiff = playerPos - pos
	if distanceDiff.x < 0:
		$AnimatedSprite.set_flip_h(true)
		isFacingRight = false
	else:
		$AnimatedSprite.set_flip_h(false)
		isFacingRight = true

	if distance < 620:
		isCloseToPlayer = true
	else:
		isCloseToPlayer = false
		$AnimatedSprite.play("Idle")

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	move_and_slide()


func handleFireWeapon():
	spawnBullet()
	$AnimatedSprite.play("Shooting")


var distance = 0


func spawnBullet():
	var bullet = Bullet.instantiate()
	var enemyPosition = get_global_position()
	# angle bullet based on mouse position relative to player position
	var randX = randf_range(-300, 300)
	var randY = randf_range(-100, 100)
	var playerPosition = Globals.Player.get_global_position()
	var randPlayerPos = playerPosition + Vector2(randX, randY)
	var angle
	if distance < 450:
		angle = enemyPosition.angle_to_point(playerPosition)
	else:
		angle = enemyPosition.angle_to_point(randPlayerPos)

	# limit angle based on player's facing direction
	# prevent shooting behind player
	bullet.set_rotation(angle)
	if isFacingRight:
		bullet.set_global_position(get_global_position() + Vector2(30, 10))
	else:
		bullet.set_global_position(get_global_position() + Vector2(-50, 10))

	Globals.Root.add_child(bullet)


func _on_timer_timeout():
	if isCloseToPlayer:
		handleFireWeapon()
