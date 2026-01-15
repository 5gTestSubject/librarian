@tool
extends ConfirmationDialog

const Util = preload("res://addons/librarian/utils.gd")

signal new_field(name: String, description: String, type: StringName)

var existing_field_names: PackedStringArray

func _on_new_name(name: String) -> void:
    if existing_field_names.has(name):
        %NameEdit.modulate = Color.RED
    else:
        %NameEdit.modulate = Color.WHITE

func _on_confirmed() -> void:
    if not %NameEdit.text.is_valid_filename():
        return
    if existing_field_names.has(%NameEdit.text):
        return
    var type: StringName
    match %TypeOption.selected:
        0: type = Util.COL_TYPE_BOOL
        1: type = Util.COL_TYPE_NUM
        2: type = Util.COL_TYPE_STRING
        _: printerr("Bad column type.")
    new_field.emit(%NameEdit.text, %DescriptionEdit.text, type)
    queue_free()

func _on_canceled() -> void:
    queue_free()
