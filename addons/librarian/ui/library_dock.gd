@tool
extends PanelContainer

const Util = preload("res://addons/librarian/utils.gd")

@export var library_path: String = ""

func _on_new_table_button_pressed() -> void:
    %NewTableDialog.popup()

func _on_new_table_dialog_confirmed() -> void:
    if not %NewTableNameField.text.is_valid_filename():
        return
    Util.create_table(Util.path_combine(library_path, %NewTableNameField.text + ".csv"), %NewTableNameField.text, %NewTableDescriptionField.text)

func _on_new_table_dialog_about_to_popup() -> void:
    %NewTableNameField.text = ""
    %NewTableDescriptionField.text = ""
