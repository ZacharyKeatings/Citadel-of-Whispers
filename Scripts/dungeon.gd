extends Node2D

@onready var player_scene = preload("res://Scenes/gridPlayer.tscn")

#var root_node: Branch
#var tile_size: int =  16
#var world_size = Vector2i(600,300)
#
#var tilemap: TileMap
#var paths: Array = []

#func _draw():
	#var rng = RandomNumberGenerator.new()
	#for leaf in root_node.get_leaves():
		#var padding = Vector4i(rng.randi_range(2,3),rng.randi_range(2,3),rng.randi_range(2,3),rng.randi_range(2,3))
		#for x in range(leaf.size.x):
			#for y in range(leaf.size.y):
				#if not is_inside_padding(x,y, leaf, padding) :
					#tilemap.set_cell(0, Vector2i(x + leaf.position.x,y + leaf.position.y), 0, Vector2i(8, 2))
	#for path in paths:
		#if path['left'].y == path['right'].y:
			#for i in range(path['right'].x - path['left'].x):
				#tilemap.set_cell(0, Vector2i(path['left'].x+i,path['left'].y), 0, Vector2i(8, 2))
		#else:
			#for i in range(path['right'].y - path['left'].y):
				#tilemap.set_cell(0, Vector2i(path['left'].x,path['left'].y+i), 0, Vector2i(8, 2))

func _ready():
	#tilemap = get_node("TileMap")
	#root_node  = Branch.new(Vector2i(0,0), world_size)
	#root_node.split(2, paths)
	#queue_redraw()
	create_player()
	#pass 

#func is_inside_padding(x, y, leaf, padding):
	#return x <= padding.x or y <= padding.y or x >= leaf.size.x - padding.z or y >= leaf.size.y - padding.w

func create_player():
	var player = player_scene.instantiate()
	add_child(player)
	player.position = Vector2(200,104)
