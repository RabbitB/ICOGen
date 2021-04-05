extends GridContainer

export (int) var column_width: int


func _on_sort_children() -> void:
	columns = int(ceil(rect_size.x / column_width))

