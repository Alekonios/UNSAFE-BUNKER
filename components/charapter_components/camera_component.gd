extends Node

@export var mouse_sens : float = 0.1
@export var camera_node : Node3D
@export var camera : Camera3D
@export var Player : CharacterBody3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if !is_multiplayer_authority(): return
	camera.current = is_multiplayer_authority()
	
func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	camera.current = is_multiplayer_authority()
	if event is InputEventMouseMotion:
		Player.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera_node.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera_node.rotation.x = clamp(camera_node.rotation.x, deg_to_rad(-70), deg_to_rad(90))
	
