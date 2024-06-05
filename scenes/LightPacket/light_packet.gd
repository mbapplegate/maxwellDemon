extends Node2D
class_name lightPacket
@onready var line = $Line2D
@onready var ray = $RayCast2D
#@onready var circ = $DEBUG
#@onready var circ2 = $DEBUG2

const SPEED = 400
const LEN = 250
const RAY_ENERGY_CUTOFF = .1

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

signal hitSomething(rayObject, collisionPoint, collisionNormal, collider)
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
	line.add_point(Vector2.ZERO)
	line.position = Vector2.ZERO
	#circ.position = Vector2.ZERO
	#circ2.position = Vector2.ZERO
	numPoints = 2
	winSize = DisplayServer.window_get_size()
	
	line.material.set_shader_parameter("red",rayColor[0])
	line.material.set_shader_parameter("green",rayColor[1])
	line.material.set_shader_parameter("blue",rayColor[2])
	line.material.set_shader_parameter("energy",energy)
	line.material.set_shader_parameter("propVisibleFront",0.0)
	line.material.set_shader_parameter("propVisibleEnd",1.0)

func setPaused(val):
	if val:
		isPaused = true
	else:
		isPaused = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isPaused:
		pass
	else:
		#Move the second point by one increment                                  #Number of points in the line
		var currentPointFront = line.get_point_position(numPoints-1)           #Front of ray
		var nextPointFront = currentPointFront + propDir.normalized()*SPEED*delta   #New position of front of ray
		var currentPointBack = line.get_point_position(0)
		var startDirToNextPointBack = line.get_point_position(0).direction_to(line.get_point_position(1))
		var nextPointBack = currentPointBack+startDirToNextPointBack*SPEED*delta
		var endDirToNextPointBack = nextPointBack.direction_to(line.get_point_position(1))
		
		if not endDirToNextPointBack.is_equal_approx(startDirToNextPointBack):
			nextPointBack = line.get_point_position(1)
		#Adjust the raycast
		ray.position = currentPointFront
		ray.set_target_position(propDir.normalized()*SPEED*delta)
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
					#Send a signal to that collider to handle the collision depending on what it is
					if not is_connected("hitSomething",collHandler._ray_hit):
						connect("hitSomething",collHandler._ray_hit)
					hitSomething.emit(self, ray.get_collision_point(), ray.get_collision_normal(),  ray.get_collider())
					#Disconnect the signal to keep things clean
					disconnect("hitSomething",collHandler._ray_hit)
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
	var frontPoint = self.to_global(line.get_point_position(numPoints-1))
	if (frontPoint.x < 0) or (frontPoint.y < 0) or (frontPoint.x > winSize[0]) or (frontPoint.y > winSize[1]):
		rayDying = true
		
func ray_add_point(newPt:Vector2):
	line.add_point(newPt)
	numPoints += 1
	
func _get_packet_length(pointArray:PackedVector2Array):
	var lineLen = 0.0
	for i in range(pointArray.size()-1):
		lineLen += pointArray[i].distance_to(pointArray[i+1])
	
	return lineLen
#
func _update_line_position(currentPtFront:Vector2, nextPtFront:Vector2, nextPtBack:Vector2):
	line.set_point_position(numPoints-1,nextPtFront)
	line.set_point_position(0,nextPtBack)
	#circ.position = nextPtFront
	#circ2.position = nextPtBack
	if numPoints > 2:
		if line.get_point_position(0).distance_squared_to(line.get_point_position(1)) <= 9.0:
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
	
	
