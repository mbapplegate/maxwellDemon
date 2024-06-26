extends pushableObject

@export var total_height = 120
@export var aperture_width = 24
@export var thickness = 8
const collThickness = 2

@onready var topShape = $Stage/TopPart/TopPartShape
@onready var topTex = $Stage/TopPart/TopPartSprite
@onready var botShape = $Stage/BotPart/BotPartShape
@onready var botTex = $Stage/BotPart/BotPartSprite

func _ready():
	isEnergizeable = false
	var shapeHt = (total_height - aperture_width) / 2.0
	var shapeOffset = (shapeHt + aperture_width) / 2.0
	
	topShape.position = Vector2(0,shapeOffset)
	topShape.shape.size = Vector2(collThickness,shapeHt)
	
	botShape.position = Vector2(0,-shapeOffset)
	botShape.shape.size = Vector2(collThickness,shapeHt)
	topTex.position = topShape.position
	topTex.region_rect = Rect2(topShape.position.x, topShape.position.y,thickness, shapeHt)
	
	botTex.position = botShape.position
	botTex.region_rect = Rect2(botShape.position.x,botShape.position.y,thickness, shapeHt)
	
func _ray_hit(photonObj:Object, _collPoint:Vector2, _collNormal:Vector2, _collider:Object):
	photonObj.rayDying = true
