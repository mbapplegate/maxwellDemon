extends pushableObject

@export var numBeamsPerRay : int = 15
@export var emitColor : Vector3 = Vector3(0.0, 1.0, 0.0)
@export var absColor : Vector3 = Vector3(0.0,0.0,1.0)

@onready var blobSprite = $Stage/FluorescentBlob
@onready var burst = preload("./light_burst.tscn")

var isPulsing : bool = false

signal fluoresce(fluoLocation:Vector2,fluoColor:Vector3, numRays:int, rayEnergies:float, originalBeam:Object)
signal attenuateBeam(location:Vector2,color:Vector3,energy:float,object:Object)
signal pulseChildRays()

func _ready():
	blobSprite.self_modulate = Color(emitColor[0],emitColor[1],emitColor[2])
	isEnergizeable = false
	if not isRotatable and initialAngle != 0:
		blobSprite.rotation=deg_to_rad(initialAngle)
		
		
func spawnBurst(globalPos:Vector2):
	#if not isPulsing:
	isPulsing = true
	pulseChildRays.emit()
	var instance = burst.instantiate()
	add_child(instance)
	instance.burstGo(globalPos,absColor)
	await instance.burst.finished
	instance.queue_free()

#This is just to tell the light manager that this can spawn new beams	
func doFluorescence():
	pass
	
func _getNewRayDirections() -> Array:
	var newDirs = []
	for i in range(numBeamsPerRay):
		var thisAngle = (i*TAU) / numBeamsPerRay
		newDirs.append(Vector2(cos(thisAngle),sin(thisAngle)))
		
	return newDirs

#Function to handle if a ray collides with either the walls of the cube or the splitter
func _ray_hit(photonObj:Object, collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	if photonObj.rayColor == absColor:
		photonObj.stopBeam(collPoint)
		fluoresce.emit(collPoint,emitColor,numBeamsPerRay,.2,photonObj)
	else:
		if photonObj.rayColor.dot(absColor) > 0:
			photonObj.stopBeam(collPoint)
			fluoresce.emit(collPoint,emitColor,numBeamsPerRay,.2,photonObj)
			var newColor = photonObj.rayColor - absColor
			for i in range(3):
				if newColor[i] < 0:
					newColor[i] = 0
				elif newColor[i] > 1.0:
					newColor[i] = 1.0
			attenuateBeam.emit(collPoint,newColor,0.5,photonObj)
		else:
			pass
	
	
 
