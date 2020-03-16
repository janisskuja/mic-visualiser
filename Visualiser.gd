extends Node2D


onready var spectrum = AudioServer.get_bus_effect_instance(0, 0)

export (int) var definition = 20
export (int) var total_w = 400
export (int) var total_h = 200

export (int) var min_frequency = 20
export (int) var max_frequency = 10000

export (int) var max_decibels = -10
export (int) var min_decibels = -50

export (float) var slope = 1.5

export (float) var acceleration = 8.0

var histogram = []

func _ready():
	for i in range (definition):
		histogram.append(0)

func _process(delta):
	var frequency = min_frequency
	var interval = (max_frequency - min_frequency) / definition
	for i in range(definition):
		
		var low_frequency = float(frequency - min_frequency) / float(max_frequency - min_frequency)
		low_frequency = low_frequency * low_frequency * low_frequency * low_frequency 
		low_frequency = lerp(min_frequency, max_frequency, low_frequency)
		
		frequency += interval
		
		var high_frequency = float(frequency - min_frequency) / float(max_frequency - min_frequency)
		high_frequency = high_frequency * high_frequency * high_frequency * high_frequency
		high_frequency = lerp(min_frequency, max_frequency, high_frequency)
		
		var magnitute = spectrum.get_magnitude_for_frequency_range(low_frequency, high_frequency)
		magnitute = linear2db(magnitute.length())
		magnitute = slope * (magnitute - min_decibels) / (max_decibels - min_decibels)
		magnitute = clamp(magnitute, 0.05, 1)
		
		histogram[i] = lerp(histogram[i], magnitute, acceleration * delta)
		
	update()

func _draw():
	var draw_pos = Vector2.ZERO
	var interwal_width = total_w / definition
	
	for i in range(definition):
		draw_line(draw_pos, draw_pos + Vector2(0, -(histogram[i] * total_h)), Color('#EBF5EE'), 21.0, true)
		draw_pos.x += interwal_width
