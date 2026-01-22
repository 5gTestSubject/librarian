@tool
extends Tree

func message_bus(): return get_node(preload("res://addons/librarian/scripts/message_bus.gd").AUTOLOAD_NODE_PATH)
const Util = preload("res://addons/librarian/utils.gd")

const COL_FIELD_NAME := 0
const COL_FIELD_ACTIONS := 1
const COL_FIELD_PROP_KEY := 0
const COL_FIELD_PROP_VALUE := 1

const DELETE_FIELD_BUTTON_ID := 1

const FIELD_TYPE_DROPDOWN: PackedStringArray = [
    Util.COL_TYPE_BOOL,
    Util.COL_TYPE_NUM,
    Util.COL_TYPE_STRING,
    Util.COL_TYPE_COLOR,
]
const NUMBER_TYPE_DROPDOWN: PackedStringArray = [
    Util.COL_TYPEHINT_INTEGER,
    Util.COL_TYPEHINT_DECIMAL,
]

var _root: TreeItem
var _table_fields_root: TreeItem

@export var metadata: LibraryTableInfo:
    get: return metadata
    set(value):
        metadata = value
        refresh()

@export_group("Icons")
@export var _add_icon: Texture2D
@export var _delete_icon: Texture2D
@export var _bool_icon: Texture2D
@export var _int_icon: Texture2D
@export var _float_icon: Texture2D
@export var _string_icon: Texture2D
@export var _color_icon: Texture2D

func _ready() -> void:
    message_bus().field_updated.connect(func(_id, _idx): refresh())
    message_bus().field_added.connect(func(_id): refresh())
    message_bus().field_deleted.connect(func(_id, _idx): refresh())
    message_bus().field_moved.connect(func(_id, _old_idx, _new_idx): refresh())
    _root = create_item()
    refresh()

func refresh() -> void:
    var expanded_cols := []
    if _table_fields_root:
        for child in _table_fields_root.get_children():
            if not child.collapsed:
                expanded_cols.append(child.get_metadata(COL_FIELD_NAME).id)

    _table_fields_root = null
    for c in _root.get_children():
        _root.remove_child(c)
        c.free()

    if not metadata:
        return

    _table_fields_root = _root.create_child()
    _table_fields_root.set_text(COL_FIELD_NAME, metadata.name)
    _table_fields_root.disable_folding = true

    for i in range(metadata.fields.size()):
        var field_item = _table_fields_root.create_child()
        field_item.set_metadata(COL_FIELD_NAME, metadata.fields[i])
        field_item.collapsed = true
        _refresh_field(i, field_item)

    if _table_fields_root:
        for child in _table_fields_root.get_children():
            if expanded_cols.has(child.get_metadata(COL_FIELD_NAME).id):
                child.collapsed = false

func _refresh_field(field_idx: int, field_item: TreeItem) -> void:
    var field = metadata.fields[field_idx]
    field_item.set_text(COL_FIELD_NAME, field.name)
    field_item.add_button(COL_FIELD_ACTIONS, _delete_icon, DELETE_FIELD_BUTTON_ID, false, "Delete table column")

    var desc_item = field_item.create_child()
    desc_item.set_text(COL_FIELD_PROP_KEY, "Description")
    desc_item.set_text(COL_FIELD_PROP_VALUE, field.description)
    desc_item.set_editable(COL_FIELD_PROP_VALUE, true)

    # special-case string. no difference between absent and empty string
    if field.type != Util.COL_TYPE_STRING:
        var optional_item = field_item.create_child()
        optional_item.set_text(COL_FIELD_PROP_KEY, "Optional")
        optional_item.set_cell_mode(COL_FIELD_PROP_VALUE, TreeItem.CELL_MODE_CHECK)
        optional_item.set_checked(COL_FIELD_PROP_VALUE, field.optional)
        optional_item.set_editable(COL_FIELD_PROP_VALUE, true)

    var type_item = field_item.create_child()
    type_item.set_text(COL_FIELD_PROP_KEY, "Type")
    type_item.set_cell_mode(COL_FIELD_PROP_VALUE, TreeItem.CELL_MODE_RANGE)
    type_item.set_text(COL_FIELD_PROP_VALUE, ",".join(FIELD_TYPE_DROPDOWN))
    type_item.set_editable(COL_FIELD_PROP_VALUE, true)
    match field.type:
        Util.COL_TYPE_BOOL:
            type_item.set_range(COL_FIELD_PROP_VALUE, 0)
            field_item.set_icon(COL_FIELD_NAME, _bool_icon)
        Util.COL_TYPE_NUM:
            type_item.set_range(COL_FIELD_PROP_VALUE, 1)
            _refresh_number_properties(field_idx, field_item)
        Util.COL_TYPE_STRING:
            type_item.set_range(COL_FIELD_PROP_VALUE, 2)
            field_item.set_icon(COL_FIELD_NAME, _string_icon)
            _refresh_text_properties(field_idx, field_item)
        Util.COL_TYPE_COLOR:
            type_item.set_range(COL_FIELD_PROP_VALUE, 3)
            field_item.set_icon(COL_FIELD_NAME, _color_icon)

