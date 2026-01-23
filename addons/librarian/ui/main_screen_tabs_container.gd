@tool
extends PanelContainer

var current_tab_focus: int:
    get:
        var result := -1
        for i in range(get_child_count()):
            var control = get_child(i) as Control
            if control:
                result += 1
                if control.visible:
                    return result
        return -1
    set(index):
        if index < 0:
            _invisible_all()
            return
        var target := get_tab(index)
        if not target:
            push_error("Attempted to focus nonexistent tab %s. Total tabs: %s." % [index, count()])
            return
        _invisible_all()
        target.visible = true

func count() -> int:
    var count := 0
    for i in range(get_child_count()):
        if get_child(i) is Control:
            count += 1
    return count

func get_tab(index: int) -> Control:
    if index < 0 or index >= get_child_count():
        return null
    var control_idx := -1
    for i in range(get_child_count()):
        var control = get_child(i) as Control
        if control:
            control_idx += 1
            if control_idx == index:
                return control
    return null

func remove_tab(index: int) -> bool:
    if index < 0 or index >= get_child_count():
        return false
    var control_idx := -1
    for i in range(get_child_count()):
        var control = get_child(i) as Control
        if control:
            control_idx += 1
            if control_idx == index:
                remove_child(control)
                control.queue_free()
                return true
    return false

func sort_tabs(tab_id_order: Array[StringName]) -> void:
    for i in range(tab_id_order.size()):
        for j in range(i, get_child_count()):
            var control = get_child(j) as Control
            if not control:
                continue
            if control.metadata.id == tab_id_order[i]:
                move_child(control, i)
                break

func _invisible_all() -> void:
    for child in get_children():
        if child is CanvasItem:
            child.visible = false

func _on_child_entered_tree(node:Node) -> void:
    if node is CanvasItem:
        node.visible = false
    # var new_control = node as Control
    # if not new_control:
    #     return
    # _invisible_all()
    # new_control.visible = true

func _on_child_exiting_tree(node:Node) -> void:
    var exiting_control = node as Control
    if not exiting_control:
        return
    if not exiting_control.visible:
        return
    var exiting_idx = exiting_control.get_index()

    _invisible_all()
    # first attempt to make next tab visible
    for i in range(exiting_idx + 1, get_child_count(), 1):
        var next_control = get_child(i) as Control
        if next_control:
            next_control.visible = true
            return
    # otherwise, attempt to make previous tab visible
    for i in range(exiting_idx - 1, 0, -1):
        var prev_control = get_child(i) as Control
        if prev_control:
            prev_control.visible = true
            return
