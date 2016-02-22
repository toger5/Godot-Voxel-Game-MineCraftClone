extends MeshInstance

export(FixedMaterial) var material = null

func _ready():
	var up = Vector3(0, 1, 0)

	var surface = SurfaceTool.new()
	surface.begin(VisualServer.PRIMITIVE_TRIANGLES)

	if(material):
		surface.set_material(material)

    #Generate a surface
0	surface.add_vertex(Vector3(1, 0, -1))
1	surface.add_vertex(Vector3(1, 0, 1))
2	surface.add_vertex(Vector3(-1, 0, -1))
	
1	surface.add_vertex(Vector3(1, 0, 1))
3	surface.add_vertex(Vector3(-1, 0, 1))
2	surface.add_vertex(Vector3(-1, 0, -1))

	var mesh = surface.commit()
    #Modify the surface
	var datatool = MeshDataTool.new()
	datatool.create_from_surface(mesh, 0)
	datatool.set_vertex(0, datatool.get_vertex(0) * 1)
	datatool.set_vertex(1, datatool.get_vertex(1) * 1)
	datatool.set_vertex(2, datatool.get_vertex(2) * 1)
	datatool.set_vertex(3, datatool.get_vertex(3) * 1)
	print(datatool.get_vertex_count())

#	mesh.surface_remove(0) #Remove the old one
	datatool.commit_to_surface(mesh)

	(mesh)