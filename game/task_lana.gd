extends Node3D

@onready var object_interactor: RayCast3D = $Head/Camera3D/ObjectInteractor
@onready var lana_prayer: AudioStreamPlayer3D = $Lana_Prayer

# Lana bottle nodes
@onready var lana_map := {
	1: {
		"bottle": $lanabottles/"lana bottle1",
		"bottle_collision": $lanabottles/"lana bottle1"/lanastatic1/lanacollision1,
		"drop": $lanadropscontainer1/lanadrops1,
		"drop_collision": $lanadropscontainer1/lanadrops1/StaticBody3D/CollisionShape3D,
		"shadow": $lanadropscontainer1/lanadropsshadow1
	},
	2: {
		"bottle": $lanabottles/"lana bottle2",
		"bottle_collision": $lanabottles/"lana bottle2"/lanastatic2/lanacollision2,
		"drop": $lanadropscontainer2/lanadrops2,
		"drop_collision": $lanadropscontainer2/lanadrops2/StaticBody3D/CollisionShape3D,
		"shadow": $lanadropscontainer2/lanadropsshadow2
	},
	3: {
		"bottle": $lanabottles/"lana bottle3",
		"bottle_collision": $lanabottles/"lana bottle3"/lanastatic3/lanacollision3,
		"drop": $lanadropscontainer3/lanadrops3,
		"drop_collision": $lanadropscontainer3/lanadrops3/StaticBody3D/CollisionShape3D,
		"shadow": $lanadropscontainer3/lanadropsshadow3
	},
	4: {
		"bottle": $lanabottles/"lana bottle4",
		"bottle_collision": $lanabottles/"lana bottle4"/lanastatic4/lanacollision4,
		"drop": $lanadropscontainer4/lanadrops4,
		"drop_collision": $lanadropscontainer4/lanadrops4/StaticBody3D/CollisionShape3D,
		"shadow": $lanadropscontainer4/lanadropsshadow4
	},
	5: {
		"bottle": $lanabottles/"lana bottle5",
		"bottle_collision": $lanabottles/"lana bottle5"/lanastatic5/lanacollision5,
		"drop": $lanadropscontainer5/lanadrops5,
		"drop_collision": $lanadropscontainer5/lanadrops5/StaticBody3D/CollisionShape3D,
		"shadow": $lanadropscontainer5/lanadropsshadow5
	},
	6: {
		"bottle": $lanabottles/"lana bottle6",
		"bottle_collision": $lanabottles/"lana bottle6"/lanastatic6/lanacollision6,
		"drop": $lanadropscontainer6/lanadrops6,
		"drop_collision": $lanadropscontainer6/lanadrops6/StaticBody3D/CollisionShape3D,
		"shadow": $lanadropscontainer6/lanadropsshadow6
	},
	7: {
		"bottle": $lanabottles/"lana bottle7",
		"bottle_collision": $lanabottles/"lana bottle7"/lanastatic7/lanacollision7,
		"drop": $lanadropscontainer7/lanadrops7,
		"drop_collision": $lanadropscontainer7/lanadrops7/StaticBody3D/CollisionShape3D,
		"shadow": $lanadropscontainer7/lanadropsshadow7
	},
	8: {
		"bottle": $lanabottles/"lana bottle8",
		"bottle_collision": $lanabottles/"lana bottle8"/lanastatic8/lanacollision8,
		"drop": $lanadropscontainer8/lanadrops8,
		"drop_collision": $lanadropscontainer8/lanadrops8/StaticBody3D/CollisionShape3D,
		"shadow": $lanadropscontainer8/lanadropsshadow8
	},
	9: {
		"bottle": $lanabottles/"lana bottle9",
		"bottle_collision": $lanabottles/"lana bottle9"/lanastatic9/lanacollision9,
		"drop": $lanadropscontainer9/lanadrops9,
		"drop_collision": $lanadropscontainer9/lanadrops9/StaticBody3D/CollisionShape3D,
		"shadow": $lanadropscontainer9/lanadropsshadow9
	}
}

var chosen_bottle: int = -1  
var chosen_drops = []  

func _ready() -> void:
	randomize()
	chosen_bottle = randi() % lana_map.size() + 1
	update_lana_tasking()

# Update visibility and collisions
func update_lana_tasking() -> void:
	for id in lana_map.keys():
		var data = lana_map[id]
		var is_active = (id == chosen_bottle)

		# Only the chosen bottle is visible
		data["bottle"].visible = is_active
		data["bottle_collision"].set_deferred("disabled", not is_active)

		# Drops and shadows hidden/disabled initially
		data["drop"].visible = false
		data["drop_collision"].set_deferred("disabled", true)
		data["shadow"].visible = false

	# Randomize 5 chosen drops
	var all_ids = lana_map.keys()
	all_ids.shuffle()
	chosen_drops = all_ids.slice(0, 5)

func take() -> void:
	if chosen_bottle == -1:
		return

	var bottle_data = lana_map[chosen_bottle]
	bottle_data["bottle"].visible = false
	bottle_data["bottle_collision"].set_deferred("disabled", true)
	# Enable chosen drop shadows
	# Activate shadows for chosen drops
	for id in chosen_drops:
		var drop_data = lana_map[id]
		drop_data["shadow"].visible = true
		drop_data["drop_collision"].set_deferred("disabled", false)

	chosen_bottle = -1
	
func start_deploy_sound() -> void:
	if not lana_prayer.is_playing():
		lana_prayer.play()

func stop_deploy_sound() -> void:
	lana_prayer.stop()
	
func deploy(collider_body: PhysicsBody3D) -> void:
	if not collider_body:
		return

	for id in lana_map.keys():
		var data = lana_map[id]
		# Get the StaticBody3D from the CollisionShape3D
		var body_in_map = data["drop_collision"].get_parent()

		if collider_body == body_in_map:
			var shadow_visual_node = data["shadow"]
			if shadow_visual_node.visible:
				shadow_visual_node.visible = false # Hide the SHADOW
				data["drop"].visible = true       # Show the DROP
				data["drop_collision"].set_deferred("disabled", true)
			return
