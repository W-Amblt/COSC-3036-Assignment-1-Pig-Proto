extends Node
@export var mob_scene: PackedScene
var score
signal player_dead
var spawn_points = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().call_group("mobs", "queue_free")
	EventBus.enemy_killed.connect(_on_enemy_killed)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func clear_mobs():
	for mob in get_tree().get_nodes_in_group("mobs"):
		mob.queue_free()

func new_game():
	clear_mobs()
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")



func _on_mob_timer_timeout():
	if spawn_points > 0:
		# Create a new instance of the Mob scene.
		var mob = mob_scene.instantiate()

		# Choose a random location on Path2D.
		var mob_spawn_location = $MobPath/MobSpawnLocation
		mob_spawn_location.progress_ratio = randf()
		
		#from here code was used from an AI solution
		var target_vector = ($Player.global_position - mob.global_position).normalized()
		var direction_angle = target_vector.angle()

		# Set the mob's position to the random location.
		mob.position = mob_spawn_location.position

		# 3. Safely add some randomness to the float angle (e.g., +/- 45 degrees)
		# deg_to_rad(45) prevents the mob from turning completely backward
		direction_angle += randf_range(deg_to_rad(-45), deg_to_rad(45))

		# 4. Assign the resulting float to the mob's rotation
		mob.rotation = direction_angle

		# Choose the velocity for the mob.
		var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
		mob.linear_velocity = velocity.rotated(direction_angle)

		# Spawn the mob by adding it to the Main scene.
		add_child(mob)
		spawn_points -= 1
	else:
		return
	

func _on_enemy_killed(points: int):
	score += points
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
