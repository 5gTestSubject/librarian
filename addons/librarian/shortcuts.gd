@tool

static var save_sheet := Shortcut.new()
static var save_sheet_alt := Shortcut.new()
static var save_all_sheets := Shortcut.new()

static var nav_left_edge := Shortcut.new()
static var nav_right_edge := Shortcut.new()
static var nav_top_edge := Shortcut.new()
static var nav_bottom_edge := Shortcut.new()
static var nav_sheet_start := Shortcut.new()
static var nav_sheet_end := Shortcut.new()

static var exit_sheet := Shortcut.new()

static func _static_init() -> void:
    save_sheet.events = [_ctrl_s()]
    save_sheet_alt.events = [_ctrl_alt_s()]
    save_all_sheets.events = [_ctrl_shift_alt_s()]

    nav_left_edge.events = [_nav_edge(KEY_LEFT), _nav_row_edge(KEY_HOME)]
    nav_right_edge.events = [_nav_edge(KEY_RIGHT), _nav_row_edge(KEY_END)]
    nav_top_edge.events = [_nav_edge(KEY_UP)]
    nav_bottom_edge.events = [_nav_edge(KEY_DOWN)]
    nav_sheet_start.events = [_nav_sheet_edge(KEY_HOME)]
    nav_sheet_end.events = [_nav_sheet_edge(KEY_END)]

    exit_sheet.events = [_esc()]

static func _ctrl_s() -> InputEventKey:
    var input = InputEventKey.new()
    input.keycode = KEY_S
    input.ctrl_pressed = true
    input.command_or_control_autoremap = true
    return input

static func _ctrl_alt_s() -> InputEventKey:
    var input = InputEventKey.new()
    input.keycode = KEY_S
    input.ctrl_pressed = true
    input.alt_pressed = true
    input.command_or_control_autoremap = true
    return input

static func _ctrl_shift_alt_s() -> InputEventKey:
    var input = InputEventKey.new()
    input.keycode = KEY_S
    input.ctrl_pressed = true
    input.shift_pressed = true
    input.alt_pressed = true
    input.command_or_control_autoremap = true
    return input

static func _esc() -> InputEventKey:
    var input = InputEventKey.new()
    input.keycode = KEY_ESCAPE
    return input

static func _nav_edge(arrow_key_code: Key) -> InputEventKey:
    var input = InputEventKey.new()
    input.keycode = arrow_key_code
    input.ctrl_pressed = true
    input.command_or_control_autoremap = true
    return input

static func _nav_row_edge(key_code: Key) -> InputEventKey:
    var input = InputEventKey.new()
    input.keycode = key_code
    return input

static func _nav_sheet_edge(key_code: Key) -> InputEventKey:
    var input = InputEventKey.new()
    input.keycode = key_code
    input.ctrl_pressed = true
    input.command_or_control_autoremap = true
    return input
