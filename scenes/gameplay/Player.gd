extends CharacterBody2D
class_name Player

const SPEED:float = 300.0
const JUMP_VELOCITY:float = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if Global.starting_game or Global.in_game_over: return
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		
	velocity.x = 0

	move_and_slide()
