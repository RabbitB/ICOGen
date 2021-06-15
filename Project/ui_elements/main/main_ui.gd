extends Control


const SizeSelector: Script = preload("res://ui_elements/size_selector/size_selector.gd")
const ICOGenButtons: Script = preload("res://ui_elements/io_buttons/import_export_icogen.gd")
const ImageEntry: Script = preload("res://ui_elements/image_entry/image_entry.gd")
const ImageEntryScene: PackedScene = preload("res://ui_elements/image_entry/image_entry.tscn")

var _image_entries: Dictionary

onready var _size_selector: SizeSelector = $MainUIContainer/Sizes/SizeSelector as SizeSelector
onready var _image_entry_list: Control = $MainUIContainer/Entries/EntryGridScroll/ImageEntryList
onready var _is_ready: bool = true


func _init() -> void:
	_image_entries = Dictionary()


func _ready():
	sync_image_entries()


func save_ico_file(path: String) -> void:
	pass


func load_icogen_file(path: String) -> void:
	var icogen_file: ICOGenDataFile = ICOGenDataFile.new()

	var err: int = icogen_file.load(path)
	if err:
		Log.error(
				"Could not load ICOGen file. Encountered error %s",
				[Log.get_error_description(err)])
		return

	_size_selector.uncheck_all()
	ICOGen.active_data = icogen_file.icogen_data

	for size in icogen_file.selected_image_sizes:
		_size_selector.set_checked(size, true)


func save_icogen_file(path: String) -> void:
	var err: int = ICOGenDataFile.save(
			path, _size_selector.get_checked(), ICOGen.active_data)
	if err:
		Log.error(
				"Could not save the ICOGen file to %s. Encountered error %s",
				[path, Log.get_error_description(err)])


func sync_image_entries() -> void:
	for entry in _image_entries:
		remove_image_entry(entry)

	var checked_sizes: Array = _size_selector.get_checked()
	for size in checked_sizes:
		add_image_entry(size)


func add_image_entry(for_size: int) -> void:
	if _image_entries.has(for_size):
		return

	var new_entry: ImageEntry = ImageEntryScene.instance() as ImageEntry

	_image_entry_list.add_child(new_entry, true)
	new_entry.set_meta("image_size", for_size)
	new_entry.image_size = for_size

	_image_entries[for_size] = new_entry
	sort_image_entries()


func remove_image_entry(for_size: int) -> void:
	if _image_entries.has(for_size):
		var _image_entry: ImageEntry = _image_entries[for_size] as ImageEntry

		_image_entry_list.remove_child(_image_entry)
# warning-ignore:return_value_discarded
		_image_entries.erase(for_size)
		_image_entry.queue_free()

		ICOGen.active_data.reset_image(for_size)


func sort_image_entries() -> void:
	var entry_sizes: Array = _image_entries.keys()
	entry_sizes.sort()

	var idx: int = 0
	for size in entry_sizes:
		_image_entry_list.move_child(_image_entries[size], idx)
		idx += 1


func _on_export_icogen_file(path: String) -> void:
	save_icogen_file(path)


func _on_import_icogen_file(path: String) -> void:
	load_icogen_file(path)


func _on_SizeSelector_sizes_changed(size: int, is_checked: bool) -> void:
	if !_is_ready:
		return

	if is_checked:
		add_image_entry(size)
	else:
		remove_image_entry(size)

