extends Node2D

@onready var animal_start: Marker2D = $AnimalStart
const ANIMAL = preload("res://Scenes/Animal/Animal.tscn")

func _enter_tree() -> void:
	SignalHub.on_animal_died.connect(spawn_animal)

func _exit_tree() -> void:
	SignalHub.on_animal_died.disconnect(spawn_animal)

func _ready() -> void:
	spawn_animal()
	
func _physics_process(_delta: float) -> void:
	pass
	
func spawn_animal() -> void:
	var new_animal = ANIMAL.instantiate()
	new_animal.position = animal_start.position
	add_child(new_animal)
