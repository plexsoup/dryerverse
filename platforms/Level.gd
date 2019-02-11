extends Node2D

export (float) var RotationSpeed = 0.0


# change dialog box to a number of lines..
export var IntroText = [
	"Aaah, the dryer; my favorite place...",
	"I love it here. Clean, Warm, hanging out with my partner...",
	"...",
	"Where's my partner?",
	"((Use ASD and Space to get around.))"
]

onready var global = get_node("/root/global")

signal level_initialized() # for Initializer.gd
signal restart_requested()

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("restart_requested", global.getRootSceneManager(), "_on_level_restart_requested")
	pass # Replace with function body.

	
func _process(delta):
	#print(self.name, " rotating" )
	self.set_global_rotation(self.get_global_rotation()+RotationSpeed * delta)

		

func getExit():
	if has_node("Exit"):
		return $Exit
	else:
		return null
	
func start():
#	spawnPlayer()
	emit_signal("level_initialized")
	
	spawnDialogBox()

func spawnDialogBox():
	var DialogBox = preload("res://GUI/DialogBox.tscn")
	var newDialogBox = DialogBox.instance()
	add_child(newDialogBox)
	newDialogBox.set_global_position(global.getCurrentPlayer().get_global_position() + Vector2(0, -200))
	
	newDialogBox.start(IntroText, global.getCurrentPlayer())


func victory():
	if has_node("AnimationPlayer"):
		if $AnimationPlayer.has_animation("victory"):
			$AnimationPlayer.play("victory")
	
	
func end():
	# removePlayer()
	pass

func getExitLocation():
	return $Exit.get_global_position()

func _on_Exit_body_entered(body):
	if body == global.getCurrentPlayer():
		victory()

func _on_Area2D_body_entered(body):
	# Restart Level
	emit_signal("restart_requested")

