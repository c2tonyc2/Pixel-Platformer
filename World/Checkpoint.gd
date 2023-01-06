extends Area2D

onready var animatedSprite := $AnimatedSprite


func _on_Area2D_body_entered(body):
	if not body is Player: return
	animatedSprite.play("Checked")
	Events.emit_signal("hit_checkpoint", position)
