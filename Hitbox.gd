extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Hitbox_body_entered(body):
	if body is Player: 
		get_tree().reload_current_scene()
