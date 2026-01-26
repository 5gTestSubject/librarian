@tool
extends Container

signal toggled(toggled_on: bool)

@export var selected: bool:
    get: return %CheckBox.button_pressed
    set(value): %CheckBox.button_pressed = value

@export var tag_id: StringName
@export var tag_name: String:
    get: return %TagTitle.text
    set(value): %TagTitle.text = value
@export var tag_description: String:
    get: return %TagDescription.text
    set(value): %TagDescription.text = value
@export var tag_color: Color:
    get: return %TagColor.color
    set(value): %TagColor.color = value

func _on_checkbox_toggled(toggled_on: bool) -> void:
    toggled.emit(toggled_on)
