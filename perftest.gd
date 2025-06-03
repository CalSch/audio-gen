extends Node2D

var buf: PackedInt32Array = []
var bufsize: int = 44000

func _ready() -> void:
	print("zeroing")
	var start = Time.get_ticks_usec()
	for i in bufsize:
		buf.append(0)
	var end = Time.get_ticks_usec()
	print("it took %f usec" % (end-start))
	
	print("filling with square")
	start = Time.get_ticks_usec()
	for i in bufsize:
		buf[i] = 1 if (i/100)%2==0 else 0
	end = Time.get_ticks_usec()
	print("it took %f usec" % (end-start))
	
	print("filling with sin")
	start = Time.get_ticks_usec()
	for i in bufsize:
		buf[i] = 1000*(sin(i/100)+1)
	end = Time.get_ticks_usec()
	print("it took %f usec" % (end-start))
	
	print("filling with expr")
	var expr = Expression.new()
	expr.parse("sin(440*t)+cos(632*t)",['t'])
	start = Time.get_ticks_usec()
	for i in bufsize:
		buf[i] = expr.execute([i])
	end = Time.get_ticks_usec()
	print("it took %f usec" % (end-start))
	
	print("filling with lua")
	start = Time.get_ticks_usec()
	var lua := LuaAPI.new()
	lua.bind_libraries(["base", "table", "string"])
	lua.do_string("""
function audio(t)
	return t
end
""")
	
	for i in bufsize:
		buf[i] = lua.call_function("audio", [i])
	end = Time.get_ticks_usec()
	print("it took %f usec" % (end-start))
	
