extends CanvasLayer
signal start_game

@onready var main_player: CharacterBody2D = $/root/Main/Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ScoreLabel.hide()
	$Score.hide()
	$LvlLabel.hide()
	$Lvl.hide()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_score(score):
	$Score.text = str(score)

func update_high_score(score):
	$HighScore.text = str(score)

func update_lvl(lvl):
	$Lvl.text = str(lvl)
	
func _on_start_button_pressed():
	$StartButton.hide()
	$ScoreLabel.show()
	$Score.show()
	$LvlLabel.show()
	$Lvl.show()
	start_game.emit()

func _on_message_timer_timeout():
	$Message.hide()
	

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_you_died():
	show_message("You Died!")
	await $MessageTimer.timeout
	
	$StartButton.text = "Try Again"
	$StartButton.show()

func stage_clear():
	show_message("Stage Clear!")

	
	$StartButton.text = "Next Stage"
	$StartButton.show()

func update_lives(lives):
	$Lives.text = str(lives)

func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Save Your Bacon!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.text = "Start"
	$StartButton.show()
	
