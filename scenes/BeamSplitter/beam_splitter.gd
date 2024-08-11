extends pushableObject

@export var reflectivity = 0.5      #Proportion of light reflected from the splitter (0-1). The rest is transmitted
@export var splitterIndex : Vector3 = Vector3(2.05,2.0,1.95)     #Index of refraction of the splitter

@onready var beam = preload("res://scenes/LightBeam/light_beam.tscn")
@onready var splitter = $Stage/Sprite2D/splitterArea
@onready var splitterSprite = $Stage/Sprite2D

const mediumIndex = 1.0     #Index of the medium surrounding the beam splitter
var splitterParent = null   #Parent object of the beamsplitter

func _ready():
	#Not energizeable
	isEnergizeable = false
	if not isRotatable and initialAngle != 0:
		splitterSprite.rotation=deg_to_rad(initialAngle)
	splitterParent = get_parent()
	
#Function to handle if a ray collides with either the walls of the cube or the splitter
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, collider:Object):
	var thisIndex = 1.0
	if photonObj.rayColor[0] > 0:
		thisIndex = splitterIndex[0]
	elif photonObj.rayColor[1] > 0:
		thisIndex = splitterIndex[1]
	else:
		thisIndex = splitterIndex[2]
	#If it's the center line
	if collider == splitter:
		if reflectivity > 0.1:
			
			
			#Reflect off the splitter
			var newDir = photonObj.getReflectionDirection(collNormal)
			#create new ray
			var instance = photonObj.cloneRay(newDir,photonObj.rayColor)
			#instance.propDir =newDir
			instance.position = collPoint
			instance.update_energy(instance.energy*reflectivity)
		#Update photon packet energies depending on reflectivity
		photonObj.update_energy(photonObj.energy*(1-reflectivity))
	#Otherwise we've collided with the wall of the cube so need to refract
	else:
		photonObj.refractRay(collNormal,thisIndex,collPoint)
	
