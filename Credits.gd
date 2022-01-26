extends MarginContainer

func _ready():
	$AnimationPlayer.play()
	pass

func _on_Return_button_down():
	get_tree().change_scene("res://Title.tscn")
	pass # Replace with function body.
