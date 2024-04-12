extends Node

@onready var pauseMenu = $PauseMenu
@onready var currentScene = $MainMenu
var currentSceneAlias = ""
@onready var switcher = $SceneSwitcher

func _ready():
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
			
func switchScene(sceneAlias):
	if sceneAlias == "QuitGame":
		switcher.QuitGame()
	elif sceneAlias == "Reload":
		var nextScene = await switcher.ChangeScene(currentScene,currentSceneAlias)
		currentScene = nextScene
		currentScene.nextScene.connect(switchScene)
	else:
		currentSceneAlias = sceneAlias
		var nextScene = await switcher.ChangeScene(currentScene,sceneAlias)
		currentScene = nextScene
		currentScene.nextScene.connect(switchScene)
