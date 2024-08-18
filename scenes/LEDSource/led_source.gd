extends pushableObject

const EMITTER_HEIGHT : int = 16

@export var numBeams : int = 5
@export var rayColor : Vector3 = Vector3(0.0, 1.0, 0.0)
@export var HalfAngleDeg : float = 60.0
@onready var emitterSprite = $Stage/EmitterSprite

signal registerRays(pos:Array, color:Vector3, energy:float, direction:Vector2, IOR:float, source:Object)
signal startRays(source:Object)
signal stopRays(source:Object)
signal sourceMoved(newLocation:Array,newDirection:Vector2,source:Object)

var ledParent = null
var ledEnergy = Vector3.ZERO
var rng = RandomNumberGenerator.new()
func _ready():
	if not isRotatable and initialAngle != 0:
		$Stage/backingSprite.rotation=deg_to_rad(initialAngle)
		emitterSprite.rotation=deg_to_rad(initialAngle)
	ledParent = get_parent()
	emitterSprite.modulate = Color(rayColor[0], rayColor[1],rayColor[2])
	ledEnergy = rayColor/rayColor.length_squared()
	energizeChanged.connect(handleEnergizeChanged)
	rotationChanged.connect(handleRotationChange)
	stageMoved.connect(handleMotion)
	await get_tree().process_frame
	registerBeams()

func _ray_hit(photonObj:Object, collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.stopBeam(collPoint)

func getRayDirections()->Array:
	var rayDirections = []
	#rayDirections.resize(numBeams)
	var locNumBeams = numBeams
	var angleToUse = 0.0
	if isRotatable:
		angleToUse = sprite.rotation
	else:
		angleToUse = emitterSprite.rotation
	
	if locNumBeams%2 != 0:
		rayDirections.append(Vector2(cos(angleToUse),sin(angleToUse)))
		locNumBeams -= 1
	
	var spacing = deg_to_rad(HalfAngleDeg/(locNumBeams/2.0))
	for i in range(locNumBeams/2.0):
		rayDirections.append(Vector2(cos((i+1)*spacing+angleToUse),sin((i+1)*spacing+angleToUse)))
		rayDirections.append(Vector2(cos((i+1)*-spacing+angleToUse),sin((i+1)*-spacing+angleToUse)))
		
	return rayDirections

func getRayStartLocs()->Array:
	var startLocs = []
	startLocs.resize(numBeams)
	startLocs.fill(to_global(Vector2.ZERO))
	#var angleToUse = 0.0
	#if isRotatable:
		#angleToUse = sprite.rotation
	#else:
		#angleToUse = emitterSprite.rotation
		
	#for i in range(numBeams):
		##var locHeight = rng.randi_range(-EMITTER_HEIGHT/2,EMITTER_HEIGHT/2)
		#startLocs[i] = to_global(Vector2(-locHeight*sin(angleToUse),locHeight*cos(angleToUse)))
		##startLocs[i] = to_global(Vector2.ZERO)
	return startLocs
	
func registerBeams():
	#var startLocs = getRayStartLocs()
	var startDirs = getRayDirections()
	var locs = getRayStartLocs()
	registerRays.emit(locs,rayColor,1.0,startDirs,1.0,self)
	
func handleEnergizeChanged(val:bool):
	if val:
		startRays.emit(self)
	else:
		stopRays.emit(self)

func handleRotationChange():
	handleMotion()
		
func handleMotion():
	var startLocs = getRayStartLocs()
	var startDirs = getRayDirections()

	sourceMoved.emit(startLocs,startDirs,self)
	
#func _on_timer_timeout():
	#var angle = 0.0
	#var uVal= 0.0
##	var instance 
	#var instanceRed = null
	#var instanceGreen = null
	#var instanceBlue = null
	#if (isEnergized):
		#for i in numRaysPerTimeout:
			#
			#angle = rng.randf_range(-PI/2.0,PI/2.0)
			#uVal = rng.randf()
			#while uVal > cos(angle):
				##print(uVal, ", ", cos(angle))
				#angle = rng.randf_range(-PI/2.0,PI/2.0)
				#uVal = rng.randf()
			##print("Timeout. Angle: ",angle)
			##print("Timeout. Angle: ",angle)
			#if ledEnergy[0] > 0.1:
				#instanceRed = ray.instantiate()
				#instanceRed.propDir =Vector2(cos(angle),sin(angle))
				#instanceRed.position = to_global(Vector2.ZERO)
				#instanceRed.rayColor = Vector3(1,0,0)
				#instanceRed.energy = ledEnergy[0]
				#instanceRed.lightSource = "LED"
			#
			#if ledEnergy[1] > 0.1:
				#instanceGreen = ray.instantiate()
				#instanceGreen.propDir = Vector2(cos(angle),sin(angle))
				#instanceGreen.position =to_global(Vector2.ZERO)
				#instanceGreen.rayColor = Vector3(0,1,0)
				#instanceGreen.energy = ledEnergy[1]
				#instanceGreen.lightSource = "LED"
			#
			#if ledEnergy[2] > 0.1:
				#instanceBlue = ray.instantiate()
				#instanceBlue.propDir =Vector2(cos(angle),sin(angle))
				#instanceBlue.position = to_global(Vector2.ZERO)
				#instanceBlue.rayColor = Vector3(0,0,1)
				#instanceBlue.energy = ledEnergy[2]
				#instanceBlue.lightSource = "LED"
			##instance.scale[0] = 1.0/self.scale[0]
			##instance.scale[1] = 1.0 / self.scale[1]
			#if ledParent:
				#if instanceRed:
					#ledParent.add_child(instanceRed)
				#if instanceGreen:
					#ledParent.add_child(instanceGreen)
				#if instanceBlue:
					#ledParent.add_child(instanceBlue)
			#else:
				#if instanceRed:
					#add_child(instanceRed)
				#if instanceGreen:
					#add_child(instanceGreen)
				#if instanceBlue:
					#add_child(instanceBlue)
