extends Node2D

# Declare member variables here. Examples:
onready var global = get_node("/root/global")
signal start_button_pressed()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		startLevel()
	elif Input.is_action_just_pressed("ui_cancel"):
		quitGame()

func startLevel():
	$AnimationPlayer.play("launchLevel1")
	$Level1StartTimer.start()
	
func quitGame():
	get_tree().quit()
	

func _on_StartButton_pressed():
	startLevel()
	
func _on_Level1StartTimer_timeout():
	emit_signal("start_button_pressed")


func _on_ExitButton_pressed():
	quitGame()

func _on_DryerSprite_gui_input(event):
	if Input.is_action_just_pressed("ui_accept"):
		startLevel()
		#pass
