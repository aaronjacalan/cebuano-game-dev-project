extends Node3D

var door1_opened = false
var door2_opened = false

@onready var cabinet_animation: AnimationPlayer = $Cabinet_Animation
@onready var cabinet_open: AudioStreamPlayer3D = $Cabinet_Open
@onready var cabinet_close: AudioStreamPlayer3D = $Cabinet_Close

func toggle_door1():
	if not cabinet_animation.is_playing():
		door1_opened = !door1_opened
		if door1_opened:
			cabinet_animation.play("open_cabinet_1")
			cabinet_open.play()
		else:
			cabinet_animation.play("close_cabinet_1")
			cabinet_close.play()

func toggle_door2():
	if not cabinet_animation.is_playing():
		door2_opened = !door2_opened
		if door2_opened:
			cabinet_animation.play("open_cabinet_2")
			cabinet_open.play()
		else:
			cabinet_animation.play("close_cabinet_2")
			cabinet_close.play()
