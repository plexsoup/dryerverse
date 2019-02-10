extends Node2D

# Declare member variables here. Examples:
var CurrentPlayer
var GameSpeed = 1.0
var Gravity = 600

var CurrentScene
var RootSceneManager
var CurrentVisualizer

func setCurrentPlayer(playerNode):
	CurrentPlayer = playerNode

func getCurrentPlayer():
	if CurrentPlayer != null:
		return CurrentPlayer
	else:
		print(self.name, " error: CurrentPlayer does not exist.")

func setCurrentVisualizer(node):
	CurrentVisualizer = node

func getCurrentVisualizer():
	return CurrentVisualizer
	
func getCurrentScene():
	if CurrentScene != null:
		return CurrentScene

func setCurrentScene(newScene):
	CurrentScene = newScene

func setRootSceneManager(newScene):
	RootSceneManager = newScene

func getRootSceneManager():
	if RootSceneManager != null:
		return RootSceneManager
	else:
		print(self.name, " error in getRootSceneManager. RootSceneManager == null")
