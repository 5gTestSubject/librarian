@tool

const Properties = preload("res://addons/librarian/properties.gd")

const MAX_INT := 2147483647

const COL_TYPE_TAGS := &"tags"
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

static func clear_children(node: Node, include_internal: bool = false) -> void:
    for _i in range(node.get_child_count(include_internal)):
        var child = node.get_child(0, include_internal)
        node.remove_child(child)
        child.queue_free()

static func clear_children_lazy(node: Node, include_internal: bool = false) -> void:
    for _i in range(node.get_child_count(include_internal)):
        var child = node.get_child(0, include_internal)
        child.queue_free()

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
class ChildIterator extends RefCounted:
    var _parent: Node
    var _range_start: int
    var _range_end: int
    var _step: int
    var _include_internal: bool

    func _init(parent: Node, range_start: int = 0, range_end: int = MAX_INT, step: int = 1, include_internal: bool = false) -> void:
        _parent = parent
        _range_start = range_start
        _range_end = range_end
        _step = step
        _include_internal = include_internal

    func _iter_init(iter: Array) -> bool:
        iter[0] = _range_start
        return iter[0] < _range_end and iter[0] < _parent.get_child_count(_include_internal)

    func _iter_next(iter: Array) -> bool:
        iter[0] += _step
        return iter[0] < _range_end and iter[0] < _parent.get_child_count(_include_internal)

    func _iter_get(iter: Variant) -> Variant:
        return _parent.get_child(iter, _include_internal)

class ChildBatchIterator extends RefCounted:
    var _parent: Node
    var _batch_size: int
    var _range_start: int
    var _range_end: int
    var _include_internal: bool

    func _init(parent: Node, batch_size: int, range_start: int = 0, range_end: int = MAX_INT, include_internal: bool = false) -> void:
        _parent = parent
        _batch_size = batch_size
        _range_start = range_start
        _range_end = range_end
        _include_internal = include_internal

    func _iter_init(iter: Array) -> bool:
        iter[0] = _range_start
        return iter[0] < _range_end and iter[0] < _parent.get_child_count(_include_internal)

    func _iter_next(iter: Array) -> bool:
        iter[0] += _batch_size
        return iter[0] < _range_end and iter[0] < _parent.get_child_count(_include_internal)

    func _iter_get(iter: Variant) -> Variant:
        var batch_size := min(_batch_size, _parent.get_child_count() - iter)
        var batch: Array[Node] = []
        batch.resize(batch_size)
        for i in range(0, batch_size):
            batch[i] = _parent.get_child(iter + i)
        return batch

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
