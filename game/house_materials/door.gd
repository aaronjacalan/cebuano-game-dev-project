extends Node3D

var opened = false
@onready var door_open: AudioStreamPlayer3D = $Door_Open
@onready var door_close: AudioStreamPlayer3D = $Door_Close
@onready var door_animation: AnimationPlayer = $Door_Animation

func toggle_door():
	if door_animation.current_animation != "open" and door_animation.current_animation != "close":
		opened = !opened
		if !opened:
			door_animation.play("close")
			door_close.play()
		if opened:
			door_animation.play("open") 
			door_open.play()
			
