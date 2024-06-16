extends Node2D
@onready var biomes : TileMap = get_node("biomes")
@onready var entities : Node2D = get_node("entities")
@onready var beings : Node2D = get_node("beings")
@onready var local : Node2D = get_node("local")
@export var noise_height_text : NoiseTexture2D
@export var biome_noise_heighttext : NoiseTexture2D
@export var darkscale : GradientTexture1D
@onready var biome_noise : Noise = biome_noise_heighttext.noise
@onready var heightmap_noise : Noise = noise_height_text.noise
@export var derender_distance: int = 2000  # Adjust this value as needed
var foliage_densities = [4, 7, 10, 11]
var rng = RandomNumberGenerator.new()
var chunk_size = 90
var spawn_queue = []
var world_name = ""
var time = 1.35
var chunks = []
var loaded_chunks = []
var water_height = -0.5
var spawn_rate = 80
var at_position = Vector2(0, 0)
var active_chunk = 0

class Chunk:
	var id : int
	var position : Vector2
	var foliage = []
	var entities = []
	var beings = []
	func _ready():
		self.foliage = []
		self.entities = []
		self.beings = []
		self.player_local = []
	func load_from_data():
		pass

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

func generate_biome(noisepos : Vector2):
	var noise_v = heightmap_noise.get_noise_2d(noisepos.x, noisepos.y)
	if noise_v > water_height + .25:
		# regular ground, or biome with variant
		var variant_ch = rng.randi_range(1, 100)
		var biome = get_biome(noisepos)
		if variant_ch > 50:
			biomes.set_cell(0, noisepos, 2, Vector2i(rng.randi_range(1, 9), biome))
		else:
			biomes.set_cell(0, noisepos, 2, Vector2i(0, biome))
	elif noise_v > water_height:
		# sand, connecting to water
		biomes.set_cell(0, noisepos, 2, Vector2i(0, 0))
			# water
	else:
		biomes.set_cell(0, noisepos, 2, Vector2i(0, 5))
	
func generate_chunk(chunk_size : int = chunk_size, from : Vector2 = at_position):
	print("generated chunk! ", from.x, ", ", from.y)
	var source_id = 2
	for x in range(from.x, from.x + chunk_size):
		for y in range(from.y, from.y + chunk_size):
			generate_biome(Vector2(x, y))
	var ck: Chunk = Chunk.new()
	ck.id = len(chunks)
	ck.position = from
	chunks.append(ck)
	return(ck)

func generate_full(from: Vector2 = at_position):
	var to_x = from.x + chunk_size
	var to_y = from.y + chunk_size
	var current_chunk: Chunk = Chunk.new()
	current_chunk.position = from
	chunks.append(current_chunk)
	for x in range(from.x, to_x):
		for y in range(from.y, to_y):
			var current_position : Vector2 = Vector2(x, y)
			generate_biome(current_position)
			make_foliage(current_chunk, current_position)
			make_entity(current_chunk, current_position)
	print(current_chunk.position)
	return(current_chunk)
			

func get_chunk_by_id(id : int):
	chunks[id - 1]

func get_chunk_by_position(pos : Vector2):
	for chunk in chunks:
		if chunk.position == pos:
			return(chunk)

func generate_chunk_threaded(chunk_size : int = chunk_size, from : Vector2 = Vector2(0, 0)):
	var thread = LOADER.get_open_thread()
	at_position = from
	if type_string(typeof(thread)) == "Object":
		thread.start(generate_chunk)
		return(thread.wait_to_finish())
	else:
		generate_chunk(chunk_size, from)

func load_chunk():
	pass

func make_foliage(chunk: Chunk, vec : Vector2, spawn = true):
	var variant_ch = rng.randi_range(1, 100)
	var biome = get_biome(vec)
	var adequate_foliage = LOADER.BIOMES[biome].foliage
	if variant_ch < foliage_densities[biome] and len(adequate_foliage) > 0 and heightmap_noise.get_noise_2d(vec.x, vec.y) > water_height + .25:
		var sel_foliage = rng.randi_range(0, len(adequate_foliage) - 1)
		var fol_scene = load(adequate_foliage[sel_foliage])
		var instance = fol_scene.instantiate()
		chunk.entities.append(instance)
		var ypos = (vec.y * 32)
		instance.z_index = abs(ypos) / 32
		instance.global_transform.origin.x = vec.x * 32
		instance.global_transform.origin.y = ypos
		if spawn:
			spawn_queue.append(instance)

