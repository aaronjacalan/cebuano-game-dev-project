extends Node3D
func enter_trigger(body) :
	if body.name == "ghost" and body.destination == self:
		body.pick_destination(body.destination_value)
		print("DV: " + body.destination_value)
