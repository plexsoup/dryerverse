extends Node2D

# Declare member variables here. Examples:
onready var global = get_node("/root/global")
signal level_completed() # for Initializer.gd


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_Exit_body_entered(body):
	if body == global.getCurrentPlayer():
		emit_signal("level_completed")
		if has_node("Particles2D"):
			$Particles2D.set_emitting(true)
