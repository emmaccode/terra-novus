extends Node2D
func _ready():
	var sc = $World.scale
	sc.x = sc.x * .045
	sc.y = sc.y * .045
	$World.scale = sc
	var chunk_size = $World.chunk_size
	$World.generate_chunk()
	$World.generate_chunk(chunk_size, Vector2(0 + chunk_size, 0))
	$World.generate_chunk(chunk_size, Vector2(0 + chunk_size, 0 + chunk_size))
	$World.generate_chunk(chunk_size, Vector2(0, 0 + chunk_size))
