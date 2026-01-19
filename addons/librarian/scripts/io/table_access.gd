## Provides operations on table storage.
##
## Currently, all operations operate exclusively on ltcsv files.
## Other file types or storage operations may become available. In that case, this script
## will determine which implementation to forward the call to based on some identifier.

@tool

const ltcsv = preload("res://addons/librarian/scripts/io/ltscv.gd")

static func get_table_reader():
    return ltcsv.get_table_reader()

static func get_table_writer():
    return ltcsv.get_table_writer()

static func create_table(table_path: String, name: String) -> bool:
    return ltcsv.create_table(table_path, name)

static func delete_table(table_path: String) -> void:
    return ltcsv.delete_table(table_path)