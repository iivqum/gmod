local path="flexanimator/"

local function write_vector(f,v)
	f:WriteDouble(v.x)
	f:WriteDouble(v.y)
end

local function read_vector(f)
	return f:ReadDouble(),f:ReadDouble()
end

local function write_spline_to_file(f,flex,spline)
	f:WriteShort(#flex)
	f:Write(flex)
	f:WriteShort(#spline:get_points())
	f:WriteDouble(spline.alpha)
	f:WriteDouble(spline.tension)
	write_vector(f,spline.ca)
	write_vector(f,spline.cb)
	for i,point	in ipairs(spline:get_points()) do
		write_vector(point.pos)			
	end
end

local function read_spline_from_file(f)
	local slen=f:ReadShort()
	local flex=f:Read(slen)
	local npoints=f:ReadShort()
	local alpha=f:ReadDouble()
	local tension=f:ReadDouble()
	local ca=Vector(read_vector())
	local cb=Vector(read_vector())
	local spline=catmull_rom_spline(alpha,tension,ca,cb)
	for i=1,npoints do
		local x,y=read_vector()
		spline:add_point(x,y)
	end
	return spline
end

function save_animation_file(anim)
	local f=open_file(anim.name,true)
	if not f then print("flexanim: could not save animation ",anim.name) return end
	f:WriteDouble(anim.length)
	f:WriteShort(#anim.splines)
	for flex,spline in pairs(anim.splines) do
		write_spline_to_file(f,flex,spline)
	end
	return true
end

function open_animation_file(name)
	local f=open_file(name,false)
	if not f then print("flexanim: could not open animation ",anim.name) return end
	local length=f:ReadDouble()
	local nsplines=f:ReadShort()
	local anim=create_animator(name,length)
	for i=1,nsplines do
		local spline=read_spline_from_file(f)
		anim:add_flex_curve(spline)
	end
	return anim
end

function open_file(name,clean)
	assert(type(name)=="string")
	local f=file.Open(path..name,clean and "w+" or "r+","DATA")
	if not f then print("flexanim: could not open file ",name) return end
	return f
end

function find_animation_file(name)
	return file.Exists(path..name,"DATA")
end

function open_valid_animation_file()
	if not find_animation_file(name) then return end
	return open_file(name)
end