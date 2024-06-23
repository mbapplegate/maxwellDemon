extends Node2D

@export var maxEnergy : float = 20.0
@export var updateTime : float = 1.0

const NUM_LEDS : int = 10

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

var ledArray = []
var energyDetected : float = 0.0
var energyBlocked : float = 0.0

func _ready():
	ledArray = [led1,led2,led3,led4,led5,led6,led7,led8,led9,led10]
	$Timer.wait_time = updateTime
	var meterParent = get_parent()
	if meterParent is PointDetector:
		meterParent.photonDetected.connect(rayDetected)
		meterParent.photonMissed.connect(rayBlocked)
		for child in get_parent().get_children():
			if child is FreeAperture:
				child.rayHit.connect(rayBlocked)
	
func _turnLEDOff(ledIndex : int):
	ledArray[ledIndex].texture = offTexture
	
func _turnLEDGreen(ledIndex : int):
	ledArray[ledIndex].texture = greenTexture
	
func _turnLEDRed(ledIndex : int):
	ledArray[ledIndex].texture = redTexture
	
func rayDetected(en : float):
	energyDetected += en
	
func rayBlocked(en : float):
	energyBlocked += en


func _on_timer_timeout():
	var totalEnergy = energyBlocked + energyDetected
	var pctOfMax = totalEnergy/maxEnergy
	var numLEDsLit = int(round(pctOfMax * NUM_LEDS))
	var pctDetected = energyDetected / totalEnergy
	var numGreen =int(ceil(pctDetected * numLEDsLit))
	var numRed = numLEDsLit - numGreen
	#print(energyDetected, ", ", energyBlocked)
	for i in ledArray.size():
		if i < numGreen:
			_turnLEDGreen(i)
		elif i < numGreen+numRed:
			_turnLEDRed(i)
		else:
			_turnLEDOff(i)
			
	energyBlocked = 0
	energyDetected = 0
