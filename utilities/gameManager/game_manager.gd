extends Node

@onready var pauseMenu = $PauseMenu
@onready var currentScene = $MainMenu
var currentSceneAlias = ""
@onready var switcher = $SceneSwitcher

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	currentScene.nextScene.connect(switchScene)
	pauseMenu.nextScene.connect(switchScene)
	currentSceneAlias = "MainMenu"
	
func _input(event):
	if event.is_action_pressed("pause"):
		var currPauseState = get_tree().paused
		get_tree().paused = !currPauseState
		if get_tree().paused:
			pauseMenu.gamePaused()
		else:
			pauseMenu.gameUnPaused()
			if currentSceneAlias == "MainMenu":
				currentScene.get_node("VBoxContainer/startGame").grab_focus()
			
func switchScene(sceneAlias):
	#print(currentSceneAlias, sceneAlias)
	if sceneAlias == "QuitGame":
		switcher.QuitGame()
	elif sceneAlias == "Reload":
		currentScene.nextScene.disconnect(switchScene)
		var nextScene = await switcher.ChangeScene(currentScene,currentSceneAlias)
		currentScene = nextScene
		currentScene.nextScene.connect(switchScene)
	else:
		currentScene.nextScene.disconnect(switchScene)
		currentSceneAlias = sceneAlias
		var nextScene = await switcher.ChangeScene(currentScene,sceneAlias)
		currentScene = nextScene
		currentScene.nextScene.connect(switchScene)
