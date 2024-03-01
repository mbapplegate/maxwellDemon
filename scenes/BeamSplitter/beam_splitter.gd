extends pushableObject

@export var reflectivity = 0.5      #Proportion of light reflected from the splitter (0-1). The rest is transmitted
@export var splitterIndex = 2.0     #Index of refraction of the splitter

@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")
@onready var splitter = $Stage/splitterArea

const mediumIndex = 1.0     #Index of the medium surrounding the beam splitter
var splitterParent = null   #Parent object of the beamsplitter

func _ready():
	#Not energizeable
	isEnergizeable = false
	splitterParent = get_parent()
	
#Function to handle if a ray collides with either the walls of the cube or the splitter
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, collider:Object):
	#If it's the center line
	if collider == splitter:
		if reflectivity > 0.1:
			#Create new ray
			var instance = ray.instantiate()
			#Color, energy, IOR, and direction are the same as the incoming ray
			instance.rayColor = photonObj.rayColor
			instance.energy = photonObj.energy
			instance.index_of_refraction = photonObj.index_of_refraction
			#Reflect off the splitter
			var newDir = photonObj.propDir
			#Sometimes the collision normal will be NULL, so check that
			if collNormal:
				newDir = photonObj.propDir.bounce(collNormal.normalized()).normalized()
			#Update the direction
			instance.propDir =newDir
			instance.global_position = collPoint
			#If the splitter isn't root then add the child to the parent
			if splitterParent:
				splitterParent.add_child(instance)
			#Otherwise make it a child of itself (mostly for debugging)
			else:
				instance.position = to_local(collPoint)
				add_child(instance)
			instance.update_energy(instance.energy*reflectivity)
		#Update photon packet energies depending on reflectivity
		photonObj.update_energy(photonObj.energy*(1-reflectivity))
	#Otherwise we've collided with the wall of the cube so need to refract
	else:
		var normalIn = -collNormal;
		var theta1 = normalIn.angle_to(photonObj.propDir);
		var theta2
		#Going from high index to low index
		if photonObj.index_of_refraction > mediumIndex:
			theta2 = asin(splitterIndex/mediumIndex * sin(theta1))
			photonObj.index_of_refraction = mediumIndex
		#Going from low index to high index
		else:
			theta2 = asin(mediumIndex/splitterIndex*sin(theta1))
			photonObj.index_of_refraction = splitterIndex
		#Add the point to the photon packet
		
		var newDir = normalIn.rotated(theta2)
		photonObj.propDir = newDir
		
		photonObj.ray_add_point(photonObj.to_local(collPoint))
	
