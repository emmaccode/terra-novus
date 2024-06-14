extends Node2D
var saved_pos = 0
var chunk_size = 50
# Called when the node enters the scene tree for the first time.
func _ready():
	$World.generate_chunk(chunk_size)
	saved_pos = chunk_size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func generate_new_chunk():
	print(chunk_size)
func _process(delta):
	var pos = $Camera2D.position
	pos.x += 1
	pos.y += 1
	if (saved_pos * 32)- pos.x / 32 < 100 or (saved_pos * 32) - pos.y < 100:
		print("generated a chunk!")
		$World.generate_chunk(chunk_size, Vector2(saved_pos, saved_pos))
		$World.generate_chunk(chunk_size, Vector2(saved_pos - chunk_size, saved_pos))
		$World.generate_chunk(chunk_size, Vector2(saved_pos, saved_pos - chunk_size))
		saved_pos += chunk_size
	$Camera2D.position = pos
