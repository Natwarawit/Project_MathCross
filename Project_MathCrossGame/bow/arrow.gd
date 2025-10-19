extends Node2D

const SPEED: int = 200
@export var damage: int = 40   # กำหนดดาเมจลูกศร

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta



func _on_hitbox_body_entered(body: Node2D) -> void:
		if body.is_in_group("enemy"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
			queue_free()

	
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
