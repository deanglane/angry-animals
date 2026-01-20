extends StaticBody2D

class_name Cup

static var _num_cups: int = 0 # will be used to keep track of the numbger of cups

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_num_cups += 1 # when the script loads it 
	#print("_num_cups: ",_num_cups)

# function to play the vanish animation for the cup (could be called something better)
func die() -> void:
	animation_player.play("WoodSprites") # Play animation / when player enters cup

# Signal method for when the animation stops playing
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	_num_cups -= 1
	SignalHub.emit_on_cup_destroyed(_num_cups) # Emit the signal when the cup is destroyed
	queue_free() # Remove the cup when the animation finishes
	print("Point Scored")
