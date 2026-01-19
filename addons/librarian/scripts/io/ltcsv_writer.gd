@tool
extends RefCounted

const Convert = preload("res://addons/librarian/scripts/convert.gd")
const Util = preload("res://addons/librarian/utils.gd")

var _file: FileAccess

func open(file_path: String, metadata: LibraryTableInfo) -> bool:
    _file = FileAccess.open(file_path, FileAccess.WRITE)
    if not _file:
        printerr("Failed to open \"%s\". Code %s." % [file_path, FileAccess.get_open_error()])
        return false
    _file.store_csv_line([JSON.stringify(metadata.to_dict())])
    return true

func write(row_values: Array) -> bool:
    return _file.store_csv_line(row_values.map(Convert.to_text))

func flush() -> void:
    _file.flush()

func close() -> void:
    _file.close()
