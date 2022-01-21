extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_BoundsArea_body_entered")
	pass # Replace with function body.

# func _on_BoundsArea_body_entered(body):
#	print("BOOP")
#	Events.emit_signal("missed_shape")
#	pass # Replace with function body.


func _on_BoundsArea_body_entered(body):
	Events.emit_signal("missed_shape")
	pass # Replace with function body.
