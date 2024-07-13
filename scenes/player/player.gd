extends CharacterBody2D

const TOP_BASE_OFFSET = -16
const TOP_HIGHER_OFFSET = -17



const SPEED = 70.0
const ISOMETRIC_MOVEMENT_ADJUST = 0.5

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var input_direction := Input.get_vector("Left","Right","Up","Down")
	input_direction.y *= 0.7 if not input_direction.x else ISOMETRIC_MOVEMENT_ADJUST
	velocity = input_direction * SPEED
	

	move_and_slide()
