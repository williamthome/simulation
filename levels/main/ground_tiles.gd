extends TileMap


@export var barrier_layer := 1
@export var barrier_atlas_cords := Vector2i(5, 2)
@export var barrier_source_id = 1


func _ready() -> void:
	var used_cells = get_used_cells(0)
	used_cells.reduce(
		func(accum, cell):
			for surrounding_cell in get_surrounding_cells(cell):
				var is_not_set = not accum.has(surrounding_cell)
				var is_an_empty_cell = not used_cells.has(surrounding_cell)
				if is_not_set and is_an_empty_cell:
					set_barrier_cell(surrounding_cell)
					accum.append(surrounding_cell)
			return accum,
		[]
	)


func set_barrier_cell(cellv: Vector2i) -> void:
	set_cell(barrier_layer, cellv, barrier_source_id, barrier_atlas_cords, 0)
