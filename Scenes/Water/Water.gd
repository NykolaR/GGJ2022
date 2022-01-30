extends Spatial

const MAP_SCALE : int = 60
const VIEWPORT_STEP : float = 512.0 / 60.0

var intensity : float = 0.0 setget set_intensity

export var wave_curve : Curve

var offset : Vector2 = Vector2() setget set_offset
var wind_direction : Vector2 = Vector2.UP
var wind_speed : float = 0.01
var wave_height : float = 1.0 setget set_wave_height

onready var heightmap_viewport : Viewport = $Viewport
onready var viewport_shader = $Viewport/Sprite.material as ShaderMaterial
onready var water_shader = $MeshInstance.get_surface_material(0) as ShaderMaterial
onready var heightmap : HeightMapShape = $StaticBody/CollisionShape.shape as HeightMapShape
onready var rain : CPUParticles = $CPUParticles as CPUParticles

func _ready() -> void:
	set_wave_height(wave_height)

func _physics_process(delta: float) -> void:
	update_heightmap()

func _process(delta: float) -> void:
	set_offset(offset + wind_direction * wind_speed * delta)
	var lintense : float = intensity * 0.1
	wind_direction = wind_direction.rotated(delta * rand_range(-intensity, intensity) * 15.0)
	wind_speed = lintense + (rand_range(-lintense, lintense) * 0.7)
	set_wave_height(wave_curve.interpolate_baked(intensity))
	
	if rain.emitting:
		rain.direction = Vector3(-wind_direction.x, -1, wind_direction.y)

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
	viewport_shader.set_shader_param("offset", offset)

func set_wave_height(new : float) -> void:
	wave_height = new
	water_shader.set_shader_param("height", wave_height)

func set_intensity(new : float) -> void:
	intensity = clamp(new, 0, 1)
	$Spawner.intensity = intensity
	rain.emitting = intensity > 0.6
