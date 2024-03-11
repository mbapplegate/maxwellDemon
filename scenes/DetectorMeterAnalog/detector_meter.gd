extends Node2D

const NUM_STEPS = 256
const MIN_THETA =-PI+.1 
const MAX_THETA = -.1
const LINE_LENGTH = 56
const LINE_ORIGIN = Vector2(0,32)
const NUM_POINTS_TO_AVG = 10

@export var minPower = 0.0
@export var maxPower = 10.0
@export var goalPower = 5
@export var integrationTime = 0.5

@onready var currLine = $currentPowerLine
@onready var avgLine = $averagePowerLine
@onready var goalLine = $goalLine
@onready var timer = $Timer
@onready var light = $LightSprite

var powerArray = []
var arrayIndex = 0
var currentEnergy = 0.0
var goalMet = false

func _ready():
	for child in get_children():
		if child.name == "PointDetector":
			child.photonDetected.connect(_packetDetected)	
			
	powerArray.resize(NUM_POINTS_TO_AVG)
	powerArray.fill(0.0)
	currLine.set_point_position(1,_getPointLocation(minPower))
	avgLine.set_point_position(1,_getPointLocation(minPower))
	goalLine.set_point_position(1,_getPointLocation(goalPower))
	timer.wait_time = integrationTime
	

func _getPointLocation(currPower) -> Vector2:
	var proportion = (currPower-minPower)/(maxPower-minPower)
	var angle = proportion * (MAX_THETA-MIN_THETA) + MIN_THETA
	angle = min(MAX_THETA,max(MIN_THETA,angle))
	return LINE_ORIGIN+Vector2(LINE_LENGTH*cos(angle),LINE_LENGTH*sin(angle))

func _getArrayAvg():
	var sum = 0.0
	for i in NUM_POINTS_TO_AVG:
		sum += powerArray[i]
	return sum/NUM_POINTS_TO_AVG
	
func _packetDetected(energy:float):
	currentEnergy += energy

func _on_timer_timeout():
	powerArray[arrayIndex] = currentEnergy
	arrayIndex += 1
	if (arrayIndex == NUM_POINTS_TO_AVG):
		arrayIndex = 0
	var currentAvg = _getArrayAvg()
	currLine.set_point_position(1,_getPointLocation(currentEnergy))
	avgLine.set_point_position(1,_getPointLocation(currentAvg))
	currentEnergy = 0.0
	if currentAvg >= goalPower:
		light.texture = load("res://scenes/DetectorMeterAnalog/indicatorLight_ON.png")
		goalMet = true
	else:
		light.texture = load("res://scenes/DetectorMeterAnalog/indicatorLight_OFF.png")
		goalMet = false
	