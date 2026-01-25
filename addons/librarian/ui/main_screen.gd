@tool
extends Container

func message_bus(): return get_node(preload("res://addons/librarian/scripts/message_bus.gd").AUTOLOAD_NODE_PATH)
const Properties = preload("res://addons/librarian/properties.gd")
const Shortcuts = preload("res://addons/librarian/shortcuts.gd")
const TableAccess = preload("res://addons/librarian/scripts/io/table_access.gd")
const Util = preload("res://addons/librarian/utils.gd")

const SETTINGS_ID := ".settings"

@export var close_sheet_icon: Texture2D

func _ready() -> void:
    message_bus().sheets_tab_bar_grab_focus.connect(func(): %EditorTabs.get_tab_bar().grab_focus())
    message_bus().open_table.connect(_open_table)
    message_bus().open_settings.connect(_open_settings)
    message_bus().main_screen_table_changed.connect(
        func(_table_metadata):
            if Engine.is_editor_hint():
                EditorInterface.set_main_screen_editor(Util.MAIN_SCREEN_NAME))

func _open_table(table_path: String) -> void:
    var tab_idx = _find_editor_tab(table_path)
    if tab_idx >= 0:
        %EditorTabs.current_tab = tab_idx
        return
    var table_reader = TableAccess.get_table_reader(table_path)
    table_reader.open()
    var metadata = table_reader.metadata
    table_reader.close()

    var sheet = preload(
        "res://addons/librarian/ui/spreadsheet/spreadsheet_editor_tab.tscn"
    ).instantiate()
    sheet.name = metadata.name
    _new_editor_tab(sheet,{
        "id": table_path,
        "table_metadata": metadata
    })

func _open_settings() -> void:
    var idx := _find_editor_tab(SETTINGS_ID)
    if idx >= 0:
        %EditorTabs.current_tab = idx
        return
    var settings = preload("res://addons/librarian/ui/library_settings/library_settings_editor_tab.tscn").instantiate()
    settings.name = "Settings"
    _new_editor_tab(settings, {
        "id": ".library_settings"
    })

func _new_editor_tab(tab: Control, tab_metadata: Dictionary, focus_new: bool = true) -> void:
    %EditorTabs.add_child(tab)
    var new_tab_idx = %EditorTabs.get_tab_count() - 1
    %EditorTabs.set_tab_button_icon(new_tab_idx, close_sheet_icon)
    %EditorTabs.set_tab_metadata(new_tab_idx, tab_metadata)
    if focus_new:
        %EditorTabs.current_tab = new_tab_idx
    message_bus().main_screen_table_changed.emit(tab_metadata.get("table_metadata"))
    tab.load_content(tab_metadata.get("id"))

## Searches existing open sheets for one that has opened the given path.
## Returns the tab index of that sheet, or -1 if not found.
func _find_editor_tab(id: String) -> int:
    for i in range(%EditorTabs.get_tab_count()):
        var metadata = %EditorTabs.get_tab_metadata(i)
        if metadata and metadata["id"] == id:
            return i
    return -1

func _get_active_spreadsheet():
    return %EditorTabs.get_tab(%EditorTabs.current_tab)

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
    if %EditorTabs.get_tab_count() < 1:
        return null
    var tab_metadata := %EditorTabs.get_tab_metadata(%EditorTabs.current_tab) as Dictionary
    if not tab_metadata:
        return null
    return tab_metadata.get("table_metadata")

func _on_editor_tab_bar_button_pressed(tab: int) -> void:
    %EditorTabs.remove_tab(tab)

func _shortcut_input(event: InputEvent) -> void:
    if not is_visible_in_tree(): return
    if not event.is_pressed(): return
    if event.is_echo(): return
    var handled := false
    if Shortcuts.save_sheet.matches_event(event) or Shortcuts.save_sheet_alt.matches_event(event):
        var sheet = %TabsContainer.get_tab(%TabsContainer.current_tab_focus)
        if sheet:
            sheet.save_content()
            handled = true
    elif Shortcuts.save_all_sheets.matches_event(event):
        for i in range(%TabsContainer.count()):
            var sheet = %TabsContainer.get_tab(i)
            if sheet:
                sheet.save_content()
                handled = true
    if handled:
        get_viewport().set_input_as_handled()
