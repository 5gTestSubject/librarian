@tool
extends PanelContainer

var cell_value: Array[StringName]:
    get: return cell_value
    set(value):
        cell_value = value
        refresh()

func refresh() -> void:
    var badge_parent := $TagBadges
    for i in range(badge_parent.get_child_count()):
        var child := badge_parent.get_child(i)
        badge_parent.remove_child(child)
        child.queue_free()
    for tag_id in cell_value:
        var tag = LibraryInfo.tags.get(tag_id)
        if not tag:
            continue
        var badge = preload("res://addons/librarian/ui/elements/tag_badge.tscn").instantiate()
        badge.tag_name = tag.name
        badge.tag_description = tag.description
        badge_parent.add_child(badge)
