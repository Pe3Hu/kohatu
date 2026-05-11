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

func update_intent_path(site_: Site) -> void:
	if site_.insect_intent != null: 
		site.insect_intent = self
		return
	
	if !intent_path.is_empty():
		intent_path.back().insect_intent = null
	
	intent_path.append(site_)
	site_.insect_intent = self

func intent_forward() -> void:
	if !site.forward:
		intent_aligh()
		return
	update_intent_path(site.forward)

func intent_backward() -> void:
	if !site.backward: 
		intent_aligh()
		return
	update_intent_path(site.backward)

func intent_aligh() -> void:
	if !site.align:
		site.insect_intent = self
		return
	update_intent_path(site.align)

func follow_intent() -> void:
	var final_site: Site = null
	while !intent_path.is_empty():
		final_site = intent_path.pop_back()
		if final_site.insect_intent == self:
			break
	
	if final_site != null:
		site = final_site
		horde.site_to_insect[final_site] = self
		site.insect = self
		site.insect_intent = null
	
	intent_path.clear()
