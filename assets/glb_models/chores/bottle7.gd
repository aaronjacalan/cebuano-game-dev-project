extends Node3D

@onready var object_interactor: RayCast3D = $Head/Camera3D/ObjectInteractor

# Single Lana bottle setup (Bottle 7)
@onready var lana_bottle: Node3D = $"."
@onready var lana_bottle_collision: CollisionShape3D = $lanastatic7/lanacollision7

@onready var lana_script: Node3D = $"../../../../../../CHORES ITEMS/Task_Lana"

func _ready() -> void:
	if lana_script.chosen_bottle == 7:
		lana_bottle.visible = true
		lana_bottle_collision.set_deferred("disabled", false)
	else:
		lana_bottle.visible = false
		lana_bottle_collision.set_deferred("disabled", true)

func take() -> void:
	lana_script.take()

func deploy(collider_body: PhysicsBody3D) -> void:
	lana_script.deploy(collider_body)
