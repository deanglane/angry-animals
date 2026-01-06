extends RigidBody2D

class_name Animal

# enum constanats States
enum AnimalState { Ready, Drag, Release }

const DRAG_LIM_MAX: Vector2 = Vector2(0, 60) # Bottom right
const DRAG_LIM_MIN: Vector2 = Vector2(-60, 0)
const IMPLUSE_MULTI: float = 20.0 # multiplier for the  fire impulse (needs better comment)
const IMPLUSE_MAX: float = 1200.00 # max value for the impulse (needs better comment)


@onready var arrow: Sprite2D = $Arrow
@onready var debug_label: Label = $DebugLabel
@onready var stretch_sound: AudioStreamPlayer2D = $StretchSound
@onready var launch_sound: AudioStreamPlayer2D = $LaunchSound
@onready var kick_sound: AudioStreamPlayer2D = $KickSound

var _state: AnimalState = AnimalState.Ready # State 
var _start: Vector2 = Vector2.ZERO # start posistion
var _drag_start: Vector2 = Vector2.ZERO # Drag from start position
var _dragged_vector: Vector2 = Vector2.ZERO #
var _arrorw_scale_x: float = 0.0 # scale from the start of the arrow

func _unhandled_input(event: InputEvent) -> void:
	if _state == AnimalState.Drag and event.is_action_released("drag"):
		call_deferred("change_state", AnimalState.Release) # defers the call up to the end of the current frame

# Called when the node enters the scene tree for the first time.
# Get the game setup and ready to play
func _ready() -> void:
	setup()

func setup() -> void:
	_arrorw_scale_x = arrow.scale.x # Stores the scale.x of the arrow for strecthing later
	print("_arrorw_scale_x ",_arrorw_scale_x)
	arrow.hide() # hides the arrow sprte when the game starts
	_start = position # stores the initial position of the animal sprite
	print("_start (initial starting point) ",_start)


func _physics_process(_delta: float) -> void:
	update_state()
	update_debug_label()

# MISCELLANEOUS FUNCTIONS
#region misc

func update_debug_label() -> void:
	var ds: String = "ST:%s SL:%s FR:%s\n" % [
		AnimalState.keys()[_state], sleeping, freeze
	]
	ds += "_drag_start %.1f, %.1f\n" % [_drag_start.x, _drag_start.y]
	ds += "_dragged_vector %.1f, %.1f" % [_dragged_vector.x, _dragged_vector.y]
	debug_label.text = ds

func die() -> void:
	SignalHub.emit_on_animal_died()
	queue_free()
	
#endregion


# DRAGGING FUNCTIONS
#region drag

# Handles the linear interpolation of the dragging and scalling effect of the arrow
func update_arrow_scale() -> void:
	var imp_len: float = calculate_impulse().length() # stores the length of the vector
	#print("imp_len ",imp_len)
	var perc: float = clamp(imp_len / IMPLUSE_MAX, 0.0, 1.0) # creates a percentage value which is the length / max impulse (1200)
	#print("perc ",perc)
	arrow.scale.x = lerp(_arrorw_scale_x, _arrorw_scale_x * 2, perc) # Changes the scale of on the x axis using lerp which sets a value between the 2 _arrorw_scale_x(0.3) & (0.6) values based on the percentage.
	#print("arrow.scale.x ",arrow.scale.x)
	arrow.rotation = (_start - position).angle()
	#print("arrow.rotation ",_start - position)

# This will show the arrow sprite and set the gloabl mouse position to the _drag_start varibale.
func start_dragging() -> void:
	arrow.show() # Shows / unhides the arrow sprite when the mouse click is detected and the current state is set to Ready
	_drag_start = get_global_mouse_position() # stores the gloabal mouse position to to _drag_start

func handle_dragging() -> void:
	var new_drag_vector: Vector2 = get_global_mouse_position() - _drag_start # amount we have just dragged. Drag_start is the original mouse position.
	#print("Global mouse pos ", get_global_mouse_position())
	#print("_drag_start ",_drag_start )
	#print("new_drag_vector ",new_drag_vector)
	
	# Clamping the new drag position vector to min and max values. Even though you can drag the mouse beyond this bounding box
	# you can not go past -60,60
	new_drag_vector = new_drag_vector.clamp(
		DRAG_LIM_MIN, DRAG_LIM_MAX
	)
	#print("new_drag_vector CLAMP ",new_drag_vector)
	
	var diff: Vector2 = new_drag_vector - _dragged_vector # this returns (0,0) since the new_drag_vector - _dragged_vector will be the same.
	#print("diff ", diff) # this seems to always be (0,0)
	#print("_dragged_vector ",_dragged_vector)
	#print("diff length ", diff.length())
	# for a split second the diff.length is higher that 0 so the sound can play
	if diff.length() > 0 and stretch_sound.playing == false:
		stretch_sound.play() # plays the sound of stretching when the length is higher than 0
		
	_dragged_vector = new_drag_vector
	#print("_dragged_vector ",_dragged_vector)
	
	#print("START", _start) # original click global position
	position = _start + _dragged_vector # update the animal's position every frame so it looks like it is moving with the mouse cursor
	#print("position ",position)
	
	update_arrow_scale() # evokes the stretching and scalling of the arrow

#endregion

#region release

# function to calculate the impulse force
func calculate_impulse() -> Vector2:
	return _dragged_vector * -IMPLUSE_MULTI

# what to do when the click has been released.
func start_release() -> void:
	arrow.hide() # hides the srrow upon release of the mouse click
	launch_sound.play() # plays the launch sound fx 
	freeze = false # unfreezes the ridgidBody2d sprite
	apply_central_impulse(calculate_impulse())

#endregion

# STATE CHANGES
#region state

func update_state() -> void:
	match _state:
		AnimalState.Drag: # if the currect state is Drag the evoke this functions
			handle_dragging()

func change_state(new_state: AnimalState) -> void:
	if _state == new_state: # checks to see if we are in the smae state then dont do anything. We dont want to accidentally change into the same state again.
		return
	
	# Changes the current state to the new_state. Allows us to do other other things in different states
	_state = new_state # Our current state is changed to the new_state "Drag" passed in when we evoked the function
	
	# match statement (Switch) is another way to switch states (Handling multiple possibilities). It avoids deep if nesting
	# This switch statement evokes methods if the current state matches any of these conditions
	match _state:
		AnimalState.Drag: # if the currect state is Drag the evoke this functions
			start_dragging() # function to evoke that starts the dragging. This will show the arrow sprite and set the gloabl mouse position to the _drag_start varibale.
		AnimalState.Release: # 
			start_release()
#endregion

# ALL SIGNAL FUNCTIONS
#region signals
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Check to see if the mouse buttong has been clicked and the currect state is set to Ready.
	if event.is_action_pressed("drag") and _state == AnimalState.Ready:
		change_state(AnimalState.Drag) # Changes the currect state to Drag. We pass the state Drag to the function


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	print("Animal is off screen")
	die()


func _on_sleeping_state_changed() -> void:
	pass # Replace with function body.


func _on_body_entered(_body: Node) -> void:
	pass # Replace with function body.

#endregion
