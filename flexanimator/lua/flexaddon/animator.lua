
local animation_mt={}
animation_mt.__index=animation_mt

function create_animator(name,length)
	assert(type(name)=="string")
	return setmetatable({
		splines={},
		name=name,
		length=length or 1,
		max_progress=length or 1,
		progress=0,
		nsplines=0,
		looped=false,
		playing=false
	},animation_mt)
end

function animation_mt:attach_entity(ent)
	if not IsValid(ent) then return end
	self.ent=ent
end

function animation_mt:get_flex_curve(name)
	return self.splines[name]
end

function animation_mt:set_length(t)
	assert(type(t)=="number")
	assert(t>0, "flexaddon: set_length less than or equal to 0")
	self.length=t
	self.max_progress=t
	self.progress=0
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

function animation_mt:set_stop(t)
	assert(type(t)=="number")
	self.max_progress=math.Clamp(t,0,self.length)
end

function animation_mt:update_time(dt)
	if not self.playing then return end
	self.progress=self.progress+dt
	if self.progress>self.length or self.progress>self.max_progress then 
		if self.looped then self.progress=0 return end
		self.progress=self.length
		self.playing=false
	end
end

function animation_mt:has_flex(name)
	return self.splines[name]~=nil
end

function animation_mt:update_flexes()
	if not self.playing then return end
	if not self.ent or not IsValid(self.ent) then print("flexaddon: warning, invalid entity ("..self.name..")") self:pause() return end
	for flex,spline in pairs(self.splines) do
		local fid=self.ent:GetFlexIDByName(flex)
		if fid then
			local weight=spline:sample_fofx(self:get_fraction())
			local min,max=self.ent:GetFlexBounds(fid)
			--all animations are flipped in the editor
			self.ent:SetFlexWeight(fid,weight*max)
		else
			print("flexaddon: warning, tried to animate invalid flex")
			self:pause()
			return
		end
	end
end

function animation_mt:set_looped(b)
	assert(type(b)=="boolean")
	self.looped=b
end

function animation_mt:get_length()
	return self.length
end

function animation_mt:play()
	self.progress=0
	self.playing=true
end

function animation_mt:pause()
	self.playing=false
end

function animation_mt:add_flex_curve(flex,spline)
	if self.splines[flex] then print("flexaddon: duplicate flex") return end
	self.splines[flex]=spline
	self.nsplines=self.nsplines+1
end

local ent_mt=FindMetaTable("Entity")

function ent_mt:play_animation(anim)
	anim:attach_entity(self)
	anim:play()
	self.flexanim=anim
end

hook.Add("HUDPaint","flexaddon_animate",function()
	for k,v in pairs(ents:GetAll()) do
		if v.flexanim then
			v.flexanim:update_time(FrameTime())
			v.flexanim:update_flexes()
			if v.flexanim.playing==false then
				v.flexanim=nil
			end
		end
	end
end)