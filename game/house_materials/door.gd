extends Node3D

var opened = false
@onready var door_open: AudioStreamPlayer3D = $Door_Open
@onready var door_close: AudioStreamPlayer3D = $Door_Close

func toggle_door():
	if $AnimationPlayer.current_animation != "open" and $AnimationPlayer.current_animation != "close":
		opened = !opened
		if !opened:
			$AnimationPlayer.play("close")
			door_close.play()
		if opened:
			$AnimationPlayer.play("open") 
			door_open.play()
