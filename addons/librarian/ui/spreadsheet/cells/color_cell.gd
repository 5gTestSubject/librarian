@tool
extends ColorPickerButton

const Convert = preload("res://addons/librarian/scripts/convert.gd")

var cell_value := Color.BLACK:
    get: return color
    set(v): color = Convert.to_color(v)

func _ready() -> void:
    var picker := get_picker()
    picker.edit_alpha = false
    picker.color_mode = ColorPicker.MODE_HSV
    picker.picker_shape = ColorPicker.SHAPE_HSV_WHEEL
    picker.color_modes_visible = false
    picker.sliders_visible = false

