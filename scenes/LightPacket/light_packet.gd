extends Node2D
class_name lightPacket
var thisScene = "res://scenes/LightPacket/light_packet.tscn" 
@onready var line = $Line2D
@onready var ray = $RayCast2D
#@onready var circ = $DEBUG
#@onready var circ2 = $DEBUG2

const SPEED = 300
const LEN = 250
const RAY_ENERGY_CUTOFF = .1
const MEDIUM_INDEX = 1.0

@export var propDir:Vector2 = Vector2(1,0)
@export var rayColor:Vector3 = Vector3(1.0,0.0,1.0)

var index_of_refraction = 1.0
var energy = 1.0

var proportionVisibleFront = 0.0
var proportionVisibleBack = 1.0
var rayDying = false
var winSize
var lastCollider = null
var numPoints = 0
var lineLength = 0.0
var isPaused = false
var lightSource = ""
var pointPositions = []

#signal hitSomething(rayObject, collisionPoint, collisionNormal, collider)
#
#func clonePacket():
	#var newPacket = self.duplicate()
	#newPacket.propDir = propDir
	#newPacket.rayColor = rayColor
	#newPacket.index_of_refraction = index_of_refraction
	#newPacket.energy = energy
	#newPacket._ready()
	#newPacket.proportionVisibleFront = proportionVisibleFront
	#newPacket.proportionVisibleBack = proportionVisibleBack
	#newPacket.lastCollider = lastCollider
	#newPacket.rayDying = rayDying
	#newPacket.numPoints = numPoints
	#newPacket.line.position = line.position
	#for i in numPoints:
		#newPacket.line.set_point_position(i,line.get_point_position(i))
	#newPacket.line.material.set_shader_parameter("propVisibleFront",proportionVisibleFront)
	#newPacket.line.material.set_shader_parameter("propVisibleEnd",proportionVisibleBack)
	#return newPacket
# Called when the node enters the scene tree for the first time.
func _ready():
	line.clear_points();
	line.add_point(-propDir.normalized() * LEN);
	pointPositions.append(-propDir.normalized() * LEN)
	line.add_point(Vector2.ZERO)
	line.position = Vector2.ZERO
	pointPositions.push_back(Vector2.ZERO)
	#circ.position = Vector2.ZERO
	#circ2.position = Vector2.ZERO
	numPoints = 2
	winSize = DisplayServer.window_get_size()
	
	line.material.set_shader_parameter("red",rayColor[0])
	line.material.set_shader_parameter("green",rayColor[1])
	line.material.set_shader_parameter("blue",rayColor[2])
	line.material.set_shader_parameter("energy",sqrt(energy))
	line.material.set_shader_parameter("propVisibleFront",0.0)
	line.material.set_shader_parameter("propVisibleEnd",1.0)

func setPaused(val):
	if val:
		isPaused = true
	else:
		isPaused = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if isPaused:
		pass
	else:
		var speedInMedium = SPEED#(SPEED/index_of_refraction)
		var thisDist = speedInMedium*delta
		#if thisDist > 10:
			#thisDist = 10
		#Move the second point by one increment                                  #Number of points in the line
		var currentPointFront = line.get_point_position(numPoints-1)           #Front of ray
		var nextPointFront = currentPointFront + propDir.normalized()*thisDist   #New position of front of ray
		var currentPointBack = line.get_point_position(0)
		var startDirToNextPointBack = line.get_point_position(0).direction_to(line.get_point_position(1))
		var nextPointBack = currentPointBack+startDirToNextPointBack*thisDist
		var endDirToNextPointBack = nextPointBack.direction_to(line.get_point_position(1))
		
		if not endDirToNextPointBack.is_equal_approx(startDirToNextPointBack):
			nextPointBack = line.get_point_position(1)
		#Adjust the raycast
		if not rayDying:
			ray.position = currentPointFront
			ray.set_target_position(propDir.normalized()*thisDist)
			ray.force_raycast_update()
		
		#Detect interfaces
		#Ray hasn't hit anything, so move the ray forward
		if not ray.is_colliding():
			_update_line_position(currentPointFront,nextPointFront,nextPointBack)
		#OK, the ray has hit something -- this is a big deal and we'll figure it out together
		else:
			#If the ray is alive (hasn't left the scene or hit an absorber)
			if not rayDying:
				#AAAND it's hitting something new
				if (ray.get_collider() != lastCollider):
					#print(_get_packet_length(line.points))
					#Update the last collider
					lastCollider = ray.get_collider()
					var collHandler = _get_functional_collider(lastCollider)
					collHandler._ray_hit(self, ray.get_collision_point(), ray.get_collision_normal(),  ray.get_collider())
					
					var distFrontTraveled = currentPointFront.distance_to(to_local(ray.get_collision_point()))
					nextPointBack = currentPointBack+startDirToNextPointBack*distFrontTraveled
					nextPointFront = to_local(ray.get_collision_point())
					endDirToNextPointBack = nextPointBack.direction_to(line.get_point_position(1))
					if not endDirToNextPointBack.is_equal_approx(startDirToNextPointBack):
						nextPointBack = line.get_point_position(1)
					#Advance the first point to the collision point and the back point to the next point
					_update_line_position(currentPointFront,nextPointFront,nextPointBack)
				#We've collided with the same thing as before, so ignore the collision
				else:
					_update_line_position(currentPointFront,nextPointFront,nextPointBack)	
			else:
				_update_line_position(currentPointFront,nextPointFront,nextPointBack)
		
		#If the ray is dying and has fully been absorbed, kill the ray
		if ((rayDying and proportionVisibleBack == 0.0) or numPoints == 1):
			queue_free()
			
		_has_ray_left_screen()

