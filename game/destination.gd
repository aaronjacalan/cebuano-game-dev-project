extends Node3D

@onready var area: Area3D = $Area3D

func _ready():
	area.body_entered.connect(_on_body_enter)

func _on_body_enter(body):
	if body.has_method("_pick_new_destination"):
		body._pick_new_destination()
