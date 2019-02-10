extends RigidBody2D

# Declare member variables here. Examples:
var Velocity = Vector2(0.0, 0.0)
var Gravity = 0.0
var Speed = 50
var Direction = 0
var GameSpeed = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if Input.is_action_pressed("move_right"):
		Direction = 1
	elif Input.is_action_pressed("move_left"):
		Direction = -1
	else:
		Direction = 0
	Velocity.x = Speed * Direction * delta * GameSpeed
	#Velocity.y += Gravity * delta * GameSpeed
	var floor_normal = Vector2(0.0, 1.0)
	var stop_on_slope = true
	var max_slides = 4
	var floor_max_angle = 0.785398
	var infinite_inertia = true
	#move_and_slide( Velocity, floor_normal, stop_on_slope, max_slides, floor_max_angle, infinite_inertia )
	apply_central_impulse(Velocity)
	
	
#
#
#func _input(event):
#	if event.is_action_pressed("move_right"):
#		print("moving right")
#		Direction = 1
#	elif event.is_action_pressed("move_left"):
#		Direction = -1
#	else:
#		Direction = 0

	
	