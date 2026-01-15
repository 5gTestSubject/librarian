## This scene to be inherited by others to produce specific, typed cells.
## Inheriting scenes should add a single direct child which will control the data and editing logic
## for the typed cell.
## The direct child must be a Control. It must have property `cell_value` and it must have methods
## with identical names to the methods in this script regarding focus.

@tool
extends PanelContainer

var cell_value:
    get: return get_inner().cell_value
    set(value): get_inner().cell_value = value

@export var focus_theme: Theme

func get_inner() -> Control:
    return get_child(0)

#region Focus
func set_cell_neighbor_left(neighbor: NodePath) -> void:
    focus_neighbor_left = neighbor
    get_inner().set_cell_neighbor_left(neighbor)

func set_cell_neighbor_top(neighbor: NodePath) -> void:
    focus_neighbor_top = neighbor
    get_inner().set_cell_neighbor_top(neighbor)

func set_cell_neighbor_right(neighbor: NodePath) -> void:
    focus_neighbor_right = neighbor
    get_inner().set_cell_neighbor_right(neighbor)

func set_cell_neighbor_bottom(neighbor: NodePath) -> void:
    focus_neighbor_bottom = neighbor
    get_inner().set_cell_neighbor_bottom(neighbor)

func set_cell_next(next: NodePath) -> void:
    focus_next = next
    get_inner().set_cell_next(next)

func set_cell_previous(previous: NodePath) -> void:
    focus_previous = previous
    get_inner().set_cell_previous(previous)
#endregion

#region Connections
func _on_focus_entered() -> void:
    theme = focus_theme

func _on_focus_exited() -> void:
    theme = null
#endregion
