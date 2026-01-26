@tool
extends RefCounted

const Convert = preload("res://addons/librarian/scripts/convert.gd")
const Util = preload("res://addons/librarian/utils.gd")

var _file: FileAccess
var metadata: LibraryTableInfo

func _init(file: FileAccess, metadata: LibraryTableInfo):
    _file = file
    self.metadata = metadata

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
