extends Node2D

# Declare member variables here. Examples:
export var DialogText : Array  = [""]

onready var LetterTimer = $DialogTextLabel/LetterTimer
onready var DialogBox = $DialogTextBox
onready var KeypressAudio = $KeypressNoise

var CurrentLine = 0
var DisplayedText = ""
var CurrentLineText = ""
var NumLettersDisplayed : int = 0

var NodeToFollow

signal initialized
signal completed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start(textArray, nodeToFollow):
	connect("initialized", global.getCurrentPlayer(), "_on_dialogBox_initialized")
	connect("completed", global.getCurrentPlayer(), "_on_dialogBox_completed")

	DialogText = textArray
	DisplayedText = ""
	if DialogText.size() > 0:
		CurrentLineText = DialogText[0]
	else:
		end() # quit if there's no text to show
	LetterTimer.start()
	NodeToFollow = nodeToFollow
	DialogBox.set_wrap_enabled(true)
	DialogBox.set_text("")

	emit_signal("initialized")

func end():
	emit_signal("completed")
	queue_free()

func showNextLine():
	CurrentLine += 1
	NumLettersDisplayed = 0
	if CurrentLine >= DialogText.size():
		
		end()
		return
	else:
		CurrentLineText = DialogText[CurrentLine]
		DisplayedText = ""


func showNextLetter():
	if NumLettersDisplayed < CurrentLineText.length():
		NumLettersDisplayed += 1
		KeypressAudio.play()
	DialogBox.set_text(CurrentLineText.left(NumLettersDisplayed))

func revealAllLetters():
	if Input.is_action_just_pressed("ui_accept"):
		if NumLettersDisplayed < CurrentLineText.length(): # show the whole message
			NumLettersDisplayed = CurrentLineText.length()
		else: # show the next line
			showNextLine()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		end()
	
	if is_instance_valid(NodeToFollow):
		set_global_position(NodeToFollow.get_global_position() + Vector2(0, -200))
	revealAllLetters()



func _on_LetterTimer_timeout():
	showNextLetter()

