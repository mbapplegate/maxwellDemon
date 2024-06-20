extends StaticBody2D
class_name detectorMeter

const NUM_STEPS = 256
const MIN_THETA =-PI+.1 
const MAX_THETA = -.1
const CURR_LINE_LENGTH = 100
const AVG_LINE_LENGTH = 90
const GOAL_LINE_LENGTH = 64
const LINE_ORIGIN = Vector2(0,56)
const NUM_POINTS_TO_AVG = 10
const GOAL_SPRITE_RADIUS = 110

@export var minPower = 0.0
@export var maxPower = 10.0
@export var goalPower:float = 5
@export var integrationTime = 0.5
@export var IDColor = Color(1,0,0)

@onready var currLine = $currentPowerLine
@onready var avgLine = $averagePowerLine
@onready var goalLine = $goalLine
@onready var goalSprite = $goalSprite
@onready var timer = $Timer
@onready var light = $LightSprite
@onready var idBall = $IDSprite
@onready var goalWire = $goalWire

var powerArray = []
var arrayIndex = 0
var currentEnergy = 0.0
var goalMet = false

#const WIRE_OFF_COLOR = Color(10/255.0,10/255.0,10/255.0)
#const WIRE_ON_COLOR = Color(240/255.0,240/255.0,60/255.0)

signal goalMetChanged(val:bool)

func _ready():
	var wireSet = false
	idBall.modulate = IDColor
	goalWire.modulate = LevelInfo.WIRE_OFF_COLOR
	for child in get_children():
		if child is PointDetector:
			child.initialize()
			child.photonDetected.connect(_packetDetected)	
			child.idIndicator.modulate = IDColor
		if not wireSet and child is Line2D and child.name == "WirePath":
			setGoalWirePoints(child.points)
			child.visible = false
			wireSet = true
			
	powerArray.resize(NUM_POINTS_TO_AVG)
	powerArray.fill(0.0)
	currLine.set_point_position(1,LINE_ORIGIN+CURR_LINE_LENGTH*_getPointDirection(minPower))
	avgLine.set_point_position(1,LINE_ORIGIN+AVG_LINE_LENGTH*_getPointDirection(minPower))
	goalLine.set_point_position(1,LINE_ORIGIN+GOAL_LINE_LENGTH*_getPointDirection(goalPower))
	goalSprite.position = _getGoalSpriteLocation()
	goalSprite.rotation = _getGoalSpriteAngle()
	timer.wait_time = integrationTime
	

func _getPointDirection(currPower) -> Vector2:
	var proportion = (currPower-minPower)/(maxPower-minPower)
	var angle = proportion * (MAX_THETA-MIN_THETA) + MIN_THETA
	angle = min(MAX_THETA,max(MIN_THETA,angle))
	return Vector2(cos(angle),sin(angle)).normalized()
	
func _getGoalSpriteLocation() -> Vector2:
	var goalDir = _getPointDirection(goalPower)
	return LINE_ORIGIN + GOAL_SPRITE_RADIUS*goalDir
	
func _getGoalSpriteAngle() -> float:
	var proportion = (goalPower-minPower)/(maxPower-minPower)
	var angle = proportion * (MAX_THETA-MIN_THETA) + MIN_THETA
	return angle + PI/2.0
	

func _getArrayAvg():
	var sum = 0.0
	for i in NUM_POINTS_TO_AVG:
		sum += powerArray[i]
	return sum/NUM_POINTS_TO_AVG
	
func _packetDetected(energy:float):
	currentEnergy += energy
	
func setGoalWirePoints(pointArray:PackedVector2Array):
	goalWire.clear_points()
	goalWire.points = pointArray
	
func _on_timer_timeout():
	powerArray[arrayIndex] = currentEnergy
	arrayIndex += 1
	if (arrayIndex == NUM_POINTS_TO_AVG):
		arrayIndex = 0
	var currentAvg = _getArrayAvg()
	currLine.set_point_position(1,LINE_ORIGIN + CURR_LINE_LENGTH*_getPointDirection(currentEnergy))
	avgLine.set_point_position(1,LINE_ORIGIN+AVG_LINE_LENGTH*_getPointDirection(currentAvg))
	currentEnergy = 0.0
	if currentAvg >= goalPower:
		if not goalMet:
			light.texture = load("res://scenes/DetectorMeterAnalog/indicatorLight_256px_ON.png")
			goalWire.modulate = LevelInfo.WIRE_ON_COLOR
			goalMet = true
			goalMetChanged.emit(goalMet)
	else:
		if goalMet:
			light.texture = load("res://scenes/DetectorMeterAnalog/indicatorLight_256px_OFF.png")
			goalWire.modulate = LevelInfo.WIRE_OFF_COLOR
			goalMet = false
			goalMetChanged.emit(goalMet)
	
