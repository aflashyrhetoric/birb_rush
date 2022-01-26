extends Node2D

# TODO
# - A plant that loses petals as shapes are missed
# - Victory screen
# - Persistent high score
# - Figure out this theme thing for fonts
# - Make missed shapes fade out rapidly
# - Add score milestone reward animations

var Shape = load("res://src/Shapes/Shape.tscn")

onready var spawn_position = $ShapeSpawnPoint.global_position
onready var initial_score_diff_position = $ScoreDiff.rect_position

var rng = RandomNumberGenerator.new()
var score = 0
var score_display = 0
var last_shape_hit = {"type": "", "multiplier": 1}
var misses = 0
var current_level = 0  # 1st level
var level_configs = []
var cfg

var spawn_generation = 1


func initialize_levels():
	level_configs.push_back(
		{
			"time_between": 2,
			"shapes_per_spawn": 1,
			"rounds": 5,
			"delay_before_next_level": 2,
			"only_shape": ""
		}
	)
	level_configs.push_back(
		{
			"time_between": 3,
			"shapes_per_spawn": 5,
			"rounds": 5,
			"delay_before_next_level": 2,
			"only_shape": ""
		}
	)
	level_configs.push_back(
		{
			"time_between": 0.4,
			"shapes_per_spawn": 1,
			"rounds": 40,
			"delay_before_next_level": 2,
			"only_shape": ""
		}
	)
	level_configs.push_back(
		{
			"time_between": 4.2,
			"shapes_per_spawn": 9,
			"rounds": 5,
			"delay_before_next_level": 2,
			"only_shape": ""
		}
	)
	level_configs.push_back(
		{
			"time_between": 1.5,
			"shapes_per_spawn": 3,
			"rounds": 5,
			"delay_before_next_level": 2,
			"only_shape": ""
		}
	)
	level_configs.push_back(
		{
			"time_between": 0.3,
			"shapes_per_spawn": 1,
			"rounds": 30,
			"delay_before_next_level": 2,
			"only_shape": ""
		}
	)
	level_configs.push_back(
		{
			"time_between": 5,
			"shapes_per_spawn": 10,
			"rounds": 5,
			"delay_before_next_level": 5,
		}
	)


func _init():
	initialize_levels()
	cfg = level_configs[current_level]
	pass


# Called when the node enters the scene tree for the first time.
func _ready():

	Events.connect("score_updated", self, "run_score_diff_animation")
	Events.connect("missed_shape", self, "_on_X_missed_shape")
	Events.connect("spawn_shape", self, "_on_X_spawn_shape")
	$AnimationPlayer.play("FadeIn")
	yield($AnimationPlayer, "animation_finished")
	rng.randomize()
	
	pass  # Replace with function body.


#
func check_for_hit(shape_name):
	var children = get_tree().get_nodes_in_group(shape_name)
	if children.size() > 0:
		var current_child = children.pop_front()
		current_child.queue_free()
		$Hit.play()
		if last_shape_hit.type == shape_name:
			last_shape_hit.multiplier += 1
		else:
			last_shape_hit.type = shape_name
			last_shape_hit.multiplier = 1
		var amt_to_add = 100 * last_shape_hit.multiplier
		Events.emit_signal("score_updated", amt_to_add)
		score += amt_to_add


func run_score_diff_animation(score_points_gained):
	var SCORE_DIFF_ANIM_DURATION = 0.5
	var pos = $ScoreDiff.rect_position
	var new_pos = pos
	new_pos.y += 10
	$ScoreDiff.text = "+ " + str(score_points_gained)
	$Tween.interpolate_property(
		$ScoreDiff,
		"rect_position",
		pos,
		new_pos,
		SCORE_DIFF_ANIM_DURATION,
		$Tween.TRANS_BACK,
		$Tween.EASE_OUT
	)
	$Tween.interpolate_property(
		$ScoreDiff, "modulate:a", 1, 0, SCORE_DIFF_ANIM_DURATION, $Tween.TRANS_BACK, $Tween.EASE_OUT
	)
	$Tween.start()


