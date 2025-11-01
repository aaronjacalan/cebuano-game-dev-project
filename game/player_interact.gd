extends RayCast3D

func _physics_process(delta: float) -> void:
	if not is_colliding():
		return

	var collider = get_collider()
	if not Input.is_action_just_pressed("interact"):
		return

	# --- DOOR INTERACTION ---
	if collider.is_in_group("door"):
		var node = collider
		while node and not node.has_method("toggle_door"):
			node = node.get_parent()
		if node and node.has_method("toggle_door"):
			node.toggle_door()
			return

	# --- BROWN CABINET DOOR 1 ---
	if collider.is_in_group("brown cabinet 1"):
		var node = collider
		while node and not node.has_method("toggle_door1"):
			node = node.get_parent()
		if node and node.has_method("toggle_door1"):
			node.toggle_door1()
			return

	# --- BROWN CABINET DOOR 2 ---
	if collider.is_in_group("brown cabinet 2"):
		var node = collider
		while node and not node.has_method("toggle_door2"):
			node = node.get_parent()
		if node and node.has_method("toggle_door2"):
			node.toggle_door2()
			return
