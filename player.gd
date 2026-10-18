extends CharacterBody2D
signal hit
@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
@export var is_alive: bool = true
@export var can_shoot: bool = false
var player_lives = 3

const bullet_scene = preload("res://bullet.tscn")

@onready var ShootPos: Marker2D = $/root/Main/Player/shoot_pos

var time_between_shot: float = 0.25


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	can_shoot = false
	screen_size = get_viewport_rect().size
	hide()

func start(pos):
	if player_lives <= 0:
		player_lives = 3
	position = pos
	show()
	$"Wall Collision".disabled = false
	is_alive = true
	can_shoot = true
	$Hitbox/CollisionShape2D.set_deferred("disabled", false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	rotate(get_angle_to(get_global_mouse_position()))
	
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right") and is_alive:
		velocity.x += 1
	if Input.is_action_pressed("move_left") and is_alive:
		velocity.x -= 1
	if Input.is_action_pressed("move_down") and is_alive:
		velocity.y += 1
	if Input.is_action_pressed("move_up") and is_alive:
		velocity.y -= 1
	if Input.is_action_pressed("shoot") and can_shoot and is_alive:
		shoot()
		can_shoot = false
		$ShootTimer.start()
	
	move_and_slide()

	#Adapted from AI conversation
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

#adapted from AI conversation
func shoot() -> void:
	var new_bullet = bullet_scene.instantiate()
	new_bullet.global_position = ShootPos.global_position
	new_bullet.global_rotation = ShootPos.global_rotation
	get_parent().add_child(new_bullet)
	$Shoot.play()
	

func get_lives():
	return player_lives


func _on_body_entered(body: Node2D) -> void:
	is_alive = false
	hide() # Player disappears after being hit.
	player_lives -= 1
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	



func _on_shoot_timer_timeout() -> void:
	can_shoot = true
