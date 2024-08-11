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

var normEnergy = Vector3.ZERO

func _ready():
	if not isRotatable and initialAngle != 0:
		barrel.rotation=deg_to_rad(initialAngle)
		
	normEnergy = rayColor/rayColor.length_squared() * packetEnergy
	energizeChanged.connect(handleEnergizeChanged)
	rotationChanged.connect(handleRotationChange)
	stageMoved.connect(handleMotion)
	await get_tree().process_frame
	if isEnergized:
		_generateRays()
		raysInstanced = true
	print("Laser ready")
	
func _ray_hit(photonObj:Object, collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.stopBeam(collPoint)

func setPaused(val):
	if val:
		_killRays()
		isPaused = true
	else:
		_generateRays()
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
		startLocs.append(Vector2(barrelPosition.x+yLoc*sin(angleToUse), -barrelPosition.y-yLoc*cos(angleToUse)))
	return startLocs

func handleEnergizeChanged(val:bool):
	if val:
		if raysInstanced:
			_updateRayPaths()
		else:
			_generateRays()
	else:
		_killRays()

func handleRotationChange():
	if isEnergized:
		if raysInstanced:
			_killRays()
		_generateRays()
		
func handleMotion():
	if isEnergized:
		if raysInstanced:
			_killRays()
		
		_generateRays()

	#var startingLocs = getRayStartLocs()
	#var i = 0
	#for child in get_children():
		#if child is LightBeam:
			#child.propDir =  Vector2(cos(_getCorrectAngle()),sin(_getCorrectAngle()))
			#child.sourcePos = startingLocs[i]
			#
			#child.propagateBeam()
			#print(child.numPoints)
			#i += 1
			
func _generateRays():
	raysInstanced = true
	var startingLocs = getRayStartLocs()
	var propDirection = Vector2(cos(_getCorrectAngle()),sin(_getCorrectAngle()))
	for i in range(numBeams):
		var instance = beam.instantiate()
		instance.propDir = propDirection
		instance.sourcePos = startingLocs[i]
		instance.rayColor = rayColor
		instance.energy = normEnergy[0]
		add_child(instance)
	_updateRayPaths()
		
func _killRays():
	raysInstanced = false
	for child in get_children():
		if child is LightBeam:
			child.clearBeam()
			child.free()
			
func _updateRayPaths():
	for child in get_children():
		if child is LightBeam:
			child.propagateBeam()

