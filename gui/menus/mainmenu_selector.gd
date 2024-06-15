extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$anims.play("animate_menu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_worlds_button_pressed():
	$canvas/menu_selector/popinm.visible = true
	$canvas/menu_selector/popinm/worlds.visible = true
	$anims.play("open_main")
