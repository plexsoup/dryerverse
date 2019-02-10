extends Node2D

# Declare member variables here. Examples:
onready var Yarn = get_node("Muzzle/YarnSwing")
var YarnCollisionPoint = Vector2(0.0, 0.0)

enum STATES { idle, firing, extended, reloading, stuck } # a grapple gun should be single shot.
var CurrentState = STATES.idle

var HookNode # grappling hook
onready var RaycastNode = $Muzzle/GrappleRay 

signal hook_launched(nodeA, nodeB)
signal hook_released()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(playerNode):
	connect("hook_launched", global.getCurrentVisualizer(), "_on_GrappleGun_hook_launched")
	connect("hook_released", global.getCurrentVisualizer(), "_on_GrappleGun_hook_released")
	connect("hook_released", playerNode, "_on_GrappleGun_hook_released")


func updateRayCast(targetNode):
	
	# could also use is_queued_for_deletion
	# see discussion here: https://www.reddit.com/r/godot/comments/8hp3ok/use_call_deferredfree_instead_of_queue_free/
	if is_instance_valid(targetNode) == true:
		RaycastNode.set_cast_to(targetNode.get_global_position() - get_global_position() )
	else:
		HookNode = self

func detectRayCollisions():
	
	if RaycastNode.is_colliding():
		#print(self.name, " ray colliders: ", RaycastNode.get_collider())
		var collisionPoint = RaycastNode.get_collision_point()
		# move the bullet to the collision point?
		HookNode.set_global_position(collisionPoint)

func _process(delta):
	if CurrentState == STATES.stuck:
		updateRayCast(HookNode)
		detectRayCollisions()
		update()
		
func shootBullet():
	# single shot mechanism
	if CurrentState == STATES.idle:
		var target = get_global_mouse_position()
		var vectorToTarget = target - $Muzzle.get_global_position()
		var Bullet = load("res://effects/Bullet.tscn")
		var newBullet = Bullet.instance()
		newBullet.set_global_position($Muzzle.get_global_position())

		global.getRootSceneManager().get_node("Consumables").add_child(newBullet)
			# **** adding a child to another scene is dangerously tight coupling.
			# consider moving this to a signal instead.

		newBullet.look_at(target)
		
		newBullet.start(self)
		connect("hook_released", newBullet, "_on_GrappleGun_hook_released")
		CurrentState = STATES.extended

		emit_signal("hook_launched", self, newBullet) # so the visualizer can draw lines in global coordinates
	
func releaseGrapplingHook():
	# the player character might need a signal to release the rope
	emit_signal("hook_released") # for player AND bullet
	reloadGrapplingHook()
	
func reloadGrapplingHook():
	CurrentState = STATES.idle
	HookNode = null
	updateRayCast(self)
	

func _input(event):
	if global.getCurrentPlayer().CurrentState == global.getCurrentPlayer().STATES.reading:
		return # don't shoot during dialog boxes
		
	if Input.is_action_just_pressed("shoot"):
#		shootGrapplingHook()
		if CurrentState == STATES.idle:
			shootBullet()
		elif CurrentState == STATES.extended or CurrentState == STATES.stuck:
			releaseGrapplingHook()
			shootBullet() # added for game feel.

func _on_GrapplingHook_stuck(hookNode):
	if CurrentState == STATES.extended:
		CurrentState = STATES.stuck
		HookNode = hookNode

func _on_Character_hook_release_requested():
	# Game feel: crouching should release. shooting twice should just shoot twice
	releaseGrapplingHook()
	
func _on_bullet_destroyed(bulletNode):
	reloadGrapplingHook()

	
	
	