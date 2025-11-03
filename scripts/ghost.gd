extends CharacterBody3D

# exported patrol points (assign these on the *Level* scene instance)
@export var patrol_destinations: Array[Node3D] = [$"../destination3", $"../destination4", $"../destination5"]

# child NavigationAgent3D must exist under this node
@onready var agent: NavigationAgent3D = $NavigationAgent3D

# try to find player (may be null if not present at ready)
@onready var player: Node3D = get_tree().current_scene.get_node_or_null("player")

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var speed: float = 3.0
var gravity: float = 9.8
var steer_accel: float = 10.0    # higher = snappier steering
var arrival_distance: float = 1.2

var destination: Node3D = null
var current_index: int = -1
var chasing: bool = false

# smoothing previous next pos to avoid oscillation
var _prev_next_pos: Vector3 = Vector3.ZERO
const NEXT_POS_SMOOTH := 0.45
const FALLBACK_DIST := 0.12

func _ready() -> void:
	rng.randomize()

	# agent tuning (adjust if needed)
	agent.path_desired_distance = 0.3
	agent.target_desired_distance = 0.8
	agent.path_height_offset = 0.0
	agent.avoidance_enabled = false  # disable while debugging

	if patrol_destinations.is_empty():
		push_error("⚠ No patrol_destinations assigned! (Assign them on the Level scene instance.)")
		return

	_pick_new_destination()

func _physics_process(delta: float) -> void:
	# nothing to do if no destination assigned
	if destination == null:
		return

	# optionally chase player
	if chasing and player != null:
		agent.set_target_position(player.global_transform.origin)
	else:
		agent.set_target_position(destination.global_transform.origin)

	# gravity (keep Y)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# check if we've reached the destination
	if agent.is_navigation_finished() or global_position.distance_to(destination.global_transform.origin) < arrival_distance:
		_pick_new_destination(current_index)
		return

	# get next path point from agent and keep it planar
	var raw_next: Vector3 = agent.get_next_path_position()
	raw_next.y = global_position.y

	# smooth next positions to avoid oscillation
	if _prev_next_pos != Vector3.ZERO:
		if _prev_next_pos.distance_to(raw_next) > 0.4:
			raw_next = (_prev_next_pos + raw_next) * 0.5
		else:
			raw_next = _prev_next_pos.lerp(raw_next, NEXT_POS_SMOOTH)
	_prev_next_pos = raw_next

	# compute planar direction
	var dir: Vector3 = raw_next - global_position
	dir.y = 0.0

	# fallback: if next node is too close or zero, aim directly at final destination
	if dir.length() < FALLBACK_DIST:
		var fallback: Vector3 = destination.global_transform.origin - global_position
		fallback.y = 0.0
		if fallback.length() > 0.05:
			dir = fallback.normalized()
		else:
			velocity.x = 0.0
			velocity.z = 0.0
			move_and_slide()
			return
	else:
		dir = dir.normalized()

	# desired planar velocity and smooth steering (Vector2 for x/z)
	var desired_vel: Vector2 = Vector2(dir.x * speed, dir.z * speed)
	var cur_vel: Vector2 = Vector2(velocity.x, velocity.z)
	var t: float = clamp(steer_accel * delta, 0.0, 1.0)

	# explicit typed new_vel to avoid inference errors
	var new_vel: Vector2 = cur_vel + (desired_vel - cur_vel) * t

	velocity.x = new_vel.x
	velocity.z = new_vel.y

	# apply physics movement (do NOT assign return)
	move_and_slide()

	# smooth rotation toward movement direction
	if Vector2(velocity.x, velocity.z).length() > 0.05:
		var look_dir: float = atan2(-velocity.x, -velocity.z)
		rotation.y = lerp_angle(rotation.y, look_dir, 0.12)

func _pick_new_destination(dont_choose: int = -1) -> void:
	if patrol_destinations.is_empty():
		return

	var new_index: int = rng.randi_range(0, patrol_destinations.size() - 1)

	# avoid picking same index twice in a row
	if dont_choose >= 0 and new_index == dont_choose and patrol_destinations.size() > 1:
		new_index = (new_index + 1) % patrol_destinations.size()

	current_index = new_index
	destination = patrol_destinations[current_index]

	# update agent target
	agent.set_target_position(destination.global_transform.origin)
	print("👻 Moving to point #", current_index, " at ", destination.global_transform.origin)

# optional helper to toggle chasing
func set_chasing(value: bool) -> void:
	chasing = value
	if chasing and player != null:
		print("Ghost: now chasing player")
	elif not chasing:
		_pick_new_destination(current_index)
