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
var MAX_PACKET_SIZE = 1392  # MTU лимит (включает заголовки)

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
			max_amplitude = max(abs(value), max_amplitude)
			data[i] = value

		if max_amplitude < input_started:
			return

		# Отправка данных по фрагментам
		send_audio_data(data)
		
func process_voice():
	if recordBuffer.size() <= 0 or playback == null:
		return

	for i in range(min(playback.get_frames_available(), recordBuffer.size())):
		playback.push_frame(Vector2(recordBuffer[0], recordBuffer[0]))
		recordBuffer.remove_at(0)

@rpc("call_local", "any_peer", "unreliable_ordered")
func sendData(data: PackedByteArray):
	var unpacked_data = PackedFloat32Array()
	for i in range(0, data.size(), 2):
		var sample = int(data[i]) | (int(data[i + 1]) << 8)  # Сборка int16 из 2 байтов
		if sample > 32767:
			sample -= 65536  # Преобразование для отрицательных значений
		var float_sample = float(sample) / 32767.0  # Возврат к диапазону [-1, 1]
		unpacked_data.append(float_sample)
	recordBuffer.append_array(unpacked_data)

# Преобразование float32 (-1.0 до 1.0) в int16 (-32768 до 32767) и отправка по частям
# Преобразование float32 (-1.0 до 1.0) в int16 (-32768 до 32767) и отправка по частям
func send_audio_data(data: PackedFloat32Array):
	# Преобразуем float в int16 и сохраняем в PackedByteArray
	var byte_data = PackedByteArray()
	for i in range(data.size()):
		var sample_int16 = int(data[i] * 32767.0)  # Преобразуем float (-1.0 до 1.0) в int16 (-32768 до 32767)
		byte_data.append(sample_int16 & 0xFF)  # младший байт
		byte_data.append((sample_int16 >> 8) & 0xFF)  # старший байт
	
	# Разбиваем byte_data на пакеты
	var start_index = 0
	while start_index < byte_data.size():
		# Максимальный размер пакета, учитывая заголовок
		var end_index = min(start_index + MAX_PACKET_SIZE, byte_data.size())
		
		# Проверяем, что end_index больше start_index
		if start_index >= end_index:
			break

		# Изменён вызов slice
		var packet = byte_data.slice(start_index, end_index)  # Теперь не вычитание, а конечный индекс
		sendData.rpc(packet)

		# Сдвигаем индекс на длину пакета
		start_index = end_index
