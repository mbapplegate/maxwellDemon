extends pushableObject

@export var HALF_HEIGHT = 0.0
@export var halfAngle = 0.0
@export var numRaysPerTimeout : int = 1
@export var rayColor : Vector3 = Vector3(1.0, 0, 1.0)
@export var timerTimeout : float = 0.063
@onready var barrelShape = $Stage/laserBarrel/barrelArea/barrelShape
@onready var barrel = $Stage/laserBarrel
@onready var timer = $Timer
@onready var ray = preload("res://scenes/LightPacket/light_packet.tscn")

var rng = RandomNumberGenerator.new()
var isPaused = false
var laserParent= null
const halfHeight = 32.0

func _ready():
	#halfHeight = BARREL_WIDTH * self.scale.x
	#print(halfHeight)
	#isEnergized = true
	if not isRotatable and initialAngle != 0:
		barrel.rotation=deg_to_rad(initialAngle)
	halfAngle = deg_to_rad(halfAngle)
	laserParent = get_parent()
	timer.wait_time=timerTimeout
	pass
	
func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true

func setPaused(val):
	if val:
		timer.stop()
		isPaused = true
	else:
		timer.start()
		isPaused = false
		
func _on_timer_timeout():
	var angle = 0
	var instance 
	var yLoc
	var angleToUse = 0.0
	if isRotatable:
		angleToUse = sprite.rotation
	else:
		angleToUse = barrel.rotation
		
	if (isEnergized):
		
		var barrelPosition = Vector2(barrelShape.position.x+(barrelShape.shape.size[0]/2.0+1.0)*cos(angleToUse),barrelShape.position.y-(barrelShape.shape.size[0]/2.0+1.0)*sin(angleToUse))
		for i in numRaysPerTimeout:
			if halfAngle > 0:
				angle = rng.randf_range(-halfAngle,halfAngle)
			
			if HALF_HEIGHT > 0:
				yLoc = max(min(halfHeight,rng.randfn(0,HALF_HEIGHT/2.0)),-halfHeight)
			else:
				yLoc = 0
			#print("Timeout. Angle: ",angle)
			instance = ray.instantiate()
			instance.propDir = Vector2(cos(angle+angleToUse),sin(angle+angleToUse))
			instance.position = to_global(Vector2(barrelPosition.x+yLoc*sin(angleToUse), -barrelPosition.y-yLoc*cos(angleToUse)))
			
			instance.rayColor = rayColor
			instance.lightSource = "laser"
			#instance.scale[0] = 1.0/self.scale[0]
			#instance.scale[1] = 1.0 / self.scale[1]
			if laserParent:
				laserParent.add_child(instance)
