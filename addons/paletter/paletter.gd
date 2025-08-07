@tool
extends EditorPlugin

var dock

func _enable_plugin() -> void:
	
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	dock = preload("res://addons/paletter/PalettePanel.tscn").instantiate()
	
	# Add the loaded scene to the docks.
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock)
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_control_from_docks(dock)
	# Erase the control from the memory.
	dock.free()
	pass
