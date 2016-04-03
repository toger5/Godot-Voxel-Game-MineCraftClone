#Timo Kandra

var isgenerated = false
var BlocksAtSurfaceCreated = false
var isbuilded = false
var isColliderCreated = false
var isShown = false
#var isPhysic = false

var shouldBeShown = false
var wg

var datatool
var ChunkVoxel = {}
var blocks_at_surface = []
var collsion_blocks = []
var position
var surfaceIndex
var surface = SurfaceTool.new()
var packed_Collider = load("CubeCollider.scn")

var generateCoord
var generateStatus = 10
var thread = Thread.new()

# variablen fuer mehr_frame actionen
#var x_for_filling = 0
#var z_for_filling = 0
#var index_build_old = 0.0
#var x_for_generate = 0
# variablen fuer mehr_frame actionen

func _init(pos, wordGeneratorNode):
	datatool = MeshDataTool.new()
	isgenerated = false
	BlocksAtSurfaceCreated = false
	isbuilded = false
	#x_for_generate = pos.x
	wg = wordGeneratorNode
	position = pos
	
func generate_prepare():
	#wg.processing_chunks.append(self)
	if not thread.is_active():
		#print(Thread.PRIORITY_LOW, " prio")
		thread.start(self, "process", null, 0)
#	else:
#		thread.wait_to_finish()

func process(l):
	if not isgenerated:
		
		generate()#done
		
	if not BlocksAtSurfaceCreated:
		#print("filling started")
		fill_blocks_at_surface_list()#done
		#print("filled")
		#print("isbuilded ",isbuilded)
	if not isbuilded:
		build_chunk(position)

	return 0

func show():
	if isbuilded:
		show_execute()
	shouldBeShown = true

func hide():
	if isbuilded and isShown:
		isShown = false
		shouldBeShown = false
		var mesh = wg.wg_mesh.get_mesh()
		mesh.surface_remove(surfaceIndex)
		print("surface removed ",surfaceIndex)
		#correct all other chuncs indices that thex still can access the right surface
		for c in wg.chunk_dict:
			if wg.get_surfaceIndex(c) != null:
				var index = wg.get_surfaceIndex(c)
				if index > surfaceIndex:
					wg.set_surfaceIndex(c,index - 1)
					
func get_surfaceIndex():
	return surfaceIndex
	
func generate():
	
	#if not (posVector3(pos.x + int(wg.CHUNK_SIZE),0 ,pos.y + int(wg.CHUNK_SIZE)) in wg.voxel.keys()):
	for x in range(position.x, wg.CHUNK_SIZE + position.x ):
	# var x =  x_for_generate
	# if x <  wg.CHUNK_SIZE + position.x:
		for z in range(position.y, wg.CHUNK_SIZE + position.y ):
			var xforsim = x * 0.05+40
			var yforsim = z * 0.05+2000
			var worldHeight = 1 + (((wg.simplex.simplex2(xforsim,yforsim)+1)*0.5) * 16)
			xforsim = x * 0.02+1000
			yforsim = z * 0.02-2000
			#worldHeight += (((wg.simplex.simplex2(xforsim,yforsim)+1)*0.5) * 4)
		
			for y in range(worldHeight):
				ChunkVoxel[[x,y,z]] = 1#Vector3(x,y,z)] = 1
			
	#	x_for_generate += 1
	#else:
	isgenerated = true

	
func fill_blocks_at_surface_list():
	for x in range(wg.CHUNK_SIZE):
		#yield(wg.get_tree(),"idle_frame")
		for z in range(wg.CHUNK_SIZE):
			#yield(wg.get_tree(),"idle_frame")
			fill_blocks_at_surface_list_at(x,z)
#	if x_for_filling >= wg.CHUNK_SIZE:
#		x_for_filling = 0
#		z_for_filling += 1
#	if z_for_filling >= wg.CHUNK_SIZE:
#		generateStatus = 0
#		BlocksAtSurfaceCreated = true
#
#	else:
#		for a in range(4):
#			fill_blocks_at_surface_list(x_for_filling,z_for_filling)
#			x_for_filling += 1
			

