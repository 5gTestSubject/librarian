@tool
extends Container

const Util := preload("res://addons/librarian/utils.gd")
const UUID := preload("res://addons/librarian/scripts/uuid.gd")

@export var tag_table_metadata: LibraryTableInfo

func load_tags() -> void:
    %Spreadsheet.reset_table(tag_table_metadata)
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
