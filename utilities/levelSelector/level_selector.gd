extends Node2D

signal nextScene(sceneAlias)

func _ready():
	$HBoxContainer/Level01.grab_focus()
	
func _on_level_01_pressed():
	nextScene.emit("Level001")


func _on_level_02_pressed():
	nextScene.emit("Level002")


func _on_level_03_pressed():
	nextScene.emit("Level003")


func _on_level_04_pressed():
	nextScene.emit("Level004")


func _on_level_05_pressed():
	nextScene.emit("Level005")
