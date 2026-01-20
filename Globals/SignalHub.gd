extends Node

signal on_animal_died
signal on_attempt_made # tracking attempts made
signal on_cup_destroyed(remaining_cups: int) # Tracking when cups are destroyed w/ parameter

func emit_on_animal_died() -> void:
	on_animal_died.emit()
	
# func to handle emitting signal for an attempt made
func emit_on_attempt_made() -> void:
	on_attempt_made.emit()
	
# Handles emitting the cups destroyed signal with a parameter _num_cups
func emit_on_cup_destroyed(remaining_cups: int) -> void:
	on_cup_destroyed.emit(remaining_cups)
