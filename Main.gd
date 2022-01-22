extends Node2D

# TODO
# - Animation for "+200" points on every successful hit
# - Animation for score counting up, instead of jumping to the new score
# - consecutive shapes result in additional points
# - animations
# - add collision sound
# - on game over, freeze all shapes, turn them gray, erase them
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

var Shape = load("res://src/Shapes/Shape.tscn")

onready var spawn_position = $ShapeSpawnPoint.global_position

var rng = RandomNumberGenerator.new()
var score = 0
var score_display = 0
var last_shape_hit = {
	"type": "",
	"multiplier": 1
}
var misses = 0
var current_level = 0 # 1st level
var level_configs = []
var cfg

var spawn_generation = 1

func initialize_levels():
	level_configs.push_back({
		"time_between": 2,
		"shapes_per_spawn": 1,
		"rounds": 5,
		"delay_before_next_level": 2,
	})
	level_configs.push_back({
		"time_between": 3,
		"shapes_per_spawn": 5,
		"rounds": 5,
		"delay_before_next_level": 2,
	})
	level_configs.push_back({
		"time_between": 0.4,
		"shapes_per_spawn": 1,
		"rounds": 40,
		"delay_before_next_level": 2,
	})
	level_configs.push_back({
		"time_between": 4.2,
		"shapes_per_spawn": 9,
		"rounds": 5,
		"delay_before_next_level": 2,
	})
	level_configs.push_back({
		"time_between": 1.5,
		"shapes_per_spawn": 3,
		"rounds": 5,
		"delay_before_next_level": 2,
	})
	level_configs.push_back({
		"time_between": 0.3,
		"shapes_per_spawn": 1,
		"rounds": 30,
		"delay_before_next_level": 2,
	})
	level_configs.push_back({
		"time_between": 5,
		"shapes_per_spawn": 10,
		"rounds": 5,
		"delay_before_next_level": 5,
	})

func _init():
	initialize_levels()
	cfg = level_configs[current_level]
	pass
	

# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("missed_shape", self, "_on_X_missed_shape")
	Events.connect("spawn_shape", self, "_on_X_spawn_shape")
	rng.randomize()
	pass # Replace with function body.
	
# 
func check_for_hit(shape_name):
	var children = get_tree().get_nodes_in_group(shape_name)
	if children.size() > 0:
		var current_child = children.pop_front()
		current_child.queue_free()
		
		if(last_shape_hit.type == shape_name):
			last_shape_hit.multiplier += 1
		else:
			last_shape_hit.type = shape_name
			last_shape_hit.multiplier = 1
			
		score += 100 * last_shape_hit.multiplier
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
	
func create_shape():
	var x_force = rng.randf_range(-50.0, 50.0)
	var y_force = rng.randf_range(-250.0, -320.0)
	var new_vel = Vector2(x_force, y_force)
	var shape = Shape.instance()
	
#	Randomize the spawn point a little to get some more variance in spawn area
	var x_spawn_offset = rng.randf_range(-40, 40)
	var y_spawn_offset = rng.randf_range(-20, 20)
	spawn_position.x += x_spawn_offset
	spawn_position.y += y_spawn_offset
	
#	Do we need this?
	shape.contact_monitor = true
	shape.contacts_reported = 1
	shape.position = spawn_position
	shape.linear_velocity = new_vel
	shape.add_to_group(shape.shape_to_show)
	shape.add_to_group("all_shapes")
	return shape
	pass

func advance_level():
#	Reset per-generation variables
	spawn_generation = 1
	current_level += 1
	
	cfg = level_configs[current_level]
	
	# Trigger next round immediately
	_on_X_spawn_shape() 
	$ShapeSpawnTimer.wait_time = cfg.time_between
	$ShapeSpawnTimer.start()
	pass

func _on_X_spawn_shape():
	var shapes_to_spawn = []
	
	if spawn_generation == cfg.rounds:
		$ShapeSpawnTimer.stop()
		print("End of gen ", cfg.delay_before_next_level)
		$BreakTimer.wait_time = cfg.delay_before_next_level
		$BreakTimer.start()
		pass

#	Create the shapes per generation
	for shape in range(cfg.shapes_per_spawn):
		add_child(create_shape())	
	
	$SpawnPop.play()
	
	spawn_generation += 1
	pass

func game_over():
	get_tree().paused = true
	$ShapeSpawnTimer.stop()
	print("Game Over!")	
	pass

func _on_X_missed_shape():
	misses += 1
	$Misses.text = str(misses) + "/20"
	print("missed a shape!")
	if(misses >= 20):
		game_over()
	pass # Replace with function body.


func _on_ShapeTimer_timeout():
	print("Tick")
	Events.emit_signal("spawn_shape")
	pass # Replace with function body.48


func _on_BreakTimer_timeout():
	print("Break timer timed out")
	$BreakTimer.stop()
	advance_level()
	pass # Replace with function body.
