extends Node2D

var player_array = [
	preload("uid://b4i1sf8knkrry"),
	preload("uid://cqrg2a0nupcrs"),
	preload("uid://0c3pievbgfmw"),
	preload("uid://cahkgi40rtdvr"),
	preload("uid://cw380w8bfd7gs"),
	preload("uid://dmnwy08oyf68"),
	preload("uid://co0luqp87p7bu"),
	preload("uid://j12b3n6oop0d")	
]

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var camera: Camera2D = $Camera2D
@onready var label: Label = $UI/Label

# 海拔噪声 (大轮廓)
var noise_height = FastNoiseLite.new()
# 湿度噪声
var noise_moisture = FastNoiseLite.new()

@export var noise_height_seed: int = 42
@export var noise_moisture_seed: int = 123
@export var noise_height_scale: float = 0.03
@export var noise_moisture_scale: float = 0.06

var is_dragging = false
var drag_start_position = Vector2.ZERO
var camera_start_position = Vector2.ZERO
var zoom_speed = 0.1
var min_zoom = 0.2
var max_zoom = 3.0

var tile_data = {}


func _ready():
	noise_height.seed = noise_height_seed
	noise_moisture.seed = noise_moisture_seed
	noise_height.frequency = noise_height_scale
	noise_moisture.frequency = noise_moisture_scale
	
	#generate_map()
	init_map(10, 10)
	#init_player()
	
func init_player():
	var player = Sprite2D.new()
	player.texture = player_array[0]
	player.position = tile_map_layer.map_to_local(Vector2i(1, 1))
	add_child(player)

func init_map(width, height):
	for x in range(0, width):
		for y in range(0, height):
			var height_num = noise_height.get_noise_2d(x, y)
			var moisture_num = noise_moisture.get_noise_2d(x, y)
			
			var height_tile_set_index = int(remap(height_num, -1, 1, 0, 3))
			var moisture_tile_set_index  = int(remap(moisture_num, -1, 1, 0, 7))
			
			var tile_coords = get_true_tile(height_tile_set_index, moisture_tile_set_index)
			tile_map_layer.set_cell(
				Vector2i(x, y),
				height_tile_set_index,
				tile_coords)
			
			tile_data[Vector2i(x, y)] = {
				"height": height_tile_set_index,
				"moisture": moisture_tile_set_index
			}
	
	for i in range(8):
		print(i)
		var player = Sprite2D.new()
		player.texture = player_array[i % player_array.size()]
		player.scale = Vector2(4, 4)
		var random_x = randi() % width
		var random_y = randi() % height
		player.position = tile_map_layer.map_to_local(Vector2i(random_x, random_y))
		add_child(player)

	

			

	
func get_true_tile(source_id:int, moisture_tile_set_index) ->Vector2i:
	if source_id == 0:
		return Vector2i(9+moisture_tile_set_index, 0)
	if source_id == 1:
		return Vector2i(9+moisture_tile_set_index, 1)
	if source_id == 2:
		return Vector2i(9+moisture_tile_set_index, 2)
	if source_id == 3:
		return Vector2i(9+moisture_tile_set_index, 3)
	
	assert("source_id error ")
	return Vector2i(0, 0)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_dragging = true
				drag_start_position = event.position
				camera_start_position = camera.position
			else:
				is_dragging = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom = Vector2(min(camera.zoom.x + zoom_speed, max_zoom), min(camera.zoom.y + zoom_speed, max_zoom))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom = Vector2(max(camera.zoom.x - zoom_speed, min_zoom), max(camera.zoom.y - zoom_speed, min_zoom))
	elif event is InputEventMouseMotion:
		if is_dragging:
			var delta = event.position - drag_start_position
			camera.position = camera_start_position - delta / camera.zoom.x
		else:
			update_tile_coordinates(event.position)

func update_tile_coordinates(mouse_position: Vector2):
	var tile_coords = tile_map_layer.local_to_map(get_global_mouse_position())
	
	if tile_coords in tile_data:
		var data = tile_data[tile_coords]
		label.text = "Tile: (%d, %d)\n海拔: %d\n湿度: %d" % [tile_coords.x, tile_coords.y, data["height"], data["moisture"]]
	else:
		label.text = "Tile: (%d, %d)" % [tile_coords.x, tile_coords.y]
		


	
	
	
	
			
