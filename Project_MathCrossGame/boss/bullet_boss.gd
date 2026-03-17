extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var player: Node2D = get_tree().get_first_node_in_group("player")

var acceleration: Vector2 = Vector2.ZERO 
var velocity: Vector2 = Vector2.ZERO

@export var damage := 20   # ดาเมจกระสุน

func _physics_process(delta):

	if player == null:
		return

	acceleration = (player.position - position).normalized() * 700

	velocity += acceleration * delta
	rotation = velocity.angle()

	velocity = velocity.limit_length(150)

	position += velocity * delta


func _on_body_entered(body):

	if body.is_in_group("player"):

		if body.has_method("take_damage"):
			body.take_damage(damage)

	queue_free()
