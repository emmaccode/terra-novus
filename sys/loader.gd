extends Control
const VERSION = "0.0.1"
const max_threads = 3
var THREADS = []
var load_path = ""
var last_scene = 0
var BIOMES = []
# 1: , 
#2: ["res://entities/foliage/trees/pine.tscn", ], 
#	3: ["res://entities/foliage/bushes/fern.tscn"], 4: []}
class Biome:
	var name = ""
	var foliage = []
	var entities = []

class Entity extends Sprite2D:
	func _ready():
		self.id = 0
		self.position = Vector2(0, 0)
		self.sprite = 0
		
class Item extends Entity:
	pass
class Plant extends Entity:
	func _ready():
		pass
		
func _ready():
	var total_threads : int = OS.get_processor_count() * 2
	for thread in max_threads:
		THREADS.append(Thread.new())
	var desert_b = Biome.new()
	desert_b.name = "Desert"
	desert_b.foliage = ["res://entities/foliage/trees/joshua.tscn", 
		"res://entities/foliage/bushes/yucca.tscn", "res://entities/foliage/cacti/cholla.tscn"]
	desert_b.entities = ["res://entities/landscape/rock1.tscn", "res://entities/landscape/rock2.tscn"]
	BIOMES.append(desert_b)
	var pine_b = Biome.new()
	pine_b.name = "Pine Forest"
	pine_b.foliage = ["res://entities/foliage/trees/pine.tscn", "res://entities/foliage/bushes/yucca.tscn"]
	BIOMES.append(pine_b)
	var carniferous_b = Biome.new()
	carniferous_b.name = "Carniferous Forest"
	carniferous_b.foliage = ["res://entities/foliage/trees/pine.tscn", "res://entities/foliage/bushes/fern.tscn"]
	BIOMES.append(carniferous_b)
	var plains_b = Biome.new()
	carniferous_b.name = "Plains"
	plains_b.foliage = ["res://entities/foliage/bushes/fern.tscn", "res://entities/foliage/bushes/deciduous-bush.tscn", 
	"res://entities/foliage/bushes/tallgrass.tscn"]
	BIOMES.append(plains_b)
func quick_load(path, node):
	load_path = path
	last_scene = node
	$overlay/animator.play("fade_out")
	
func world_load(w : Node):
	pass
	
func get_open_thread():
	for thread in THREADS:
		if not thread.is_started():
			return(thread)
	return(-1)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animator_animation_finished(anim_name):
	if anim_name == "fade_out":
		get_tree().root.add_child(load(load_path).instantiate())
		get_tree().root.remove_child(last_scene)
		$overlay/animator.play("fade_in")
		return
	$overlay/animator.play("nil")
