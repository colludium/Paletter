@tool
extends  Control


@onready var label_source_path = $VBoxContainer/SourcePath
@onready var label_color_palette_res_path = $VBoxContainer2/ColorPalettePath
@onready var source_dialog = $PickSrcDialog
@onready var colorpalette_dialog = $PickColorPaletteDialog
@onready var save_gpl_dialog = $GplSaveDialog
@onready var save_txt_dialog = $TxtSaveDialog


var color_array : PackedColorArray
var color_palette_res_path : String = ""
var palette_name : String = ""
var src_text : String
var tgt_text : String


func _ready() -> void:
	src_text = label_source_path.text
	tgt_text = label_color_palette_res_path.text

func _on_btn_src_pressed() -> void:
	source_dialog.popup_centered()


func _on_btn_tgt_pressed() -> void:
	colorpalette_dialog.popup_centered()


func _on_src_dialog_file_selected(path: String) -> void:
	get_color_data_from_source(path)


func _on_tgt_dialog_file_selected(path: String) -> void:
	do_target_file_work(path)


func _on_btn_load_pressed() -> void:
	load_colors_into_tgt()


func _on_btn_export_as_gpl_pressed() -> void:
	save_gpl_dialog.popup()


func _on_btn_export_as_txt_pressed() -> void:
	save_txt_dialog.popup()


func _on_gpl_save_dialog_file_selected(path: String) -> void:
	do_file_save(path, ".gpl")


func _on_txt_save_dialog_file_selected(path: String) -> void:
	do_file_save(path, ".txt")


func reset_source_data() -> void:
	label_source_path.text = src_text
	palette_name = ""
	color_array.clear()

func get_color_data_from_source(path: String):
	var is_gpl = path.ends_with(".gpl")
	var is_txt = path.ends_with(".txt")

	if not is_gpl and not is_txt:
		reset_source_data()
		print_rich("[color=yellow]Selected file needs was not .gpl or .txt: [/color]", path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text(true)

	if not content.contains(";Colors:"):
		is_txt = false

	if not content.contains("#Colors:"):
		is_gpl = false

	if not is_gpl and not is_txt:
		reset_source_data()
		print_rich("[color=yellow]Are you sure the selected file was a color palette? [/color]", path)
		return

	label_source_path.text = path

	var lines = content.split("\n")
	var colorindex = 3 #gpl index
	var name = ""

	for i in lines.size():
		lines[i] = lines[i].strip_edges(true, true)

		if lines[i].contains("Name: "):
			palette_name = lines[i].split("Name: ")[1]

		#It's probably from the internet so color start line might vary
		if is_gpl and lines[i].contains("#Colors:"):
			colorindex = i
		if is_txt and lines[i].contains(";Colors:"):
			colorindex = i

	var collines = lines.slice(colorindex, lines.size())
	var line0 : String = collines.slice(0, 1)[0]
	var colcount = line0.split(": ")[1].to_int()
	#To get an array of cells, each with color data, remove first line
	collines.remove_at(0)
	color_array.clear()

	for i in colcount:
		var line : String = collines[i]
		var newcolor: Color
		var rgb: String

		if is_gpl:
			rgb = line.split("\t")[3] # tab separator

		else:
			rgb = line.right(6)

		if not rgb.is_valid_html_color():
			continue

		newcolor = Color.html(rgb)
		color_array.push_back(newcolor)

	if color_array.is_empty():
		reset_source_data()
		print_rich("[color=yellow]ERROR: Could not find any color hex_str/html data in the file: [/color]", path)


func reset_color_palette_res_path_data() -> void:
	label_color_palette_res_path.text = tgt_text
	color_palette_res_path = ""

func do_target_file_work(path: String) -> void:
	var a_resource = path.ends_with(".tres") or path.ends_with(".res")

	if not a_resource:
		reset_color_palette_res_path_data()
		print_rich("[color=yellow]The selected target file was not a Godot resource: [/color]", path)
		return

	var temp = ResourceLoader.load(path)

	if temp is not ColorPalette:
		reset_color_palette_res_path_data()
		print_rich("[color=yellow]The selected resource was not a ColorPalette object: [/color]", path)
		return

	label_color_palette_res_path.text = path
	color_palette_res_path = path


func load_colors_into_tgt() -> void:
	if color_palette_res_path == "" or color_array.is_empty():
		print_rich("[color=dim_gray]Missing source or target[/color]")
		return

	var target : ColorPalette = ResourceLoader.load(color_palette_res_path)
	target.resource_name = palette_name
	target.colors = color_array
	ResourceSaver.save(target, color_palette_res_path)
	print_rich("[color=green]Colors loaded into: [/color]", color_palette_res_path)


func do_file_save(path: String, endswith: String) -> void:
	if color_palette_res_path == "":
		print_rich("[color=yellow]Need to select a ColorPalette object.")
		return

	if not path.ends_with(endswith):
		print_rich("[color=yellow]Save file was not a valid " + endswith + " file: [/color]", path)
		return

	var cp : ColorPalette = ResourceLoader.load(color_palette_res_path)

	if cp is not ColorPalette:
		reset_color_palette_res_path_data()
		print_rich("[color=yellow]The selected resource was not a ColorPalette object: [/color]", color_palette_res_path)
		return

	# Now the work
	var pca : PackedColorArray = cp.colors
	var colcount : String = str(pca.size())
	var res_name = cp.resource_name
	var str = ''

	if endswith == ".txt":
		str = ';paint.net Palette File
;Downloaded from Godot/Paleter
;Palette Name: ' + res_name + '
;Description:
;Colors: ' + colcount + "\n"

	else: # .gpl
		str = 'GIMP Palette
#Palette Name: ' + res_name + '
#Description:
#Colors: ' + colcount + "\n"

	for color in pca:
		var hex_str = color.to_html(false) + "\n"

		if endswith == ".txt":
			str += "FF" + hex_str
		else: # .gpl
			var r = str(color.r8)
			var g = str(color.g8)
			var b = str(color.b8)
			var tab = "\t"
			str += r + tab + g + tab + b + tab + hex_str

	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_string(str)
	file.close()
	print_rich("[color=green]Saved as "+ endswith + "![/color]")
