extends Node2D


const THIS_SCENE_ALIAS = "DigitalMeterLesson"
var nextSceneAlias = LevelInfo.GameFlow[THIS_SCENE_ALIAS]

@onready var meter = $MeterLEDs

var rng = RandomNumberGenerator.new()
var signalEmitted : bool = false

signal nextScene(sceneAlias)
	
func _ready():
	meter.goalMetChanged.connect(changeLegend)
	for child in get_children():
		if child is pushableObject:
			child.initialize()

func _input(event):
	if not signalEmitted and event.is_pressed():
		nextScene.emit(nextSceneAlias)
		signalEmitted = true


func changeLegend(goalMet):
	if goalMet:
		$goalLightLegend.texture = load("res://scenes/MeterLEDs/goalOn.png")
	else:
		$goalLightLegend.texture = load("res://scenes/MeterLEDs/goalOff.png")

	
func _on_timer_timeout():
	meter.clearMeter()
	meter.areLEDsGreen =rng.randf() > 0.5
	meter.rayWillBeDetected(abs(rng.randfn(4.0,2.0)))
	meter.rayBlocked(abs(rng.randfn(2.0,1.0)))
	
	
