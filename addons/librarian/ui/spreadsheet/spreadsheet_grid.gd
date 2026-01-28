@tool
extends GridContainer

const Shortcuts = preload("res://addons/librarian/shortcuts.gd")
const Util = preload("res://addons/librarian/utils.gd")
const TITLE_CELL_SCENE = preload("res://addons/librarian/ui/spreadsheet/cells/column_title.tscn")

## Extra columns for numbering rows and giving them checkboxes.
const EXTRA_COLS := 2
## One extra row for titleing columns.
const EXTRA_ROWS := 1

const ROW_CHECKBOX_COL_IDX := 0
const ROW_NUM_COL_IDX := 1

@export var _metadata: LibraryTableInfo

var _hide_row_checkboxes := false
var _hide_row_nums := false
var _hidden_field_idxs := {}

func _ready() -> void:
    LibraryMessageBus.field_updated.connect(_on_field_updated)
    LibraryMessageBus.field_added.connect(_on_field_added)
    LibraryMessageBus.field_deleted.connect(_on_field_deleted)
    LibraryMessageBus.field_moved.connect(_on_field_moved)
    LibraryMessageBus.row_added.connect(_on_row_added)
    LibraryMessageBus.row_deleted.connect(_on_row_deleted)
    LibraryMessageBus.row_moved.connect(_on_row_moved)

func get_metadata() -> LibraryTableInfo:
    return _metadata

func reset_table(metadata: LibraryTableInfo) -> void:
    clear_grid()
    _metadata = metadata
    if not _metadata:
        return
    _adjust_grid_container_columns()
    for _i in range(EXTRA_COLS):
        add_child(Control.new())
    for field in _metadata.fields:
        var title = TITLE_CELL_SCENE.instantiate()
        add_child(title)
        title.cell_value = field.name

func clear_grid() -> void:
    while get_child_count() > 0:
        var child := get_child(0)
        remove_child(child)
        child.queue_free()

func add_row(data: Array) -> void:
    if not _metadata:
        return
    for leading_cell in _get_leading_cells(get_spreadsheet_row_count() + 1):
        add_child(leading_cell)
    for i in range(_metadata.fields.size()):
        var cell = _get_cell_scene(i)
        add_child(cell)
        if i < data.size():
            cell.cell_value = data[i]
        if _hidden_field_idxs.has(i):
            cell.visible = false

func get_spreadsheet_row_count() -> int:
    if not _metadata:
        return EXTRA_COLS
    return _calculate_spreadsheet_rows(get_child_count(), _metadata.fields.size())

func get_spreadsheet_width() -> int:
    if not _metadata:
        return EXTRA_COLS
    return _calculate_spreadsheet_width(_metadata.fields.size())

static func _calculate_spreadsheet_rows(child_count: int, field_count: int) -> int:
    return (child_count / (EXTRA_COLS + field_count)) - EXTRA_ROWS

static func _calculate_spreadsheet_width(field_count: int) -> int:
    return EXTRA_COLS + field_count

func get_spreadsheet_cell_count() -> int:
    if not _metadata:
        return 0
    return get_spreadsheet_row_count() * _metadata.fields.size()

#region Hidden Columns
# Hidden columns are solely to do with cell visibility. It has no effect on any programatic operations.

func set_checkbox_visibility(visible: bool) -> void:
    _hide_row_checkboxes = not visible
    for control in Util.ChildIterator.new(self, ROW_CHECKBOX_COL_IDX, self.get_child_count(), get_spreadsheet_width()):
        control.visible = visible
    _adjust_grid_container_columns()

func set_row_num_visibility(visible: bool) -> void:
    _hide_row_nums = not visible
    for control in Util.ChildIterator.new(self, ROW_NUM_COL_IDX, self.get_child_count(), get_spreadsheet_width()):
        control.visible = visible
    _adjust_grid_container_columns()

func set_field_visibility(field_idx: int, visible: bool) -> void:
    if visible:
        _hidden_field_idxs.erase(field_idx)
    else:
        _hidden_field_idxs[field_idx] = null
    for control in Util.ChildIterator.new(self, EXTRA_COLS + field_idx, self.get_child_count(), get_spreadsheet_width()):
        control.visible = visible
    _adjust_grid_container_columns()

func _adjust_grid_container_columns() -> void:
    columns = get_spreadsheet_width() - _hidden_field_idxs.size() - int(_hide_row_checkboxes) - int(_hide_row_nums)
#endregion

#region Iteration
## Iterates over every cell in a column of the grid, not including the title cell.
## Iterates over the cell Controls.
## Cell values can be accessed by calling `.cell_value` on each element of the iteration.
func iter_field_cells(field_idx: int):
    if not _metadata:
        return []
    return Util.ChildIterator.new(
        self,
        get_spreadsheet_width() + EXTRA_COLS + field_idx,
        self.get_child_count(),
        get_spreadsheet_width())

## Iterates over each row's CheckBox.
func iter_checkboxes():
    if not _metadata:
        return []
    return Util.ChildIterator.new(self, get_spreadsheet_width() + ROW_CHECKBOX_COL_IDX, self.get_child_count(), get_spreadsheet_width())

