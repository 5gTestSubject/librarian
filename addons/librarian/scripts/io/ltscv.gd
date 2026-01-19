@tool

const Properties = preload("res://addons/librarian/properties.gd")
const Util = preload("res://addons/librarian/utils.gd")
const UUID = preload("res://addons/librarian/scripts/uuid.gd")

const LTCSV_FILE_EXTENSION := ".ltcsv"

static func to_ltcsv_filepath(table_path: String) -> String:
    return Util.path_combine(Properties.get_library_location(), table_path + LTCSV_FILE_EXTENSION)

static func get_table_reader(table_path: String):
    return preload("res://addons/librarian/scripts/io/ltcsv_reader.gd").new(to_ltcsv_filepath(table_path))

static func get_table_writer(table_path: String):
    return preload("res://addons/librarian/scripts/io/ltcsv_writer.gd").new(to_ltcsv_filepath(table_path))

static func create_table(table_path: String, name: String) -> bool:
    var file_path := to_ltcsv_filepath(table_path)
    if FileAccess.file_exists(file_path):
        return false
    var metadata = LibraryTableInfo.new()
    metadata.id = UUID.v4()
    metadata.name = name
    var writer = get_table_writer(table_path)
    writer.open(metadata)
    writer.flush()
    writer.close()
    return true

static func delete_table(table_path: String) -> void:
    DirAccess.remove_absolute(to_ltcsv_filepath(table_path))
