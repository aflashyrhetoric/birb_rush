extends RigidBody2D

signal spawn_shape


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var s = get_shape() + "_sprite"
	var shape_to_show = get_node(s)
	print("Print new shape", " ", s)
	shape_to_show.visible = true
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_shape():
	var _shapes = ["o", "x", "square", "triangle"]
	var random_shape = _shapes[randi() % _shapes.size()]
	return random_shape

func _on_ShapeTimer_timeout():
	emit_signal("spawn_shape")
	pass

