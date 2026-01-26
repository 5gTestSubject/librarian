@tool

static func to_tags(value) -> Array[StringName]:
    var result: Array[StringName] = []
    var s := str(value).strip_edges()
    if s.left(1) != "[" or s.right(1) != "]":
        return result
    var tokens := s.substr(1, s.length() - 2).split(",")
    result.resize(tokens.size())
    for i in result.size():
        result[i] = StringName(tokens[i])
    return result

static func to_bool(value) -> bool:
    match(typeof(value)):
        TYPE_NIL: return false
        TYPE_BOOL: return value
        TYPE_INT: return bool(value)
        TYPE_FLOAT: return bool(value)
        TYPE_STRING:
            if value.to_lower() == "false": return false
            if value == "0": return false
            return not value.is_empty()
        TYPE_COLOR: return false
        _: return false

static func to_number(value) -> float:
    match(typeof(value)):
        TYPE_NIL: return 0.0
        TYPE_BOOL: return 1.0 if value else 0.0
        TYPE_INT: return float(value)
        TYPE_FLOAT: return value
        TYPE_STRING: return value.to_float()
        TYPE_COLOR: return 0.0
        _: return 0.0

static func to_text(value) -> String:
    match typeof(value):
        TYPE_NIL: return ""
        # serialize bools as 1/0 instead of true/false
        TYPE_BOOL:
            return str(int(value))
        # don't serialize the decimal points if unneeded
        TYPE_FLOAT:
            return str(int(value)) if int(value) == value else str(value)
        TYPE_COLOR:
            return value.to_html()
        _:
            return str(value)

static func to_color(value) -> Color:
    match(typeof(value)):
        TYPE_NIL: return Color.WHITE
        TYPE_BOOL: return Color.WHITE
        TYPE_INT: return Color.WHITE
        TYPE_FLOAT: return Color.WHITE
        TYPE_STRING:
            if Color.html_is_valid(value):
                return Color.html(value)
            else:
                return Color.WHITE
        TYPE_COLOR: return value
        _: return Color.WHITE