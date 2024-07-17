extends pushableObject

@export var sideLength : float = 120
@export var prismIOR : Vector3 = Vector3(2.05,2.00,1.95)

const COLLISION_THICKNESS = 4.0

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
	
	var minDeviation = 2*(rad_to_deg(asin(prismIOR[1]*sin(deg_to_rad(30))))-30)
	var incidentAngle = (60+minDeviation) / 2.0
	#print(minDeviation, ", ", incidentAngle)
	if not isRotatable and initialAngle != 0:
		var radAngle = deg_to_rad(initialAngle)
		$Stage/Polygon2D.rotation=radAngle
		$Stage/bodyA.rotation = radAngle
		$Stage/bodyB.rotation = radAngle
		$Stage/bodyC.rotation = radAngle
		
	
func _ray_hit(photonObj:Object, collPoint:Vector2, collNormal:Vector2, _collider:Object):
	var thisIndex = 1.0
	
	if photonObj.rayColor[0] > 0:
		thisIndex = prismIOR[0]
	elif photonObj.rayColor[1] > 0:
		thisIndex = prismIOR[1]
	else:
		thisIndex = prismIOR[2]
	#$Stage/Sprite2D.position = to_local(collPoint)
	#$Stage/Sprite2D2.position = collNormal*25.0+to_local(collPoint)
	photonObj.refractRay(collNormal, thisIndex, collPoint)
	#print(photonObj.index_of_refraction)
