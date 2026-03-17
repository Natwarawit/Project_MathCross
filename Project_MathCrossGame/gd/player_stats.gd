extends Node2D

@export_group("Basic Stats")
@export var level = 25
@export var basicHealth = 500
@export var basicStrenght = 50
@export var basicArmor = 180

@export_group("Final Stats")
@export var health: int
@export var strenght: int
@export var armor: int

func update_equipment_stats(equipStats):
	health = basicHealth + equipStats.health
	strenght = basicStrenght + equipStats.strenght
	armor = basicArmor + equipStats.armor
