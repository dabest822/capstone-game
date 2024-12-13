extends Node2D

@export var polygon_to_flip_path: NodePath = "Polygon2D2"  # Path to the Polygon2D node to flip

func _ready():
	if polygon_to_flip_path:
		var polygon = get_node_or_null(polygon_to_flip_path)
		if polygon and polygon is Polygon2D:
			flip_polygon_horizontal(polygon)
		else:
			print("The node is not a valid Polygon2D!")
	else:
		print("No Polygon2D node path provided!")

func flip_polygon_horizontal(polygon: Polygon2D):
	# Get the current points of the Polygon2D
	var points = polygon.polygon

	# Iterate through each point and flip the X coordinate
	for i in range(points.size()):
		points[i].x = -points[i].x

	# Assign the modified points back to the Polygon2D
	polygon.polygon = points
	print("Polygon2D flipped horizontally!")
