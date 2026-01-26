@tool
extends RefCounted

const Convert = preload("res://addons/librarian/scripts/convert.gd")
const Util = preload("res://addons/librarian/utils.gd")

var _file: FileAccess
var metadata: LibraryTableInfo

func _init(file: FileAccess, metadata: LibraryTableInfo):
    _file = file
    self.metadata = metadata

func write(row_values: Array) -> bool:
    return _file.store_csv_line(row_values.map(Convert.to_text))

func flush() -> void:
    _file.flush()

func close() -> void:
    _file.close()
