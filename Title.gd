extends MarginContainer

onready var transitions = $Transitions
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
	$PlaySound.play()
	get_tree().change_scene("res://Main.tscn")
	pass # Replace with function body.

func _on_Credits_Button_button_down():
	get_tree().change_scene("res://Credits.tscn")
	pass # Replace with function body.
