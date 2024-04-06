extends Node2D
class_name SceneManager

@export var Scenes : Dictionary = {}
@onready var fader = $ColorRect
var currentSceneAlias : StringName = ""
const FaderBlack = Color(12/255.0,12/255.0,12/255.0,1.0)
const FaderTrans = Color(12/255.0, 12/255.0, 12/255.0, 0.0)

func _ready():
	var mainScene : StringName = ProjectSettings.get_setting("application/run/main_scene")
	currentSceneAlias = Scenes.find_key(mainScene)
	var fadeIn = get_tree().create_tween()
	fadeIn.set_ease(Tween.EASE_IN_OUT)
	fadeIn.set_trans(Tween.TRANS_LINEAR)
	fadeIn.tween_property(fader,"color",FaderTrans,1.0)

func AddScene(sceneAlias : String, scenePath : String):
	Scenes[sceneAlias] = scenePath
	
func RemoveScene(sceneAlias : String):
	Scenes.erase(sceneAlias)
	
func ChangeScene(sceneAlias : String):
	var fadeOut = get_tree().create_tween()
	fadeOut.set_ease(Tween.EASE_IN_OUT)
	fadeOut.set_trans(Tween.TRANS_LINEAR)
	fadeOut.tween_property(fader,"color",FaderBlack,1.0)
	await fadeOut.finished
	currentSceneAlias = sceneAlias
	get_tree().change_scene_to_file(Scenes[sceneAlias])
	var fadeIn = get_tree().create_tween()
	fadeIn.set_ease(Tween.EASE_IN_OUT)
	fadeIn.set_trans(Tween.TRANS_LINEAR)
	fadeIn.tween_property(fader,"color",FaderTrans,1.0)
	
func ReloadCurrentScene():
	get_tree().reload_current_scene()
	
func QuitGame():
	get_tree().quit()
	
func GetSceneCount():
	return Scenes.size()
	
func GetCurrentSceneAlias():
	return currentSceneAlias
