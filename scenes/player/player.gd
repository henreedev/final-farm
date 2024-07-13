extends CharacterBody2D


const SPEED = 70.0


func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_direction := Input.get_vector("Left","Right","Up","Down")
	velocity = input_direction * SPEED


	move_and_slide()
