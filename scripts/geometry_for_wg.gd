extends Node

var HEIGHT = 20
var surface
var wg_mesh




#var voxel = {}
var chunk_dict = {}
var chunkClass = load("scripts/Chunk.gd")
var simplex = load("scripts/simplex2D.gd")
#var processing_chunks = []
export(FixedMaterial) var material = null

var ringlist
var hidelist = []
#var generateStatus = 10
var generateCoord = Vector2(0,0)
var pos_to_generate = Vector2(0,0)
var currentrange = 0
var CHUNK_SIZE = 16
var RANGE = 5
var thread = Thread.new()

#testvars 
var frameone = true

func _ready():
	print("changed")

	var generateCoord = Vector2(0,0)
#	print(simplex.simplex2(0.1,0.1))
	wg_mesh = get_node("wg")
	surface = SurfaceTool.new()
	set_process(true)
	set_process_input(true)
#	set_fixed_process(true)

#	create_chunc_at(Vector2(0,0))
	
func _input(event):
	#only for testing (outdated)
	if event.type == InputEvent.KEY:
		
		if event.scancode == KEY_G:
			print("inG")
			var pos = generateCoord
			for x in range(2):
				pos.x = x * 16
				print(pos)
				if not pos in chunk_dict.keys():
					add_chunk(pos)
		if event.scancode == KEY_B:
			chunk_dict[Vector2(0,0)].show()
		if event.scancode == KEY_C:
			chunk_dict[Vector2(0,0)].remove_block(Vector3(6,12,4))
		if event.scancode == KEY_1:
			generateCoord.y = 16
		if event.scancode == KEY_2:
			generateCoord.y = 32

#func initial_generate(size):
#	var s = size+2
#	for x in range(s):
#		for y in range(s):
#			var pos = Vector2(x-((s-1)/2), y-((s-1)/2))*16
#			chunk_dict[pos] = chunkClass.new(pos,self)
#			#chunk_dict[pos].generate()
#	var s = size
#	for x in range(s):
#		for y in range(s):
#			var pos = Vector2(x-((s-1)/2), y-((s-1)/2))*16
#			chunk_dict[pos].generate_prepare()
#			chunk_dict[pos].show()


func generate_chunks():
	
	if frameone:
		frameone = false
		ringlist = build_neededChuncsList(Vector2(0,0))
	if not ringlist.empty():# and processing_chunks.size() == 0:
		if not ringlist[0] in chunk_dict or not chunk_dict[ringlist[0]].isbuilded:
			create_chunc_at(ringlist[0])
		else:
			if not chunk_dict[ringlist[0]].thread.is_active():
				#print(Thread.PRIORITY_LOW, " prio")
				#thread.start(self, "create_chunc_at", ringlist[0], 1)
				#create_chunc_at(ringlist[0])
				chunk_dict[ringlist[0]].show()
				ringlist.remove(0)
			else:
				chunk_dict[ringlist[0]].thread.wait_to_finish()
			#wg.processing_chunks.append(self)
		

func create_chunc_at(pos):
	#print(pos)
#	var nothing_done = true
	
	#prepeare surunging chuncs for main chunc generation
	#var t = OS.get_ticks_msec()
	for x in [-1,0,1]:
		for y in [-1,0,1]:
			var surrounding_chunk_pos = Vector2(x, y)*16 + pos
			if not surrounding_chunk_pos in chunk_dict:
				chunk_dict[surrounding_chunk_pos] = chunkClass.new(surrounding_chunk_pos,self)
			if not chunk_dict[surrounding_chunk_pos].isgenerated:
				chunk_dict[surrounding_chunk_pos].generate()
			#yield(get_tree(),"idle_frame")
				#print("generateion")
#				nothing_done = false
	#print("all surrounding chuncs werer generated time_",OS.get_ticks_msec() - t)
	if not chunk_dict[pos].isShown:
		#generate main chunc
		chunk_dict[pos].generate_prepare()
		chunk_dict[pos].show()
#		nothing_done = false
	
#	return nothing_done

	

func build_neededChuncsList(pos):
	var l = [pos]
	var xRing = 0
	var yRing = 0
	var r = 1
	while r <= (RANGE):
		xRing = r
		yRing = r
		for dir in [-1,1]:
			for i in range(r*2):
				xRing += dir
				l.append( pos + Vector2(xRing,yRing)*16.0)
				
			for i in range(r*2):
				yRing += dir
				l.append( pos + Vector2(xRing,yRing)*16.0)
		r+=1
	return l

