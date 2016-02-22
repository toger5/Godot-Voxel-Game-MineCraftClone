#Timo Kandra

extends Spatial


var packed_Collider = load("CubeCollider.scn")
var wg
var worldMesh
var colSize = 3
var pressed = false

func _ready():
	wg = get_parent()
	worldMesh = wg.get_node("wg")
	initialColliderCreate()
	set_process(true)

func _process(delta):

	if Input.is_key_pressed(KEY_0) and !pressed:
		#refresh_collider()
		worldMesh.create_trimesh_collision()
		print("colldier gemacht")
		pressed = true
	if !Input.is_key_pressed(KEY_0):
		pressed = false

func refresh_collider():
	
	#for m in get_children():
	#print("refreshed")
	var camPos = wg.get_node("RigidBody 2").get_translation()
	for x in range(colSize):
		for z in range(colSize):
			for y in range(colSize):
				var c = Vector3(round(camPos.x), round(camPos.y), round(camPos.z))
				var col = colSize-1
				var p = Vector3(x-(col/2) + c.x, y-(col/2) + c.y, z-(col/2) + c.z)
				if wg.check_voxel(p):
					get_child( x*colSize*colSize + z*colSize + y ).set_translation(p)
#					print(x,"  ",z)
#					print(x*colSize+z," bewegtZu: ",p)


func initialColliderCreate():
	var camPos = wg.get_node("cameraParent").get_translation()
	for x in range(colSize):
		for z in range(colSize):
			for y in range(colSize):
			#print(!(Vector3(camPos.x + x,camPos.y +  y+camPos.y1, z) in wg.voxel),"  ", (Vector3(camPos.x + x, camPos.y +y, z) in wg.voxel))
				addCollider()
	print("collider amount = ",get_child_count())


func addCollider():
	var c = packed_Collider.instance()
	add_child(c)
