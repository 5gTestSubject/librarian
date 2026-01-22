@tool
extends GridContainer

func message_bus(): return get_node(preload("res://addons/librarian/scripts/message_bus.gd").AUTOLOAD_NODE_PATH)
const Shortcuts = preload("res://addons/librarian/shortcuts.gd")
const Util = preload("res://addons/librarian/utils.gd")
const TITLE_CELL_SCENE = preload("res://addons/librarian/ui/spreadsheet/cells/column_title.tscn")

## Extra columns for numbering rows and giving them checkboxes.
const EXTRA_COLS := 2
## One extra row for titleing columns.
const EXTRA_ROWS := 1

const ROW_CHECKBOX_COL_IDX := 0
const ROW_NUM_COL_IDX := 1

## Columns of the logical spreadsheet, not the grid container.
## Grid container maintains an extra column to number rows with.
var spreadsheet_columns: int:
    get: return columns - _extra_columns
    set(value): columns = value + _extra_columns

@export var _metadata: LibraryTableInfo

var _extra_columns: int:
    get: return EXTRA_COLS - int(_hide_row_checkboxes) - int(_hide_row_nums)
var _hide_row_checkboxes := false
var _hide_row_nums := false
var _hidden_field_idxs := {}

func _ready() -> void:
    message_bus().field_updated.connect(_on_field_updated)
    message_bus().field_added.connect(_on_field_added)
    message_bus().field_deleted.connect(_on_field_deleted)
    message_bus().field_moved.connect(_on_field_moved)
    message_bus().row_added.connect(_on_row_added)
    message_bus().row_deleted.connect(_on_row_deleted)
    message_bus().row_moved.connect(_on_row_moved)

func reset_table(metadata: LibraryTableInfo) -> void:
    clear_grid(true)
    _metadata = metadata
    spreadsheet_columns = metadata.fields.size()
    for _i in range(_extra_columns):
        add_child(Control.new())
    for field in _metadata.fields:
        var title = TITLE_CELL_SCENE.instantiate()
        add_child(title)
        title.cell_value = field.name

func refresh_focus_neighbors() -> void:
    # skip non-cell rows
    for i in range(columns * EXTRA_ROWS, get_child_count()):
        # skip non-cell columns
        if 0 <= i % columns and i % columns < _extra_columns:
            continue
        var cell = get_child(i)
        var is_left_edge = i % columns == _extra_columns
        var is_right_edge = (i+1) % columns == 0
        var is_top_edge = i - columns < EXTRA_ROWS * columns
        var is_bottom_edge = i + columns >= get_child_count()

        cell.set_cell_neighbor_left(cell.get_path() if is_left_edge else get_child(i-1).get_path())
        cell.set_cell_neighbor_right(cell.get_path() if is_right_edge else get_child(i+1).get_path())
        cell.set_cell_neighbor_top(cell.get_path() if is_top_edge else get_child(i-columns).get_path())
        cell.set_cell_neighbor_bottom(cell.get_path() if is_bottom_edge else get_child(i+columns).get_path())

        if is_right_edge and is_bottom_edge:
            cell.set_cell_next(cell.get_path())
        elif is_right_edge:
            cell.set_cell_next(get_child(i + 1 + _extra_columns).get_path())
        else:
            cell.set_cell_next(get_child(i + 1).get_path())

        if is_left_edge and is_top_edge:
            cell.set_cell_previous(cell.get_path())
        elif is_left_edge:
            cell.set_cell_previous(get_child(i - _extra_columns - 1).get_path())
        else:
            cell.set_cell_previous(get_child(i - 1).get_path())

func clear_grid(clear_title_row: bool = false) -> void:
    for i in range(0 if clear_title_row else columns, get_child_count()):
        var child := get_child(i)
        remove_child(child)
        child.queue_free()

func add_row(data: Array, row_idx: int = -1) -> void:
    for leading_cell in _get_leading_cells(get_spreadsheet_row_count() + 1):
        add_child(leading_cell)
    for i in range(spreadsheet_columns):
        var cell = _get_cell_scene(i)
        add_child(cell)
        if i < data.size():
            cell.cell_value = data[i]

    if row_idx >= 0:
        var insert_idx = (row_idx + EXTRA_ROWS) * columns
        for i in range(columns):
            move_child(get_child(get_child_count() - columns + i), insert_idx + i)

    refresh_focus_neighbors()

func get_spreadsheet_row_count() -> int:
    return (get_child_count() / columns) - EXTRA_ROWS

