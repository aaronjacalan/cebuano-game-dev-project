extends CharacterBody3D
@export var patrol_destinations: Array[Node3D]
@onready var nav_agent = $NavigationAgent3D
var speed = 3.0
var gravity = 9.8
@onready var rng = RandomNumberGenerator.new()
var destination
var chasing = false
var destination_value
var is_ready_to_move = false
var debug_timer = 0.0

func _ready() -> void:
	# Configure NavigationAgent3D
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 3.0
	
	# Wait for navigation map to sync
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame
	pick_destination()
	is_ready_to_move = true

func _physics_process(delta: float) -> void:
	if not is_ready_to_move or destination == null:
		return
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0
	
	# Debug every 2 seconds
	debug_timer += delta
	if debug_timer >= 2.0:
		var distance_to_dest = global_position.distance_to(destination.global_position)
		var current_location = global_position
		var next_location = nav_agent.get_next_path_position()
		print("Distance to dest: ", snappedf(distance_to_dest, 0.01))
		print("Current: ", current_location)
		print("Next path: ", next_location)
		print("Same position? ", current_location.distance_to(next_location) < 0.1)
		print("Is target reachable? ", nav_agent.is_target_reachable())
		print("---")
		debug_timer = 0.0
	
	# Check if we're close enough to the destination
	var distance_to_dest = global_position.distance_to(destination.global_position)
	
	if distance_to_dest < 3.0:
		print(">>> REACHED! Picking new destination...")
		pick_destination(destination_value)
		return
	
	# Move toward destination
	var current_location = global_position
	var next_location = nav_agent.get_next_path_position()
	
	# Check if we have a valid path
	if current_location.distance_to(next_location) < 0.1:
		print("WARNING: No valid path to destination!")
		return
	
	var new_velocity = (next_location - current_location).normalized() * speed
	
	# Only update X and Z, keep Y for gravity
	velocity.x = new_velocity.x
	velocity.z = new_velocity.z
	
	move_and_slide()
	
	# Look in movement direction
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	if horizontal_velocity.length() > 0.1:
		var look_dir = atan2(-velocity.x, -velocity.z)
		rotation.y = lerp_angle(rotation.y, look_dir, 0.1)

func pick_destination(dont_choose = null):
	if patrol_destinations.is_empty():
		push_error("ERROR: No patrol destinations set!")
		return
	
	var num = rng.randi_range(0, patrol_destinations.size() - 1)
	destination_value = num 
	destination = patrol_destinations[num]
	
	if destination != null and dont_choose != null and num == dont_choose:
		num = (num + 1) % patrol_destinations.size()
		destination_value = num
		destination = patrol_destinations[num]
	
	if destination != null:
		nav_agent.target_position = destination.global_position
		print("=== Moving to destination #", num, " (", destination.name, ") ===")
	else:
		push_error("Destination is null!")
