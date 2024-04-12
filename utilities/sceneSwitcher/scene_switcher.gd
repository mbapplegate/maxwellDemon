extends Node2D
class_name SceneManager

@export var Scenes : Dictionary = {}
@onready var fader = $ColorRect

var currentSceneAlias : StringName = "MainMenu"
const FaderBlack = Color(12/255.0,12/255.0,12/255.0,1.0)
const FaderTrans = Color(12/255.0, 12/255.0, 12/255.0, 0.0)

func _ready():
	var fadeIn = get_tree().create_tween()
	fadeIn.set_ease(Tween.EASE_IN_OUT)
	fadeIn.set_trans(Tween.TRANS_LINEAR)
	fadeIn.tween_property(fader,"color",FaderTrans,0.5)

func AddScene(sceneAlias : StringName, scenePath : StringName):
	Scenes[sceneAlias] = scenePath
	
func RemoveScene(sceneAlias : String):
	Scenes.erase(sceneAlias)
	
func ChangeScene(sceneFrom : Object, sceneAlias : StringName):
	var fadeOut = get_tree().create_tween()
	fadeOut.set_ease(Tween.EASE_IN_OUT)
	fadeOut.set_trans(Tween.TRANS_LINEAR)
	fadeOut.tween_property(fader,"color",FaderBlack,1.0)
	await fadeOut.finished
	sceneFrom.queue_free()
	var newScene = load(String(Scenes[sceneAlias]))
	var sceneInstance = newScene.instantiate()
	get_tree().root.add_child(sceneInstance)
	#FadeIn(0.5, true)
	var fadeIn = get_tree().create_tween()
	fadeIn.set_ease(Tween.EASE_IN_OUT)
	fadeIn.set_trans(Tween.TRANS_LINEAR)
	fadeIn.tween_property(fader,"color",FaderTrans,0.5)
	currentSceneAlias = sceneAlias
	return sceneInstance
	
func ReloadCurrentScene():
	get_tree().reload_current_scene()
	
func QuitGame():
	get_tree().quit()
	
func GetSceneCount():
	return Scenes.size()
	
func GetCurrentSceneAlias():
	return currentSceneAlias
