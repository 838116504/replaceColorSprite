tool
extends Sprite

var replaceColor = null setget set_replace_color
var tempTexture = ImageTexture.new()
var tempImage = Image.new()

func _init():
	connect("texture_changed", self, "_texture_changed")
#	material = ShaderMaterial.new()
#	material.shader = preload("replaceColor.shader")

func _texture_changed():
	property_list_changed_notify()

func set_replace_color(p_value):
	if replaceColor:
		replaceColor.disconnect("changed", self, "_on_replaceColor_changed")
	replaceColor = p_value
	if replaceColor:
		replaceColor.connect("changed", self, "_on_replaceColor_changed")
	update()
	property_list_changed_notify()

func _on_replaceColor_changed():
#	if material:
#		material.set_shader_param("replaceColors", get_texture_from_replace_color())
	update()

func _draw():
	if !texture:
		return
	var rect = get_rect()
	var renderTex = texture
	if replaceColor && replaceColor.colors.size() > 0:
		VisualServer.canvas_item_clear(get_canvas_item())
		var baseRect:Rect2
		if region_enabled:
			baseRect = region_rect
		else:
			baseRect = Rect2(0, 0, texture.get_width(), texture.get_height())
		
		var frame_size = baseRect.size / Vector2(hframes, vframes)
		var frame_offset = Vector2(frame % hframes, frame / hframes)
		frame_offset *= frame_size
		var sRect = Rect2(baseRect.position + frame_offset, frame_size)
		var sx = int(clamp(sRect.position.x, 0, texture.get_width() - 1))
		var sy = int(clamp(sRect.position.y, 0, texture.get_height() - 1))
		sRect.position -= Vector2(sx, sy)
		var w = min(texture.get_width() - sx, ceil(sRect.end.x))
		var h = min(texture.get_height() - sy, ceil(sRect.end.y))
		var sImg = texture.get_data()
		tempImage.create(w, h, sImg.has_mipmaps(), sImg.get_format())
		var color
		tempImage.lock()
		sImg.lock()
		for x in w:
			for y in h:
				color = sImg.get_pixel(sx + x, sy + y)
				for c in replaceColor.colors:
					if c.fromColor.is_equal_approx(color):
						color = c.toColor
						break
				tempImage.set_pixel(x, y, color)
		tempImage.unlock()
		sImg.unlock()
		tempTexture.create_from_image(tempImage, texture.flags)
		
		var dest_offset = offset
		if centered:
			dest_offset -= frame_size / 2
		if ProjectSettings.get_setting("rendering/quality/2d/use_pixel_snap"):
			dest_offset = dest_offset.floor()
		var dRect = Rect2(dest_offset, frame_size)
		if flip_h:
			dRect.size.x = -dRect.size.x
		if flip_v:
			dRect.size.y = -dRect.size.y
		draw_texture_rect_region(tempTexture, dRect, sRect, Color.white, false, normal_map, region_enabled && region_filter_clip)
	

func get_texture_from_replace_color():
	if !replaceColor || replaceColor.colors.size() <= 0:
		return null
	
	var texture = ImageTexture.new()
	var img = Image.new()
	img.create(replaceColor.colors.size() * 2, 1, false, Image.FORMAT_RGBA8)
	img.lock()
	for i in replaceColor.colors.size():
		img.set_pixel(i * 2, 0, replaceColor.colors[i].fromColor)
		img.set_pixel(i * 2 + 1, 0, replaceColor.colors[i].toColor)
	img.unlock()
	texture.create_from_image(img, 0)
	return texture

func _set(p_property, p_value):
	if p_property == "unreplaceColor":
		if texture && replaceColor:
			var colors = get_unreplace_colors()
			if p_value.size() == colors.size():
				var rc = replaceColor.colors
				var temp
				for i in colors.size():
					if colors[i] == p_value[i]:
						continue
					temp = ReplaceColorObj.new()
					temp.fromColor = colors[i]
					temp.toColor = p_value[i]
					rc.append(temp)
				if replaceColor.colors.size() < rc.size():
					replaceColor.colors = rc
					property_list_changed_notify()
	else:
		return false
	
	return true

func _get(p_property):
	if p_property == "unreplaceColor":
		if texture && replaceColor:
			var colors = get_unreplace_colors()
			if colors.size() > 0:
				return colors
	return null

func _get_property_list():
	var ret = []
	ret.append({ "name":"replaceColor", "type":TYPE_OBJECT, "hint":PROPERTY_HINT_RESOURCE_TYPE, "hint_string":"ReplaceColorRes", "usage":PROPERTY_USAGE_DEFAULT })
	if texture && replaceColor:
		ret.append({"name":"unreplaceColor", "type":TYPE_COLOR_ARRAY, "usage":PROPERTY_USAGE_EDITOR})
	return ret

func get_colors():
	var img = texture.get_data()
	img.lock()
	var ret = PoolColorArray()
	var colorDict = {}
	var rect = get_rect()
	rect.position = offset
	if region_enabled:
		rect.position += region_rect.position
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			if img.get_pixel(x, y).a == 0 || colorDict.has(img.get_pixel(x, y)):
				continue
			ret.append(img.get_pixel(x, y))
			colorDict[img.get_pixel(x, y)] = true
	img.unlock()
	return ret

func get_unreplace_colors():
	var colors = get_colors()
	for i in range(colors.size() - 1, -1, -1):
		for j in replaceColor.colors:
			if j && j.fromColor.r8 == colors[i].r8 && j.fromColor.g8 == colors[i].g8 && j.fromColor.b8 == colors[i].b8:
				colors.remove(i)
				break
	return colors
