@tool
extends LineEdit

const Convert = preload("res://addons/librarian/scripts/convert.gd")
const Util = preload("res://addons/librarian/utils.gd")

var cell_value = "":
    get: return text
    set(value): text = Convert.to_text(value)

func format(metadata: LibraryTableFieldInfo) -> void:
    placeholder_text = metadata.text_info.placeholder_text

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
