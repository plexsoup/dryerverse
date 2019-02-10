extends Node2D

# Declare member variables here. Examples:
export var DialogText : String  = ""

onready var Timer = $CanvasLayer/DialogTextLabel/LetterTimer
onready var Label = $CanvasLayer/DialogTextLabel

var DisplayedText : String = ""
var NumLettersDisplayed : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start(textString):
	DialogText = textString
	Timer.start()

#func play():
#	Timer.start()

func _Input(event):
	if event.is_action_pressed("ui_accept"):
		if NumLettersDisplayed < DialogText.length(): # show the whole message
			DisplayedText = DialogText
		else: # quit the dialog
			queue_free()

		
func showNextLetter():
	if NumLettersDisplayed < DialogText.length():
		NumLettersDisplayed += 1
	Label.set_text(DialogText.left(NumLettersDisplayed))
		
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_LetterTimer_timeout():
	showNextLetter()
	