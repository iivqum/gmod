local camera={}

local cam={}
local cam_mt={__index=cam}

local function new(p,a,fov)
	return setmetatable({
		p=p or Vector(),
		a=a or Angle(),
		fov=fov or 90
	},cam_mt)
end

local function initializeFromEntity(name,...)
	local ent=ents.FindByName(name)[1]
	assert(IsValid(ent),"initializeFromEntity")
	print("new camera "..name)
	return new(ent:GetPos(),ent:GetAngles(),...)
end

camera.initializeFromEntity=initializeFromEntity

setmetatable(camera,{__call=function(t,...)return new(...)end})

return camera