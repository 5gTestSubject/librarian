@tool

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
        _: return false

static func to_number(value) -> float:
    match(typeof(value)):
        TYPE_NIL: return 0.0
        TYPE_BOOL: return 1.0 if value else 0.0
        TYPE_INT: return float(value)
        TYPE_FLOAT: return value
        TYPE_STRING: return value.to_float()
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
        _:
            return str(value)
