extends Node3D

var opened = false

@onready var wardrobe_open: AudioStreamPlayer3D = $"../../../../../Wardrobe_Open"
@onready var wardrobe_close: AudioStreamPlayer3D = $"../../../../../Wardrobe_Close"
@onready var wardrobe_animation: AnimationPlayer = $"../../../../../Wardrobe_Animation"


func interact():
	if wardrobe_animation.current_animation != "open" and wardrobe_animation.current_animation != "close":
		opened = !opened
		if !opened:
			wardrobe_animation.play("close_wardrobe")
			wardrobe_close.play()
		if opened:
			wardrobe_animation.play("open_wardrobe") 
			wardrobe_open.play()
			
