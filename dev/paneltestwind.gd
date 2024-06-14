extends Sprite2D

var set_position = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Panel/cont/pos.text = str(global_transform.origin.x) + "," + str(global_transform.origin.y)
	$Panel/cont/zindex.text = str(z_index)
