extends Node2D

# Declare member variables here. Examples:
onready var global = get_node("/root/global")
signal start_button_pressed()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartButton_pressed():
	$AnimationPlayer.play("launchLevel1")
	$Level1StartTimer.start()

func _on_Level1StartTimer_timeout():
	emit_signal("start_button_pressed")


func _on_ExitButton_pressed():
	get_tree().quit()
