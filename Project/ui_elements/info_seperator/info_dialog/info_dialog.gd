extends AcceptDialog


const HEADER_FONT_PATH: String = "res://fonts/default_heading.tres"
const DFACTION_COLOR: Color = Color("991F33")
const HEADER_COLOR: Color = Color("53A788")
const LOGO_IMG_PATH: String = "res://branding/icon.png"
const DFACTION_IMG_PATH: String = "res://branding/splash.png"
const DFACTION_URL: String = "https://dfaction.net"
const ICOGEN_URL: String = "https://dfaction.itch.io/icogen"

export(float) var window_size_ratio: float = 0.9

onready var _about: RichTextLabel = $Tabs/ABOUT/RichTextLabel as RichTextLabel
onready var _copyright: RichTextLabel = $Tabs/COPYRIGHT/RichTextLabel as RichTextLabel
onready var _licenses: RichTextLabel = $Tabs/LICENSES/RichTextLabel as RichTextLabel


func _ready():
# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")
	get_close_button().visible = false

	_about.bbcode_text = "%s%s" % \
			[_make_url(_make_image(LOGO_IMG_PATH), ICOGEN_URL), _get_about_info()]

	_copyright.bbcode_text = "\n%s" % _get_copyright_info()
	_licenses.bbcode_text = "\n%s" % _get_license_info()


func _get_about_info() -> String:
	var description_text: String = "A lightweight GUI based .ico file creator that supports " + \
			"mixed icon sizes, and provides fine-grained control over source images and " + \
			"automatic image resizing."

	var output: String = _center_text("By")
	output += _make_url(_make_image(DFACTION_IMG_PATH, 128), DFACTION_URL)

	output += _make_header(_make_url("DIGITAL FACTION", DFACTION_URL, DFACTION_COLOR))
	output += _center_text(_make_labeled_line("Copyright", "2021 Digital Faction"))
	output += _center_text(_make_labeled_line("License", "Expat"))
	output += "\n"
	output += _justify_text(description_text)

	return output


func _get_copyright_info() -> String:
	var output: String = _colorize(_make_header("COPYRIGHT"), HEADER_COLOR)

	for copyright_info in Engine.get_copyright_info():
		output += _make_highlight(copyright_info.name)

		for part in copyright_info.parts:
			for copyright in part.copyright:
				output += "%s\n" % copyright

			output += "%s\n" % _make_labeled_line("License", part.license)

		output += "\n"

	return output


func _get_license_info() -> String:
	var output: String = _colorize(_make_header("3RD PARTY LICENSES"), HEADER_COLOR)
	var license_info: Dictionary = Engine.get_license_info()

	for license in license_info:
		output += _make_highlight(license)
		output += "[fill]"

		#	Godot stores every license with hard line-breaks. For readability,
		#	we need to remove these hard line-breaks, but keep paragraph seperation.
		for license_part in license_info[license].split("\n\n", false):
			output += "%s\n\n" % license_part.replace("\n", " ")

		output += "[/fill]\n"

	return output


func _make_header(content: String) -> String:
	return _center_text("%s\n" % _make_highlight(content))


func _make_highlight(content: String) -> String:
	return "[font=%s][u]%s[/u][/font]\n" % [HEADER_FONT_PATH, content]


func _make_labeled_line(label: String, content: String) -> String:
	return "[u]%s:[/u] %s\n" % [_colorize(label, Color.white), content]


func _make_url(content: String, url: String, link_color: Color = Color.transparent) -> String:
	var output: String = "[url=%s]%s[/url]" % [url, content]
	if !link_color.is_equal_approx(Color.transparent):
		output = _colorize(output, link_color)

	return output


func _make_image(img_path: String, width: int = 0, height: int = 0) -> String:
	var img_size_modifier: String = ""
	if width > 0 && height > 0:
		img_size_modifier = "=%dx%d" % [width, height]
	elif int(max(width, height)) > 0:
		img_size_modifier = "=%d" % int(max(width, height))

	return "[center][img%s]%s[/img][/center]" % [img_size_modifier, img_path]


func _center_text(content: String) -> String:
	return "[center]%s[/center]" % content


func _justify_text(content: String) -> String:
	return "[fill]%s[/fill]" % content


func _colorize(content: String, color: Color) -> String:
	return "[color=#%s]%s[/color]" % [color.to_html(), content]


func _on_viewport_size_changed() -> void:
	set_global_position(get_viewport().size * (1.0 - window_size_ratio) / 2.0)
	rect_size = get_viewport().size * window_size_ratio


func _on_RichTextLabel_meta_clicked(meta) -> void:
# warning-ignore:return_value_discarded
	OS.shell_open(str(meta))

