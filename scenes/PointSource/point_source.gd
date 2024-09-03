extends pushableObject

@export var angleRangeDeg : Vector2 = Vector2(-90,90)
@export var numBeams : int = 1
@export var rayColor : Vector3 = Vector3(1.0, 0, 1.0)

@onready var sourceBall = $sourceBall

var sourceParent = null
var pointEnergy = Vector3.ZERO
var angleRange = Vector2.ZERO

const POINT_RADIUS = 8

signal registerRays(pos:Array, color:Vector3, energy:float, direction:Vector2, IOR:float, source:Object)
signal startRays(source:Object)
signal stopRays(source:Object)
signal sourceMoved(newLocation:Array,newDirection:Vector2,source:Object)

func _ready():
	sourceParent = get_parent()
	angleRange = Vector2(deg_to_rad(angleRangeDeg.x),deg_to_rad(angleRangeDeg.y))
	isRotatable=false
	sourceBall.modulate = Color(rayColor[0], rayColor[1],rayColor[2])
	pointEnergy = rayColor/rayColor.length_squared()
	energizeChanged.connect(handleEnergizeChanged)
	stageMoved.connect(handleMotion)
	await get_tree().process_frame
	registerBeams()

func handleEnergizeChanged(val):
	if val:
		startRays.emit(self)
	else:
		stopRays.emit(self)
		
func handleMotion():
	var locs = getStartingLocations()
	var startDirs = getPropagationDirections()
	sourceMoved.emit(locs,startDirs,self)
		
func getPropagationDirections() -> Array:
	var totalAngle = angleRange[1]-angleRange[0]
	var angleSpacing = totalAngle/numBeams
	
	var directions = []
	directions.resize(numBeams)
	for i in range(numBeams):
		var angle = angleRange[0] + i*angleSpacing
		directions[i] = Vector2(cos(angle),sin(angle))
	return directions

func getStartingLocations() -> Array:
	var locs = []
	locs.resize(numBeams)
	locs.fill(to_global(Vector2.ZERO))
	return locs
		
func registerBeams():
		var dirs = getPropagationDirections()
		var locs = getStartingLocations()
		registerRays.emit(locs,rayColor,1.0,dirs,1.0,self)
			
	
		


func _ray_hit(photonObj:Object, collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.stopBeam(collPoint)
