extends Node

var sample_hz = 11025.0 # Keep the number of samples to mix low, GDScript is not super fast.
var increment = 1.0 / sample_hz
var time = 0.0

var volume: float = 1.0
var muted: bool = true

var playback: AudioStreamPlayback = null # Actual playback stream, assigned in _ready().

var lua: LuaAPI = LuaAPI.new()

@export var osc: Oscilloscope

func reset_audio():
	osc.buffer.fill(0)
	osc.write_head = 0
	playback.stop()
	playback.clear_buffer()
	playback.start()

func _fill_buffer():
	var to_fill = playback.get_frames_available()
	var ret = lua.call_function("_get_frames",[time,increment,to_fill])
	var buf = []
	if ret is LuaError:
		print("ERROR %d: %s" % [ret.type, ret.message])
		for i in to_fill:
			buf.append(0)
			#playback.push_frame(Vector2.ZERO)
	else:
		if ret is Array:
			for i in ret:
				if i is float:
					buf.append(i)
					#playback.push_frame(Vector2.ONE * i)
				else:
					buf.append(0)
					#playback.push_frame(Vector2.ZERO)
		else:
			for i in to_fill:
				buf.append(0)
				#playback.push_frame(Vector2.ZERO)
	var max_value = buf.max()
	
	if max_value is float and max_value>1:
		for i in buf:
			i /= max_value
	for i in buf:
		playback.push_frame(Vector2.ONE * i)
	
	osc.add_samples(buf)
	osc.update_lines()
	time += to_fill * increment
	#while to_fill > 0:
		#if muted:
			#playback.push_frame(Vector2.ZERO)
			#return
		#var ret = lua.call_function("audio", [time])
		#if not ret is LuaError:
			#playback.push_frame(Vector2.ONE * ret * volume) # Audio frames are stereo.
		#else:
			#playback.push_frame(Vector2.ZERO)
		#time += increment
		#to_fill -= 1


func _process(_delta):
	if muted:
		$Player.stream_paused = true
	else:
		$Player.stream_paused = false
		_fill_buffer()
		lua.do_string("collectgarbage(\"collect\")")
	#print("mem: %d" % lua.get_memory_usage())

func _lua_sine(t:float):
	return sin(t*TAU)
func _lua_triangle(t:float):
	return pingpong(t,1)*2.0-1.0
func _lua_saw(t:float):
	return fmod(t,1.0)*2.0-1.0
func _lua_lerp(a:float,b:float,t:float):
	return lerp(a,b,t)
func _lua_remap(t:float,min1:float,max1:float,min2:float,max2:float):
	return remap(t,min1,max1,min2,max2)
func _lua_note(note):
	var step = 0
	if note is String:
		if note.length()<=1:
			return 0
		step = {
			"a":0,
			"b":2,
			"c":3,
			"d":5,
			"e":7,
			"f":8,
			"g":10,
		}[note[0].to_lower()]
		if note[1] == "#":
			step += 1
		elif note[1] == "b":
			step -= 1
		step += 12*(note[-1].to_int()-4)
	elif step is float or step is int:
		step = note
	else:
		return 0
	if step is int:
		return 440*pow(2,step/12.0)
	else:
		return 0

func _ready():
	lua.bind_libraries(["base", "table", "string", "math"])
	lua.push_variant("sine",_lua_sine)
	lua.push_variant("triangle",_lua_triangle)
	lua.push_variant("saw",_lua_saw)
	lua.push_variant("lerp",_lua_lerp)
	lua.push_variant("remap",_lua_remap)
	lua.push_variant("note",_lua_note)
	
	var err: LuaError = lua.do_string("""
	function _get_frames(time,inc,count)
		l={}
		for i = 1, count do
			l[i] = audio(time+inc*i)
		end
		return l
	end
	function audio(t)
		return sine(t*440)
	end
	""")
	if err is LuaError:
		print("ERROR %d: %s" % [err.type, err.message])
		return
	
	
	# Setting mix rate is only possible before play().
	$Player.stream.mix_rate = sample_hz
	$Player.play()
	playback = $Player.get_stream_playback()
	# `_fill_buffer` must be called *after* setting `playback`,
	# as `fill_buffer` uses the `playback` member variable.
	_fill_buffer()


#func _on_frequency_h_slider_value_changed(value):
	#%FrequencyLabel.text = "%d Hz" % value
	#pulse_hz = value


#func _on_volume_h_slider_value_changed(value):
	## Use `linear_to_db()` to get a volume slider that matches perceptual human hearing.
	#%VolumeLabel.text = "%.2f dB" % linear_to_db(value)
	#$Player.volume_db = linear_to_db(value)
