class_name StateMachine

extends Node

@onready var animator = $"../../Y-bot2/AnimationTree"

@onready var sync_animator = $"../../Y-bot2/AnimationPlayer"

enum {Idle, Walk, Run}

var current_state = Idle

func _process(delta: float) -> void:
	update_states()
	if Input.is_action_just_pressed("ui_accept"):
		if !is_multiplayer_authority(): return
		jump_anim.rpc()

func update_states():
	if !is_multiplayer_authority(): return
	match current_state:
		Idle:
			update_with_rpc.rpc("idle_")
		Walk:
			update_with_rpc.rpc("walk_")
		Run:
			update_with_rpc.rpc("run_")



@rpc("any_peer", "call_local")
func update_with_rpc(name_):
	animator.set("parameters/Movement/transition_request", name_)
	
	
@rpc("any_peer", "call_local")
func jump_anim():
	animator.set("parameters/JumpAnim/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
