extends Node2D

enum {HOVER, FALL, LAND, RISE}

var state = HOVER

onready var start_position = position
onready var timer := $Timer
onready var raycast := $RayCast2D
onready var animated_sprite := $AnimatedSprite
onready var particles := $Particles2D

func _physics_process(delta):
	match state:
		HOVER: hover_state()
		FALL: fall_state(delta)
		LAND: land_state()
		RISE: rise_state(delta)

func hover_state():
	state = FALL

func fall_state(delta):
	animated_sprite.play("Falling")
	position.y += 100 * delta
	if raycast.is_colliding():
		# var collision_position = raycast.get_collision_point()
		# position.y = collision_position.y\
		print(position, raycast.get_collision_point(), raycast.get_collision_normal())
		state = LAND
		timer.start(1.0)
		particles.emitting = true

func land_state():
	if timer.time_left == 0:
		state = RISE

func rise_state(delta):
	animated_sprite.play("Rising")
	position.y = move_toward(position.y, start_position.y, 20 * delta)
	if position.y == start_position.y:
		state = HOVER
