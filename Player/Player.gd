extends KinematicBody2D
class_name Player

enum{
	MOVE,
	CLIMB,
	WALL_CLIMB,
}

export(Resource) var moveData = preload("res://Player/FastPlayerMovementData.tres") as PlayerMovementData

var velocity = Vector2.ZERO
var state = MOVE
var gravity_factor = 1
var fast_falling = false
var double_jump = 1
var buffered_jump = false
var coyote_jump = false

onready var animatedSprite := $AnimatedSprite
onready var ladderCheck := $LadderCheck
onready var wallCheck := $WallCheck
onready var jumpBufferTimer := $JumpBufferTimer
onready var coyoteJumpTimer := $CoyoteJumpTimer
onready var remoteTransform2d = $RemoteTransform2D

# Called when the node enters the scene tree for the first time.
func _ready():
	animatedSprite.frames = load("res://Player/PlayerGreenSkin.tres")

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	match state:
		MOVE: move_state(input, delta)
		CLIMB: climb_state(input)
		WALL_CLIMB: wall_climb_state(input)
	
func move_state(input, delta):
	if is_on_ladder() and Input.is_action_just_pressed("ui_up"):
		state = CLIMB
	
	if is_climbing_wall() and horizontal_move(input):
		state = WALL_CLIMB
	
	apply_gravity(delta)
	if Input.is_action_just_pressed("gravity_flip"):
		gravity_factor *= -1
		scale.y = gravity_factor
	if not horizontal_move(input):
		apply_friction(delta)
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x, delta)
		animatedSprite.animation = "Run"
		orient_character(input.x > 0)
	
	if is_on_floor():
		reset_double_jump()
	else:
		animatedSprite.animation = "Jump"

	if can_jump():
		input_jump()
	else:
		jump_released()
		double_jump()
		buffer_jump()
		fast_fall(delta)

	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP * gravity_factor)
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		coyoteJumpTimer.start()
	
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
	velocity = input * moveData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)

func wall_climb_state(input):
	if not is_climbing_wall():
		state = MOVE
	
	if Input.is_action_just_pressed("ui_up"):
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE * gravity_factor
		velocity.x = -sign(wallCheck.cast_to.x) * moveData.MAX_SPEED * 3
		orient_character(sign(wallCheck.cast_to.x) < 0)

func player_die():
	SoundPlayer.play_sound(SoundPlayer.OOF)
	queue_free()
	Events.emit_signal("player_died")

func connect_camera(camera):
	var camera_path = camera.get_path()
	remoteTransform2d.remote_path = camera_path

func orient_character(facing_right):
	if facing_right:
		animatedSprite.flip_h = true
		wallCheck.cast_to.x = abs(wallCheck.cast_to.x)
	else:
		animatedSprite.flip_h = false
		wallCheck.cast_to.x = -abs(wallCheck.cast_to.x)

func is_climbing_wall():
	return wallCheck.is_colliding() and not is_on_floor()

func is_on_ladder():
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true

func apply_gravity(delta):
	velocity.y += moveData.GRAVITY * gravity_factor * delta
	if gravity_factor > 0:
		velocity.y = min(velocity.y, moveData.MAX_FALL_SPEED * gravity_factor)
	else:
		velocity.y = max(velocity.y, moveData.MAX_FALL_SPEED * gravity_factor)

func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION * delta)

func apply_acceleration(amount, delta):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION * delta)

func input_jump():
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		fast_falling = false
		buffered_jump = false
		velocity.y = moveData.JUMP_FORCE * gravity_factor

func reset_double_jump():
	double_jump = moveData.ADDITIONAL_JUMP_COUNT 

func can_jump():
	return is_on_floor() or coyote_jump

func horizontal_move(input):
	return input.x != 0

func jump_released():
	if not fast_falling and Input.is_action_just_released("ui_up") and abs(velocity.y) > abs(moveData.SHORT_JUMP_FORCE * gravity_factor):
		velocity.y = moveData.SHORT_JUMP_FORCE * gravity_factor
		fast_falling = true

func double_jump():
	if Input.is_action_just_pressed("ui_up") and double_jump > 0:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE
		double_jump -= 1

func buffer_jump():
	if Input.is_action_just_pressed("ui_up"):
		buffered_jump = true
		jumpBufferTimer.start()

func fast_fall(delta):
	if velocity.y != 0:
		velocity.y += moveData.FAST_FALL_GRAVITY * gravity_factor * delta


func _on_JumpBufferTimer_timeout():
	buffered_jump = false


func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false # Replace with function body.
