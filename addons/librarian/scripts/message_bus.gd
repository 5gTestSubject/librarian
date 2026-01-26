@tool
extends Node

const AUTOLOAD_NAME := "LibraryMessageBus"
const AUTOLOAD_NODE_PATH := ^"/root/LibraryMessageBus"

signal read_table(table_path: String)
signal open_settings

signal main_screen_table_changed(table_metadata: LibraryTableInfo)

signal field_updated(table_id: StringName, field_idx: int)
## added fields will always be the last field in the metadata's field list
signal field_added(table_id: StringName)
signal field_deleted(table_id: StringName, deleted_field_idx: int)
signal field_moved(table_id: StringName, previous_field_idx: int, new_field_idx: int)

# all rows 0-indexed.
# do not confuse this with the GUI labelling, which 1-indexes.
signal row_added(table_id: StringName)
signal row_deleted(table_id: StringName, row_idx: int)
signal row_moved(table_id: StringName, previous_row_idx: int, new_row_idx: int)
signal row_select_updated(table_id: StringName, selected_row_count: int)

signal sheets_tab_bar_grab_focus
