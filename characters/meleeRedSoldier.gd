extends CharacterBody2D

class_name MeleeSoldier
@onready var target = Globals.Player
var playEveryOtherSecond = false
var animationPlaying = false

const enemyName = "MeleeSoldier"
const SPEED = 10000
const JUMP_VELOCITY = -700.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var isCloseToPlayer = false
var isFacingRight = true
var health = 10
const INITIAL_POSITION = Vector2(1300, -9)


func _ready():
	#set_position(INITIAL_POSITION)
	pass

func _physics_process(delta):
	var pos = get_global_position()
	var playerPos = Globals.Player.get_global_position()
	var _distance = pos.distance_to(playerPos)
	self.distance = _distance
	if _distance < 650:
		#self.velocity = global_position.direction_to(target.global_position) * SPEED * delta
		var newVelocity = global_position.direction_to(target.global_position) * SPEED * delta
		self.velocity.x = newVelocity.x
		
		if newVelocity.y < -150 and is_on_floor():
			self.velocity.y = JUMP_VELOCITY
		move_and_slide()
		
	self.distance = _distance
	var distanceDiff = playerPos - pos
	if distanceDiff.x < 0:
		$AnimatedSprite2D.set_flip_h(true)
		isFacingRight = false
		#self.velocity.x = -5
		
	else:
		$AnimatedSprite2D.set_flip_h(false)
		isFacingRight = true
		#self.velocity.x = 5
	if distance < 100:
		isCloseToPlayer = true
		$AnimatedSprite2D.play("Slash")
		Globals.Player.damage(5)

	else:
		isCloseToPlayer = false
		$AnimatedSprite2D.play("Idle")

	# Add the gravity.
	if not is_on_floor():
		velocity.y +=  gravity * delta
	
	#move_and_slide()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.


var distance = 0

func damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
