extends Node2D

var _pipe_spawn_timer:float = 0.0

@onready var player:Player = $Player

@onready var pipes:Node2D = $BG/pipers/Pipes
@onready var pipe_template:Node2D = $PipeTemplate

@onready var score_label:Label = $UI/ScoreLabel
@onready var camera:Camera2D = $Camera
@onready var camera_anim:AnimationPlayer = $Camera/AnimationPlayer

@onready var scrolling_bg:ParallaxLayer = $"BG/BG but real"
@onready var scrolling_fg:ParallaxLayer = $"BG/ground real"

@onready var lose_screen:Panel = $UI/LoseScreen

func update_score():
	score_label.text = str(Global.score)

func _process(delta):
	if Global.in_game_over and Input.is_action_just_pressed("jump") and lose_screen.visible:
		_on_try_again_pressed()
		
	if Global.starting_game and Input.is_action_just_pressed("jump"):
		Global.starting_game = false
		player.velocity.y = player.JUMP_VELOCITY
		
	if Global.starting_game or Global.in_game_over: return
	
	# Scrolling BG moment :3
	scrolling_bg.motion_offset.x -= Global.adjust_to_fps(3)
	scrolling_fg.motion_offset.x -= Global.adjust_to_fps(10 * Global.pipe_speed_mult)
	
	# Pipe spawning & positioning logic
	_pipe_spawn_timer += delta
	if _pipe_spawn_timer >= Global.pipe_spawn_time / Global.pipe_speed_mult:
		_pipe_spawn_timer = 0.0
		
		var pipe:Pipe = pipe_template.duplicate()
		pipe.position = Vector2(1400, randf_range(-120, 120) - 64)
		pipe.visible = true
		pipe.type = Global.get_random_pipe()
		pipes.add_child(pipe)
		
	for pipe in pipes.get_children():
		pipe.position.x -= Global.adjust_to_fps(10 * Global.pipe_speed_mult)
		if pipe.position.x <= -50:
			pipe.queue_free()
			pipes.remove_child(pipe)

func _on_pipe_passed_through(body:Node2D):
	if Global.in_game_over or not body is Player: return
	
	Global.score += 1
	
	if Global.score > Global.best_score:
		Global.best_score = Global.score
	
	update_score()
	
	Global.pipe_spawn_time = clampf(Global.pipe_spawn_time * 0.9875, 0.75, INF)

func game_over(make_player_fall:bool = true):
	if Global.in_game_over: return
	Global.pipe_speed_mult = 0.0
	Global.in_game_over = true
	Global.game_over.emit()

	camera_anim.play("shake")
	for c in camera_anim.animation_finished.get_connections():
		camera_anim.animation_finished.disconnect(c.callable)
		
	camera_anim.animation_finished.connect(func(name:StringName): bye_bye(make_player_fall))

func _on_pipe_collision(body:Node2D):
	if not body is Player: return
	game_over()
	
var player_tween:Tween
	
func bye_bye(make_player_fall:bool = true):
	if make_player_fall:
		if player_tween != null:
			player_tween.stop()
			player_tween.unreference()
			
		player_tween = create_tween()
		player_tween.set_ease(Tween.EASE_IN)
		player_tween.set_trans(Tween.TRANS_CUBIC)
		player_tween.set_parallel()
		player_tween.tween_property(player, "position:y", 600.0, 1.0)
		player_tween.tween_property(player, "rotation_degrees", 800.0, 1.0)
	
	await get_tree().create_timer(1.65 if make_player_fall else 0.5).timeout
	
	show_lose_screen()
	
func show_lose_screen():
	$UI/LoseScreen/CoolSwag.text = "%s\n%s" % [
		"Score: "+str(Global.score),
		"Best Score: "+str(Global.best_score),
	]
	lose_screen.position.y = -lose_screen.size.y
	lose_screen.visible = true
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(lose_screen, "position:y", 229.0, 0.45)

func _on_try_again_pressed():
	while pipes.get_child_count() > 0:
		var p = pipes.get_child(0)
		p.queue_free()
		pipes.remove_child(p)
		
	_pipe_spawn_timer = 0.0
	player.position = Vector2(640, 360)
	player.rotation_degrees = 0.0
	player.velocity = Vector2.ZERO
		
	Global.reset_game()
	update_score()
		
	$UI/LoseScreen/TryAgain.release_focus()
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(lose_screen, "position:y", -lose_screen.size.y, 0.45)
	tween.tween_callback(func(): lose_screen.visible = false)

func _on_touch_grass(body:Node2D):
	if not body is Player: return
	game_over(false)
