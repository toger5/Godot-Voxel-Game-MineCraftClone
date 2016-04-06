#Timo Kandra

extends Spatial

var packed_Collider = load("CubeCollider.scn")
var wg
var character
var spital
var size

func _init(siz,pos,char,spit):
	spital = spit
	size = siz
	wg = char.get_node("/root/Node")
	initialColliderCreate(size,pos)
	
func refresh(pos):
	var index = 0
	var neededPos = []
	for y in [-1,2]:
		if wg.check_voxel(pos + Vector3(0,y,0)):
			neededPos.push_back(pos + Vector3(0,y,0))
			
	for y in [0,1]:
		for x in [-1,1]:
			if wg.check_voxel(pos + Vector3(x,y,0)):
				neededPos.push_back(pos + Vector3(x,y,0))
				
		for z in [-1,1]:
			if wg.check_voxel(pos + Vector3(0,y,z)):
				neededPos.push_back(pos + Vector3(0,y,z))
				
	if neededPos.size()>0:
		for i in range(size):
			if i < neededPos.size():
				spital.get_child(i).set_translation(neededPos[i])
			else:
				spital.get_child(i).set_translation(neededPos[0])
			
func initialColliderCreate(size,pos):
	
	for i in range(size):
		#print(!(Vector3(camPos.x + x,camPos.y +  y+camPos.y1, z) in wg.voxel),"  ", (Vector3(camPos.x + x, camPos.y +y, z) in wg.voxel))
		addCollider()
	refresh(pos)
	
func addCollider():
	var c = packed_Collider.instance()
	spital.add_child(c)
