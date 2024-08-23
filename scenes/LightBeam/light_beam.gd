extends Node2D
class_name LightBeam

@export var originalPropDir : Vector2 = Vector2.RIGHT
@export var rayColor : Vector3 = Vector3(1.0,0.0,0.0)
@export var sourcePos : Vector2 = Vector2.ZERO

@onready var line = $lightLine
@onready var cast = $lightCast
@onready var pulseTexture = preload("res://scenes/LightBeam/pulseTexture.png")

const MEDIUM_INDEX : float = 1.0
const BEAM_STEP : int = 1024
const PULSE_SPEED : int = 300
const PULSE_SPACING : int = 128
const MAX_ITERS : int = 20

var energy : float = 1.0
var index_of_refraction : float = 1.0
var beamLength : float = 0.0
var beamDying : bool = false
var numPoints : int = 0
var lastCollider : Object = null
var beamGoing : bool = false
var propDone : bool = false
var propDir = Vector2.RIGHT
var lightSource = ""
var pulseArrived : bool = false

func _ready():
	$Timer.wait_time = PULSE_SPACING/float(PULSE_SPEED)
	propDir = originalPropDir
	line.default_color = Color(rayColor[0], rayColor[1], rayColor[2], _getAlpha(energy))

func defineBeam(location:Vector2, color:Vector3, newEnergy:float, direction:Vector2, IOR:float):
	originalPropDir = direction
	sourcePos = location
	rayColor = color
	energy = newEnergy
	index_of_refraction = IOR
	line.default_color = Color(rayColor[0], rayColor[1], rayColor[2], _getAlpha(energy))
	
func moveBeam(location:Vector2, direction:Vector2):
	originalPropDir = direction
	sourcePos = location
	
func propagateBeam():
	propDone = false
	#lastCollider = null
	line.clear_points()
	beamLength = 0
	numPoints = 0
	beamAddPoint(sourcePos)
	#$Path2D/PathFollow2D/Sprite2D.position = sourcePos
	cast.set_position(sourcePos)
	cast.set_target_position(propDir.normalized()*BEAM_STEP)
	cast.force_raycast_update()
	beamGoing = true
	beamDying = false
	var numIters = 0
	while not beamDying and numIters < MAX_ITERS:
		numIters += 1
		if not cast.is_colliding():
			beamAddPoint(cast.position+cast.target_position)
			cast.position += cast.target_position
			cast.set_target_position(propDir.normalized()*512)
			cast.force_raycast_update()
			#print(cast.position, ", ", cast.target_position)
		#OK, the ray has hit something -- this is a big deal and we'll figure it out together
		else:
			if (cast.get_collider() != lastCollider):
				lastCollider = cast.get_collider()
				var collHandler = _get_functional_collider(lastCollider)
				collHandler._ray_hit(self, cast.get_collision_point(), cast.get_collision_normal(),  cast.get_collider())
				if not beamDying:
					cast.position = to_local(cast.get_collision_point())
					cast.set_target_position(propDir.normalized()*512)
					cast.force_raycast_update()
			else:
				cast.position = to_local(cast.get_collision_point()+propDir.normalized()*10)
				cast.set_target_position(propDir.normalized()*512)
				cast.force_raycast_update()
		#print(propDir,", ", originalPropDir)
		#print(cast.position, ", ", cast.target_position)
		#$Sprite2D.position = cast.position
	if numIters == MAX_ITERS-1:
		print("Too many bounces")
	_beamToPath($Path2D)
	propDone = true
	if $Timer.is_stopped():
		_on_timer_timeout()
	

func _beamToPath(pathObject:Path2D):
	pathObject.curve.clear_points()
	#$Path2D/PathFollow2D/Sprite2D.position = line.get_point_position(0)
	for i in range(numPoints):
		pathObject.curve.add_point(line.get_point_position(i))
		
func reflectRay(normalAngle, collisionPoint) ->Vector2:
	if normalAngle:
		var newDir = getReflectionDirection(normalAngle)
		propDir = newDir
		beamAddPoint(to_local(collisionPoint))
		return newDir
	else:
		return propDir

func getReflectionDirection(normalAngle : Vector2)->Vector2:
	if normalAngle:
		return propDir.reflect(normalAngle.rotated(PI/2).normalized()).normalized()
	else:
		return propDir

