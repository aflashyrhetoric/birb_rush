extends Node2D

var X = load("res://src/Shapes/X.tscn")

onready var spawn_position = $ShapeSpawnPoint.global_position

var rng = RandomNumberGenerator.new()
var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	print(spawn_position.x, " ", spawn_position.y)
	rng.randomize()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("hit_x"):
		var children = get_tree().get_nodes_in_group("x_sprite")
		print(children)
		if children.size() > 0:
			var current_child = children.pop_back()
			current_child.queue_free()
			score += 1
			$Score.text = str(score)
	if Input.is_action_just_pressed("hit_o"):
		var children = get_tree().get_nodes_in_group("o_sprite")
		print(children)
		if children.size() > 0:
			var current_child = children.pop_back()
			current_child.queue_free()
			score += 1
			$Score.text = str(score)
	if Input.is_action_just_pressed("hit_t"):
		var children = get_tree().get_nodes_in_group("triangle_sprite")
		print(children)
		if children.size() > 0:
			var current_child = children.pop_back()
			current_child.queue_free()
			score += 1
			$Score.text = str(score)
	if Input.is_action_just_pressed("hit_s"):
		var children = get_tree().get_nodes_in_group("square_sprite")
		print(children)
		if children.size() > 0:
			var current_child = children.pop_back()
			current_child.queue_free()
			score += 1
			$Score.text = str(score)
	pass 

func _on_X_spawn_shape():
	var x_force = rng.randf_range(-75.0, 75.0)
	var y_force = rng.randf_range(-250.0, -300.0)
	var new_vel = Vector2(x_force,	 y_force)
	var shape = X.instance()
	shape.position = spawn_position
	shape.linear_velocity = new_vel
	shape.add_to_group(shape.shape_to_show)
	print("shape to show: ", shape.get_current_shape())
	$SpawnPop.play()
	add_child(shape)
	pass

