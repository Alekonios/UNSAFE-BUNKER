class_name StateMachine

extends Node


@export var current_animation : String

@onready var animator = $"../../Y-bot2/AnimationTree"
@onready var sync_animator = $"../../Y-bot2/AnimationPlayer"

enum {Idle, Walk, Run}

var current_state = Idle

func _process(delta: float) -> void:
	if animator.animation_player_changed:
		update_states()
	if Input.is_action_just_pressed("ui_accept"):
		if !is_multiplayer_authority(): return
		jump_anim.rpc()

func update_states():
	if !is_multiplayer_authority(): return
	match current_state:
		Idle:
			update_anim("idle_")
		Walk:
			update_anim("walk_")
		Run:
			update_anim("run_")

func update_anim(name_):
	current_animation = name_
	animator.set("parameters/Movement/transition_request", current_animation)


@rpc("any_peer", "call_local")
func jump_anim():
	animator.set("parameters/JumpAnim/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
