extends Node2D


@export var total_height = 120
@export var thickness = 8
@export var snapX : bool = false
@export var snapY : bool = true
@export var filterAbsorption : Color = Color(1.0,0.0,0.0,0.5)
const collThickness = 2
const TILE_SIZE = 32

@onready var filter = $filterBody/filterShape
@onready var filterSprite = $filterBody/ColorRect
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")
@onready var filterParent = get_parent()
signal rayHit(energy)

func _ready():
	var snappedPos = global_position.snapped(Vector2(TILE_SIZE,TILE_SIZE))
	if snapY:
		global_position.y = snappedPos.y
	if snapX:
		global_position.x = snappedPos.x
	#print("Ht: ", shapeHt, ", y-Offset: ", shapeOffset)
	filter.position = Vector2(0,thickness/2.0)
	filter.shape.size = Vector2(collThickness,total_height)
	
	filterSprite.set_deferred("size", Vector2(thickness,total_height))
	filterSprite.set_deferred("position",Vector2(-thickness/2.0, -total_height/2.0))
	filterSprite.color = Color(1.0-filterAbsorption[0],1.0-filterAbsorption[1],1.0-filterAbsorption[2],0.5)
	#botTex.position = botShape.position
	#botTex.region_rect = Rect2(botShape.position.x,botShape.position.y,thickness, shapeHt)
	
func _ray_hit(photonObj:Object, collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	#print("Hit Center")
	#Create new ray
	var instance = ray.instantiate()
	#Color, energy, IOR, and direction are the same as the incoming ray
	var absVector = Vector3(filterAbsorption[0],filterAbsorption[1], filterAbsorption[2])
	instance.rayColor = photonObj.rayColor * (Vector3.ONE-absVector)
	instance.energy = photonObj.energy * (instance.rayColor.length_squared() / photonObj.rayColor.length_squared())
	instance.index_of_refraction = photonObj.index_of_refraction
	#Reflect off the splitter
	instance.propDir = photonObj.propDir
	#Sometimes the collision normal will be NULL, so check that
	instance.global_position = collPoint
	#If the splitter isn't root then add the child to the parent
	if filterParent:
		instance.lightSource = "filterAbs"
		filterParent.add_child(instance)
	#Otherwise make it a child of itself (mostly for debugging)
	else:
		instance.position = to_local(collPoint)
		add_child(instance)
	#Update photon packet energies depending on reflectivity
	instance.update_energy(instance.energy)
	photonObj.rayDying = true

