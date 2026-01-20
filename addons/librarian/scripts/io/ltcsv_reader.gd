@tool
extends RefCounted

const Convert = preload("res://addons/librarian/scripts/convert.gd")
const Util = preload("res://addons/librarian/utils.gd")

var _file_path: String
var _file: FileAccess
var metadata: LibraryTableInfo

func _init(file_path: String):
    _file_path = file_path

func open() -> bool:
    _file = FileAccess.open(_file_path, FileAccess.READ)
    if not _file:
        printerr("Failed to open \"%s\". Code %s." % [_file_path, FileAccess.get_open_error()])
        return false
    metadata = LibraryTableInfo.from_dict(JSON.parse_string(_file.get_csv_line()[0]))
    if not _is_valid(metadata):
        printerr("Failed to open \"%s\". Code %s." % [_file_path, FileAccess.get_open_error()])
        _file.close()
        return false
    return true

func read() -> Array:
    var result = Array(_file.get_csv_line())
    if result.size() == 1 and result[0].is_empty():
        return []
    for i in range(min(result.size(), metadata.fields.size())):
        match metadata.fields[i].type:
            Util.COL_TYPE_BOOL:
                result[i] = Convert.to_bool(result[i])
            Util.COL_TYPE_NUM:
                result[i] = Convert.to_number(result[i])
            Util.COL_TYPE_STRING:
                result[i] = Convert.to_text(result[i])
            Util.COL_TYPE_COLOR:
                result[i] = Convert.to_color(result[i])
            _:
                result[i] = false
    return result

func close() -> void:
    _file.close()
    
static func _is_valid(library_table_info: LibraryTableInfo) -> bool:
    printerr("TODO: validate parsed metadata")
    return true
