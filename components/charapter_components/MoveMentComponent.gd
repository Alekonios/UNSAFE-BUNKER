class_name MoveMentComponent

extends CharacterBody3D

@export var _StateMachine : StateMachine

@export var target_position : Vector3
@export var target_rotation : Vector3

@export var IK : SkeletonIK3D

@export var defoult_speed : float
@export var run_speed : float

var SPEED = 2.5
const JUMP_VELOCITY = 4.5

var running = false
 
func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		target_position = global_position
		target_rotation = global_rotation
	else:
		global_position = global_position.lerp(target_position, delta * 7)
		global_rotation.y = lerp_angle(global_rotation.y, target_rotation.y, delta * 7)
	
	if !is_multiplayer_authority(): return
	
	if Input.is_action_pressed("run") and !Input.is_action_pressed("move_back"):
		running = true
		SPEED = run_speed
	elif !Input.is_action_pressed("run"):
		running = false
		SPEED = defoult_speed

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED * 1.2, 20 * delta)
		velocity.z = lerp(velocity.z, direction.z * SPEED * 1.2, 20 * delta)
		if running:
			_StateMachine.current_state = _StateMachine.Run
		elif !running:
			_StateMachine.current_state = _StateMachine.Walk
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		_StateMachine.current_state = _StateMachine.Idle
		 
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()
