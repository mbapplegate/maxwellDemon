extends Node2D

@onready var _animation_player = $MaxwellBody/AnimatedSprite2D
@onready var _activate_region = $MaxwellBody/ActivationRegion/CollisionShape2D
@onready var _player_body = $MaxwellBody
@onready var _cast = $MaxwellBody/checkCollision
@onready var _cast2 = $MaxwellBody/checkCollision2

@export var SPEED = 400.0
@export var PUSH_SPEED = 200.0
const SPRITE_SIZE = Vector2(64,64)
const ACTIVATION_SIZE = 30
const SEC_TO_IDLE = 2
const TILE_SIZE = 32

var idle = false
var idleCount = 0
var actionTaken = false
var screen_size
var itemActive = null
var tile_map
var isMoving = false

signal rotateCWSignal
signal rotateCCWSignal
signal energizeSignal
signal levelComplete

var drawSize = Vector2.ZERO
var velocity = Vector2.ZERO

var inputs = {
	"right": Vector2.RIGHT,
	"left": Vector2.LEFT,
	"up": Vector2.UP,
	"down": Vector2.DOWN
}
	
func _ready():
	self.position = self.position.snapped(Vector2.ONE * TILE_SIZE)
	#self.position += Vector2.ONE*(TILE_SIZE/2)
	screen_size = get_viewport_rect().size
	idleCount = SEC_TO_IDLE+1
	idle = true
	update_animation(Vector2.ZERO)
	drawSize.x = SPRITE_SIZE.x * self.scale.x
	drawSize.y = SPRITE_SIZE.y * self.scale.y
	_activate_region.shape.size =Vector2(ACTIVATION_SIZE,ACTIVATION_SIZE)

func _unhandled_input(event):
	if event.is_action_pressed("rotateCW"):
		actionTaken= true
		rotateCWSignal.emit()
	elif event.is_action_pressed("rotateCCW"):
		actionTaken= true
		rotateCCWSignal.emit()
	elif event.is_action_pressed("toggleEnergize"):
		energizeSignal.emit()
		actionTaken= true
	else:
		for dir in inputs.keys():
			if event.is_action_pressed(dir) and not isMoving:
				actionTaken= true
				update_animation(inputs[dir])
				move_grid(dir)
				
func move_grid(direction:String):
	
	var newPos = inputs[direction].normalized()*(TILE_SIZE) + self.global_position
	if not isMoving and not Input.is_action_pressed("pull"):
		_set_activation_region(direction)
		
	if validate_movement(newPos, inputs[direction]) and not isMoving:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CUBIC)
		if itemActive and Input.is_action_pressed("pull"):
			itemActive.pull(inputs[direction],_player_body)
		tween.tween_property(self,"global_position",newPos,0.2)
		update_animation(inputs[direction])
		isMoving = true
		await tween.finished
		isMoving = false
		
	
func validate_movement(testLoc:Vector2, direction:Vector2):
	var dirCast1 = Vector2.ZERO
	var dirCast2 = Vector2.ZERO
	if direction == Vector2.RIGHT:
		dirCast1 = (Vector2.RIGHT + Vector2.UP).normalized()
		dirCast2 = (Vector2.RIGHT + Vector2.DOWN).normalized()
	elif direction == Vector2.UP:
		dirCast1 = (Vector2.RIGHT + Vector2.UP).normalized()
		dirCast2 = (Vector2.LEFT + Vector2.UP).normalized()
	elif direction == Vector2.DOWN:
		dirCast1 = (Vector2.RIGHT + Vector2.DOWN).normalized()
		dirCast2 = (Vector2.LEFT + Vector2.DOWN).normalized()
	elif direction == Vector2.LEFT:
		dirCast1 = (Vector2.LEFT + Vector2.UP).normalized()
		dirCast2 = (Vector2.LEFT + Vector2.DOWN).normalized()
		
	_cast.position = SPRITE_SIZE/2.0 + dirCast1*TILE_SIZE
	_cast.target_position =to_local(testLoc)
	_cast2.position = SPRITE_SIZE/2.0 + dirCast2*TILE_SIZE
	_cast2.target_position = to_local(testLoc)
	#_cast.position = self.position
	_cast.force_raycast_update()
	_cast2.force_raycast_update()
	if (not _cast.is_colliding()) and (not _cast2.is_colliding()):
		return true
	else:
		if _cast.is_colliding():
			if _cast.get_collider() is pushableObject and _cast.get_collider().isPushable:
				_cast.get_collider().push(_cast.target_position)
				return _cast.get_collider().isSliding
			else:
				return false
		elif _cast2.is_colliding():
			if _cast2.get_collider() is pushableObject and _cast2.get_collider().isPushable:
				_cast2.get_collider().push(_cast2.target_position)
				return _cast2.get_collider().isSliding
			else:
				return false
			
			
