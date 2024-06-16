extends Node2D
var saved_pos = 0
@onready var camera : Camera2D = Camera2D.new()

func _ready():
	$World/local.add_child(camera)
	$World.start_world()
	camera.enabled = true
	camera.position.y = 40 * 32
	camera.position.x = 40 * 32
	if LOADER.VERSION[2] == '0':
		$gamegui/devmenu.visible = true
	
func _process(delta):
	var pos = camera.position
	camera.position.x += .75
