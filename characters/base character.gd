extends CharacterBody2D

const SPEED = 150
const DECAY = 420

var zoom_level = 1
const ZOOM_SPEED = .25
const ZOOM_MAX = 2
const ZOOM_MIN = .25
var facing = "r"
var z = 1
var anim = "walk-left"

func _physics_process(delta):
	z_index = abs(global_transform.origin.y / 32)
	$Panel/poslabel.text = str(global_transform.origin.x) + ", " + str(global_transform.origin.y) + ", " + str(z_index)
	# movement
	var input_vector = Vector2.ZERO
	var current_anim : String = "idle-"
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	# animate
	if input_vector == Vector2(0, -1):
		# up
		facing = "u"
	elif input_vector == Vector2(-1, 0):
		# left
		facing = "l"
	elif input_vector == Vector2(1, 0):
		# right
		facing = "r"
	elif input_vector == Vector2(0, 1):
		# down
		facing = "d"
	elif input_vector == Vector2(1, 1):
		facing = "dr"
	elif input_vector == Vector2(-1, 1):
		# down and left
		facing = "dl"
	elif input_vector == Vector2(1, -1):
		# up and right
		facing = "ur"
	elif input_vector == Vector2(-1, -1):
		facing = "ul"
		print("4")
	else:
		print(input_vector)
	# move
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity = input_vector * SPEED
	#	facing = "l"
		current_anim = "walk-"
		if Input.is_action_pressed("run"):
			velocity *= 1.33 
	else:
		velocity -= velocity.normalized() * DECAY * delta
	$animator.play(current_anim + facing)
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
	
