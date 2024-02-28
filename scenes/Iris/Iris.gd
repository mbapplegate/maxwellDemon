extends pushableObject

@export var total_height = 256
@export var aperture_width = 24
@export var thickness = 8

@onready var topShape = $Stage/TopPart/TopPartShape
@onready var topTex = $Stage/TopPart/TopPartSprite
@onready var botShape = $Stage/BotPart/BotPartShape
@onready var botTex = $Stage/BotPart/BotPartSprite

func _ready():
	isEnergizeable = false
	var shapeHt = (total_height - aperture_width) / 2.0
	var shapeOffset = (shapeHt + aperture_width) / 2.0
	
	topShape.position = Vector2(0,shapeOffset)
	topShape.shape.size = Vector2(thickness,shapeHt)
	
	botShape.position = Vector2(0,-shapeOffset)
	botShape.shape.size = Vector2(thickness,shapeHt)
	topTex.position = topShape.position
	topTex.region_rect = Rect2(topShape.position,topShape.shape.size)
	
	botTex.position = botShape.position
	botTex.region_rect = Rect2(botShape.position,botShape.shape.size)
	
func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true
