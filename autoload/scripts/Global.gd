extends Node

signal game_over

enum PIPE_TYPE {
	NORMAL,
	MOVING,
	SPEED_BOOST,
	ICE
}

const PIPE_DATA:Dictionary = {
	PIPE_TYPE.NORMAL: {"color": Color("56f0a1"), "chance": 100.0},
	PIPE_TYPE.MOVING: {"color": Color("f05656"), "chance": 50.0},
	PIPE_TYPE.SPEED_BOOST: {"color": Color("f0b056"), "chance": 35.0},
	PIPE_TYPE.ICE: {"color": Color("56f0f0"), "chance": 22.0},
}

var score:int = 0
var best_score:int = 0

var starting_game:bool = true
var effects_applied:Dictionary = {
	"speed": false
}
var pipe_spawn_time:float = 1.2

var in_game_over:bool = false
var pipe_speed_mult:float = 1.0

func _ready():
	best_score = Settings.get_setting("best score")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("saved settings!")
		Settings.set_setting("best score", best_score)
		Settings.flush()
		
func reset_game():
	in_game_over = false
	starting_game = true
	
	pipe_spawn_time = 1.2
	pipe_speed_mult = 1.0
	
	effects_applied.speed = false
	
	score = 0

func random_bool(chance:float = 100.0):
	return randf_range(0.0, 100.0) < clampf(chance, 0.0, INF)
	
func get_random_pipe() -> PIPE_TYPE:
	var pipe:PIPE_TYPE = PIPE_DATA.keys()[randi_range(1, PIPE_DATA.size()-1)]
	var do_custom:bool = random_bool(PIPE_DATA[pipe].chance)
	return pipe if do_custom else PIPE_TYPE.NORMAL

func adjust_to_fps(num:float):
	return get_process_delta_time() * 60 * num
