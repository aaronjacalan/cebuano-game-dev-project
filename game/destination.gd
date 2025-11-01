extends Node3D

func _ready():
	# Assuming you have an Area3D as a child
	var area = $Area3D
	if area:
		area.body_entered.connect(enter_trigger)
	else:
		print("ERROR: No Area3D found on destination!")

func enter_trigger(body):
	if body.name == "ghost" and body.destination == self:
		body.pick_destination(body.destination_value)
		print("Ghost reached destination, picking new one")
