extends Spatial

const MAP_SCALE : int = 60
const VIEWPORT_STEP : float = 512.0 / 60.0

var offset : Vector2 = Vector2() setget set_offset
var wind_direction : Vector2 = Vector2.UP
var wind_speed : float = 0.01
var wave_height : float = 1.0 setget set_wave_height

onready var heightmap_viewport : Viewport = $Viewport
onready var water_shader = $Viewport/Sprite.material as ShaderMaterial
onready var heightmap : HeightMapShape = $StaticBody/CollisionShape.shape as HeightMapShape

func _ready() -> void:
	set_wave_height(wave_height)

func _physics_process(delta: float) -> void:
	update_heightmap()

func _process(delta: float) -> void:
	set_offset(offset + wind_direction * wind_speed * delta)

func update_heightmap() -> void:
	var n_float_array : PoolRealArray = PoolRealArray()
	n_float_array.resize(MAP_SCALE * MAP_SCALE)
	var data : Image = heightmap_viewport.get_texture().get_data()
	data.lock() # can the image be permanently stored instead of allocated each frame?
	
	var i : int = 0
	for y in MAP_SCALE:
		for x in MAP_SCALE:
			var h : float = data.get_pixel(x * VIEWPORT_STEP, y * VIEWPORT_STEP).r
			n_float_array[i] = h * wave_height
			i += 1
	
	data.unlock()
	heightmap.map_data = n_float_array

func set_offset(new : Vector2) -> void:
	offset = new
	water_shader.set_shader_param("offset", offset)

func set_wave_height(new : float) -> void:
	wave_height = new
	water_shader.set_shader_param("height", wave_height)
