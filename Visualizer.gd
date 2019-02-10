extends Node2D

# Declare member variables here. Examples:

onready var global = get_node("/root/global")

var GrappleGun
var GrappleHook

# Called when the node enters the scene tree for the first time.
func _ready():
	global.setCurrentVisualizer(self)

func _process(delta):
	update()
	
func _draw():
#	for item in get_node("../Consumables").get_children():
#		draw_circle(item.get_global_position(), 20, Color(0.8, 0.8, 0, 0.5))
#		if item.is_class("PinJoint2D"):
#
#			var from = item.get_node(item.get_node_a()).get_global_position()
#			var to = item.get_node(item.get_node_b()).get_global_position()
#			draw_line(from, to, Color(0, 0, 0.8))

	if global.RootSceneManager.CurrentState == global.RootSceneManager.STATES.playing and GrappleHook != null:
		if is_instance_valid(GrappleGun) and is_instance_valid(GrappleHook):
			var posA = GrappleGun.get_global_position()
			var posB = GrappleHook.get_global_position()
			var lineColor = Color(0.1, 0.1, 0.1)
			var lineWidth = 4.0
			var antialias = false
			draw_line(posA, posB, lineColor, lineWidth, antialias)
		
		
	
func _on_GrappleGun_hook_launched(nodeA, nodeB):
	GrappleGun = nodeA
	GrappleHook = nodeB
	
func _on_GrappleGun_hook_released():
	GrappleHook = null
	

