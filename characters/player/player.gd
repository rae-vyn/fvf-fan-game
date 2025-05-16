extends CharacterBody3D

@onready var head = $Head

var current_speed: float = 5.0

@export var walking_speed: float = 7.0
@export var sprinting_speed: float = 9.0
@export var crouching_speed: float = 3.0
@export var mouse_sens: float = 0.3
@export var Jump_Max: int = 1
@export var initialGravity: float = 2
@export var Jumptime: float = 0.2
@onready var coyote_timer: Timer = $CoyoteTimer

var Jump_amount: int = 1
var jump_velocity: float = 8.5
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
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed if is_on_floor() else current_speed
		head.position.y = lerp(head.position.y, 1.6 + crouching_depth, delta * lerp_speed)
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
		if Jump_amount:
			if coyote_timer.is_stopped():
				coyote_timer.start(Jumptime)
			#Makes a timer connecting to the variable to the Function
			
		
		velocity += get_gravity() * initialGravity * delta 
	else:
		Jump_amount = Jump_Max

	# Handle jump.
	if Input.is_action_just_pressed("jump") and Jump_amount > 0:
		velocity.y = jump_velocity
		Jump_amount += -1
		coyote_timer.stop()

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

#Timer calls this function when its timed out
func jumptimeout():
	Jump_amount += -1
	
