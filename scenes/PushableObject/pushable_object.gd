extends CharacterBody2D
class_name pushableObject

const OBJECT_SIZE : int = 128
const TILE_SIZE : int = 32
const NUDGE_DISTANCE : int = 2
const ROTATION_INCREMENT = deg_to_rad(15)

@export var sliding_time = 0.2
@export var initialAngle = 0.0
@export var isPushable = true
@export var isRotatable = true
@export var isEnergizeable = true
@export var isEnergized = false

@onready var sprite = $Stage
@onready var bg = $Background
@onready var indicator = $Indicator

signal energizeChanged(val)
signal rotationChanged()
signal stageMoved()

var isActive = false

var isSliding : bool = false
# Called when the node enters the scene tree for the first time.
func initialize():
	#print(position.snapped(Vector2(TILE_SIZE,TILE_SIZE)))
	self.global_position = global_position.snapped(Vector2(TILE_SIZE,TILE_SIZE))
	if isRotatable and initialAngle != 0.0:
		sprite.rotation = deg_to_rad(initialAngle)
	#print("Initializing: ",self,", energ?: ", isEnergizeable)
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
		stageMoved.emit()
		isSliding = false
		return true
	else:
		return false
		
func pull(direction:Vector2,player:Object):
	if isSliding or not isPushable:
		return false
	if player:
		self.add_collision_exception_with(player)	
	
	var globalTargetLoc = global_position + direction.normalized()*TILE_SIZE
	#print("Pulling: ",direction, ", ", to_local(globalTargetLoc),", ",can_move(to_local(globalTargetLoc)))
	if can_move(to_local(globalTargetLoc)):
		var tween = get_tree().create_tween()
		
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self,"global_position",globalTargetLoc,sliding_time)
		isSliding = true
		await tween.finished
		stageMoved.emit()
		isSliding = false
		if player:
			self.remove_collision_exception_with(player)
		return true
	else:
		if player:
			self.remove_collision_exception_with(player)
		return false

func nudgePull(direction:Vector2,player:Object):
	if isSliding or not isPushable:
		return false
	if player:
		self.add_collision_exception_with(player)	
	
	var globalTargetLoc = global_position + direction.normalized()*NUDGE_DISTANCE
	#print("Pulling: ",direction, ", ", to_local(globalTargetLoc),", ",can_move(to_local(globalTargetLoc)))
	if can_move(to_local(globalTargetLoc)):
		var tween = get_tree().create_tween()
		
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self,"global_position",globalTargetLoc,sliding_time)
		isSliding = true
		await tween.finished
		stageMoved.emit()
		isSliding = false
		if player:
			self.remove_collision_exception_with(player)
		return true
	else:
		if player:
			self.remove_collision_exception_with(player)
		return false
		
func can_move(localDestination:Vector2):
	var collInfo =  move_and_collide(localDestination, true)
	if collInfo:
		return false
	else:
		return true
	#return not test_move(future_transform,Vector2.ZERO)
# Called every frame. 'delta' is the elapsed time since the previous frame.
	
func update_texture():
	if isActive and (isPushable or isRotatable or isEnergizeable):
		bg.texture = load("res://tiles/pushable/pushableBase_BACKGROUND_ACTIVE.png")
	elif isPushable:
		bg.texture = load("res://tiles/pushable/pushableBase_BACKGROUND_NORMAL.png")
	else:
		bg.texture = load("res://tiles/pushable/pushableBase_BACKGROUND_STATIC.png")
	
	if isRotatable:
		sprite.texture = load("res://tiles/pushable/circularRotationBase_whiteOutline.png")
	else:
		sprite.texture = load("res://tiles/pushable/squareBase_whiteOutline.png")
	
	if not isPushable:
		$fixation.texture = load("res://tiles/pushable/fixation_HEX.png")
	else:
		$fixation.texture = null
	if isEnergizeable:
		if isEnergized:
			indicator.texture = load("res://tiles/pushable/onButton.png")
		else:
			indicator.texture = load("res://tiles/pushable/offButton.png")
	else:
		indicator.texture = null

func snapToGrid() -> bool:
	if isPushable:
		self.global_position = global_position.snapped(Vector2(TILE_SIZE,TILE_SIZE))
		return true
	else:
		return false
	
func rotateCW(numDegrees : float):
	if isRotatable:
		sprite.rotation += numDegrees
		rotationChanged.emit()
	
func rotateCCW(numDegrees : float):
	if isRotatable:
		sprite.rotation -= numDegrees
		rotationChanged.emit()

func getRotation():
	if isRotatable:
		return sprite.rotation	
	else:
		return deg_to_rad(initialAngle)
		
func togEnergize():
	if isEnergizeable:
		if isEnergized:
			isEnergized = false
			update_texture()
		else:
			isEnergized = true
			update_texture()
		energizeChanged.emit(isEnergized)
