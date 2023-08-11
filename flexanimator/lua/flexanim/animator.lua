
local animation_mt={}
animation_mt.__index=animation_mt

function create_animator(name,length)
	assert(type(name)=="string")
	return setmetatable({
		splines={},
		name=name,
		length=length or 1,
		progress=0
	},animation_mt)
end

function animation_mt:attach_entity(ent)
	if not IsValid(ent) then return end
	self.ent=ent
end

function animation_mt:set_progress(d)
	self.progress=math.Clamp(d,0,self.length)
end

function animation_mt:get_progress()
	return self.progress
end

function animation_mt:get_fraction()
	return self.progress/self.length
end

function animation_mt:update_time(dt)
	self.progress=self.progress+dt
	if self.progress>self.length then self.progress=0 end
end

function animation_mt:update_flexes()
	if not self.ent or not IsValid(self.ent) then print("flexanim: warning, invalid entity (",self.name,")") return end
	for flex,spline in pairs(self.splines) do
		local fid=self.ent:GetFlexIDByName(flex)
		if fid then
			local weight=spline:sample_fofx(self:get_fraction())

			self.ent:SetFlexWeight(fid,1-weight)
		end
	end
end

function animation_mt:get_length()
	return self.length
end

function animation_mt:add_flex_curve(flex,spline)
	if self.splines[flex] then print("flex_anim: duplicate flex") return end
	self.splines[flex]=spline
end

function animation_mt:find_anim_frame(flex)
	if not self.splines[flex] then print("flex_anim: duplicate flex") return end
	
end