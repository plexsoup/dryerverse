extends KinematicBody2D

"""
Player Avatar handles movement, jumping, swinging, etc.

Notes
-----
We don't have a separate playercontroller for handling inputs, so we're not set up for AI players

We have a separate GrapplingGun which handles shooting

ISSUES
------
- swinging movement is jerky

"""

const DEBUG = false
const DebugVectorMagnitude = 1

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

#onready var Yarn = get_node("Muzzle/YarnSwing")
#var YarnCollisionPoint = Vector2(0.0, 0.0)

# Declare member variables here. Examples:
enum KEYS { up, down, left, right, shoot }
var KeysPressed = [ false, false, false, false, false ]


export var JumpVelocity = 100.0

var CurrentVelocity = Vector2(0.0, 0.0)
var MovementSpeed = 5 * 64
var MovementDirection = 1

var CrouchTicks : int = 0
var MaxCrouchTicks : int = 5
var XFriction : float  = 0.0 # not greater than 1.0
var MinIdleDownVelocity = 10.0

const UP = Vector2(0, -1.0)
#const GRAVITY = 600.0 # pixels per second (how many pixels is a meter, exactly?)

onready var GrappleGun = get_node("GrappleGun")

var RopeAttachmentNode
var DesiredRopeLength
var DesiredRopeLengthSquared

var Frame : int = 0

signal hook_release_requested()
signal level_restart_requested()


enum STATES { idle, moving, jumping, crouching, sliding, swinging, warping, running, falling, reading } 
var CurrentState = STATES.idle


func stateToString(state):
	var stateArray = [ "idle", "moving", "jumping", "crouching", "sliding", "swinging", "warping", "running", "falling", "reading" ]
	return stateArray[state]


# Called when the node enters the scene tree for the first time.
func _ready():
	#set_sync_to_physics(true)
	pass

func start():
	changeState(STATES.falling)
	GrappleGun.start(self)
	connect("hook_release_requested", GrappleGun, "_on_Character_hook_release_requested")
	connect("level_restart_requested", global.getRootSceneManager(), "_on_Character_level_restart_requested")

func jump(magnitude):
	CrouchTicks = 0
	print(self.name, " jump ", magnitude )
	CurrentVelocity.y = -1 * JumpVelocity * magnitude
	print(self.name, " CurrentVelocity.y == " , CurrentVelocity.y )
	changeState(STATES.jumping)

func applyFriction(delta):
	
	CurrentVelocity.x *= 1 - XFriction
	# *** This should incorporate delta somehow, but I haven't figured it out yet.
	
func applyUserInput(delta):
	var spriteContainer = $SpriteContainer
	if Input.is_action_pressed("move_left"):
		MovementDirection = -1
		CurrentVelocity.x = MovementSpeed * MovementDirection
	elif Input.is_action_pressed("move_right"):
		MovementDirection = 1
		CurrentVelocity.x = MovementSpeed * MovementDirection
	else: # neither left, nor right
		if CurrentState == STATES.running:
			changeState(STATES.idle)
	spriteContainer.set_scale(Vector2(MovementDirection, 1.0))

func applyGravity(delta):
	var gravityVector = Vector2(0, global.Gravity * delta)
	
	CurrentVelocity += gravityVector

	return gravityVector


func applyObstacles(delta):
	if CurrentState == STATES.jumping and CurrentVelocity.y < 0 and is_on_ceiling():
		CurrentVelocity.y = MinIdleDownVelocity

	if CurrentState == STATES.idle and CurrentVelocity.y >= 0 and is_on_floor():
		CurrentVelocity.y = MinIdleDownVelocity

	if CurrentState == STATES.running and CurrentVelocity.y >= 0 and is_on_floor():
		CurrentVelocity.y = MinIdleDownVelocity

	if CurrentState == STATES.crouching and CurrentVelocity.y >= 0 and is_on_floor():
		CurrentVelocity.y = MinIdleDownVelocity


func applySpring(delta):
	# get the initial spring length and try to maintain it.
	# up or down might shorten and lengthen the spring
	
	# treat the character as a point on a circle having radius == ropelength
		# any time the distance between the player and attachment point is longer than the desired roplength, 
		# move the player back to the desired ropelength, directly toward the attachment point
	if is_instance_valid(RopeAttachmentNode) == false:
		print(self.name, ": error in applySpring. Grappling hook no longer exists")
		return # the Grappling hook is gone. Stop using it.
		
	
	var myPos = get_global_position()
	var gunPos = $GrappleGun/Muzzle.get_global_position()
	var hookPos = RopeAttachmentNode.get_global_position()
	var testPos = myPos + CurrentVelocity

	var testDistToHook = testPos.distance_to(hookPos)
	
	if testDistToHook > DesiredRopeLength:
		# **** TODO: fix the rope-swinging mechanic so it doesn't have so much apparent friction
		
		var vectorToHook = hookPos - testPos

		# drag the player back to the circle radius
		var distDifference = testDistToHook - DesiredRopeLength
		var vectorToCorrectSwingingArc = vectorToHook.normalized() * distDifference
		CurrentVelocity += vectorToCorrectSwingingArc
		CurrentVelocity.x = clamp(CurrentVelocity.x, -10000, 10000)
		CurrentVelocity.y = clamp(CurrentVelocity.y, -10000, 10000)
			


