extends RigidBody2D

signal spawn_shape

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_ShapeTimer_timeout():
	print("Print new shape")
	emit_signal("spawn_shape")
	pass

