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
	
	if destination != null and not agent.is_navigation_finished():
		var current_location = global_position
		var next_location = agent.get_next_path_position()
		
		# Check if very close to the next point
		var distance_to_next = current_location.distance_to(next_location)
		
		if distance_to_next < 0.2:
			# If close, snap directly to avoid getting stuck
			global_position = next_location
		else:
			# Calculate full 3D direction INCLUDING vertical (Y) component
			var direction = (next_location - current_location).normalized()
			
			# Boost speed when climbing to overcome friction
			var climb_multiplier = 1.3 if direction.y > 0.05 else 1.0
			var new_velocity = direction * speed * climb_multiplier
			
			# Use full velocity - no lerp to avoid getting stuck
			velocity = new_velocity
			
			move_and_slide()
			
			# Rotate to face movement direction (horizontal only)
			var horizontal_dir = Vector3(direction.x, 0, direction.z)
			if horizontal_dir.length() > 0.01:
				var look_dir = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), 0.1)
				rotation.y = look_dir
	
	# Check if patrol destination reached
	#if !chasing and agent.is_navigation_finished():
		#pick_destination(destination_value)

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
