#Timo Kandra

extends RigidBody

var colliderClass = load("scripts/collider.gd")
export var sensitivity = 1.0
export var speed = 0.2
export var boost = 2
export var Jump_Speed = 1.0
onready var collider = colliderClass.new(10,get_pos_int(), self, get_node("/root/Node/PlayerCollision"))
var active = true
var in_air = false
var cam
var lastpos
var lastChunk = Vector2(0,0)
var destroy_oneBlock = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cam = get_node("Camera")
	set_fixed_process(true)
	Input.warp_mouse_pos(get_viewport().get_rect().size * 0.5)
	lastChunk = getCurrentChunk() + Vector2(1,0)
	get_node("Camera/RayClick").add_exception(self)
func getCurrentChunk():
	var intpos = Vector2(int(get_translation().x),int(get_translation().z))
	return Vector2(floor(intpos.x/16.0)*16, floor(intpos.y/16.0)*16)

#func createInitialPhysic():
#	var chunks = get_node("/root/Node").chunk_dict
#	for x in [-16,0,16]:
#		for y in [-16,0,16]:
#			if Vector2(getCurrentChunk().x+x, getCurrentChunk().y+y) in chunks:
#				chunks[Vector2(getCurrentChunk().x+x, getCurrentChunk().y+y) ].activate_physic()
	
func _fixed_process(delta):
	#pysic activieren im richtigen bereich
	var chunks = get_node("/root/Node").chunk_dict
	
	var currentChunk = getCurrentChunk()
	if currentChunk != lastChunk:
		var dir = (currentChunk - lastChunk)/16
		lastChunk = currentChunk
		print("direction: ",dir)
		#refresh physic
#		for felder in [-16,0,16]:
#			var cActivate = Vector2(0,0) + currentChunk #             felder*dir.y, fleder*dir.x
#			cActivate.x = felder*dir.y + dir.x*16 + currentChunk.x
#			cActivate.y = felder*dir.x + dir.y*16 + currentChunk.y 
#			if cActivate in chunks:
#				chunks[cActivate].activate_physic()
#			var cDeactivate = Vector2(0,0)#x + (-dir.x * 16), 2*y*-dir.y) + currentChunk
#			cDeactivate.x = felder*dir.y - dir.x * 32 + currentChunk.x
#			cDeactivate.y = felder*dir.x - dir.y * 32 + currentChunk.y 
#			if cDeactivate in chunks:
#				print("deactivate physic for: ",cDeactivate)
#				chunks[cDeactivate].ddeactivate_physic()
#				
				
		#call function for nwe generation ring
		get_node("/root/Node").entered_new_chunk(dir,currentChunk)
#	var chunkx = floor(intpos.x/16.0)*16
#	var chunky = floor(intpos.y/16.0)*16
	

	
	
	if lastpos != get_pos_int():
		#print("newPos: ",get_pos_int())
		lastpos = get_pos_int()
		collider.refresh(lastpos)
		
	if Input.is_key_pressed(KEY_O) and active == false:
		active = true
		print(active)
	if active and Input.is_key_pressed(KEY_P):
		active = false
		print(active)
	if Input.is_action_pressed("jump"):
		jumpen()
	if Input.is_action_pressed("l_click") and not destroy_oneBlock:
		destroyClickedBlock()
	if not Input.is_action_pressed("l_click"):
		destroy_oneBlock = false
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
		var moveDir = Vector3(0,0,0)
		moveDir = addVectorOnPressed(KEY_W,Vector3(0,0,-1),moveDir)
		moveDir = addVectorOnPressed(KEY_S,Vector3(0,0,1),moveDir)
		moveDir = addVectorOnPressed(KEY_A,Vector3(-1,0,0),moveDir)
		moveDir = addVectorOnPressed(KEY_D,Vector3(1,0,0),moveDir)
		move(moveDir.normalized())
		#move(KEY_Q,get_transform().basis.xform(Vector3(0,-1,0)))
		#move(KEY_E,get_transform().basis.xform(Vector3(0,1,0)))
func addVectorOnPressed(k,dir,vec):
	if(Input.is_key_pressed(k)):
		return dir + vec
	return vec
func move(dir):
	var b = 1
	if(dir != Vector3(0,0,0)):
		if(Input.is_key_pressed(KEY_SHIFT)):
			b = boost
		#else:s
		var d = dir * speed * b
		var transformedDir = get_transform().basis.xform(d)
		var vel = Vector3(transformedDir.x, get_linear_velocity().y,transformedDir.z)
		set_linear_velocity(vel)
		#set_linear_velocity(dir * speed * 50)

func jumpen():
	var curV = get_linear_velocity()
	set_linear_velocity(Vector3(curV.x, Jump_Speed, curV.z))
	if not in_air:
		var curV = get_linear_velocity()
		set_linear_velocity(Vector3(curV.x, Jump_Speed, curV.z))
		in_air = true
	else:
		var ray_cast = get_node("RayCast")
		ray_cast.set_enabled(true)
		if ray_cast.is_colliding():
			in_air = false
		ray_cast.set_enabled(false)
		
func destroyClickedBlock():
	print(destroy_oneBlock)
	var ray = get_node("Camera/RayClick")
	#var nor = ray.get_collision_normal()
	print(ray.get_collider())
	if ray.get_collider() != null:
		var pos = ray.get_collider().get_translation()
		
		utils.get_chunc_by_coord(get_node("/root/Node").chunk_dict,pos).remove_block(pos)
		destroy_oneBlock = true
	
func get_pos_int():
	var g = get_translation()
	return Vector3(round(g.x),round(g.y),round(g.z))