extends CanvasLayer

@export var player: CharacterBody2D
@export var tile_map: TileMap

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport

var mini_map_player: CharacterBody2D

func _ready():
	# duplicate tilemap ลง minimap
	var mini_map_tilemap = tile_map.duplicate()
	sub_viewport.add_child(mini_map_tilemap)

	# duplicate player ลง minimap
	mini_map_player = player.duplicate()
	sub_viewport.add_child(mini_map_player)

func _process(delta):
	if mini_map_player and player:
		mini_map_player.position = player.position