func update_score_display():
	var SCORE_DIVISION_AMT = 20
	var score_difference = score - score_display
	var normalized_score_increment = score_difference / SCORE_DIVISION_AMT
	var amount_to_add = 0
	if score_difference < 20:
		amount_to_add = score_difference
	else:
		amount_to_add = normalized_score_increment

	score_display += amount_to_add

	$Score.text = str(floor(score_display))
	pass


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

	if score_display < score:
		update_score_display()
		
	if Input.is_action_just_pressed("ui_cancel") and get_tree().paused == false:
		print("pause")
		pause_game()
		return
	pass


func create_shape():
	cfg = level_configs[current_level]
	var x_force = rng.randf_range(-150.0, 150.0)
	var y_force = rng.randf_range(-500.0, -700.0)
	var new_vel = Vector2(x_force, y_force)
	var shape = Shape.instance()
	
	if(cfg.only_shape != null and cfg.only_shape.length() > 0):
		shape.set_specific_shape(cfg.only_shape)

#	Randomize the spawn point a little to get some more variance in spawn area
	var x_spawn_offset = rng.randf_range(-40, 40)
	var y_spawn_offset = rng.randf_range(-20, 20)
	var adj_spawn_point = spawn_position
	adj_spawn_point.x += x_spawn_offset
	adj_spawn_point.y += y_spawn_offset

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
	
#	0 5
	if current_level == level_configs.size():
		game_over()
		return
		

	cfg = level_configs[current_level]

	# Trigger next round immediately
	_on_X_spawn_shape()
	$ShapeSpawnTimer.wait_time = cfg.time_between
	$ShapeSpawnTimer.start()
	pass


func _on_X_spawn_shape():
	var shapes_to_spawn = []

	if spawn_generation >= cfg.rounds:
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
	$Buttons.visible = false
	$Again.visible = true
	pass

func _on_X_missed_shape(body_that_missed):
	misses += 1
	$Misses.text = str(misses) + "/20"
	body_that_missed.queue_free()
	var random = rng.randf_range(1, 7)
	if floor(random) == 1:
		print("MISS")
		$OhYouSuck.play()
	else:
		$MissedSound.play()
	if misses >= 20:
		game_over()
	pass  # Replace with function body.


func _on_ShapeTimer_timeout():
	Events.emit_signal("spawn_shape")
	pass  # Replace with function body.48


func _on_BreakTimer_timeout():
#	print("Break timer timed out")
	$BreakTimer.stop()
	advance_level()
	pass  # Replace with function body.


func _on_Tween_tween_completed(object, key):
	$ScoreDiff.text = ""
	$ScoreDiff.rect_position = initial_score_diff_position
	pass  # Replace with function body.

func kill_all_shapes():
	var all_shapes = get_tree().get_nodes_in_group("all_shapes")
	for shape in all_shapes:
		shape.queue_free()
	pass

func restart_game():
	get_tree().paused = false
	kill_all_shapes()
	score = 0
	score_display = 0
	last_shape_hit = {"type": "", "multiplier": 1}
	misses = 0
	current_level = 0  # 1st level
	level_configs = []
	$Buttons.visible = true
	$Again.visible = false
	$Misses.text = "0/20"
	$ShapeSpawnTimer.start()
	pass

func _on_Again_button_down():
	get_tree().reload_current_scene()
	get_tree().paused = false
	pass # Replace with function body.
	
func toggle_visibility_of_pause_gui(isVisible):
	$Buttons.visible = !isVisible
	$Pause.visible = !isVisible
	$Resume.visible = isVisible
	$QuitToMainMenu.visible = isVisible

func unpause_game():
	get_tree().paused = false
	toggle_visibility_of_pause_gui(false)
	false

func pause_game():
	get_tree().paused = true
	toggle_visibility_of_pause_gui(true)
	pass

func _on_Resume_button_down():
	unpause_game()
	pass # Replace with function body.

func _on_Pause_button_down():
	pause_game()
	pass # Replace with function body.


func _on_QuitToMainMenu_button_down():
	get_tree().change_scene("res://Title.tscn")
	get_tree().paused = false
	pass # Replace with function body.
