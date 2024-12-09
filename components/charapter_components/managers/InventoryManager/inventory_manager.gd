class_name InventoryManager

extends Node3D


@export var InteractionCollider : RayCast3D
@export var ItemsListNode : Node3D
@export var drop_marker : Marker3D
@export var player : Node3D

@export var items_count : int

@export var current_item_id = 0

var scene_
var current_item
var last_item

var ItemsList = ["Air"]

func _ready() -> void:
	scene_ = get_parent().get_parent().get_parent()

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority() : return
	if Input.is_action_just_pressed("use"): interact()
	if Input.is_action_just_pressed("interact"): Item_Use.rpc()
	if Input.is_action_just_pressed("drop"): drop_item.rpc()
	Change_Item.rpc()
		

func interact():
	if InteractionCollider.is_colliding() and InteractionCollider.get_collider() is Hitbox:
		InteractionCollider.get_collider().interact(self.get_parent())

@rpc("any_peer", "call_local")
func Add_Item(Item_Name):
	for child in ItemsListNode.get_children():
		if child is Item: 
			if child.Item_Name == Item_Name:
				if ItemsList.size() < items_count:
					ItemsList.append(Item_Name)
@rpc("any_peer", "call_local")
func Change_Item():
	if Input.is_action_just_pressed("Scroll_Up"):
		last_item = current_item_id
		var a = ItemsList.size()
		a -= 1
		if current_item_id < a:
			current_item_id += 1
			Inicilization_Item.rpc()
	elif Input.is_action_just_pressed("Scroll_Down"):
		if current_item_id > 0:
			current_item_id -= 1
			Inicilization_Item.rpc()

@rpc("any_peer", "call_local")
func Inicilization_Item():
	for i in ItemsList:
		if ItemsList.find(i) == current_item_id:
			for child in ItemsListNode.get_children():
				if child is Item and child.Item_Name == i:
					current_item = child
					child.show()
					if child.animator:
						child.animator.play("take")
				if child.Item_Name != i:
					child.hide()
@rpc("any_peer", "call_local")
func Item_Use():
	if current_item and current_item.animator != null:
		current_item.animator.play("use")
@rpc("any_peer", "call_local")
func drop_item():
	if current_item == null: return
	if current_item.drop_item == null: return
	var a
	for child in ItemsListNode.get_children():
		if child.Item_Name == ItemsList[current_item_id]:
			a = child
	var vector = drop_marker.global_position - $"../Camera_Node".global_position
	var c = a.drop_item.resource_path
	scene_.add_item.rpc(c, drop_marker.global_position, vector)
	ItemsList.remove_at(current_item_id)
	current_item_id = 0
	Inicilization_Item.rpc()