func _refresh_number_properties(field_idx: int, field_item: TreeItem) -> void:
    var field = metadata.fields[field_idx]

    var type_item = field_item.create_child()
    type_item.set_text(COL_FIELD_PROP_KEY, "Number Type")
    type_item.set_cell_mode(COL_FIELD_PROP_VALUE, TreeItem.CELL_MODE_RANGE)
    type_item.set_text(COL_FIELD_PROP_VALUE, ",".join(NUMBER_TYPE_DROPDOWN))
    type_item.set_editable(COL_FIELD_PROP_VALUE, true)
    match field.number_info.type:
        Util.COL_TYPEHINT_INTEGER:
            type_item.set_range(COL_FIELD_PROP_VALUE, 0)
            field_item.set_icon(COL_FIELD_NAME, _int_icon)
        Util.COL_TYPEHINT_DECIMAL:
            type_item.set_range(COL_FIELD_PROP_VALUE, 1)
            field_item.set_icon(COL_FIELD_NAME, _float_icon)

            var step_item = field_item.create_child()
            step_item.set_text(COL_FIELD_PROP_KEY, "Arrow Step")
            step_item.set_cell_mode(COL_FIELD_PROP_VALUE, TreeItem.CELL_MODE_RANGE)
            step_item.set_range_config(COL_FIELD_PROP_VALUE, 0.001, 1.0, 0.001)
            step_item.set_range(COL_FIELD_PROP_VALUE, field.number_info.arrow_step)
            step_item.set_editable(COL_FIELD_PROP_VALUE, true)

func _refresh_text_properties(field_idx: int, field_item: TreeItem) -> void:
    var field = metadata.fields[field_idx]

    var placeholder_item = field_item.create_child()
    placeholder_item.set_text(COL_FIELD_PROP_KEY, "Placeholder Text")
    placeholder_item.set_text(COL_FIELD_PROP_VALUE, field.text_info.placeholder_text)
    placeholder_item.set_editable(COL_FIELD_PROP_VALUE, true)

func _on_item_edited() -> void:
    var edited_item = get_edited()
    var edited_parent = edited_item.get_parent()
    
    # field title updated
    if edited_parent == _table_fields_root:
        metadata.fields[edited_item.get_index()].name = edited_item.get_text(COL_FIELD_NAME)
        message_bus().field_updated.emit(metadata.id, edited_item.get_index())
        return

    # field property updated
    var field = metadata.fields[edited_parent.get_index()]
    match edited_item.get_text(COL_FIELD_PROP_KEY):
        "Arrow Step":
            field.number_info.arrow_step = edited_item.get_range(COL_FIELD_PROP_VALUE)
        "Description":
            field.description = edited_item.get_text(COL_FIELD_PROP_VALUE)
        "Number Type":
            field.number_info.type = NUMBER_TYPE_DROPDOWN[int(edited_item.get_range(COL_FIELD_PROP_VALUE))]
        "Optional":
            field.optional = edited_item.is_checked(COL_FIELD_PROP_VALUE)
        "Placeholder Text":
            field.text_info.placeholder_text = edited_item.get_text(COL_FIELD_PROP_VALUE)
        "Type":
            field.type = FIELD_TYPE_DROPDOWN[int(edited_item.get_range(COL_FIELD_PROP_VALUE))]
        _:
            printerr("TODO support updating field property `%s`" % edited_item.get_text(COL_FIELD_PROP_KEY))
    message_bus().field_updated.emit(metadata.id, edited_parent.get_index())

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
    # table action
    # if item == _table_fields_root:
    #     match id:
    #         ADD_FIELD_BUTTON_ID:
    #             pass
    #         _:
    #             printerr("Unrecognized button.")
    # # field action
    # elif item.get_parent() == _table_fields_root:
    match id:
        DELETE_FIELD_BUTTON_ID:
            if mouse_button_index != MOUSE_BUTTON_LEFT:
                return
            var field_index := item.get_index()
            metadata.fields.remove_at(field_index)
            message_bus().field_deleted.emit(metadata.id, field_index)
        _:
            printerr("Unrecognized button.")
