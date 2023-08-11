include("flexanim/spline.lua")
include("flexanim/animator.lua")

FLEX_ANIMATION_BASEFOLDER="flexanimator"

file.CreateDir(FLEX_ANIMATION_BASEFOLDER)

local function write_vector(f,v)
	f:WriteDouble(v.x)
	f:WriteDouble(v.y)
end

local function read_vector(f)
	return f:ReadDouble(),f:ReadDouble()
end

local function write_spline_to_file(f,flex,spline)
	f:WriteUShort(#flex)
	f:Write(flex)
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
	local slen=f:ReadUShort()
	local flex=f:Read(slen)
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
	if not f then print("flexanim: could not save animation ",anim.name) return end
	f:WriteDouble(anim.length)
	f:WriteUShort(anim.nsplines)
	for flex,spline in pairs(anim.splines) do
		write_spline_to_file(f,flex,spline)
	end
	f:Flush()
	f:Close()
	return true
end

function open_animation_file(name)
	local f=open_file(name,true)
	if not f then print("flexanim: could not open animation ",name) return end
	local length=f:ReadDouble()
	local nsplines=f:ReadUShort()
	local anim=create_animator(name,length)
	for i=1,nsplines do
		local flex,spline=read_spline_from_file(f)
		anim:add_flex_curve(flex==nil and "" or flex,spline)
	end
	PrintTable(anim)
	f:Close()
	return anim
end

function open_file(name,rd)
	assert(type(name)=="string")
	local f=file.Open(FLEX_ANIMATION_BASEFOLDER.."/"..name..".dat",rd and "rb" or "wb","DATA")
	if not f then print("flexanim: could not open file ",name) return end
	return f
end

function find_animation_file(name)
	return file.Exists(FLEX_ANIMATION_BASEFOLDER..name,"DATA")
end

function open_valid_animation_file()
	if not find_animation_file(name) then return end
	return open_file(name)
end