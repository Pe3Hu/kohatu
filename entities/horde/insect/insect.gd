extends Area2D
class_name Insect


var horde: Horde
var site: Site = null:
	set(value_):
		if site != null:
			horde.set_cell(site.coord, 0, Catalog.EMPTY_INSECT_COORD)
		
		site = value_
		
		horde.set_cell(site.coord, 0, Catalog.windrose_to_palette[site.sector.windrose])
		position = horde.map_to_local(site.coord)
var intent_path : Array[Site]
var index: int:
	set(value_):
		index = value_
		%IndexLabel.text = str(index)


func setup(horde_: Horde) -> void:
	horde = horde_
	
	index = horde.insects.size()
	horde.insects.append(self)