func fill_blocks_at_surface_list_at(x,z):
		for y in range(wg.HEIGHT):
			var pos_to_check = Vector3(position.x + x, y, position.y + z)
			if check_voxel(pos_to_check):
				if check_if_surface_voxel(pos_to_check):
					blocks_at_surface.append(pos_to_check)

func check_if_surface_voxel(pos):
	var richtungen_liste = []
	var normals = [Vector3(1,0,0),Vector3(0,1,0),Vector3(0,0,1)]
	var flip = [1,-1]

	for nor in normals:
		for f in flip:
			if !((pos+nor*f).y == -1) and !(check_voxel(pos+nor*f)):
				return true
	return false

#func block_collider_initialisation():
#	var world = wg.get_node("/root/Node/world")
#	for pos in blocks_at_surface:
#		var col = packed_Collider.instance()
#		collsion_blocks.append(col)
#		col.translate(pos)

#	isColliderCreated = true
	
#func activate_physic():
#	if not thread.is_active():
#		#print("activate thread started")
#		thread.start(self,"aactivate_physic")
#	else:
#		thread.wait_to_finish()
		#print("tried to start active thread")
	
#func aactivate_physic(trash):
	
#	if not isPhysic and isColliderCreated:
#		var world = wg.get_node("world")
#		var blocks_per_frame = 100
#		var counter = 0
#		for c in collsion_blocks:#range(10):
#			if c.get_parent() != world:
#				counter += 1
#				world.call_deferred("add_child",(c))
#				if counter > blocks_per_frame:
#					counter = 0
#					yield(world.get_tree(),"idle_frame")
		#max einen chunc pro frame bauen dann sollte das genuegend performace geben
#		print("physics are created")
#		isPhysic = true
		
#func deactivate_physic(trash):
#	if not thread.is_active():
		#print("deactivate thread started")
#		thread.start(self,"ddeactivate_physic")
#	else:
#		thread.wait_to_finish()
		#print("tried to start deactive thread")
		
#func ddeactivate_physic():
	
#	if isPhysic:
#		var world = wg.get_node("world")
#		#for i in range(world.get_child_count()):    
#		var blocks_per_frame = 10
#		var counter = 0
#		print("!start colbblockcreation")
#		for c in collsion_blocks: 
#			if c.get_parent() == world:
#				world.call_deferred("remove_child",c)
#				if counter > blocks_per_frame:
#					counter = 0
#					yield(world.get_tree(),"idle_frame")
		#erstaml alles in eine Liste reinhauen und dann jedes frame etwas davon löschen
		# in einer weiteren process function oder sogar in die momentane mit ifs integriert......
		#diese liste wird erst bearbeitet wenn die anderen chunks gebaut worden sind
			#world.remove_child(world.get_child(0))
