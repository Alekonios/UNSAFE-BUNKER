extends CanvasLayer

@export var Enter_Ip : LineEdit


const PORT = 1488
var enet_peer = ENetMultiplayerPeer.new()

var scene = get_node

func _on_host_pressed() -> void:
	enet_peer.create_server(PORT, 10)
	multiplayer.multiplayer_peer = enet_peer
	get_tree().change_scene_to_file("res://assets/scenes/test/main_test_level/test.tscn")


func _on_join_pressed() -> void:
	enet_peer.create_client(Enter_Ip.text, PORT)
	multiplayer.multiplayer_peer = enet_peer
	get_tree().change_scene_to_file("res://assets/scenes/test/main_test_level/test.tscn")
