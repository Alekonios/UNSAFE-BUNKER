class_name StateMachine

extends Node

@onready var animator = $"../../Y-bot2/AnimationTree"

@onready var sync_animator = $"../../Y-bot2/AnimationPlayer"

enum {Idle, Walk, Run}

var current_state = Idle

func _process(delta: float) -> void:
	update_states()

func update_states():
	if !is_multiplayer_authority(): return
	match current_state:
		Idle:
			#animator.set("parameters/Movement/transition_request", "idle_")
			sync_animator.play("idle")
		Walk:
			#animator.set("parameters/Movement/transition_request", "walk_")
			sync_animator.play("walk")
		Run:
			#animator.set("parameters/Movement/transition_request", "run_")
			sync_animator.play("run")
			