## Iterates over data entries in the grid.
## Data entries are arrays of cell values, where each array is one row.
## Data entries do not include the title row.
func iter_entries():
    if not _metadata:
        return []
    return Util.MapIterator.new(
        Util.ChildBatchIterator.new(self, get_spreadsheet_width(), get_spreadsheet_width()),
        func(cell_row): return cell_row.slice(EXTRA_COLS).map(func(cell): return cell.cell_value))
#endregion

#region Construct Cells
func _get_cell_scene(column_index: int) -> Control:
    var info := _metadata.fields[column_index]
    match info.type:
        Util.COL_TYPE_TAGS:
            return preload("res://addons/librarian/ui/spreadsheet/cells/tags_cell.tscn").instantiate()
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
    var checkbox := CheckBox.new()
    checkbox.toggled.connect(_on_row_checked)
    checkbox.visible = not _hide_row_checkboxes
    var row_number := TITLE_CELL_SCENE.instantiate()
    row_number.cell_value = str(row_num)
    row_number.visible = not _hide_row_nums
    return [checkbox, row_number]
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

# func _shortcut_input(event: InputEvent) -> void:
#     if not is_visible_in_tree(): return
#     if not event.is_pressed(): return
#     if event.is_echo(): return
#     var focused_cell = _get_focused_cell_root_or_null()
#     if not focused_cell:
#         return
#     var handled := false
#     if Shortcuts.nav_left_edge.matches_event(event):
#         var row_index = focused_cell.get_index() / columns
#         get_child(row_index * columns).grab_focus()
#         handled = true
#     elif Shortcuts.nav_right_edge.matches_event(event):
#         var row_index = focused_cell.get_index() / columns
#         get_child(row_index * columns + columns - 1).grab_focus()
#         handled = true
#     elif Shortcuts.nav_top_edge.matches_event(event):
#         var col_index = focused_cell.get_index() % columns
#         get_child(col_index).grab_focus()
#         handled = true
#     elif Shortcuts.nav_bottom_edge.matches_event(event):
#         var col_index = focused_cell.get_index() % columns
#         get_child(columns * (get_spreadsheet_row_count() - 1) + col_index).grab_focus()
#         handled = true
#     elif Shortcuts.nav_sheet_start.matches_event(event):
#         get_child(0).grab_focus()
#         handled = true
#     elif Shortcuts.nav_sheet_end.matches_event(event):
#         get_child(get_child_count() - 1).grab_focus()
#         handled = true
#     elif Shortcuts.exit_sheet.matches_event(event):
#         LibraryMessageBus.sheets_tab_bar_grab_focus.emit()
#         handled = true

#     if handled:
#         get_viewport().set_input_as_handled()

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
    for old_cell in iter_field_cells(field_idx):
        var old_cell_idx = old_cell.get_index()
        var cell_value = old_cell.cell_value
        remove_child(old_cell)
        old_cell.queue_free()
        var new_cell = _get_cell_scene(field_idx)
        add_child(new_cell)
        move_child(new_cell, old_cell_idx)
        new_cell.cell_value = cell_value
        if _hidden_field_idxs.has(field_idx):
            new_cell.visible = false

func _on_field_added(table_id: StringName) -> void:
    if not _metadata or table_id != _metadata.id:
        return
    _adjust_grid_container_columns()
    var field_idx = _metadata.fields.size() - 1
    var total_rows = _calculate_spreadsheet_rows(get_child_count(), _metadata.fields.size() - 1)
    var title = TITLE_CELL_SCENE.instantiate()
    add_child(title)
    move_child(title, EXTRA_COLS + field_idx)
    title.cell_value = _metadata.fields[field_idx].name
    for i in range(total_rows):
        var cell = _get_cell_scene(field_idx)
        add_child(cell)
        move_child(cell, (i + EXTRA_ROWS) * get_spreadsheet_width() + EXTRA_COLS + field_idx)

func _on_field_deleted(table_id: StringName, field_idx: int) -> void:
    _hidden_field_idxs.erase(field_idx)
    if not _metadata or table_id != _metadata.id:
        return
    var old_width := _calculate_spreadsheet_width(_metadata.fields.size() + 1)
    for i in range(get_child_count() - old_width + EXTRA_COLS + field_idx, -1, -old_width):
        var child = get_child(i)
        remove_child(child)
        child.queue_free()
    _adjust_grid_container_columns()

func _on_field_moved(table_id: StringName, previous_field_idx: int, new_field_idx: int) -> void:
    if not _metadata or table_id != _metadata.id:
        return
    for i in range(EXTRA_COLS, get_child_count(), get_spreadsheet_width()):
        var child = get_child(i + previous_field_idx)
        move_child(child, i + new_field_idx)

func _on_row_added(table_id: StringName) -> void:
    if not _metadata or table_id != _metadata.id:
        return
    add_row([])

func _on_row_deleted(table_id: StringName, row_idx: int) -> void:
    if not _metadata or table_id != _metadata.id:
        return
    var cell_idx := (EXTRA_ROWS + row_idx) * get_spreadsheet_width()
    for _i in range(get_spreadsheet_width()):
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
    LibraryMessageBus.row_select_updated.emit(_metadata.id, get_checked_rows_count())
#endregion

func _setup_test_data() -> void:
    pass
