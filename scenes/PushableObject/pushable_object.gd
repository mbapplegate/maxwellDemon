extends CharacterBody2D
class_name pushableObject

const OBJECT_SIZE = 128
const TILE_SIZE = 32
const ROTATION_INCREMENT = deg_to_rad(15)

@export var sliding_time = 0.2
@export var isPushable = true
@export var isRotatable = true
@export var isEnergizeable = true
@export var isEnergized = false

@onready var sprite = $Stage
@onready var bg = $Background
@onready var indicator = $Indicator

var isActive = false

var isSliding : bool = false
# Called when the node enters the scene tree for the first time.
func initialize():
	#print(position.snapped(Vector2(TILE_SIZE,TILE_SIZE)))
	self.position = position.snapped(Vector2(TILE_SIZE,TILE_SIZE))
	update_texture()
	
func calculate_destination(dir:Vector2):
	return self.position+dir.normalized()*TILE_SIZE
	#var tile_map_position = tile_map.local_to_map(self.position) + Vector2i(dir)
	#return tile_map.map_to_local(tile_map_position)

func push(motion:Vector2):
	if isSliding or not isPushable:
		return false
		
	if can_move(motion):
		var tween = get_tree().create_tween()
		
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self,"global_position",self.global_position+motion,sliding_time)
		isSliding = true
		await tween.finished
		isSliding = false
		return true
	else:
		return false

func can_move(localDestination:Vector2):
	if move_and_collide(localDestination, true):
		return false
	else:
		return true
	#return not test_move(future_transform,Vector2.ZERO)
# Called every frame. 'delta' is the elapsed time since the previous frame.
	
func update_texture():
	if isActive:
		bg.texture = load("res://tiles/pushable/pushableBase_BACKGROUND_ACTIVE.png")
	elif isRotatable or isPushable:
		bg.texture = load("res://tiles/pushable/pushableBase_BACKGROUND_NORMAL.png")
	else:
		bg.texture = load("res://tiles/pushable/pushableBase_BACKGROUND_STATIC.png")
	
	if isRotatable:
		sprite.texture = load("res://tiles/pushable/circularRotationBase.png")
	else:
		sprite.texture = load("res://tiles/pushable/squareBase.png")
	
	if isEnergizeable:
		if isEnergized:
			indicator.texture = load("res://tiles/pushable/onButton.png")
		else:
			indicator.texture = load("res://tiles/pushable/offButton.png")
	else:
		indicator.texture = null
	#if isEnergizeable:
		#if isRotatable:
			#if isEnergized:
				#sprite.texture = load("res://tiles/pushable/pushableBase_ON.png")
			#else:
				#sprite.texture = load("res://tiles/pushable/pushableBase_OFF.png")
		#else:
			#if isEnergized:
				#sprite.texture = load("res://tiles/pushable/squareStage_ON.png")
			#else:
				#sprite.texture = load("res://tiles/pushable/squareStage_OFF.png")			
func rotateCW():
	if isRotatable:
		sprite.rotation -= ROTATION_INCREMENT
	
func rotateCCW():
	if isRotatable:
		sprite.rotation += ROTATION_INCREMENT
		
func togEnergize():
	if isEnergizeable:
		if isEnergized:
			isEnergized = false
			update_texture()
		else:
			isEnergized = true
			update_texture()
