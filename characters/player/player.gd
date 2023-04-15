extends CharacterBody2D


@export var movement_speed := 300.0


func _physics_process(_delta):
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	velocity = direction * movement_speed
	move_and_slide()
