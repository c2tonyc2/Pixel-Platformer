tool
extends Path2D

enum ANIMATION_TYPE {
	LOOP,
	BOUNCE
}

export(ANIMATION_TYPE) var animation_type setget set_animation_type
export(int) var speed = 1 setget set_speed

onready var animationPlayer: = $AnimationPlayer

func _ready():
	play_updated_animation(animationPlayer)

func set_speed(value):
	var ap = find_node("AnimationPlayer")
	if ap: ap.playback_speed = value

func set_animation_type(value):
	animation_type = value
	var ap =  find_node("AnimationPlayer")
	if ap: play_updated_animation(ap)

func play_updated_animation(ap):
	match animation_type:
		ANIMATION_TYPE.LOOP: ap.play("MoveAlongPathLoop")
		ANIMATION_TYPE.BOUNCE: ap.play("MoveAlongPathBounce")