#		isPhysic = false
		
		
func remove_block(pos):
	print(pos)
	if pos in blocks_at_surface:
		
		ChunkVoxel.erase(vec_to_int(pos))
		blocks_at_surface.erase(pos)
		
		var mesh = wg.wg_mesh.get_mesh()
		datatool.create_from_surface(mesh, surfaceIndex)
		
		surface.begin(VisualServer.PRIMITIVE_TRIANGLES)
		surface.set_material(wg.material)
		
		
		for fI in range(datatool.get_face_count()):
			var v_pos = datatool.get_vertex(datatool.get_face_vertex(fI,0)) #bekomme index eines verts der face
			var diff = pos - v_pos
			var needed = true
			if abs(diff.x) == 0.5 and abs(diff.y) == 0.5 and abs(diff.z) == 0.5: #cheken ob es überhaupt in frage kommt
				var counter_for_all_verts_of_the_face = 1
				for i in range(2):
					var checkVector = pos - datatool.get_vertex(datatool.get_face_vertex(fI,i+1))
					if abs(checkVector.x) == 0.5 and abs(checkVector.y) == 0.5 and abs(checkVector.z) == 0.5: #fuer alle anderen verts der face checken
						counter_for_all_verts_of_the_face += 1
					if counter_for_all_verts_of_the_face == 3:#wenn alle teil einer zu löschendn face sind dann face nicht machen
						needed = false
			if needed:
				for i in range(3):
					var vIndex = datatool.get_face_vertex(fI,i)
					surface.add_uv(datatool.get_vertex_uv(vIndex))
					surface.add_normal(datatool.get_vertex_normal(vIndex))
					surface.add_vertex(datatool.get_vertex(vIndex))
			else:
				print("wurden nicht gebraucht")
		for voxel_r in check_surrounding_voxel_normal(pos):
			var voxel_pos = pos + voxel_r
			if not voxel_pos in blocks_at_surface:
				#print("added ",voxel_pos," to vox at surface")
				blocks_at_surface.push_back(voxel_pos)
			face_at(voxel_pos,-voxel_r,1)#ChunkVoxel[voxel_pos])muss noch nach voxeln im anderen chunc suchen
		
		#datatool.create_from_surface(surface.commit(), 0)
		hide()
		show()
		#isShown = true
		#shouldBeShown = true
		#surfaceIndex = mesh.get_surface_count()
		#yield(wg.get_tree(),"idle_frame")
		#mesh = surface.commit(mesh)
		
		#datatool.commit_to_surface(mesh)
		wg.get_node("Player").collider.refresh(wg.get_node("Player").get_pos_int())
		
	#	for vI in range(datatool.get_vertex_count()):
	#		var v_pos = datatool.get_vertex(vI)
	#		var v_n = datatool.get_vertex_normal(vI)
	#		var v_uv = datatool.get_vertex_uv(vI)
	#		#print("claorBlock v_n = ",v_n)
	#		var needed = true
	#		var diff = pos - v_pos
	#		if abs(diff.x) == 0.5 and abs(diff.y) == 0.5 and abs(diff.z) == 0.5:
	#			print("aaaa")
	#			var face = datatool.get_vertex_faces(vI)[0]
	#			var counter_for_all_verts_of_the_face = 0
	#			for i in range(3):
	#				var checkVector = pos - datatool.get_vertex(datatool.get_face_vertex(face,i))
	#				if abs(checkVector.x) == 0.5 and abs(checkVector.y) == 0.5 and abs(checkVector.z) == 0.5:
	#					counter_for_all_verts_of_the_face += 1
	#			if counter_for_all_verts_of_the_face == 3:
	#				needed = false
	#
	#		if needed:
	#			
	#			wg.surface.add_uv(v_uv)
	#			wg.surface.add_normal(v_n)
	#			wg.surface.add_vertex(v_pos)
			#else:
				#print("not needed: ",v_pos,"nor ist: ",v_n)
		
		
		
func build_chunk(pos):
	
#	if generateStatus == 0:
	surface.begin(VisualServer.PRIMITIVE_TRIANGLES)
	generateStatus = 1

#	if generateStatus == 1:
#	var buildspeed = 50
	#wenn index von blocks_at_surface ueberschritten werden wuerde
#		if index_build_old + buildspeed > blocks_at_surface.size():
#			buildspeed = blocks_at_surface.size() - index_build_old
#			generateStatus = 2
	##
#		for index in range(index_build_old,index_build_old + buildspeed):
	for index in range(blocks_at_surface.size()):
#		print(index)
		#yield(wg.get_tree(),"idle_frame")
		cube_at(blocks_at_surface[index],check_surrounding_voxel(blocks_at_surface[index]), ChunkVoxel[vec_to_int(blocks_at_surface[index])])
#		index_build_old += buildspeed

#	if generateStatus == 2:
		#print("generation is done now the chunc should be shown because: ",shouldBeShown)
	isbuilded = true
		#wg.surface.index()
	#print("datatool created ",surface)
	#datatool.create_from_surface(surface.commit(), 0)
	#print("datatool created ",isbuilded)
	if shouldBeShown:
		show_execute()

