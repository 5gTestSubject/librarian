@tool

const Properties = preload("res://addons/librarian/properties.gd")

const MAX_INT := 2147483647

const COL_TYPE_BOOL := &"bool"
const COL_TYPE_NUM := &"number"
const COL_TYPE_STRING := &"string"
const COL_TYPE_COLOR := &"color"

const COL_TYPEHINT_LINE_EDIT := &"LineEdit"
const COL_TYPEHINT_TEXT_EDIT := &"TextEdit"
const COL_TYPEHINT_INTEGER := &"Integer"
const COL_TYPEHINT_DECIMAL := &"Decimal"

const MAIN_SCREEN_NAME = "Librarian"

static func printwarn(msg: String) -> void:
    print_rich("[color=Yellow]%s[/color]" % msg)

static func path_combine(path1: String, path2: String) -> String:
    return path1.trim_suffix("/") + "/" + path2.trim_prefix("/")


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

static func _cols_array_to_dict(arr: Array[LibraryTableFieldInfo]) -> Dictionary[StringName, LibraryTableFieldInfo]:
    var dict: Dictionary[StringName, LibraryTableFieldInfo] = {}
    for field in arr:
        dict[field.id] = field
    return dict

static func _get_exclusive_ids(target: Dictionary[StringName, LibraryTableFieldInfo], comparison: Dictionary[StringName, LibraryTableFieldInfo]) -> Array[StringName]:
    var ret: Array[StringName] = []
    for id in target:
        if not comparison.has(id):
            ret.append(id)
    ret.sort()
    return ret

static func _get_common_ids(left: Dictionary[StringName, LibraryTableFieldInfo], right: Dictionary[StringName, LibraryTableFieldInfo]) -> Array[StringName]:
    var ret: Array[StringName] = []
    for id in left:
        if right.has(id):
            ret.append(id)
    ret.sort()
    return ret
#endregion

#region Iterators
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
