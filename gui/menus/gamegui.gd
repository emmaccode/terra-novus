extends Control
@onready var devmenu : CanvasLayer = get_node("devmenu")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if devmenu.visible:
		$devmenu/top/fpscont/fpslabel.text = str(round(Engine.get_frames_per_second()))
		$devmenu/top/v/version.text = "lonely acres  |  v. " + LOADER.VERSION
		var curr_pos = get_viewport().get_camera_2d().position
		$devmenu/top/pos/position.text = "(" + str(curr_pos.x) + "," + str(curr_pos.y) + ")"
		var core_c = OS.get_processor_count()
		$devmenu/top/cores/cores.text = str(core_c / 2) + " (" + str(core_c) + ")"
	if Input.is_action_just_released("developer_overlay"):
		devmenu.visible = not(devmenu.visible)