func move(delta):
	
	applyUserInput(delta)
	applyGravity(delta)
	applyObstacles(delta)
	applyFriction(delta)
	
	match CurrentState: # idle, moving, jumping, crouching, sliding, swinging, warping, running 
		STATES.swinging:
			applySpring(delta)
		STATES.warping:
			pass
		STATES.jumping:
			pass
		STATES.crouching:
			pass
		STATES.running:
			pass
		STATES.idle:
			pass
		STATES.falling:
			pass

	checkForStateTransition()
	

	move_and_slide(CurrentVelocity, UP)
	var numCollisions = get_slide_count()
	for indexNum in numCollisions:
		var collision = get_slide_collision(indexNum)
		if collision.get_collider().is_in_group("enemies"):
			# restart the level. you hit a dust bunny
			emit_signal("level_restart_requested")

	
	#update() # calls _draw()
	

func changeState(newState):
	var animationPlayer = $AnimationPlayer

	match newState:
		STATES.idle:
			animationPlayer.play("idle")
			XFriction = 0.5
		STATES.crouching:
			animationPlayer.play("crouch")
			XFriction = 0.75
			$CrouchTimer.start()
		STATES.jumping:
			animationPlayer.play("jump")
			XFriction = 0.01
		STATES.swinging:
			animationPlayer.play("swing")
			XFriction = 0.01
		STATES.running:
			animationPlayer.play("run")
			XFriction = 0.01
		STATES.falling:
			animationPlayer.play("fall")
			XFriction = 0.01
	
	CurrentState = newState
	
func checkForStateTransition():
	""" 
	Triggered in physics process, each tick this will compare the current state with the situation
	to see if a new state is warranted. Note. This isn't the only way to change states. Signals will also trigger state changes.
	See also: _on_GrapplingHook_stuck and _on_GrapplingHook_released
	"""
	match CurrentState:
		STATES.idle:
			if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
				changeState(STATES.running)
			if Input.is_action_pressed("crouch"):
				changeState(STATES.crouching)
		STATES.jumping:
			if is_on_floor() and CurrentVelocity.y > 0: # just landed
				changeState(STATES.idle)
		STATES.crouching:
			if Input.is_action_pressed("crouch") == false:
				print("jumping!")
				CurrentVelocity.y = -1
				jump(clamp(CrouchTicks, 1, MaxCrouchTicks))
		STATES.swinging:
			if Input.is_action_pressed("crouch"):
				emit_signal("hook_release_requested")
				jump(3)
				changeState(STATES.jumping) # Should be STATES.falling
			# NEED A NEW STATE: Jumping on yarn.
		STATES.running:
			if Input.is_action_pressed("crouch"):
				changeState(STATES.crouching)
			if is_on_floor() == false and is_on_wall() == false and CurrentVelocity.y > MinIdleDownVelocity:
				changeState(STATES.falling)
		STATES.falling:
			if is_on_floor() and CurrentVelocity.y > 0:
				changeState(STATES.idle)



func hidePlayer():
	$SpriteContainer/Sprite.hide()
	$CollisionShape2D.call_deferred("set_disabled", true)
	CurrentState = STATES.warping
	CurrentVelocity = Vector2(0.0, 0.0)

func end():
	queue_free()

func _physics_process(delta):	
	if CurrentState != STATES.reading:
		move(delta)
		Frame += 1

# Moved this logic to checkStateTransitions()
#func _input(event):
#
#	# **** GAME FEEL BUG: if you start holding crouch while jumping, you should start crouching as soon as you land.
#	if Input.is_action_just_pressed("crouch") and CurrentState == STATES.running or CurrentState == STATES.idle:
#		#print(self.name, " crouching" )
#		CrouchTicks = 0
#		$CrouchTimer.start()
#		$AnimationPlayer.play("crouch")
#		CurrentState = STATES.crouching
#
#		# if you were swinging, release the grappling hook
#	elif Input.is_action_just_pressed("crouch") and CurrentState == STATES.swinging:
#		print("trying to release the hook")
#		emit_signal("hook_release_requested")
#
#	elif Input.is_action_just_released("crouch") and CurrentState == STATES.crouching:
#		#print(self.name, " jumping")
#		jump(CrouchTicks)
#		$AnimationPlayer.play("jump")


func _on_CrouchTimer_timeout():
	#print("CrouchTick")
	CrouchTicks += 1
	if CrouchTicks < MaxCrouchTicks and CurrentState == STATES.crouching:
		$CrouchTimer.start()

func _on_GrapplingHook_stuck(hookNode):
	changeState(STATES.swinging)
	RopeAttachmentNode = hookNode
	DesiredRopeLength = get_global_position().distance_to( RopeAttachmentNode.get_global_position() )

	if is_on_floor(): # make it a bit shorter so you don't slide into the floor
		DesiredRopeLength -= 75.0

	if DesiredRopeLength < 75: # make it a bit longer so you don't get stuck on the ceiling
		DesiredRopeLength = 75
		
	DesiredRopeLengthSquared = pow(DesiredRopeLength, 2.0)
	# print(self.name, " DesiredRopeLength == ", DesiredRopeLength)

func _on_GrappleGun_hook_released():
	RopeAttachmentNode = null
	changeState(STATES.idle)

func _on_dialogBox_initialized():
	CurrentState = STATES.reading
	
func _on_dialogBox_completed():
	CurrentState = STATES.idle
	