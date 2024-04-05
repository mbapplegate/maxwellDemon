extends Node2D
class_name WorldTemplate

@onready var tmap = $TileMap
@onready var door = $Doorway
@onready var detMeter = $DetectorMeter
@onready var player = $Player
@onready var wire = $goalWire
@onready var fader = $screenFader

@export var nextScenePath = "res://worlds/world_template.tscn"
var newScene = null
const WIRE_OFF_COLOR = Color(10/255.0,10/255.0,10/255.0)
const WIRE_ON_COLOR = Color(240/255.0,240/255.0,60/255.0)
const FADE_IN_TIME = 0.75
const FADE_OUT_TIME = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(fader,"color",Color(0.1,0.1,0.1,0.0),FADE_IN_TIME)
	
	
	player.levelComplete.connect(_next_level)
	wire.modulate = WIRE_OFF_COLOR
	for child in get_children():
		if child is pushableObject:
			child.initialize()
		elif child is detectorMeter:
			child.goalMetChanged.connect(_toggleDoor)
	newScene = load(nextScenePath)
	await tween.finished

func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true
	
func _toggleDoor(val):
	if val:
		var allTrue = true
		for child in get_children():
			if child is detectorMeter:
				if not child.goalMet:
					allTrue = false
		if allTrue:
			wire.modulate = WIRE_ON_COLOR
			door.openDoor()
	else:
		wire.modulate = WIRE_OFF_COLOR
		door.closeDoor()
		
func _next_level():
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(fader,"color",Color(0.1,0.1,0.1,1.0),FADE_OUT_TIME)
	await tween.finished
	get_tree().change_scene_to_packed(newScene)
