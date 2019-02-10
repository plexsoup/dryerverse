extends Node

"""
Finite State Machine for a character.

Receives signals from player controller or AI controller.
Changes states
Connects and disconnects signals as appropriate when changing states

Passes button presses on to current state

Receives signals and passes them onto the current state

Interface:
----------
Each child state needs the following methods:
	start(), end(), update(), handleInput()
They also need a signal:
	`transition_requested(newStateName)`

Notes
-----

Question: How does the player controller know what action is requested,
if state transitions are held by the state objects themselves?

Answer: All I can do is pass buttons pressed to the state objects.
AI player controller would have to translate their goals into button presses.

Question: Why is there only one CurrentState?
Couldn't the player be moving and crouching, or swinging and idle?

Should states be more like a tag cloud than a hierarchy?

Question: Should each state have it's own sprite / animatedSprite,
or should they manage the region in a texture atlas somehow?

Question: how does a finite state machine work with blended animations?
Sometimes you want overlap between jumping and sliding, or running and turning, or whatever.
"""

signal state_changed

onready var StatesMap : Dictionary = { }
var CurrentState : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # **** not ready quite yet
	# start() # Change this.. have the parent node initialize the state machine manually	

func start():
	for stateNode in get_children():
		StatesMap[stateNode.name] = stateNode

	CurrentState = StatesMap["idle"]
	

func changeState(newStateName):
	CurrentState.disconnect("transition_requested", self, "_on_state_transition_requested")

	var newState = StatesMap[newStateName]
	newState.connect("transition_requested", self, "_on_state_transition_requested")

	CurrentState = newState

#func _physics_process(delta):
#	if CurrentState.has_method("update"):
#		CurrentState.update(delta)

#func _input(event):
#	CurrentState.handleInput(event)

	
func _on_state_transition_requested(newStateName):
	changeState(newStateName)
	



