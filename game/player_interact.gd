extends RayCast3D

@onready var interaction_label: Label = $"../Filters/Interaction_Label"
@onready var take_item: AudioStreamPlayer3D = $"../../../Sounds/Take_Item"
# Map groups to the method to call and the key to display
var group_interactions := {
	"interactable": {"method": "interact", "key": "E", "type": "press"},
	"equipable": {"method": "take", "key": "F", "type": "press"},
	"deployable": {"method": "use", "key": "F", "type": "press"}, 
	"hold_deploy": {"method": "deploy", "key": "F", "type": "hold"} 
}

var hold_time: float = 0.0
const USE_HOLD_DURATION: float = 7.0 # The time to hold, in seconds
var last_collider: Node = null # To track if we look away
var last_node_with_method: Node = null

func _physics_process(delta: float) -> void:
	var collider = get_collider()

	# --- RESET LOGIC (WHEN LOOKING AT NOTHING) ---
	if not collider or (collider is CollisionShape3D and collider.disabled):
		interaction_label.hide()
		if last_node_with_method and last_node_with_method.has_method("stop_deploy_sound"):
			last_node_with_method.call("stop_deploy_sound")
		hold_time = 0.0 # Reset timer
		last_collider = null
		return
	if collider is Node3D:
		var col = collider.get_node_or_null("CollisionShape3D")
		if col and col.disabled:
			interaction_label.hide()
			if last_node_with_method and last_node_with_method.has_method("stop_deploy_sound"):
				last_node_with_method.call("stop_deploy_sound")
			hold_time = 0.0 # Reset timer
			last_collider = null
			return
	# --- END RESET LOGIC ---

	var interaction_found := false
	for group_name in group_interactions.keys():
		if collider.is_in_group(group_name):
			# Get all interaction data from the map
			var data = group_interactions[group_name]
			var method_name = data["method"]
			var key_text = data["key"]
			var interaction_type = data["type"] # Get the "type" ("press" or "hold")

			# Walk up the tree to find the method
			var node = collider
			while node and not node.has_method(method_name):
				node = node.get_parent()

			if node and node.has_method(method_name):
				
				# Check if player looked at a NEW object
				if last_collider != collider:
					if last_node_with_method and last_node_with_method.has_method("stop_deploy_sound"):
						last_node_with_method.call("stop_deploy_sound")
					hold_time = 0.0 # Reset timer
					last_collider = collider # Update what we're looking at

				var input_action = "interact" if key_text == "E" else "item_interact"

				# --- START: LOGIC BASED ON INTERACTION TYPE ---
				
				if interaction_type == "hold":
					# --- HOLD LOGIC (for "hold_deploy") ---
					if Input.is_action_just_pressed(input_action):
						if node.has_method("start_deploy_sound"):
							node.call("start_deploy_sound")
							
					if Input.is_action_pressed(input_action):
						# Key is being held
						hold_time += delta
						
						# Update label to show progress
						var percent = int(clamp(hold_time / USE_HOLD_DURATION, 0.0, 1.0) * 100)
						interaction_label.text = "[Hold %s] %s... %d%%" % [key_text, method_name.capitalize(), percent]
						interaction_label.show()

						if hold_time >= USE_HOLD_DURATION:
							# --- ACTION TRIGGERED ---
							# (Add sound logic here if you want)
							# use_item.play() 
							
							node.call(method_name, collider) # Pass collider
							hold_time = 0.0
							interaction_label.hide()
					
					elif Input.is_action_just_released(input_action):
						# Key was released too early
						if node.has_method("stop_deploy_sound"):
							node.call("stop_deploy_sound")
						hold_time = 0.0
						interaction_label.text = "[Hold %s] %s" % [key_text, method_name.capitalize()]
						interaction_label.show()
					
					else:
						# Key is not being pressed
						hold_time = 0.0
						interaction_label.text = "[Hold %s] %s" % [key_text, method_name.capitalize()]
						interaction_label.show()
						
				elif interaction_type == "press":
					# --- PRESS LOGIC (for "interactable", "equipable", "deployable") ---
					interaction_label.text = "[%s] %s" % [key_text, method_name.capitalize()]
					interaction_label.show()
					
					if Input.is_action_just_pressed(input_action):
						if method_name == "use":
							# (Add use_item sound here if you have one)
							node.call("use", collider)
						elif method_name == "take":
							take_item.volume_db = -33
							take_item.play()
							node.call(method_name)
						else: # This will catch "interact"
							node.call(method_name)
						
						interaction_label.hide()

				# --- END: NEW LOGIC ---
				
				interaction_found = true
				break

	if not interaction_found:
		if last_node_with_method and last_node_with_method.has_method("stop_deploy_sound"):
			last_node_with_method.call("stop_deploy_sound")
		interaction_label.hide()
		hold_time = 0.0 # Reset timer
		last_collider = null
