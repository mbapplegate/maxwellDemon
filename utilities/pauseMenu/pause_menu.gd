extends Node2D

signal nextScene(sceneAlias)

func _ready():
	hide()

func gamePaused():
	show()
	$VBoxContainer/Resume.grab_focus()
	
func gameUnPaused():
	hide()
		
func _on_resume_pressed():
	hide()
	get_tree().paused = false


func _on_restart_pressed():
	get_tree().paused = false
	hide()
	nextScene.emit("Reload")


func _on_quit_to_menu_pressed():
	get_tree().paused = false
	hide()
	nextScene.emit("MainMenu")


func _on_quit_game_pressed():
	nextScene.emit("QuitGame")
