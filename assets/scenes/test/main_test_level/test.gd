extends Node3D

var player = preload("res://assets/scenes/charapters/Y-bot/Y-bot.tscn")

func _ready() -> void:
	if !multiplayer.is_server(): return
	var _player = player.instantiate()
	multiplayer.peer_connected.connect(add_player)
	add_player(multiplayer.get_unique_id())

func add_player(peer_id):
	var _player = player.instantiate()
	_player.name = str(peer_id)
	%player_node.add_child(_player)
	
func remove_player(peer_id):
	var player = %player_node.get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
