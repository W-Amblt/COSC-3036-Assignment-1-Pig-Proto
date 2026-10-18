extends Area2D


@export var speed: float = 800.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
 # Move forward along the bullet's rotation axis
	global_position += Vector2(1, 0).rotated(rotation) * speed * delta

	


func _on_distance_timeout_timeout() -> void:
	queue_free()



func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if is_instance_valid(body) and body.name != "Wall":
		EventBus.enemy_killed.emit(100)
		body.queue_free()
		queue_free()
		
		
