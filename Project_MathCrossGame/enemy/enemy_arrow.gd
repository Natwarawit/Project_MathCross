extends Node2D

const SPEED := 120

@export var damage: int = 40

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta


func _on_hitbox_body_entered(body):
	if body.has_method("player"):
		body.health -= damage
		body.flash_red()

		print("Player โดนลูกศร! damage =", damage)

		queue_free()


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
