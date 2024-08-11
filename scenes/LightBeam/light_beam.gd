extends Node2D
class_name LightBeam

@export var propDir : Vector2 = Vector2.RIGHT
@export var rayColor : Vector3 = Vector3(1.0,0.0,0.0)
@export var sourcePos : Vector2 = Vector2.ZERO

@onready var line = $lightLine
@onready var cast = $lightCast

const MEDIUM_INDEX : float = 1.0
const BEAM_STEP : int = 1024
const PULSE_SPEED : int = 512

var energy : float = 1.0
var index_of_refraction : float = 1.0
var beamLength : float = 0.0
var beamDying : bool = false
var numPoints : int = 0
var lastCollider : Object = null
var beamGoing : bool = false
var propDone : bool = false
var lightSource = ""

func _ready():
	line.default_color = Color(rayColor[0], rayColor[1], rayColor[2], _getAlpha(energy))
	
func propagateBeam():
	propDone = false
	lastCollider = null
	line.clear_points()
	beamLength = 0
	numPoints = 0
	beamAddPoint(sourcePos)
	#$Path2D/PathFollow2D/Sprite2D.position = sourcePos
	cast.set_position(sourcePos)
	cast.set_target_position(propDir.normalized()*BEAM_STEP)
	cast.force_raycast_update()
	beamGoing = true
	var numIters = 0
	while not beamDying and numIters < 4:
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
		#print(cast.position, ", ", cast.target_position)
		
		#$Sprite2D.position = cast.position
	_beamToPath()
	propDone = true

func _beamToPath():
	$Path2D.curve.clear_points()
	#$Path2D/PathFollow2D/Sprite2D.position = line.get_point_position(0)
	for i in range(numPoints):
		$Path2D.curve.add_point(line.get_point_position(i))
		
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
		
func refractRay(normalAngle, objectIOR,collisionPoint):
	if objectIOR == MEDIUM_INDEX:
		pass
	else:
		var normalIn = -normalAngle;
		var theta1 = normalIn.angle_to(propDir)
		var theta2
		var internalReflection = false
		#Going from high index to low index
		if index_of_refraction > MEDIUM_INDEX:
			var arg =  objectIOR/MEDIUM_INDEX * sin(theta1)
			if abs(arg) <= 1.0:
				theta2 = asin(objectIOR/MEDIUM_INDEX * sin(theta1))
				index_of_refraction = MEDIUM_INDEX
			else:
				reflectRay(normalAngle,collisionPoint)
				internalReflection=true
		#Going from low index to high index
		else:
			theta2 = asin(MEDIUM_INDEX/objectIOR*sin(theta1))
			index_of_refraction = objectIOR
		#Add the point to the photon packet
		if not internalReflection:
			var newDir = normalIn.rotated(theta2)
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
		return .5
	elif beamEnergy < .1:
		return 0
	else:
		return 0.2 + (1-beamEnergy)/.2

func _on_timer_timeout():
	if propDone:
		$Path2D/PathFollow2D/Sprite2D.visible = true
		var t = create_tween().set_trans(Tween.TRANS_LINEAR)
		t.tween_property($Path2D/PathFollow2D,'progress_ratio',1,beamLength/PULSE_SPEED)
		await t.finished
		$Path2D/PathFollow2D/Sprite2D.visible = false
		$Path2D/PathFollow2D.progress_ratio = 0
		
func update_energy(val : float):
	energy = val
	line.default_color.a = _getAlpha(val)
	
func clearBeam():
	line.clear_points()
	numPoints = 0
	beamLength = 0
	$Path2D.curve.clear_points()
	propDone = false
	beamGoing = false
	lastCollider = null
	
	
