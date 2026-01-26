@tool

const Properties = preload("res://addons/librarian/properties.gd")
const Util = preload("res://addons/librarian/utils.gd")
const UUID = preload("res://addons/librarian/scripts/uuid.gd")

const LTCSV_FILE_EXTENSION := ".ltcsv"

const VERSION_STRING = "pre-alpha"

static func to_ltcsv_filepath(table_path: String) -> String:
    return Util.path_combine(Properties.get_library_location(), table_path + LTCSV_FILE_EXTENSION)

static func read_table(table_path: String):
    var file_path := to_ltcsv_filepath(table_path)
    var file := FileAccess.open(file_path, FileAccess.READ)
    if not file:
        printerr("Failed to open \"%s\". Code %s." % [file_path, FileAccess.get_open_error()])
        return null
    var version_string := file.get_line()
    if version_string != VERSION_STRING:
        printerr("Unrecognized file header: " + file_path)
        return null
    var metadata := LibraryTableInfo.from_dict(JSON.parse_string(file.get_line()))
    return preload("res://addons/librarian/scripts/io/ltcsv_reader_prealpha.gd").new(file ,metadata)

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
