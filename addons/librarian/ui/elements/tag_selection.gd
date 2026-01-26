@tool
extends Control

const Util = preload("res://addons/librarian/utils.gd")

const MIN_FILTER_CHARS := 2

signal selection_update(tag_ids: Array[StringName])

func get_selected_tag_ids() -> Array[StringName]:
    var result: Array[StringName] = []
    result.resize(%SelectedTags.get_child_count())
    for i in range(result.size()):
        result[i] = (%SelectedTags.get_child(i).tag_id)
    return result

func refresh(selected_tag_ids: Array[StringName]) -> void:
    Util.clear_children(%SelectedTags)
    Util.clear_children(%OtherTags)
    for tag in LibraryInfo.tags.values():
        _add_tag_option(selected_tag_ids.has(tag.id), tag.id, tag.name, tag.description, tag.color)
    _sort_options(%SelectedTags)
    _sort_options(%OtherTags)
    selection_update.emit(get_selected_tag_ids())

func _add_tag_option(selected: bool, tag_id: StringName, tag_name: String, tag_description: String, tag_color: Color) -> void:
    var option_control = preload("res://addons/librarian/ui/elements/tag_selection_option.tscn").instantiate()
    var parent: BoxContainer = %SelectedTags if selected else %OtherTags
    parent.add_child(option_control)
    option_control.selected = selected
    option_control.tag_id = tag_id
    option_control.tag_name = tag_name
    option_control.tag_description = tag_description
    option_control.tag_color = tag_color
    option_control.toggled.connect(func(toggled_on): _on_option_toggled(option_control, toggled_on))

func _sort_options(parent: Control) -> void:
    var children := parent.get_children()
    for child in children:
        parent.remove_child(child)
    children.sort_custom(func(left, right): return left.tag_name.naturalnocasecmp_to(right.tag_name) < 0)
    for child in children:
        parent.add_child(child)

func _on_option_toggled(option: Control, toggled_on: bool) -> void:
    if %SelectedTags.get_children().has(option):
        %SelectedTags.remove_child(option)
    if %OtherTags.get_children().has(option):
        %OtherTags.remove_child(option)
    if toggled_on:
        %SelectedTags.add_child(option)
        _sort_options(%SelectedTags)
    else:
        %OtherTags.add_child(option)
        _sort_options(%OtherTags)
    selection_update.emit(get_selected_tag_ids())

func _on_filter_text_changed(new_text:String) -> void:
    var entries = %SelectedTags.get_children()
    entries.append_array(%OtherTags.get_children())
    if new_text.length() < MIN_FILTER_CHARS:
        for entry in entries:
            entry.visible = true
    else:
        for entry in entries:
            entry.visible = (entry.tag_name as String).containsn(new_text)

func _on_close_button_pressed() -> void:
    visible = false
