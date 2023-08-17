include("flexaddon/spline.lua")
include("flexaddon/animator.lua")

FLEX_ANIMATION_BASEFOLDER="flexanimator"

file.CreateDir(FLEX_ANIMATION_BASEFOLDER)

local function write_vector(f,v)
	f:WriteDouble(v.x)
	f:WriteDouble(v.y)
end

local function read_vector(f)
	return f:ReadDouble(),f:ReadDouble()
end

local function write_string(f,s)
	assert(type(s)=="string")
	f:WriteUShort(#s)
	f:Write(s)
end

local function read_string(f)
	local l=f:ReadUShort()
	local s=f:Read(l)
	return s
end

local function write_spline_to_file(f,flex,spline)
	write_string(f,flex)
	f:WriteUShort(#spline:get_points())
	f:WriteDouble(spline.alpha)
	f:WriteDouble(spline.tension)
	write_vector(f,spline.ca)
	write_vector(f,spline.cb)
	for i,point	in ipairs(spline:get_points()) do
		write_vector(f,point.pos)		
	end
end

local function read_spline_from_file(f)
	local flex=read_string(f)
	local npoints=f:ReadUShort()
	local alpha=f:ReadDouble()
	local tension=f:ReadDouble()
	local ca=Vector(read_vector(f))
	local cb=Vector(read_vector(f))
	local spline=catmull_rom_spline(alpha,tension,ca,cb)
	for i=1,npoints do
		local x,y=read_vector(f)
		spline:add_point(x,y)
	end
	return flex,spline
end

function save_animation_file(anim)
	--file.Delete(FLEX_ANIMATION_BASEFOLDER.."/"..anim.name..".dat")
	local f=open_file(anim.name,false)
	if not f then print("flexaddon: could not save animation ",anim.name) return end
	f:WriteDouble(anim.length)
	f:WriteUShort(anim.nsplines)
	for flex,spline in pairs(anim.splines) do
		write_spline_to_file(f,flex,spline)
		f:WriteDouble(anim:get_offset(flex))
	end
	write_string(f,anim.load_model)
	f:Flush()
	f:Close()
	return true
end

function open_animation_file(name)
	local f=open_file(name,true)
	if not f then print("flexaddon: could not open animation ",name) return end
	local length=f:ReadDouble()
	local nsplines=f:ReadUShort()
	local anim=create_animator(name,length)
	for i=1,nsplines do
		local flex,spline=read_spline_from_file(f)
		local offset=f:ReadDouble()
		anim:add_flex_curve(flex==nil and "" or flex,spline)
		anim:set_offset(flex==nil and "" or flex,offset)
	end
	local load_model=read_string(f)
	anim.load_model=load_model
	f:Close()
	return anim
end

function open_file(name,rd)
	assert(type(name)=="string")
	local f=file.Open(FLEX_ANIMATION_BASEFOLDER.."/"..name..".dat",rd and "rb" or "wb","DATA")
	if not f then print("flexaddon: could not open file ",name) return end
	return f
end

function find_animation_file(name)
	return file.Exists(FLEX_ANIMATION_BASEFOLDER..name,"DATA")
end

function open_valid_animation_file()
	if not find_animation_file(name) then return end
	return open_file(name)
end