func _process(_delta):
	pass
		
func _set_activation_region(dir):
	if (dir == "up"):
		_activate_region.position = Vector2(SPRITE_SIZE.x/2.0,-ACTIVATION_SIZE/2.0-1)
	elif (dir == "down"):
		_activate_region.position = Vector2(SPRITE_SIZE.x/2.0,SPRITE_SIZE.y+ACTIVATION_SIZE/2.0+1)
	elif (dir == "right"):
		_activate_region.position = Vector2(SPRITE_SIZE.x+ACTIVATION_SIZE/2.0+1,SPRITE_SIZE.y/2.0)
	elif (dir == "left"):
		_activate_region.position = Vector2(-ACTIVATION_SIZE/2.0-1,SPRITE_SIZE.y/2.0)
		
func _ray_hit(_photonObj:Object, _collPoint:Vector2, _collNormal:Vector2):
	pass
	
func _physics_process(delta):
	#var motion = Vector2.ZERO
	#velocity.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	#velocity.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	if not actionTaken:
		idleCount += delta
	else:
		idleCount = 0
		idle = false
		actionTaken = false
		
	if idleCount > SEC_TO_IDLE:
		update_animation(Vector2.ZERO)
		idle = true
	elif not isMoving:
		_animation_player.stop()
	#else:
	#	update_animation(velocity)
		
	#var collider = _player_body.move_and_collide(velocity.normalized()*delta*SPEED)
	#if collider:
	#	check_pushable_collision(velocity,collider.get_collider())
	#elif itemActive and Input.is_action_pressed("pull") and velocity.length()>0.0:
		#Add tween?
	#	check_pullable_collision(velocity,itemActive)
	
func update_animation(motion:Vector2):
	var animation = _animation_player.animation
	if not Input.is_action_pressed("pull"):
		if motion.x > 0:
			_set_activation_region("right")
			animation = "WalkRight"
			_animation_player.flip_h = false
		elif motion.x < 0:
			_set_activation_region("left")
			animation = "WalkRight"
			_animation_player.flip_h = true
		elif motion.y > 0:
			_set_activation_region("down")
			animation = "WalkDown"
		elif motion.y < 0:
			_set_activation_region("up")
			animation = "WalkUp"
		elif motion == Vector2.ZERO and idle:
			animation = "Idle"
			#_set_activation_region("down")
#		else:
#			_animation_player.stop()
	#else:
		#if motion.x > 0:
			#_set_activation_region("left")
			#animation = "WalkRight"
			#_animation_player.flip_h = true
		#elif motion.x < 0:
			#_set_activation_region("right")
			#animation = "WalkRight"
			#_animation_player.flip_h = false
		#elif motion.y > 0:
			#_set_activation_region("up")
			#animation = "WalkUp"
		#elif motion.y < 0:
			#_set_activation_region("down")
			#animation = "WalkDown"
		#elif motion == Vector2.ZERO and idle:
			#animation = "Idle"
			#_set_activation_region("down")
#		else:
#			_animation_player.stop()
				
	#if _animation_player.animation != animation:
	_animation_player.play(animation)
		
#func check_pushable_collision(motion:Vector2, collider:Object):
	#if abs(motion.x) + abs(motion.y) > 1.0:
		#return
	#var pushable = collider as pushableObject
	#if pushable:
		#pushable.push(motion.normalized())
		#
#func check_pullable_collision(motion:Vector2, collider:Object):
	#if abs(motion.x) + abs(motion.y) > 1.0:
		#return
	#var pushable = collider as pushableObject
	#if pushable:
		#pushable.pull(motion.normalized())
	
func _on_activation_region_body_entered(body):
	var obj = body as pushableObject
	if obj:
		if not obj.isActive:
			obj.isActive = true
			itemActive = obj
			connect("rotateCCWSignal",obj.rotateCCW)
			connect("rotateCWSignal",obj.rotateCW)
			connect("energizeSignal",obj.togEnergize)
			obj.update_texture()


func _on_activation_region_body_exited(body):
	var obj = body as pushableObject
	if obj:
		if obj.isActive:
			itemActive = null
			obj.isActive = false
			if rotateCCWSignal.is_connected(obj.rotateCCW):
				rotateCCWSignal.disconnect(obj.rotateCCW)
			if rotateCWSignal.is_connected(obj.rotateCW):
				rotateCWSignal.disconnect(obj.rotateCW)
			if energizeSignal.is_connected(obj.togEnergize):
				energizeSignal.disconnect(obj.togEnergize)
			obj.update_texture()
