extends CanvasLayer

@onready var label:Label = $Label

func _physics_process(delta):
	label.text = "FPS: %s" % str(Engine.get_frames_per_second())
