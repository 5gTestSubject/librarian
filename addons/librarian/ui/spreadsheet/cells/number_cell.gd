@tool
extends PanelContainer

const Util = preload("res://addons/librarian/utils.gd")

var cell_value = 0.0:
    get: return $Editor.value
    set(v): $Editor.value = Util.convert_to_number(v)

func format(metadata: LibraryTableFieldInfo) -> void:
    var num_metadata := metadata.number_info
    %Editor.step = num_metadata.get_precision()
    %Editor.custom_arrow_step = num_metadata.arrow_step if num_metadata.type == Util.COL_TYPEHINT_DECIMAL else 0.0
    %Editor.rounded = num_metadata.type == Util.COL_TYPEHINT_INTEGER

func set_cell_neighbor_left(neighbor: NodePath) -> void:
    $Editor.focus_neighbor_left = neighbor

func set_cell_neighbor_top(neighbor: NodePath) -> void:
    $Editor.focus_neighbor_top = neighbor

func set_cell_neighbor_right(neighbor: NodePath) -> void:
    $Editor.focus_neighbor_right = neighbor

func set_cell_neighbor_bottom(neighbor: NodePath) -> void:
    $Editor.focus_neighbor_bottom = neighbor

func set_cell_next(next: NodePath) -> void:
    $Editor.focus_next = next

func set_cell_previous(previous: NodePath) -> void:
    $Editor.focus_previous = previous
