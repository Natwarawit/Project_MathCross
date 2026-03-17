extends CanvasLayer

@export var player: CharacterBody2D
@export var tile_map: Node2D

@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport

var mini_map_player: CharacterBody2D