#Walks up the tree until something with a _ray_hit method is found
#If no method is found -- return null which I think means the object is ignored
func _get_functional_collider(collider:Object):
	while not collider.has_method("_ray_hit") or collider == get_tree().root:
		collider = collider.get_parent()
	if collider == get_tree().root:
		return null
	else:
		return collider
		
func _has_ray_left_screen():
	return false
	#var frontPoint = self.to_global(line.get_point_position(numPoints-1))
	#if (frontPoint.x < 0) or (frontPoint.y < 0) or (frontPoint.x > winSize[0]) or (frontPoint.y > winSize[1]):
		#rayDying = true
		
func ray_add_point(newPt:Vector2):
	line.add_point(newPt)
	pointPositions.push_back(newPt)
	numPoints += 1
	
func _get_packet_length(pointArray:PackedVector2Array):
	var lineLen = 0.0
	for i in range(pointArray.size()-1):
		lineLen += pointArray[i].distance_to(pointArray[i+1])
	
	return lineLen
#
func _update_line_position(currentPtFront:Vector2, nextPtFront:Vector2, nextPtBack:Vector2):
	line.set_point_position(numPoints-1,nextPtFront)
	pointPositions[numPoints-1] = nextPtFront
	line.set_point_position(0,nextPtBack)
	pointPositions[0] = nextPtBack
	#circ.position = nextPtFront
	#circ2.position = nextPtBack
	if numPoints > 2:
		if line.get_point_position(0).distance_squared_to(line.get_point_position(1)) <= 4.0:
				
				line.remove_point(0)
				numPoints -= 1

	if (proportionVisibleFront < 1.0):
		proportionVisibleFront += abs(nextPtFront.distance_to(currentPtFront)) / LEN
		if proportionVisibleFront > 1.0:
			proportionVisibleFront = 1.0
		line.material.set_shader_parameter("propVisibleFront",proportionVisibleFront)
	if (rayDying):
		if (proportionVisibleBack > 0):
			proportionVisibleBack -= abs(nextPtFront.distance_to(currentPtFront))/LEN
			if proportionVisibleBack < 0.0:
				proportionVisibleBack = 0.0
			line.material.set_shader_parameter("propVisibleEnd",proportionVisibleBack)
	#print(proportionVisibleBack)
	
	#if numPoints > 2:
		#lineLength = 0.0
		#for i in numPoints-1:
			#lineLength += line.get_point_position(i+1).distance_squared_to(line.get_point_position(i))
		#if lineLength > (1.1*LEN)*(1.1*LEN):
			#print("Point removed")
			#line.remove_point(0)
			#numPoints -= 1
		
func update_energy(newEnergy:float):
	if newEnergy > 1.0:
		energy = 1.0
	if newEnergy < RAY_ENERGY_CUTOFF:
		energy = 0
		propDir = Vector2.ZERO
		rayDying = true
	else:
		energy = newEnergy
		line.material.set_shader_parameter("energy",sqrt(energy))
		
func set_ray_color(newColor: Vector3):
	rayColor = newColor
	line.material.set_shader_parameter("red",rayColor[0])
	line.material.set_shader_parameter("green",rayColor[1])
	line.material.set_shader_parameter("blue",rayColor[2])
	
func addCollisionException(noCollideObject : Object):
	if noCollideObject:
		ray.add_exception(noCollideObject)
	
func removeCollisionException(collideObject : Object):
	if collideObject:
		ray.remove_exception(collideObject)

func cloneRay(propDirection : Vector2, newColor : Vector3) -> lightPacket:
	var newRay = load(thisScene).instantiate()
	newRay.propDir = propDirection
	newRay.rayColor = newColor
	newRay.index_of_refraction = index_of_refraction
	newRay.position = self.position
	newRay.energy = energy
	self.get_parent().add_child(newRay)
	newRay.update_energy(energy)
	return newRay
		
func reflectRay(normalAngle, collisionPoint) ->Vector2:
	if normalAngle:
		var newDir = getReflectionDirection(normalAngle)
		propDir = newDir
		ray_add_point(to_local(round(collisionPoint)))
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
			
			ray_add_point(to_local(collisionPoint))
			
func stopBeam():
	rayDying = true
		
	
	
