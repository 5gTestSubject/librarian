@tool
extends PanelContainer

const UUID = preload("res://addons/librarian/scripts/uuid.gd")

func message_bus(): return get_node(preload("res://addons/librarian/scripts/message_bus.gd").AUTOLOAD_NODE_PATH)

@export var metadata: LibraryTableInfo:
    get: return metadata
    set(value):
        metadata = value
        refresh()

func _ready() -> void:
    message_bus().main_screen_table_changed.connect(func(table_metadata): metadata = table_metadata)

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
    message_bus().field_added.emit(metadata.id)
