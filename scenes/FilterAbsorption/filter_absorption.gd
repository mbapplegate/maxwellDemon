extends pushableObject

const mediumIndex = 1.0
const COLLISION_WIDTH = 6

@export var filterIndex : float = 2.0
@export var filterWidth : int = 20
@export var filterHeight : int = 120
@export var filterAbsorbance : Color = Color(1.0,0.0,0.0)
@onready var filterCenterShape = $Stage/Center/CenterColl
@onready var filterLeftShape = $Stage/Left/WallLeftColl
@onready var filterRightShape = $Stage/Right/WallRightColl
@onready var filterSprite = $Stage/ColorRect
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")

@onready var filterParent = get_parent()

func _ready():
	filterCenterShape.shape.size = Vector2(COLLISION_WIDTH,filterHeight)
	filterCenterShape.position = Vector2.ZERO
	filterLeftShape.shape.size = Vector2(COLLISION_WIDTH,filterHeight)
	filterLeftShape.position = Vector2(-filterWidth/2.0+1,0)
	filterRightShape.shape.size = Vector2(COLLISION_WIDTH,filterHeight)
	filterRightShape.position = Vector2(filterWidth/2.0-1,0)
	filterSprite.set_deferred("size", Vector2(filterWidth,filterHeight))
	filterSprite.set_deferred("position",Vector2(-filterWidth/2.0, -filterHeight/2.0))
	#filterSprite.size = Vector2(filterWidth,filterHeight)
	#filterSprite.position = Vector2(-filterWidth/2.0, -filterHeight/2.0)
	isEnergizeable = false
	filterSprite.color = Color(1.0-filterAbsorbance[0],1.0-filterAbsorbance[1],1.0-filterAbsorbance[2],0.5)
	filterSprite.pivot_offset = Vector2(filterWidth/2.0,filterHeight/2.0)
	if not isRotatable and initialAngle != 0:
		$Stage/Center.rotation=deg_to_rad(initialAngle)
		$Stage/Left.rotation=deg_to_rad(initialAngle)
		$Stage/Right.rotation=deg_to_rad(initialAngle)
		$Stage/ColorRect.rotation=deg_to_rad(initialAngle)

#Function to handle if a ray collides with either the walls of the cube or the splitter
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, collider:Object):
	if collider == $Stage/Center:
		var thisAbs = 0.0
		if photonObj.rayColor[0] > 0:
			thisAbs = filterAbsorbance[0]
		elif photonObj.rayColor[1] > 0:
			thisAbs = filterAbsorbance[1]
		else:
			thisAbs = filterAbsorbance[2]
		#print("Hit Center")
		#Create new ray
		if thisAbs == 1.0:
			photonObj.rayDying = true
		elif thisAbs == 0.0:
			pass
		else:
			var thisEnergy = photonObj.energy * (1-thisAbs)
			if thisEnergy < 0.1:
				photonObj.rayDying = true
			else:
				var instance = ray.instantiate()
				#Color, energy, IOR, and direction are the same as the incoming ray
				#var absVector = Vector3(filterAbsorbance[0],filterAbsorbance[1], filterAbsorbance[2])
				instance.rayColor = photonObj.rayColor
				instance.energy = thisEnergy
				instance.index_of_refraction = photonObj.index_of_refraction
				#Reflect off the splitter
				instance.propDir = photonObj.propDir
				#Sometimes the collision normal will be NULL, so check that
				instance.global_position = collPoint
				#If the splitter isn't root then add the child to the parent
				if photonObj.get_parent():
					instance.lightSource = "filterAbs"
					photonObj.get_parent().add_child(instance)
				#Otherwise make it a child of itself (mostly for debugging)
				else:
					instance.position = to_local(collPoint)
					add_child(instance)
				#Update photon packet energies depending on reflectivity
				instance.update_energy(instance.energy)
				photonObj.rayDying = true
	else:
		photonObj.refractRay(collNormal, filterIndex, collPoint)
