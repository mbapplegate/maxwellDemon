extends pushableObject

@export var halfAngle = 0.0
@export var numRaysPerTimeout : int = 1
@export var rayColor : Vector3 = Vector3(1.0, 0, 1.0)
@onready var barrelShape = $Stage/laserBarrel/barrelArea/barrelShape
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")

var rng = RandomNumberGenerator.new()
var laserParent= null
const halfHeight = 32.0

func _ready():
	#halfHeight = BARREL_WIDTH * self.scale.x
	#print(halfHeight)
	#isEnergized = true
	laserParent = get_parent()
	pass
	
func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	print("Hit barrel")
	photonObj.rayDying = true

func _on_timer_timeout():
	var angle = 0
	var instance 
	var yLoc
	if (isEnergized):
		var barrelPosition = Vector2(barrelShape.position.x+(barrelShape.shape.size[0]/2.0+1.0)*cos(sprite.rotation),barrelShape.position.y-(barrelShape.shape.size[0]/2.0+1.0)*sin(sprite.rotation))
		for i in numRaysPerTimeout:
			if halfAngle > 0:
				angle = rng.randf_range(-halfAngle,halfAngle)
		
			yLoc = max(min(halfHeight,rng.randfn(0,halfHeight/2.0)),-halfHeight)
			#print("Timeout. Angle: ",angle)
			instance = ray.instantiate()
			instance.propDir = Vector2(cos(angle+sprite.rotation),sin(angle+sprite.rotation))
			instance.position = to_global(Vector2(barrelPosition.x+yLoc*sin(sprite.rotation), -barrelPosition.y-yLoc*cos(sprite.rotation)))
			
			instance.rayColor = rayColor
			instance.scale[0] = 1.0/self.scale[0]
			instance.scale[1] = 1.0 / self.scale[1]
			if laserParent:
				laserParent.add_child(instance)
