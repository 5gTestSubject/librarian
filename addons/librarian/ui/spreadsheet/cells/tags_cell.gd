@tool
extends PanelContainer

var cell_value: Array[StringName]:
    get: return cell_value
    set(value):
        cell_value = value
        refresh()

@export var _badge_parent: NodePath
@export var _selector_scene: NodePath

func refresh() -> void:
    var badges = get_node(_badge_parent)
    for _i in range(badges.get_child_count()):
        var child := badges.get_child(0)
        badges.remove_child(child)
        child.queue_free()
    for tag_id in cell_value:
        var tag = LibraryInfo.tags.get(tag_id)
        if not tag:
            continue
        var badge = preload("res://addons/librarian/ui/elements/tag_badge.tscn").instantiate()
        badge.tag_name = tag.name
        badge.tag_description = tag.description
        badges.add_child(badge)

func _on_configure_button_pressed() -> void:
    var selector := get_node(_selector_scene)
    selector.visible = true
    selector.refresh(cell_value)

func _on_tag_selection_update(tag_ids: Array[StringName]) -> void:
    cell_value = tag_ids
