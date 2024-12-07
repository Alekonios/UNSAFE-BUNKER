class_name InventoryManager

extends Node3D

@export var InteractionCollider : RayCast3D
@export var ItemsListNode : Node3D
@export var items_count : int
@export var drop_marker : Marker3D

var current_item_id = 0
var current_item
var last_item

var ItemsList = ["Air"]


func _process(delta: float) -> void:
	Change_Item()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("use"): interact()
	if Input.is_action_just_pressed("interact"): Item_Use()
	if Input.is_action_just_pressed("drop"): drop_item()
		

func interact():
	if !is_multiplayer_authority(): return
	if InteractionCollider.is_colliding() and InteractionCollider.get_collider() is Hitbox:
		InteractionCollider.get_collider().interact(self.get_parent())
		
func Add_Item(Item_Name):
	for child in ItemsListNode.get_children():
		if child is Item: 
			if child.Item_Name == Item_Name:
				if ItemsList.size() < items_count:
					ItemsList.append(Item_Name)

func Change_Item():
	if Input.is_action_just_pressed("Scroll_Up"):
		last_item = current_item_id
		var a = ItemsList.size()
		a -= 1
		if current_item_id < a:
			current_item_id += 1
			Inicilization_Item()
	elif Input.is_action_just_pressed("Scroll_Down"):
		if current_item_id > 0:
			current_item_id -= 1
			Inicilization_Item()
		
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
func Item_Use():
	if current_item:
		current_item.animator.play("use")
		
func drop_item():
	var scene = get_tree().root
	if current_item == null: return
	if current_item.drop_item == null: return
	var a = current_item.drop_item.instantiate()
	scene.add_child(a)
	a.global_position = drop_marker.global_position
	var vector = drop_marker.global_position - $"../Camera_Node".global_position
	a.apply_central_impulse(vector * 8)
	ItemsList.remove_at(current_item_id)
	current_item_id = 0
	Inicilization_Item()
