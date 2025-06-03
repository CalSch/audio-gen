@tool
class_name Oscilloscope
extends PanelContainer

@export var line2d: Line2D
@export var write_head_line: Line2D
@export var xaxis_line: Line2D

@export var buffer: PackedFloat32Array = []:
	set(value):
		buffer = value
		#update_lines()
@export var buffer_size: int = 256:
	set(value):
		buffer_size = value
		update_lines()
@export var write_head: int = 0:
	set(value):
		write_head = value
		#update_lines()

@export_tool_button("Update display") var update_lines_ = update_lines
@export_tool_button("Sine preview") var sine_preview = func():
	buffer = []
	for i in buffer_size:
		buffer.append(sin(float(i)/float(buffer_size)*2.0*TAU))
	update_lines()

func update_lines():
	var real_buf := get_uncircled_buffer()
	var trigger_idx := find_centered_steepest_trigger(real_buf)
	#trigger_idx = 0
	if line2d is Line2D:
		
		line2d.clear_points()
		for i in buffer_size:
			var index_fr = (trigger_idx + i) % buffer.size()
			#var index_fr = i
			var v = real_buf[index_fr]
			#if i==trigger_idx:
				#print(v)
			#if i==trigger_idx and abs(v)>0.2:
				#print("aah!")
				#print("v=%f" % v)
				#print("i=%d" % i)
				#print("indexfr=%d" % index_fr)
				#print("triggeridx=%d" % trigger_idx)
				#print("writehead=%d" % write_head)
			line2d.add_point(Vector2(
				(float(i)/float(buffer_size-1)) * get_size().x,
				(0.5 - v/2.0) * get_size().y
			))
	if write_head_line is Line2D:
		#TODO: optimize this
		write_head_line.clear_points()
		write_head_line.add_point(Vector2(
			(float(trigger_idx)/float(buffer_size-1)) * get_size().x,
			0
		))
		write_head_line.add_point(Vector2(
			(float(trigger_idx)/float(buffer_size-1)) * get_size().x,
			get_size().y
		))
	if xaxis_line:
		# TODO: optimize this too
		xaxis_line.clear_points()
		xaxis_line.add_point(Vector2(
			0,
			get_size().y/2
		))
		xaxis_line.add_point(Vector2(
			get_size().x,
			get_size().y/2
		))

func add_samples(samples:PackedFloat32Array):
	for s in samples:
		buffer[write_head] = s
		write_head = (write_head+1) % buffer.size()

func get_uncircled_buffer() -> PackedFloat32Array:
	var a = buffer.slice(write_head)
	a.append_array(buffer.slice(0,write_head))
	return a

# thanks chat jee bee dee
func find_centered_steepest_trigger(samples: PackedFloat32Array, threshold: float = 0.01) -> int:
	var center := samples.size() / 2
	var best_score := -INF
	var best_index := 0
	
	#var last = samples[-1]
	
	for i in samples.size()-1:
		if i==0:
			continue
		var value = samples[i]
		var last = samples[i-1]
		#if sign(last) != sign(value):
		if last<0 and value>0:
			return (i) if value < -last else (i-1)
		#last = value

	#for i in range(samples.size() - 1):
		#var s0 := samples[i]
		#var s1 := samples[i + 1]
#
		#if s0 < -threshold and s1 >= threshold:
			#var slope := s1 - s0
			#var distance: int = abs(i - center)
			#var alpha := 0.5  # You can adjust this to tune slope vs centering
			#var score := slope - alpha * float(distance) / samples.size()
#
			#if score > best_score:
				#best_score = score
				#best_index = i

	return -1
