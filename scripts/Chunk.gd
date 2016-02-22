#Timo Kandra

var isgenerated = false
var isReady = false
var isbuilded = false
var isColliderCreated = false
var isShown = false
var isPhysic = false

var shouldBeShown = false
var wg

var datatool
var ChunkVoxel = {}
var blocks_at_surface = []
var collsion_blocks = []
var position
var surfaceIndex

var packed_Collider = load("CubeCollider.scn")

var generateCoord
var generateStatus = 10

# variablen fuer mehr_frame actionen
var x_for_filling = 0
var z_for_filling = 0
var index_build_old = 0.0
var x_for_generate = 0
# variablen fuer mehr_frame actionen

func _init(pos, wordGeneratorNode):
	datatool = MeshDataTool.new()
	isgenerated = false
	isReady = false
	isbuilded = false
	x_for_generate = pos.x
	wg = wordGeneratorNode
	position = pos

func process():
	if not isgenerated:
		generate()
	elif not isReady:
		makeReady()
	elif not isColliderCreated:
		block_collider_initialisation()
	elif not isbuilded:
	 	build_chunk(position)
	else:
		print("chunc already isgenerated, isReady, isbuilded")

func generate_prepare():
	wg.processing_chunks.append(self)

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
				ChunkVoxel[Vector3(x,y,z)] = 1
			
	#	x_for_generate += 1
	#else:
	isgenerated = true

func makeReady():
	if x_for_filling >= wg.CHUNK_SIZE:
		x_for_filling = 0
		z_for_filling += 1
	if z_for_filling >= wg.CHUNK_SIZE:
		generateStatus = 0
		isReady = true

	else:
		for a in range(4):
			fill_blocks_at_surface_list(x_for_filling,z_for_filling)
			x_for_filling += 1
			

func fill_blocks_at_surface_list(x,z):
		#for z in range(16):
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

func block_collider_initialisation():
	var world = wg.get_node("/root/Node/world")
	for pos in blocks_at_surface:
		var col = packed_Collider.instance()
		collsion_blocks.append(col)
		col.translate(pos)

	isColliderCreated = true
	
func activate_physic():
	if not isPhysic and isColliderCreated:
		var world = wg.get_node("world")
		for c in collsion_blocks:#range(10):
			if c.get_parent() != world:
				world.add_child(c)
		#max einen chunc pro frame bauen dann sollte das genuegend performace geben
		
		isPhysic = true
		
func deactivate_physic():
	if isPhysic:
		var world = wg.get_node("world")
		#for i in range(world.get_child_count()):    
		for c in collsion_blocks: 
		 	world.remove_child(c)
		#erstaml alles in eine Liste reinhauen und dann jedes frame etwas davon löschen
		# in einer weiteren process function oder sogar in die momentane mit ifs integriert......
		#diese liste wird erst bearbeitet wenn die anderen chunks gebaut worden sind
			#world.remove_child(world.get_child(0))
		isPhysic = false
		
func build_chunk(pos):

	if generateStatus == 0:
		wg.surface.begin(VisualServer.PRIMITIVE_TRIANGLES)
		generateStatus = 1

	if generateStatus == 1:
		var buildspeed = 50
	#wenn index von blocks_at_surface ueberschritten werden wuerde
		if index_build_old + buildspeed > blocks_at_surface.size():
			buildspeed = blocks_at_surface.size() - index_build_old
			generateStatus = 2
	##
		for index in range(index_build_old,index_build_old + buildspeed):
			cube_at(blocks_at_surface[index],check_surrounding_voxel(blocks_at_surface[index]), ChunkVoxel[blocks_at_surface[index]])
		index_build_old += buildspeed

	if generateStatus == 2:
		#print("generation is done now the chunc should be shown because: ",shouldBeShown)
		isbuilded = true
		wg.surface.index()
		datatool.create_from_surface(wg.surface.commit(), 0)
		#print("datatool created ",isbuilded)
		if shouldBeShown:
			show_execute()

func show_execute():
	#print("show",isbuilded,isShown)
	if isbuilded and not isShown:
		isShown = true
		var mesh = wg.wg_mesh.get_mesh()

		surfaceIndex = mesh.get_surface_count()
		datatool.commit_to_surface(mesh)

func check_voxel(v_pos):
	
	var von_x = position.x
	var bis_x = position.x + wg.CHUNK_SIZE - 1
	var von_z = position.y
	var bis_z = position.y + wg.CHUNK_SIZE - 1
	#im aktuellem chunk
	if von_x <= v_pos.x and v_pos.x <= bis_x    and   von_z <= v_pos.z and v_pos.z <= bis_z:
		return v_pos in ChunkVoxel
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
		wg.surface.set_material(wg.material)
		wg.surface.add_uv((uv_offset * uv_size) + (uv_size * Vector2(order_uv[v][0],order_uv[v][1])))
		wg.surface.add_normal(normal)
		wg.surface.add_vertex(verts[order_v[v]] + pos)

func calcUV(type,normal):
	var uv_orderList = [[1,0],[1,1],[0,1],[0,1],[0,0],[1,0]]
	var uvoffset = Vector2(2,0)
	if type == 1 and normal == Vector3(0,1,0):
		uvoffset = Vector2(0,0)
	return [uv_orderList,uvoffset]
