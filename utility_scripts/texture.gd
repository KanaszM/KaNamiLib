"""
# Version 1.0.0 (02-Apr-2025):
	- Reviewed release;
"""


class_name UtilsTexture


static func get_most_prominent_color(texture: Texture2D) -> Color:
	var image: Image = texture.get_image()
	var color_count: Dictionary[Color, int]
	var most_prominent_color: Color
	var max_count: int
	
	for y: int in range(image.get_height()):
		for x: int in range(image.get_width()):
			var color: Color = image.get_pixel(x, y)
			
			if color in color_count:
				color_count[color] += 1
			
			else:
				color_count[color] = 1
	
	for color: Color in color_count:
		if color_count[color] > max_count:
			most_prominent_color = color
			max_count = color_count[color]
	
	return most_prominent_color
