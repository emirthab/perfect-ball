@tool
class_name StyleBoxMulti
extends StyleBox

@export var style_boxes: Array[StyleBox] = [] : set = set_style_boxes, get = get_style_boxes

func _draw(canvas_item: RID, rect: Rect2) -> void:
	for style_box in style_boxes:
		style_box.draw(canvas_item, rect)

func set_style_boxes(_style_boxes):
	style_boxes = _style_boxes

func get_style_boxes():
	return style_boxes
