extends Node2D

func _ready():
	$VBoxContainer/startGame.grab_focus()
	
func _on_button_pressed():
	SceneSwitcher.ChangeScene("Level001")

func _on_select_level_pressed():
	SceneSwitcher.ChangeScene("MainMenu")
	
func _on_quit_game_pressed():
	SceneSwitcher.QuitGame() # Replace with function body.
