extends Node2D
var saved_pos = Vector2(0, 0)
var derender_at = 0
var len = 6
var chunk_size = 50
# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/World.chunk_size = chunk_size
	$gamegui/devmenu.visible = true
	$Panel/World.start_world()
	$Panel/World/global_tick.wait_time = 0.0000001
	$Panel/World.time = 1.5
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func run_render_test():
	$Timer.start()


func _on_timer_timeout():
	var chk1 = $Panel/World.generate_full(saved_pos)
	saved_pos.x += chunk_size
	if saved_pos.x / chunk_size == len:
		saved_pos.y += chunk_size
		saved_pos.x = 0
	if saved_pos.y / chunk_size > len:
		$Timer.stop()
		saved_pos = Vector2(0, 0)

func start_press():
	run_render_test()



func _on_button_2_pressed():
	derender_at = len($Panel/World.chunks) - 1
	$derender.start()


func _on_derender_timeout():
	if derender_at == -1:
		$derender.stop()
		return
	$Panel/World.derender_chunk_by_position($Panel/World.chunks[derender_at].position)
	derender_at -= 1
