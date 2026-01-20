extends Node2D

@onready var animal_start: Marker2D = $AnimalStart

const ANIMAL: PackedScene = preload("res://Scenes/Animal/Animal.tscn")
const MAIN: PackedScene = preload("res://Scenes/Main/Main.tscn")

# handles navigating back to the menu if the back button has been hit
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("back") == true:
		get_tree().change_scene_to_packed(MAIN) # navigates back to MAIN 

func _enter_tree() -> void:
	SignalHub.on_animal_died.connect(spawn_animal)
	
func _exit_tree() -> void:
	SignalHub.on_animal_died.disconnect(spawn_animal)

func _ready() -> void:
	spawn_animal()

	
func spawn_animal() -> void:
	var new_animal: Animal = ANIMAL.instantiate()
	new_animal.position = animal_start.position
	add_child(new_animal)
