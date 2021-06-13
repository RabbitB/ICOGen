class_name PersistentFileDialog, "iconography/persistent_file_dialog.png"
extends FileDialog


const LAST_USED_PATH: String = "last_used_path"

export(String) var config_identifier: String = "file_dialog"
export(String, FILE) var config_file_path: String = "user://persistent.cfg"


func _ready():
	self.connect("about_to_show", self, "_on_about_to_show_persistent")
	self.connect("dir_selected", self, "_on_dir_selected_persistent")
	self.connect("file_selected", self, "_on_dir_selected_persistent")
	self.connect("files_selected", self,"_on_files_selected_persistent")


func load_persistent_data() -> void:
	var config: ConfigFile = _get_loaded_config_file()
	current_dir = config.get_value(
			config_identifier,
			LAST_USED_PATH,
			OS.get_executable_path())


func save_persistent_data(working_path: String) -> void:
	var config: ConfigFile = _get_loaded_config_file()
	config.set_value(config_identifier, LAST_USED_PATH, working_path)

	var err: int = config.save(config_file_path)
	if err:
		Log.error("Cannot save the config file that stores the persisent " \
				+ "data for this file dialog. Encountered error %s",
				[Log.get_error_description(err)])


func _get_loaded_config_file() -> ConfigFile:
	var config: ConfigFile = ConfigFile.new()
	var err: int = config.load(config_file_path)

	# We don't consider file not found as an error, as we can reset to defaults
	# and create a new file. Other errors need to be handled though.
	if err && err != ERR_FILE_NOT_FOUND:
		Log.error("Cannot load the config file that stores the persistent " \
				+ "data for this file dialog. Encountered error %s",
				[Log.get_error_description(err)])

	return config


func _on_about_to_show_persistent() -> void:
	load_persistent_data()


func _on_dir_selected_persistent(dir: String) -> void:
	# Sometimes selecting a file triggers this signal even though it shouldn't.
	# So we account for that scenario.
	if dir.get_extension():
		save_persistent_data(dir.get_base_dir())
	else:
		save_persistent_data(dir)


func _on_file_selected_persistent(file: String) -> void:
	save_persistent_data(file.get_base_dir())


func _on_files_selected_persistent(paths: PoolStringArray) -> void:
	save_persistent_data(paths[0].get_base_dir())

