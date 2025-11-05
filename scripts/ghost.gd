extends CharacterBody3D
@onready var agent = $NavigationAgent3D
@export var patrol_destinations: Array[Node3D]
@onready var player = get_tree().get_first_node_in_group("player")
var speed = 3.0
@onready var rng = RandomNumberGenerator.new()
var destination
var chasing = false
var destination_value
var chase_timer = 0.0

func _ready() -> void:
	pick_destination()
	
func _process(delta: float) -> void:
	if chasing:
		if speed != 5.0:
			speed = 5.0
		if chase_timer < 15:
			chase_timer += 1 * delta
		else:
			chase_timer = 0.0
			chasing = false
			pick_destination()
	elif !chasing:
		if speed != 3.0:
			speed = 3.0
	
	if destination != null:
		update_target_location()
		
func _physics_process(_delta: float) -> void:
	chase_player($RayCast3D)
	chase_player($RayCast3D2)
	chase_player($RayCast3D3)
	chase_player($RayCast3D4)
	chase_player($RayCast3D5)
	
	if destination != null:
		var current_location = global_position
		var next_location = agent.get_next_path_position()
		
		# Calculate full 3D direction INCLUDING vertical (Y) component
		var direction = (next_location - current_location).normalized()
		var new_velocity = direction * speed
		
		# DON'T use move_toward for Y axis - use the full vertical component
		velocity.x = lerp(velocity.x, new_velocity.x, 0.25)
		velocity.z = lerp(velocity.z, new_velocity.z, 0.25)
		velocity.y = new_velocity.y  # Use full Y velocity for climbing
		
		move_and_slide()
		
		# Rotate to face movement direction (horizontal only)
		if direction.length() > 0.01:
			var look_dir = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), 0.1)
			rotation.y = look_dir
	
	# Check if patrol destination reached
	if !chasing and agent.is_navigation_finished():
		pick_destination(destination_value)

func chase_player(cast: RayCast3D):
	if cast.is_colliding():
		var hit = cast.get_collider()
		if hit and hit.is_in_group("player"):
			chasing = true
			destination = player

func pick_destination(dont_choose = null):
	if !chasing:
		var num = rng.randi_range(0, patrol_destinations.size() - 1)
		destination_value = num
		destination = patrol_destinations[num]
		if destination != null and dont_choose != null and destination == patrol_destinations[dont_choose]:
			if dont_choose <= 0:
				destination = patrol_destinations[dont_choose + 1]
			elif dont_choose > 0 and dont_choose <= patrol_destinations.size() - 1:
				destination = patrol_destinations[dont_choose - 1]

func update_target_location():
	agent.target_position = destination.global_position
