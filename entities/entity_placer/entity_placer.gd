# FIXME: If the player moves to the cell where the blueprint is instantiated,
#		 the player can step over it. Maybe a signal can be implemented
#		 to avoid this behavior.
extends CanvasItem


@export var ground: TileMap
@export var placeable_ground_layers := [0]
@export var entities: Array[Entity] = []

var entity_to_place: Entity
var picked_entity_blueprint: Node2D
var new_instance_position: Vector2
var available_cells: Array[Vector2i] = []
var is_cell_available := false


func _ready():
	var unavailable_cells: Array[Vector2i] = []
	for child in ground.get_children():
		if child is StaticBody2D:
			var cell = ground.local_to_map(child.global_position)
			unavailable_cells.append(cell)
			
	for layer in placeable_ground_layers:
		available_cells.append_array(
			ground.get_used_cells(layer).filter(
				func(cell): return not unavailable_cells.has(cell)
			)
		)
	
	# TODO: Signal to assign the entity to place
	entity_to_place = entities[0]


func _unhandled_input(event):
	if not entity_to_place: return
	
	if event is InputEventMouseMotion:
		handle_mouse_motion(event)
	elif event is InputEventMouseButton:
		handle_mouse_button(event)


func handle_mouse_motion(_event: InputEventMouseMotion) -> void:
	var mouse_location = get_normalized_mouse_location()
	var curr_mouse_position = mouse_location.local_position
	if new_instance_position == curr_mouse_position: return
	
	new_instance_position = curr_mouse_position
	
	var unavailable_cells: Array[Vector2i] = []
	for child in ground.get_children():
		if child is CharacterBody2D:
			var cell = ground.local_to_map(child.global_position)
			unavailable_cells.append(cell)
			
	is_cell_available = (
		available_cells.has(mouse_location.cell)
		and not unavailable_cells.has(mouse_location.cell)
	)
	if not is_cell_available: 
		if is_instance_valid(picked_entity_blueprint):
			picked_entity_blueprint.queue_free()
		return
	
	if not picked_entity_blueprint:
		picked_entity_blueprint = entity_to_place.blueprint.instantiate()
		ground.add_child(picked_entity_blueprint)
		
	picked_entity_blueprint.global_position = new_instance_position


func handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT: return
	if not event.pressed: return
	if not is_cell_available: return
	if new_instance_position == Vector2.INF: return
	
	var instance: Node2D = entity_to_place.scene.instantiate()
	instance.global_position = new_instance_position
	ground.add_child(instance)
	
	var cell = ground.local_to_map(new_instance_position)
	available_cells.erase(cell)
	
	new_instance_position = Vector2.INF
	picked_entity_blueprint.queue_free()


func get_normalized_mouse_location():
	var global_pos = get_global_mouse_position()
	var cell = ground.local_to_map(global_pos)
	var local_pos = ground.map_to_local(cell)
	return {
		"global_position": global_pos,
		"cell": cell,
		"local_position": local_pos,
	}
