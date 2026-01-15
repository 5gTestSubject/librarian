@tool

const MAX_INT := 2147483647

const COL_TYPE_BOOL := &"bool"
const COL_TYPE_NUM := &"number"
const COL_TYPE_STRING := &"string"

const COL_TYPEHINT_LINE_EDIT := &"LineEdit"
const COL_TYPEHINT_TEXT_EDIT := &"TextEdit"
const COL_TYPEHINT_INTEGER := &"Integer"
const COL_TYPEHINT_DECIMAL := &"Decimal"

const MAIN_SCREEN_NAME = "Librarian"

const MetadataSuffx := ".metadata.json"

static func printwarn(msg: String) -> void:
    print_rich("[color=Yellow]%s[/color]" % msg)

static func path_combine(path1: String, path2: String) -> String:
    return path1.trim_suffix("/") + "/" + path2.trim_prefix("/")

#region Table Operations
#region Create
static func create_table(data_path: String, name: String, description: String = "") -> void:
    if FileAccess.file_exists(data_path + MetadataSuffx):
        if not FileAccess.file_exists(data_path):
            var file = FileAccess.open(data_path, FileAccess.WRITE)
            file.flush()
            file.close()
        return
    var metadata = LibraryTableInfo.new()
    metadata.name = name
    metadata.description = description
    save_metadata(data_path + MetadataSuffx, metadata)
    var file = FileAccess.open(data_path, FileAccess.WRITE)
    file.flush()
    file.close()

#endregion

#region Delete
static func delete_table(data_path: String) -> void:
    if FileAccess.file_exists(data_path + MetadataSuffx):
        DirAccess.remove_absolute(data_path + MetadataSuffx)
    if FileAccess.file_exists(data_path):
        DirAccess.remove_absolute(data_path)
#endregion

#region Load
static func load_metadata(data_path: String) -> LibraryTableInfo:
    var metadata = LibraryTableInfo.new()
    if FileAccess.file_exists(data_path + MetadataSuffx):
        var raw_metadata = JSON.parse_string(
            FileAccess.get_file_as_string(data_path + MetadataSuffx))
        metadata = LibraryTableInfo.from_dict(raw_metadata)
    return metadata

## Loads a table fom the given path using the provided metadata
## Returns an iterator of data rows in the table
static func load_table(path: String, metadata: LibraryTableInfo) -> CsvDeserializationIterator:
    return CsvDeserializationIterator.new(
        load_raw_table(path),
        func(row: PackedStringArray): return parse_row(metadata, row))

## Loads CSV text line-by-line.
## Returns an iterator of those lines.
static func load_raw_table(path: String) -> CsvFileIterator:
    return CsvFileIterator.new(path)

static func parse_row(metadata: LibraryTableInfo, row: PackedStringArray) -> Array:
    if row.size() == 0 or (row.size() == 1 and row[0] == ""): return []
    var parsed_row := []
    for i in range(metadata.fields.size()):
        match metadata.fields[i].type:
            COL_TYPE_BOOL:
                parsed_row.push_back(bool(int(row[i])))
            COL_TYPE_NUM:
                parsed_row.push_back(float(row[i]))
            COL_TYPE_STRING:
                parsed_row.push_back(row[i])
            _:
                printwarn("Unrecognized column type %s. CSV value: %s"
                    % [metadata.fields[i].type, row[i]])
    return parsed_row
#endregion

#region Save
## Saves a table to disk, along with it's metadata.
## Null metadata will leave the existing metadata alone on disk.
## If no metadata exists on disk and no metadata is provided,
## dummy metadata will be written to disk.
static func save_table(path: String, metadata: LibraryTableInfo, row_data_iterator) -> void:
    save_metadata(path + MetadataSuffx, metadata)

    var file = FileAccess.open(path, FileAccess.WRITE)
    for line in CsvSerializationIterator.new(row_data_iterator, convert_to_string):
        file.store_csv_line(line)
    file.flush()
    file.close()

static func save_metadata(metadata_path: String, metadata: LibraryTableInfo) -> void:
    if metadata == null and !FileAccess.file_exists(metadata_path):
        metadata = LibraryTableInfo.new()

    var metadata_file = FileAccess.open(metadata_path, FileAccess.WRITE)
    metadata_file.store_string(JSON.stringify(metadata.to_dict(), "  ", true))
    metadata_file.flush()
    metadata_file.close()
