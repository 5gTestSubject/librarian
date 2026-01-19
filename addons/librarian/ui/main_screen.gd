@tool
extends Container

func message_bus(): return get_node(preload("res://addons/librarian/scripts/message_bus.gd").AUTOLOAD_NODE_PATH)
const TableAccess = preload("res://addons/librarian/scripts/io/table_access.gd")
const Properties = preload("res://addons/librarian/properties.gd")
const Shortcuts = preload("res://addons/librarian/shortcuts.gd")
const Util = preload("res://addons/librarian/utils.gd")

@export var close_sheet_icon: Texture2D

func _ready() -> void:
    message_bus().sheets_tab_bar_grab_focus.connect(func(): %SpreadsheetsTabBar.grab_focus())
    message_bus().open_table.connect(_open_table)
    message_bus().main_screen_table_changed.connect(
        func(_table_metadata):
            if Engine.is_editor_hint():
                EditorInterface.set_main_screen_editor(Util.MAIN_SCREEN_NAME))
    message_bus().row_select_updated.connect(_on_row_select_updated)

func _open_table(path: String) -> void:
    var sheet_idx = _find_sheet(path)
    if sheet_idx >= 0:
        %SpreadsheetsTabBar.current_tab = sheet_idx
        return
    var table_reader = TableAccess.get_table_reader(path)
    table_reader.open()
    var metadata = table_reader.metadata
    table_reader.close()

    var sheet = preload(
        "res://addons/librarian/ui/spreadsheet/spreadsheet_container.tscn"
    ).instantiate()
    %SpreadsheetsContainer.add_child(sheet)
    sheet.name = metadata.name

    %SpreadsheetsTabBar.add_tab(metadata.name)
    var new_tab_idx = %SpreadsheetsTabBar.tab_count - 1
    %SpreadsheetsTabBar.set_tab_button_icon(new_tab_idx, close_sheet_icon)
    %SpreadsheetsTabBar.set_tab_metadata(new_tab_idx, {
        "path": path,
        "table_metadata": metadata
    })

    %SpreadsheetsTabBar.current_tab = new_tab_idx
    ## edge case on creation of first tab
    if %SpreadsheetsTabBar.tab_count == 1:
        _on_spreadsheets_tab_bar_tab_changed(0)
    message_bus().main_screen_table_changed.emit(table_reader.metadata)
    sheet.load_table(path)

## Searches existing open sheets for one that has opened the given path.
## Returns the tab index of that sheet, or -1 if not found.
func _find_sheet(path: String) -> int:
    for i in range(%SpreadsheetsTabBar.tab_count):
        var metadata = %SpreadsheetsTabBar.get_tab_metadata(i)
        if metadata and metadata["path"] == path:
            return i
    return -1

func _is_spreadsheet_active() -> bool:
    if %SpreadsheetsTabBar.current_tab < 0:
        Util.printwarn("No open spreadsheet.")
        return false
    return true

func _get_active_spreadsheet():
    return %SpreadsheetsContainer.get_spreadsheet(%SpreadsheetsContainer.current_spreadsheet_focus)

func _evaluate_active_controls():
    var table = _get_active_spreadsheet()
    for node in get_tree().get_nodes_in_group("table_operator"):
        if node is BaseButton:
            node.disabled = not table
    var row_operators_enabled = false if not table else table.get_checked_rows_count()
    for node in get_tree().get_nodes_in_group("table_rows_operator"):
        if node is BaseButton:
            node.disabled = not row_operators_enabled

func _get_active_spreadsheet_metadata() -> LibraryTableInfo:
    if not _is_spreadsheet_active():
        return null
    var tab_metadata := %SpreadsheetsTabBar.get_tab_metadata(%SpreadsheetsTabBar.current_tab) as Dictionary
    if not tab_metadata:
        return null
    return tab_metadata.get("table_metadata")

func _on_spreadsheets_tab_bar_tab_changed(tab:int) -> void:
    if tab < 0 or tab >= %SpreadsheetsTabBar.tab_count:
        _evaluate_active_controls()
        message_bus().main_screen_table_changed.emit(null)
        return
    var metadata = %SpreadsheetsTabBar.get_tab_metadata(tab)
    ## edge case on creation of first tab
    if not metadata:
        return
    %SpreadsheetsContainer.current_spreadsheet_focus = tab
    message_bus().main_screen_table_changed.emit(metadata["table_metadata"])
    _evaluate_active_controls()

func _on_spreadsheets_tab_bar_button_pressed(tab: int) -> void:
    %SpreadsheetsContainer.remove_spreadsheet(tab)
    %SpreadsheetsTabBar.remove_tab(tab)

func _on_spreadsheets_tab_bar_active_tab_rearranged(_idx_to:int) -> void:
    var ids: Array[int] = []
    ids.resize(%SpreadsheetsTabBar.tab_count)
    for i in range(%SpreadsheetsTabBar.tab_count):
        ids[i] = %SpreadsheetsTabBar.get_tab_metadata(i)["table_metadata"].id
    %SpreadsheetsContainer.sort_spreadsheets(ids)
    pass # _on_spreadsheets_tab_bar_tab_changed(%SpreadsheetsTabBar.current_tab)

func _on_new_row_button_pressed() -> void:
    var table_metadata = _get_active_spreadsheet_metadata()
    if not table_metadata:
        return
    message_bus().row_added.emit(table_metadata.id, -1)

func _on_delete_selected_rows_button_pressed() -> void:
    _evaluate_active_controls()
    var table = _get_active_spreadsheet()
    if not table:
        return
    var checked_rows: Array[int] = table.get_checked_rows()
    checked_rows.sort()
    checked_rows.reverse()
    for row_idx in checked_rows:
        message_bus().row_deleted.emit(_get_active_spreadsheet_metadata().id, row_idx)

func _on_row_select_updated(_table_id: StringName, _selected_row_count: int) -> void:
    _evaluate_active_controls()

func _shortcut_input(event: InputEvent) -> void:
    if not is_visible_in_tree(): return
    if not event.is_pressed(): return
    if event.is_echo(): return
    var handled := false
    if Shortcuts.save_sheet.matches_event(event) or Shortcuts.save_sheet_alt.matches_event(event):
        var sheet = %SpreadsheetsContainer.get_spreadsheet(%SpreadsheetsContainer.current_spreadsheet_focus)
        if sheet:
            sheet.save_table()
            handled = true
    elif Shortcuts.save_all_sheets.matches_event(event):
        for i in range(%SpreadsheetsContainer.get_spreadsheet_count()):
            var sheet = %SpreadsheetsContainer.get_spreadsheet(i)
            if sheet:
                sheet.save_table()
                handled = true
    if handled:
        get_viewport().set_input_as_handled()
