extends CharacterBody3D
@export var patrol_destinations: Array[Node3D]
@onready var nav_agent = $NavigationAgent3D
var speed = 3.0

func _ready() -> void:
	print("========= GHOST SCRIPT STARTED =========")
	print("Ghost position: ", global_position)
	print("Destinations count: ", patrol_destinations.size())
	
	# Move ghost to nav mesh level
	global_position.y = 2.1
	print("Moved ghost to Y = 2.1")
	
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 3.0
	
	call_deferred("actor_setup")

func actor_setup():
	await get_tree().physics_frame
	if patrol_destinations.size() > 0:
		nav_agent.target_position = patrol_destinations[0].global_position
		print("Set target to first destination: ", patrol_destinations[0].global_position)
	else:
		print("ERROR: No destinations!")

func _physics_process(delta: float) -> void:
	print("Physics frame running - Position: ", global_position)
	
	var next_location = nav_agent.get_next_path_position()
	var direction = (next_location - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()
