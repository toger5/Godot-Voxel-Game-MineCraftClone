extends Spatial

func _ready():
	set_process(true)
func _process(delta):
	if Input.is_key_pressed(KEY_L):

		remove_child(get_child(0))
