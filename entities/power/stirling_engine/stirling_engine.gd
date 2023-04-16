extends StaticBody2D


const BOOTUP_TIME := 6.0

@onready var animation := $Animation
@onready var tween = create_tween()


func _ready():
	tween.tween_property(animation, "speed_scale", 1, BOOTUP_TIME)
