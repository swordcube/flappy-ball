extends Node2D
class_name Pipe

var sin_time:float = 0.0

var og_y:float = 0.0
var type:Global.PIPE_TYPE = Global.PIPE_TYPE.NORMAL

func _ready():
	og_y = position.y
	modulate = Global.PIPE_DATA[type].color

func _process(delta):
	if Global.in_game_over: return
	
	match type:
		Global.PIPE_TYPE.MOVING:
			position.y = og_y + (sin(sin_time * 2) * 100)
			
		Global.PIPE_TYPE.ICE:
			position.y = og_y + (sin(sin_time * (sin(sin_time * 3.5) * 1)) * 100)
			
		_: pass
		
	sin_time += delta

func _on_pipe_pass_through(body):
	if Global.in_game_over or not body is Player: return
	
	match type:
		Global.PIPE_TYPE.SPEED_BOOST:
			apply_speed_boost()
			
func apply_speed_boost():
	if Global.effects_applied.speed: return
	
	Global.effects_applied.speed = true
	get_tree().create_tween().tween_property(Global, "pipe_speed_mult", 1.35, 1.5)
	get_tree().create_timer(5.0).timeout.connect(func():
		if Global.in_game_over: return
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(Global, "pipe_speed_mult", 1.0, 1.5)
		tween.tween_callback(func(): Global.effects_applied.speed = false)
	)
