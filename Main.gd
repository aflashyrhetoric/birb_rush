extends Node2D

# TODO
# - consecutive shapes result in additional points
# - animations
# - 20/20 misses counted, then failure on the 21st miss
# - FEATURE: as the shapes get extremely close to the edge of the boundary, they start to get "rough" around the edges? glitch effect?
# - game phases:
#	- slow x 4
#   - groups x 5
#   - rapidfire x 40
#   - groups x 5 with 1.5x the amount
#   - rapid fire groups (3 at a time) x 5
#   - ultra rapid fire 
#   - groups of 10 with lower gravity
#

var X = load("res://src/Shapes/X.tscn")

onready var spawn_position = $ShapeSpawnPoint.global_position

var rng = RandomNumberGenerator.new()
var score = 0
var misses = 0
var total_rendered_shapes = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("missed_shape", self, "_on_X_missed_shape")
	print(spawn_position.x, " ", spawn_position.y)
	rng.randomize()
	pass # Replace with function body.
	
# 
func check_for_hit(shape_name):
	var children = get_tree().get_nodes_in_group(shape_name)
	if children.size() > 0:
		var current_child = children.pop_back()
		current_child.queue_free()
		score += 1
		$Score.text = str(score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("hit_x"):
		check_for_hit("x_sprite")
	if Input.is_action_just_pressed("hit_o"):
		check_for_hit("o_sprite")
	if Input.is_action_just_pressed("hit_t"):
		check_for_hit("triangle_sprite")
	if Input.is_action_just_pressed("hit_s"):
		check_for_hit("square_sprite")
	pass 

func _on_X_spawn_shape():
	var x_force = rng.randf_range(-75.0, 75.0)
	var y_force = rng.randf_range(-250.0, -300.0)
	var new_vel = Vector2(x_force,	 y_force)
	var shape = X.instance()
	total_rendered_shapes += 1
	shape.position = spawn_position
	shape.linear_velocity = new_vel
	shape.add_to_group(shape.shape_to_show)
	# print("shape to show: ", shape.get_current_shape())
	$SpawnPop.play()
	add_child(shape)
	pass

func _on_X_missed_shape():
	misses += 1
	$Misses.text = str(misses) + "/20"
	print("missed a shape!")
	if(misses >= 20):
		$ShapeTimer.stop()
		print("Game Over!")	
	pass # Replace with function body.


func _on_BoundsArea_body_entered(body):
#	Events.emit_signal("missed_shape")
	print("body entered from main")
	_on_X_missed_shape()
	pass # Replace with function body.
