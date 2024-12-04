class_name InventoryManager

extends Node3D

@export var InteractionCollider : RayCast3D

var items = []

func _process(delta: float) -> void:
	print(items)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("use"):
		interact()

func interact():
	if InteractionCollider.is_colliding() and InteractionCollider.get_collider() is Hitbox:
		InteractionCollider.get_collider().interact(self.get_parent())
