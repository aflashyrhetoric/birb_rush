extends RigidBody2D

var shape_to_show = ""

func _init():
	randomize()
	shape_to_show = get_random_shape() + "_sprite"
	
func set_specific_shape(shape):
	if shape != null: 
		shape_to_show = shape

# Called when the node enters the scene tree for the first time.
func _ready():
	var shape = get_node(shape_to_show)
	shape.visible = true
	pass # Replace with function body.

func get_current_shape():
	return shape_to_show

func get_random_shape():
	var _shapes = ["o", "x", "square", "triangle"]
	var random_shape = _shapes[randi() % _shapes.size()]
	return random_shape
