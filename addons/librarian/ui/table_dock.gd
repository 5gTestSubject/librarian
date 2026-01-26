@tool
extends PanelContainer

const Util = preload("res://addons/librarian/utils.gd")
const UUID = preload("res://addons/librarian/scripts/uuid.gd")

@export var metadata: LibraryTableInfo:
    get: return metadata
    set(value):
        metadata = value
        refresh()

func _ready() -> void:
    LibraryMessageBus.main_screen_table_changed.connect(func(table_metadata): metadata = table_metadata)

func refresh() -> void:
    %TableDetailsTree.metadata = metadata

func _on_new_field_button_pressed() -> void:
    var dialog = preload("res://addons/librarian/ui/dialogs/new_field_dialog.tscn").instantiate()
    var existing_field_names = PackedStringArray()
    existing_field_names.resize(metadata.fields.size())
    for i in range(metadata.fields.size()):
        existing_field_names[i] = metadata.fields[i].name
    dialog.existing_field_names = existing_field_names
    add_child(dialog)
    dialog.new_field.connect(_on_new_field_submitted)
    dialog.visible = true

func _on_new_field_submitted(name: String, description: String, type: StringName) -> void:
    var field = LibraryTableFieldInfo.new()
    field.name = name
    field.description = description
    field.type = type
    field.id = UUID.v4()
    metadata.fields.append(field)
    LibraryMessageBus.field_added.emit(metadata.id)

    # if last (now 2nd-last) field was tags, keep it that way
    if metadata.fields.size() >= 2 and metadata.fields[metadata.fields.size() - 2].type == Util.COL_TYPE_TAGS:
        var tags_field = metadata.fields.pop_at(metadata.fields.size() - 2)
        metadata.fields.push_back(tags_field)
        LibraryMessageBus.field_moved.emit(
            metadata.id,
            metadata.fields.size() - 2,
            metadata.fields.size() - 1)
