@tool
extends PanelContainer

const TableAccess = preload("res://addons/librarian/scripts/io/table_access.gd")
const Util = preload("res://addons/librarian/utils.gd")

@export var library_path: String = ""

func _on_new_table_button_pressed() -> void:
    %NewTableDialog.popup()

func _on_new_table_dialog_confirmed() -> void:
    if not %NewTableNameField.text.is_valid_filename():
        return
    if not TableAccess.create_table(%NewTableNameField.text, %NewTableNameField.text):
        Util.printwarn("Failed to create \"%s\"." % %NewTableNameField.text)

func _on_new_table_dialog_about_to_popup() -> void:
    %NewTableNameField.text = ""
    %NewTableDescriptionField.text = ""
