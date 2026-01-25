@tool
extends VBoxContainer

func message_bus(): return get_node(preload("res://addons/librarian/scripts/message_bus.gd").AUTOLOAD_NODE_PATH)
const Util = preload("res://addons/librarian/utils.gd")

## Load the given table path into this spreadsheet using the given metadata.
func load_content(_path: String) -> void:
    %TagManagement.load_tags()

func save_content(flush_every: int = -1) -> void:
    if flush_every > 0:
        Util.printwarn("TODO: support intermittent flush on saving tags.")
    %TagManagement.save_tags()

func on_editor_tab_selected() -> void:
    message_bus().main_screen_table_changed.emit(null)
