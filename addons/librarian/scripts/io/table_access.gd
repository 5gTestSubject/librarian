@tool
class_name LibraryTableAccess

## Provides operations on table storage.
##
## Currently, all operations operate exclusively on ltcsv files.
## Other file types or storage operations may become available. In that case, this script
## will determine which implementation to forward the call to based on some identifier.

const ltcsv = preload("res://addons/librarian/scripts/io/ltcsv.gd")

static func read_table(table_path: String):
    return ltcsv.read_table(table_path)

static func write_table(table_path: String, metadata: LibraryTableInfo):
    return ltcsv.write_table(table_path, metadata)

static func create_table(table_path: String, name: String) -> bool:
    return ltcsv.create_table(table_path, name)

static func delete_table(table_path: String) -> void:
    return ltcsv.delete_table(table_path)
