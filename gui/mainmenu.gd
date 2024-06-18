extends Node2D
var animation_over : bool = false
var saved_pos = 0
@onready var camera : Camera2D = get_node("cam")
@onready var world = get_node("World")

func _ready():
	$AnimationPlayer.play("animate_intro")
	world.time = 2
	world.generate_full(Vector2(0, 0))
	world.generate_full(Vector2(-90, -90))
	world.generate_full(Vector2(-90, 0))
	world.start_world()
	if LOADER.VERSION[2] == '0':
		$gamegui/devmenu.visible = true
	
func _process(delta):
	if animation_over:
		var pos = camera.position
		camera.position.x += .75
		camera.position.y += .75


func _on_animation_player_animation_finished(anim_name):
	remove_child(camera)
	world.local.add_child(camera)
	animation_over = true
	camera.position.x += 1
	camera.position.y += 1
