# Godot-Voxel-Game-MineCraftClone
This is a Godot project. The main purpose of this project is to get familier with the Godot game engine.

![GitHub Logo](/screenshots/screenshot1.PNG)

**Project Overview**  
To achive a decent performance and as a consequence a decent rendering distance of the world I only generate the top surface of the terrain (so the surface is created out of one single plane and not by multiple cubes (as I did it in the minecraft blender game engine project on my git hub page))
Therefore I used the godot datatool to manipulate and create single face and UV maps.

**how to test**  
If you want to test the game:
* just download or clone the repository
* than download Godot [Godot](http://www.godotengine.org/)
* start the Godot client
* scan for project and choose the downloaded unzipped folder

**features**  

Until now there are only a few things working:  
- [x] there is a randomly created voxel engine based on dictionaries
- [x] A surface mesh is generated where needed with proper UV mapping
- [x] Physic bodies are created so there is interaction with the world
- [x] Basic character controls to explore the world...

Some features which I'm planning to implement:

- [ ] you still can't build or destroy blocks. Because I have to manipulate the surface to get new blocks or to destroy a Voxel this is not as easy than just adding a cube mesh.
