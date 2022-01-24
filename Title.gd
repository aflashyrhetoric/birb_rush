extends MarginContainer

var main_scene = preload("res://Main.tscn").instance()

# DEBUGGING VALUE
var skip_title = false

func _ready():
	$AnimationPlayer.play()
	if skip_title:
		_on_TextureButton_button_down()
	pass

func _on_TextureButton_button_down():
	$TitleSong.stop()
	get_tree().change_scene("res://Main.tscn")
	pass # Replace with function body.
