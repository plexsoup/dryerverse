extends Node2D

var CurrentLevelIndex : int = -1
var Levels = ["res://platforms/Level1.tscn", "res://platforms/Level2.tscn", "res://platforms/Level3.tscn"]
var CurrentLevelNode

var TitleScreen

var CurrentPlayerNode
onready var global = get_node("/root/global")

enum STATES { title, options, playing, celebrating, credits }
var CurrentState = STATES.title

# Called when the node enters the scene tree for the first time.
func _ready():
	showTitleScreen()
	global.setRootSceneManager(self)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func showTitleScreen():
	var titleScreen = load("res://titleScreens/TitleScreen.tscn")
	var newTitleScreen = titleScreen.instance()
	add_child(newTitleScreen)
	newTitleScreen.connect("start_button_pressed", self, "_on_TitleScreen_start_button_pressed")
	TitleScreen = newTitleScreen

func removeTitleScreen():
	TitleScreen.queue_free()
	
	
func startGame():
	pass
	

func removeOldLevel():
	if CurrentLevelNode:
		CurrentLevelNode.queue_free()
	if CurrentPlayerNode:
		CurrentPlayerNode.queue_free()


func instantiateNewLevel(levelPath):
	var levelScene = load(levelPath)
	CurrentLevelNode = levelScene.instance()
	add_child(CurrentLevelNode)
	global.setCurrentScene(CurrentLevelNode)
	CurrentLevelNode.connect("level_initialized", self, "_on_level_initialized")
	CurrentLevelNode.start() # spawn the player or whatever else you need to do.
	
	CurrentLevelNode.getExit().connect("level_completed", self, "_on_level_completed")
	
	
func nextLevel():
	removeOldLevel()
	CurrentLevelIndex +=1
	if CurrentLevelIndex < Levels.size():
		instantiateNewLevel(Levels[CurrentLevelIndex])
		CurrentState = STATES.playing

func restartLevel():
	removeOldLevel()
	instantiateNewLevel(Levels[CurrentLevelIndex])
	CurrentState = STATES.playing
	

func spawnPlayer(location):
	var playerScene = preload("res://characters/Character.tscn")
	#var playerScene = load("res://characters/CharacterRigidBody.tscn")
	var newPlayer = playerScene.instance()
	newPlayer.set_global_position(location)
	add_child(newPlayer)
	newPlayer.start()
	CurrentPlayerNode = newPlayer
	global.setCurrentPlayer(newPlayer)

func _input(event):
	if event.is_action_pressed("ui_down"):
		nextLevel()

func _on_level_initialized():
	spawnPlayer(CurrentLevelNode.get_node("PlayerSpawnPoint").get_global_position())
	
func _on_level_completed():
	# hide the player
	# zoom out the level
	# show "get ready"
	# start the countdown timer to spawn the next level

	$CelebrationTimer.start()
	CurrentState = STATES.celebrating
	
	for consumable in $Consumables.get_children():
		consumable.queue_free()
			
	CurrentPlayerNode.hidePlayer()
	CurrentPlayerNode.set_global_position(CurrentLevelNode.getExitLocation())
		
func _on_CelebrationTimer_timeout():
	CurrentPlayerNode.end()
	nextLevel()
	
func _on_TitleScreen_start_button_pressed():
	removeTitleScreen()
	nextLevel()
	
func _on_Character_level_restart_requested():
	restartLevel()
	
func _on_level_restart_requested():
	restartLevel()
	