@tool
extends Container

func message_bus(): return get_node(preload("res://addons/librarian/scripts/message_bus.gd").AUTOLOAD_NODE_PATH)
const Util := preload("res://addons/librarian/utils.gd")
const UUID := preload("res://addons/librarian/scripts/uuid.gd")

func load_tags() -> void:
    %Spreadsheet.reset_table(%Spreadsheet._metadata)
    var tags = LibraryInfo.tags.values()
    tags.sort_custom(func(left: LibraryTag, right: LibraryTag): return left.name < right.name)
    for tag in tags:
        %Spreadsheet.add_row([tag.id, tag.name, tag.description, tag.color])
    %Spreadsheet.set_field_visibility(0, false)

func save_tags() -> void:
    LibraryInfo.tags.clear()
    for entry in %Spreadsheet.iter_entries():
        var tag := LibraryTag.new(entry[0], entry[1], entry[2], entry[3])
        LibraryInfo.tags[tag.id] = tag
    LibraryInfo.save_tags()

func _on_new_tag_button_pressed() -> void:
    %Spreadsheet.add_row([UUID.v4()])

func delete_selected() -> void:
    var checked_rows = %Spreadsheet.get_checked_rows()
    checked_rows.sort()
    checked_rows.reverse()
    for i in checked_rows:
        message_bus().row_deleted.emit(%Spreadsheet.get_metadata().id, i)
