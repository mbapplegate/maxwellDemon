extends Node2D

@export var nextSceneAlias = "Level006"
const THIS_SCENE_ALIAS = "MeterLesson"

@onready var meter = $DetectorMeter
@onready var wireLegend = $WireLegend
@onready var goalLightLegend = $GoalMetLegend

var rng = RandomNumberGenerator.new()
var signalEmitted : bool = false

signal nextScene(sceneAlias)
	
func _ready():
	meter.goalMetChanged.connect(changeLegend)
	wireLegend.self_modulate = LevelInfo.WIRE_OFF_COLOR
	goalLightLegend.texture = load("res://scenes/DetectorMeterAnalog/indicatorLight_256px_OFF.png")
	for child in get_children():
		if child is pushableObject:
			child.initialize()

func _input(_event):
	if not signalEmitted:
		nextScene.emit(nextSceneAlias)
		signalEmitted = true


func changeLegend(goalMet):
	if goalMet:
		wireLegend.self_modulate = LevelInfo.WIRE_ON_COLOR
		goalLightLegend.texture = load("res://scenes/DetectorMeterAnalog/indicatorLight_256px_ON.png")
	else:
		wireLegend.self_modulate = LevelInfo.WIRE_OFF_COLOR
		goalLightLegend.texture = load("res://scenes/DetectorMeterAnalog/indicatorLight_256px_OFF.png")

	
func _on_timer_timeout():
	meter._packetDetected(rng.randfn(6.0,2.0))
	
