extends Node2D

signal nextScene(sceneAlias)

func _ready():
	$VBoxContainer/startGame.grab_focus()
	
func _on_button_pressed():
	nextScene.emit("Level001")

func _on_select_level_pressed():
	nextScene.emit("LevelSelect")
	
func _on_quit_game_pressed():
	nextScene.emit("QuitGame")

func _on_load_game_pressed():
	nextScene.emit("MainMenu")
