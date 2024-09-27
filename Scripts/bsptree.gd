extends Node2D

var world_size = Vector2i(1200,800)
var tilesize: int = 32
var fixed_world_size = Vector2i(world_size.x/tilesize,world_size.y/tilesize)
var tilemaplayer: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tilemaplayer = get_node("TileMapLayer2")
	queue_redraw()

func _draw():
	#tilemaplayer.set_cell(Vector2i(0,0), 1, Vector2i(0,0))
	
	var rng = RandomNumberGenerator.new()
	
	#draw background
	for x in range(fixed_world_size.x):
		for y in range(fixed_world_size.y):
			tilemaplayer.set_cell(Vector2i(x,y), rng.randi_range(1,2), Vector2i(0,0))
			
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