func getRefractionInfo(normalAngle,objectIOR) -> Array:
	if objectIOR == MEDIUM_INDEX:
		return [propDir, MEDIUM_INDEX]
	else:
		var newDirection :Vector2
		var normalIn = -normalAngle;
		var theta1 = normalIn.angle_to(propDir)
		var theta2
		var internalReflection = false
		var newIndex
		#Going from high index to low index
		if index_of_refraction > MEDIUM_INDEX:
			var arg =  objectIOR/MEDIUM_INDEX * sin(theta1)
			if abs(arg) <= 1.0:
				theta2 = asin(objectIOR/MEDIUM_INDEX * sin(theta1))
				newIndex = MEDIUM_INDEX
			else:
				newDirection = getReflectionDirection(normalAngle)
				internalReflection=true
				newIndex = index_of_refraction
		#Going from low index to high index
		else:
			theta2 = asin(MEDIUM_INDEX/objectIOR*sin(theta1))
			newIndex = objectIOR
		#Add the point to the photon packet
		
		if not internalReflection:
			newDirection = normalIn.rotated(theta2)
		
		return [newDirection, newIndex]
	
func refractRay(normalAngle, objectIOR,collisionPoint):
	
	var refractInfo = getRefractionInfo(normalAngle,objectIOR)
	index_of_refraction = refractInfo[1]
	var newDir = refractInfo[0]	
		
	propDir = newDir
	beamAddPoint(to_local(collisionPoint))
	
		
			
func beamAddPoint(newPointLoc : Vector2):
	line.add_point(newPointLoc)
	numPoints += 1
	if numPoints > 1:
		beamLength += line.get_point_position(numPoints-2).distance_to(line.get_point_position(numPoints-1))
	
#Walks up the tree until something with a _ray_hit method is found
#If no method is found -- return null which I think means the object is ignored
func _get_functional_collider(collider:Object) -> Object:
	while not collider.has_method("_ray_hit") or collider == get_tree().root:
		collider = collider.get_parent()
	if collider == get_tree().root:
		return null
	else:
		return collider
		
func stopBeam(globalStopLoc : Vector2):
	beamAddPoint(to_local(globalStopLoc))
	beamDying = true
	beamGoing = false
		
func _getAlpha(beamEnergy : float) -> float:
	if beamEnergy > .9:
		return .3
	elif beamEnergy < .1:
		return 0
	else:
		return 0.2
		
func _spawnPulse()->Array:
	var isDetected = false
	var pathInstance = Path2D.new()
	pathInstance.curve = $Path2D.curve.duplicate()
	add_child(pathInstance)
	var followInstance = PathFollow2D.new()
	pathInstance.add_child(followInstance)
	var spriteInstance = Sprite2D.new()
	spriteInstance.texture = pulseTexture
	spriteInstance.scale = Vector2.ONE*0.2
	spriteInstance.self_modulate = Color(rayColor[0],rayColor[1],rayColor[2])
	spriteInstance.material = CanvasItemMaterial.new()
	spriteInstance.material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	spriteInstance.position = Vector2(-(spriteInstance.texture.get_width()*0.1), 0.0)
	followInstance.add_child(spriteInstance)
	if lastCollider.name == "activeArea":
		isDetected = true
	return [pathInstance,followInstance, isDetected]
	
func _on_timer_timeout():
	if propDone:
		var pulseObjects = _spawnPulse()
		pulseObjects[1].progress_ratio = 0
		var t = create_tween().set_trans(Tween.TRANS_LINEAR)
		t.tween_property(pulseObjects[1],'progress_ratio',1,beamLength/PULSE_SPEED)
		t.finished.connect(_destroyPulse.bind(pulseObjects[0],pulseObjects[2]))
		$Timer.start()

func _destroyPulse(followNode:Path2D, isDetected:bool):
	if is_instance_valid(followNode):
		followNode.queue_free()
		if lastCollider:
			var realCollider = _get_functional_collider(lastCollider)
			if realCollider is PointDetector and isDetected:
				realCollider.pulseHit(energy,self)

func _destroyPulseNoSignal(followNode):	
	if is_instance_valid(followNode):
		followNode.queue_free()
		
func update_energy(val : float):
	energy = val
	line.default_color.a = _getAlpha(val)
	
func clearBeam():
	line.clear_points()
	numPoints = 0
	beamLength = 0
	propDone = false
	beamGoing = false
	lastCollider = null
	pulseArrived = false
	index_of_refraction = 1.0
	propDir = originalPropDir
	#for child in $Path2D.get_children():
		#if child is PathFollow2D:
			#_destroyPulseNoSignal(child)
	#$Timer.stop()
	#$Path2D.curve.clear_points()
	
	
