extends Node2D
@onready var biomes : TileMap = get_node("biomes")
@onready var entities : Node2D = get_node("entities")
@onready var beings : Node2D = get_node("beings")
@export var noise_height_text : NoiseTexture2D
@export var biome_noise_heighttext : NoiseTexture2D
@onready var biome_noise : Noise = biome_noise_heighttext.noise
@onready var heightmap_noise : Noise = noise_height_text.noise
var foliage = {0 : ["res://entities/foliage/trees/joshua.tscn", 
"res://entities/foliage/bushes/yucca.tscn", "res://entities/foliage/cacti/cholla.tscn"], 
1: ["res://entities/foliage/trees/pine.tscn", "res://entities/foliage/bushes/yucca.tscn"], 
2: ["res://entities/foliage/trees/pine.tscn", "res://entities/foliage/bushes/fern.tscn"], 
	3: ["res://entities/foliage/bushes/fern.tscn"], 4: []}

class Entity extends Sprite2D:
	func __init__():
		self.id = 0
		self.position = Vector2(0, 0)
		self.sprite = 0

class Plant extends Entity:
	func __init__():
		pass

class Chunk:
	func __init__(id, position):
		self.id = id
		self.position = position
		self.foliage = []
		self.entities = []
		self.beings = []
		self.player_local = []
	func load_from_data():
		pass

var foliage_densities = [1, 3, 3, 5]
var rng = RandomNumberGenerator.new()
var seed = 115
var chunk_size = 100
var chunks = {Vector2(0, 0) : []}
var at_position = Vector2(0, 0)
# tilemap info:
# the tilemap is organized in rows, so having the same `y` will yield the same 
# biome. The first will be the first colored base tile. The following 10 are 
# terrain variations
# 0 - desert
# 1 - canyons
# 2 - carniferous
# 3 - plains
# 4 - fresh water
# 5 - sea
# 6 - sand
func generate_chunk(chunk_size : int = chunk_size, from : Vector2 = at_position):
	var source_id = 2
	for x in range(from.x, from.x + chunk_size):
		rng.randomize()
		for y in range(from.y, from.y + chunk_size):
			var noise_v = heightmap_noise.get_noise_2d(x, y)
			var noisepos = Vector2(x, y)
			if noise_v > 0:
				# regular ground, or biome with variant
				var variant_ch = rng.randi_range(1, 100)
				var biome = get_biome(noisepos)
				if variant_ch > 50:
					biomes.set_cell(0, noisepos, source_id, Vector2i(rng.randi_range(1, 9), biome))
				else:
					biomes.set_cell(0, noisepos, source_id, Vector2i(0, biome))
			elif noise_v < 0.2 && noise_v > -0.07:
				# sand, connecting to water
				biomes.set_cell(0, noisepos, 2, Vector2i(0, 0))
				# water
			elif noise_v < 0.0:
				biomes.set_cell(0, noisepos, source_id, Vector2i(0, 5))
			else:
				pass

func generate_chunk_threaded(chunk_size : int = chunk_size, from : Vector2 = Vector2(0, 0)):
	var thread = LOADER.get_open_thread()
	at_position = from
	if type_string(typeof(thread)) == "Object":
		thread.start(generate_chunk)
	else:
		generate_chunk(chunk_size, from)

func load_chunk():
	pass

func spawn_entities(chunk : Chunk):
	for x in chunk_size:
		for y in chunk_size:
			current_biome = get_biome()
			make_foliage(Vector2(x, y), biome)

func spawn_beings():
	pass

func make_foliage(vec : Vector2, biome : int):
	var variant_ch = rng.randi_range(1, 100)
	var adequate_foliage = foliage[biome]
	if variant_ch < foliage_densities[biome] and len(adequate_foliage) > 0:
		var sel_foliage = rng.randi_range(0, len(adequate_foliage) - 1)
		var fol_scene = load(adequate_foliage[sel_foliage])
		var instance = fol_scene.instantiate()
		entities.add_child(instance)
		var ypos = (vec.y * 32)
		instance.z_index = (ypos + (instance.texture.get_size().y * (instance.scale.y * .25))) / 32
		instance.global_transform.origin.x = vec.x * 32
		instance.global_transform.origin.y = ypos
	else:
		return
	
func get_biome(vec : Vector2):
	var biomeinf = []
	var max = .78
	var noise_v = abs(biome_noise.get_noise_2d(vec.x, vec.y))
	if noise_v < max * .6:
		return(0)
	elif noise_v < max * .8:
		return(3)
	elif noise_v < max * .95:
		return(1)
	else:
		return(2)
		
func delete_chunk_by_position(pos : Vector2):
	pass
	
func delete_chunk_by_id(id : int):
	pass
# Called when the node enters the scene tree for the first time.
func _ready():
	biome_noise.seed = rng.randi_range(1, 1000)
	heightmap_noise.seed = rng.randi_range(1, 1000)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
