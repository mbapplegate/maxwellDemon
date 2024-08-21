extends pushableObject

@export var sideLength : float = 120
@export var prismIOR : Vector3 = Vector3(2.05,2.00,1.95)

const COLLISION_THICKNESS = 4.0

signal disperseBeam(dispLocation:Vector2,dispDirection:Array, IOR:Vector3, energies:Vector3, originalBeam:Object)

func _ready():
	isEnergizeable = false
	#Altitude of each side
	var alt = sqrt(3.0)/2.0 * sideLength
	#Radius of the circle that hits all points
	var circRadius = 2.0*alt/3.0
	
	var prismPoly = PackedVector2Array()
	var ptA = Vector2(0,-circRadius)
	var ptB = Vector2(circRadius * cos(deg_to_rad(30)),circRadius*sin(deg_to_rad(30)))
	var ptC = Vector2(-circRadius * cos(deg_to_rad(30)),circRadius*sin(deg_to_rad(30)))
	prismPoly.append_array([ptA,ptB,ptC,ptA])
	
	$Stage/bodyA/sideA.shape.a = ptA
	$Stage/bodyA/sideA.shape.b = ptB
	
	$Stage/bodyB/sideB.shape.a = ptB
	$Stage/bodyB/sideB.shape.b = ptC
	
	$Stage/bodyC/sideC.shape.a = ptC
	$Stage/bodyC/sideC.shape.b = ptA
	
	$Stage/Polygon2D.polygon = prismPoly
	
	#var minDeviation = 2*(rad_to_deg(asin(prismIOR[1]*sin(deg_to_rad(30))))-30)
	#var incidentAngle = (60+minDeviation) / 2.0
	#print(minDeviation, ", ", incidentAngle)
	if not isRotatable and initialAngle != 0:
		var radAngle = deg_to_rad(initialAngle)
		$Stage/Polygon2D.rotation=radAngle
		$Stage/bodyA.rotation = radAngle
		$Stage/bodyB.rotation = radAngle
		$Stage/bodyC.rotation = radAngle
		
func _dispersionNeeded(rayColor:Vector3, IOR:Vector3)->bool:
	var hasColor = []
	hasColor.resize(3)
	var usedIOR = []
	for i in range(3):
		if rayColor[i] > 0:
			hasColor[i] = true
			usedIOR.append(IOR[i])
		else:
			hasColor[i] = false
			
	if hasColor.count(true) == 1:
		return false
	else:
		if usedIOR.count(usedIOR[0]) == usedIOR.size():
			return false
		else:
			return true

func _selectIndex(rayColor:Vector3, IOR:Vector3)->float:
	if not _dispersionNeeded(rayColor,IOR):
		for i in range(3):
			if rayColor[i] > 0:
				return IOR[i]
		return -1.0
	else:
		return -1.0
	
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, _collider:Object):
	var indexToUse = _selectIndex(photonObj.rayColor,prismIOR)
	#$Stage/Sprite2D.position = to_local(collPoint)
	#$Stage/Sprite2D2.position = collNormal*25.0+to_local(collPoint)
	if indexToUse != -1:
		photonObj.refractRay(collNormal, indexToUse, collPoint)
	else:
		photonObj.stopBeam(collPoint)
		#print(photonObj.energy)
		var normEnergy = photonObj.rayColor/photonObj.rayColor.length_squared() * photonObj.energy
		var dispersionDirection:Array[Vector2]= []
		var newIORs:Vector3 = Vector3(-1,-1,-1)
		dispersionDirection.resize(3)
		dispersionDirection.fill(Vector2.ZERO)
		
		for i in range(3):
			if normEnergy[i] > 0:
				var dispInformation = photonObj.getRefractionInfo(collNormal,prismIOR[i])
				dispersionDirection[i] = dispInformation[0]
				newIORs[i] = dispInformation[1]
		disperseBeam.emit(collPoint,dispersionDirection, newIORs, normEnergy, photonObj)
	#print(photonObj.index_of_refraction)
