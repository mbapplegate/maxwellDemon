extends Node2D

signal nextScene(sceneAlias)
@onready var cLayer = $CanvasLayer

func _ready():
	cLayer.hide()

func gamePaused():
	cLayer.show()
	$CanvasLayer/VBoxContainer/Resume.grab_focus()
	
func gameUnPaused():
	cLayer.hide()
		
func _on_resume_pressed():
	cLayer.hide()
	get_tree().paused = false


func _on_restart_pressed():
	get_tree().paused = false
	cLayer.hide()
	nextScene.emit("Reload")

func _on_quit_to_menu_pressed():
	get_tree().paused = false
	cLayer.hide()
	nextScene.emit("MainMenu")
	
func _on_quit_game_pressed():
	nextScene.emit("QuitGame")
