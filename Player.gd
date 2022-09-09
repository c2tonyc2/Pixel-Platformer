extends KinematicBody2D
class_name Player

enum{
	MOVE,
	CLIMB,
}

export(Resource) var moveData

var velocity = Vector2.ZERO
var state = MOVE
var gravity_factor = 1
var fast_falling = false

onready var animatedSprite = $AnimatedSprite
onready var ladderCheck = $LadderCheck

# Called when the node enters the scene tree for the first time.
func _ready():
	animatedSprite.frames = load("res://PlayerGreenSkin.tres")

func _physics_process(delta):
	if is_on_ladder():
		print("on ladder")

	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	match state:
		MOVE: move_state(input)
		CLIMB: climb_state(input)
	
func move_state(input):
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
		state = CLIMB
	apply_gravity()
	if Input.is_action_just_pressed("gravity_flip"):
		gravity_factor *= -1
		scale.y = gravity_factor
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
			velocity.y = moveData.JUMP_FORCE * gravity_factor
	else:
		animatedSprite.animation = "Jump"
		if not fast_falling and Input.is_action_just_released("ui_up") and abs(velocity.y) > abs(moveData.SHORT_JUMP_FORCE * gravity_factor):
			velocity.y = moveData.SHORT_JUMP_FORCE * gravity_factor
			fast_falling = true
		
		if velocity.y != 0:
			velocity.y += moveData.FAST_FALL_GRAVITY * gravity_factor

	var was_in_air = not is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP * gravity_factor)

	if is_on_floor() and was_in_air:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1

func climb_state(input):
	if not is_on_ladder():
		state = MOVE
	if input.length() != 0:
		$AnimatedSprite.animation = "Run"
	else:
		$AnimatedSprite.animation = "Idle"
	velocity = input * 50
	velocity = move_and_slide(velocity, Vector2.UP)

func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true

func apply_gravity():
	velocity.y += moveData.GRAVITY * gravity_factor
	if gravity_factor > 0:
		velocity.y = min(velocity.y, moveData.MAX_FALL_SPEED * gravity_factor)
	else:
		velocity.y = max(velocity.y, moveData.MAX_FALL_SPEED * gravity_factor)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
