extends CharacterBody2D

const SPEED = 150
const DECAY = 420

var zoom_level = 1
const ZOOM_SPEED = .25
const ZOOM_MAX = 2
const ZOOM_MIN = .25
var facing = "r"
var z = 1

func _physics_process(delta):
	z_index = abs(global_transform.origin.y / 32)
	$Panel/poslabel.text = str(global_transform.origin.x) + ", " + str(global_transform.origin.y) + ", " + str(z_index)
	# movement
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity = input_vector * SPEED
		if Input.is_action_pressed("run"):
			velocity *= 1.33 
	else:
		velocity -= velocity.normalized() * DECAY * delta
	# Zooming
	var curr_zoom = $playercamera.zoom
	if Input.is_action_just_released("zoom_out") and zoom_level > ZOOM_MIN:
		zoom_level -= ZOOM_SPEED
		curr_zoom -= Vector2(ZOOM_SPEED, ZOOM_SPEED)
		$playercamera.zoom = curr_zoom
	elif Input.is_action_just_released("zoom_in") and zoom_level < ZOOM_MAX:
		zoom_level += ZOOM_SPEED
		curr_zoom += Vector2(ZOOM_SPEED, ZOOM_SPEED)
		$playercamera.zoom = curr_zoom
	move_and_slide()

func animate(action):
	pass
	
