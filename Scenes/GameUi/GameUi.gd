extends Control

@onready var attempt_label: Label = $MarginContainer/VBoxContainer/AttemptLabel
@onready var music: AudioStreamPlayer = $Music
@onready var v_box_gam_over: VBoxContainer = $MarginContainer/VBoxGamOver
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
#@onready var best_label: Label = $MarginContainer/VBoxContainer/BestLabel

var _attempts: int = -1 # negative 1 mean we are not using the defualt text label. the game wil atumatically set to 0 when started

func _enter_tree() -> void:
	SignalHub.on_attempt_made.connect(on_attempt_made) # connect the attempts made signal and evoke method
	SignalHub.on_cup_destroyed.connect(on_cup_destroyed)

func _ready() -> void:
	level_label.text = "Level %s" % ScoreManager.level_selected
	#best_label.text = "Best Attempt %s" % str(ScoreManager.get_level_best(ScoreManager.level_selected))
	on_attempt_made() # evokes the attempts method to adjust the score to ZERO when the game starts
	

func _exit_tree() -> void:
	if SignalHub.on_attempt_made.is_connected(on_attempt_made):
		SignalHub.on_attempt_made.disconnect(on_attempt_made)

	if SignalHub.on_cup_destroyed.is_connected(on_cup_destroyed):
		SignalHub.on_cup_destroyed.disconnect(on_cup_destroyed)
		

# handles incrementing the attempts variable by 1 and updating the GameUi attempts label
func on_attempt_made() -> void:
	_attempts += 1 # increments each attempt by 1 
	attempt_label.text =  "Attempts %s" % _attempts # updates the label when an attempt has been made

# Handles displaying the game over label and plays the gameover music when all the cups are destroyed
func on_cup_destroyed(remaining_cups: int) -> void: 
	if remaining_cups == 0:
		music.play() # Play the music
		v_box_gam_over.show() # show the Gameover labels
		ScoreManager.set_score_for_level(
			ScoreManager.level_selected,
			_attempts
		)
	
