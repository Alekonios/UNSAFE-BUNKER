class_name VoiceManager

extends Node

@export var input : AudioStreamPlayer
@export var Import_Audio : NodePath
@export var debug_cube : Node3D

var index : int
var effect : AudioEffectCapture
var playback : AudioStreamGeneratorPlayback
var input_started = 0.008
var recordBuffer := PackedFloat32Array()

func _ready() -> void:
	setupAudio()

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		processMic()
	process_voice()
	

func setupAudio():
	if is_multiplayer_authority():
		input.stream = AudioStreamMicrophone.new()
		input.play()
		index = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(index, 0)
	if !is_multiplayer_authority():
		playback = get_node(Import_Audio).get_stream_playback()
	
	
func processMic():
	var stereoData: PackedVector2Array = effect.get_buffer(effect.get_frames_available())
	
	if stereoData.size() > 0:
		var data = PackedFloat32Array()
		data.resize(stereoData.size())
		var max_amplitude := 0.0
		
		for i in range(stereoData.size()):
			var value = (stereoData[i].x + stereoData[i].y) / 2
			max_amplitude = max(value, max_amplitude)
			data[i] = value
		if max_amplitude < input_started:
			return
		sendData.rpc(data)
		
func process_voice():
	if recordBuffer.size() <= 0 or playback == null:
		return
	for i in range(min(playback.get_frames_available(), recordBuffer.size())):
		playback.push_frame(Vector2(recordBuffer[0], recordBuffer[0]))
		recordBuffer.remove_at(0)
@rpc("call_local", "any_peer", "unreliable_ordered")
func sendData(data: PackedFloat32Array):
	recordBuffer.append_array(data)
	
