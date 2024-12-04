class_name Hitbox

extends Area3D

#для юзабельных обьектов
@export var type : String
@export var _name : String
@export var have_rpc : bool
@export var have_sender : bool

var sender

func interact(_sender):
	if type == "UsableObject":
		if have_sender and have_rpc:
			_sender = _sender.get_path()
			RPC_interact.rpc(_sender)
			
@rpc("any_peer", "call_local")
func RPC_interact(_sender):
	var player = multiplayer.get_remote_sender_id()
	sender = get_tree().root.get_node(_sender)
	if multiplayer.get_remote_sender_id() == player:
		sender._InventoryManager.items.append(_name)
	
