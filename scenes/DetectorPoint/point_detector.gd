extends pushableObject
class_name PointDetector

signal photonDetected(energy)
signal photonMissed(energy)
signal photonWillHit(energy)

@onready var idIndicator = $Stage/Pivot/detSprite/IDSprite
#@onready var detector = $Stage/Pivot/detSprite
signal goalMetChanged(val)
var goalMet = false
#var beamDetected = false
#var detectionSignalEmitted = false
#var currentEnergy = 0.0
var beamsDetected = []

func _ready():
	isEnergizeable = false
	if not isRotatable and initialAngle != 0:
		$Stage/Pivot.rotation = deg_to_rad(initialAngle)
	for child in get_children():
		if child is DigitalMeter:
			child.goalMetChanged.connect(goalChanged)
	
func _ray_hit(photonObj:Object, collPoint:Vector2, _collNormal:Vector2, collider:Object):
	#print(to_local(_collPoint))
	photonObj.stopBeam(collPoint)
	#print(collider.name)
	if collider.name == "activeArea":
		photonWillHit.emit(photonObj.energy)
		beamsDetected.append(photonObj)
	else:
		#beamDetected = false
		photonMissed.emit(photonObj.energy)

func resetBeamDetected():
	beamsDetected = []
	#detectionSignalEmitted = false
	#currentEnergy = 0.0
	
func pulseHit(energy:float, beam:Object):
	if beamsDetected.has(beam):
		photonDetected.emit(energy)
		beamsDetected.erase(beam)
			
func goalChanged(val):
	goalMet = val
	goalMetChanged.emit(val)
