extends TextureRect

@export var itemResource: Item

func set_new_data(resource: Item):
	itemResource = resource
	if itemResource != null:
		texture = itemResource.icon
		itemResource.inventarSlot = get_parent().name 
		itemResource.inventarPosition = int(name.split("Slot")[1])
	else:
		texture = null
