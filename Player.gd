extends KinematicBody2D
class_name Player

export(int) var JUMP_FORCE = -130
export(int) var SHORT_JUMP_FORCE = -70
export(int) var MAX_SPEED = 50
export(int) var MAX_FALL_SPEED = 300
export(int) var ACCELERATION = 10 
export(int) var FRICTION = 10
export(int) var GRAVITY = 4
export(int) var FAST_FALL_GRAVITY = 6

var velocity = Vector2.ZERO
var gravity_factor = 1
var fast_falling = false

onready var animatedSprite = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	animatedSprite.frames = load("res://PlayerGreenSkin.tres")
	print(bool(float(0)))
	print(Vector2.RIGHT, bool(Vector2.UP.x), bool(Vector2.RIGHT.y))
	var rotated = Vector2.RIGHT.rotated(PI/2)
	print(rotated, bool(rotated.x), bool(rotated.y))
	rotated = rotated.rotated(PI/2)
	print(rotated, bool(rotated.x), bool(rotated.y))
	rotated = rotated.rotated(PI/2)
	print(rotated, bool(rotated.x), bool(rotated.y))

func _physics_process(delta):
	if Input.is_action_just_pressed("gravity_flip"):
		gravity_factor *= -1
		scale.y = gravity_factor

	apply_gravity()
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if input.x == 0:
		apply_friction()
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = input.x > 0

	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			fast_falling = false
			velocity.y = JUMP_FORCE * gravity_factor
	else:
		animatedSprite.animation = "Jump"
		if not fast_falling and Input.is_action_just_released("ui_up") and abs(velocity.y) > abs(SHORT_JUMP_FORCE * gravity_factor):
			velocity.y = SHORT_JUMP_FORCE * gravity_factor
			fast_falling = true
		
		if velocity.y != 0:
			velocity.y += FAST_FALL_GRAVITY * gravity_factor

	var was_in_air = not is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP * gravity_factor)

	if is_on_floor() and was_in_air:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1

func apply_gravity():
	velocity.y += GRAVITY * gravity_factor
	if gravity_factor > 0:
		velocity.y = min(velocity.y, MAX_FALL_SPEED * gravity_factor)
	else:
		velocity.y = max(velocity.y, MAX_FALL_SPEED * gravity_factor)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, MAX_SPEED * amount, ACCELERATION)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
