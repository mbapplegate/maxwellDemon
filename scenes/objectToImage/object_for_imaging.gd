extends Node2D
class_name ImagerObject
const TEXTURE_SIZE : Vector2 = Vector2(32.0,32.0)

@export var pieceSize : Vector2  = Vector2(32,32)
@export var objectColor: Vector3 = Vector3(1.0,1.0,1.0)

@onready var element = $StaticBody2D/Sprite2D
@onready var imagingTimer = $Timer
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")

var objectParent = null
var rng = RandomNumberGenerator.new()
var imagingMode = false
var imagingLens = null

func _ready():
	objectParent = get_parent()
	$StaticBody2D/CollisionShape2D.shape.size = Vector2(pieceSize.x-4, pieceSize.y-4)
	element.scale.x = pieceSize.x/TEXTURE_SIZE.x
	element.scale.y = pieceSize.y/TEXTURE_SIZE.y
	
	element.self_modulate = Color(objectColor[0], objectColor[1], objectColor[2])

func setImagingLens(lensObject):
	imagingLens = lensObject

func changeImagingMode(val):
	imagingMode = val
	if val:
		imagingTimer.start()
	else:
		imagingTimer.stop()
		
func getLambertian():
	var angle = rng.randf_range(-PI/2.0,PI/2.0)
	var uVal = rng.randf()
	while uVal > cos(angle):
		#print(uVal, ", ", cos(angle))
		angle = rng.randf_range(-PI/2.0,PI/2.0)
		uVal = rng.randf()
	return angle
	
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, _collider:Object):	
	if not imagingMode:
		var newColor = photonObj.rayColor * objectColor
		var totalColor = photonObj.rayColor.x + photonObj.rayColor.y + photonObj.rayColor.z
		var energyPerColor = (photonObj.rayColor / totalColor) * photonObj.energy
		var newEnergyPerColor = energyPerColor * newColor 
		var newTotalEnergy = newEnergyPerColor.x + newEnergyPerColor.y + newEnergyPerColor.z
		if newTotalEnergy >= 0.1:
			var instance = ray.instantiate()
			#Color, energy, IOR, and direction are the same as the incoming ray
			instance.rayColor = newColor
			instance.energy = photonObj.energy
			instance.index_of_refraction = photonObj.index_of_refraction
					#Reflect off the splitter
			var newAngle = getLambertian() + collNormal.angle()
			instance.propDir = Vector2(cos(newAngle),sin(newAngle)).normalized()
			instance.global_position = collPoint
			photonObj.rayDying = true
			
			#If the splitter isn't root then add the child to the parent
			if objectParent:
				objectParent.add_child(instance)
			#Otherwise make it a child of itself (mostly for debugging)
			else:
				add_child(instance)
			#instance.update_energy(newTotalEnergy)
		else:
			photonObj.rayDying = true
	
	