#endregion
#endregion

#region Conversions
static func convert_to_bool(value) -> bool:
    match(typeof(value)):
        TYPE_NIL: return false
        TYPE_BOOL: return value
        TYPE_INT: return bool(value)
        TYPE_FLOAT: return bool(value)
        TYPE_STRING:
            if value.to_lower() == "false": return false
            if value == "0": return false
            return not value.is_empty()
        _: return false

static func convert_to_number(value) -> float:
    match(typeof(value)):
        TYPE_NIL: return 0.0
        TYPE_BOOL: return 1.0 if value else 0.0
        TYPE_INT: return float(value)
        TYPE_FLOAT: return value
        TYPE_STRING: return value.to_float()
        _: return 0.0

static func convert_to_string(value) -> String:
    match typeof(value):
        TYPE_NIL: return ""
        # serialize bools as 1/0 instead of true/false
        TYPE_BOOL:
            return str(int(value))
        # don't serialize the decimal points if unneeded
        TYPE_FLOAT:
            return str(int(value)) if int(value) == value else str(value)
        _:
            return str(value)
#endregion

#region Compare Metadata
## Returns a 3-array of the following structure.
## 0. columns in left that aren't present in right
## 1. columns in right that aren't present in left
## 2. columns that are present in both and are unchanged
## 3. columns that are present in both and are changed
##
## Each of those elements is an Array[int] of column IDs.
static func compare_column_sets(left_arr: Array[LibraryTableFieldInfo], right_arr: Array[LibraryTableFieldInfo]) -> Array:
    var left := _cols_array_to_dict(left_arr)
    var right := _cols_array_to_dict(right_arr)

    var common_ids = _get_common_ids(left, right)
    var unchanged: Array[int] = []
    var changed: Array[int] = []
    for id in common_ids:
        if left[id].equivalent_to(right[id]):
            unchanged.append(id)
        else:
            changed.append(id)

    return [
        _get_exclusive_ids(left, right),
        _get_exclusive_ids(right, left),
        unchanged,
        changed
    ]

static func _cols_array_to_dict(arr: Array[LibraryTableFieldInfo]) -> Dictionary[int, LibraryTableFieldInfo]:
    var dict: Dictionary[int, LibraryTableFieldInfo] = {}
    for field in arr:
        dict[field.id] = field
    return dict

static func _get_exclusive_ids(target: Dictionary[int, LibraryTableFieldInfo], comparison: Dictionary[int, LibraryTableFieldInfo]) -> Array[int]:
    var ret: Array[int] = []
    for id in target:
        if not comparison.has(id):
            ret.append(id)
    ret.sort()
    return ret

static func _get_common_ids(left: Dictionary[int, LibraryTableFieldInfo], right: Dictionary[int, LibraryTableFieldInfo]) -> Array[int]:
    var ret: Array[int] = []
    for id in left:
        if right.has(id):
            ret.append(id)
    ret.sort()
    return ret
#endregion

#region Iterators
#region CSV
## Converts an iteration of data rows to an iteration of CSV rows
## CSV rows are defined by Godot as a PackedStringArray
class CsvSerializationIterator extends RefCounted:
    var row_iterator
    var serialize: Callable

    func _init(row_iterator, serialize: Callable):
        self.row_iterator = row_iterator
        self.serialize = serialize

    func _iter_init(arg):
        return row_iterator._iter_init(arg)

    func _iter_next(arg):
        return row_iterator._iter_next(arg)

    func _iter_get(arg):
        var arr = row_iterator._iter_get(arg)
        var ret := PackedStringArray()
        ret.resize(arr.size())
        for i in range(arr.size()):
            ret[i] = serialize.call(arr[i])
        return ret

    func has_remaining():
        return row_iterator.has_remaining()

## Converts an iteration of CSV rows to an iteration of data rows
## CSV rows are defined by Godot as a PackedStringArray
class CsvDeserializationIterator extends RefCounted:
    var row_iterator
    var deserialize: Callable

    func _init(row_iterator, deserialize: Callable):
        self.row_iterator = row_iterator
        self.deserialize = deserialize

    func _iter_init(_arg):
        return row_iterator._iter_init(_arg)

    func _iter_next(_arg):
        return row_iterator._iter_next(_arg)

    func _iter_get(_arg):
        var raw_get = row_iterator._iter_get(_arg)
        return deserialize.call(raw_get)

