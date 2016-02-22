#Timo Kandra

extends RigidBody


export var sensitivity = 1.0
export var speed = 0.2
export var boost = 2
export var Jump_Speed = 1.0
var b
var active = true
var in_air = false
var cam
var lastpos
var lastChunk = Vector2(0,0)

func _ready():
	cam = get_node("Camera")
	set_fixed_process(true)
	Input.warp_mouse_pos(get_viewport().get_rect().size * 0.5)
	lastChunk = getCurrentChunk() + Vector2(1,0)
	
func getCurrentChunk():
	var intpos = Vector2(int(get_translation().x),int(get_translation().z))
	return Vector2(floor(intpos.x/16.0)*16, floor(intpos.y/16.0)*16)

func createInitialPhysic():
	var chunks = get_node("/root/Node").chunk_dict
	for x in [-16,0,16]:
		for y in [-16,0,16]:
			if Vector2(getCurrentChunk().x+x, getCurrentChunk().y+y) in chunks:
				chunks[Vector2(getCurrentChunk().x+x, getCurrentChunk().y+y) ].activate_physic()
	
func _fixed_process(delta):
	#pysic activieren im richtigen bereich
	var chunks = get_node("/root/Node").chunk_dict
	
	var currentChunk = getCurrentChunk()
	if currentChunk != lastChunk:
		var dir = (currentChunk - lastChunk)/16
		lastChunk = currentChunk
		print("direction: ",dir)
		#refresh physic
		for felder in [-16,0,16]:
			var cActivate = Vector2(0,0) + currentChunk #             felder*dir.y, fleder*dir.x
			cActivate.x = felder*dir.y + dir.x*16 + currentChunk.x
			cActivate.y = felder*dir.x + dir.y*16 + currentChunk.y 
			if cActivate in chunks:
				chunks[cActivate].activate_physic()
			var cDeactivate = Vector2(0,0)#x + (-dir.x * 16), 2*y*-dir.y) + currentChunk
			cDeactivate.x = felder*dir.y - dir.x * 32 + currentChunk.x
			cDeactivate.y = felder*dir.x - dir.y * 32 + currentChunk.y 
			if cDeactivate in chunks:
				print("deactivate physic for: ",cDeactivate)
				chunks[cDeactivate].deactivate_physic()
				
				
		#call function for nwe generation ring
		get_parent().entered_new_chunk(dir,currentChunk)
#	var chunkx = floor(intpos.x/16.0)*16
#	var chunky = floor(intpos.y/16.0)*16
	

	
	
	if lastpos != getPosInt():
		#print("newPos: ",getPosInt())
		lastpos = getPosInt()
		#get_node("/root/Node/world").refresh_collider()
	if Input.is_key_pressed(KEY_O) and active == false:
		active = true
		print(active)
	if active and Input.is_key_pressed(KEY_P):
		active = false
		print(active)
	if Input.is_action_pressed("jump"):
		jumpen()
		#in_air = true

	#steuerung um sich mit der maus umzusehen
	if active:
		var mouseMove = (get_viewport().get_mouse_pos()-get_viewport().get_rect().size * 0.5) * sensitivity * 0.01
		Input.warp_mouse_pos(get_viewport().get_rect().size * 0.5)
		cam.rotate_x(mouseMove.y)
		if cam.get_rotation().x < -1.5:
			cam.set_rotation(Vector3(-1.5,cam.get_rotation().y,cam.get_rotation().z))
		if cam.get_rotation().x > 1.5:
			cam.set_rotation(Vector3(1.5,cam.get_rotation().y,cam.get_rotation().z))
		rotate_y(mouseMove.x)

		#steuerung mit W_A_S_D und Hoch/runter mit Q_E
		set_linear_velocity(Vector3(0,get_linear_velocity().y,0))
		move(KEY_W,Vector3(0,0,-1))
		move(KEY_S,Vector3(0,0,1))
		move(KEY_A,Vector3(-1,0,0))
		move(KEY_D,Vector3(1,0,0))
		#move(KEY_Q,get_transform().basis.xform(Vector3(0,-1,0)))
		#move(KEY_E,get_transform().basis.xform(Vector3(0,1,0)))
func move(k,dir):
	b = 1
	if(Input.is_key_pressed(k)):
		if(Input.is_key_pressed(KEY_SHIFT)):
			b = boost
		#else:s
		var d = dir * speed * b
		var transformedDir = get_transform().basis.xform(d)
		var vel = Vector3(transformedDir.x, get_linear_velocity().y,transformedDir.z)
		set_linear_velocity(vel)
		#set_linear_velocity(dir * speed * 50)

func jumpen():
	#print("jo")
	if not in_air:
		var curV = get_linear_velocity()
		set_linear_velocity(Vector3(curV.x, Jump_Speed, curV.z))
		in_air = true
	else:
		var ray_cast = get_node("/root/Node/Player/RayCast")
		ray_cast.set_enabled(true)
		
		if ray_cast.is_colliding():
			in_air = false
			ray_cast.set_enabled(false)

func getPosInt():
	var g = get_translation()
	return Vector3(round(g.x),round(g.y),round(g.z))
