@tool
extends Node

const AUTOLOAD_NAME := "LibrarianMessageBus"
const AUTOLOAD_NODE_PATH := ^"/root/LibrarianMessageBus"

signal open_table(table_path: String)

signal main_screen_table_changed(table_metadata: LibraryTableInfo)

signal field_updated(table_id: int, field_idx: int)
signal field_added(table_id: int, field_idx: int)
signal field_deleted(table_id: int, deleted_field_idx: int)
signal field_moved(table_id: int, previous_field_idx: int, new_field_idx: int)

# all rows 0-indexed.
# do not confuse this with the GUI labelling, which 1-indexes.
signal row_added(table_id: int, row_idx: int)
signal row_deleted(table_id: int, row_idx: int)
signal row_moved(table_id: int, previous_row_idx: int, new_row_idx: int)
signal row_select_updated(table_id: int, selected_row_count: int)

signal sheets_tab_bar_grab_focus
