extends Control
const VERSION = "0.0.1"
const max_threads = 3
var THREADS = []
var load_path = ""
func _ready():
	var total_threads : int = OS.get_processor_count() * 2
	for thread in max_threads:
		THREADS.append(Thread.new())
		
func quick_load(path):
	load_path = path
	$overlay/animator.play("fade_out")
	
	
func get_open_thread():
	for thread in THREADS:
		if not thread.is_alive():
			return(thread)
	return(-1)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animator_animation_finished(anim_name):
	if anim_name == "fade_out":
		get_tree().change_scene_to_file(load_path)
		$overlay/animator.play("fade_in")
		return
	$overlay/animator.play("nil")
