@tool
extends RefCounted

const Convert = preload("res://addons/librarian/scripts/convert.gd")
const Util = preload("res://addons/librarian/utils.gd")

var _file_path: String
var _file: FileAccess

func _init(file_path: String):
    _file_path = file_path

func open(metadata: LibraryTableInfo) -> bool:
    _file = FileAccess.open(_file_path, FileAccess.WRITE)
    if not _file:
        printerr("Failed to open \"%s\". Code %s." % [_file_path, FileAccess.get_open_error()])
        return false
    _file.store_csv_line([JSON.stringify(metadata.to_dict())])
    return true

func write(row_values: Array) -> bool:
    return _file.store_csv_line(row_values.map(Convert.to_text))

func flush() -> void:
    _file.flush()

func close() -> void:
    _file.close()