func entered_new_chunk(dir,chunk_pos): #character changed chunc position
	#print(chunk_pos)
	ringlist = build_neededChuncsList(chunk_pos)
	#hide chunks which are aout of range
	for i in range(-RANGE,RANGE+1):
		var c_hide = Vector2()
		c_hide.x = i*dir.y*CHUNK_SIZE - dir.x * RANGE*CHUNK_SIZE + chunk_pos.x
		c_hide.y = i*dir.x*CHUNK_SIZE - dir.y * RANGE*CHUNK_SIZE + chunk_pos.y
		hidelist.push_back(c_hide)
		
func hide_hidelist_chunks():
	if hidelist.size() > 0:
		
		if hidelist[0] in chunk_dict:
			chunk_dict[hidelist[0]].hide()
		hidelist.remove(0)
			
func get_surfaceIndex(position):
	return chunk_dict[position].surfaceIndex
	
func set_surfaceIndex(position,value):
	chunk_dict[position].surfaceIndex = value
	
func _process(delta):
	#process_chunks()
	hide_hidelist_chunks()
	generate_chunks()
#	if frameone:
#		frameone = false
#		ringlist = build_neededChuncsList(Vector2(0,0))
#	if not ringlist.empty():# and processing_chunks.size() == 0:
#		create_chunc_at(ringlist[0]) #returns true if nothing was done
#		ringlist.remove(0)


#wenn auf bereich in neuem chungc geklickt dann datat tool aus dieser surface machen
#man braucht vector der position von dem collider der physik der mit dem ray des carracters collided
#	datatool.create_from_surface(wg_mesh.get_mesh(),0)#surface über index position array bekommen es werden immer die gleiche indices gelöscht welche auch in dem emsch gelöscht werden
	#VIEL ARBEIT wenn auf bestimmte position geclicked dann werden die richtigen verts gesucht und geändert
	#weniger arbeit die voxel werden aktualisiert
#	for i in range(datatool.get_vertex_count()):
#		if datatool.get_vertex(i) == Vector3(0.5,0.5,1.5):
#			pass
		#dann wird das neue mesh der gleich surface wieder zugewiedsen wie davor

#wenn sich die palyer coord um 1 ändert werden alle collider meshes gelöscht.
#dann alle Y achesn von player.x -2,player.z-2 bis player.x+2 bis player.z+2 neu gescannt und stellen bestimmt wo es physic meshes braucht

#letzte aufgabe: wenn der player sic so wei bewegt, dass es einen weiteren chunc braucht dann werden die richtigen chunc surfaces gelöscht und
# nue erstellt (mit der generator function) diese werden dann hinten drangehängt. die Liste mit den chunc ids und den coordinaten wird immer parallel dazu mitgeändert
#func add_chunk(pos):
#	chunk_dict[pos] = chunkClass.new(pos,self)
#	chunk_dict[pos].generate_prepare()
#	chunk_dict[pos].show()

func check_voxel(v_pos):
#	var fuerMinus_x = 0
#	var fuerMinus_z = 0
#	if v_pos.x<0:
#		fuerMinus_x = -16
#	if v_pos.z < 0:
#		fuerMinus_z = -16
#	var chunkx = floor(intpos.x/16.0)*16
#	var chunky = floor(intpos.y/16.0)*16
#	var correctChunkPos = Vector2(int(v_pos.x) - ((int(v_pos.x)%CHUNK_SIZE)) + fuerMinus_x,int(v_pos.z) - ((int(v_pos.z)%CHUNK_SIZE)) + fuerMinus_z)
	var correctChunkPos = Vector2(floor(v_pos.x/16.0)*16, floor(v_pos.z/16.0)*16)
	if correctChunkPos in chunk_dict:
#		if v_pos.x > 15:
#			
#			print("existieret",v_pos in chunk_dict[correctChunkPos].ChunkVoxel)
		return utils.vec_to_int(v_pos) in utils.get_chunc_by_coord(chunk_dict,v_pos).ChunkVoxel#chunk_dict[correctChunkPos].ChunkVoxel
	return false

#func process_chunks():
#	if processing_chunks.size() > 0:
#		if !processing_chunks[0].isbuilded:
#			processing_chunks[0].process()
#		else:
#			processing_chunks.remove(0)
#			#get_node("Player").createInitialPhysic()
#			#print("Chunk FertiG!!!!! anzahl an noch zu berechenenden chunks: ", processing_chunks.size())
