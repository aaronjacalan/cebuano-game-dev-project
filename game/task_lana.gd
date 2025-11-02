extends Node3D

# Lana bottle nodes
@onready var lana_bottles: Array[Node3D] = [
	$"lana bottle1",
	$"lana bottle2",
	$"lana bottle3",
	$"lana bottle4",
	$"lana bottle5",
	$"lana bottle6",
	$"lana bottle7",
	$"lana bottle8",
	$"lana bottle9"
]

# Corresponding CollisionShape3D nodes for each bottle
@onready var lana_collisions: Array[CollisionShape3D] = [
	$"lana bottle1/lanastatic1/lanacollision1",
	$"lana bottle2/lanastatic2/lanacollision2",
	$"lana bottle3/lanastatic3/lanacollision3",
	$"lana bottle4/lanastatic4/lanacollision4",
	$"lana bottle5/lanastatic5/lanacollision5",
	$"lana bottle6/lanastatic6/lanacollision6",
	$"lana bottle7/lanastatic7/lanacollision7",
	$"lana bottle8/lanastatic8/lanacollision8",
	$"lana bottle9/lanastatic9/lanacollision9"
]

var chosen_index: int = -1  

func _ready() -> void:
	randomize()
	chosen_index = randi() % lana_bottles.size()
	_update_bottles()

# Update visibility and collisions
func _update_bottles() -> void:
	for i in range(lana_bottles.size()):
		var bottle = lana_bottles[i]
		var collision = lana_collisions[i]
		var is_active = (i == chosen_index)
		bottle.visible = is_active
		if collision:
			collision.set_deferred("disabled", not is_active)

# Take the chosen bottle
func take() -> void:
	if chosen_index == -1:
		return

	var bottle = lana_bottles[chosen_index]
	var collision = lana_collisions[chosen_index]

	bottle.visible = false
	if collision:
		collision.set_deferred("disabled", true)

	chosen_index = -1
