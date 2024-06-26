extends pushableObject
class_name PointDetector

signal photonDetected(energy)
signal photonMissed(energy)

@onready var idIndicator = $Stage/Pivot/detSprite/IDSprite
#@onready var detector = $Stage/Pivot/detSprite
signal goalMetChanged(val)
var goalMet = false

func _ready():
	isEnergizeable = false
	if not isRotatable and initialAngle != 0:
		$Stage/Pivot.rotation = deg_to_rad(initialAngle)
	for child in get_children():
		if child is DigitalMeter:
			child.goalMetChanged.connect(goalChanged)
	
func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, collider:Object):
	#print(to_local(_collPoint))
	photonObj.rayDying = true
	#print(collider.name)
	if collider.name == "activeArea":
		photonDetected.emit(photonObj.energy)
	else:
		photonMissed.emit(photonObj.energy)
		
func goalChanged(val):
	goalMet = val
	goalMetChanged.emit(val)
