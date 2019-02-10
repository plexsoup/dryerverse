extends RigidBody2D

# IDEAS:
	# what if: the player can't move left/right, only jump and fall.
		# the level is constantly rotating.
		# you'd have to instance the player as a peer of the level, not a child.

# affordances:
	# jump
	# grab
	# hang
	# fall
	# kick / whip
	# unravel and swing
	# reassemble / re-ravel / knit


# Declare member variables here. Examples:
enum KEYS { up, down, left, right, shoot }
var KeysPressed = [ false, false, false, false, false ]

enum STATES { idle, moving, jumping, sliding, swinging, warping }
var CurrentState = STATES.idle

export var JumpVelocity = 400

var CurrentVelocity = Vector2(0.0, 0.0)
var MovementSpeed = 5 * 64
var MovementDirection = 1

const UP = Vector2(0, -1.0)
const GRAVITY = 600.0 # pixels per second (how many pixels is a meter, exactly?)

# Called when the node enters the scene tree for the first time.
func _ready():
	#set_sync_to_physics(true)
	pass
	$FloorDetector.set_exclude_parent_body(true)

func jump():
	CurrentVelocity.y -= JumpVelocity

func move(delta):
	CurrentVelocity.y += GRAVITY * delta
	if CurrentState != STATES.warping:
		#move_and_slide(CurrentVelocity, UP)
		apply_central_impulse( CurrentVelocity )


func checkState():
	var isStanding = false
	
	if is_colliding() or $FloorDetector.is_colliding():
		isStanding = true
	
	if CurrentVelocity.y >= 0 and isStanding:
		CurrentState = STATES.idle
		CurrentVelocity.y = 0.1

func showDebugInfo():
	$CanvasLayer/StateLabel.set_text("State: " + stateToString(CurrentState))
	$CanvasLayer/VelocityLabel.set_text("Velocity: (" + str(int(CurrentVelocity.x)) + ", " + str(int(CurrentVelocity.y)) + ")" )

func stateToString(state):
	var stateArray = [ "idle", "moving", "jumping", "sliding", "swinging", "warping" ]
	return stateArray[state]

func hidePlayer():
	$Sprite.hide()
	$CollisionShape2D.call_deferred("set_disabled", true)
	CurrentState = STATES.warping
	CurrentVelocity = Vector2(0.0, 0.0)

func end():
	queue_free()

func _physics_process(delta):
	checkState()
	move(delta)
	showDebugInfo()


func _input(event):

	if Input.is_action_pressed("move_right"):
		MovementDirection = 1
		$Sprite.set_flip_h(false)

		CurrentVelocity.x = MovementSpeed * MovementDirection
	elif Input.is_action_pressed("move_left"):
		MovementDirection = -1
		$Sprite.set_flip_h(true)

		CurrentVelocity.x = MovementSpeed * MovementDirection

	else:
		# **** should probably skid to a halt instead
		CurrentVelocity.x = 0.0

	if Input.is_action_pressed("jump") and CurrentState != STATES.jumping:
		# *** should also check   and is_on_floor().
		CurrentVelocity.y -= JumpVelocity
		CurrentState = STATES.jumping

