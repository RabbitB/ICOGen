tool
class_name FixedFlexGridContainer, "iconography/fixed_flex_grid_container_icon.png"
extends GridContainer
# A GridContainer with a flexible number of columns, that changes to fit as
# many fixed-width columns as possible, into the GridContainer's current size.


export (int) var column_width: int setget _set_column_width

var _skip_next_sort: bool


func _ready() -> void:
	self.connect("sort_children", self, "_on_sort_children")

	# If the column width isn't a valid value, force a default value.
	if column_width <= 0:
		self.column_width = 0


func _update_columns(should_sort: bool) -> void:
	_skip_next_sort = !should_sort

	var column_count: int = int(ceil(rect_size.x / column_width))
	var columns_needed = min(column_count, get_child_count())
	columns = max(1, columns_needed)


func _on_sort_children() -> void:
	if !_skip_next_sort:
		_update_columns(false)
	else:
		_skip_next_sort = false


func _set_column_width(new_width: int) -> void:
	column_width = new_width if new_width > 0 else rect_size.x
	_update_columns(true)

