@tool
extends Container

const Util := preload("res://addons/librarian/utils.gd")

@export var tag_table_metadata: LibraryTableInfo

func _ready() -> void:
    %Spreadsheet.reset_table(tag_table_metadata)
    _refresh_tags()

func _refresh_tags() -> void:
    var tags = LibraryInfo.tags.values()
    tags.sort_custom(func(left: LibraryTag, right: LibraryTag): return left.name < right.name)
    for tag in tags:
        %Spreadsheet.add_row([tag.id, tag.name, tag.description, tag.color])
    %Spreadsheet.set_field_visibility(0, false)
