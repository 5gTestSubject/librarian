@tool
extends Container

const Properties = preload("res://addons/librarian/properties.gd")
const Shortcuts = preload("res://addons/librarian/shortcuts.gd")
const TableAccess = preload("res://addons/librarian/scripts/io/table_access.gd")
const Util = preload("res://addons/librarian/utils.gd")

const SETTINGS_ID := ".settings"

@export var close_sheet_icon: Texture2D

func _ready() -> void:
    LibraryMessageBus.sheets_tab_bar_grab_focus.connect(func(): %EditorTabs.get_tab_bar().grab_focus())
    LibraryMessageBus.read_table.connect(_open_table)
    LibraryMessageBus.open_settings.connect(_open_settings)
    LibraryMessageBus.main_screen_table_changed.connect(
        func(_table_metadata):
            if Engine.is_editor_hint():
                EditorInterface.set_main_screen_editor(Util.MAIN_SCREEN_NAME))

func _open_table(table_path: String) -> void:
    var tab_idx = _find_editor_tab(table_path)
    if tab_idx >= 0:
        %EditorTabs.current_tab = tab_idx
        return

    var sheet = preload(
        "res://addons/librarian/ui/spreadsheet/spreadsheet_editor_tab.tscn"
    ).instantiate()

    var table_reader = TableAccess.read_table(table_path)
    sheet.name = table_reader.metadata.name
    table_reader.close()

    _new_editor_tab(sheet,{
        "id": table_path,
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
    tab.load_content(tab_metadata.get("id"))

## Searches existing open sheets for one that has opened the given path.
## Returns the tab index of that sheet, or -1 if not found.
func _find_editor_tab(id: String) -> int:
    for i in range(%EditorTabs.get_tab_count()):
        var metadata = %EditorTabs.get_tab_metadata(i)
        if metadata and metadata["id"] == id:
            return i
    return -1

func _on_editor_tab_bar_button_pressed(tab: int) -> void:
    %EditorTabs.remove_tab(tab)

func _on_editor_tab_changed(tab: int) -> void:
    var control = %EditorTabs.get_tab_control(tab)
    if control and control.has_method(&"on_editor_tab_selected"):
        control.on_editor_tab_selected()

func _shortcut_input(event: InputEvent) -> void:
    if not is_visible_in_tree(): return
    if not event.is_pressed(): return
    if event.is_echo(): return
    var handled := false
    var tab_open: bool = %EditorTabs.current_tab >= 0
    if tab_open and (Shortcuts.save_sheet.matches_event(event) or Shortcuts.save_sheet_alt.matches_event(event)):
        var tab: Control = %EditorTabs.get_current_tab_control()
        if tab and tab.has_method(&"save_content"):
            tab.save_content()
            handled = true
    elif %EditorTabs.get_tab_count() > 0 and Shortcuts.save_all_sheets.matches_event(event):
        for i in range(%EditorTabs.get_tab_count()):
            var tab = %EditorTabs.get_tab_control(i)
            if tab and tab.has_method(&"save_content"):
                tab.save_content()
                handled = true
    if handled:
        get_viewport().set_input_as_handled()
