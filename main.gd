extends Node
@export var mob_scene: PackedScene
var score = 0
signal player_dead
var spawn_points = 20
var current_spawn_points = 0
var high_score = 0
var current_lvl = 1
var spawn_init = true
var velocity_multiplier
var score_multiplier

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().call_group("mobs", "queue_free")
	EventBus.enemy_killed.connect(_on_enemy_killed)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if score > high_score:
		$HUD.update_high_score(score)



func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	if $Player.get_lives() <= 0:
		$HUD.show_game_over()
		spawn_init = true
	else:
		$HUD.show_you_died()
	
	
	if score > high_score:
		high_score = score
		$HUD.update_high_score(high_score)

func clear_mobs():
	for mob in get_tree().get_nodes_in_group("mobs"):
		mob.queue_free()

func new_game():
	clear_mobs()
	
	if spawn_init:		 
		$MobTimer.wait_time = 1.0
		score = 0
		current_lvl = 1
		spawn_points = 20
		current_spawn_points = spawn_points
		velocity_multiplier = 1.0
		score_multiplier = 1
		spawn_init = false
	elif current_spawn_points <= 6:
		current_spawn_points += 5
	$HUD.update_lvl(current_lvl)
	$Player.start($StartPosition.position)
	$HUD.update_lives($Player.get_lives())
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")


func _on_mob_timer_timeout():
	if current_spawn_points > 0:
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
		var velocity = Vector2(randf_range(350.0 * velocity_multiplier, 450.0 * velocity_multiplier), 0.0)
		mob.linear_velocity = velocity.rotated(direction_angle)


		# Spawn the mob by adding it to the Main scene.
		add_child(mob)
		$PigNoises.play()
		current_spawn_points -= 1

	elif current_spawn_points <= 0 and get_tree().get_nodes_in_group("mobs").size() == 0:
		stage_clear()
		$MobTimer.stop()
		return
	
func stage_clear():
	spawn_points += 10
	current_spawn_points = spawn_points
	current_lvl += 1
	velocity_multiplier += 0.5
	score_multiplier += 1
	$MobTimer.wait_time = $MobTimer.wait_time * 0.9
	$HUD.stage_clear()
	


func _on_enemy_killed(points: int):
	score += points * score_multiplier
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
