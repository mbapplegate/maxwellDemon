extends pushableObject

@export var beamHalfHeight : int = 0
@export var numBeams : int = 3
@export var rayColor : Vector3 = Vector3(1.0, 0, 0.0)
@export var packetEnergy : float = 1.0

@onready var barrelShape = $Stage/laserBarrel/barrelArea/barrelShape
@onready var barrel = $Stage/laserBarrel
@onready var beam = preload("res://scenes/LightBeam/light_beam.tscn")

#var rng = RandomNumberGenerator.new()
var isPaused = false
var raysInstanced : bool = false
signal registerRays(pos:Array, color:Vector3, energy:float, direction:Vector2, source:Object)
signal stopRays(source:Object)
signal startRays(source:Object)
signal sourceMoved(newLocation:Array,newDirection:Vector2,source:Object)

var normEnergy = Vector3.ZERO

func _ready():
	if not isRotatable and initialAngle != 0:
		barrel.rotation=deg_to_rad(initialAngle)
		
	normEnergy = rayColor/rayColor.length_squared() * packetEnergy
	energizeChanged.connect(handleEnergizeChanged)
	rotationChanged.connect(handleRotationChange)
	stageMoved.connect(handleMotion)
	await get_tree().process_frame
	registerBeams()
	
func _ray_hit(photonObj:Object, collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.stopBeam(collPoint)

func setPaused(val):
	if val:
		stopRays.emit(self)
		isPaused = true
	else:
		startRays.emit(self)
		isPaused = false
		
func _getCorrectAngle() -> float:
	var angleToUse = 0.0
	if isRotatable:
		angleToUse = sprite.rotation
	else:
		angleToUse = barrel.rotation
	return angleToUse

func getRayStartLocs() -> Array:
	var startLocs = []
	
	var angleToUse = _getCorrectAngle()	
	var barrelPosition = Vector2(barrelShape.position.x+(barrelShape.shape.size[0]/2.0+1.0)*cos(angleToUse),barrelShape.position.y-(barrelShape.shape.size[0]/2.0+1.0)*sin(angleToUse))

	for i in range(numBeams):
		var yLoc = -beamHalfHeight + (2.0*beamHalfHeight*i)/(numBeams-1)
		startLocs.append(to_global(Vector2(barrelPosition.x+yLoc*sin(angleToUse), -barrelPosition.y-yLoc*cos(angleToUse))))
	return startLocs

func handleEnergizeChanged(val:bool):
	if val:
		startRays.emit(self)
	else:
		stopRays.emit(self)

func handleRotationChange():
	handleMotion()
		
func handleMotion():
	var startLocs = getRayStartLocs()
	var angleToUse = 0.0
	if isRotatable:
		angleToUse = sprite.rotation
	else:
		angleToUse = barrel.rotation
	sourceMoved.emit(startLocs,Vector2(cos(angleToUse),sin(angleToUse)),self)

			
func registerBeams():
	var startLocs = getRayStartLocs()
	var angleToUse = 0.0
	if isRotatable:
		angleToUse = sprite.rotation
	else:
		angleToUse = barrel.rotation
	
	registerRays.emit(startLocs,rayColor,1.0,Vector2(cos(angleToUse),sin(angleToUse)),self)
