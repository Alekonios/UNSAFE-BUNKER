class_name InventoryManager

extends Node3D

@export var InteractionCollider : RayCast3D
@export var ItemsListNode : Node3D
@export var items_count : int

var current_item = 0
var last_item

var ItemsList = ["Air"]


func _process(delta: float) -> void:
	Change_Item()
	print(ItemsList.size())

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("use"):
		interact()

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
		last_item = current_item
		var a = ItemsList.size()
		a -= 1
		if current_item < a:
			current_item += 1
			Inicilization_Item()
	elif Input.is_action_just_pressed("Scroll_Down"):
		if current_item > 0:
			current_item -= 1
			Inicilization_Item()
		
func Inicilization_Item():
	for i in ItemsList:
		if ItemsList.find(i) == current_item:
			for child in ItemsListNode.get_children():
				if child is Item and child.Item_Name == i:
					print(i)
					child.show()
				if child.Item_Name != i:
					child.hide()
				
					
