extends Node2D
class_name InvisibleSource

@export var propagationDirection : Vector2 = Vector2.DOWN
@export var sourceColor : Vector3 = Vector3(1.0, 0.0, 0.0)
@export var packetEnergy : float = 1.0
@export var beamHalfHeight : int = 32
@export var numBeams : int = 1
#@export var numRaysPerTimeout : int = 1
#@export var timerTimeout : float = 1.0

signal registerRays(pos:Array, color:Vector3, energy:float, direction:Array, IOR:float, source:Object)
signal stopRays(source:Object)
signal startRays(source:Object)

@onready var timer = $Timer

@onready var beam = preload("res://scenes/LightBeam/light_beam.tscn")
var rng = RandomNumberGenerator.new()
var invisParent = null
var srcEnergy = Vector3.ZERO
var isEnergized : bool = true
func _ready():
	invisParent = get_parent()
	#timer.wait_time = timerTimeout
	srcEnergy = sourceColor/sourceColor.length_squared() * packetEnergy
	await get_tree().process_frame
	registerBeams()


func changeSourceColor(newColor : Vector3):
	sourceColor = newColor
	srcEnergy = sourceColor/sourceColor.length_squared()
	
func energizeBeam():
	isEnergized = true
	startRays.emit(self)
	
func deEnergizeBeam():
	isEnergized = false
	stopRays.emit(self)

func getRayStartLocs() -> Array:
	var startLocs = []
	
	for i in range(numBeams):
		var yLoc
		if numBeams == 1:
			yLoc = 0
		else:
			yLoc = -beamHalfHeight + (2.0*beamHalfHeight*i)/(numBeams-1)
		startLocs.append(to_global(Vector2(0.0,yLoc)))
	return startLocs
	
func registerBeams():
	var startLocs = getRayStartLocs()
	
	var startDirections = []
	startDirections.resize(numBeams)
	startDirections.fill(propagationDirection)
	registerRays.emit(startLocs,sourceColor,packetEnergy,startDirections,1.0,self)
