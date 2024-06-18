extends Node2D
func _ready():
	var sc = $Panel/World.scale
	sc.x = sc.x * .045
	sc.y = sc.y * .045
	var WORLD = $Panel/World
	WORLD.scale = sc
	WORLD.world_name = "gondwana"
	$Panel/wname.text = WORLD.world_name
	$Panel/wseed.text = str(WORLD.rng.seed)
	$Panel/wtime.text = str(WORLD.time)
	$Panel/World/daynight.visible = false
	$Panel/World.chunk_size = 135
	$Panel/World.generate_chunk(Vector2(0, 0))
