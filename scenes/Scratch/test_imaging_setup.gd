extends Node2D

@onready var imagingLens = $LensPlanoConvex
@onready var objectToImage = $ObjectForImaging

var ray = preload("res://scenes/LightPacket/light_packet.tscn")

func _ready():
	imagingLens.initialize()

func launchPrincipalRays():
	launchCenterRays()
	launchFocusRays()
	launchPerpRays()
	
func launchPerpRays():
	var objectTop = objectToImage.position + Vector2(-objectToImage.pieceSize.x/2.0,-objectToImage.pieceSize.y/2.0)
	var objectBottom = objectToImage.position +Vector2(-objectToImage.pieceSize.x/2.0,objectToImage.pieceSize.y/2.0)

	var topRay = ray.instantiate()
	var bottomRay = ray.instantiate()
	
	topRay.position = objectTop
	bottomRay.position = objectBottom
	var lensAngle = imagingLens.getRotation()
	
	topRay.propDir = Vector2(cos(lensAngle+PI),sin(lensAngle+PI))
	bottomRay.propDir = Vector2(cos(lensAngle+PI),sin(lensAngle+PI))
	
	add_child(topRay)
	add_child(bottomRay)
	
func launchFocusRays():
	var objectTop = objectToImage.position + Vector2(-objectToImage.pieceSize.x/2.0,-objectToImage.pieceSize.y/2.0)
	var objectBottom = objectToImage.position +Vector2(-objectToImage.pieceSize.x/2.0,objectToImage.pieceSize.y/2.0)
	
	var topRay = ray.instantiate()
	var bottomRay = ray.instantiate()
	
	topRay.position = objectTop
	bottomRay.position = objectBottom
	var focusPts = imagingLens.getFocusPositions()
	topRay.propDir = topRay.position.direction_to(imagingLens.position+focusPts[0])
	bottomRay.propDir = bottomRay.position.direction_to(imagingLens.position+focusPts[0])
	
	add_child(topRay)
	add_child(bottomRay)
	
func launchCenterRays():
	var objectTop = objectToImage.position + Vector2(-objectToImage.pieceSize.x/2.0,-objectToImage.pieceSize.y/2.0)
	var objectBottom = objectToImage.position +Vector2(-objectToImage.pieceSize.x/2.0,objectToImage.pieceSize.y/2.0)
	
	var topRay = ray.instantiate()
	var bottomRay = ray.instantiate()
	
	topRay.position = objectTop
	bottomRay.position = objectBottom
	topRay.propDir = topRay.position.direction_to(imagingLens.position)
	bottomRay.propDir = bottomRay.position.direction_to(imagingLens.position)
	
	add_child(topRay)
	add_child(bottomRay)
	
func _on_timer_timeout():
	launchPrincipalRays()