class CsvFileIterator extends RefCounted:
    var path: String
    var _file: FileAccess
    var _curr_row: PackedStringArray

    func _init(path: String):
        self.path = path
        _curr_row = PackedStringArray()

    func _iter_init(_arg):
        if _file:
            _file.close()
        _file = FileAccess.open(path, FileAccess.READ)
        _curr_row = _file.get_csv_line()
        return has_remaining()

    func _iter_next(_arg):
        _curr_row = _file.get_csv_line()
        return has_remaining()

    func _iter_get(_arg):
        return _curr_row
    
    func has_remaining() -> bool:
        match _curr_row.size():
            0:
                return false
            1:
                return not _curr_row[0].is_empty()
            _:
                return true
#endregion

#region GridContainer
class GridContainerColIterator extends RefCounted:
    var grid_container: GridContainer
    var begin_row: int
    var end_row: int
    var row_idx: int
    var col_idx: int

    func _init(grid_container: GridContainer, col_idx: int, begin_row: int = 0, end_row: int = MAX_INT):
        self.grid_container = grid_container
        self.begin_row = begin_row
        self.end_row = end_row
        self.row_idx = begin_row
        self.col_idx = col_idx

    func _iter_init(_arg) -> bool:
        row_idx = begin_row
        return has_remaining()

    func _iter_next(_arg) -> bool:
        row_idx += 1
        return has_remaining()

    func _iter_get(_arg) -> Variant:
        return grid_container.get_child(row_idx * grid_container.columns + col_idx)

    func has_remaining() -> bool:
        return row_idx * grid_container.columns + col_idx < grid_container.get_child_count()

class GridContainerRowIterator extends RefCounted:
    var grid_container: GridContainer
    var row_slice_start: int
    var row_slice_end: int
    var begin_row: int
    var end_row: int
    var row_idx: int

    func _init(grid_container: GridContainer, row_slice_start: int = 0, row_slice_end: int = MAX_INT, begin_row: int = 0, end_row: int = MAX_INT):
        self.grid_container = grid_container
        self.row_slice_start = row_slice_start
        self.row_slice_end = row_slice_end
        self.begin_row = begin_row
        self.end_row = end_row
        self.row_idx = begin_row

    func _iter_init(_arg) -> bool:
        row_idx = begin_row
        return has_remaining()

    func _iter_next(_arg) -> bool:
        row_idx += 1
        return has_remaining()

    func _iter_get(_arg) -> Variant:
        var row_size = min(row_slice_end - row_slice_start, grid_container.columns - row_slice_start)
        row_size = min(row_size, grid_container.get_child_count() - (row_idx * grid_container.columns) - row_slice_start)
        var result := []
        result.resize(row_size)
        for i in range(0, row_size):
            result[i] = grid_container.get_child(row_idx * grid_container.columns + row_slice_start + i)
        return result

    func has_remaining() -> bool:
        return row_idx * grid_container.columns + row_slice_start < grid_container.get_child_count()
#endregion

class EnumerateIterator extends RefCounted:
    var iterator
    var count: int

    func _init(iterator: Variant) -> void:
        self.iterator = iterator
        self.count = 0

    func _iter_init(iter: Array) -> bool:
        self.count = 0
        return self.iterator._iter_init(iter)

    func _iter_next(iter: Array) -> bool:
        self.count += 1
        return self.iterator._iter_next(iter)

    func _iter_get(iter: Variant) -> Variant:
        return [count, self.iterator._iter_get(iter)]

class MapIterator extends RefCounted:
    var iterator
    var map: Callable

    func _init(iterator: Variant, map: Callable) -> void:
        self.iterator = iterator
        self.map = map

    func _iter_init(iter: Array) -> bool:
        return self.iterator._iter_init(iter)

    func _iter_next(iter: Array) -> bool:
        return self.iterator._iter_next(iter)

    func _iter_get(iter: Variant) -> Variant:
        return map.call(self.iterator._iter_get(iter))
#endregion