func get_spreadsheet_cell_count() -> int:
    return get_spreadsheet_row_count() * spreadsheet_columns

#region Hidden Columns
# TODO GridContainer iterators broken. They can't account for hidden columns.
func set_checkbox_visibility(visible: bool) -> void:
    _hide_row_checkboxes = not visible
    for control in Util.ChildIterator.new(self, ROW_CHECKBOX_COL_IDX, self.get_child_count(), EXTRA_COLS + _metadata.fields.size()):
        control.visible = visible
    _adjust_grid_container_columns()

func set_row_num_visibility(visible: bool) -> void:
    _hide_row_nums = not visible
    for control in Util.ChildIterator.new(self, ROW_NUM_COL_IDX, self.get_child_count(), EXTRA_COLS + _metadata.fields.size()):
        control.visible = visible
    _adjust_grid_container_columns()

func set_field_visibility(field_idx: int, visible: bool) -> void:
    if visible:
        _hidden_field_idxs.erase(field_idx)
    else:
        _hidden_field_idxs[field_idx] = null
    for control in Util.ChildIterator.new(self, EXTRA_COLS + field_idx, self.get_child_count(), EXTRA_COLS + _metadata.fields.size()):
        control.visible = visible
    _adjust_grid_container_columns()

func _adjust_grid_container_columns() -> void:
    columns = _metadata.fields.size() - _hidden_field_idxs.size() + int(not _hide_row_checkboxes) + int(not _hide_row_nums)
#endregion

#region Iteration
func iter_field(field_idx: int):
    if not _metadata:
        return []
    return Util.MapIterator.new(
        Util.ChildIterator.new(self, EXTRA_COLS + _metadata.fields.size() + EXTRA_COLS + field_idx, self.get_child_count(), EXTRA_COLS + _metadata.fields.size()),
        func(cell): return cell.cell_value)

func iter_checkboxes():
    if not _metadata:
        return []
    return Util.ChildIterator.new(self, EXTRA_COLS + _metadata.fields.size() + ROW_CHECKBOX_COL_IDX, self.get_child_count(), EXTRA_COLS + _metadata.fields.size())

func iter_entries():
    if not _metadata:
        return []
    return Util.MapIterator.new(
        Util.ChildBatchIterator.new(self, EXTRA_COLS + _metadata.fields.size(), EXTRA_COLS + _metadata.fields.size()),
        func(cell_row): return cell_row.slice(EXTRA_COLS).map(func(cell): return cell.cell_value))
#endregion

#region Construct Cells
func _get_cell_scene(column_index: int) -> Control:
    var info := _metadata.fields[column_index]
    match info.type:
        Util.COL_TYPE_BOOL:
            return preload("res://addons/librarian/ui/spreadsheet/cells/bool_cell.tscn").instantiate()
        Util.COL_TYPE_NUM:
            var cell = preload("res://addons/librarian/ui/spreadsheet/cells/number_cell.tscn").instantiate()
            cell.get_inner().format(info)
            return cell
        Util.COL_TYPE_STRING:
            var cell = preload("res://addons/librarian/ui/spreadsheet/cells/string_cell_line_edit.tscn")\
                .instantiate()
            cell.get_inner().format(info)
            return cell
        Util.COL_TYPE_COLOR:
            return preload("res://addons/librarian/ui/spreadsheet/cells/color_cell.tscn").instantiate()
    var wrn := "Failed to parse column type \"%s\" of \"%s\"(row:%d)" % [info.type, info["name"], column_index]
    var placeholder := Label.new()
    placeholder.text = "ERROR"
    placeholder.tooltip_text = wrn
    Util.printwarn(wrn)
    return placeholder

func _get_leading_cells(row_num: int) -> Array[Control]:
    var result : Array[Control] = [CheckBox.new(), TITLE_CELL_SCENE.instantiate()]
    result[1].cell_value = str(row_num)
    result[0].toggled.connect(_on_row_checked)
    return result
#endregion

func get_checked_rows_count() -> int:
    var count := 0
    for checkbox in iter_checkboxes():
        if checkbox.button_pressed:
            count += 1
    return count

func get_checked_rows() -> Array[int]:
    var checked_rows: Array[int] = []
    for tup in Util.EnumerateIterator.new(iter_checkboxes()):
        if tup[1].button_pressed:
            checked_rows.push_back(tup[0])
    return checked_rows