func show_execute():
	#wg.already_show_this_frame = true
	#print("done")
	#print("show",isbuilded,isShown)
	if isbuilded and not isShown:
		isShown = true
		var mesh = wg.wg_mesh.get_mesh()
		surfaceIndex = mesh.get_surface_count()
		print("surface added ",surfaceIndex)
		mesh = surface.call_deferred("commit",mesh)
		#datatool.call_deferred("commit_to_surface",mesh)

func check_voxel(v_pos):
	
	var von_x = position.x
	var bis_x = position.x + wg.CHUNK_SIZE - 1
	var von_z = position.y
	var bis_z = position.y + wg.CHUNK_SIZE - 1
	#im aktuellem chunk
	if von_x <= v_pos.x and v_pos.x <= bis_x    and   von_z <= v_pos.z and v_pos.z <= bis_z:
		return vec_to_int(v_pos) in ChunkVoxel
	else:
		return wg.check_voxel(v_pos)
	return false

func check_surrounding_voxel(pos):
	var richtungen_liste = []
	var normals = [Vector3(1,0,0),Vector3(0,1,0),Vector3(0,0,1)]
	var flip = [1,-1]

	for nor in normals:
		for f in flip:
			if ((pos+nor*f).y == -1): #ist der block ganz unten
				richtungen_liste.append(0)
			elif check_voxel(pos+nor*f):
				richtungen_liste.append(0)
			else:
				richtungen_liste.append(1)

	return richtungen_liste
	
func check_surrounding_voxel_normal(pos):
	var richtungen_liste = []
	for nor in [Vector3(1,0,0),Vector3(0,1,0),Vector3(0,0,1)]:
		for f in [1,-1]:
			if check_voxel(pos+nor*f):
				richtungen_liste.append(nor*f)

	return richtungen_liste




func cube_at(pos,neededFaces,type):
#	neededFaces is structured x (left,right) y (up,down) z (front, back) [0,0,1,0,0,0]
	var dirs = [Vector3(1,0,0),Vector3(0,1,0),Vector3(0,0,1)]

	for i in range(3):
		for k in range(2):
			if neededFaces[i*2+k] != 0:
				var n = dirs[i]*-(k*2 -1)
				face_at(pos,n,type)

func face_at(pos,normal,type):

	var s = 0.5
	pos += normal*s

	var verts =[Vector3(  0,  s, -s  ),
				Vector3(  0, -s, -s  ),
				Vector3(  0,  s,  s  ),
				Vector3(  0, -s,  s  )]

	#flippen von den noramls
	if normal.x + normal.y + normal.z < 0:
		verts = [verts[0],verts[2],verts[1],verts[3]]

	#eine liste mit der reinfolge wie oft coor x,y,z getauscht werden wird
	var normalList = [normal.x,normal.z,normal.y]
	for i in normalList:
		if abs(i) > 0:
			break
		else:
			var index = 0
			for v in verts:
				var tempV = v
				v.x = tempV.y
				v.y = tempV.z
				v.z = tempV.x
				verts[index] = v
				index += 1

	var uv_size = 0.0625
	var uvInfo = calcUV(type,normal)
	var uv_offset = uvInfo[1]#Vector2(0,0)
	var order_v  = [ 2   , 0   , 1   ,1    , 3   , 2   ]
	var order_uv = uvInfo[0]#[[1,0],[1,1],[0,1],[0,1],[0,0],[1,0]]
	for v in range(6):
		surface.set_material(wg.material)
		surface.add_uv((uv_offset * uv_size) + (uv_size * Vector2(order_uv[v][0],order_uv[v][1])))
		surface.add_normal(normal)
		surface.add_vertex(verts[order_v[v]] + pos)



func calcUV(type,normal):
	var uv_orderList = [[1,0],[1,1],[0,1],[0,1],[0,0],[1,0]]
	var uvoffset = Vector2(2,0)
	if type == 1 and normal == Vector3(0,1,0):
		uvoffset = Vector2(0,0)
	return [uv_orderList,uvoffset]
	
func vec_to_int(v):
	return [int(v.x),int(v.y),int(v.z)]
	
func int_to_vec(i):
	return Vector3(i[0],i[1],i[2])