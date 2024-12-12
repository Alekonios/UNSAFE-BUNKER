class_name Visual_Component


extends Node

@export var IK_head : SkeletonIK3D



func _ready() -> void:
	IK_head.start()
	hide_ob()

func _process(delta: float) -> void:
	%FPS_bar.text = str(Engine.get_frames_per_second())

func hide_ob():
	if is_multiplayer_authority():
		$"../../Y-bot2/Armature_003/Skeleton3D/Alpha_Joints".transparency = 1
		$"../../Y-bot2/Armature_003/Skeleton3D/Alpha_Surface".transparency = 1
