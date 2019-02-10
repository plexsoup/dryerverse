extends KinematicBody2D

# Declare member variables here. Examples:

enum MODES { horizontal, asteroids }
export var CurrentMode = MODES.horizontal
export var RoamingRange = 200


onready var global = get_node("/root/global")
var Velocity : Vector2 = Vector2(0, 0)
var Direction : int = 1
var Speed : int = 200
var UP : Vector2 = Vector2(0, 1)
var InitialPosition : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	start()

func start():
	InitialPosition = get_global_position()
	
	
#func applyGravity(delta):
#	Velocity.y += global.Gravity * delta * global.GameSpeed
#	if is_on_floor():
#		Velocity.y = 10.0

func getGravityVector(delta):
	var gravityVector = Vector2(0, 0)
	gravityVector.y = global.Gravity * delta * global.GameSpeed
	if is_on_floor():
		gravityVector.y = 0
	return gravityVector

func moveLikeAsteroids(delta):
	"""
		tumble in a straight line until you hit something, then change direction
	"""
	
	if Velocity == Vector2(0, 0):
		var randRotation = randf() * 2*PI
		Velocity = Vector2(1.0, 0).rotated(randRotation) * Speed
	var collisionObj = move_and_collide(Velocity * delta, false)
	if collisionObj:
		var bounceVector = collisionObj.get_remainder().bounce(collisionObj.get_normal())
		#print(self.name , " Velocity " , Velocity , " , bounceVector ", bounceVector  )
		move_and_collide(bounceVector)
		Velocity = bounceVector.normalized() * Speed
		
	
func walkBackAndForth(delta, center, furthestDistance ):
	if get_global_position().x < center.x - furthestDistance:
		Direction = 1
		
	elif get_global_position().x > center.x + furthestDistance:
		Direction = -1
	
	if Direction > 0:
		$Sprite.set_flip_h(true)
	else:
		$Sprite.set_flip_h(false)
		
	Velocity = Vector2(Direction * Speed * delta, 0.0)
	#Velocity += getGravityVector(delta)
	
	
	#move_and_slide(Velocity, UP)
	var collisionObj = move_and_collide(Velocity, true)
	if collisionObj != null:
		if collisionObj.get_collider().name.find("Socko") > 0:
			print("RAN INTO SOCKO!")
			 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if CurrentMode == MODES.horizontal:
		walkBackAndForth( delta, InitialPosition, RoamingRange )
	elif CurrentMode == MODES.asteroids:
		moveLikeAsteroids(delta)