func generate_foliage(chunk : Chunk = active_chunk, spawn = true):
	for x in range(chunk.position.x, chunk.position.x + chunk_size):
		for y in range(chunk.position.y, chunk.position.y + chunk_size):
			var noise_v = heightmap_noise.get_noise_2d(x, y)
			if noise_v > water_height + .25:
				make_foliage(chunk, Vector2(x, y), spawn)
	
func generate_foliage_threaded(chunk : Chunk):
	var thread = LOADER.get_open_thread()
	active_chunk = chunk
	if type_string(typeof(thread)) == "Object":
		thread.start(generate_foliage)
	else:
		generate_foliage(chunk)
	
func spawn_foliage(chunk : Chunk):
	for instance in chunk.entities:
		entities.add_child(instance)

func make_entity(chunk: Chunk, vec : Vector2, spawn = true):
	var variant_ch = rng.randi_range(1, 110)
	var biome_ents = LOADER.BIOMES[get_biome(vec)].entities
	if variant_ch < 2 and len(biome_ents) > 0:
		var sel_ent = rng.randi_range(0, len(biome_ents) - 1)
		var fol_scene = load(biome_ents[sel_ent])
		var instance = fol_scene.instantiate()
		chunk.entities.append(instance)
		var ypos = (vec.y * 32)
		instance.z_index = abs(ypos) / 32
		instance.global_transform.origin.x = vec.x * 32
		instance.global_transform.origin.y = ypos
		if spawn:
			spawn_queue.append(instance)

func generate_entities(chunk : Chunk, spawn = true):
	for x in chunk_size:
		for y in chunk_size:
			var pos = Vector2(x, y)
			make_entity(chunk, pos, spawn)

func spawn_beings():
	pass
	
func derender_chunk_by_position(pos: Vector2):
	print("derendered chunk! ", pos.x, ", ", pos.y)
	var chunk_to_derender = get_chunk_by_position(pos)
	if chunk_to_derender != null:
		for instance in chunk_to_derender.entities:
			entities.remove_child(instance)
		# Remove tiles from biomes tilemap
		for x in range(pos.x, pos.x + chunk_size):
			for y in range(pos.y, pos.y + chunk_size):
				biomes.erase_cell(0, Vector2(x, y))
		chunks.erase(chunk_to_derender)
		loaded_chunks.append(chunk_to_derender)

	else:
		print("Chunk not found to derender:", pos)
	
func derender_chunk_by_id(id : int):
	pass

func render_chunk_by_position(pos : Vector2):
	pass
func render_chunk_by_id(id : int):
	pass

func generate_world():
	pass

func save_world():
	pass
func start_world():
	var darkness_value = (sin(time - PI / 2) + 1.0) / 2.0
	$daynight.color = darkscale.gradient.sample(darkness_value)
	for active_player in local.get_children():
		var chk = get_chunk_position(active_player.position)
		generate_full(chk)
	$global_tick.start()

func _ready():
	biome_noise.seed = rng.randi_range(1, 1000)
	heightmap_noise.seed = rng.randi_range(1, 1000)
	
func _process(delta):
	pass

func get_chunk_position(pos : Vector2):
	return(Vector2(pos.x / (32 * chunk_size), pos.y / (32 * chunk_size)))
	
func get_chunk(pos : Vector2):
	for chk in chunks:
		var x = (chk.position.x * 32)
		var y = (chk.position.y * 32)
		var cmass = chunk_size * 32
		if pos.x >= x && pos.x <= x + cmass && pos.y >= y && pos.y <= y + cmass:
			return(chk)
