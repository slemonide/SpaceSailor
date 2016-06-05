function global_to_local(x, y, origin_x, origin_y)
	local local_x = x - origin_x
	local local_y = origin_y - y

	return local_x, local_y 
end
