extends Node2D

# Declare member variables here. Examples:
const FORWARD = Vector2(1.0, 0.0)
export var Speed = 2200

enum STATES { flying, exploding, sticking, stuck, loose, falling }
var CurrentState = STATES.flying

export var Sticky = true
export var MaxDistanceSquared = 250000

var MyGun
var FallVelocity = Vector2(0.0, 0.0)

var AttachedTo

signal stuck(node)
signal destroyed(node)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(myGun):
	MyGun = myGun
	connect("destroyed", MyGun, "_on_bullet_destroyed")


func move(delta):
	set_position(get_position() + FORWARD.rotated(get_rotation()) * Speed * delta * global.GameSpeed)


func startFalling():
	CurrentState = STATES.falling
	$StickyArea/CollisionShape2D.call_deferred("set_disabled", true)

func fall(delta):
	FallVelocity.y += global.Gravity * delta * global.GameSpeed
	
	set_global_position(get_global_position() + FallVelocity)
	
func stick(body):
	CurrentState = STATES.stuck
	# now tell the scene to attach a pin joint from the player to the bullet
	# we might need a staticBody2D
	#print(self.name, " sticking to : ", body.get_class() )
	if body.is_class("TileMap") == false:
		AttachedTo = body
	
	connect("stuck", global.getCurrentPlayer(), "_on_GrapplingHook_stuck")
	connect("stuck", MyGun, "_on_GrapplingHook_stuck")
	emit_signal("stuck", self)

func explode():
	AttachedTo = null
	CurrentState = STATES.exploding
	
	$Explosion.set_emitting(true)
	#$CollisionShape2D.call_deferred("set_disabled", true)
	$StickyArea/CollisionShape2D.call_deferred("set_disabled", true)

	$DestructionTimer.start()
	$Sprite.hide()

func checkDistanceFromGun():
	
	
	if get_global_position().distance_squared_to(MyGun.get_global_position()) > MaxDistanceSquared:
		emit_signal("destroyed", self)
		queue_free()
		#$DestructionTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if CurrentState == STATES.flying:
		move(delta)
		checkDistanceFromGun()
	if CurrentState == STATES.falling:
		fall(delta)
	
	if CurrentState == STATES.stuck: # stay with your target, in case they move.
		if AttachedTo != null:
			set_global_position(AttachedTo.get_global_position())
		
	update()




#func _on_Bullet_body_entered(body):
func _on_StickyArea_body_entered(body):
	
	if body != global.getCurrentPlayer() and body.name.find("Exit") == -1:
		#print(self.name, " entered ", body.name)
		if Sticky == false:
			explode()
		elif CurrentState != STATES.stuck:
			stick(body)

func _on_DestructionTimer_timeout():
	queue_free()

func _on_GrappleGun_hook_released():
	
	# **** GAME FEEL
		# falling looks dumb. maybe explode instead?
	
	# startFalling()
	explode()

	$DestructionTimer.start()
	

