extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.position = Vector2(0, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Panel/Label.text = str(z_index)
	$ColorRect.position = Vector2(0, 0)
