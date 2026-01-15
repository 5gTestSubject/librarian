@tool
class_name LibraryTableNumberFieldInfo extends Resource

const Util = preload("res://addons/librarian/utils.gd")

const PRECISION = 0.001
const DEFAULT_ARROW_STEP = 0.01

@export var type := Util.COL_TYPEHINT_INTEGER
@export var arrow_step := DEFAULT_ARROW_STEP

func get_precision() -> float:
    if type == Util.COL_TYPEHINT_INTEGER:
        return 1.0
    return PRECISION

func equivalent_to(other: LibraryTableNumberFieldInfo) -> bool:
    return (
        other != null &&
        type == other.type &&
        arrow_step == other.arrow_step
    )

func to_dict() -> Dictionary:
    var ret = {}
    ret["type"] = type
    if type == Util.COL_TYPEHINT_DECIMAL:
        ret["arrow_step"] = arrow_step
    return ret

static func from_dict(raw: Dictionary) -> LibraryTableNumberFieldInfo:
    var field = LibraryTableNumberFieldInfo.new()
    field.type = StringName(raw.get("type", Util.COL_TYPEHINT_INTEGER))
    field.arrow_step = raw.get("arrow_step", DEFAULT_ARROW_STEP)
    return field