func check_load_chunks():
	for player in local.get_children():
		var pos = player.global_transform.origin
		var chk = get_chunk(pos)
		if chk == null:
			print("CHK NULL:", pos.x, ", ", pos.y)
			for chnk in chunks:
				print(chnk.position)
				$global_tick.stop()
				return
		var adj_size = chunk_size * 32
		var chunk_buffer = adj_size * 0.37
		var x = chk.position.x * 32
		var y = chk.position.y * 32
		# Generate chunks based on player position relative to current chunk boundaries
		if pos.x > adj_size - chunk_buffer:
			generate_right_chunk(chk)
			if pos.y > y + adj_size - chunk_buffer:
				generate_bottom_right_corner(chk)
			elif pos.y < y + chunk_buffer:
				generate_top_right_corner(chk)
		
		if pos.x < x + chunk_buffer:
			generate_left_chunk(chk)
			if pos.y > y + adj_size - chunk_buffer:
				generate_bottom_left_corner(chk)
			elif pos.y < y + chunk_buffer:
				generate_top_left_corner(chk)
		if pos.y > y + adj_size - chunk_buffer:
			generate_bottom_chunk(chk)
		if pos.y < y + chunk_buffer:
			generate_top_chunk(chk)
		
		# Derender chunks that are not close enough
		for chunk in chunks:
			if chunk.position != chk.position:
				var chunk_center = chunk.position * 32 + Vector2(adj_size / 2, adj_size / 2)
				var distance = pos.distance_to(chunk_center)
				if distance > adj_size * 2:
					derender_chunk_by_position(chunk.position)
					
func generate_right_chunk(chk: Chunk):
	var right_chunk_pos = Vector2(chk.position.x + chunk_size, chk.position.y)
	var genchk = get_chunk_by_position(right_chunk_pos)
	if genchk == null:  # Ensure chunk doesn't already exist
		print("gen right chunk")
		generate_full(right_chunk_pos)

func generate_left_chunk(chk: Chunk):
	var left_chunk_pos = Vector2(chk.position.x - chunk_size, chk.position.y)
	var genchk = get_chunk_by_position(left_chunk_pos)
	if genchk == null:  # Ensure chunk doesn't already exist
		print("gen left chunk")
		generate_full(left_chunk_pos)

func generate_bottom_chunk(chk: Chunk):
	var bottom_chunk_pos = Vector2(chk.position.x, chk.position.y + chunk_size)
	var genchk = get_chunk_by_position(bottom_chunk_pos)
	if genchk == null:  # Ensure chunk doesn't already exist
		generate_full(bottom_chunk_pos)

func generate_top_chunk(chk: Chunk):
	var top_chunk_pos = Vector2(chk.position.x, chk.position.y - chunk_size)
	var genchk = get_chunk_by_position(top_chunk_pos)
	if genchk == null:  # Ensure chunk doesn't already exist
		print("gen top chunk")
		generate_full(top_chunk_pos)

func generate_bottom_right_corner(chk: Chunk):
	var bottom_right_pos = Vector2(chk.position.x + chunk_size, chk.position.y + chunk_size)
	var genchk = get_chunk_by_position(bottom_right_pos)
	if genchk == null:  # Ensure chunk doesn't already exist
		print("gen bottom right chunk")
		generate_full(bottom_right_pos)

func generate_bottom_left_corner(chk: Chunk):
	var bottom_left_pos = Vector2(chk.position.x - chunk_size, chk.position.y + chunk_size)
	var genchk = get_chunk_by_position(bottom_left_pos)
	if genchk == null:  # Ensure chunk doesn't already exist
		print("gen bottom left chunk")
		generate_full(bottom_left_pos)

func generate_top_right_corner(chk: Chunk):
	var top_right_pos = Vector2(chk.position.x + chunk_size, chk.position.y - chunk_size)
	var genchk = get_chunk_by_position(top_right_pos)
	if genchk == null:  # Ensure chunk doesn't already exist
		print("gen top right chunk")
		generate_full(top_right_pos)

func generate_top_left_corner(chk: Chunk):
	var top_left_pos = Vector2(chk.position.x - chunk_size, chk.position.y - chunk_size)
	var genchk = get_chunk_by_position(top_left_pos)
	if genchk == null:  # Ensure chunk doesn't already exist
		print("gen top left chunk")
		generate_full(top_left_pos)
	
func _on_global_tick():
	time += .0002
	var darkness_value = (sin(time - PI / 2) + 1.0) / 2.0
	$daynight.color = darkscale.gradient.sample(darkness_value)
	var spawn_n = len(spawn_queue)
	check_load_chunks()
	if spawn_n > 0:
		var offset = 0
		if spawn_n > spawn_rate:
			for i in range(0, spawn_rate):
				entities.add_child(spawn_queue[i + offset])
				spawn_queue.remove_at(i + offset)
				offset -= 1
		else:
			for i in range(0, spawn_n):
				entities.add_child(spawn_queue[i + offset])
				spawn_queue.remove_at(i + offset)
				offset -= 1

