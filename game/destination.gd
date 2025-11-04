extends Node3D
@onready var rng = RandomNumberGenerator.new()

func enter_trigger(body) :
	if body.name == "ghost":
		var agent: NavigationAgent3D = body.get_node("NavigationAgent3D")
		if agent and agent.is_navigation_finished():
			await get_tree().create_timer(rng.randf_range(1.0, 5.0), false).timeout
			body.pick_destination(body.destination_value)
			print("DV: ", body.destination_value)
