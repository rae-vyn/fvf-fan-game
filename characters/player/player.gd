extends CharacterBody3D

@onready var head = $Head

var current_speed: float = 5.0

@export var walking_speed: float = 7.0
@export var sprinting_speed: float = 9.0
@export var crouching_speed: float = 3.0
@export var mouse_sens: float = 0.3


var jump_velocity: float = 6
var lerp_speed: float = 10.0
var direction: Vector3 = Vector3.ZERO

var crouching_depth = -0.5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-deg_to_rad(event.relative.x * mouse_sens))
		head.rotate_x(-deg_to_rad(event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("crouch") and is_on_floor():
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth, delta * lerp_speed)
		$StandingShape.disabled = true
		$CrouchingShape.disabled = false
	elif !$StandingCast.is_colliding():
		head.position.y = lerp(head.position.y, 1.8, delta * lerp_speed)
		$StandingShape.disabled = false
		$CrouchingShape.disabled = true
		if Input.is_action_pressed("sprint"):
			current_speed = sprinting_speed
		else:
			current_speed = walking_speed
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
