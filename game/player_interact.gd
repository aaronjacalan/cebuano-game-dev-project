extends RayCast3D

@onready var interaction_label: Label = $"../Filters/Interaction_Label"

# Map groups to the method to call and the key to display
var group_interactions := {
	"interactable": {"method": "interact", "key": "E"},
	"equipable": {"method": "take", "key": "F"}
}

func _physics_process(delta: float) -> void:
	var collider = get_collider()

	if not collider or (collider is CollisionShape3D and collider.disabled):
		interaction_label.hide()
		return
	if collider is Node3D:
		# Check for child CollisionShape3D
		var col = collider.get_node_or_null("CollisionShape3D")
		if col and col.disabled:
			interaction_label.hide()
			return

	# Determine which group the collider belongs to
	var interaction_found := false
	for group_name in group_interactions.keys():
		if collider.is_in_group(group_name):
			var method_name = group_interactions[group_name]["method"]
			var key_text = group_interactions[group_name]["key"]

			# Walk up the tree to find the method
			var node = collider
			while node and not node.has_method(method_name):
				node = node.get_parent()

			if node and node.has_method(method_name):
				# Show the label with the correct key
				interaction_label.text = "[%s] %s" % [key_text, method_name.capitalize()]
				interaction_label.show()
				
				# Call method if key pressed
				var input_action = "interact" if key_text == "E" else "item_interact"
				if Input.is_action_just_pressed(input_action):
					node.call(method_name)
					interaction_label.hide()  # Hide immediately after action
				interaction_found = true
				break  # Stop after first valid interaction

	if not interaction_found:
		interaction_label.hide()
