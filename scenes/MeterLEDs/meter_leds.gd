extends Node2D
class_name DigitalMeter

@export var maxEnergy : float = 20.0
@export var goalEnergy : float = 10.0
@export var goalOnTop : bool = true
@export var updateTime : float = 1.0

const NUM_LEDS : int = 10
const NUM_TO_AVG : int = 5
const PANEL_BOORDER_SIZE : int = 19

@onready var led1 = $Panel/LED01
@onready var led2 = $Panel/LED02
@onready var led3 = $Panel/LED03
@onready var led4 = $Panel/LED04
@onready var led5 = $Panel/LED05
@onready var led6 = $Panel/LED06
@onready var led7 = $Panel/LED07
@onready var led8 = $Panel/LED08
@onready var led9 = $Panel/LED09
@onready var led10 = $Panel/LED10

@onready var offTexture = preload("res://scenes/MeterLEDs/offLED.png")
@onready var redTexture = preload("res://scenes/MeterLEDs/redLED.png")
@onready var greenTexture = preload("res://scenes/MeterLEDs/greenLED.png")
@onready var yellowTexture = preload("res://scenes/MeterLEDs/yellowLED.png")

var ledArray = []
var energyDetected : float = 0.0
var energyBlocked : float = 0.0
var detectedArray : Array = []
var avgIdx : int = 0
var goalMet = false
var panelWidth = 10.0
var areLEDsGreen = false
var lastEnergy : float = 0.0

signal goalMetChanged(val:bool)

func _ready():
	ledArray = [led1,led2,led3,led4,led5,led6,led7,led8,led9,led10]
	detectedArray.resize(NUM_TO_AVG)
	detectedArray.fill(0.0)
	
	$Timer.wait_time = updateTime
	
	var goalXPos = goalEnergy/maxEnergy * (led10.position.x-led1.position.x) + led1.position.x
	$Goal.position.x = goalXPos
	panelWidth = $Panel.texture.get_width() - 2*PANEL_BOORDER_SIZE
	$avgPower.position.x = led1.position.x
	#$Panel/ColorRect.size.x =0
	if not goalOnTop:
		$avgPower.position.y = -$avgPower.position.y
		$Goal.position.y = -$Goal.position.y
		$avgPower.rotation = PI
		$Goal.rotation=PI
		
	var meterParent = get_parent()
	if meterParent is PointDetector:
		meterParent.photonDetected.connect(rayDetected)
		meterParent.photonMissed.connect(rayBlocked)
		meterParent.photonWillHit.connect(rayWillBeDetected)
		for child in get_parent().get_children():
			if child is FreeAperture:
				child.rayHit.connect(rayBlocked)
				
	maxEnergy= goalEnergy
	
func _turnLEDOff(ledIndex : int):
	ledArray[ledIndex].texture = offTexture
	
func _turnLEDGreen(ledIndex : int):
	ledArray[ledIndex].texture = greenTexture
	
func _turnLEDRed(ledIndex : int):
	ledArray[ledIndex].texture = redTexture
	
func _turnLEDYellow(ledIndex : int):
	ledArray[ledIndex].texture = yellowTexture

func rayWillBeDetected(en : float):
	energyDetected += en
	updateMeter()
	
func rayDetected(_en : float):
	#energyDetected += en
	areLEDsGreen = true
	updateMeter()
	
func rayBlocked(en : float):
	energyBlocked += en
	updateMeter()
	
func clearMeter():
	energyDetected = 0
	energyBlocked = 0
	areLEDsGreen = false
	#updateMeter()

func _getArrayAvg(arr, arrLen)->float:
	var sum = 0.0
	for i in arrLen:
		sum += arr[i]
	return sum/float(arrLen)
	
func updateMeter():
	#Calculate which LEDs should be lit
	
	var totalEnergy = energyBlocked + energyDetected
	
	var pctOfMax = totalEnergy/maxEnergy
	var numLEDsLit = int(round(pctOfMax * NUM_LEDS))
	var pctDetected = energyDetected / totalEnergy
	var numGreen =int(ceil(pctDetected * numLEDsLit))
	var numRed = numLEDsLit - numGreen
	#print(energyDetected, ", ", energyBlocked)
	for i in ledArray.size():
		if i < numGreen:
			if areLEDsGreen:
				_turnLEDGreen(i)
			else:
				_turnLEDYellow(i)
		elif i < numGreen+numRed:
			_turnLEDRed(i)
		else:
			_turnLEDOff(i)
			
	if lastEnergy == totalEnergy:
		checkDoor()
		
	lastEnergy = totalEnergy
	#Update average
	#detectedArray[avgIdx] = energyDetected
	#var arrAvg = _getArrayAvg(detectedArray,NUM_TO_AVG)
	#print(energyBlocked, ", ", energyDetected, ", ", arrAvg)
	#Update index
	#avgIdx += 1
	#if avgIdx >= NUM_TO_AVG:
	#	avgIdx = 0
		
	
		
	#Place average marker
	#var markerXVal = arrAvg/maxEnergy * (led10.position.x-led1.position.x) + led1.position.x
	#$avgPower.position.x = max(led1.position.x,min(led10.position.x,markerXVal))
	#$Panel/ColorRect.size.x =  max(0,min(panelWidth,arrAvg/maxEnergy*panelWidth))
	#Reset vars
	#energyBlocked = 0
	#energyDetected = 0
func checkDoor():
	#Send goal met signal
	if energyDetected >= goalEnergy and areLEDsGreen and not goalMet:
		goalMet = true
		goalMetChanged.emit(goalMet)
		#$Goal.texture = load("res://scenes/MeterLEDs/goalOn.png")
	elif energyDetected < goalEnergy and goalMet:
		#print(energyDetected)
		goalMet = false
		goalMetChanged.emit(goalMet)
		#$Goal.texture = load("res://scenes/MeterLEDs/goalOff.png")
