extends Node2D
var chunk_size = 150

# Called when the node enters the scene tree for the first time.
func _ready():
	var scene = load("res://characters/base character.tscn")
	var player_instance = scene.instantiate()
	player_instance.global_transform.origin.x = 50
	player_instance.global_transform.origin.y = 50
	$World/local.add_child(player_instance)
	$World.start_world()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
