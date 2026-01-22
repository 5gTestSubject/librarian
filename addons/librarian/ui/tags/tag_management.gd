@tool
extends Container

const Util := preload("res://addons/librarian/utils.gd")
const UUID := preload("res://addons/librarian/scripts/uuid.gd")

@export var tag_table_metadata: LibraryTableInfo

func _ready() -> void:
    _refresh_tags()

func _refresh_tags() -> void:
    %Spreadsheet.reset_table(tag_table_metadata)
    var tags = LibraryInfo.tags.values()
    tags.sort_custom(func(left: LibraryTag, right: LibraryTag): return left.name < right.name)
    for tag in tags:
        %Spreadsheet.add_row([tag.id, tag.name, tag.description, tag.color])
    %Spreadsheet.set_field_visibility(0, false)

func _on_new_tag_button_pressed() -> void:
    %Spreadsheet.add_row([UUID.v4()])
