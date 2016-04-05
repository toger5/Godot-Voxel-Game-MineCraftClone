extends Node

func vec_to_int(v):
	return [int(v.x),int(v.y),int(v.z)]
	
func int_to_vec(i):
	return Vector3(i[0],i[1],i[2])

func get_chunc_by_coord(cd,pos):
	var correctChunkPos = Vector2(floor(pos.x/16.0)*16, floor(pos.z/16.0)*16)
	if correctChunkPos in cd:
		return cd[correctChunkPos]
	else:
		print("chunk ",pos," is not in chunk_dict")
	return 0