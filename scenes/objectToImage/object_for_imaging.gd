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

func fillLens(rayStart:Vector2):
	if imagingLens:
		var minAngle = rayStart.angle_to_point((Vector2(imagingLens.position.x,imagingLens.position.y-imagingLens.LENS_HEIGHT/2.0)))
		var maxAngle = rayStart.angle_to_point((Vector2(imagingLens.position.x,imagingLens.position.y+imagingLens.LENS_HEIGHT/2.0)))
		var totalAngle = maxAngle - minAngle
		var interiorAngle = TAU - (totalAngle)
		var angle = randf_range(0,interiorAngle/2.0) + maxAngle +interiorAngle/4.0
		return angle
	else:
		return getLambertian()
		
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
			var newAngle = fillLens(collPoint) #+ collNormal.angle()
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
	
	

func launchPrincipalRays(objectTop :Vector2, objectBottom:Vector2):
	launchCenterRays(objectTop, objectBottom)
	launchFocusRays(objectTop,objectBottom)
	launchPerpRays(objectTop, objectBottom)
	
func launchPerpRays(objectTop :Vector2, objectBottom:Vector2):

	var topRay = ray.instantiate()
	var bottomRay = ray.instantiate()
	
	topRay.position = objectTop
	bottomRay.position = objectBottom
	var lensAngle = imagingLens.getRotation()
	
	topRay.propDir = Vector2(cos(lensAngle+PI),sin(lensAngle+PI))
	bottomRay.propDir = Vector2(cos(lensAngle+PI),sin(lensAngle+PI))
	topRay.rayColor = objectColor
	bottomRay.rayColor = objectColor
	if objectParent:
		objectParent.add_child(topRay)
		objectParent.add_child(bottomRay)
	else:	
		add_child(topRay)
		add_child(bottomRay)
	
func launchFocusRays(objectTop :Vector2, objectBottom:Vector2):
	var topRay = ray.instantiate()
	var bottomRay = ray.instantiate()
	
	topRay.position = objectTop
	bottomRay.position = objectBottom
	var focusPts = imagingLens.getFocusPositions()
	topRay.propDir = topRay.position.direction_to(imagingLens.position+focusPts[0])
	bottomRay.propDir = bottomRay.position.direction_to(imagingLens.position+focusPts[0])
	topRay.rayColor = objectColor
	bottomRay.rayColor = objectColor
	if objectParent:
		objectParent.add_child(topRay)
		objectParent.add_child(bottomRay)
	else:	
		add_child(topRay)
		add_child(bottomRay)
	
func launchCenterRays(objectTop :Vector2, objectBottom:Vector2):
	var topRay = ray.instantiate()
	var bottomRay = ray.instantiate()
	
	topRay.position = objectTop
	bottomRay.position = objectBottom
	topRay.rayColor = objectColor
	bottomRay.rayColor = objectColor
	topRay.propDir = topRay.position.direction_to(imagingLens.position)
	bottomRay.propDir = bottomRay.position.direction_to(imagingLens.position)
	
	if objectParent:
		objectParent.add_child(topRay)
		objectParent.add_child(bottomRay)
	else:	
		add_child(topRay)
		add_child(bottomRay)


func _on_timer_timeout():
	if imagingLens:
		var xShift
		if imagingLens.position.x < self.position.x:
			xShift = -pieceSize.x/2.0
		else:
			xShift = pieceSize.x/2.0
		var objectTop = Vector2(self.position.x+xShift, self.position.y+pieceSize.y/2.0)
		var objectBottom = Vector2(self.position.x+xShift,self.position.y-pieceSize.y/2.0)
	
		launchPrincipalRays(objectTop,objectBottom)
		
func _draw():
	draw_line(to_local(Vector2(imagingLens.position.x,imagingLens.position.y-imagingLens.LENS_HEIGHT/2.0)),to_local(Vector2(imagingLens.position.x,imagingLens.position.y+imagingLens.LENS_HEIGHT/2.0)),Color(1.0,0.0,0.0),10)
