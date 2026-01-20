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

func set_cell_neighbor_left(neighbor: NodePath) -> void:
    focus_neighbor_left = neighbor

func set_cell_neighbor_top(neighbor: NodePath) -> void:
    focus_neighbor_top = neighbor

func set_cell_neighbor_right(neighbor: NodePath) -> void:
    focus_neighbor_right = neighbor

func set_cell_neighbor_bottom(neighbor: NodePath) -> void:
    focus_neighbor_bottom = neighbor

func set_cell_next(next: NodePath) -> void:
    focus_next = next

func set_cell_previous(previous: NodePath) -> void:
    focus_previous = previous
