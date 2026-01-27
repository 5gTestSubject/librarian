@tool
extends PanelContainer

@export var tag_name: String:
    get: return %NameLabel.text
    set(value): %NameLabel.text = value
@export var tag_description: String:
    get: return tooltip_text
    set(value): tooltip_text = value