func _shortcut_input(event: InputEvent) -> void:
    if not is_visible_in_tree(): return
    if not event.is_pressed(): return
    if event.is_echo(): return
    var focused_cell = _get_focused_cell_root_or_null()
    if not focused_cell:
        return
    var handled := false
    if Shortcuts.nav_left_edge.matches_event(event):
        var row_index = focused_cell.get_index() / columns
        get_child(row_index * columns).grab_focus()
        handled = true
    elif Shortcuts.nav_right_edge.matches_event(event):
        var row_index = focused_cell.get_index() / columns
        get_child(row_index * columns + columns - 1).grab_focus()
        handled = true
    elif Shortcuts.nav_top_edge.matches_event(event):
        var col_index = focused_cell.get_index() % columns
        get_child(col_index).grab_focus()
        handled = true
    elif Shortcuts.nav_bottom_edge.matches_event(event):
        var col_index = focused_cell.get_index() % columns
        get_child(columns * (get_spreadsheet_row_count() - 1) + col_index).grab_focus()
        handled = true
    elif Shortcuts.nav_sheet_start.matches_event(event):
        get_child(0).grab_focus()
        handled = true
    elif Shortcuts.nav_sheet_end.matches_event(event):
        get_child(get_child_count() - 1).grab_focus()
        handled = true
    elif Shortcuts.exit_sheet.matches_event(event):
        message_bus().sheets_tab_bar_grab_focus.emit()
        handled = true

    if handled:
        get_viewport().set_input_as_handled()

func _get_focused_cell_root_or_null() -> Control:
    var current_focused_control := get_viewport().gui_get_focus_owner()
    if current_focused_control.get_parent() == self:
        return current_focused_control
    if current_focused_control.owner and current_focused_control.owner.get_parent() == self:
        return current_focused_control.owner
    return null

#region Signal Actions
func _on_field_updated(table_id: StringName, field_idx: int) -> void:
    if not _metadata or table_id != _metadata.id:
        return
    for i in range(columns + _extra_columns + field_idx, get_child_count(), columns):
        var old_cell = get_child(i)
        var cell_value = old_cell.cell_value
        var new_cell = _get_cell_scene(field_idx)
        remove_child(old_cell)
        old_cell.queue_free()
        add_child(new_cell)
        move_child(new_cell, i)
        new_cell.cell_value = cell_value

func _on_field_added(table_id: StringName, field_idx: int) -> void:
    if not _metadata or table_id != _metadata.id:
        return
    var total_rows = get_spreadsheet_row_count()
    columns += 1
    var title = TITLE_CELL_SCENE.instantiate()
    add_child(title)
    move_child(title, field_idx + _extra_columns)
    title.cell_value = _metadata.fields[field_idx].name
    for i in range(total_rows):
        var cell = _get_cell_scene(field_idx)
        add_child(cell)
        move_child(cell, ((i + EXTRA_ROWS) * columns) + field_idx + _extra_columns)

func _on_field_deleted(table_id: StringName, field_idx: int) -> void:
    if not _metadata or table_id != _metadata.id:
        return
    for i in range(get_child_count() - spreadsheet_columns + field_idx, -1, -columns):
        var child = get_child(i)
        remove_child(child)
        child.queue_free()
    columns -= 1

func _on_field_moved(table_id: StringName, previous_field_idx: int, new_field_idx: int) -> void:
    if not _metadata or table_id != _metadata.id:
        return
    for i in range(_extra_columns, get_child_count(), columns):
        var child = get_child(i + previous_field_idx)
        move_child(child, i + new_field_idx)

func _on_row_added(table_id: StringName, row_idx: int) -> void:
    if not _metadata or table_id != _metadata.id:
        return
    add_row([], row_idx)

func _on_row_deleted(table_id: StringName, row_idx: int) -> void:
    if not _metadata or table_id != _metadata.id:
        return
    var cell_idx := (EXTRA_ROWS + row_idx) * columns
    for _i in range(columns):
        var child = get_child(cell_idx)
        remove_child(child)
        child.queue_free()

func _on_row_moved(table_id: StringName, previous_row_idx: int, new_row_idx: int) -> void:
    if not _metadata or table_id != _metadata.id:
        return
    push_warning("TODO: implement row move")

func _on_row_checked(_checked: bool) -> void:
    if not _metadata:
        return
    message_bus().row_select_updated.emit(_metadata.id, get_checked_rows_count())
#endregion

func _setup_test_data() -> void:
    pass
